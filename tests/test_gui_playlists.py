"""Smoke tests for the playlist GUI (gui_playlists.py).

These tests run with QT_QPA_PLATFORM=offscreen so they work without a real
display. They cover:
- SmartPlaylistDialog round-trip: create -> serialize -> reload
- ManualPlaylistDialog name/description capture
- PlaylistsView: refresh, selection, item population for both manual and
  smart playlists
"""

import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

# Run Qt headless. Must be set BEFORE QApplication is created.
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from core import Database, TagManager
from playlists import PlaylistManager
from query_builder import QueryBuilder

from gui_playlists import (
    ConditionRow, ManualPlaylistDialog, PlaylistsView, SmartPlaylistDialog,
)


_app = QApplication.instance() or QApplication(sys.argv)


def _dispose_widget(widget):
    widget.close()
    widget.deleteLater()
    _app.processEvents()


def _insert_media(db, **fields):
    fields.setdefault("title", "Untitled")
    fields.setdefault("type", "movie")
    fields.setdefault("source", "local")
    fields.setdefault("provider_id", fields["title"])
    fields.setdefault("is_favorite", 0)
    cursor = db.execute(
        """INSERT INTO media_items (title, type, source, provider_id, is_favorite)
           VALUES (:title, :type, :source, :provider_id, :is_favorite)""",
        fields,
    )
    return cursor.lastrowid


class TestSmartPlaylistDialog(unittest.TestCase):
    def test_default_dialog_creates_one_empty_row(self):
        dialog = SmartPlaylistDialog()
        try:
            rows = dialog._row_widgets()
            self.assertEqual(len(rows), 1)
            self.assertIsInstance(rows[0], ConditionRow)
        finally:
            _dispose_widget(dialog)

    def test_round_trip_with_existing_query(self):
        # Build a smart query with multiple fields, then load + serialize.
        builder = QueryBuilder()
        builder.add_condition("type", "=", "movie")
        builder.add_condition("favorite", "=", True, conjunction="AND")
        builder.set_order("title", "DESC")
        builder.set_limit(25)
        original_json = builder.to_json()

        dialog = SmartPlaylistDialog(name="Test", smart_query_json=original_json)
        try:
            # Two rows should be loaded.
            rows = dialog._row_widgets()
            self.assertEqual(len(rows), 2)

            # First row's conjunction combo should be disabled (no leading OR/AND).
            self.assertFalse(rows[0].conjunction_combo.isEnabled())

            # Reading back the dialog must yield an equivalent query.
            reloaded = json.loads(dialog.smart_query_json())
            self.assertEqual(len(reloaded["conditions"]), 2)
            self.assertEqual(reloaded["conditions"][0]["field"], "type")
            self.assertEqual(reloaded["conditions"][0]["operator"], "=")
            self.assertEqual(reloaded["conditions"][0]["value"], "movie")
            self.assertEqual(reloaded["conditions"][1]["field"], "favorite")
            # Boolean is normalized to int by QueryBuilder.
            self.assertIn(reloaded["conditions"][1]["value"], (1, True))
            self.assertEqual(reloaded["order_by"], "title")
            self.assertEqual(reloaded["order_dir"], "DESC")
            self.assertEqual(reloaded["limit"], 25)
        finally:
            _dispose_widget(dialog)

    def test_is_empty_operator_skips_value(self):
        dialog = SmartPlaylistDialog(
            name="Test",
            smart_query_json=QueryBuilder().to_json(),
        )
        try:
            row = dialog._row_widgets()[0]
            # Switch to is_empty -> value widget becomes a disabled placeholder.
            idx = row.field_combo.findData("description")
            row.field_combo.setCurrentIndex(idx)
            op_idx = row.operator_combo.findText("is_empty")
            row.operator_combo.setCurrentIndex(op_idx)

            payload = json.loads(dialog.smart_query_json())
            cond = payload["conditions"][0]
            self.assertEqual(cond["field"], "description")
            self.assertEqual(cond["operator"], "is_empty")
            # Value defaults to None for is_empty.
            self.assertIsNone(cond["value"])
        finally:
            _dispose_widget(dialog)


