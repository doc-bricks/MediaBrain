import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'

import { db } from '../services/db'
import {
  MEDIA_TYPE_ICON,
  MEDIA_TYPE_LABEL,
  MediaItem,
} from '../types/media'

export function LibraryScreen() {
  const [items, setItems] = useState<MediaItem[]>([])
  const [types, setTypes] = useState<string[]>([])
  const [query, setQuery] = useState('')
  const [type, setType] = useState<string | null>(null)
  const [favoritesOnly, setFavoritesOnly] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let alive = true
    setLoading(true)
    Promise.all([
      db.listItems({ query, type: type ?? undefined, favoritesOnly, limit: 500 }),
      db.listAllTypes(),
    ]).then(([rows, ts]) => {
      if (!alive) return
      setItems(rows)
      setTypes(ts)
      setLoading(false)
    })
    return () => {
      alive = false
    }
  }, [query, type, favoritesOnly])

  const summary = useMemo(() => {
    return {
      total: items.length,
      favorites: items.filter((i) => i.is_favorite).length,
    }
  }, [items])

  if (loading && items.length === 0) {
    return <p className="p-4 text-gray-500">Lade Bibliothek …</p>
  }

  if (!loading && items.length === 0 && !query && !type && !favoritesOnly) {
    return (
      <div className="p-6 text-center">
        <div className="text-5xl mb-4">📥</div>
        <h1 className="text-xl font-bold mb-2">Bibliothek leer</h1>
        <p className="text-gray-600 mb-4">
          Importiere einen Bibliothek-Export (JSON) aus MediaBrain Desktop.
        </p>
        <Link
          to="/import"
          className="inline-block bg-blue-600 text-white px-4 py-2 rounded-lg"
        >
          Zum Import
        </Link>
      </div>
    )
  }

  return (
    <div>
      <div className="p-4 bg-white border-b border-gray-200 sticky top-0 z-10">
        <h1 className="text-2xl font-bold">Bibliothek</h1>
        <p className="text-xs text-gray-500 mb-3">
          {summary.total} Einträge · {summary.favorites} Favoriten
        </p>
        <input
          type="search"
          placeholder="Suchen (Titel, Künstler, Kanal, …)"
          className="w-full bg-gray-100 px-3 py-2 rounded-lg"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <div className="mt-2 flex gap-2 overflow-x-auto pb-1">
          <FilterChip
            label="Alle"
            active={type === null}
            onClick={() => setType(null)}
          />
          {types.map((t) => (
            <FilterChip
              key={t}
              label={`${MEDIA_TYPE_ICON[t] ?? '🗂️'} ${MEDIA_TYPE_LABEL[t] ?? t}`}
              active={type === t}
              onClick={() => setType(type === t ? null : t)}
            />
          ))}
          <FilterChip
            label="⭐ Favoriten"
            active={favoritesOnly}
            onClick={() => setFavoritesOnly(!favoritesOnly)}
          />
        </div>
      </div>

      {items.length === 0 ? (
        <p className="p-6 text-gray-500 text-center">
          Keine Treffer für die aktuelle Filterauswahl.
        </p>
      ) : (
        <ul className="divide-y divide-gray-200">
          {items.map((m) => (
            <li key={m.id}>
              <Link
                to={`/library/${m.id}`}
                className="flex items-start p-3 bg-white active:bg-gray-100"
              >
                <Thumb url={m.thumbnail_url ?? null} type={m.type} />
                <div className="ml-3 flex-1 min-w-0">
                  <div className="font-medium truncate">{m.title}</div>
                  <div className="text-xs text-gray-500 truncate">
                    {MEDIA_TYPE_LABEL[m.type] ?? m.type}
                    {m.source && ` · ${m.source}`}
                    {m.artist && ` · ${m.artist}`}
                    {m.channel && ` · ${m.channel}`}
                    {m.season != null && m.episode != null &&
                      ` · S${m.season}E${m.episode}`}
                  </div>
                  {m.tags && m.tags.length > 0 && (
                    <div className="flex flex-wrap gap-1 mt-1">
                      {m.tags.slice(0, 4).map((t) => (
                        <span
                          key={t}
                          className="text-xs bg-blue-50 text-blue-700 px-2 rounded-full"
                        >
                          {t}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
                <div className="ml-2 flex flex-col items-end gap-1">
                  {m.is_favorite && <span>⭐</span>}
                  <span className="text-gray-300">›</span>
                </div>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={
        'whitespace-nowrap px-3 py-1.5 rounded-full text-sm border ' +
        (active
          ? 'bg-blue-600 text-white border-blue-600'
          : 'bg-white text-gray-700 border-gray-300')
      }
    >
      {label}
    </button>
  )
}

function Thumb({ url, type }: { url: string | null; type: string }) {
  if (url && url.startsWith('http')) {
    return (
      <img
        src={url}
        alt=""
        loading="lazy"
        className="w-14 h-14 rounded object-cover bg-gray-200"
        onError={(e) => {
          ;(e.currentTarget as HTMLImageElement).style.display = 'none'
        }}
      />
    )
  }
  return (
    <div className="w-14 h-14 rounded bg-gray-100 flex items-center justify-center text-2xl">
      {MEDIA_TYPE_ICON[type] ?? '🗂️'}
    </div>
  )
}
