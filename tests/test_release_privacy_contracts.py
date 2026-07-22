"""Release, export, and mobile privacy contract regressions."""

import csv
import json
import os
import plistlib
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from core import Database
from export_import import MediaExporter, _detect_app_version
from version import __version__


ROOT = Path(__file__).resolve().parent.parent


class TestDesktopVersionContract(unittest.TestCase):
    def test_default_export_version_is_canonical_release(self):
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("MEDIABRAIN_VERSION", None)
            os.environ.pop("APP_VERSION", None)
            self.assertEqual(_detect_app_version(), __version__)

    def test_packaging_version_override_wins(self):
        with patch.dict(os.environ, {"MEDIABRAIN_VERSION": "2.0.0+build.7"}):
            self.assertEqual(_detect_app_version(), "2.0.0+build.7")


class TestPrivatePathExportContract(unittest.TestCase):
    def _database_with_private_path(self, folder: Path) -> Database:
        db = Database(folder / "source.db")
        db.execute(
            """
            INSERT INTO media_items
                (title, type, source, provider_id, is_local_file, local_path)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (
                "Private recording",
                "document",
                "local",
                "private-1",
                1,
                r"C:\Users\Example\Private\recording.mp4",
            ),
        )
        return db

    def test_json_redacts_local_paths_by_default_and_allows_explicit_opt_in(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            db = self._database_with_private_path(folder)
            try:
                exporter = MediaExporter(db.conn)
                safe = exporter.build_export_payload(include_playlists=False)
                self.assertFalse(safe["capabilities"]["local_paths"])
                self.assertNotIn("local_path", safe["items"][0])

                explicit = exporter.build_export_payload(
                    include_playlists=False,
                    include_local_paths=True,
                )
                self.assertTrue(explicit["capabilities"]["local_paths"])
                self.assertEqual(
                    explicit["items"][0]["local_path"],
                    r"C:\Users\Example\Private\recording.mp4",
                )
            finally:
                db.close()

    def test_csv_redacts_local_paths_by_default(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            db = self._database_with_private_path(folder)
            try:
                target = folder / "library.csv"
                MediaExporter(db.conn).export_csv(str(target))
                with target.open(encoding="utf-8", newline="") as handle:
                    row = next(csv.DictReader(handle))
                self.assertNotIn("local_path", row)
            finally:
                db.close()


class TestBuildOutputContract(unittest.TestCase):
    def test_windows_build_keeps_artifact_outside_onedrive_checkout(self):
        source = (ROOT / "build_exe.bat").read_text(encoding="utf-8")
        self.assertIn(r"C:\_Local_DEV\codex_build\mediabrain", source)
        self.assertNotIn('copy /Y "%LOCAL_DIST%', source)
        self.assertNotIn("'dist\\MediaBrain.exe','MediaBrain.exe'", source)


class TestFlutterTransportContract(unittest.TestCase):
    def test_server_sync_requires_https(self):
        source = (ROOT / "flutter_port/lib/services/sync_service.dart").read_text(
            encoding="utf-8"
        )
        self.assertIn("url = 'https://$url';", source)
        self.assertIn("Server-Sync erfordert HTTPS", source)
        self.assertNotIn("url = 'http://$url';", source)

    def test_background_scan_never_pushes_library(self):
        source = (ROOT / "flutter_port/lib/services/background_scan.dart").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("SyncService.instance.push()", source)
        self.assertNotIn("sync_service.dart", source)

    def test_ios_transport_security_is_single_and_strict(self):
        path = ROOT / "flutter_port/ios/Runner/Info.plist"
        source = path.read_text(encoding="utf-8")
        self.assertEqual(source.count("<key>NSAppTransportSecurity</key>"), 1)
        payload = plistlib.loads(path.read_bytes())
        self.assertEqual(payload["NSAppTransportSecurity"], {
            "NSAllowsArbitraryLoads": False
        })


if __name__ == "__main__":
    unittest.main()
