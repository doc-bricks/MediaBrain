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


def test_unknown_german_key_never_raises_when_catalog_is_unwritable(monkeypatch, tmp_path):
    from translator import TranslationSystem

    ts = TranslationSystem("de", app_dir=tmp_path)

    def denied():
        raise PermissionError("WindowsApps ist schreibgeschützt")

    monkeypatch.setattr(ts, "_save_translations", denied)
    assert ts.t("Neuer unbekannter Text für die Prüfung") == "Neuer unbekannter Text für die Prüfung"


def test_frozen_build_does_not_write_the_translation_catalog(monkeypatch, tmp_path):
    from translator import TranslationSystem

    ts = TranslationSystem("de", app_dir=tmp_path)
    monkeypatch.setattr(sys, "frozen", True, raising=False)
    ts.t("Noch ein unbekannter Text für die Prüfung")
    assert not ts.translations_file.exists()


def test_cli_finds_the_database_of_a_store_installation(monkeypatch, tmp_path):
    """Store-/gebautes Programm legt die DB unter %LOCALAPPDATA%/MediaBrain an (config.DATA_DIR);
    die CLI suchte nur neben dem Code und unter %APPDATA%/MediaBrain."""
    import cli

    store_db = tmp_path / "Local" / "MediaBrain" / "media_brain.db"
    store_db.parent.mkdir(parents=True)
    store_db.write_bytes(b"")
    monkeypatch.delenv("MEDIABRAIN_DB", raising=False)
    monkeypatch.delenv("MEDIABRAIN_DATA_DIR", raising=False)
    monkeypatch.setenv("LOCALAPPDATA", str(tmp_path / "Local"))
    monkeypatch.setenv("APPDATA", str(tmp_path / "Roaming"))
    monkeypatch.setattr(cli, "_APP_DIR", tmp_path / "program")
    assert cli._find_db() == store_db

    custom = tmp_path / "custom"
    custom.mkdir()
    (custom / "media_brain.db").write_bytes(b"")
    monkeypatch.setenv("MEDIABRAIN_DATA_DIR", str(custom))
    assert cli._find_db() == custom / "media_brain.db"
