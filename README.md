# MediaBrain

Ein lokaler, datenschutzfreundlicher Media-Hub, der Inhalte aus allen Quellen automatisch erkennt, sammelt, organisiert und zugaenglich macht.
Vereint Streaming-Dienste, lokale Dateien, Browser-Aktivitaet und App-Nutzung in einer einzigen Oberflaeche.

> A local, privacy-friendly media hub that automatically detects, collects, organizes, and makes accessible content from all sources. Unifies streaming services, local files, browser activity, and app usage in a single interface.

## Screenshots

![Hauptfenster / Main Window](screenshots/main.png)

## Features

- **Medienerkennung / Media Detection:** Netflix, YouTube, Spotify, lokale Dateien (mp3, mp4, mkv, pdf, epub ...)
- **Medienverwaltung / Media Management:** Favoriten, Blacklist mit Ablaufdatum, Sortierung, Filter, Detailansicht, Verlauf
- **Oeffnungslogik / Open Logic:** Browser, App-Deep-Links, lokale Dateien, Auto-Modus
- **Dashboard:** Favoriten, zuletzt geoeffnet, globale Suche, Statistiken, Schnellaktionen
- **Bibliotheken / Libraries:** Filme, Serien, Musik, Clips, Podcasts, Hoerbuecher, Dokumente
- **Themes:** Hell/Dunkel/High-Contrast mit dynamischem Wechsel
- **Tag-System:** Tags erstellen, zuweisen, filtern
- **System Tray:** Optionales Minimieren ins Tray statt Beenden
- **Reaktives Refresh-System:** Background -> Queue -> MainThread -> GUI

## Architektur / Architecture

```
Core Layer       Datenbank, MediaManager, BlacklistManager, EventProcessor, TagManager
Provider Layer   Netflix, YouTube, Spotify, Disney+, Prime, AppleTV+, Twitch, Lokal
Background Layer FileIndexer, WindowWatcher
GUI Layer        Dashboard, Bibliotheken, Favoriten, Blacklist, Statistiken, Einstellungen
```

Vollstaendiges Diagramm / Full diagram: [ARCH.md](ARCH.md)

## Installation

- Python >= 3.8
- PySide6

```bash
pip install -r requirements.txt
```

Beim ersten Start wird `settings.json` erstellt. Beispielkonfiguration: `settings.example.json`.

## Nutzung / Usage

```bash
python MediaBrain.py
```

## Roadmap

[ROADMAP.md](ROADMAP.md)

## Lizenz / License

GPL v3 - Siehe/See [LICENSE](LICENSE). Dieses Projekt verwendet PySide6 (LGPL).

---

**Autor:** Lukas Geiger | **Zuletzt aktualisiert:** Maerz 2026
