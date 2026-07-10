"""Regression tests for configurable MediaBrain media type navigation."""

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

import config as config_module
from core import BlacklistManager, Database, MediaManager
from gui import MainWindow, SettingsWindow

_app = QApplication.instance() or QApplication(sys.argv)


class TestMediaTypeSettings(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.settings_path = Path(self.tmpdir.name) / "settings.json"
        self.settings_patcher = patch.object(config_module, "SETTINGS_PATH", self.settings_path)
        self.settings_patcher.start()
        self.original_config = config_module.config
        config_module.config = config_module.Config()

        db_fd, db_path = tempfile.mkstemp(suffix=".db")
        self.db_fd = db_fd
        self.db_path = db_path
        self.db = Database(db_path)
        self.media_manager = MediaManager(self.db)
        self.blacklist_manager = BlacklistManager(self.db)

    def tearDown(self):
        for widget in QApplication.topLevelWidgets():
            if isinstance(widget, (MainWindow, SettingsWindow)):
                widget.close()
                widget.deleteLater()
        _app.processEvents()

        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)
        config_module.config = self.original_config
        self.settings_patcher.stop()
        self.tmpdir.cleanup()

    def test_defaults_include_documents_as_toggleable_media_type(self):
        enabled = config_module.config.get_enabled_media_types()

        self.assertTrue(enabled["document"])
        self.assertIn("document", {entry["key"] for entry in config_module.MEDIA_TYPE_DEFINITIONS})

    def test_main_window_hides_disabled_media_type_button(self):
        window = MainWindow(self.media_manager, self.blacklist_manager)

        self.assertIn("document", window.library_views)
        self.assertFalse(window.library_buttons["document"].isHidden())

        config_module.config.set_media_type_enabled("document", False)
        window.apply_media_type_visibility()

        self.assertTrue(window.library_buttons["document"].isHidden())
        self.assertIn("document", window.library_views)

    def test_settings_checkbox_persists_media_type_visibility(self):
        settings = SettingsWindow()
        checkbox = settings.media_type_checkboxes["document"]

        checkbox.setChecked(False)
        _app.processEvents()

        self.assertFalse(config_module.config.get_enabled_media_types()["document"])


if __name__ == "__main__":
    unittest.main()
