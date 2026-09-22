"""
TranslationSystem - Multi-Language Support für Anwendungen
============================================================
Version: 1.0.0 (isoliert aus _LANG)
Quelle: ARC_EntwicklungsschleifeAdvanced/TranslationSystem.py v2.4

Verwendung:
-----------
from translator import TranslationSystem

translator = TranslationSystem('de')
label.setText(translator.t('Datei öffnen'))
translator.set_language('en')
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Set


SUPPORTED_LANGUAGES = ['de', 'en', 'es', 'zh', 'ja', 'ru']


class TranslationSystem:
    """Multi-Language Support System v1.1"""

    def __init__(self, default_lang: str = 'de', app_dir: Path = None):
        """
        Initialisiert Translation-System.

        Args:
            default_lang: Standard-Sprache (eines von SUPPORTED_LANGUAGES)
            app_dir: Verzeichnis der Anwendung (default: aktuelles Verzeichnis)
        """
        self.current_lang = default_lang

        if app_dir is None:
            app_dir = Path.cwd()
        self.app_dir = Path(app_dir)

        self.translations_file = self.app_dir / "locales" / "translations.json"

        self.string_patterns = [
            re.compile(r'setText\s*\(\s*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'setWindowTitle\s*\(\s*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'QLabel\s*\(\s*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'QPushButton\s*\(\s*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'addAction\s*\([^,]*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'addTab\s*\([^,]+,\s*["\']([^"\']+)["\']\s*\)'),
            re.compile(r'text\s*=\s*"([^"]+)"'),
        ]

        self.german_hints = [
            "datei", "bearbeiten", "ansicht", "hilfe", "öffnen", "speichern",
            "schließen", "einstellungen", "abbrechen", "ok", "ja", "nein",
            "start", "stop", "pause", "fortsetzen", "laden", "aktualisieren",
            "filter", "fehler", "export", "import", "optionen", "anzeigen",
        ]

        self.translations = {}
        self._load_translations()

    def _load_translations(self):
        if self.translations_file.exists():
            try:
                with open(self.translations_file, 'r', encoding='utf-8') as f:
                    self.translations = json.load(f)
            except Exception:
                self.translations = {}
        else:
            self.translations = {}

    def _save_translations(self):
        self.translations_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.translations_file, 'w', encoding='utf-8') as f:
            json.dump(self.translations, f, indent=2, ensure_ascii=False)

    def t(self, key: str, **kwargs) -> str:
        """
        Übersetzt einen Key in die aktuelle Sprache mit robuster 4-Stufen-Fallback-Kette.

        Fallback-Reihenfolge:
            1. Aktuelle Sprache (self.current_lang)
            2. Englisch ('en')
            3. Deutsch ('de')
            4. Ursprünglicher Key

        Args:
            key: Translation-Key (oft der deutsche Originaltext)
            **kwargs: Optionale Formatierungs-Parameter für String-Interpolation

        Returns:
            Übersetzter und ggf. formatierter Text
        """
        text = None
        if key in self.translations:
            entry = self.translations[key]
            if isinstance(entry, dict):
                # 1. Stufe: Aktuelle Sprache prüfen
                val = entry.get(self.current_lang)
                if val and isinstance(val, str) and val.strip():
                    text = val
                # 2. Stufe: Fallback auf Englisch
                elif self.current_lang != 'en':
                    val_en = entry.get('en')
                    if val_en and isinstance(val_en, str) and val_en.strip():
                        text = val_en
                # 3. Stufe: Fallback auf Deutsch
                if text is None and self.current_lang != 'de':
                    val_de = entry.get('de')
                    if val_de and isinstance(val_de, str) and val_de.strip():
                        text = val_de

        if text is None:
            if key not in self.translations and self._is_german(key):
                entry = {"de": key}
                for lang in SUPPORTED_LANGUAGES:
                    if lang != "de":
                        entry.setdefault(lang, "")
                self.translations[key] = entry
                self._save_translations()
            text = key

        if kwargs and text:
            try:
                return text.format(**kwargs)
            except (KeyError, IndexError, ValueError):
                return text

        return text

    def set_language(self, lang: str):
        if lang in SUPPORTED_LANGUAGES:
            self.current_lang = lang

    def get_language(self) -> str:
        return self.current_lang

    def add_translation(self, key: str, de: str, en: str, **kwargs):
        entry = {"de": de, "en": en}
        for lang in SUPPORTED_LANGUAGES:
            if lang not in entry:
                entry[lang] = kwargs.get(lang, "")
        self.translations[key] = entry
        self._save_translations()

    def scan_and_update(self, project_dir: Path = None) -> Dict:
        """Scannt Projekt-Dateien nach deutschen Strings und aktualisiert translations.json."""
        if project_dir is None:
            project_dir = self.app_dir

        found_strings = self._find_german_strings(project_dir)

        added = []
        for string in sorted(found_strings):
            if string not in self.translations:
                entry = {"de": string}
                for lang in SUPPORTED_LANGUAGES:
                    if lang != "de":
                        entry[lang] = ""
                self.translations[string] = entry
                added.append(string)

        if added:
            self._save_translations()

        missing = self.get_missing_translations()

        return {'added': added, 'missing': missing, 'total': len(self.translations)}

    def _find_german_strings(self, directory: Path) -> Set[str]:
        german_strings = set()
        skip_dirs = {'build', 'dist', 'venv', '.venv', '__pycache__', 'releases'}

        for py_file in directory.rglob("*.py"):
            if any(folder in py_file.parts for folder in skip_dirs):
                continue
            try:
                with open(py_file, 'r', encoding='utf-8') as f:
                    content = f.read()
            except Exception:
                continue

            for pattern in self.string_patterns:
                for match in pattern.findall(content):
                    if match and self._is_german(match):
                        german_strings.add(match.strip())

        return german_strings

    def _is_german(self, text: str) -> bool:
        if any(ch in text for ch in "äöüÄÖÜß"):
            return True
        text_lower = text.lower()
        return any(hint in text_lower for hint in self.german_hints)

    def get_supported_languages(self) -> List[str]:
        """Gibt eine Liste aller unterstützten Sprachcodes zurück."""
        return list(SUPPORTED_LANGUAGES)

    def get_missing_translations(self, lang: str = None) -> List[str]:
        """Gibt Keys zurück, bei denen Übersetzungen fehlen oder leer sind.

        Args:
            lang: Einzelne Sprache prüfen (default: alle außer 'de')
        """
        def _is_empty(val) -> bool:
            return not val or not str(val).strip()

        if lang:
            return [k for k, v in self.translations.items() if _is_empty(v.get(lang))]
        return [k for k, v in self.translations.items()
                if any(_is_empty(v.get(l)) for l in SUPPORTED_LANGUAGES if l != "de")]

    def get_coverage(self, lang: str = None) -> Dict[str, float]:
        """Berechnet die Übersetzungsabdeckung in Prozent (0.0 bis 100.0)."""
        total = len(self.translations)
        if total == 0:
            targets = [lang] if lang else SUPPORTED_LANGUAGES
            return {l: 100.0 for l in targets}

        def _cov(l: str) -> float:
            missing = len([k for k, v in self.translations.items() if not v.get(l) or not str(v.get(l)).strip()])
            return round(((total - missing) / total) * 100.0, 1)

        if lang:
            return {lang: _cov(lang)}
        return {l: _cov(l) for l in SUPPORTED_LANGUAGES}

    def is_fully_translated(self, lang: str) -> bool:
        """Prüft, ob eine Sprache zu 100% ohne Leerstellen übersetzt ist."""
        return len(self.get_missing_translations(lang)) == 0


if __name__ == "__main__":
    tr = TranslationSystem('de')
    print(f"Sprache: {tr.get_language()}")
    result = tr.scan_and_update()
    print(f"Scan: {result['total']} Strings, {len(result['added'])} neu, {len(result['missing'])} mit fehlenden Übersetzungen")
