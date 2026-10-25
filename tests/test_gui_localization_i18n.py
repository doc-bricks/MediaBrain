from __future__ import annotations

import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
PATCH_DIR = Path(__file__).resolve().parents[1]
REPO_DIR = Path(r"C:\_Local_DEV\_wt\mediabrain-worldset-20261025")
sys.path.insert(0, str(REPO_DIR))
sys.path.insert(0, str(PATCH_DIR))

import pytest
from PySide6.QtWidgets import QApplication, QDialogButtonBox

import config
import gui
from gui_playlists import ConditionRow, SmartPlaylistDialog
from search_advanced import AdvancedSearchBar
from translator import TranslationSystem, resolve_language


@pytest.fixture(scope="module")
def qapp():
    app = QApplication.instance() or QApplication([])
    yield app


def _translator(language: str) -> TranslationSystem:
    return TranslationSystem(
        language,
        app_dir=PATCH_DIR,
        auto_register_missing=False,
    )


def test_settings_language_persists_worldset_code_and_localizes_restart_notice(qapp, tmp_path, monkeypatch):
    settings_path = tmp_path / "settings.json"
    monkeypatch.setattr(config, "SETTINGS_PATH", settings_path)
    test_config = config.Config()
    monkeypatch.setattr(config, "config", test_config)

    translator = _translator("es")
    messages = []
    monkeypatch.setattr(
        gui,
        "_show_message",
        lambda icon, parent, title, body, *args: messages.append((title, body)) or 0,
    )

    window = gui.SettingsWindow(translator=translator)
    assert window.windowTitle() == translator.t("Einstellungen")
    ja_index = window.language_select.findData("ja")
    assert ja_index >= 0
    assert window.language_select.itemText(ja_index) == "日本語"

    window.language_select.setCurrentIndex(ja_index)

    assert test_config.get("ui.language") == "ja"
    assert window.language_select.currentData() == "ja"
    assert messages == [(
        translator.t("Anzeigesprache gespeichert"),
        translator.t("Die Änderung der Anzeigesprache wird nach einem Neustart wirksam."),
    )]
    assert messages[0][0] != "Anzeigesprache gespeichert"
    window.close()


def test_condition_row_locales_keep_filter_codes_in_item_data(qapp):
    spanish = _translator("es")
    es_row = ConditionRow(translator=spanish)
    artist_index = es_row.field_combo.findData("artist")
    assert artist_index >= 0
    assert es_row.field_combo.itemText(artist_index) == spanish.t("Kuenstler")
    assert es_row.field_combo.itemData(artist_index) == "artist"
    assert es_row.operator_combo.currentText() == spanish.t("contains")
    assert es_row.operator_combo.currentData() == "contains"
    assert es_row.conjunction_combo.currentText() == spanish.t("AND")
    assert es_row.conjunction_combo.currentData() == "AND"
    es_row.conjunction_combo.setCurrentIndex(es_row.conjunction_combo.findData("OR"))
    condition = es_row.to_condition()
    assert (condition.field, condition.operator, condition.conjunction) == ("title", "contains", "OR")

    japanese = _translator("ja")
    ja_row = ConditionRow(translator=japanese)
    assert ja_row.operator_combo.currentText() == japanese.t("contains")
    assert ja_row.operator_combo.currentData() == "contains"
    assert ja_row.field_combo.currentData() == "title"


def test_search_dropdown_labels_do_not_replace_filter_codes(qapp):
    translator = _translator("ja")
    search = AdvancedSearchBar(translator=translator)
    movie_index = search.combo_type.findData("movie")
    assert movie_index >= 0
    assert search.combo_type.itemText(movie_index) == translator.t("Filme")
    assert search.combo_type.itemData(movie_index) == "movie"

    title_sort = next(
        index for index in range(search.combo_sort.count())
        if tuple(search.combo_sort.itemData(index)) == ("title", False)
    )
    assert search.combo_sort.itemText(title_sort) == translator.t("Titel A-Z")
    assert tuple(search.combo_sort.itemData(title_sort)) == ("title", False)


def test_playlist_dialog_has_translated_standard_buttons_and_stable_operator_data(qapp):
    translator = _translator("es")
    dialog = SmartPlaylistDialog(translator=translator)
    buttons = dialog.findChild(QDialogButtonBox)
    assert buttons is not None
    assert buttons.button(QDialogButtonBox.StandardButton.Ok).text() == translator.t("OK")
    assert buttons.button(QDialogButtonBox.StandardButton.Cancel).text() == translator.t("Abbrechen")

    row = dialog._row_widgets()[0]
    assert row.operator_combo.currentText() == translator.t("contains")
    assert row.operator_combo.currentData() == "contains"
    assert row.to_condition().operator == "contains"
    dialog.close()


def test_language_resolution_keeps_historical_default_and_regional_env_values():
    assert resolve_language(None, None) == "de"
    assert resolve_language("es-MX", "de") == "es"
    assert resolve_language("unsupported", "ja") == "ja"
