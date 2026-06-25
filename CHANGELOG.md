# Changelog / Änderungsprotokoll

Alle wesentlichen Änderungen an diesem Projekt werden hier dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Behoben / Fixed

- YouTube-, Spotify- und Apple-TV-URL-Erkennung prüft jetzt exakte Hostnamen
  oder vertrauenswürdige Subdomains statt freier Substring-Treffer.
- `core.py` (B-012): `_build_browser_url()` baute bei Netflix und Spotify ungültige
  Direkt-URLs, wenn `provider_id` per Fenstertitel-Fallback gesetzt war (kein echter
  numerischer/Base62-Bezeichner). Analog zum bestehenden YouTube-Fix: neue Regex-Konstanten
  `_NF_REAL_ID` (`^\d+$`) und `_SP_REAL_ID` (`^[A-Za-z0-9]{10,}$`) validieren die ID;
  ohne Treffer → Such-URL (`/search?q=…` bzw. `open.spotify.com/search/…`).
  6 Regressionstests in `tests/test_database.py` (`TestBuildBrowserUrl`).
- MB-001: `SearchCriteria.local_only` hatte keinen Effekt — Feld fehlte in `SearchCriteria`, `_on_local_only_toggle`-Handler war nicht angeschlossen. Regressionstests in `tests/test_search_advanced.py` hinzugefügt.
- Die kompakte `AdvancedSearchBar` behält ihre Symbol-/Kompakt-UI, exponiert aber jetzt sprechende Accessible Names, Descriptions und Tooltips für Suchfeld, Favoritenfilter und unbeschriftete Filter-Combos. Offscreen-Regressionstests in `tests/test_search_advanced.py` decken den A11y-Kontext ab.

### Geändert / Changed

- README, README_de, `llms.txt` und Web-Companion-Paketmetadaten mit präziseren Discovery-, PWA-Companion- und Disambiguation-Ankern für `doc-bricks/MediaBrain`, private SQLite-Medienbibliotheken, PySide6-Smart-Playlists und lokale Medienverlauf-Verwaltung aktualisiert.
- `web_companion/` für Android- und iOS-PWA-Nutzung gehärtet: `viewport-fit=cover`, Apple-Web-App-Metadaten, Safe-Area-Layout, 44px-Touch-Ziele in der Bottom-Navigation und kontextuelle Install-Hinweise vor dem ersten Add-to-Home-Screen.
- README auf English-first GitHub-Landing-Page umgestellt und separate deutsche README ergänzt.
- `llms.txt` mit kanonischem Projektkontext, Suchphrasen und Privacy-Grenzen ergänzt.
- Community-Workflows auf aktuelle Major-Versionen gehoben.

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
