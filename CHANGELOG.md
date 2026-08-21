# Changelog / Änderungsprotokoll

Alle wesentlichen Änderungen an diesem Projekt werden hier dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Tag-Matching, Query-Builder & Smart-Playlist Import Hardening [2026-08-21]
- **QueryBuilder Tag-Filter-Operatoren (`query_builder.py`):** Vollständige Unterstützung für die Operatoren `!=`, `starts_with`, `is_empty` und `is_not_empty` beim Tag-Filtering implementiert. Zuvor wurden diese gültigen Operatoren in `_build_tag_condition` lautlos übersprungen und führten zu ungefilterten Gesamtabfragen.
- **Smart-Playlist-Import Typsicherheit (`export_import.py`):** `smart_query`-Payloads werden beim Import aus JSON-Dateien auch dann via `_coerce_value` sicher als JSON-Zeichenkette serialisiert, wenn sie als verschachteltes Dictionary übergeben werden, wodurch `sqlite3.ProgrammingError` zuverlässig verhindert wird.
- **Regressionstests (`tests/`):** 5 neue Tests in `tests/test_query_builder.py`, `tests/test_playlists.py` und `tests/test_export_import.py` integriert; Pytest-Vollsuite mit 263 Tests und 29 Subtests zu 100% grün (56.7s).
- **Windows Store Preparation Guide (`WINDOWS_STORE_PREP.md`):** Umfassenden Leitfaden mit Identitätsmetadaten (`CN=52596601-BAB4-4F3F-B182-E8F3F273B202`, `Geiger.MediaBrain`, `2.1.0.0`), Vorbereitungsschritten, Kachel-Assets, Screenshot-Zuordnungen, Partner-Center-Gates und Offline-First-Architektur implementiert.
- **Store Policy 10.1.3 Compliance (`STORE_LISTING.md`):** Bilinguale Suchbegriffe (Suchbegriffe / Keywords) auf strikt maximal 7 Keywords pro Sprache ohne Fremdmarkenverletzungen gehärtet.
- **Store-Asset-Spiegelung (`store_assets/`):** Vollständiges Set an MSIX-Tile-Icons (`icon_44x44.png`, `icon_50x50.png`, `icon_150x150.png`, `icon_310x150.png`, `icon_310x310.png`) in `store_assets/` synchronisiert.
- **Automatisierter Readiness-Auditor (`scripts/check_store_readiness.py`):** Prüfung um `WINDOWS_STORE_PREP.md`, strikte Keyword-Limits (Policy 10.1.3) und Kachelicon-Verifikation über alle drei Speicherorte (`assets/icons/`, `store_assets/`, `store_package/MediaBrain/icons/`) erweitert.
- **Testsuite-Erweiterung (`tests/test_store_materials.py`):** 4 neue Contract-Tests für Keyword-Limits, Metadaten-Parität, Multi-Location-Tile-Assets und deutsche Umlaut-Integrität hinzugefügt (8/8 passed, 258/258 Pytest-Tests grün).

### Flutter Mobile Port: Smart-Playlists & Tag-System (Android/iOS) [2026-08-21]
- **Datenmodelle & Smart-Matching:** Neue Modelle `MediaTag`, `Playlist`, `SmartPlaylistQuery` und `PlaylistType` mit nativer JSON-Serialisierung und deterministischer In-Memory-Query-Matching-Engine für dynamische Smart-Playlists (Filter nach Kategorie, Tag, Favoriten, Mindest-Foreground-Zeit und Volltext-Suchquery) in `flutter_port/lib/models/models.dart`.
- **SQLite-Schema v2 & Persistenz:** SQLite-Datenbank in `DatabaseService` (`flutter_port/lib/services/database_service.dart`) auf Version 2 aktualisiert mit automatischer Migration (`playlists`, `playlist_items`), Indexierung, Tag-Aggregation (`listTags`, `addTagToItem`, `removeTagFromItem`) und vollständigen Playlist-CRUD-Methoden (`listPlaylists`, `getPlaylist`, `upsertPlaylist`, `deletePlaylist`, `addItemToPlaylist`, `removeItemFromPlaylist`, `getPlaylistItems`, `evaluateSmartPlaylist`).
- **UI-Screens & Dialoge:** Neuer Tab `PlaylistsScreen` (`flutter_port/lib/screens/playlists_screen.dart`), Playlist-Detailansicht mit Smart-Filter-Chips und Entfernungs-Funktion (`flutter_port/lib/screens/playlist_detail_screen.dart`), Erstellungs-/Bearbeitungsdialog (`flutter_port/lib/dialogs/playlist_dialog.dart`), interaktive Tag-Verwaltung und Schnellzuweisung in `item_detail_screen.dart`, Tag-Filter-Chips in `library_screen.dart` sowie Tab-Integration in `home_screen.dart`.
- **Vollständige Lokalisierung & Parität:** Bilinguale DE/EN Lokalisierungs-Strings mit echten deutschen Umlauten in `flutter_port/lib/l10n/app_localizations.dart`.
- **Testabdeckung & Qualitätsprüfung:** Neue Dart-Testsuite `flutter_port/test/playlists_and_tags_test.dart` und Python-Contract-Testsuite `tests/test_flutter_playlists_and_tags_contract.py` integriert; 254/254 Pytest-Tests erfolgreich bestanden (100% grün).

