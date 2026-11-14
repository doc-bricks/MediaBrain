"""Store-Blocker BZ-MB-01: im gebauten Programm (PyInstaller/MSIX) liegen Daten nie im Programmordner.

MSIX installiert nach WindowsApps (schreibgeschützt); dort konnten media_brain.db, settings.json
und Logs nicht angelegt werden. Muster wie AmpelClip: %LOCALAPPDATA%\\MediaBrain.
"""
import importlib
import sys
from pathlib import Path

import config


def _reload_config(monkeypatch, tmp_path, frozen):
    if frozen:
        monkeypatch.setattr(sys, "frozen", True, raising=False)
    else:
        monkeypatch.delattr(sys, "frozen", raising=False)
    monkeypatch.setenv("LOCALAPPDATA", str(tmp_path / "LocalAppData"))
    monkeypatch.delenv("MEDIABRAIN_DATA_DIR", raising=False)
    return importlib.reload(config)


def test_frozen_build_stores_data_in_local_appdata(monkeypatch, tmp_path):
    cfg = _reload_config(monkeypatch, tmp_path, frozen=True)
    try:
        expected = tmp_path / "LocalAppData" / "MediaBrain"
        assert cfg.DB_PATH == expected / "media_brain.db"
        assert cfg.SETTINGS_PATH == expected / "settings.json"
        assert cfg.LOG_PATH.parent.parent == expected
    finally:
        _reload_config(monkeypatch, tmp_path, frozen=False)


def test_frozen_build_takes_over_existing_data_without_overwriting(monkeypatch, tmp_path):
    bundle = tmp_path / "bundle"
    bundle.mkdir()
    (bundle / "media_brain.db").write_bytes(b"alt")
    (bundle / "settings.json").write_text('{"x": 1}', encoding="utf-8")
    target = tmp_path / "LocalAppData" / "MediaBrain"
    target.mkdir(parents=True)
    (target / "settings.json").write_text('{"neu": true}', encoding="utf-8")
    config._migrate_legacy_data(bundle, target)
    assert (target / "media_brain.db").read_bytes() == b"alt"           # übernommen
    assert (target / "settings.json").read_text(encoding="utf-8") == '{"neu": true}'  # nicht überschrieben
    assert (bundle / "media_brain.db").exists()                        # Original bleibt


def test_source_run_keeps_data_next_to_code(monkeypatch, tmp_path):
    cfg = _reload_config(monkeypatch, tmp_path, frozen=False)
    assert cfg.DB_PATH == Path(cfg.__file__).resolve().parent / "media_brain.db"


def test_metadata_reads_api_keys_from_the_same_settings_file():
    import metadata_v2
    assert metadata_v2.CONFIG_PATH == config.SETTINGS_PATH


def test_logger_system_writes_logs_to_the_data_dir():
    import logger_system
    assert logger_system.LOG_DIR == config.DATA_DIR / "logs"
