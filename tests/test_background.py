"""
Regression tests for background.py.

Bug: import os stand innerhalb von FileIndexer.scan() statt im Modul-Namespace.
_scan_recursive ist eine separate Methode und sieht lokale Variablen aus scan()
nicht — Ergebnis: NameError: name 'os' is not defined, still abgefangen von scan().
"""

import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock

sys.path.insert(0, str(Path(__file__).parent.parent))

from background import FileIndexer


class TestFileIndexerScan(unittest.TestCase):
    """Regression: import os war in scan() statt im Modul-Namespace."""

    def _make_indexer(self, watch_path):
        fake_processor = MagicMock()
        fake_processor.queue = MagicMock()
        indexer = FileIndexer(fake_processor)
        indexer.watch_paths = [Path(watch_path)]
        return indexer

    def test_scan_discovers_mp4_file(self):
        """scan() muss eine .mp4-Datei im Watch-Verzeichnis in known_files aufnehmen."""
        with tempfile.TemporaryDirectory() as tmpdir:
            media_file = Path(tmpdir) / "movie.mp4"
            media_file.touch()

            indexer = self._make_indexer(tmpdir)
            indexer.scan()

            self.assertIn(str(media_file.resolve()), indexer.known_files)

    def test_scan_ignores_non_media_files(self):
        """scan() darf .txt-Dateien nicht in known_files aufnehmen."""
        with tempfile.TemporaryDirectory() as tmpdir:
            txt_file = Path(tmpdir) / "readme.txt"
            txt_file.touch()

            indexer = self._make_indexer(tmpdir)
            indexer.scan()

            self.assertNotIn(str(txt_file.resolve()), indexer.known_files)

    def test_scan_discovers_nested_file(self):
        """scan() muss Mediendateien in Unterordnern rekursiv finden."""
        with tempfile.TemporaryDirectory() as tmpdir:
            subdir = Path(tmpdir) / "music"
            subdir.mkdir()
            audio_file = subdir / "track.mp3"
            audio_file.touch()

            indexer = self._make_indexer(tmpdir)
            indexer.scan()

            self.assertIn(str(audio_file.resolve()), indexer.known_files)


if __name__ == "__main__":
    unittest.main()
