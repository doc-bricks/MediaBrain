# MediaBrain

Ein lokaler, datenschutzfreundlicher Media-Hub, der Inhalte aus allen Quellen automatisch erkennt, sammelt, organisiert und zugaenglich macht.
Vereint Streaming-Dienste, lokale Dateien, Browser-Aktivitaet und App-Nutzung in einer einzigen Oberflaeche.

## Features

### Medienerkennung
- Netflix-Titel
- YouTube-Videos
- Spotify-Tracks
- Lokale Dateien (mp3, mp4, mkv, pdf, epub ...)

### Medienverwaltung
- Favoriten und Blacklist (mit Ablaufdatum)
- Sortierung, Filter, Detailansicht
- Verlauf (erstellt, zuletzt geoeffnet, Oeffnungsmethode)

### Oeffnungslogik
- Browser, App-Deep-Links, lokale Dateien
- Auto-Modus (merkt sich letzte Methode)

### Dashboard
- Favoriten und zuletzt geoeffnet
- Globale Suche, Statistiken, Schnellaktionen

### Bibliotheken
- Filme, Serien, Musik, Clips
- Podcasts, Hoerbuecher, Dokumente

### Weitere Features
- Hell/Dunkel-Theme mit dynamischem Wechsel
- Reaktives Refresh-System (Background -> Queue -> MainThread -> GUI)
- Blacklist-Verwaltung mit Filter und Dauer

## Architektur

```
Core Layer       Datenbank, MediaManager, BlacklistManager, EventProcessor
Provider Layer   Netflix, YouTube, Spotify, Lokal
Background Layer FileIndexer, BrowserWatcher, AppWatcher, TrayApp
GUI Layer        Dashboard, Bibliotheken, Favoriten, Blacklist, Einstellungen
```

Vollstaendiges Architekturdiagramm: [ARCH.md](ARCH.md)

## Screenshots

![Hauptfenster](screenshots/main.png)

## Installation

### Voraussetzungen

- Python >= 3.8
- PySide6

### Setup

```bash
pip install -r requirements.txt
```

### Konfiguration

Beim ersten Start wird `settings.json` erstellt. Eine Beispielkonfiguration ist in `settings.example.json` verfuegbar.

## Nutzung

```bash
python MediaBrain.py
```

Oder ueber die Batch-Datei:

```bash
START.bat
```

## Roadmap

Offene Punkte und geplante Features: [ROADMAP.md](ROADMAP.md)

## Lizenz

GPL v3 - Siehe [LICENSE](LICENSE)

Dieses Projekt verwendet PySide6 (LGPL).

---

**Autor:** Lukas Geiger
**Zuletzt aktualisiert:** Maerz 2026

---

## English

A local, privacy-friendly media hub that automatically detects, collects, organizes, and makes accessible content from all sources.
Unifies streaming services, local files, browser activity, and app usage in a single interface.

### Features

#### Media Detection
- Netflix titles
- YouTube videos
- Spotify tracks
- Local files (mp3, mp4, mkv, pdf, epub ...)

#### Media Management
- Favorites and blacklist (with expiration date)
- Sorting, filters, detail view
- History (created, last opened, opening method)

#### Open Logic
- Browser, app deep links, local files
- Auto mode (remembers last method)

#### Dashboard
- Favorites and recently opened
- Global search, statistics, quick actions

#### Libraries
- Movies, series, music, clips
- Podcasts, audiobooks, documents

#### Additional Features
- Light/Dark theme with dynamic switching
- Reactive refresh system (Background -> Queue -> MainThread -> GUI)
- Blacklist management with filter and duration

### Architecture

```
Core Layer       Database, MediaManager, BlacklistManager, EventProcessor
Provider Layer   Netflix, YouTube, Spotify, Local
Background Layer FileIndexer, BrowserWatcher, AppWatcher, TrayApp
GUI Layer        Dashboard, Libraries, Favorites, Blacklist, Settings
```

Full architecture diagram: [ARCH.md](ARCH.md)

### Screenshots

![Main Window](screenshots/main.png)

### Installation

#### Prerequisites

- Python >= 3.8
- PySide6

#### Setup

```bash
pip install -r requirements.txt
```

#### Configuration

On first launch, `settings.json` is created. A sample configuration is available in `settings.example.json`.

### Usage

```bash
python MediaBrain.py
```

Or via the batch file:

```bash
START.bat
```

### Roadmap

Open items and planned features: [ROADMAP.md](ROADMAP.md)

### License

GPL v3 - See [LICENSE](LICENSE)

This project uses PySide6 (LGPL).

---

**Author:** Lukas Geiger
**Last Updated:** March 2026
