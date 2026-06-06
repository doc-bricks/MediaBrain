import { describe, expect, it } from 'vitest'

import { coercePlaylist, ImportError, parseLibrary } from './media'

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