### Discoverability, README-Design, Badges & Metadata Parity / Maintenance (Pfad B) [2026-08-20]
- `README.md` & `README_de.md`: Badges für Version (`2.1.0`), Tests (`247 passed`), `doc-bricks`-Ökosystem und `open-bricks`-Dachprojekt synchronisiert.
- `README.md` & `README_de.md`: Umfassende zweisprachige Geschwisterwerkzeuge-Matrix innerhalb der `doc-bricks`-, `file-bricks`- und `open-bricks`-Ökosysteme (`CleanMarkdown`, `PDFtoPDFocr`, `llm-note`, `LaunchBoards`, `ProFiler`, `KnowledgeDigest`, `WinStorePackager`, `DevCenter`, `open-bricks`) integriert.
- `tests/test_repo_metadata.py`: Neue automatisierte Testsuite für Versionsparität (`version.py`, `pyproject.toml`, `store_package.json`, `AppxManifest.xml`, Docs), Badges und Dokumentationsintegrität implementiert.
- `llms.txt`: Last-checked Timestamp auf `2026-08-20` und Schlüsseldateienliste um `test_repo_metadata.py` erweitert.
- Testsuite-Verifikation: Vollständige Pytest-Suite mit 247/247 Tests (29 Subtests) erfolgreich bestanden.

### Technische Hygiene & Linting-Standardisierung / Maintenance (Pfad A) [2026-08-16]
- `pyproject.toml`: `[tool.ruff]` und `[tool.ruff.lint]` Konfiguration integriert (`target-version = "py310"`, `line-length = 120`, `E501`/`E402`/`E701`/`E741`/`F841` ignore, `ruff check` 100% sauber).
- `patch_metadata_panel.py`, `search_advanced.py`, `tests/`: Ungenutzte Imports und Trailing Whitespace bereinigt.
- `llms.txt`: Last-checked Timestamp auf `2026-08-16` aktualisiert.
- Testsuite-Verifikation: 244/244 Pytest-Tests bestanden (30.73s).

### Windows Store Release Packaging & Asset Staging (TW-MB-01 / #935) [2026-08-14]
- **Windows Store Packaging Staging:** `store_package/MediaBrain/AppxManifest.xml` mit `Geiger.MediaBrain`, Version `2.1.0.0`, `runFullTrust`-Capability, `de-de`/`en-us`-Lokalisierungsressourcen und Standard-Tile-Bindings angelegt.
- **Store-Tile & Multi-Resolution App Icons:** Vollständiges Asset-Set in `assets/` und `store_package/MediaBrain/icons/` generiert (`icon_44x44.png`, `icon_50x50.png`, `icon_150x150.png`, `icon_310x150.png`, `icon_310x310.png`, 512x512 Master-PNG, Favicon sowie Multi-Layer Windows-ICOs `MediaBrain.ico`, `assets/app_icon.ico`, `assets/icon.ico` mit allen 7 Standardauflösungen).
- **Store Promo & Feature Screenshots:** 4 hochauflösende 1920x1080 Store-Screenshots unter `screenshots/store/` und `README/screenshots/store/` (`shot-1-library-overview.png`, `shot-2-smart-playlists.png`, `shot-3-metadata-tags.png`, `shot-4-export-backup.png`) bereitgestellt.
- **Fail-Closed Store-Readiness Audit:** `scripts/check_store_readiness.py` zu vollständigem Release-Gate-Tool ausgebaut (prüft Manifest, JSON-Metadaten, Versionsparität, Kachelicons, Store-Screenshots, bilinguale Doku, Lizenz/Datenschutz sowie externe WACK/MSIX/SBOM/Signaturnachweise).
- **Testabdeckung & Asset-Validierung:** `tests/test_store_materials.py` erweitert und neue Testsuite `tests/test_app_assets.py` integriert (244/244 Tests passed).
- **Build-Tooling:** `build_exe.bat` um automatische Einbettung von `assets` und `locales` (`--add-data`) ergänzt.

