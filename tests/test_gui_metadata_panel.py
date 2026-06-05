"""Tests for the online metadata helpers in gui.py."""

import os
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from gui import build_online_metadata_fetch_kwargs, format_online_metadata
from gui import MediaDetailView


_app = QApplication.instance() or QApplication(sys.argv)


def _layout_texts(layout):
    texts = []
    for index in range(layout.count()):
        widget = layout.itemAt(index).widget()
        if widget is not None and hasattr(widget, "text"):
            texts.append(widget.text())
    return texts

class TestOnlineMetadataHelpers(unittest.TestCase):
    def test_fetch_kwargs_for_movie_item(self):
        item = SimpleNamespace(
            title="Inception",
            type="movie",
            source="netflix",
            provider_id="nf-123",
            artist=None,
            local_path=None,
        )

        kwargs = build_online_metadata_fetch_kwargs(item)

        self.assertEqual(kwargs["title"], "Inception")
        self.assertEqual(kwargs["media_type"], "movie")
        self.assertEqual(kwargs["source"], "netflix")
        self.assertEqual(kwargs["provider_id"], "nf-123")
        self.assertNotIn("url", kwargs)

    def test_fetch_kwargs_for_youtube_clip_uses_clip_mode_and_url(self):
        item = SimpleNamespace(
            title="Demo Clip",
            type="clip",
            source="youtube",
            provider_id="dQw4w9WgXcQ",
            artist=None,
            local_path="https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        )

        kwargs = build_online_metadata_fetch_kwargs(item)

        self.assertEqual(kwargs["media_type"], "clip")
        self.assertEqual(kwargs["url"], "https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    def test_format_online_metadata_includes_common_fields(self):
        result = {
            "title": "Inception",
            "year": "2010",
            "rating": 8.8,
            "genres": ["Action", "Sci-Fi"],
            "runtime": 148,
            "director": "Christopher Nolan",
            "source": "tmdb",
            "description": "A dream within a dream.",
            "thumbnail_url": "https://example.com/poster.jpg",
        }

        lines, description, message = format_online_metadata(result, current_description="Local description")

        self.assertIsNone(message)
        self.assertIn("Titel: Inception", lines)
        self.assertIn("Jahr: 2010", lines)
        self.assertIn("Bewertung: 8.8/10", lines)
        self.assertIn("Genres: Action, Sci-Fi", lines)
        self.assertIn("Laufzeit: 148 Min", lines)
        self.assertIn("Regie: Christopher Nolan", lines)
        self.assertIn("Quelle: tmdb", lines)
        self.assertIn("Vorschaubild: verfügbar", lines)
        self.assertEqual(description, "A dream within a dream.")

    def test_format_online_metadata_truncates_long_description(self):
        result = {
            "title": "Clip",
            "description": "x" * 600,
        }

        lines, description, message = format_online_metadata(result)

        self.assertIsNone(message)
        self.assertEqual(lines, ["Titel: Clip"])
        self.assertTrue(description.endswith("..."))
        self.assertLessEqual(len(description), 503)

    def test_format_online_metadata_handles_errors(self):
        lines, description, message = format_online_metadata({"error": "boom"})

        self.assertEqual(lines, [])
        self.assertIsNone(description)
        self.assertEqual(message, "Fehler: boom")

    def test_media_detail_view_shows_loaded_metadata(self):
        item = SimpleNamespace(
            title="Inception",
            type="movie",
            source="netflix",
            provider_id="nf-123",
            artist=None,
            created_at="2026-05-11T10:00:00",
            last_opened_at=None,
            open_method="auto",
            is_favorite=False,
            thumbnail_url=None,
            description="Lokale Beschreibung",
            local_path=None,
        )

        media_manager = SimpleNamespace(db=SimpleNamespace(execute=lambda *args, **kwargs: None))
        blacklist_manager = SimpleNamespace()

        class InlineThread:
            def __init__(self, target, daemon=True):
                self.target = target

            def start(self):
                self.target()

        with patch("gui.Thread", InlineThread):
            with patch("metadata_v2.MetadataFetcher.auto_fetch", return_value={
                "title": "Inception",
                "year": "2010",
                "rating": 8.8,
                "genres": ["Action", "Sci-Fi"],
                "runtime": 148,
                "director": "Christopher Nolan",
                "source": "tmdb",
                "description": "A dream within a dream.",
            }):
                widget = MediaDetailView(item, media_manager, blacklist_manager, lambda: None)
                try:
                    texts = _layout_texts(widget.online_meta_container)
                    joined = "\n".join(texts)
                    self.assertIn("Titel: Inception", joined)
                    self.assertIn("Bewertung: 8.8/10", joined)
                    self.assertIn("Online-Beschreibung:", joined)
                finally:
                    widget.close()
                    widget.deleteLater()
                    _app.processEvents()


if __name__ == "__main__":
    unittest.main()
