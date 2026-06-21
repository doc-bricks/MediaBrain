// MediaBrain Companion — Datenmodell.
//
// Spiegelt die SQLite-Tabellen aus MediaBrain Desktop:
// - media_items
// - tags + media_tags
// - playlists + playlist_items

export type MediaType =
  | 'movie'
  | 'series'
  | 'music'
  | 'clip'
  | 'podcast'
  | 'audiobook'
  | 'document'
  | string // tolerant für ungewöhnliche Werte

export interface MediaItem {
  id: number
  title: string
  type: MediaType
  source: string
  provider_id: string
  provider_subtype?: string | null
  length_seconds?: number | null
  created_at?: string | null
  last_opened_at?: string | null
  open_method?: string | null
  is_favorite: boolean
  is_local_file: boolean
  local_path?: string | null
  description?: string | null
  thumbnail_url?: string | null
  season?: number | null
  episode?: number | null
  artist?: string | null
  album?: string | null
  channel?: string | null
  blacklist_flag?: number | null
  blacklisted_at?: string | null
  procedure_code?: number | null
  tags?: string[]
}

export interface Playlist {
  id: number
  name: string
  description?: string | null
  type?: string | null
  /** Manuelle Playlist: Items als Array von MediaItem-IDs. Smart-Playlist: leer. */
  item_ids?: number[]
  items?: Array<{
    media_id?: number
    source?: string
    provider_id?: string
    title?: string
    type?: string
  }>
  // Smart-Playlist Felder können in den Export einfließen, werden aber
  // im Companion nicht ausgewertet (P2):
  rules?: unknown
}

// ─── Import / Schema ─────────────────────────────────────────────

/**
 * Das von MediaBrain Desktop geschriebene JSON-Format (siehe
 * `export_import.py:MediaExporter.export_json`). Wir lesen es tolerant —
 * Felder fehlen werden mit Defaults gefüllt.
 */
export interface LibraryExport {
  version?: string
  schema?: string
  schema_version?: number
  app_name?: string
  app_version?: string
  exported_at?: string
  source?: Record<string, unknown>
  capabilities?: Record<string, unknown>
  item_count?: number
  items: Array<Record<string, unknown>>
  playlists?: Array<Record<string, unknown>>
}

export class ImportError extends Error {}

export function parseLibrary(raw: unknown): LibraryExport {
  if (typeof raw !== 'object' || raw === null) {
    throw new ImportError('Datei ist kein JSON-Objekt.')
  }
  const obj = raw as Record<string, unknown>
  const schema = typeof obj.schema === 'string' ? obj.schema : undefined
  if (schema && schema !== 'mediabrain-library-v1') {
    throw new ImportError(
      `Unbekanntes Schema "${schema}". Erwartet wird "mediabrain-library-v1".`,
    )
  }
  const schemaVersion =
    typeof obj.schema_version === 'number' ? obj.schema_version : undefined
  if (schemaVersion !== undefined && schemaVersion !== 1) {
    throw new ImportError(
      `Nicht unterstützte schema_version ${schemaVersion}. Erwartet wird 1.`,
    )
  }
  const items = obj.items
  if (!Array.isArray(items)) {
    throw new ImportError('Feld "items" fehlt oder ist kein Array.')
  }
  return {
    version: typeof obj.version === 'string' ? obj.version : undefined,
    schema,
    schema_version: schemaVersion,
    app_name: typeof obj.app_name === 'string' ? obj.app_name : undefined,
    app_version: typeof obj.app_version === 'string' ? obj.app_version : undefined,
    exported_at: typeof obj.exported_at === 'string' ? obj.exported_at : undefined,
    source:
      typeof obj.source === 'object' && obj.source !== null
        ? (obj.source as Record<string, unknown>)
        : undefined,
    capabilities:
      typeof obj.capabilities === 'object' && obj.capabilities !== null
        ? (obj.capabilities as Record<string, unknown>)
        : undefined,
    item_count:
      typeof obj.item_count === 'number' ? obj.item_count : items.length,
    items: items as Array<Record<string, unknown>>,
    playlists: Array.isArray(obj.playlists)
      ? (obj.playlists as Array<Record<string, unknown>>)
      : undefined,
  }
}

