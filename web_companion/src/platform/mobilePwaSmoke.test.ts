import 'fake-indexeddb/auto'

import { afterEach, describe, expect, it } from 'vitest'

import { MediaBrainDB } from '../services/db'
import { LibraryExport, parseLibrary } from '../types/media'
import { detectPwaInstallPlatform, getPwaInstallHint } from './pwa'

const ANDROID_CHROME =
  'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 Chrome/124.0 Mobile Safari/537.36'
const IOS_SAFARI =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1'

let dbCounter = 0
const openDbs: MediaBrainDB[] = []

function createIsolatedDb(): MediaBrainDB {
  dbCounter += 1
  const db = new MediaBrainDB(`mediabrain-mobile-pwa-smoke-${Date.now()}-${dbCounter}`)
  openDbs.push(db)
  return db
}

afterEach(async () => {
  while (openDbs.length > 0) {
    const db = openDbs.pop()
    await db?.delete()
  }
})

function buildLargeExport(size = 180): LibraryExport {
  const types = ['movie', 'series', 'music', 'clip', 'podcast', 'audiobook', 'document']
  const sources = ['netflix', 'youtube', 'spotify', 'local', 'appletv']
  const items = Array.from({ length: size }, (_, index) => {
    const id = index + 1
    const source = sources[index % sources.length]
    const type = types[index % types.length]
    return {
      id,
      title: `Mobile Smoke Item ${String(id).padStart(3, '0')}`,
      type,
      source,
      provider_id: source === 'local' ? '' : `${source}-${id}`,
      length_seconds: 120 + id,
      last_opened_at: `2026-07-${String((index % 28) + 1).padStart(2, '0')}T12:00:00Z`,
      is_favorite: id % 9 === 0,
      is_local_file: source === 'local',
      local_path: source === 'local' ? `media/smoke/item-${id}.mp4` : null,
      description: `Large mobile PWA smoke fixture ${id}`,
      tags: [`tag-${id % 6}`, type],
    }
  })

  return {
    schema: 'mediabrain-library-v1',
    schema_version: 1,
    version: '1.0',
    app_name: 'MediaBrain Desktop',
    app_version: 'dev',
    source: {
      app_name: 'MediaBrain Desktop',
      app_version: 'dev',
      platform: 'windows',
    },
    capabilities: {
      tags: true,
      playlists: true,
      stable_media_refs: true,
      legacy_alias_import: true,
    },
    exported_at: '2026-07-06T12:00:00+02:00',
    item_count: items.length,
    items,
    playlists: [
      {
        id: 1,
        name: 'Mobile Watchlist',
        playlist_type: 'manual',
        item_ids: [1, 2, 3, 4],
        item_refs: items.slice(0, 4).map((item) => ({
          source: item.source,
          provider_id: item.provider_id,
          title: item.title,
          type: item.type,
        })),
      },
      {
        id: 2,
        name: 'Offline Favorites',
        playlist_type: 'smart',
        smart_query: JSON.stringify({
          conditions: [{ field: 'is_favorite', operator: '=', value: true }],
          conjunction: 'AND',
          limit: 25,
        }),
        item_ids: [],
        item_refs: [],
      },
    ],
  }
}

describe('mobile PWA smoke contract', () => {
  it('keeps Android and iOS install guidance active until standalone mode', () => {
    expect(detectPwaInstallPlatform(ANDROID_CHROME)).toBe('android')
    expect(detectPwaInstallPlatform(IOS_SAFARI)).toBe('ios')

    expect(getPwaInstallHint('android', false)).toContain('App installieren')
    expect(getPwaInstallHint('ios', false)).toContain('Zum Home-Bildschirm')
    expect(getPwaInstallHint('android', true)).toBeNull()
    expect(getPwaInstallHint('ios', true)).toBeNull()
  })

  it('imports a large real-schema desktop export into isolated IndexedDB storage', async () => {
    const payload = parseLibrary(buildLargeExport())
    const db = createIsolatedDb()

    const result = await db.replaceWithExport(payload)

    expect(result).toEqual({ items: 180, playlists: 2 })
    expect(await db.items.count()).toBe(180)
    expect(await db.playlists.count()).toBe(2)
    expect(await db.listAllTags()).toContain('music')
    expect(await db.listItems({ query: 'Item 042' })).toHaveLength(1)
    expect(await db.listItems({ type: 'music', limit: 5 })).toHaveLength(5)

    const meta = JSON.parse((await db.getMeta('last_import')) ?? '{}')
    expect(meta.schema).toBe('mediabrain-library-v1')
    expect(meta.source_platform).toBe('windows')
    expect(meta.item_count).toBe(180)
  })

  it('exports mobile favorite changes against the last imported desktop baseline', async () => {
    const payload = parseLibrary(buildLargeExport(40))
    const db = createIsolatedDb()
    await db.replaceWithExport(payload)

    await db.toggleFavorite(1)
    await db.toggleFavorite(4)

    const favoriteExport = await db.buildFavoriteChangesPayload()

    expect(favoriteExport.schema).toBe('mediabrain-companion-favorites-v1')
    expect(favoriteExport.schema_version).toBe(1)
    expect(favoriteExport.base_import_fingerprint).toBe('2026-07-06T12:00:00+02:00|40')
    expect(favoriteExport.changes).toHaveLength(2)
    expect(favoriteExport.changes.map((change) => change.id).sort((a, b) => a - b)).toEqual([
      1,
      4,
    ])
    expect(favoriteExport.changes.find((change) => change.id === 4)?.provider_id).toBe('')
  })
})
