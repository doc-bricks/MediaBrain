"""Regression tests for the application controller bootstrap."""

import os
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from MediaBrain import AppController


_app = QApplication.instance() or QApplication(sys.argv)


class _DummyWindow:
    def __init__(self, *args, **kwargs):
        self.icon = None
        self.refreshed = 0
        self.shown = False

    def setWindowIcon(self, icon):
        self.icon = icon

    def refresh_all_views(self):
        self.refreshed += 1

    def show(self):
        self.shown = True


class TestAppController(unittest.TestCase):
    def test_reuses_existing_qapplication_instance(self):
        fake_db = SimpleNamespace(conn=object())
        fake_media_manager = SimpleNamespace()
        fake_blacklist_manager = SimpleNamespace()
        fake_tag_manager = SimpleNamespace()
        fake_playlist_manager = SimpleNamespace()
        fake_event_processor = SimpleNamespace(queue=None, on_data_changed=None)

        with patch("MediaBrain.Database", return_value=fake_db), \
             patch("MediaBrain.MediaManager", return_value=fake_media_manager), \
             patch("MediaBrain.BlacklistManager", return_value=fake_blacklist_manager), \
             patch("MediaBrain.TagManager", return_value=fake_tag_manager), \
             patch("MediaBrain.PlaylistManager", return_value=fake_playlist_manager), \
             patch("MediaBrain.EventProcessor", return_value=fake_event_processor), \
             patch("MediaBrain.MainWindow", side_effect=_DummyWindow), \
             patch.object(AppController, "_start_background_services", autospec=True), \
             patch.object(AppController, "_start_event_loop", autospec=True):
            controller = AppController()

        self.assertIs(controller.app, _app)
        self.assertIs(controller.window.icon, controller.app_icon)
        controller.event_processor.on_data_changed()
        self.assertEqual(controller.window.refreshed, 1)
        self.assertTrue(controller.window.shown)


if __name__ == "__main__":
    unittest.main()
