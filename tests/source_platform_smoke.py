"""Source-level smoke tests for the Linux and macOS desktop targets.

These tests exercise portable contracts without claiming native packaging,
desktop integration, or a manual live acceptance on either platform.
"""

from __future__ import annotations

import json
import os
import platform
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

import pytest
from PySide6.QtWidgets import QApplication

import config
import core
from core import BlacklistManager, Database, MediaManager, OpenHandler, TagManager
from export_import import MediaExporter, MediaImporter
from gui import MainWindow
from playlists import PlaylistManager


@pytest.fixture(scope="session")
def qapp() -> QApplication:
    app = QApplication.instance() or QApplication(["mediabrain-source-smoke"])
    yield app
    app.processEvents()


def test_runner_is_a_supported_desktop_source_target() -> None:
    assert platform.system() in {"Windows", "Linux", "Darwin"}


def test_default_watch_paths_follow_the_runner_home() -> None:
    home = Path.home()
    watch_paths = config.DEFAULT_SETTINGS["file_indexer"]["watch_paths"]

    assert [Path(path) for path in watch_paths] == [
        home / "Music",
        home / "Videos",
        home / "Downloads",
    ]


def test_config_roundtrip_handles_unicode_paths(tmp_path: Path, monkeypatch) -> None:
    settings_path = tmp_path / "Einstellungen" / "settings.json"
    monkeypatch.setattr(config, "SETTINGS_PATH", settings_path)

    settings = config.Config()
    library_path = tmp_path / "Medien" / "Überblick"
    settings.set("file_indexer.watch_paths", [str(library_path)])

    reloaded = config.Config()
    assert reloaded.get("file_indexer.watch_paths") == [str(library_path)]
    assert json.loads(settings_path.read_text(encoding="utf-8"))[
        "file_indexer"
    ]["watch_paths"] == [str(library_path)]


def test_json_exchange_roundtrip_handles_unicode_paths(tmp_path: Path) -> None:
    source = Database(tmp_path / "Quelle-Übersicht.db")
    target = Database(tmp_path / "Ziel-Übersicht.db")
    PlaylistManager(source.conn)
    PlaylistManager(target.conn)
    export_path = tmp_path / "Austausch" / "mediabrain-library-v1.json"
    export_path.parent.mkdir()

    try:
        source.execute(
            """
            INSERT INTO media_items
                (title, type, source, provider_id, description)
            VALUES (?, ?, ?, ?, ?)
            """,
            ("Hörbuch für unterwegs", "audiobook", "local", "quelle-1", "Größe: groß"),
        )

        assert MediaExporter(source.conn).export_json(str(export_path)) == 1
        stats = MediaImporter(target.conn).import_json(str(export_path))
        imported = target.fetchone(
            "SELECT title, type, description FROM media_items WHERE provider_id = ?",
            ("quelle-1",),
        )

        assert stats["imported"] == 1
        assert stats["errors"] == 0
        assert dict(imported) == {
            "title": "Hörbuch für unterwegs",
            "type": "audiobook",
            "description": "Größe: groß",
        }
    finally:
        source.close()
        target.close()


def test_local_file_opener_uses_the_runner_command(
    tmp_path: Path, monkeypatch
) -> None:
    db = Database(tmp_path / "open-handler.db")
    manager = MediaManager(db)
    media_path = tmp_path / "Medien" / "Hörprobe.mp3"
    media_path.parent.mkdir()
    media_path.write_bytes(b"source-smoke")

    manager.add_or_update(
        {
            "title": "Hörprobe",
            "type": "music",
            "source": "local",
            "provider_id": str(media_path),
            "is_local_file": True,
            "local_path": str(media_path),
            "has_real_id": True,
        }
    )
    item = manager.get_by_provider(str(media_path), "local")
    calls: list[object] = []
    system = platform.system()

    if system == "Windows":
        monkeypatch.setattr(
            core.os, "startfile", lambda path: calls.append(path), raising=False
        )
        expected: object = str(media_path)
    else:
        monkeypatch.setattr(
            core.subprocess, "Popen", lambda command: calls.append(command)
        )
        opener = "open" if system == "Darwin" else "xdg-open"
        expected = [opener, str(media_path)]

    try:
        OpenHandler(manager)._open_local(item)
        assert calls == [expected]
        assert db.fetchone(
            "SELECT open_method FROM media_items WHERE id = ?", (item.id,)
        )["open_method"] == "local"
    finally:
        db.close()


def test_offscreen_window_and_tray_lifecycle(
    tmp_path: Path, monkeypatch, qapp: QApplication
) -> None:
    db = Database(tmp_path / "gui-smoke.db")
    media_manager = MediaManager(db)
    blacklist_manager = BlacklistManager(db)
    tag_manager = TagManager(db)
    playlist_manager = PlaylistManager(db.conn)
    monkeypatch.setitem(config.config.settings["ui"], "system_tray", False)

    window = MainWindow(
        media_manager,
        blacklist_manager,
        tag_manager,
        playlist_manager,
    )
    try:
        assert window.windowTitle() == "MediaBrain"
        window.update_system_tray(True)
        assert window.tray_icon is not None
        window.update_system_tray(False)
        assert window.tray_icon is None
    finally:
        window.close()
        window.deleteLater()
        qapp.processEvents()
        db.close()
