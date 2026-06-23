"""Tests for the online metadata helpers in gui.py."""

import os
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from gui import build_online_metadata_fetch_kwargs, format_online_metadata
from gui import MediaDetailView, MediaItemWidget


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


class TestFetchOnlineMetadata(unittest.TestCase):
    """Regression: rating column does not exist in media_items schema."""

    def _make_item(self, **kwargs):
        defaults = dict(
            id=42, title="Inception", type="movie", source="netflix",
            provider_id="nf-123", artist=None, year=2010,
            description="Old description", provider_subtype=None,
            is_favorite=False, thumbnail_url=None, local_path=None,
        )
        defaults.update(kwargs)
        return SimpleNamespace(**defaults)

    def test_rating_not_included_in_db_update(self):
        """fetch_online_metadata must not include 'rating' in UPDATE — no such column in schema."""
        item = self._make_item()
        executed_queries = []

        mock_db = SimpleNamespace(execute=lambda q, p=None: executed_queries.append((q, p)))
        media_manager = SimpleNamespace(db=mock_db)
        blacklist_manager = SimpleNamespace(set_blacklist=lambda *a: None)

        widget = MediaItemWidget(item, media_manager, blacklist_manager)
        try:
            mock_fetcher = MagicMock()
            mock_fetcher.get_status.return_value = {"tmdb": True}
            mock_fetcher.auto_fetch.return_value = {
                "title": "Inception",
                "rating": 8.8,
                "description": "New description",
                "source": "tmdb",
            }
            with patch("metadata_v2.MetadataFetcher", return_value=mock_fetcher), \
                 patch("PySide6.QtWidgets.QMessageBox.information"), \
                 patch("gui.notify_gui_refresh"):
                widget.fetch_online_metadata()

            self.assertTrue(executed_queries, "Expected db.execute to be called for updates")
            sql, _ = executed_queries[-1]
            self.assertNotIn("rating", sql,
                "rating must not appear in UPDATE — no such column in media_items")
            self.assertIn("description", sql, "description should still be updated")
        finally:
            widget.close()
            widget.deleteLater()
            _app.processEvents()


class TestMediaItemWidgetAccessibility(unittest.TestCase):
    def _make_item(self, **kwargs):
        defaults = dict(
            id=7,
            title="Inception",
            type="movie",
            source="netflix",
            provider_id="nf-123",
            artist=None,
            year=2010,
            description=None,
            provider_subtype=None,
            is_favorite=False,
            thumbnail_url=None,
            local_path=None,
        )
        defaults.update(kwargs)
        return SimpleNamespace(**defaults)

    def test_compact_favorite_button_exposes_accessible_context(self):
        item = self._make_item()
        widget = MediaItemWidget(
            item,
            SimpleNamespace(db=MagicMock()),
            SimpleNamespace(set_blacklist=lambda *args: None),
        )
        try:
            self.assertEqual(widget.fav_btn.toolTip(), "Als Favorit markieren")
            self.assertEqual(
                widget.fav_btn.accessibleName(),
                "Inception als Favorit markieren",
            )
            self.assertIn("Inception", widget.fav_btn.accessibleDescription())
        finally:
            widget.close()
            widget.deleteLater()
            _app.processEvents()

    def test_compact_favorite_button_updates_accessible_name_for_favorites(self):
        item = self._make_item(is_favorite=True)
        widget = MediaItemWidget(
            item,
            SimpleNamespace(db=MagicMock()),
            SimpleNamespace(set_blacklist=lambda *args: None),
        )
        try:
            self.assertEqual(widget.fav_btn.toolTip(), "Favorit entfernen")
            self.assertEqual(
                widget.fav_btn.accessibleName(),
                "Inception aus Favoriten entfernen",
            )
        finally:
            widget.close()
            widget.deleteLater()
            _app.processEvents()

    def test_media_item_inlay_keeps_icons_and_actions_visible(self):
        item = self._make_item(title="Ein sehr langer Medientitel mit Zusatztext")
        widget = MediaItemWidget(
            item,
            SimpleNamespace(db=MagicMock()),
            SimpleNamespace(set_blacklist=lambda *args: None),
        )
        try:
            self.assertGreaterEqual(widget.minimumHeight(), 56)
            self.assertGreaterEqual(widget.type_icon_label.minimumWidth(), 36)
            self.assertGreaterEqual(widget.type_icon_label.minimumHeight(), 36)
            self.assertGreaterEqual(widget.fav_btn.minimumWidth(), 40)
            self.assertGreaterEqual(widget.fav_btn.minimumHeight(), 40)
            self.assertGreaterEqual(widget.open_btn.minimumHeight(), 36)
            self.assertGreaterEqual(widget.details_btn.minimumHeight(), 36)
        finally:
            widget.close()
            widget.deleteLater()
            _app.processEvents()


if __name__ == "__main__":
    unittest.main()
