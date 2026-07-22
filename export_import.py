"""Export/Import functionality for MediaBrain.

Supports exporting the media library to JSON and CSV,
and importing from these formats.
"""

import csv
import hashlib
import json
import logging
import os
import platform
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from version import __version__

logger = logging.getLogger("MediaBrain.ExportImport")

EXPORT_SCHEMA = "mediabrain-library-v1"
EXPORT_SCHEMA_VERSION = 1
EXPORT_APP_NAME = "MediaBrain Desktop"
LEGACY_EXPORT_VERSION = "1.0"


def _detect_app_version() -> str:
    """Returns a human-readable app version for exports.

    Environment overrides support reproducible packaging; otherwise the
    canonical Desktop release metadata is used.
    """
    for env_name in ("MEDIABRAIN_VERSION", "APP_VERSION"):
        value = os.getenv(env_name, "").strip()
        if value:
            return value
    return __version__


class MediaExporter:
    """Exports media library data to various formats."""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn

    def build_export_payload(
        self,
        include_tags: bool = True,
        include_playlists: bool = True,
        include_local_paths: bool = False,
    ) -> Dict[str, object]:
        """Builds the stable JSON exchange payload for MediaBrain exports."""
        self.conn.row_factory = sqlite3.Row
        items = self.conn.execute("SELECT * FROM media_items ORDER BY title").fetchall()
        app_version = _detect_app_version()

        data: Dict[str, object] = {
            "schema": EXPORT_SCHEMA,
            "schema_version": EXPORT_SCHEMA_VERSION,
            "version": LEGACY_EXPORT_VERSION,
            "app_name": EXPORT_APP_NAME,
            "app_version": app_version,
            "source": {
                "app_name": EXPORT_APP_NAME,
                "app_version": app_version,
                "platform": platform.system().lower(),
            },
            "capabilities": {
                "tags": include_tags,
                "playlists": include_playlists,
                "stable_media_refs": include_playlists,
                "legacy_alias_import": True,
                "local_paths": include_local_paths,
            },
            "exported_at": datetime.now().astimezone().isoformat(),
            "item_count": len(items),
            "items": [],
        }

        for item in items:
            item_dict = dict(item)
            if not include_local_paths:
                item_dict.pop("local_path", None)

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
                    """
                    SELECT
                        pi.media_id,
                        m.source,
                        m.provider_id,
                        m.title,
                        m.type
                    FROM playlist_items pi
                    INNER JOIN media_items m ON m.id = pi.media_id
                    WHERE pi.playlist_id = ?
                    ORDER BY pi.position
                    """,
                    (pl["id"],)
                ).fetchall()
                pl_dict["item_ids"] = [r["media_id"] for r in pl_items]
                pl_dict["item_refs"] = [
                    {
                        "source": r["source"],
                        "provider_id": r["provider_id"],
                        "title": r["title"],
                        "type": r["type"],
                    }
                    for r in pl_items
                ]
                data["playlists"].append(pl_dict)

        return data

    def export_json(self, output_path: str, include_tags: bool = True,
                   include_playlists: bool = True,
                   include_local_paths: bool = False) -> int:
        """Exports the entire library to a JSON file.

        Args:
            output_path: Target file path.
            include_tags: Include tag associations.
            include_playlists: Include playlists and their items.

        Returns:
            Number of items exported.
        """
        data = self.build_export_payload(
            include_tags=include_tags,
            include_playlists=include_playlists,
            include_local_paths=include_local_paths,
        )

        Path(output_path).write_text(
            json.dumps(data, indent=2, ensure_ascii=False, default=str),
            encoding="utf-8"
        )

        item_count = int(data.get("item_count", 0))
        logger.info("Exportiert: %d Items nach %s", item_count, output_path)
        return item_count

    def export_csv(self, output_path: str, include_local_paths: bool = False) -> int:
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

        fieldnames = list(items[0].keys())
        if not include_local_paths and "local_path" in fieldnames:
            fieldnames.remove("local_path")

        with open(output_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for item in items:
                item_dict = dict(item)
                if not include_local_paths:
                    item_dict.pop("local_path", None)
                writer.writerow(item_dict)

        logger.info("CSV-Export: %d Items nach %s", len(items), output_path)
        return len(items)


class MediaImporter:
    """Imports media library data from various formats."""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn
        self.conn.row_factory = sqlite3.Row
        self.media_columns = self._get_media_columns()
        self.playlist_columns = self._get_playlist_columns()

    def import_json(self, input_path: str, merge: bool = True) -> Dict[str, int]:
        """Imports media items from a JSON file.

        Args:
            input_path: Source file path.
            merge: If True, skip existing items (by title+type). If False, replace.

        Returns:
            Dict with counts: imported, skipped, errors, playlists_imported, playlists_skipped.
        """
        stats = {
            "imported": 0,
            "skipped": 0,
            "errors": 0,
            "playlists_imported": 0,
            "playlists_skipped": 0,
        }

        try:
            data = json.loads(Path(input_path).read_text(encoding="utf-8-sig"))
        except (json.JSONDecodeError, OSError) as e:
            logger.error("Import-Fehler: %s", e)
            stats["errors"] = 1
            return stats

        if not isinstance(data, dict):
            logger.error("Import-Fehler: JSON-Wurzel ist kein Objekt")
            stats["errors"] = 1
            return stats

        error = self._validate_payload_metadata(data)
        if error:
            logger.error("Import-Fehler: %s", error)
            stats["errors"] = 1
            return stats

        items = data.get("items", [])
        if not isinstance(items, list):
            logger.error("Import-Fehler: Kein items-Array im JSON gefunden")
            stats["errors"] += 1
            return stats

        for item in items:
            if not isinstance(item, dict):
                stats["errors"] += 1
                continue
            try:
                item = self._normalize_item_payload(item)
                title = str(item.get("title", "")).strip()
                item_type = str(item.get("type", "")).strip()
                source = str(item.get("source", "")).strip()
                provider_id = str(item.get("provider_id", "")).strip()

                if not title or not item_type or not source:
                    stats["errors"] += 1
                    continue

                if not provider_id:
                    provider_id = self._make_provider_id(source, item.get("title", ""))
                    item["provider_id"] = provider_id

                existing_id = self._find_existing_media(
                    title=title,
                    media_type=item_type,
                    source=source,
                    provider_id=provider_id,
                )
                if merge:
                    if existing_id:
                        stats["skipped"] += 1
                        continue
                else:
                    if existing_id:
                        self._delete_media_by_id(existing_id)

                # Felder filtern die in der DB existieren
                filtered = self._filter_media_fields(item)
                if not filtered:
                    stats["errors"] += 1
                    continue

                columns = ", ".join(filtered.keys())
                placeholders = ", ".join(["?"] * len(filtered))
                cursor = self.conn.execute(
                    f"INSERT INTO media_items ({columns}) VALUES ({placeholders})",
                    list(filtered.values())
                )
                media_id = cursor.lastrowid
                self.conn.commit()

                # Tags importieren
                if "tags" in item and isinstance(item["tags"], list):
                    for tag_name in item["tags"]:
                        self._ensure_tag(tag_name, media_id)

                stats["imported"] += 1

            except Exception as e:
                logger.warning("Item-Import Fehler: %s (%s)", item.get("title", "?"), e)
                stats["errors"] += 1

        self.conn.commit()
        logger.info("Import abgeschlossen: %s", stats)
        self._import_playlists(data.get("playlists", []), merge=merge, stats=stats)
        self.conn.commit()
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
            with open(input_path, "r", newline="", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    try:
                        if not isinstance(row, dict):
                            stats["errors"] += 1
                            continue

                        item = self._normalize_item_payload(row)
                        title = str(item.get("title", "")).strip()
                        item_type = str(item.get("type", "")).strip()
                        source = str(item.get("source", "")).strip()
                        provider_id = str(item.get("provider_id", "")).strip()

                        if not title or not item_type or not source:
                            stats["errors"] += 1
                            continue

                        if not provider_id:
                            provider_id = self._make_provider_id(source, title)
                            item["provider_id"] = provider_id

                        existing_id = self._find_existing_media(
                            title=title,
                            media_type=item_type,
                            source=source,
                            provider_id=provider_id,
                        )
                        if existing_id:
                            stats["skipped"] += 1
                            continue

                        filtered = self._filter_media_fields(item)
                        if not filtered:
                            stats["errors"] += 1
                            continue

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

    def _get_media_columns(self) -> set:
        rows = self.conn.execute("PRAGMA table_info(media_items)").fetchall()
        return {row["name"] for row in rows}

    def _get_playlist_columns(self) -> set:
        try:
            rows = self.conn.execute("PRAGMA table_info(playlists)").fetchall()
            return {row["name"] for row in rows}
        except sqlite3.DatabaseError:
            return set()

    def _filter_media_fields(self, item: Dict) -> Dict:
        item = dict(item)
        item["source"] = item.get("source", "") or item.get("provider", "")
        item["provider_id"] = item.get("provider_id", "") or self._make_provider_id(
            item.get("source", ""), item.get("title", "")
        )

        valid_fields = {
            "title", "type", "source", "provider_id", "provider_subtype",
            "length_seconds", "created_at",
            "last_opened_at", "open_method", "is_favorite", "is_local_file",
            "local_path", "description", "thumbnail_url", "season", "episode",
            "artist", "album", "channel", "blacklist_flag", "blacklisted_at",
            "procedure_code",
        }
        filtered = {}
        for key, value in item.items():
            if key not in valid_fields:
                continue
            if key not in self.media_columns:
                continue
            if value is None or value == "":
                continue
            filtered[key] = self._coerce_value(key, value)

        required = {"title", "type", "source", "provider_id"}
        if not required.issubset(filtered):
            return {}

        return filtered

    def _coerce_value(self, field: str, value):
        if field in {"is_favorite", "is_local_file", "blacklist_flag", "procedure_code"}:
            if isinstance(value, bool):
                return int(value)
            if str(value).strip().lower() in {"true", "1", "yes", "ja"}:
                return 1
            if str(value).strip().lower() in {"false", "0", "no", "nein"}:
                return 0
            try:
                return int(value)
            except (TypeError, ValueError):
                return 0

        if field in {"length_seconds", "season", "episode"}:
            try:
                return int(value)
            except (TypeError, ValueError):
                return 0

        if isinstance(value, (dict, list)):
            return json.dumps(value, ensure_ascii=False, sort_keys=True, default=str)

        return value

    def _make_provider_id(self, source: str, title: str) -> str:
        seed = f"{source}|{title}".strip()
        return hashlib.md5(seed.encode("utf-8")).hexdigest()[:16]

    def _find_existing_media(self, title: str, media_type: str,
                            source: str, provider_id: str) -> Optional[int]:
        if source and provider_id:
            row = self.conn.execute(
                "SELECT id FROM media_items WHERE source = ? AND provider_id = ? LIMIT 1",
                (source, provider_id)
            ).fetchone()
            if row:
                return row["id"]

        row = self.conn.execute(
            "SELECT id FROM media_items WHERE title = ? AND type = ? LIMIT 1",
            (title, media_type)
        ).fetchone()
        return row["id"] if row else None

    def _delete_media_by_id(self, media_id: int) -> None:
        self.conn.execute("DELETE FROM playlist_items WHERE media_id = ?", (media_id,))
        self.conn.execute("DELETE FROM media_tags WHERE media_id = ?", (media_id,))
        self.conn.execute("DELETE FROM media_items WHERE id = ?", (media_id,))

    def _normalize_item_payload(self, item: Dict) -> Dict:
        normalized = dict(item)
        if "provider" in normalized and "source" not in normalized:
            normalized["source"] = normalized["provider"]
        if "source_url" in normalized and "source" not in normalized:
            normalized["source"] = normalized["source_url"]
        if "status" in normalized and "provider_id" not in normalized:
            normalized["provider_id"] = normalized["status"]
        if "duration_minutes" in normalized and "length_seconds" not in normalized:
            minutes = normalized.get("duration_minutes")
            try:
                normalized["length_seconds"] = int(minutes) * 60
            except (TypeError, ValueError):
                normalized["length_seconds"] = 0
        if "is_favourite" in normalized and "is_favorite" not in normalized:
            normalized["is_favorite"] = normalized["is_favourite"]
        return normalized

    def _validate_payload_metadata(self, payload: Dict) -> Optional[str]:
        schema = payload.get("schema")
        if schema not in (None, "", EXPORT_SCHEMA):
            return (
                f"Schema '{schema}' wird nicht unterstützt "
                f"(erwartet: {EXPORT_SCHEMA})."
            )

        schema_version = payload.get("schema_version")
        if schema_version in (None, ""):
            return None

        try:
            normalized = int(schema_version)
        except (TypeError, ValueError):
            return f"Ungültige schema_version: {schema_version!r}"

        if normalized != EXPORT_SCHEMA_VERSION:
            return (
                f"schema_version {normalized} wird nicht unterstützt "
                f"(erwartet: {EXPORT_SCHEMA_VERSION})."
            )

        return None

    def _import_playlists(self, playlists, merge: bool, stats: Dict[str, int]) -> None:
        if not isinstance(playlists, list) or not playlists:
            return
        if not self.playlist_columns:
            logger.warning("Keine playlists-Tabelle gefunden - Playlist-Import übersprungen.")
            return

        for raw in playlists:
            if not isinstance(raw, dict):
                continue

            name = str(raw.get("name", "")).strip()
            if not name:
                continue

            playlist_type = str(raw.get("playlist_type", "manual")).strip() or "manual"
            smart_query = raw.get("smart_query", "")

            existing = self.conn.execute(
                "SELECT id FROM playlists WHERE name = ? LIMIT 1", (name,)
            ).fetchone()
            if existing:
                if merge:
                    stats["playlists_skipped"] += 1
                    continue
                self.conn.execute("DELETE FROM playlist_items WHERE playlist_id = ?", (existing["id"],))
                self.conn.execute("DELETE FROM playlists WHERE id = ?", (existing["id"],))

            valid_fields = {"name", "description", "playlist_type", "smart_query"}
            filtered = {
                key: self._coerce_value(key, raw[key])
                for key in valid_fields
                if key in raw and key in self.playlist_columns
            }
            filtered["name"] = name
            filtered["playlist_type"] = playlist_type
            filtered["smart_query"] = smart_query
            filtered = {
                k: v for k, v in filtered.items()
                if k in self.playlist_columns
            }

            columns = ", ".join(filtered.keys())
            placeholders = ", ".join("?" * len(filtered))
            playlist_id = self.conn.execute(
                f"INSERT INTO playlists ({columns}) VALUES ({placeholders})",
                list(filtered.values())
            ).lastrowid

            for entry in raw.get("item_refs", []):
                if not isinstance(entry, dict):
                    continue
                media_id = self._find_existing_media(
                    title=str(entry.get("title", "")).strip(),
                    media_type=str(entry.get("type", "")).strip(),
                    source=str(entry.get("source", "")).strip(),
                    provider_id=str(entry.get("provider_id", "")).strip(),
                )
                if not media_id:
                    continue
                self.conn.execute(
                    "INSERT OR IGNORE INTO playlist_items (playlist_id, media_id, position) "
                    "VALUES (?, ?, COALESCE((SELECT MAX(position)+1 FROM playlist_items WHERE playlist_id=?), 0))",
                    (playlist_id, media_id, playlist_id),
                )

            stats["playlists_imported"] += 1
