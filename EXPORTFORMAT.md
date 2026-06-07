# Exportformat MediaBrain

Stand: 2026-05-26

Dieses Dokument beschreibt das stabile Austauschformat `mediabrain-library-v1.json` für den Datenaustausch zwischen MediaBrain Desktop, Web/PWA-Companion, Android und iOS.

## Ziel

- Die Desktop-App bleibt die autoritative Offline-First-Quelle.
- Companion-Clients dürfen Exporte lesen, ohne direkt auf die SQLite-Datenbank zuzugreifen.
- Das Format bleibt vorwärts planbar und rückwärts tolerant.

## Dateiname

Empfohlener Name: `mediabrain-library-v1.json`

Abweichende Dateinamen sind erlaubt, solange das JSON den Schema-Marker trägt.

## Top-Level-Schema

```json
{
  "schema": "mediabrain-library-v1",
  "schema_version": 1,
  "version": "1.0",
  "app_name": "MediaBrain Desktop",
  "app_version": "dev",
  "source": {
    "app_name": "MediaBrain Desktop",
    "app_version": "dev",
    "platform": "windows"
  },
  "capabilities": {
    "tags": true,
    "playlists": true,
    "stable_media_refs": true,
    "legacy_alias_import": true
  },
  "exported_at": "2026-05-26T21:30:00+02:00",
  "item_count": 123,
  "items": [],
  "playlists": []
}
```

## Bedeutung der Top-Level-Felder

| Feld | Typ | Pflicht | Bedeutung |
|---|---|---|---|
| `schema` | String | ja | Eindeutiger Schema-Marker. Aktuell immer `mediabrain-library-v1`. |
| `schema_version` | Integer | ja | Maschinenlesbare Version des Austauschformats. Aktuell `1`. |
| `version` | String | nein | Legacy-Feld für ältere Verbraucher. Bleibt vorerst `1.0`. |
| `app_name` | String | ja | Exportierende Anwendung. Aktuell `MediaBrain Desktop`. |
| `app_version` | String | ja | Informative Build-/App-Version. Ohne zentrale Release-Quelle aktuell oft `dev`. |
| `source` | Objekt | nein | Zusätzliche Herkunftsdaten wie Plattform oder mobile/Desktop-Quelle. |
| `capabilities` | Objekt | nein | Gibt an, welche optionalen Bereiche im Export enthalten sind. |
| `exported_at` | String | ja | ISO-8601-Zeitstempel mit Zeitzone. |
| `item_count` | Integer | ja | Anzahl der Medien in `items`. |
| `items` | Array | ja | Vollständige Medienbibliothek. |
| `playlists` | Array | nein | Playlists inklusive stabiler Medienreferenzen. |

## Medieneinträge in `items`

Jeder Eintrag in `items` repräsentiert genau einen Datensatz aus `media_items`.

Pflichtfelder:

| Feld | Typ | Bedeutung |
|---|---|---|
| `title` | String | Anzeigename des Mediums |
| `type` | String | Medientyp, z. B. `movie`, `series`, `music`, `clip`, `podcast`, `audiobook`, `document` |
| `source` | String | Quelle/Provider, z. B. `netflix`, `youtube`, `spotify`, `local` |
| `provider_id` | String | Stabile Referenz innerhalb der Quelle |

Übliche optionale Felder:

- `provider_subtype`
- `length_seconds`
- `created_at`
- `last_opened_at`
- `open_method`
- `is_favorite`
- `is_local_file`
- `local_path`
- `description`
- `thumbnail_url`
- `season`
- `episode`
- `artist`
- `album`
- `channel`
- `blacklist_flag`
- `blacklisted_at`
- `procedure_code`
- `tags`

## Tags

Tags werden nicht als eigene Top-Level-Tabelle exportiert. Stattdessen trägt jedes Medium optional ein Feld `tags`:

```json
{
  "title": "Test Film",
  "source": "netflix",
  "provider_id": "nf-123",
  "type": "movie",
  "tags": ["Favorit", "Sci-Fi"]
}
```

Das vermeidet zusätzliche Join-Logik für Companion-Clients.

## Playlists

`playlists` ist optional und wird nur geschrieben, wenn der Export Playlists einschließt.

Jede Playlist kann enthalten:

| Feld | Typ | Bedeutung |
|---|---|---|
| `name` | String | Playlist-Name |
| `description` | String | Beschreibung |
| `playlist_type` | String | `manual` oder `smart` |
| `smart_query` | String | QueryBuilder-JSON für Smart-Playlists |
| `item_ids` | Array<Integer> | Roh-IDs aus der Desktop-Datenbank, nur informativ |
| `item_refs` | Array<Object> | Stabile Medienreferenzen für Re-Importe |

### Stabile Medienreferenzen

`item_refs` ist der entscheidende mobile/companion-taugliche Teil:

```json
{
  "source": "spotify",
  "provider_id": "track-42",
  "title": "Song A",
  "type": "music"
}
```

`item_ids` allein reichen nicht aus, weil Desktop-IDs zwischen Installationen oder Importläufen nicht stabil sind. Verbraucher und Re-Importe müssen daher `item_refs` bevorzugen.

## Kompatibilitätsregeln

1. Verbraucher müssen `schema` prüfen, wenn es vorhanden ist.
2. Verbraucher müssen `schema_version == 1` akzeptieren.
3. Fehlen `schema` und `schema_version`, darf ein Legacy-Export weiter gelesen werden, solange `items` vorhanden ist.
4. Unbekannte zusätzliche Felder müssen ignoriert werden.
5. Für Medien-Deduplikation bleibt `source + provider_id` der primäre stabile Schlüssel.
6. Falls `provider_id` in alten Exporten fehlt, darf der Desktop-Importer wie bisher einen Ersatzschlüssel erzeugen.
7. `app_version` ist informativ und darf nicht für harte Migrationslogik verwendet werden.

## Legacy-Import

Der Desktop-Importer normalisiert weiterhin ältere Feldnamen:

- `provider` → `source`
- `source_url` → `source`
- `status` → `provider_id`
- `duration_minutes` → `length_seconds`
- `is_favourite` → `is_favorite`

Damit bleiben ältere Exporte weiterhin importierbar.
