# Changelog / Aenderungsprotokoll

Alle wesentlichen Aenderungen an diesem Projekt werden hier dokumentiert.
Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.1.0/).

## [Unreleased]

### Hinzugefuegt / Added
- Regressionstests für Smart-Playlists mit QueryBuilder-JSON, Tag-Filtern, dynamischen Counts und defekten Query-JSONs.
- Regressionstests für den QueryBuilder mit Schema-Aliasen, Tag-Filtern und SQL-Sanitizing.

### Geaendert / Changed
- PlaylistManager wertet Smart-Playlists jetzt dynamisch über QueryBuilder aus; manuelle Playlists bleiben unverändert.
- QueryBuilder nutzt jetzt das echte media_items-Schema und kompatible Aliase für UI/JSON-Felder.

### Behoben / Fixed
- Defekte Smart-Playlist-Queries liefern keine Treffer statt versehentlich die gesamte Bibliothek.
- QueryBuilder übernimmt ungeprüfte conjunction/order_dir-Werte nicht mehr in erzeugtes SQL.

## [1.0.0] - YYYY-MM-DD

### Hinzugefuegt / Added
- Erstveroeffentlichung / Initial release
