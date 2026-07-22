"""Regression tests for the official read-only MediaBrain CLI."""

import argparse
import io
import sqlite3
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

import cli


SCHEMA = """
CREATE TABLE media_items (
    id INTEGER PRIMARY KEY,
    title TEXT,
    type TEXT,
    source TEXT,
    provider_id TEXT,
    is_favorite INTEGER DEFAULT 0,
    blacklist_flag INTEGER DEFAULT 0,
    artist TEXT,
    description TEXT,
    channel TEXT,
    last_opened_at TEXT,
    length_seconds INTEGER
)
"""


class TestReadOnlyCli(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db_path = Path(self.temp.name) / "library.db"
        conn = sqlite3.connect(self.db_path)
        conn.executescript(SCHEMA)
        conn.executemany(
            """
            INSERT INTO media_items
                (id, title, type, source, provider_id, is_favorite,
                 blacklist_flag, artist, last_opened_at, length_seconds)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (1, "Visible", "document", "local", "visible", 1, 0,
                 "Künstlerin", "2026-07-20T12:00:00", 61),
                (2, "Hidden", "movie", "netflix", "hidden", 0, 1,
                 None, None, None),
            ],
        )
        conn.commit()
        conn.close()

    def tearDown(self):
        self.temp.cleanup()

    def test_connection_is_enforced_read_only(self):
        conn = cli._open(self.db_path)
        try:
            self.assertEqual(conn.execute("PRAGMA query_only").fetchone()[0], 0)
            with self.assertRaises(sqlite3.OperationalError):
                conn.execute("DELETE FROM media_items")
        finally:
            conn.close()

    def test_numeric_show_honors_blacklist(self):
        conn = cli._open(self.db_path)
        output = io.StringIO()
        try:
            with redirect_stdout(output):
                result = cli.cmd_show(
                    conn,
                    argparse.Namespace(id_or_title="2"),
                )
        finally:
            conn.close()
        self.assertEqual(result, 1)
        self.assertNotIn("Hidden", output.getvalue())

    def test_list_and_types_show_only_visible_entries(self):
        conn = cli._open(self.db_path)
        output = io.StringIO()
        try:
            with redirect_stdout(output):
                self.assertEqual(
                    cli.cmd_list(
                        conn,
                        argparse.Namespace(type=None, limit=50),
                    ),
                    0,
                )
                self.assertEqual(cli.cmd_types(conn), 0)
        finally:
            conn.close()
        text = output.getvalue()
        self.assertIn("Visible", text)
        self.assertIn("document", text)
        self.assertNotIn("Hidden", text)
        self.assertNotIn("movie", text)


if __name__ == "__main__":
    unittest.main()
