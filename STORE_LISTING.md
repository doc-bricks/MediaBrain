# MediaBrain – Microsoft Store Listing Draft

> Status: vorbereiteter Entwurf. Keine Store-Einreichung und kein Nachweis für
> eine Partner-Center-Reservierung, ein signiertes MSIX oder einen WACK-Lauf.

## Deutsch

**Kurzbeschreibung**

MediaBrain organisiert persönliche Videos, Musik, Dokumente und den
Streaming-Verlauf lokal auf Ihrem Windows-PC.

**Beschreibung**

MediaBrain ist eine lokale, offline-first Medienbibliothek. Sie können Inhalte
aus unterstützten Diensten und lokale Dateien in einer Übersicht verwalten,
taggen, filtern, auf eine Merkliste setzen und in manuellen oder intelligenten
Wiedergabelisten organisieren. Import und Export verwenden ein dokumentiertes
JSON-Format für Sicherungen und Gerätewechsel.

Ihre Bibliothek bleibt auf Ihrem Gerät. MediaBrain enthält keine Telemetrie,
kein Tracking und keine automatische Cloud-Synchronisation. Netzwerkzugriffe
finden nur statt, wenn Sie optionale Metadatenquellen verwenden oder eine
ausdrückliche mobile Push-/Pull-Aktion auslösen.

**Suchbegriffe**

Medienbibliothek, Streaming-Verlauf, Wiedergabelisten, Medienverwaltung,
Video, Musik, Dokumente, lokal, offline

## English

**Short description**

MediaBrain organizes personal video, music, documents, and streaming history
locally on your Windows PC.

**Description**

MediaBrain is a local, offline-first media library. Manage supported services
and local files in one place, add tags, filter entries, keep favorites, and
create manual or smart playlists. Import and export use a documented JSON
format for backups and device changes.

Your library stays on your device. MediaBrain has no telemetry, no tracking,
and no automatic cloud synchronization. Network access occurs only when you
use optional metadata sources or explicitly start a mobile Push or Pull action.

**Keywords**

media library, streaming history, playlists, media manager, video, music,
documents, local, offline

## Submission prerequisites still open

- Confirm the Partner Center identity after the product reservation exists.
- Dedicated Store screenshots with synthetic media data are kept in
  `screenshots/store/` and regenerated with
  `python scripts/generate_store_screenshots.py`.
- Build and sign a fresh MSIX from the current `MediaBrain.exe`.
- Run WACK against that MSIX and retain the generated report.
