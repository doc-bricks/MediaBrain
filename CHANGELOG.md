# Changelog / Änderungsprotokoll

Alle wesentlichen Änderungen an diesem Projekt werden hier dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Behoben / Fixed

- `gui_playlists.py`: Der kompakte `✕`-Button zum Entfernen einer
  Smart-Playlist-Bedingung exponiert jetzt einen sprechenden Tooltip sowie
  Accessible Name und Description, damit die kompakte Symbol-UI im Dialog auch
  per Screenreader klar bleibt. Regression in `tests/test_gui_playlists.py`.
- Legacy-Dokumente mit `type = "file"` verschwinden nicht mehr aus der
  Dokumentbibliothek: `core.py` kanonisiert den Legacy-Typ jetzt auf
  `document`, und die Dokumentliste liest für Bestandsdaten `document`
  sowie `file` gemeinsam ein. Regression in
  `tests/test_media_type_settings.py`.
- `web_companion/src/lib/smartPlaylist.test.ts` baut jetzt wieder sauber mit `tsc -b`: die
  Test-Fixture `makeItem()` entkoppelt `id` vom Rest-Override, statt dieselbe Property erst
  explizit und dann nochmals via Spread zu setzen.
- YouTube-, Spotify- und Apple-TV-URL-Erkennung prüft jetzt exakte Hostnamen
  oder vertrauenswürdige Subdomains statt freier Substring-Treffer.
- `gui.py` (Qt-Layout-Fix): `MediaItemWidget`-Inlay-Panels (Favoriten, Verlauf,
  Suchergebnisse im Dashboard) zeigten abgeschnittene Emoji-Icons und zu enge Buttons.
  Konstanten erhöht: `ICON_SIZE` 36→44 px, `ITEM_MIN_HEIGHT` 56→64 px,
  `fav_btn` 40→44 px, `ACTION_BUTTON_MIN_SIZE`-Höhe 36→40 px; Icon-Schriftgröße
  auf 22 px angepasst. 6 neue Regressionstests in `tests/test_gui_inlay_layout.py`.
  (User-Wunsch 2026-06-15, behoben 2026-06-28)
- `core.py` (B-012): `_build_browser_url()` baute bei Netflix und Spotify ungültige
  Direkt-URLs, wenn `provider_id` per Fenstertitel-Fallback gesetzt war (kein echter
  numerischer/Base62-Bezeichner). Analog zum bestehenden YouTube-Fix: neue Regex-Konstanten
  `_NF_REAL_ID` (`^\d+$`) und `_SP_REAL_ID` (`^[A-Za-z0-9]{10,}$`) validieren die ID;
  ohne Treffer → Such-URL (`/search?q=…` bzw. `open.spotify.com/search/…`).
  6 Regressionstests in `tests/test_database.py` (`TestBuildBrowserUrl`).
- `core.py` (B-012/B-013/B-014, 2026-06-28): `OpenHandler` konnte Medien von 4 von 8
  Providern nicht öffnen — `_build_browser_url()` gab für `disney`, `prime`, `appletv`,
  `twitch` immer `None` zurück (stiller Fehlschlag). Außerdem baute `_build_deep_link()`
  ungültige `spotify:`-URIs bei Fallback-Titeln als `provider_id`, und `_open_local()`
  warf `OSError` bei gelöschten Dateien ohne Rückmeldung an den User.
  Fixes: (1) `_build_browser_url()` um alle 4 Provider erweitert (Disney+/Prime mit
  Direkt-URL bei gültiger ID, sonst Homepage; Apple TV+ immer Homepage da ID allein nicht
  rekonstruierbar; Twitch mit Channel-URL); (2) `_build_deep_link()` prüft Spotify-ID
  via `_SP_REAL_ID` und gibt `None` zurück statt ungültigem Link; (3) `_open_local()`
  prüft `Path(path).exists()` vor `os.startfile()`. +23 Regressionstests
  (`TestBuildBrowserUrl`, `TestBuildDeepLink`, `TestOpenLocal` in `tests/test_database.py`).
