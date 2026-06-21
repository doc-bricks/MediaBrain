// IndexedDB-Persistenz für MediaBrain Companion.

import Dexie, { Table } from 'dexie'

import {
  coerceItem,
  coercePlaylist,
  FavoriteChange,
  FavoriteChangesExport,
  LibraryExport,
  MediaItem,
  Playlist,
} from '../types/media'

interface MetaRow {
  key: string
  value: string
  updated_at: string
}

export class MediaBrainDB extends Dexie {
  items!: Table<MediaItem, number>
  playlists!: Table<Playlist, number>
  meta!: Table<MetaRow, string>
  favoriteChanges!: Table<FavoriteChange, number>

  constructor() {
    super('mediabrain-companion')
    this.version(1).stores({
      items: 'id, title, type, source, provider_id, is_favorite, is_local_file, last_opened_at, *tags',
      playlists: 'id, name',
      meta: 'key',
    })
    this.version(2).stores({
      items: 'id, title, type, source, provider_id, is_favorite, is_local_file, last_opened_at, *tags',
      playlists: 'id, name',
      meta: 'key',
      favoriteChanges: 'id',
    })
  }

  async replaceWithExport(payload: LibraryExport): Promise<{ items: number; playlists: number }> {
    const items = payload.items.map(coerceItem)
    const playlists = (payload.playlists ?? []).map(coercePlaylist)

    await this.transaction('rw', [this.items, this.playlists, this.meta, this.favoriteChanges], async () => {
      await this.items.clear()
      await this.playlists.clear()
      await this.favoriteChanges.clear()
      if (items.length > 0) await this.items.bulkPut(items)
      if (playlists.length > 0) await this.playlists.bulkPut(playlists)
      await this.meta.put({
        key: 'last_import',
        value: JSON.stringify({
          schema: payload.schema ?? 'legacy',
          schema_version: payload.schema_version ?? null,
          app_name: payload.app_name ?? '',
          app_version: payload.app_version ?? '',
          source_platform:
            typeof payload.source?.platform === 'string'
              ? payload.source.platform
              : '',
          exported_at: payload.exported_at ?? '',
          imported_at: new Date().toISOString(),
          item_count: items.length,
          playlist_count: playlists.length,
        }),
        updated_at: new Date().toISOString(),
      })
    })

    return { items: items.length, playlists: playlists.length }
  }

  async listItems(opts: {
    query?: string
    type?: string
    favoritesOnly?: boolean
    limit?: number
  } = {}): Promise<MediaItem[]> {
    let rows: MediaItem[]
    if (opts.type) {
      rows = await this.items.where('type').equals(opts.type).toArray()
    } else {
      rows = await this.items.toArray()
    }
    if (opts.favoritesOnly) rows = rows.filter((r) => r.is_favorite)
    if (opts.query) {
      const q = opts.query.toLowerCase()
      rows = rows.filter(
        (r) =>
          r.title.toLowerCase().includes(q) ||
          (r.artist ?? '').toLowerCase().includes(q) ||
          (r.album ?? '').toLowerCase().includes(q) ||
          (r.channel ?? '').toLowerCase().includes(q) ||
          (r.description ?? '').toLowerCase().includes(q),
      )
    }
    rows.sort((a, b) => {
      const al = a.last_opened_at ?? ''
      const bl = b.last_opened_at ?? ''
      const cmp = bl.localeCompare(al)
      if (cmp !== 0) return cmp
      return a.title.localeCompare(b.title, 'de')
    })
    return opts.limit ? rows.slice(0, opts.limit) : rows
  }

  async getItem(id: number): Promise<MediaItem | undefined> {
    return this.items.get(id)
  }

  async toggleFavorite(id: number): Promise<void> {
    const item = await this.items.get(id)
    if (!item) return
    const newState = !item.is_favorite
    await this.transaction('rw', [this.items, this.favoriteChanges], async () => {
      await this.items.update(id, { is_favorite: newState })
      await this.favoriteChanges.put({
        id: item.id,
        source: item.source,
        provider_id: item.provider_id,
        title: item.title,
        is_favorite: newState,
        changed_at: new Date().toISOString(),
      })
    })
  }

  async listPlaylists(): Promise<Playlist[]> {
    return (await this.playlists.toArray()).sort((a, b) =>
      a.name.localeCompare(b.name, 'de'),
    )
  }

  async listAllTypes(): Promise<string[]> {
    const set = new Set<string>()
    await this.items.each((it) => set.add(it.type))
    return Array.from(set).sort()
  }

  async listAllTags(): Promise<string[]> {
    const set = new Set<string>()
    await this.items.each((it) => {
      if (it.tags) for (const t of it.tags) set.add(t)
    })
    return Array.from(set).sort((a, b) => a.localeCompare(b, 'de'))
  }

  async getMeta(key: string): Promise<string | undefined> {
    const row = await this.meta.get(key)
    return row?.value
  }

  async setMeta(key: string, value: string): Promise<void> {
    await this.meta.put({
      key,
      value,
      updated_at: new Date().toISOString(),
    })
  }

  async pendingFavoriteChangesCount(): Promise<number> {
    return this.favoriteChanges.count()
  }

  async buildFavoriteChangesPayload(): Promise<FavoriteChangesExport> {
    const changes = await this.favoriteChanges.toArray()
    const lastImportRaw = await this.getMeta('last_import')
    let fingerprint: string | null = null
    if (lastImportRaw) {
      try {
        const li = JSON.parse(lastImportRaw)
        fingerprint = `${li.exported_at ?? ''}|${li.item_count ?? 0}`
      } catch { /* ignore */ }
    }
    return {
      schema: 'mediabrain-companion-favorites-v1',
      schema_version: 1,
      created_at: new Date().toISOString(),
      source: {
        app_name: 'MediaBrain Companion',
        platform: navigator?.userAgent ? 'web' : 'unknown',
      },
      base_import_fingerprint: fingerprint,
      changes,
    }
  }

  async clearFavoriteChanges(): Promise<void> {
    await this.favoriteChanges.clear()
  }

  async clearAll(): Promise<void> {
    await this.transaction('rw', [this.items, this.playlists, this.meta, this.favoriteChanges], async () => {
      await this.items.clear()
      await this.playlists.clear()
      await this.meta.clear()
      await this.favoriteChanges.clear()
    })
  }
}

export const db = new MediaBrainDB()
