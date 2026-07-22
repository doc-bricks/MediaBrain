// Tests für die SmartPlaylist-Regel-Engine.
//
// Prüft Parsen, Operatoren, Feld-Aliase, AND/OR-Präzedenz,
// Bool-Koercion, Tags, Sortierung und Limit.

import { describe, expect, it } from 'vitest'
import type { MediaItem } from '../types/media'
import {
  evaluateSmartPlaylist,
  parseSmartQuery,
  type SmartCondition,
  type SmartQuery,
} from './smartPlaylist'

// ─── Test-Fixture ────────────────────────────────────────────────

function makeItem(overrides: Partial<MediaItem> & { id: number }): MediaItem {
  const { id, ...rest } = overrides

  return {
    ...rest,
    id,
    title: rest.title ?? `Item ${id}`,
    type: rest.type ?? 'movie',
    source: rest.source ?? 'local',
    provider_id: rest.provider_id ?? String(id),
    is_favorite: rest.is_favorite ?? false,
    is_local_file: rest.is_local_file ?? false,
    tags: rest.tags ?? [],
    length_seconds: rest.length_seconds ?? null,
    blacklist_flag: rest.blacklist_flag ?? 0,
    last_opened_at: rest.last_opened_at ?? null,
    description: rest.description ?? null,
  }
}

const ITEMS: MediaItem[] = [
  makeItem({ id: 1, title: 'Inception', type: 'movie', is_favorite: true, length_seconds: 8880, tags: ['Sci-Fi', 'Thriller'], last_opened_at: '2026-01-10' }),
  makeItem({ id: 2, title: 'Breaking Bad', type: 'series', is_favorite: false, length_seconds: 2700, tags: ['Drama', 'Crime'], last_opened_at: '2026-01-05' }),
  makeItem({ id: 3, title: 'Interstellar', type: 'movie', is_favorite: true, length_seconds: 10140, tags: ['Sci-Fi'], last_opened_at: '2026-01-15' }),
  makeItem({ id: 4, title: 'Beethoven Sinfonie', type: 'music', is_favorite: false, length_seconds: 4200, tags: ['Klassik'], last_opened_at: null }),
  makeItem({ id: 5, title: 'Podcast Episode 42', type: 'podcast', is_favorite: false, length_seconds: 3600, tags: [], last_opened_at: '2026-01-01' }),
  makeItem({ id: 6, title: 'Dunno', type: 'movie', is_favorite: false, blacklist_flag: 1, tags: ['Action'], last_opened_at: '2026-01-20' }),
]

// ─── parseSmartQuery ─────────────────────────────────────────────

describe('parseSmartQuery', () => {
  it('parst ein Objekt direkt', () => {
    const q: SmartQuery = { conditions: [{ field: 'type', operator: '=', value: 'movie' }] }
    expect(parseSmartQuery(q)).toEqual(q)
  })

  it('parst einen JSON-String (Desktop-Exportformat)', () => {
    const q: SmartQuery = { conditions: [{ field: 'type', operator: '=', value: 'movie' }] }
    expect(parseSmartQuery(JSON.stringify(q))).toEqual(q)
  })

  it('gibt null für ungültigen String zurück', () => {
    expect(parseSmartQuery('kein json {{')).toBeNull()
  })

  it('gibt null für null zurück', () => {
    expect(parseSmartQuery(null)).toBeNull()
  })

  it('gibt null zurück, wenn conditions-Feld fehlt', () => {
    expect(parseSmartQuery({ order_by: 'title' })).toBeNull()
  })

  it('gibt null für leeren String zurück', () => {
    expect(parseSmartQuery('')).toBeNull()
  })
})

// ─── Einfache Operatoren ─────────────────────────────────────────

