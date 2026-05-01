# Privacy Policy / Datenschutzhinweise

## Kurzfassung

MediaBrain ist offline-first. Die Anwendung speichert Medienverlauf, Favoriten, Blacklist, Tags, Playlists und Einstellungen lokal auf dem Gerät. Es gibt keine Telemetrie, kein Tracking und keine automatische Cloud-Synchronisation.

## Lokal gespeicherte Daten

Je nach Nutzung können lokal gespeichert werden:

- erkannte Medien-Titel, Quellen und technische Metadaten
- Favoriten, Blacklist-Einträge, Tags und Playlists
- lokale Dateipfade, wenn lokale Medien indexiert werden
- optionale TMDb-/OMDb-API-Keys in `settings.json`
- Cache-Datenbanken für Metadaten

Diese Dateien sind durch `.gitignore` vom Repository ausgeschlossen.

## Netzwerkzugriffe

MediaBrain kann optional externe Metadaten abrufen:

- TMDb, wenn ein TMDb-API-Key konfiguriert ist
- OMDb, wenn ein OMDb-API-Key konfiguriert ist
- MusicBrainz ohne API-Key

Diese Abfragen werden nur für Metadatenfunktionen verwendet. MediaBrain sendet keine Telemetrie an den Projektbetreiber.

## GitHub-Hinweise

Bitte veröffentlichen Sie keine echten `settings.json`-Dateien, Datenbanken, Logs, API-Keys, privaten Medienpfade oder Screenshots mit persönlichen Inhalten in Issues oder Pull Requests.

---

## Summary

MediaBrain is offline-first. The app stores media history, favorites, blacklist entries, tags, playlists, and settings locally on the device. It has no telemetry, tracking, or automatic cloud sync.

## Locally Stored Data

Depending on usage, local data may include:

- detected media titles, sources, and technical metadata
- favorites, blacklist entries, tags, and playlists
- local file paths when local media is indexed
- optional TMDb/OMDb API keys in `settings.json`
- metadata cache databases

These files are excluded from the repository through `.gitignore`.

## Network Access

MediaBrain can optionally fetch external metadata:

- TMDb when a TMDb API key is configured
- OMDb when an OMDb API key is configured
- MusicBrainz without an API key

These requests are only used for metadata features. MediaBrain does not send telemetry to the project maintainer.

## GitHub Notes

Do not publish real `settings.json` files, databases, logs, API keys, private media paths, or screenshots with personal content in issues or pull requests.
