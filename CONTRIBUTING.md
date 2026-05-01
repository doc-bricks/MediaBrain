# Beitragsrichtlinie / Contributing Guide

## Deutsch

Vielen Dank für Ihr Interesse, zu MediaBrain beizutragen.

### Wie Sie beitragen können

1. **Bug melden:** Erstellen Sie ein Issue mit Reproduktionsschritten.
2. **Feature vorschlagen:** Beschreiben Sie Anwendungsfall, erwartetes Verhalten und mögliche Randfälle.
3. **Code beitragen:** Öffnen Sie einen Pull Request mit Tests und aktualisierter Dokumentation, sofern nötig.

### Lokale Einrichtung

```bash
git clone https://github.com/doc-bricks/MediaBrain.git
cd MediaBrain
pip install -r requirements.txt
python MediaBrain.py
```

### Tests

```bash
python -m pytest tests/ -q
```

### Code-Richtlinien

- Python-Code folgt PEP 8.
- GUI-Code verwendet PySide6, nicht PyQt.
- Öffentliche Dokumentation wird in Deutsch und Englisch gepflegt, wo sinnvoll.
- Keine hardcodierten privaten Pfade, API-Keys, Tokens oder lokalen Datenbanken committen.
- `settings.json`, `*.db`, Logs, Build-Artefakte und lokale Testdaten bleiben unversioniert.

### Pull Requests

1. Erstellen Sie einen Feature-Branch.
2. Committen Sie zusammenhängende Änderungen mit klarer Commit-Message.
3. Führen Sie die relevanten Tests aus.
4. Aktualisieren Sie README, Changelog oder Privacy/Security-Dokumente, wenn sich Verhalten oder Datennutzung ändern.

Aktuell ist kein separates CLA-Dokument erforderlich. Mit einem Beitrag bestätigen Sie, dass Sie berechtigt sind, den Code unter der Projektlizenz einzureichen.

---

## English

Thank you for your interest in contributing to MediaBrain.

### How to Contribute

1. **Report bugs:** Open an issue with reproduction steps.
2. **Suggest features:** Describe the use case, expected behavior, and relevant edge cases.
3. **Contribute code:** Open a pull request with tests and updated documentation where needed.

### Local Setup

```bash
git clone https://github.com/doc-bricks/MediaBrain.git
cd MediaBrain
pip install -r requirements.txt
python MediaBrain.py
```

### Tests

```bash
python -m pytest tests/ -q
```

### Code Guidelines

- Python code follows PEP 8.
- GUI code uses PySide6, not PyQt.
- Public documentation is maintained in German and English where useful.
- Do not commit hardcoded private paths, API keys, tokens, or local databases.
- `settings.json`, `*.db`, logs, build artifacts, and local test data stay unversioned.

### Pull Requests

1. Create a feature branch.
2. Commit related changes with a clear commit message.
3. Run the relevant tests.
4. Update README, changelog, privacy, or security docs when behavior or data handling changes.

No separate CLA document is currently required. By contributing, you confirm that you have the right to submit the code under the project license.
