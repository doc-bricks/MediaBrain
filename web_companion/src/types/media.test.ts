import { describe, expect, it } from 'vitest'

import {
  coercePlaylist,
  FavoriteChange,
  FavoriteChangesExport,
  ImportError,
  parseLibrary,
} from './media'

describe('parseLibrary', () => {
  it('accepts the stable mediabrain-library-v1 schema', () => {
    const payload = parseLibrary({
      schema: 'mediabrain-library-v1',
      schema_version: 1,
      app_name: 'MediaBrain Desktop',
      app_version: '1.2.3',
      source: { platform: 'windows' },
      capabilities: { playlists: true },
      exported_at: '2026-06-04T10:00:00+02:00',
      items: [{ id: 1, title: 'Alpha', type: 'movie', source: 'youtube', provider_id: 'yt-1' }],
      playlists: [],
    })

    expect(payload.schema).toBe('mediabrain-library-v1')
    expect(payload.schema_version).toBe(1)
    expect(payload.app_version).toBe('1.2.3')
    expect(payload.item_count).toBe(1)
  })

  it('rejects unknown schemas', () => {
    expect(() =>
      parseLibrary({
        schema: 'other-schema',
        items: [],
      }),
    ).toThrowError(ImportError)
  })

  it('rejects unsupported schema versions', () => {
    expect(() =>
      parseLibrary({
        schema: 'mediabrain-library-v1',
        schema_version: 2,
        items: [],
      }),
    ).toThrowError('schema_version 2')
  })
})

describe('coercePlaylist', () => {
  it('maps current desktop exports with playlist_type and item_refs', () => {
    const playlist = coercePlaylist({
      id: 7,
      name: 'Abendprogramm',
      playlist_type: 'manual',
      item_ids: [12, 34],
      item_refs: [
        { source: 'youtube', provider_id: 'yt-1', title: 'Clip', type: 'clip' },
        { source: 'spotify', provider_id: 'sp-1', title: 'Song', type: 'music' },
      ],
      smart_query: '{"favorite":true}',
    })

    expect(playlist.type).toBe('manual')
    expect(playlist.item_ids).toEqual([12, 34])
    expect(playlist.items).toEqual([
      {
        media_id: 12,
        source: 'youtube',
        provider_id: 'yt-1',
        title: 'Clip',
        type: 'clip',
      },
      {
        media_id: 34,
        source: 'spotify',
        provider_id: 'sp-1',
        title: 'Song',
        type: 'music',
      },
    ])
    expect(playlist.rules).toBe('{"favorite":true}')
  })
})

describe('FavoriteChangesExport type contract', () => {
  it('matches the mediabrain-companion-favorites-v1 schema shape', () => {
    const payload: FavoriteChangesExport = {
      schema: 'mediabrain-companion-favorites-v1',
      schema_version: 1,
      created_at: '2026-06-22T10:00:00+02:00',
      source: { app_name: 'MediaBrain Companion', platform: 'web' },
      base_import_fingerprint: '2026-05-26T21:30:00+02:00|123',
      changes: [
        {
          id: 1,
          source: 'youtube',
          provider_id: 'yt-42',
          title: 'Test Video',
          is_favorite: true,
          changed_at: '2026-06-22T10:05:00+02:00',
        },
      ],
    }
    expect(payload.schema).toBe('mediabrain-companion-favorites-v1')
    expect(payload.schema_version).toBe(1)
    expect(payload.changes).toHaveLength(1)
    expect(payload.changes[0].source).toBe('youtube')
    expect(payload.changes[0].provider_id).toBe('yt-42')
    expect(payload.changes[0].is_favorite).toBe(true)
  })

  it('allows null base_import_fingerprint for fresh companions', () => {
    const payload: FavoriteChangesExport = {
      schema: 'mediabrain-companion-favorites-v1',
      schema_version: 1,
      created_at: '2026-06-22T10:00:00+02:00',
      source: { app_name: 'MediaBrain Companion', platform: 'web' },
      base_import_fingerprint: null,
      changes: [],
    }
    expect(payload.base_import_fingerprint).toBeNull()
    expect(payload.changes).toHaveLength(0)
  })

  it('carries absolute state (is_favorite), not a toggle flag', () => {
    const change: FavoriteChange = {
      id: 99,
      source: 'spotify',
      provider_id: 'sp-99',
      title: 'Song',
      is_favorite: false,
      changed_at: '2026-06-22T10:10:00+02:00',
    }
    expect(typeof change.is_favorite).toBe('boolean')
    expect(change.is_favorite).toBe(false)
  })
})