- MB-001: `SearchCriteria.local_only` hatte keinen Effekt — Feld fehlte in `SearchCriteria`, `_on_local_only_toggle`-Handler war nicht angeschlossen. Regressionstests in `tests/test_search_advanced.py` hinzugefügt.
- Die kompakte `AdvancedSearchBar` behält ihre Symbol-/Kompakt-UI, exponiert aber jetzt sprechende Accessible Names, Descriptions und Tooltips für Suchfeld, Favoritenfilter und unbeschriftete Filter-Combos. Offscreen-Regressionstests in `tests/test_search_advanced.py` decken den A11y-Kontext ab.

### Geändert / Changed

- `ROADMAP.md`, `PORTIERUNGSPLAN.md` und die lokale Aufgabensteuerung trennen
  jetzt projektweiten Status, Plattformentscheidungen, Strangnachweise und offene
  TASKPLAN-Arbeit eindeutig. Lokale Contract-/Build-Smokes werden ausdrücklich
  nicht als Android-, iOS-, macOS-, Linux- oder Store-Live-Nachweis gewertet.
- `THIRD_PARTY_LICENSES.txt` ergänzt eine direkte Inventur der Python-Desktop- und
  Web/PWA-Companion-Abhängigkeiten; README/README_de verlinken die Lizenzinventur.
- `.gitignore` schließt `LOCK*.txt` aus, damit temporäre Multi-Agenten-Sperren nicht
  versehentlich in Git auftauchen.
- README, README_de, `llms.txt` und Web-Companion-Paketmetadaten mit präziseren Discovery-, PWA-Companion- und Disambiguation-Ankern für `doc-bricks/MediaBrain`, private SQLite-Medienbibliotheken, PySide6-Smart-Playlists und lokale Medienverlauf-Verwaltung aktualisiert.
- `web_companion/` für Android- und iOS-PWA-Nutzung gehärtet: `viewport-fit=cover`, Apple-Web-App-Metadaten, Safe-Area-Layout, 44px-Touch-Ziele in der Bottom-Navigation und kontextuelle Install-Hinweise vor dem ersten Add-to-Home-Screen.
- `web_companion/package.json` ergänzt jetzt die reproduzierbaren Sicherheits-Scripts `npm run audit` und `npm run audit:prod`; Companion-README, `PORTING_STATUS.md` und `AUFGABEN.txt` sind auf den verifizierten Audit-Stand vom 2026-07-02 synchronisiert.
- README auf English-first GitHub-Landing-Page umgestellt und separate deutsche README ergänzt.
- `llms.txt` mit kanonischem Projektkontext, Suchphrasen und Privacy-Grenzen ergänzt.
- Community-Workflows auf aktuelle Major-Versionen gehoben.

### Hinzugefügt / Added

- Desktop-Einstellungen für sichtbare Medientypen ergänzt: Filme, Serien, Musik,
  Clips, Podcasts, Hörbücher und Dokumente können einzeln in der Bibliotheks-
  Navigation ein- oder ausgeblendet werden; Dokumente sind dabei ein regulärer
  Medientyp und werden standardmäßig mitgeführt.
- `web_companion/src/lib/smartPlaylist.ts`: TypeScript-Port des Desktop-QueryBuilders als
  In-Memory-Regel-Engine. Unterstützt alle Operatoren (`=`, `!=`, `>`, `>=`, `<`, `<=`,
  `contains`, `starts_with`, `not_contains`, `is_empty`, `is_not_empty`), Feld-Aliase
  aus `query_builder.py`, Tags als Array-Sonderfall, Bool-/Zahlen-Koercion (`is_favorite`)
  sowie korrekte AND/OR-Präzedenz (Sum-of-Products wie SQL: AND bindet stärker als OR).
- `web_companion/src/lib/smartPlaylist.test.ts`: 41 Vitest-Tests für parseSmartQuery
  (JSON-String-Input vom Desktop, Objekt, Fehlerfälle), alle Operatoren, Feld-Aliase,
  Bool-Koercion, AND/OR-Präzedenz und Sortierung/Limit.
- `web_companion/src/screens/PlaylistsScreen.tsx` aktualisiert: Smart-Playlists
  (`type = "smart"`) werden jetzt client-seitig mit der Regel-Engine ausgewertet;
  Trefferzahl, Vorschau der ersten 5 Items und „Smart"-Badge werden angezeigt.

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
