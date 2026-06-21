"""Regression tests for the 2026-06-21 desktop bugsweep of MediaBrain.

Covered:
  D1 translator._is_german: iterated over single ASCII chars ("aeoeue...") so almost
     every string (incl. English) counted as German -> polluted translations.json.
  C1 export_import.import_json: UTF-8 BOM made json.loads fail -> 0 items, silent.
  C2 export_import.import_csv: UTF-8 BOM corrupted the first ("title") column header
     -> every row dropped as missing-required-field.
  C3 providers.clean_window_title: a zero-width space (U+200B) inside the
     " - Microsoft Edge" literal meant the real Edge suffix never matched.
(B1 add_or_update re-raise and B3 refresh_blacklist timestamp guard are covered by
 code review — they need full DB/event harness setup; the fixes are localized.)
"""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import Database
from export_import import MediaExporter, MediaImporter
from playlists import PlaylistManager
from providers import clean_window_title
from translator import TranslationSystem


class IsGermanTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tr = TranslationSystem(app_dir=Path(self._tmp.name))

    def tearDown(self):
        self._tmp.cleanup()

    def test_english_is_not_german(self):
        self.assertFalse(self.tr._is_german("Save Close Search Open"))

    def test_real_umlaut_is_german(self):
        self.assertTrue(self.tr._is_german("Größe ändern"))


class CleanWindowTitleTests(unittest.TestCase):
    def test_edge_suffix_stripped(self):
        self.assertEqual(clean_window_title("Mein Video - Microsoft Edge", []), "Mein Video")


class BomImportTests(unittest.TestCase):
    def test_json_with_bom_imports(self):
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            src = Database(d / "src.db")
            try:
                PlaylistManager(src.conn)  # ensures playlists schema for export
                src.execute(
                    "INSERT INTO media_items (title, type, source, provider_id) VALUES (?, ?, ?, ?)",
                    ("Mein Film", "movie", "netflix", "pid1"),
                )
                src.conn.commit()
                jp = d / "lib.json"
                MediaExporter(src.conn).export_json(str(jp))
            finally:
                src.conn.close()
            # Prepend a UTF-8 BOM (Excel/Windows default).
            jp.write_text("﻿" + jp.read_text(encoding="utf-8"), encoding="utf-8")
            dst = Database(d / "dst.db")
            try:
                PlaylistManager(dst.conn)  # playlists schema for import side
                stats = MediaImporter(dst.conn).import_json(str(jp))
            finally:
                dst.conn.close()
            self.assertGreaterEqual(stats["imported"], 1, stats)

    def test_csv_with_bom_imports(self):
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            cp = d / "lib.csv"
            # 'title' is the first column -> a BOM corrupts exactly the required header.
            cp.write_text("﻿title,type,source\nMein Film,movie,netflix\n", encoding="utf-8")
            dst = Database(d / "dst.db")
            try:
                stats = MediaImporter(dst.conn).import_csv(str(cp))
            finally:
                dst.conn.close()
            self.assertGreaterEqual(stats["imported"], 1, stats)


if __name__ == "__main__":
    unittest.main()