class TestManualPlaylistDialog(unittest.TestCase):
    def test_returns_name_and_description(self):
        dialog = ManualPlaylistDialog(name="Mein Mix",
                                       description="Lieblingsfilme")
        try:
            self.assertEqual(dialog.name(), "Mein Mix")
            self.assertEqual(dialog.description(), "Lieblingsfilme")
        finally:
            _dispose_widget(dialog)


class TestPlaylistsView(unittest.TestCase):
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.tags = TagManager(self.db)
        self.manager = PlaylistManager(self.db.conn)

        self.matrix_id = _insert_media(self.db, title="Matrix",
                                        type="movie", source="netflix",
                                        provider_id="netflix-matrix",
                                        is_favorite=1)
        self.arrival_id = _insert_media(self.db, title="Arrival",
                                         type="movie", source="prime",
                                         provider_id="prime-arrival",
                                         is_favorite=0)

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    def test_refresh_lists_existing_playlists(self):
        manual_id = self.manager.create_playlist("Manual")
        self.manager.add_item(manual_id, self.matrix_id)

        smart_query = QueryBuilder()
        smart_query.add_condition("type", "=", "movie")
        self.manager.create_smart_playlist("All Movies", smart_query.to_json())

        view = PlaylistsView(self.manager)
        try:
            # Two playlists, sorted by name (Manual + "All Movies").
            self.assertEqual(view.playlists_model.rowCount(), 2)
        finally:
            _dispose_widget(view)

    def test_selection_populates_items_for_smart_playlist(self):
        smart_query = QueryBuilder()
        smart_query.add_condition("type", "=", "movie")
        smart_id = self.manager.create_smart_playlist("All Movies",
                                                       smart_query.to_json())

        view = PlaylistsView(self.manager)
        try:
            # Select the playlist - PlaylistsView should populate the right pane.
            model = view.playlists_model
            for row in range(model.rowCount()):
                playlist = model.playlist_at(row)
                if playlist and playlist.id == smart_id:
                    view.playlists_list.setCurrentIndex(model.index(row))
                    break

            # Items list should contain both movies (Matrix + Arrival).
            items_text = [view.items_list.item(i).text()
                          for i in range(view.items_list.count())]
            self.assertEqual(len(items_text), 2)
            self.assertTrue(any("Matrix" in t for t in items_text))
            self.assertTrue(any("Arrival" in t for t in items_text))
        finally:
            _dispose_widget(view)

    def test_selection_populates_items_for_manual_playlist(self):
        manual_id = self.manager.create_playlist("Manual Picks")
        self.manager.add_item(manual_id, self.arrival_id)

        view = PlaylistsView(self.manager)
        try:
            model = view.playlists_model
            for row in range(model.rowCount()):
                playlist = model.playlist_at(row)
                if playlist and playlist.id == manual_id:
                    view.playlists_list.setCurrentIndex(model.index(row))
                    break

            items_text = [view.items_list.item(i).text()
                          for i in range(view.items_list.count())]
            self.assertEqual(len(items_text), 1)
            self.assertIn("Arrival", items_text[0])
        finally:
            _dispose_widget(view)

    def test_refresh_recovers_after_external_changes(self):
        self.manager.create_playlist("Manual Picks")
        view = PlaylistsView(self.manager)
        try:
            self.assertEqual(view.playlists_model.rowCount(), 1)

            # Simulate an external edit (another worker, CLI, ...) that adds a
            # second playlist; PlaylistsView.refresh() must pick it up.
            self.manager.create_smart_playlist(
                "Auto Movies", QueryBuilder().to_json()
            )
            view.refresh()
            self.assertEqual(view.playlists_model.rowCount(), 2)
        finally:
            _dispose_widget(view)


if __name__ == "__main__":
    unittest.main()
