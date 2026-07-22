"""Regression checks for the committed desktop translation catalog."""

import json
import unittest
from pathlib import Path

from translator import TranslationSystem


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


if __name__ == "__main__":
    unittest.main()
