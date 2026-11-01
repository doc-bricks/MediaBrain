"""Regression tests for the official read-only MediaBrain CLI."""

import argparse
import io
import json
import os
import sqlite3
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest.mock import patch

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


    def test_cli_selects_each_worldset_locale_and_keeps_database_read_only(self):
        catalog_path = Path(cli.__file__).resolve().parent / 'locales' / 'translations.json'
        catalog = json.loads(catalog_path.read_text(encoding='utf-8'))
        before = self.db_path.read_bytes()
        for lang in ['de', 'en', 'es', 'zh', 'ja', 'ru', 'fr', 'hi', 'ar', 'bn', 'pt']:
            with self.subTest(lang=lang):
                output = io.StringIO()
                with redirect_stdout(output):
                    result = cli.main([
                        '--db', str(self.db_path), '--lang', lang, 'show', '1'
                    ])
                self.assertEqual(result, 0)
                self.assertIn(catalog['Titel:'][lang], output.getvalue())
                self.assertIn('Visible', output.getvalue())
        self.assertEqual(before, self.db_path.read_bytes())

    def test_cli_language_option_after_subcommand_is_supported(self):
        output = io.StringIO()
        with redirect_stdout(output):
            result = cli.main([
                '--db', str(self.db_path), 'show', '1', '--lang', 'fr'
            ])
        self.assertEqual(result, 0)
        self.assertIn('Titre :', output.getvalue())


    def test_all_cli_commands_translate_result_messages(self):
        expected = {
            'list': 'Entrées : 1 (max. 50)',
            'search': 'Résultats : 1',
            'favs': 'Favoris : 1',
            'recent': 'Ouverts récemment : 1',
            'types': 'Entrées : 1',
        }
        for command, phrase in expected.items():
            with self.subTest(command=command):
                output = io.StringIO()
                argv = ['--lang', 'fr', '--db', str(self.db_path), command]
                if command == 'search':
                    argv.append('Visible')
                with redirect_stdout(output):
                    result = cli.main(argv)
                self.assertEqual(result, 0)
                self.assertIn(phrase, output.getvalue())

    def test_help_uses_selected_language_for_argparse_and_application_text(self):
        output = io.StringIO()
        with redirect_stdout(output):
            with self.assertRaises(SystemExit) as raised:
                cli.main(['--lang', 'es', '--help'])
        self.assertEqual(raised.exception.code, 0)
        self.assertIn('uso: ', output.getvalue())
        self.assertIn('opciones', output.getvalue())
        self.assertIn('solo lectura', output.getvalue())
        self.assertIn('Idioma de la CLI', output.getvalue())

    def test_environment_language_accepts_regional_code(self):
        output = io.StringIO()
        with patch.dict(os.environ, {'MEDIABRAIN_LANG': 'pt_BR'}):
            with redirect_stdout(output):
                result = cli.main(['--db', str(self.db_path), 'show', '1'])
        self.assertEqual(result, 0)
        self.assertIn('Título:', output.getvalue())

    def test_missing_database_keeps_exit_code_and_localizes_error(self):
        missing = Path(self.temp.name) / 'missing.db'
        error = io.StringIO()
        with redirect_stderr(error):
            with self.assertRaises(SystemExit) as raised:
                cli.main(['--lang', 'fr', '--db', str(missing), 'list'])
        self.assertEqual(raised.exception.code, 1)
        self.assertIn('Base de données introuvable', error.getvalue())

    def test_argparse_invalid_locale_keeps_usage_error_exit_code(self):
        error = io.StringIO()
        with redirect_stderr(error):
            with self.assertRaises(SystemExit) as raised:
                cli.main(['--lang', 'xx', 'list'])
        self.assertEqual(raised.exception.code, 2)
        self.assertIn('Ungültige Auswahl', error.getvalue())


if __name__ == "__main__":
    unittest.main()
