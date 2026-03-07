# MediaBrain

Lokale, datenschutzfreundliche Medien-Zentrale, die Inhalte aus allen Quellen automatisch erkennt, sammelt, organisiert und zugaenglich macht.
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
- Chronik (erstellt, zuletzt geoeffnet, Oeffnungsmethode)

### Oeffnen-Logik
- Browser, App-Deep-Links, lokale Dateien
- Auto-Modus (merkt sich letzte Methode)

### Dashboard
- Favoriten und zuletzt geoeffnet
- Globale Suche, Statistiken, Quick Actions

### Bibliotheken
- Filme, Serien, Musik, Clips
- Podcasts, Hoerbuecher, Dokumente

### Weitere Features
- Light/Dark Theme mit dynamischem Umschalten
- Reaktives Refresh-System (Background -> Queue -> MainThread -> GUI)
- Blacklist-Verwaltung mit Filter und Dauer

## Architektur

```
Core Layer       Database, MediaManager, BlacklistManager, EventProcessor
Provider Layer   Netflix, YouTube, Spotify, Local
Background Layer FileIndexer, BrowserWatcher, AppWatcher, TrayApp
GUI Layer        Dashboard, Bibliotheken, Favoriten, Blacklist, Einstellungen
```

Vollstaendiges Architekturdiagramm: [ARCH.md](ARCH.md)

## Screenshots

![Hauptfenster](screenshots/main.png)

## Installation

### Voraussetzungen

- Python >= 3.8
- PyQt6

### Setup

```bash
pip install -r requirements.txt
```

### Konfiguration

Beim ersten Start wird `settings.json` erstellt. Eine Beispielkonfiguration liegt in `settings.example.json`.

## Verwendung

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

Dieses Projekt verwendet PyQt6 (GPL).

---

**Autor:** Lukas Geiger
**Letzte Aktualisierung:** Maerz 2026

---

English version: [README.md](README.md)
