# Changelog / Änderungsprotokoll

Alle wesentlichen Änderungen an diesem Projekt werden hier dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Hinzugefügt / Added

- Playlist-GUI in `gui_playlists.py`: `PlaylistsView` als Sidebar-Eintrag,
  `SmartPlaylistDialog` mit dynamischen Bedingungs-Reihen (Operator pro Feldtyp,
  Order-By, Limit) und `ManualPlaylistDialog` für Name + Beschreibung.
- `PlaylistManager` wird in `MediaBrain.py` instanziiert und an `MainWindow`
  übergeben; Sidebar-Button "Playlists" und Stack-Eintrag werden nur angelegt,
  wenn ein Manager vorhanden ist.
- 8 GUI-Smoke-Tests in `tests/test_gui_playlists.py` (offscreen).
- `PRIVACY_POLICY.md` mit lokaler Datenspeicherung, optionalen Metadatenabfragen und GitHub-Hinweisen.
- Regressionstests für Smart-Playlists mit QueryBuilder-JSON, Tag-Filtern, dynamischen Counts und defekten Query-JSONs.
- Regressionstests für den QueryBuilder mit Schema-Aliasen, Tag-Filtern und SQL-Sanitizing.

### Geändert / Changed

- `MainWindow.refresh_all_views()` markiert auch die `PlaylistsView` dirty, sobald
  Daten extern geändert werden.
- README, Security-Policy und Contributing-Guide auf Playlist-Funktion, Datenschutz und aktuellen GitHub-Remote aktualisiert.
- `.gitignore` um zusätzliche lokale Datenbanken, Cache-, Coverage-, Backup- und Secret-Patterns erweitert.
- `settings.example.json` ist wieder valides JSON und enthält leere TMDb-/OMDb-Platzhalter.
- PlaylistManager wertet Smart-Playlists jetzt dynamisch über QueryBuilder aus; manuelle Playlists bleiben unverändert.
- QueryBuilder nutzt jetzt das echte `media_items`-Schema und kompatible Aliase für UI/JSON-Felder.

### Behoben / Fixed

- Defekte Smart-Playlist-Queries liefern keine Treffer statt versehentlich die gesamte Bibliothek.
- QueryBuilder übernimmt ungeprüfte `conjunction`-/`order_dir`-Werte nicht mehr in erzeugtes SQL.

## [1.0.0] - YYYY-MM-DD

### Hinzugefügt / Added

- Erstveröffentlichung / Initial release
