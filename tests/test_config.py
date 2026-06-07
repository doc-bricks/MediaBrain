"""
test_config.py
Regressionstests für Config-Backup und Recovery.
"""

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import sys

# Projekt-Root zum Path hinzufuegen
sys.path.insert(0, str(Path(__file__).parent.parent))

import config as config_module


class TestConfigBackupRecovery(unittest.TestCase):
    """Sichert Backup-Erstellung und Recovery-Verhalten ab."""

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.settings_path = Path(self.tmpdir.name) / "settings.json"
        self.backup_path = self.settings_path.with_suffix(".json.bak")
        self.patcher = patch.object(config_module, "SETTINGS_PATH", self.settings_path)
        self.patcher.start()

    def tearDown(self):
        self.patcher.stop()
        self.tmpdir.cleanup()

    def _write_json(self, path, payload):
        path.write_text(json.dumps(payload, indent=4), encoding="utf-8")

    def _read_json(self, path):
        return json.loads(path.read_text(encoding="utf-8"))

    def test_recovery_preserves_existing_backup(self):
        """Ein korruptes settings.json wird aus .bak wiederhergestellt, ohne das Backup zu ersetzen."""
        backup_payload = {"ui": {"theme": "backup_theme"}}
        self._write_json(self.backup_path, backup_payload)
        self.settings_path.write_text("{defekt", encoding="utf-8")

        conf = config_module.Config()

        self.assertEqual(conf.get("ui.theme"), "backup_theme")
        self.assertTrue(self.settings_path.exists())
        self.assertEqual(self._read_json(self.settings_path), backup_payload)
        self.assertEqual(self._read_json(self.backup_path), backup_payload)

    def test_save_creates_backup_before_overwrite(self):
        """Ein normaler Save sichert die vorherige Version in .bak."""
        initial_payload = {"ui": {"theme": "old_theme"}}
        self._write_json(self.settings_path, initial_payload)

        conf = config_module.Config()
        conf.set("ui.theme", "new_theme")

        self.assertEqual(conf.get("ui.theme"), "new_theme")
        self.assertEqual(self._read_json(self.settings_path)["ui"]["theme"], "new_theme")
        self.assertEqual(self._read_json(self.backup_path), initial_payload)


if __name__ == "__main__":
    unittest.main()
