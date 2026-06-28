// SmartPlaylist-Regel-Engine für MediaBrain Companion.
//
// Portiert query_builder.py nach TypeScript (in-memory, kein SQL).
// Gleiche AND/OR-Präzedenz wie SQL: AND bindet stärker als OR.
// Implementierung als Sum-of-Products: aufeinanderfolgende AND-Bedingungen
// bilden eine Gruppe, OR startet eine neue Gruppe. Mindestens eine Gruppe
// muss vollständig erfüllt sein.

import type { MediaItem } from '../types/media'

// Feld-Aliase aus query_builder.py FIELD_ALIASES
const FIELD_ALIASES: Record<string, string> = {
  provider: 'source',
  duration_seconds: 'length_seconds',
  last_watched: 'last_opened_at',
  favorite: 'is_favorite',
  blacklisted: 'blacklist_flag',
}

export type SmartOperator =
  | '='
  | '!='
  | '>'
  | '>='
  | '<'
  | '<='
  | 'contains'
  | 'starts_with'
  | 'not_contains'
  | 'is_empty'
  | 'is_not_empty'

export interface SmartCondition {
  field: string
  operator: SmartOperator
  value?: unknown
  /** Konjunktion ZUM VORHERIGEN Element. Fehlt = AND. */
  conjunction?: 'AND' | 'OR' | string
}

export interface SmartQuery {
  conditions: SmartCondition[]
  order_by?: string | null
  order_dir?: 'ASC' | 'DESC' | string
  limit?: number | null
}

/**
 * Parst `raw` zu einem SmartQuery-Objekt.
 *
 * Akzeptiert JSON-String (vom Desktop exportiert), fertiges Objekt oder null.
 * Gibt null zurück, wenn `raw` nicht parsbar oder kein gültiges Query-Objekt ist.
 */
export function parseSmartQuery(raw: unknown): SmartQuery | null {
  try {
    let parsed: unknown = raw
    if (typeof raw === 'string') {
      parsed = JSON.parse(raw)
    }
    if (
      parsed === null ||
      typeof parsed !== 'object' ||
      !Array.isArray((parsed as SmartQuery).conditions)
    ) {
      return null
    }
    return parsed as SmartQuery
  } catch {
    return null
  }
}

// Löst Feld-Alias auf (z. B. "favorite" → "is_favorite")
function resolveField(field: string): string {
  return FIELD_ALIASES[field] ?? field
}

// Liest ein Feld aus einem MediaItem (typsicher über Index-Zugriff)
function getFieldValue(item: MediaItem, field: string): unknown {
  return (item as unknown as Record<string, unknown>)[field]
}

/**
 * Normalisiert Werte für Gleichheitsvergleiche (= / !=).
 *
 * - boolean → number (false → 0, true → 1), damit is_favorite (JS-Boolean)
 *   und blacklist_flag (Zahl) konsistent vergleichbar sind
 * - String-Repräsentationen ("true"/"1") → 1, ("false"/"0") → 0
 * - Alles andere bleibt unverändert
 */
function normalizeForCompare(v: unknown): unknown {
  if (typeof v === 'boolean') return v ? 1 : 0
  if (typeof v === 'number') return v
  if (typeof v === 'string') {
    const lower = v.trim().toLowerCase()
    if (lower === 'true' || lower === '1' || lower === 'yes' || lower === 'ja') return 1
    if (lower === 'false' || lower === '0' || lower === 'no' || lower === 'nein') return 0
  }
  return v
}

