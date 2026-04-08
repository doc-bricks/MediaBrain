"""Export/Import functionality for MediaBrain.

Supports exporting the media library to JSON and CSV,
and importing from these formats.
"""

import csv
import json
import logging
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

logger = logging.getLogger("MediaBrain.ExportImport")


class MediaExporter:
    """Exports media library data to various formats."""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def export_json(self, output_path: str, include_tags: bool = True,
                   include_playlists: bool = True) -> int:
        """Exports the entire library to a JSON file.

        Args:
            output_path: Target file path.
            include_tags: Include tag associations.
            include_playlists: Include playlists and their items.

        Returns:
            Number of items exported.
        """
        self.conn.row_factory = sqlite3.Row
        items = self.conn.execute("SELECT * FROM media_items ORDER BY title").fetchall()

        data = {
            "version": "1.0",
            "exported_at": datetime.now().isoformat(),
            "item_count": len(items),
            "items": [],
        }

        for item in items:
            item_dict = dict(item)

            if include_tags:
                tags = self.conn.execute("""
                    SELECT t.name FROM tags t
                    JOIN media_tags mt ON t.id = mt.tag_id
                    WHERE mt.media_id = ?
                """, (item["id"],)).fetchall()
                item_dict["tags"] = [t["name"] for t in tags]

            data["items"].append(item_dict)

        if include_playlists:
            playlists = self.conn.execute("SELECT * FROM playlists").fetchall()
            data["playlists"] = []
            for pl in playlists:
                pl_dict = dict(pl)
                pl_items = self.conn.execute(
                    "SELECT media_id FROM playlist_items WHERE playlist_id = ? ORDER BY position",
                    (pl["id"],)
                ).fetchall()
                pl_dict["item_ids"] = [r["media_id"] for r in pl_items]
                data["playlists"].append(pl_dict)

        Path(output_path).write_text(
            json.dumps(data, indent=2, ensure_ascii=False, default=str),
            encoding="utf-8"
        )

        logger.info("Exportiert: %d Items nach %s", len(items), output_path)
        return len(items)

    def export_csv(self, output_path: str) -> int:
        """Exports media items to a CSV file.

        Args:
            output_path: Target file path.

        Returns:
            Number of items exported.
        """
        self.conn.row_factory = sqlite3.Row
        items = self.conn.execute("SELECT * FROM media_items ORDER BY title").fetchall()

        if not items:
            return 0

        fieldnames = items[0].keys()

        with open(output_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for item in items:
                writer.writerow(dict(item))

        logger.info("CSV-Export: %d Items nach %s", len(items), output_path)
        return len(items)


class MediaImporter:
    """Imports media library data from various formats."""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def import_json(self, input_path: str, merge: bool = True) -> Dict[str, int]:
        """Imports media items from a JSON file.

        Args:
            input_path: Source file path.
            merge: If True, skip existing items (by title+type). If False, replace.

        Returns:
            Dict with counts: imported, skipped, errors.
        """
        stats = {"imported": 0, "skipped": 0, "errors": 0}

        try:
            data = json.loads(Path(input_path).read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as e:
            logger.error("Import-Fehler: %s", e)
            stats["errors"] = 1
            return stats

        items = data.get("items", [])

        for item in items:
            try:
                title = item.get("title", "")
                item_type = item.get("type", "")

                if not title:
                    stats["errors"] += 1
                    continue

                if merge:
                    existing = self.conn.execute(
                        "SELECT id FROM media_items WHERE title = ? AND type = ?",
                        (title, item_type)
                    ).fetchone()
                    if existing:
                        stats["skipped"] += 1
                        continue

                # Felder filtern die in der DB existieren
                valid_fields = {
                    "title", "type", "provider", "source_url", "status",
                    "rating", "genre", "year", "duration_minutes",
                    "description", "poster_url", "is_favorite",
                    "watch_count", "last_watched",
                }
                filtered = {k: v for k, v in item.items() if k in valid_fields}

                columns = ", ".join(filtered.keys())
                placeholders = ", ".join(["?"] * len(filtered))
                self.conn.execute(
                    f"INSERT INTO media_items ({columns}) VALUES ({placeholders})",
                    list(filtered.values())
                )

                # Tags importieren
                if "tags" in item and isinstance(item["tags"], list):
                    media_id = self.conn.execute("SELECT last_insert_rowid()").fetchone()[0]
                    for tag_name in item["tags"]:
                        self._ensure_tag(tag_name, media_id)

                stats["imported"] += 1

            except Exception as e:
                logger.warning("Item-Import Fehler: %s (%s)", item.get("title", "?"), e)
                stats["errors"] += 1

        self.conn.commit()
        logger.info("Import abgeschlossen: %s", stats)
        return stats

    def import_csv(self, input_path: str) -> Dict[str, int]:
        """Imports media items from a CSV file.

        Args:
            input_path: Source file path.

        Returns:
            Dict with counts: imported, skipped, errors.
        """
        stats = {"imported": 0, "skipped": 0, "errors": 0}

        try:
            with open(input_path, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    try:
                        title = row.get("title", "")
                        if not title:
                            stats["errors"] += 1
                            continue

                        existing = self.conn.execute(
                            "SELECT id FROM media_items WHERE title = ? AND type = ?",
                            (title, row.get("type", ""))
                        ).fetchone()
                        if existing:
                            stats["skipped"] += 1
                            continue

                        valid_fields = {
                            "title", "type", "provider", "source_url", "status",
                            "rating", "genre", "year",
                        }
                        filtered = {k: v for k, v in row.items() if k in valid_fields and v}

                        columns = ", ".join(filtered.keys())
                        placeholders = ", ".join(["?"] * len(filtered))
                        self.conn.execute(
                            f"INSERT INTO media_items ({columns}) VALUES ({placeholders})",
                            list(filtered.values())
                        )
                        stats["imported"] += 1

                    except Exception as e:
                        logger.warning("CSV-Import Zeile Fehler: %s", e)
                        stats["errors"] += 1

            self.conn.commit()
        except (OSError, csv.Error) as e:
            logger.error("CSV-Import Fehler: %s", e)
            stats["errors"] += 1

        return stats

    def _ensure_tag(self, tag_name: str, media_id: int):
        """Ensures a tag exists and links it to a media item."""
        row = self.conn.execute(
            "SELECT id FROM tags WHERE name = ?", (tag_name,)
        ).fetchone()

        if row:
            tag_id = row[0]
        else:
            cursor = self.conn.execute(
                "INSERT INTO tags (name) VALUES (?)", (tag_name,)
            )
            tag_id = cursor.lastrowid

        self.conn.execute(
            "INSERT OR IGNORE INTO media_tags (media_id, tag_id) VALUES (?, ?)",
            (media_id, tag_id)
        )