describe('evaluateSmartPlaylist — Basis-Operatoren', () => {
  it('filtert nach type = movie', () => {
    const q = query([cond('type', '=', 'movie')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3, 6]))
    expect(result).toHaveLength(3)
  })

  it('filtert nach type != movie', () => {
    const q = query([cond('type', '!=', 'movie')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.every((i) => i.type !== 'movie')).toBe(true)
    expect(result).toHaveLength(3)
  })

  it('filtert nach length_seconds > 5000', () => {
    const q = query([cond('length_seconds', '>', 5000)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
    expect(result).toHaveLength(2)
  })

  it('filtert nach length_seconds >= 8880', () => {
    const q = query([cond('length_seconds', '>=', 8880)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
  })

  it('filtert nach length_seconds < 3000', () => {
    const q = query([cond('length_seconds', '<', 3000)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([2]))
  })

  it('filtert nach length_seconds <= 3600', () => {
    const q = query([cond('length_seconds', '<=', 3600)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([2, 5]))
  })
})

// ─── String-Operatoren (case-insensitive) ────────────────────────

describe('evaluateSmartPlaylist — String-Operatoren', () => {
  it('contains matcht case-insensitive', () => {
    const q = query([cond('title', 'contains', 'inter')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(3) // Interstellar
  })

  it('starts_with matcht case-insensitive', () => {
    const q = query([cond('title', 'starts_with', 'inc')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(1) // Inception
  })

  it('not_contains schließt Items aus', () => {
    const q = query([cond('title', 'not_contains', 'inter')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).not.toContain(3) // Interstellar ausgeschlossen
  })

  it('is_empty matcht null/leer', () => {
    const q = query([cond('last_opened_at', 'is_empty')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(4) // Beethoven: null
  })

  it('is_not_empty schließt null aus', () => {
    const q = query([cond('last_opened_at', 'is_not_empty')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).not.toContain(4) // Beethoven: null → ausgeschlossen
  })
})

// ─── Tags (Array-Membership) ─────────────────────────────────────

describe('evaluateSmartPlaylist — Tags', () => {
  it('tags contains matcht case-insensitive', () => {
    const q = query([cond('tags', 'contains', 'sci-fi')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
  })

  it('tags = matcht exakt (case-insensitive)', () => {
    const q = query([cond('tags', '=', 'drama')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(2) // Drama-Tag
    expect(result.map((i) => i.id)).not.toContain(1)
  })

  it('tags not_contains schließt Items aus', () => {
    const q = query([cond('tags', 'not_contains', 'sci-fi')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).not.toContain(1)
    expect(result.map((i) => i.id)).not.toContain(3)
  })

  it('tags is_empty matcht Items ohne Tags', () => {
    const q = query([cond('tags', 'is_empty')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(5) // Podcast: keine Tags
  })

  it('tags is_not_empty matcht Items mit Tags', () => {
    const q = query([cond('tags', 'is_not_empty')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).not.toContain(5)
  })
})

// ─── Feld-Aliase ─────────────────────────────────────────────────

describe('evaluateSmartPlaylist — Feld-Aliase', () => {
  it('favorite → is_favorite', () => {
    const q = query([cond('favorite', '=', true)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
    expect(result).toHaveLength(2)
  })

  it('blacklisted → blacklist_flag', () => {
    const q = query([cond('blacklisted', '=', 1)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toContain(6)
    expect(result).toHaveLength(1)
  })

  it('duration_seconds → length_seconds', () => {
    const q = query([cond('duration_seconds', '>', 5000)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
  })
})

// ─── Bool-Koercion (is_favorite) ─────────────────────────────────

describe('evaluateSmartPlaylist — Bool-Koercion', () => {
  it('is_favorite = true (JS-boolean)', () => {
    const q = query([cond('is_favorite', '=', true)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(2)
  })

  it('is_favorite = 1 (Zahl, wie Python-Regeln)', () => {
    const q = query([cond('is_favorite', '=', 1)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(2)
  })

  it('is_favorite = false', () => {
    const q = query([cond('is_favorite', '=', false)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(4)
  })

  it('is_favorite = 0', () => {
    const q = query([cond('is_favorite', '=', 0)])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(4)
  })
})

// ─── AND/OR-Präzedenz (Sum-of-Products) ──────────────────────────
//
// KRITISCH: AND bindet stärker als OR (wie SQL).
// "A AND B OR C" = "(A AND B) OR C", NICHT "A AND (B OR C)".

describe('evaluateSmartPlaylist — AND/OR-Präzedenz', () => {
  it('AND/AND: beide Bedingungen müssen zutreffen', () => {
    // type = movie AND is_favorite = true → nur Inception (1) + Interstellar (3)
    const q = query([
      cond('type', '=', 'movie'),
      { ...cond('is_favorite', '=', true), conjunction: 'AND' },
    ])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
    expect(result).toHaveLength(2)
  })

  it('OR öffnet neue Gruppe: type = movie AND is_favorite = true OR type = music', () => {
    // Erwartet: (movie AND favorite) OR music
    // → Inception (1, movie+fav), Interstellar (3, movie+fav), Beethoven (4, music)
    const q = query([
      cond('type', '=', 'movie'),
      { ...cond('is_favorite', '=', true), conjunction: 'AND' },
      { ...cond('type', '=', 'music'), conjunction: 'OR' },
    ])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3, 4]))
    expect(result).toHaveLength(3)
    // Dunno (6, movie+nicht-fav) darf NICHT enthalten sein
    expect(result.map((i) => i.id)).not.toContain(6)
  })

  it('gemischtes AND/OR/AND: A AND B OR C AND D', () => {
    // type = movie AND is_favorite = true OR type = podcast AND is_favorite = false
    // = (movie AND fav) OR (podcast AND nicht-fav)
    // → Inception(1), Interstellar(3), Podcast(5)
    const q = query([
      cond('type', '=', 'movie'),
      { ...cond('is_favorite', '=', true), conjunction: 'AND' },
      { ...cond('type', '=', 'podcast'), conjunction: 'OR' },
      { ...cond('is_favorite', '=', false), conjunction: 'AND' },
    ])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3, 5]))
    expect(result).toHaveLength(3)
  })
})

// ─── Sortierung und Limit ─────────────────────────────────────────

describe('evaluateSmartPlaylist — Sortierung', () => {
  it('order_by title ASC', () => {
    const q: SmartQuery = {
      conditions: [cond('type', '=', 'movie')],
      order_by: 'title',
      order_dir: 'ASC',
    }
    const result = evaluateSmartPlaylist(ITEMS, q)
    const titles = result.map((i) => i.title)
    expect(titles).toEqual([...titles].sort((a, b) => a.localeCompare(b, 'de')))
  })

  it('order_by title DESC', () => {
    const q: SmartQuery = {
      conditions: [cond('type', '=', 'movie')],
      order_by: 'title',
      order_dir: 'DESC',
    }
    const result = evaluateSmartPlaylist(ITEMS, q)
    const titles = result.map((i) => i.title)
    expect(titles).toEqual([...titles].sort((a, b) => b.localeCompare(a, 'de')))
  })

  it('order_by length_seconds ASC (nur Items mit definierter Länge)', () => {
    // is_not_empty schließt null aus, so dass nur Zahlen verglichen werden
    const q: SmartQuery = {
      conditions: [cond('length_seconds', 'is_not_empty')],
      order_by: 'length_seconds',
      order_dir: 'ASC',
    }
    const result = evaluateSmartPlaylist(ITEMS, q)
    const lengths = result.map((i) => i.length_seconds!)
    expect(lengths).toEqual([...lengths].sort((a, b) => a - b))
  })

  it('limit kürzt das Ergebnis', () => {
    const q: SmartQuery = {
      conditions: [],
      order_by: 'id',
      order_dir: 'ASC',
      limit: 3,
    }
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(3)
  })

  it('leere conditions gibt alle Items zurück', () => {
    const q: SmartQuery = { conditions: [] }
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(ITEMS.length)
  })
})

// ─── Edge Cases ───────────────────────────────────────────────────

describe('evaluateSmartPlaylist — Edge Cases', () => {
  it('gibt leeres Array zurück, wenn keine Items matchen', () => {
    const q = query([cond('type', '=', 'audiobook')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(0)
  })

  it('Alias last_watched → last_opened_at', () => {
    const q = query([cond('last_watched', 'is_not_empty')])
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result.map((i) => i.id)).not.toContain(4) // Beethoven: null
  })

  it('limit = 0 wird ignoriert (kein Kürzen)', () => {
    const q: SmartQuery = { conditions: [], limit: 0 }
    const result = evaluateSmartPlaylist(ITEMS, q)
    expect(result).toHaveLength(ITEMS.length)
  })

  it('parseSmartQuery + evaluateSmartPlaylist mit JSON-String aus dem Desktop', () => {
    const json = JSON.stringify({
      conditions: [
        { field: 'type', operator: '=', value: 'movie', conjunction: 'AND' },
        { field: 'favorite', operator: '=', value: true, conjunction: 'AND' },
      ],
      order_by: 'title',
      order_dir: 'ASC',
    })
    const q = parseSmartQuery(json)
    expect(q).not.toBeNull()
    const result = evaluateSmartPlaylist(ITEMS, q!)
    expect(result.map((i) => i.id)).toEqual(expect.arrayContaining([1, 3]))
    expect(result).toHaveLength(2)
  })
})

// ─── Hilfsfunktionen für lesbare Tests ────────────────────────────

function cond(
  field: string,
  operator: SmartCondition['operator'],
  value?: unknown,
): SmartCondition {
  return { field, operator, value }
}

function query(conditions: SmartCondition[]): SmartQuery {
  return { conditions }
}
