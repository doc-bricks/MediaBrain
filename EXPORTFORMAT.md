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
    "app_version": "2.0.0",
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
| `app_version` | String | ja | Informative Desktop-Version aus `version.py`; ein Packaging-Build darf sie über `MEDIABRAIN_VERSION` überschreiben. |
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
- `local_path` (aus Datenschutzgründen standardmäßig nicht exportiert; nur bei ausdrücklichem Opt-in)
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

## Datenschutzstandard für lokale Pfade

JSON- und CSV-Exporte lassen `local_path` standardmäßig aus. So gelangen private
absolute Dateipfade nicht versehentlich in Share-Sheets, PWA-Importe oder andere
Geräte. Nur ein ausdrücklich aufgerufener Export mit `include_local_paths=True`
nimmt das Feld auf; das Capability-Feld `local_paths` dokumentiert diesen Zustand.

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

---

## Companion-Rücksync: `mediabrain-companion-favorites-v1`

Stand: 2026-06-22

Dieses Format transportiert Favoriten-Änderungen vom Web/PWA-Companion zurück zum Desktop. Es ist ein eigenständiges Schema, kein Unterobjekt von `mediabrain-library-v1`.

### Dateiname

Empfohlen: `mediabrain-companion-favorites-v1.json`

### Top-Level-Schema

```json
{
  "schema": "mediabrain-companion-favorites-v1",
  "schema_version": 1,
  "created_at": "2026-06-22T10:00:00+02:00",
  "source": {
    "app_name": "MediaBrain Companion",
    "platform": "web"
  },
  "base_import_fingerprint": "2026-05-26T21:30:00+02:00|123",
  "changes": []
}
```

### Felder

| Feld | Typ | Pflicht | Bedeutung |
|---|---|---|---|
| `schema` | String | ja | `mediabrain-companion-favorites-v1` |
| `schema_version` | Integer | ja | Aktuell `1` |
| `created_at` | String | ja | ISO-8601-Zeitstempel der Export-Erstellung |
| `source` | Objekt | ja | Herkunft: `app_name`, `platform` |
| `base_import_fingerprint` | String\|null | nein | `exported_at\|item_count` des letzten Imports. Erlaubt dem Desktop, veraltete Änderungen zu erkennen |
| `changes` | Array | ja | Favoriten-Änderungen (siehe unten) |

### Änderungseinträge in `changes`

Jeder Eintrag repräsentiert den **absoluten Zielzustand** eines Favoriten-Flags:

| Feld | Typ | Bedeutung |
|---|---|---|
| `id` | Integer | Companion-interne Item-ID (Fallback-Match bei leerem `provider_id`) |
| `source` | String | Quelle des Mediums (z.B. `youtube`, `spotify`) |
| `provider_id` | String | Stabile Referenz innerhalb der Quelle |
| `title` | String | Anzeigename (informativ, nicht für Matching) |
| `is_favorite` | Boolean | Zielzustand: `true` = Favorit, `false` = kein Favorit |
| `changed_at` | String | ISO-8601-Zeitstempel der Änderung |

### Desktop-Apply-Vertrag

1. **Match-Key:** `source + provider_id` (identisch mit Regel 5 aus `mediabrain-library-v1`). **Fallback bei leerem `provider_id`:** Wenn `provider_id` leer ist (typisch für lokale Dateien, `source = "local"`), kann der Desktop alternativ über `id` + `title` matchen. Die `id` ist innerhalb eines Import-Standes eindeutig. Dieser Fallback gilt nur, wenn der Favoriten-Export auf dieselbe Desktop-DB angewandt wird, die den Library-Export erzeugte — `id` ist nicht installationsübergreifend stabil.
2. **Idempotentes Setzen:** `is_favorite` wird als absoluter Zielzustand auf den gematchten Datensatz angewandt. Mehrfaches Importieren derselben Datei ist sicher.
3. **Unbekannte Referenzen:** Kann weder `source + provider_id` noch der Fallback-Key auf einen Desktop-Datensatz gemappt werden, wird die Änderung übersprungen (kein Fehler).
4. **Last-Write-Wins:** Pro Item (`id`) existiert im Export maximal ein Eintrag (der jüngste). Bei Doppel-Toggle (fav→unfav→fav) bleibt nur der letzte Zustand.
5. **Baseline-Reset:** Ein neuer Bibliothek-Import (`mediabrain-library-v1`) im Companion löscht alle ausstehenden Changes. Der `base_import_fingerprint` erlaubt dem Desktop zu prüfen, ob die Änderungen auf einem aktuellen Stand basieren.
