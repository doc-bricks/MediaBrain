<img src="assets/banner.svg" width="100%" alt="MediaBrain Banner">

# MediaBrain

[![Lizenz: MIT](https://img.shields.io/badge/Lizenz-MIT-green.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/)
[![Plattform: Windows](https://img.shields.io/badge/Plattform-Windows-lightgrey.svg)]()
[![Offline-first](https://img.shields.io/badge/offline--first-ja-brightgreen.svg)]()

> **MediaBrain ist ein lokaler PySide6-Medienmanager für persönliche Video-, Musik-, Playlist- und Streaming-Verläufe.**

[English](README.md) | **[Deutsch](README_de.md)** | [Datenschutz](PRIVACY_POLICY.md) | [Mitwirken](CONTRIBUTING.md) | [Changelog](CHANGELOG.md)

![MediaBrain Hauptfenster](README/screenshots/main.png)

## Schnellstart

| Bedarf | Einstieg |
|---|---|
| Desktop-App starten | `python MediaBrain.py` |
| Datenschutzgrenzen prüfen | [PRIVACY_POLICY.md](PRIVACY_POLICY.md) |
| Architektur verstehen | [ARCH.md](ARCH.md) |
| Geplante Arbeit ansehen | [ROADMAP.md](ROADMAP.md) |
| Maschinenlesbaren Kontext nutzen | [llms.txt](llms.txt) |

## Wofür MediaBrain gedacht ist

MediaBrain bündelt Medien, die Sie ansehen, sammeln, taggen, ausblenden oder in Playlists organisieren. Das Projekt ist kein Streaming-Dienst und lädt keine private Mediensammlung in eine Cloud.

- Lokale SQLite-Speicherung für Medien, Favoriten, Tags, Blacklist-Einträge und Playlists
- PySide6-Desktopoberfläche mit Dashboard, Bibliotheken, Suche, Statistiken, Einstellungen und High-Contrast-Theme
- Provider-Schicht für Netflix, YouTube, Spotify, Disney+, Prime Video, Apple TV+, Twitch und lokale Dateien
- Manuelle Playlists und Smart-Playlists mit QueryBuilder-Regeln
- Read-only Web-/PWA-Companion für den Import von `mediabrain-library-v1.json`-Exporten auf Mobilgeräten
- Optionale Metadatenabfragen über selbst konfigurierte TMDb-/OMDb-Keys oder öffentliche MusicBrainz-Daten
- Keine Telemetrie, kein Tracking und keine automatische Cloud-Synchronisation

## Suchkontext

Dieses Repository ist die kanonische GitHub-Adresse für:

- `doc-bricks MediaBrain`
- `MediaBrain Medienmanager`
- `private SQLite Medienbibliothek`
- `lokaler PySide6 Medienmanager`
- `PySide6 Smart-Playlist Medienmanager`
- `offline media hub smart playlists`
- `Desktop Medienverlauf Tracker`
- `MediaBrain PWA Companion`
- `privacy-first media history desktop app`

Der Name „MediaBrain“ kollidiert mit Media-Analytics-Firmen, KI-Medienlaboren und generischen Media-Planning-Tools. Dieses Repository ist konkret die lokale Desktop-Medienbibliothek `doc-bricks/MediaBrain`, keine Cloud-Plattform für Werbeanalysen, kein Multimedia-Forschungslabor und kein KI-Mediengenerator.

## Architektur

```text
Core Layer        Database, MediaManager, BlacklistManager, TagManager, PlaylistManager
Query Layer       QueryBuilder für erweiterte Filter und Smart-Playlists
Provider Layer    Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Local
Background Layer  FileIndexer, WindowWatcher
GUI Layer         Dashboard, Libraries, Favorites, Blacklist, Playlists, Search, Stats, Settings
```

Vollständiges Diagramm: [ARCH.md](ARCH.md)

## Installation

Voraussetzungen:

- Python 3.10 oder neuer
- Windows, Linux oder macOS mit Qt-/PySide6-Unterstützung

```bash
pip install -r requirements.txt
```

Beim ersten Start wird `settings.json` lokal erzeugt. Die öffentliche Vorlage liegt in [settings.example.json](settings.example.json). Persönliche Einstellungen, Datenbanken, Logs und Build-Artefakte sind per `.gitignore` ausgeschlossen.

## Nutzung

```bash
python MediaBrain.py
```

Rein lesender Kommandozeilenzugriff (schreibt nie in die Datenbank):

```bash
python cli.py list
python cli.py search "Titel"
python cli.py --db /pfad/zu/media_brain.db types
```

Die CLI blendet Einträge auf der Blacklist aus. Mit `MEDIABRAIN_DB` oder `--db`
wird eine Datenbank ausdrücklich ausgewählt.

Windows-Start per Doppelklick:

```bat
START.bat
```

Ein schlanker Windows-Starter kann mit folgendem Skript gebaut werden:

```bat
build_exe.bat
```

## Tests

```bash
python -m pytest tests/ -q
```

Die Tests decken Datenbankmanager, Metadaten, Tags, QueryBuilder, Playlists und Playlist-GUI-Verhalten im Offscreen-Modus ab.

## Datenschutz

MediaBrain speichert Nutzungsdaten lokal in SQLite-Dateien und Konfigurationsdateien. Es gibt keine Telemetrie und keine automatische Cloud-Synchronisation. Optionale Metadatenabfragen nutzen nur die vom Nutzer konfigurierten TMDb-/OMDb-API-Keys oder öffentliche MusicBrainz-Daten. Details stehen in [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Lizenz

MIT, siehe [LICENSE](LICENSE). Direkte Drittanbieter-Abhängigkeiten für Runtime und Entwicklung sind in [THIRD_PARTY_LICENSES.txt](THIRD_PARTY_LICENSES.txt) inventarisiert. Die GUI nutzt PySide6 unter LGPL-Bedingungen.

## Haftung

Dieses Projekt wird kostenlos und ohne Gewährleistung bereitgestellt. Es gibt keine Wartungszusage, keine Verfügbarkeitsgarantie und keine Gewähr für Fehlerfreiheit oder Eignung für einen bestimmten Zweck. Nutzung auf eigenes Risiko.
