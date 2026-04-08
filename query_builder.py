"""Query Builder for MediaBrain advanced filtering.

Allows constructing complex SQL queries from filter conditions.
Used by smart playlists and the advanced search interface.

Usage:
    qb = QueryBuilder()
    qb.add_condition("type", "=", "movie")
    qb.add_condition("rating", ">=", 7.0)
    qb.add_condition("tags", "contains", "Action")
    sql, params = qb.build()
"""

import json
import logging
from typing import List, Tuple, Any, Optional
from dataclasses import dataclass, field

logger = logging.getLogger("MediaBrain.QueryBuilder")


@dataclass
class FilterCondition:
    """A single filter condition."""
    field: str
    operator: str   # "=", "!=", ">", ">=", "<", "<=", "contains", "starts_with", "not_contains"
    value: Any
    conjunction: str = "AND"  # "AND" or "OR"


class QueryBuilder:
    """Builds SQL WHERE clauses from filter conditions."""

    VALID_FIELDS = {
        "title", "type", "provider", "status", "rating",
        "year", "genre", "source_url", "is_favorite",
        "watch_count", "last_watched", "created_at", "tags",
    }

    VALID_OPERATORS = {
        "=", "!=", ">", ">=", "<", "<=",
        "contains", "starts_with", "not_contains",
        "is_empty", "is_not_empty",
    }

    def __init__(self):
        self.conditions: List[FilterCondition] = []
        self.order_by: Optional[str] = None
        self.order_dir: str = "ASC"
        self.limit: Optional[int] = None

    def add_condition(self, field: str, operator: str, value: Any = None,
                     conjunction: str = "AND"):
        """Adds a filter condition.

        Args:
            field: Column name (must be in VALID_FIELDS).
            operator: Comparison operator.
            value: Filter value.
            conjunction: AND/OR with previous condition.
        """
        if field not in self.VALID_FIELDS:
            logger.warning("Unbekanntes Feld: %s", field)
            return
        if operator not in self.VALID_OPERATORS:
            logger.warning("Unbekannter Operator: %s", operator)
            return

        self.conditions.append(FilterCondition(
            field=field, operator=operator, value=value,
            conjunction=conjunction
        ))

    def set_order(self, field: str, direction: str = "ASC"):
        """Sets the ORDER BY clause."""
        if field in self.VALID_FIELDS:
            self.order_by = field
            self.order_dir = direction.upper()

    def set_limit(self, limit: int):
        """Sets the LIMIT clause."""
        self.limit = max(1, limit)

    def build(self) -> Tuple[str, list]:
        """Builds the SQL query.

        Returns:
            Tuple of (SQL WHERE clause starting with SELECT, list of parameters).
        """
        base = "SELECT * FROM media_items"
        params = []
        where_parts = []

        for i, cond in enumerate(self.conditions):
            clause, clause_params = self._build_condition(cond)
            if clause:
                if i > 0:
                    where_parts.append(cond.conjunction)
                where_parts.append(clause)
                params.extend(clause_params)

        sql = base
        if where_parts:
            sql += " WHERE " + " ".join(where_parts)

        if self.order_by:
            sql += f" ORDER BY {self.order_by} {self.order_dir}"

        if self.limit:
            sql += f" LIMIT {self.limit}"

        return sql, params

    def _build_condition(self, cond: FilterCondition) -> Tuple[str, list]:
        """Builds a single WHERE condition."""
        field = cond.field
        op = cond.operator
        val = cond.value

        # Tag-Suche ist ein Sonderfall (JOIN mit tags/media_tags)
        if field == "tags":
            return self._build_tag_condition(op, val)

        if op == "contains":
            return f"{field} LIKE ?", [f"%{val}%"]
        elif op == "starts_with":
            return f"{field} LIKE ?", [f"{val}%"]
        elif op == "not_contains":
            return f"{field} NOT LIKE ?", [f"%{val}%"]
        elif op == "is_empty":
            return f"({field} IS NULL OR {field} = '')", []
        elif op == "is_not_empty":
            return f"({field} IS NOT NULL AND {field} != '')", []
        elif op in ("=", "!=", ">", ">=", "<", "<="):
            return f"{field} {op} ?", [val]

        return "", []

    def _build_tag_condition(self, op: str, tag_name: str) -> Tuple[str, list]:
        """Builds a subquery for tag filtering."""
        if op == "contains":
            return (
                "id IN (SELECT media_id FROM media_tags mt "
                "JOIN tags t ON mt.tag_id = t.id WHERE t.name LIKE ?)",
                [f"%{tag_name}%"]
            )
        elif op == "not_contains":
            return (
                "id NOT IN (SELECT media_id FROM media_tags mt "
                "JOIN tags t ON mt.tag_id = t.id WHERE t.name LIKE ?)",
                [f"%{tag_name}%"]
            )
        elif op == "=":
            return (
                "id IN (SELECT media_id FROM media_tags mt "
                "JOIN tags t ON mt.tag_id = t.id WHERE t.name = ?)",
                [tag_name]
            )
        return "", []

    def clear(self):
        """Removes all conditions."""
        self.conditions.clear()
        self.order_by = None
        self.limit = None

    def to_json(self) -> str:
        """Serializes the query to JSON (for smart playlists)."""
        data = {
            "conditions": [
                {"field": c.field, "operator": c.operator,
                 "value": c.value, "conjunction": c.conjunction}
                for c in self.conditions
            ],
            "order_by": self.order_by,
            "order_dir": self.order_dir,
            "limit": self.limit,
        }
        return json.dumps(data)

    @classmethod
    def from_json(cls, json_str: str) -> "QueryBuilder":
        """Deserializes a QueryBuilder from JSON."""
        qb = cls()
        try:
            data = json.loads(json_str)
            for c in data.get("conditions", []):
                qb.add_condition(
                    c["field"], c["operator"], c.get("value"),
                    c.get("conjunction", "AND")
                )
            if data.get("order_by"):
                qb.set_order(data["order_by"], data.get("order_dir", "ASC"))
            if data.get("limit"):
                qb.set_limit(data["limit"])
        except (json.JSONDecodeError, KeyError, TypeError) as e:
            logger.error("QueryBuilder JSON Parse Fehler: %s", e)
        return qb
