# Windows Store Preparation & Packaging Guide — MediaBrain

Stand: 2026-08-21

## Übersicht

MediaBrain wird als modernes MSIX-Paket für den Microsoft Store paketiert. Das Paket kapselt die lokale PySide6-Desktop-Anwendung in einer sicheren, offline-fähigen Windows-Desktop-Container-Umgebung.

## Metadaten & Identität

- **Publisher:** CN=52596601-BAB4-4F3F-B182-E8F3F273B202
- **Publisher Display:** Lukas Geiger
- **Identity Name:** Geiger.MediaBrain
- **Package Version:** 2.1.0.0
- **Category:** Entertainment
- **Capabilities:** 
unFullTrust, internetClient
- **Languages:** de-DE, n-US
- **Executable:** MediaBrain.exe

## Erledigte Vorbereitungsschritte

1. **Paketierungs-Metadaten (store_package.json):**
   - Vollständige Publisher-DN, Identity-Name und Versionsangaben (2.1.0.0) konfiguriert.
   - HTTPS-URLs für Datenschutzrichtlinie und Support hinterlegt.

2. **Windows Desktop AppxManifest (store_package/MediaBrain/AppxManifest.xml):**
   - Canonical AppxManifest mit TargetDeviceFamily Windows.Desktop (MinVersion 10.0.17763.0, MaxVersionTested 10.0.26100.0).
   - Mehrsprachige Ressourcen (de-de, n-us) und Tile-Deklarationen eingebunden.

3. **MSIX Tile- und Icon-Assets:**
   - Vollständiges Set an Kachel- und Logo-Assets:
     - icon_44x44.png (Square44x44Logo / Square71x71Logo)
     - icon_50x50.png (Square50x50Logo / StoreLogo)
     - icon_150x150.png (Square150x150Logo)
     - icon_310x150.png (Wide310x150Logo)
     - icon_310x310.png (Square310x310Logo)
   - Synchron gehalten in ssets/icons/, store_package/MediaBrain/icons/ und store_assets/.

4. **Store Screenshots:**
   - Vier hochauflösende Screenshots unter screenshots/store/ und README/screenshots/store/:
     - shot-1-library-overview.png: Bibliotheksübersicht mit Mediengittern
     - shot-2-smart-playlists.png: Intelligente Wiedergabelisten und QueryBuilder
     - shot-3-metadata-tags.png: Metadaten-Editor, Tags und Detailansichten
     - shot-4-export-backup.png: JSON-Export, Sicherungen und Migration

5. **Bilingualer Store-Listing-Entwurf (STORE_LISTING.md):**
   - Vollständige deutsche und englische Beschreibungen mit Feature-Listen.
   - Strikt maximal 7 Suchbegriffe pro Sprache gemäß **Microsoft Store Policy 10.1.3** ohne Fremdmarkenverletzungen.

6. **Automatisiertes Readiness-Audit (scripts/check_store_readiness.py):**
   - Automatisierte Validierung aller Manifeste, Metadaten, Icons, Screenshots und Lizenzdokumente.
   - Getestet über Pytest in 	ests/test_store_materials.py.

## Vor der Einreichung im Partner Center (externe Gates)

- **Partner Center Reservierung:** Identität Geiger.MediaBrain und Anzeigename MediaBrain im Microsoft Partner Center bestätigen.
- **MSIX-Erstellung & Signierung:** Produktions-MSIX im Packaging-Workflow erstellen und mit Entwicklerzertifikat signieren.
- **WACK-Zertifizierungstest:** Windows App Certification Kit mit OVERALL RESULT: PASS durchlaufen.
- **Partner Center Upload:** Signiertes .msix-Paket, Listing-Texte und Screenshots übermitteln.

## Technische Hinweise

- **Lokale Datenhaltung:** MediaBrain speichert Konfiguration und SQLite-Metadatenbank lokal unter %LOCALAPPDATA%\MediaBrain bzw. Standard-Desktop-Pfade.
- **Netzwerkzugriffe:** Erfolgen ausschließlich bei aktivierter optionaler Metadatensuche (TMDb, OMDb, MusicBrainz) über HTTPS.
- **Datenschutz:** 100% Offline-First, keine Telemetrie, kein Tracking.
