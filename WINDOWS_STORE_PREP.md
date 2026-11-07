# Windows Store Preparation & Packaging Guide — MediaBrain

Stand: 2026-11-07

## Übersicht

MediaBrain wird als modernes MSIX-Paket für den Microsoft Store paketiert. Das Paket kapselt die lokale PySide6-Desktop-Anwendung in einer sicheren, offline-fähigen Windows-Desktop-Container-Umgebung.

## Metadaten & Identität

- **Publisher:** CN=52596601-BAB4-4F3F-B182-E8F3F273B202
- **Publisher Display:** Lukas Geiger
- **Identity Name:** Geiger.MediaBrain
- **Package Version:** 2.1.0.0
- **Category:** Entertainment
- **Capabilities:** runFullTrust, internetClient
- **Languages:** de-DE, en-US, es-ES, zh-CN, ja-JP, ru-RU
- **Executable:** MediaBrain.exe

## Erledigte Vorbereitungsschritte

1. **Paketierungs-Metadaten (store_package.json & store_settings.json):**
   - Vollständige Publisher-DN, Identity-Name und Versionsangaben (2.1.0.0) konfiguriert.
   - HTTPS-URLs für Datenschutzrichtlinie und Support hinterlegt.
   - Sprachenliste (`languages`) auf alle 6 Tier-2 Zielsprachen (de-DE, en-US, es-ES, zh-CN, ja-JP, ru-RU) und Lizenz auf `MIT` standardisiert.
   - Kurzbeschreibungen für alle 6 Sprachen hinterlegt und normiert auf strikt <= 100 Zeichen.
   - Genau 7 markenrechtsfreie Suchbegriffe je Sprache definiert (Policy 10.1.3, <= 30 Zeichen je Begriff).

2. **Windows Desktop AppxManifest (store_package/MediaBrain/AppxManifest.xml):**
   - Canonical AppxManifest mit TargetDeviceFamily Windows.Desktop (MinVersion 10.0.17763.0, MaxVersionTested 10.0.26100.0).
   - Mehrsprachige Ressourcen im `<Resources>`-Block für alle 6 Sprachen (de-de, en-us, es-es, zh-cn, ja-jp, ru-ru) deklariert.
   - Tile-Deklarationen und Properties-Logo auf standardkonformes `icons\StoreLogo.png` (50×50) gehärtet.

3. **MSIX Tile- und Icon-Assets:**
   - Vollständiges Set an Kachel- und Logo-Assets:
     - icon_44x44.png (Square44x44Logo / Square71x71Logo)
     - icon_50x50.png / StoreLogo.png (Square50x50Logo / StoreLogo)
     - icon_150x150.png (Square150x150Logo)
     - icon_310x150.png (Wide310x150Logo)
     - icon_310x310.png (Square310x310Logo)
   - Synchron gehalten in `assets/icons/`, `store_package/MediaBrain/icons/`, `store_assets/` und `releases/windowsstore/`.

4. **Store Screenshots:**
   - Vier hochauflösende Screenshots unter `screenshots/store/`, `README/screenshots/store/` und `releases/windowsstore/screenshots/`:
     - shot-1-library-overview.png: Bibliotheksübersicht mit Mediengittern (1920×1080)
     - shot-2-smart-playlists.png: Intelligente Wiedergabelisten und QueryBuilder (1920×1080)
     - shot-3-metadata-tags.png: Metadaten-Editor, Tags und Detailansichten (1920×1080)
     - shot-4-export-backup.png: JSON-Export, Sicherungen und Migration (1920×1080)

5. **Tier-2 6-Sprachen Store-Listing-Entwurf (STORE_LISTING.md):**
   - Vollständige Store-Listings für Deutsch, Englisch, Spanisch, Chinesisch (vereinfacht), Japanisch und Russisch.
   - Strikt maximal 7 Suchbegriffe pro Sprache gemäß **Microsoft Store Policy 10.1.3** ohne Fremdmarkenverletzungen.
   - Standalone Staging-Dateien unter `releases/windowsstore/`:
     - `store_listing_de.md`
     - `store_listing_en.md`
     - `store_listing_es.md`
     - `store_listing_zh.md`
     - `store_listing_ja.md`
     - `store_listing_ru.md`

6. **Packaging-Staging (`releases/windowsstore/`):**
   - Vollständiges Staging aufgebaut: `BUILD.md`, `WACK_PROTOCOL.md`, `store_settings.json`, alle 6 `store_listing_<lang>.md` Dateien, Kachelicons inkl. `StoreLogo.png`, `screenshots/` und `test_reports/`.

7. **WACK-Preflight & Readiness-Audit:**
   - WACK-Runner `scripts/run_windows_wack.py` generiert hermetische XML- und JSON-Preflight-Reports (`OVERALL RESULT: PASS`, 6/6 Kriterien erfüllt).
   - Automatisierte Validierung über `scripts/check_store_readiness.py` (gehärtet auf alle 6 Zielsprachen) und Pytest-Vertragstests in `tests/test_store_materials.py`.

## Vor der Einreichung im Partner Center (externe Gates)

- **Partner Center Reservierung:** Identität Geiger.MediaBrain und Anzeigename MediaBrain im Microsoft Partner Center bestätigen.
- **MSIX-Erstellung & Signierung:** Produktions-MSIX im Packaging-Workflow erstellen und mit Entwicklerzertifikat signieren.
- **WACK-Zertifizierungstest:** Windows App Certification Kit mit OVERALL RESULT: PASS durchlaufen.
- **Partner Center Upload:** Signiertes .msix-Paket, Listing-Texte und Screenshots übermitteln.

## Technische Hinweise

- **Lokale Datenhaltung:** MediaBrain speichert Konfiguration und SQLite-Metadatenbank lokal unter %LOCALAPPDATA%\MediaBrain bzw. Standard-Desktop-Pfade.
- **Netzwerkzugriffe:** Erfolgen ausschließlich bei aktivierter optionaler Metadatensuche (TMDb, OMDb, MusicBrainz) über HTTPS.
- **Datenschutz:** 100% Offline-First, keine Telemetrie, kein Tracking.
