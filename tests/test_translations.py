"""Regression and contract checks for the committed desktop translation catalog."""

import json
import tempfile
import unittest
from pathlib import Path

from translator import SUPPORTED_LANGUAGES, TranslationSystem


ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "locales" / "translations.json"


class TestEnglishDesktopCatalog(unittest.TestCase):
    def test_every_committed_key_has_a_nonempty_english_value(self):
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))

        self.assertTrue(catalog)
        self.assertEqual(
            [key for key, value in catalog.items() if not value.get("en", "").strip()],
            [],
        )

    def test_translation_system_resolves_each_catalog_key_in_english(self):
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        translator = TranslationSystem("en", app_dir=ROOT)

        for key, values in catalog.items():
            with self.subTest(key=key):
                self.assertEqual(translator.t(key), values["en"])

    def test_locale_switch_uses_the_catalog_without_losing_symbol_prefixes(self):
        translator = TranslationSystem("de", app_dir=ROOT)

        self.assertEqual(translator.t("🔄 Aktualisieren"), "🔄 Aktualisieren")
        translator.set_language("en")
        self.assertEqual(translator.t("🔄 Aktualisieren"), "🔄 Refresh")

    def test_desktop_string_scan_has_no_unregistered_german_keys(self):
        catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        translator = TranslationSystem("en", app_dir=ROOT)

        self.assertEqual(
            sorted(translator._find_german_strings(ROOT) - set(catalog)),
            [],
        )


class TestMultiLanguageTier2Catalog(unittest.TestCase):
    """Tier-2 multi-language contract tests (DE, EN, ES, ZH, JA, RU)."""

    def setUp(self):
        self.catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        self.translator = TranslationSystem("de", app_dir=ROOT)

    def test_supported_languages_list(self):
        self.assertEqual(
            self.translator.get_supported_languages(),
            ['de', 'en', 'es', 'zh', 'ja', 'ru'],
        )

    def test_every_committed_key_has_a_nonempty_value_in_all_languages(self):
        for lang in SUPPORTED_LANGUAGES:
            missing = [
                key for key, value in self.catalog.items()
                if not str(value.get(lang, "")).strip()
            ]
            self.assertEqual(
                missing,
                [],
                f"Missing or empty translations for language '{lang}' in {CATALOG}",
            )

    def test_translation_system_resolves_each_catalog_key_in_all_languages(self):
        for lang in SUPPORTED_LANGUAGES:
            self.translator.set_language(lang)
            for key, values in self.catalog.items():
                with self.subTest(lang=lang, key=key):
                    expected = values[lang]
                    self.assertEqual(self.translator.t(key), expected)

    def test_all_supported_languages_report_100_percent_coverage(self):
        coverage = self.translator.get_coverage()
        for lang in SUPPORTED_LANGUAGES:
            self.assertEqual(coverage.get(lang), 100.0, f"Coverage for {lang} is not 100%")
            self.assertTrue(self.translator.is_fully_translated(lang))
        self.assertEqual(self.translator.get_missing_translations(), [])


class TestTranslationFallbackAndInterpolation(unittest.TestCase):
    """Tests 4-tier fallback (target -> en -> de -> key) and interpolation."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp_path = Path(self._tmp.name)
        locales_dir = self.tmp_path / "locales"
        locales_dir.mkdir(parents=True)
        catalog = {
            "OnlyEnDe": {
                "de": "Deutscher Text",
                "en": "English Text",
                "es": "",
                "zh": "",
                "ja": "",
                "ru": "",
            },
            "OnlyDe": {
                "de": "Nur Deutsch",
                "en": "",
                "es": "",
                "zh": "",
                "ja": "",
                "ru": "",
            },
            "AllEmpty": {
                "de": "",
                "en": "",
                "es": "",
                "zh": "",
                "ja": "",
                "ru": "",
            },
            "TemplateKey": {
                "de": "Gefunden: {count} Einträge",
                "en": "Found: {count} items",
                "es": "Encontrado: {count} elementos",
                "zh": "找到: {count} 项",
                "ja": "見つかりました: {count} 件",
                "ru": "Найдено: {count} записей",
            },
        }
        (locales_dir / "translations.json").write_text(json.dumps(catalog), encoding="utf-8")
        self.translator = TranslationSystem("es", app_dir=self.tmp_path)

    def tearDown(self):
        self._tmp.cleanup()

    def test_empty_target_falls_back_to_english(self):
        # Current lang is 'es'; 'es' is empty -> falls back to 'en'
        self.assertEqual(self.translator.t("OnlyEnDe"), "English Text")

    def test_empty_target_and_en_falls_back_to_german(self):
        # Current lang is 'es'; 'es' and 'en' are empty -> falls back to 'de'
        self.assertEqual(self.translator.t("OnlyDe"), "Nur Deutsch")

    def test_all_empty_falls_back_to_key(self):
        # Current lang is 'es'; all empty -> falls back to key
        self.assertEqual(self.translator.t("AllEmpty"), "AllEmpty")

    def test_unknown_key_falls_back_to_key(self):
        self.assertEqual(self.translator.t("CompletelyUnknownKey"), "CompletelyUnknownKey")

    def test_interpolation_with_kwargs(self):
        self.assertEqual(
            self.translator.t("TemplateKey", count=10),
            "Encontrado: 10 elementos",
        )
        self.translator.set_language("en")
        self.assertEqual(
            self.translator.t("TemplateKey", count=3),
            "Found: 3 items",
        )

    def test_interpolation_resilient_to_missing_kwargs(self):
        # Missing 'count' kwarg should not raise KeyError
        res = self.translator.t("TemplateKey")
        self.assertEqual(res, "Encontrado: {count} elementos")


if __name__ == "__main__":
    unittest.main()
