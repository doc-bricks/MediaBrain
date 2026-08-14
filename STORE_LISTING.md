# MediaBrain – Microsoft Store Listing Draft

> Status: Repository-seitig vorbereitet (Metadaten, AppxManifest, Kacheln und Screenshots vollständig gestaged).
> Externe Gates: Partner-Center-Reservierung, signiertes MSIX und WACK-Lauf.

## Deutsch

**Kurzbeschreibung**

MediaBrain organisiert persönliche Videos, Musik, Dokumente und den
Streaming-Verlauf lokal und datenschutzfreundlich auf Ihrem Windows-PC.

**Beschreibung**

MediaBrain ist eine lokale, offline-first Medienbibliothek. Sie können Inhalte
aus unterstützten Streaming-Diensten, Webquellen und lokale Dateien in einer
übersichtlichen Oberfläche verwalten, taggen, filtern, auf eine Merkliste setzen
und in manuellen oder intelligenten Wiedergabelisten organisieren. Import und
Export verwenden ein standardisiertes JSON-Format für Datensicherungen und
Gerätewechsel.

Ihre Bibliothek bleibt vollständig auf Ihrem Gerät. MediaBrain enthält keine
Telemetrie, kein Tracking und keine unaufgeforderte Cloud-Synchronisation.
Netzwerkzugriffe finden ausschließlich statt, wenn Sie optionale Metadatenquellen
(z. B. TMDb, OMDb, MusicBrainz) aktivieren oder eine explizite Datenübertragung
auslösen.

**Hauptfunktionen**

- Universelle Medienverwaltung: Videos, Filme, Serien, Musik, Podcasts, Hörbücher und Dokumente
- Acht spezialisierte Provider mit modularer Ein- und Ausschaltung
- Automatische Erkennung und Datei-Indexierung
- Dynamischer QueryBuilder und intelligente Smart-Playlists
- Detaillierter Metadaten-Editor mit technischer Datei-Inspektion
- 100 % datenschutzfreundlich und offline-fähig

**Suchbegriffe**

Medienbibliothek, Streaming-Verlauf, Wiedergabelisten, Medienverwaltung,
Video, Musik, Dokumente, lokal, offline, Smart-Playlists

## English

**Short description**

MediaBrain organizes personal video, music, documents, and streaming history
locally and privately on your Windows PC.

**Description**

MediaBrain is a local-first, offline-ready media library manager. Organize
supported streaming services, web sources, and local files in one clean interface,
assign tags, filter entries, manage favorites, and build manual or intelligent
smart playlists. Import and export utilize a standardized JSON format for reliable
backups and device migration.

Your media collection stays strictly on your device. MediaBrain has no telemetry,
no tracking, and no unsolicited cloud syncing. Network connections only occur
when you explicitly enable optional metadata providers (e.g. TMDb, OMDb, MusicBrainz)
or perform a manual data transfer.

**Key Features**

- Universal Media Management: Videos, Movies, TV Shows, Music, Podcasts, Audiobooks, and Documents
- Eight specialized media providers with customizable visibility
- Automated file change monitoring and media indexing
- Dynamic QueryBuilder with criteria-driven Smart-Playlists
- Rich metadata inspector with deep technical audio/video properties
- 100% private, local-first architecture

**Keywords**

media library, streaming history, playlists, media manager, video, music,
documents, local, offline, smart playlists

## Submission prerequisites status

- [x] Repository packaging metadata (`store_package.json`, version `2.1.0.0`, capabilities)
- [x] Canonical Windows Desktop AppxManifest (`store_package/MediaBrain/AppxManifest.xml`)
- [x] Microsoft Store tile and icon assets (`44x44`, `50x50`, `150x150`, `310x150`, `310x310`)
- [x] Synthetic store screenshots staged (`screenshots/store/` and `README/screenshots/store/`)
- [x] Bilingual Store Listing and Support documentation
- [ ] Confirm Partner Center identity reservation (`CN=...`, `Geiger.MediaBrain`)
- [ ] Build and sign final production MSIX in packaging pipeline
- [ ] Run Windows App Certification Kit (WACK) validation and store pass report
