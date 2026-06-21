// DB-Tests für Favoriten-Change-Tracking.
// Voraussetzung: npm install -D fake-indexeddb
//
// Falls fake-indexeddb nicht installiert ist, werden diese Tests übersprungen.
// Installation: npm install -D fake-indexeddb
// Dann: npx vitest run src/services/db.test.ts

import { afterEach, beforeEach, describe, expect, it } from 'vitest'
import type { MediaBrainDB as MediaBrainDBType } from './db'

let MediaBrainDB: typeof MediaBrainDBType | null = null

try {
  // @ts-expect-error -- optional dependency
  await import('fake-indexeddb/auto')
  const mod = await import('./db')
  MediaBrainDB = mod.MediaBrainDB
} catch {
  // fake-indexeddb not installed — tests will be skipped
}

const describeIf = MediaBrainDB ? describe : describe.skip

describeIf('favoriteChanges tracking', () => {
  let testDb: InstanceType<typeof MediaBrainDBType>

  beforeEach(async () => {
    testDb = new MediaBrainDB!()
    await testDb.items.bulkPut([
      {
        id: 1, title: 'Film A', type: 'movie', source: 'netflix', provider_id: 'nf-1',
        is_favorite: false, is_local_file: false, tags: [],
      },
      {
        id: 2, title: 'Song B', type: 'music', source: 'spotify', provider_id: 'sp-2',
        is_favorite: true, is_local_file: false, tags: [],
      },
    ])
  })

  afterEach(async () => {
    await testDb.delete()
  })

  it('toggleFavorite records a change keyed by item id', async () => {
    await testDb.toggleFavorite(1)
    const count = await testDb.pendingFavoriteChangesCount()
    expect(count).toBe(1)

    const changes = await testDb.favoriteChanges.toArray()
    expect(changes[0].id).toBe(1)
    expect(changes[0].source).toBe('netflix')
    expect(changes[0].provider_id).toBe('nf-1')
    expect(changes[0].is_favorite).toBe(true)
    expect(changes[0].title).toBe('Film A')
  })

  it('double toggle produces last-write-wins (upsert on id key)', async () => {
    await testDb.toggleFavorite(1) // false → true
    await testDb.toggleFavorite(1) // true → false
    const count = await testDb.pendingFavoriteChangesCount()
    expect(count).toBe(1)

    const changes = await testDb.favoriteChanges.toArray()
    expect(changes[0].is_favorite).toBe(false)
  })

  it('local items with empty provider_id do not collide', async () => {
    await testDb.items.bulkPut([
      {
        id: 10, title: 'Local A', type: 'document', source: 'local', provider_id: '',
        is_favorite: false, is_local_file: true, tags: [],
      },
      {
        id: 11, title: 'Local B', type: 'document', source: 'local', provider_id: '',
        is_favorite: false, is_local_file: true, tags: [],
      },
    ])
    await testDb.toggleFavorite(10)
    await testDb.toggleFavorite(11)
    const count = await testDb.pendingFavoriteChangesCount()
    expect(count).toBe(2)

    const changes = await testDb.favoriteChanges.toArray()
    const ids = changes.map(c => c.id).sort()
    expect(ids).toEqual([10, 11])
  })

  it('replaceWithExport clears pending changes (baseline reset)', async () => {
    await testDb.toggleFavorite(1)
    expect(await testDb.pendingFavoriteChangesCount()).toBe(1)

    await testDb.replaceWithExport({
      schema: 'mediabrain-library-v1',
      schema_version: 1,
      items: [{ id: 1, title: 'X', type: 'movie', source: 'netflix', provider_id: 'nf-1' }],
    })
    expect(await testDb.pendingFavoriteChangesCount()).toBe(0)
  })

  it('buildFavoriteChangesPayload returns correct schema', async () => {
    await testDb.toggleFavorite(1)
    await testDb.toggleFavorite(2)

    const payload = await testDb.buildFavoriteChangesPayload()
    expect(payload.schema).toBe('mediabrain-companion-favorites-v1')
    expect(payload.schema_version).toBe(1)
    expect(payload.changes).toHaveLength(2)
  })

  it('clearFavoriteChanges empties the table', async () => {
    await testDb.toggleFavorite(1)
    await testDb.clearFavoriteChanges()
    expect(await testDb.pendingFavoriteChangesCount()).toBe(0)
  })

  it('clearAll also clears favoriteChanges', async () => {
    await testDb.toggleFavorite(1)
    await testDb.clearAll()
    expect(await testDb.pendingFavoriteChangesCount()).toBe(0)
  })
})
