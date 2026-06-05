"""Regression tests for MediaBrain export/import roundtrips."""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import Database
from export_import import (
    EXPORT_SCHEMA,
    EXPORT_SCHEMA_VERSION,
    MediaExporter,
    MediaImporter,
)
from playlists import PlaylistManager


class TestExportImportCsv(unittest.TestCase):
    def test_exported_csv_can_be_imported_again(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir = Path(tmpdir)
            source_db = Database(tmpdir / "source.db")
            try:
                source_db.execute(
                    """
                    INSERT INTO media_items
                        (title, type, source, provider_id, is_favorite, description)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    ("Test Film", "movie", "netflix", "abc123", 1, "Roundtrip check"),
                )

                csv_path = tmpdir / "library.csv"
                exporter = MediaExporter(source_db.conn)
                exported = exporter.export_csv(str(csv_path))
                self.assertEqual(exported, 1)
            finally:
                source_db.close()

            target_db = Database(tmpdir / "target.db")
            try:
                importer = MediaImporter(target_db.conn)
                stats = importer.import_csv(str(csv_path))

                self.assertEqual(stats["imported"], 1)
                self.assertEqual(stats["errors"], 0)

                rows = target_db.fetchall(
                    """
                    SELECT title, type, source, provider_id, is_favorite, description
                    FROM media_items
                    """
                )
                self.assertEqual(len(rows), 1)
                row = rows[0]
                self.assertEqual(row["title"], "Test Film")
                self.assertEqual(row["type"], "movie")
                self.assertEqual(row["source"], "netflix")
                self.assertEqual(row["provider_id"], "abc123")
                self.assertEqual(row["is_favorite"], 1)
                self.assertEqual(row["description"], "Roundtrip check")
            finally:
                target_db.close()


class TestExportImportJson(unittest.TestCase):
    def test_json_export_contains_schema_tags_and_playlist_refs(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir = Path(tmpdir)
            source_db = Database(tmpdir / "source.db")
            try:
                playlist_manager = PlaylistManager(source_db.conn)
                media_id = source_db.execute(
                    """
                    INSERT INTO media_items
                        (title, type, source, provider_id, is_favorite, description)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    ("Synthwave Mix", "music", "spotify", "track-42", 1, "Export schema"),
                ).lastrowid
                tag_id = source_db.execute(
                    "INSERT INTO tags (name, color) VALUES (?, ?)",
                    ("Favorit", "#ff9800"),
                ).lastrowid
                source_db.execute(
                    "INSERT INTO media_tags (media_id, tag_id) VALUES (?, ?)",
                    (media_id, tag_id),
                )
                playlist_id = playlist_manager.create_playlist(
                    "Unterwegs",
                    description="Mobile Begleiter",
                )
                playlist_manager.add_item(playlist_id, media_id)

                json_path = tmpdir / "mediabrain-library-v1.json"
                exporter = MediaExporter(source_db.conn)
                exported = exporter.export_json(str(json_path))
                self.assertEqual(exported, 1)

                payload = json.loads(json_path.read_text(encoding="utf-8"))
                self.assertEqual(payload["schema"], EXPORT_SCHEMA)
                self.assertEqual(payload["schema_version"], EXPORT_SCHEMA_VERSION)
                self.assertEqual(payload["app_name"], "MediaBrain Desktop")
                self.assertIn("app_version", payload)
                self.assertEqual(payload["capabilities"]["tags"], True)
                self.assertEqual(payload["capabilities"]["playlists"], True)

                item = payload["items"][0]
                self.assertEqual(item["tags"], ["Favorit"])

                playlist = payload["playlists"][0]
                self.assertEqual(playlist["name"], "Unterwegs")
                self.assertEqual(playlist["item_ids"], [media_id])
                self.assertEqual(
                    playlist["item_refs"][0],
                    {
                        "source": "spotify",
                        "provider_id": "track-42",
                        "title": "Synthwave Mix",
                        "type": "music",
                    },
                )
            finally:
                source_db.close()

    def test_json_roundtrip_restores_tags_and_playlists(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir = Path(tmpdir)
            source_db = Database(tmpdir / "source.db")
            try:
                playlist_manager = PlaylistManager(source_db.conn)
                media_id = source_db.execute(
                    """
                    INSERT INTO media_items
                        (title, type, source, provider_id, is_favorite)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    ("Archivfund", "document", "local", "doc-77", 0),
                ).lastrowid
                tag_id = source_db.execute(
                    "INSERT INTO tags (name) VALUES (?)",
                    ("Archiv",),
                ).lastrowid
                source_db.execute(
                    "INSERT INTO media_tags (media_id, tag_id) VALUES (?, ?)",
                    (media_id, tag_id),
                )
                playlist_id = playlist_manager.create_playlist("Leseliste")
                playlist_manager.add_item(playlist_id, media_id)

                json_path = tmpdir / "roundtrip.json"
                exporter = MediaExporter(source_db.conn)
                exporter.export_json(str(json_path))
            finally:
                source_db.close()

            target_db = Database(tmpdir / "target.db")
            try:
                PlaylistManager(target_db.conn)
                importer = MediaImporter(target_db.conn)
                stats = importer.import_json(str(json_path))

                self.assertEqual(stats["imported"], 1)
                self.assertEqual(stats["skipped"], 0)
                self.assertEqual(stats["errors"], 0)
                self.assertEqual(stats["playlists_imported"], 1)

                media_row = target_db.fetchone(
                    "SELECT id, title, source, provider_id FROM media_items"
                )
                self.assertIsNotNone(media_row)
                self.assertEqual(media_row["title"], "Archivfund")
                self.assertEqual(media_row["source"], "local")
                self.assertEqual(media_row["provider_id"], "doc-77")

                tags = target_db.fetchall(
                    """
                    SELECT t.name
                    FROM tags t
                    JOIN media_tags mt ON t.id = mt.tag_id
                    WHERE mt.media_id = ?
                    """,
                    (media_row["id"],),
                )
                self.assertEqual([row["name"] for row in tags], ["Archiv"])

                playlist_row = target_db.fetchone(
                    "SELECT id, name FROM playlists WHERE name = ?",
                    ("Leseliste",),
                )
                self.assertIsNotNone(playlist_row)
                playlist_items = target_db.fetchall(
                    "SELECT media_id FROM playlist_items WHERE playlist_id = ?",
                    (playlist_row["id"],),
                )
                self.assertEqual([row["media_id"] for row in playlist_items], [media_row["id"]])
            finally:
                target_db.close()


    def test_import_tag_case_mismatch_does_not_error(self):
        """Tag import must reuse existing tags case-insensitively (COLLATE NOCASE).

        If "Action" already exists in the DB and the JSON payload contains "action",
        _ensure_tag must find the existing row instead of attempting a duplicate INSERT
        that would raise IntegrityError and cause the item to be counted as an error.
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpdir = Path(tmpdir)
            db = Database(tmpdir / "test.db")
            try:
                db.execute("INSERT INTO tags (name) VALUES (?)", ("Action",))

                payload = {
                    "schema": EXPORT_SCHEMA,
                    "schema_version": EXPORT_SCHEMA_VERSION,
                    "items": [
                        {
                            "title": "Test Film",
                            "type": "movie",
                            "source": "netflix",
                            "provider_id": "nfx-1",
                            "tags": ["action"],  # lowercase variant
                        }
                    ],
                }
                json_path = tmpdir / "test.json"
                json_path.write_text(
                    json.dumps(payload), encoding="utf-8"
                )

                importer = MediaImporter(db.conn)
                stats = importer.import_json(str(json_path))

                self.assertEqual(stats["imported"], 1, "Item must be counted as imported")
                self.assertEqual(stats["errors"], 0, "No errors expected")

                tags = db.fetchall(
                    """
                    SELECT t.name FROM tags t
                    JOIN media_tags mt ON t.id = mt.tag_id
                    JOIN media_items m ON m.id = mt.media_id
                    WHERE m.provider_id = 'nfx-1'
                    """
                )
                self.assertEqual(len(tags), 1, "Item must have exactly one tag")
            finally:
                db.close()


if __name__ == "__main__":
    unittest.main()