// Prüft, ob ein MediaItem eine einzelne Bedingung erfüllt
function matchesCondition(item: MediaItem, cond: SmartCondition): boolean {
  const field = resolveField(cond.field)

  // Tags: Sonderfall — das Feld ist ein Array, kein Skalar
  if (field === 'tags') {
    const tags = item.tags ?? []
    const needle = String(cond.value ?? '').toLowerCase()
    switch (cond.operator) {
      case 'contains':
        return tags.some((t) => t.toLowerCase().includes(needle))
      case 'not_contains':
        return !tags.some((t) => t.toLowerCase().includes(needle))
      case '=':
        return tags.some((t) => t.toLowerCase() === needle)
      case 'is_empty':
        return tags.length === 0
      case 'is_not_empty':
        return tags.length > 0
      default:
        return false
    }
  }

  const raw = getFieldValue(item, field)

  switch (cond.operator) {
    case 'is_empty':
      return raw === null || raw === undefined || raw === ''
    case 'is_not_empty':
      return raw !== null && raw !== undefined && raw !== ''
    case 'contains': {
      const needle = String(cond.value ?? '').toLowerCase()
      return String(raw ?? '').toLowerCase().includes(needle)
    }
    case 'starts_with': {
      const needle = String(cond.value ?? '').toLowerCase()
      return String(raw ?? '').toLowerCase().startsWith(needle)
    }
    case 'not_contains': {
      const needle = String(cond.value ?? '').toLowerCase()
      return !String(raw ?? '').toLowerCase().includes(needle)
    }
    case '=':
      return normalizeForCompare(raw) === normalizeForCompare(cond.value)
    case '!=':
      return normalizeForCompare(raw) !== normalizeForCompare(cond.value)
    case '>':
      return Number(raw) > Number(cond.value)
    case '>=':
      return Number(raw) >= Number(cond.value)
    case '<':
      return Number(raw) < Number(cond.value)
    case '<=':
      return Number(raw) <= Number(cond.value)
    default:
      return false
  }
}

/**
 * Sum-of-Products: AND bindet stärker als OR (wie SQL).
 *
 * Aufeinanderfolgende AND-Bedingungen bilden eine Gruppe.
 * Eine OR-Konjunktion startet eine neue Gruppe.
 * Das Item matcht, wenn mindestens eine Gruppe vollständig erfüllt ist.
 */
function matchesQuery(item: MediaItem, conditions: SmartCondition[]): boolean {
  if (conditions.length === 0) return true

  // Erste Bedingung beginnt immer die erste Gruppe
  const groups: SmartCondition[][] = [[]]
  for (const cond of conditions) {
    const conj = (cond.conjunction ?? 'AND').toUpperCase()
    if (conj === 'OR' && groups[groups.length - 1].length > 0) {
      groups.push([])
    }
    groups[groups.length - 1].push(cond)
  }

  return groups.some((group) => group.every((c) => matchesCondition(item, c)))
}

// Vergleicht zwei Items anhand eines Feldes für die Sortierung
function compareItems(
  a: MediaItem,
  b: MediaItem,
  orderBy: string,
  orderDir: 'ASC' | 'DESC',
): number {
  const field = resolveField(orderBy)
  const av = (a as unknown as Record<string, unknown>)[field]
  const bv = (b as unknown as Record<string, unknown>)[field]

  let cmp = 0
  if (typeof av === 'string' && typeof bv === 'string') {
    cmp = av.localeCompare(bv, 'de')
  } else if (av === null || av === undefined) {
    cmp = bv === null || bv === undefined ? 0 : 1
  } else if (bv === null || bv === undefined) {
    cmp = -1
  } else if (typeof av === 'number' && typeof bv === 'number') {
    cmp = av - bv
  } else {
    cmp = av < bv ? -1 : av > bv ? 1 : 0
  }

  return orderDir === 'DESC' ? -cmp : cmp
}

/**
 * Wertet eine Smart-Playlist-Regel-Abfrage gegen eine Liste von MediaItems aus.
 *
 * @param items   Alle verfügbaren MediaItems (z. B. aus der Dexie-DB)
 * @param query   Geparste SmartQuery (Ergebnis von parseSmartQuery)
 * @returns       Gefiltertes, sortiertes und auf `limit` gekürztes Array
 */
export function evaluateSmartPlaylist(items: MediaItem[], query: SmartQuery): MediaItem[] {
  let result = items.filter((item) => matchesQuery(item, query.conditions))

  if (query.order_by) {
    const dir = ((query.order_dir ?? 'ASC') as string).toUpperCase() as 'ASC' | 'DESC'
    // slice() erzeugt Kopie, da sort() in-place arbeitet
    result = result.slice().sort((a, b) => compareItems(a, b, query.order_by!, dir))
  }

  if (query.limit != null && query.limit > 0) {
    result = result.slice(0, query.limit)
  }

  return result
}