### Technische Hygiene & Doku-Wartung / Maintenance (Pfad A) [2026-07-29]
- `llms.txt`: Header auf `Last-checked: 2026-07-29` aktualisiert.
- `README.md` & `README_de.md`: Pytest-Statusbadge auf 239 Passed Tests synchronisiert.

### Added
- Windows Store readiness materials now provide a repository-owned
  `store_package.json`, bilingual `STORE_LISTING.md`, and `SUPPORT.md`.
  `scripts/check_store_readiness.py` validates their required metadata without
  treating Partner Center, MSIX signing, or WACK as complete.
- `tests/source_platform_smoke.py` covers Unicode paths, configuration and JSON
  exchange, the runner-specific file opener, and the offscreen window/tray
  lifecycle. `source-platform-smoke.yml` runs the focused contract on Ubuntu
  and macOS without claiming native packaging or manual desktop acceptance.

### Behoben / Fixed
- Die sichtbare Fehlermeldung beim temporären Ausblenden verwendet jetzt das
  korrekte deutsche Wort „Temporäres“; eine Offscreen-Regression sichert den
  gesamten Fehlerpfad.
- Der Flutter-Import erhält `foreground_minutes` und `last_opened_at` bei
  Desktop-Payloads, die diese Mobile-Felder nicht mitsenden. Explizit gelieferte
  Werte werden weiterhin übernommen; Regressionstests und ein neuer
  Flutter-3.44-CI-Smoke sichern den Vertrag.

### Geändert / Changed
- Die Flutter-Mobil-Linie verwendet wieder einen konsistenten, aus `flutter_port/assets/icons/icon.png` abgeleiteten App-Icon-Satz für Android-Launcher, adaptiven Foreground und iOS-AppIcons. `README.md`, `README_de.md`, `flutter_port/README.md` und `flutter_port/PORTING_STATUS.md` verweisen auf den aktuellen Mobile-Stand.
- Die öffentlichen Testhinweise und Badges spiegeln jetzt 238 gesammelte Tests
  sowie die Grenze zwischen Source-/Offscreen-Smoke und Live-Abnahme.

## [2.1.0-hygiene] - 2026-07-25

### Hinzugefügt / Added
- Standardisierte PEP 621 `pyproject.toml` mit Projektmetadaten, URLs und Pytest-Konfiguration (`pythonpath = "."`).
- KI / Agenten-Integrationshinweis und strukturierter Kontext-Callout in `README.md` und `README_de.md`.
- Status-Badges für Pytest (235 passed), PySide6, MIT-Lizenz, Local-First Privacy und LLM-Ready Kontext.

### Geändert / Changed
- `llms.txt` Header auf `Last-checked: 2026-07-25` aktualisiert.
- `README.md`, `README_de.md` und `llms.txt` zur Ausrichtung der Dokumentation an die Entfernung des Web-Companions bereinigt.

### Entfernt / Removed

- **Web/PWA-Companion (`web_companion/`) entfernt** — kein dokumentierter
  Nutzer-Usecase (reiner Lese-Companion ohne Aktionsnutzen), Entscheidung vom
  2026-07-23 im Rahmen des `.SOFTWARE`-Companion-Usecase-Audits. Der Strang wird
  bewusst nicht wieder aufgebaut; neue Companions/Ports nur mit dokumentiertem
  Usecase im `PORTIERUNGSPLAN.md`. Lizenzinventar, ROADMAP und Portierungsdoku
  wurden entsprechend bereinigt. Ältere Companion-Einträge unten bleiben als
  Historie erhalten.

### Behoben / Fixed

- The committed desktop translation catalog now has a nonempty English value
  for every existing key. `tests/test_translations.py` prevents incomplete
  English entries from being reintroduced.
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

- Kanonische Desktop-Version `2.0.0` in `version.py` und konsistenter Python-3.10+-Vertrag.
- Offizielle rein lesende CLI mit dokumentierter Datenbankauswahl und Blacklist-Schutz.
- Sichere Exportvorgabe: private lokale Dateipfade werden nur nach ausdrücklichem Opt-in ausgegeben.
- Mobile Server-Synchronisation auf manuelle HTTPS-Aktionen begrenzt; Hintergrund-Scans übertragen keine Bibliotheksdaten.
- PWA-Lockfile ohne bekannte npm-Schwachstellen; Backup-Testbäume sind aus dem kanonischen Vitest-Lauf ausgeschlossen.


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
