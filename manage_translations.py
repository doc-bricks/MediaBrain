"""
manage_translations.py - Auto-Scanner für deutsche GUI-Strings
================================================================
Findet deutsche Strings in .py-Dateien und pflegt locales/translations.json
gemäß P-006 Tier-2 (DE, EN, ES, ZH, JA, RU).

Verwendung:
    python manage_translations.py [--dir PROJEKTVERZEICHNIS] [--check]
"""

import argparse
import json
import os
import re
import sys

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

TRANSLATION_FILE = "locales/translations.json"
SUPPORTED_LANGUAGES = ['de', 'en', 'es', 'zh', 'ja', 'ru']

STRING_PATTERNS = [
    re.compile(r'text\s*=\s*"([^"]+)"'),
    re.compile(r'setText\s*\(\s*["\']([^"\']+)["\']\s*\)'),
    re.compile(r'setWindowTitle\s*\(\s*["\']([^"\']+)["\']\s*\)'),
    re.compile(r'QLabel\s*\(\s*["\']([^"\']+)["\']\s*\)'),
    re.compile(r'QPushButton\s*\(\s*["\']([^"\']+)["\']\s*\)'),
]

GERMAN_HINTS = [
    "datei", "filter", "fehler", "laden", "speichern",
    "ansicht", "optionen", "zurück", "anzeigen", "export",
    "import", "einstellungen", "abbrechen", "hilfe", "bearbeiten",
    "öffnen", "schließen", "start", "aktualisieren",
]


def is_german(text):
    if any(ch in text for ch in "\u00e4\u00f6\u00fc\u00c4\u00d6\u00dc\u00df"):
        return True
    text_lower = text.lower()
    return any(w in text_lower for w in GERMAN_HINTS)


def find_german_strings(source_dir):
    german_strings = set()
    skip_dirs = {'build', 'dist', 'venv', '.venv', '__pycache__', 'releases'}

    for root, dirs, files in os.walk(source_dir):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for file in files:
            if file.endswith(".py"):
                path = os.path.join(root, file)
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        content = f.read()
                except Exception:
                    continue
                for pattern in STRING_PATTERNS:
                    for match in pattern.findall(content):
                        if is_german(match):
                            german_strings.add(match.strip())
    return german_strings


def manage_translations(source_dir=".", check_only=False):
    trans_file = os.path.join(source_dir, TRANSLATION_FILE)

    if os.path.exists(trans_file):
        with open(trans_file, "r", encoding="utf-8") as f:
            try:
                translations = json.load(f)
            except json.JSONDecodeError:
                translations = {}
    else:
        translations = {}

    found = find_german_strings(source_dir)

    added = []
    if not check_only:
        for s in sorted(found):
            if s not in translations:
                entry = {"de": s}
                for lang in SUPPORTED_LANGUAGES:
                    if lang != "de":
                        entry[lang] = ""
                translations[s] = entry
                added.append(s)

        os.makedirs(os.path.dirname(trans_file), exist_ok=True)
        with open(trans_file, "w", encoding="utf-8") as f:
            json.dump(translations, f, indent=2, ensure_ascii=False)

    if added:
        print(f"[+] {len(added)} neue Eintraege hinzugefuegt:")
        for s in added[:20]:
            print(f"    - {s}")
        if len(added) > 20:
            print(f"    ... und {len(added) - 20} weitere")
    else:
        print("[i] Keine neuen deutschen Strings gefunden.")

    missing = [k for k, v in translations.items()
               if any(not v.get(l) or not str(v.get(l)).strip() for l in SUPPORTED_LANGUAGES if l != "de")]
    if missing:
        print(f"\n[!] {len(missing)} Strings mit fehlenden Übersetzungen")
        if check_only:
            return 1
    else:
        print("\n[ok] Alle Strings haben Übersetzungen in allen Sprachen.")

    print(f"\n[i] Gesamt: {len(translations)} Strings in {trans_file}")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Translation catalog manager")
    parser.add_argument("pos_dir", nargs="?", default=None, help="Project directory (positional)")
    parser.add_argument("--dir", dest="opt_dir", default=None, help="Project directory")
    parser.add_argument("--check", action="store_true", help="Exit 1 if translations missing")
    args = parser.parse_args()

    target = args.opt_dir or args.pos_dir or "."
    code = manage_translations(target, check_only=args.check)
    sys.exit(code)