export function coerceItem(raw: Record<string, unknown>): MediaItem {
  return {
    id: Number(raw.id ?? 0),
    title: String(raw.title ?? '(ohne Titel)'),
    type: (raw.type as string) ?? 'document',
    source: (raw.source as string) ?? '',
    provider_id: (raw.provider_id as string) ?? '',
    provider_subtype: (raw.provider_subtype as string | null) ?? null,
    length_seconds:
      typeof raw.length_seconds === 'number' ? raw.length_seconds : null,
    created_at: (raw.created_at as string | null) ?? null,
    last_opened_at: (raw.last_opened_at as string | null) ?? null,
    open_method: (raw.open_method as string | null) ?? null,
    is_favorite: Boolean(raw.is_favorite),
    is_local_file: Boolean(raw.is_local_file),
    local_path: (raw.local_path as string | null) ?? null,
    description: (raw.description as string | null) ?? null,
    thumbnail_url: (raw.thumbnail_url as string | null) ?? null,
    season: typeof raw.season === 'number' ? raw.season : null,
    episode: typeof raw.episode === 'number' ? raw.episode : null,
    artist: (raw.artist as string | null) ?? null,
    album: (raw.album as string | null) ?? null,
    channel: (raw.channel as string | null) ?? null,
    blacklist_flag:
      typeof raw.blacklist_flag === 'number' ? raw.blacklist_flag : 0,
    blacklisted_at: (raw.blacklisted_at as string | null) ?? null,
    procedure_code:
      typeof raw.procedure_code === 'number' ? raw.procedure_code : null,
    tags: Array.isArray(raw.tags) ? (raw.tags as string[]) : [],
  }
}

export function coercePlaylist(raw: Record<string, unknown>): Playlist {
  const itemIds = Array.isArray(raw.item_ids)
    ? raw.item_ids
        .map((value) => Number(value))
        .filter((value) => Number.isFinite(value))
    : []
  const rawEntries = Array.isArray(raw.item_refs)
    ? raw.item_refs
    : Array.isArray(raw.items)
      ? raw.items
      : []
  return {
    id: Number(raw.id ?? 0),
    name: String(raw.name ?? '(ohne Name)'),
    description: (raw.description as string | null) ?? null,
    type:
      (raw.playlist_type as string | null) ??
      (raw.type as string | null) ??
      null,
    item_ids: itemIds,
    items: rawEntries.map((entry, index) => {
      const item = (entry ?? {}) as Record<string, unknown>
      const mediaId =
        itemIds[index] ??
        (typeof item.media_id === 'number' ? item.media_id : undefined)
      return {
        media_id: mediaId,
        source: typeof item.source === 'string' ? item.source : undefined,
        provider_id:
          typeof item.provider_id === 'string' ? item.provider_id : undefined,
        title: typeof item.title === 'string' ? item.title : undefined,
        type: typeof item.type === 'string' ? item.type : undefined,
      }
    }),
    rules: raw.smart_query ?? raw.rules,
  }
}

// ─── Favoriten-Rück-Sync ────────────────────────────────────────

export interface FavoriteChange {
  id: number
  source: string
  provider_id: string
  title: string
  is_favorite: boolean
  changed_at: string
}

export interface FavoriteChangesExport {
  schema: 'mediabrain-companion-favorites-v1'
  schema_version: 1
  created_at: string
  source: {
    app_name: string
    platform: string
  }
  base_import_fingerprint: string | null
  changes: FavoriteChange[]
}

/** Anzeige-Labels pro Medientyp. */
export const MEDIA_TYPE_LABEL: Record<string, string> = {
  movie: 'Film',
  series: 'Serie',
  music: 'Musik',
  clip: 'Clip',
  podcast: 'Podcast',
  audiobook: 'Hörbuch',
  document: 'Dokument',
}

export const MEDIA_TYPE_ICON: Record<string, string> = {
  movie: '🎬',
  series: '📺',
  music: '🎵',
  clip: '🎞️',
  podcast: '🎙️',
  audiobook: '📖',
  document: '📄',
}
