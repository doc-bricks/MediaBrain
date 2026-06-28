import { useEffect, useState } from 'react'

import { db } from '../services/db'
import { evaluateSmartPlaylist, parseSmartQuery } from '../lib/smartPlaylist'
import { MediaItem, Playlist } from '../types/media'

// Typisierte Vorschau für eine aufgelöste Playlist (manuell oder smart)
interface ResolvedPlaylist {
  playlist: Playlist
  previewItems: Array<{ title: string; key: string }>
  totalCount: number
  isSmart: boolean
}

function resolvePlaylist(p: Playlist, allItems: MediaItem[]): ResolvedPlaylist {
  const isSmart = p.type === 'smart'

  if (isSmart && p.rules != null) {
    const query = parseSmartQuery(p.rules)
    if (query) {
      const smartItems = evaluateSmartPlaylist(allItems, query)
      return {
        playlist: p,
        isSmart: true,
        totalCount: smartItems.length,
        previewItems: smartItems.slice(0, 5).map((it, i) => ({
          title: it.title,
          key: `smart-${p.id}-${it.id}-${i}`,
        })),
      }
    }
    // Regeln vorhanden, aber nicht parsbar
    return { playlist: p, isSmart: true, totalCount: 0, previewItems: [] }
  }

  // Manuelle Playlist — vorhandene items-/item_ids-Infos nutzen
  const manualItems = p.items ?? []
  return {
    playlist: p,
    isSmart: false,
    totalCount: manualItems.length || p.item_ids?.length || 0,
    previewItems: manualItems.slice(0, 5).map((it, index) => ({
      title: it.title ?? it.provider_id ?? 'Unbenannter Eintrag',
      key: `${it.media_id ?? index}-${it.provider_id ?? it.title ?? 'playlist-item'}`,
    })),
  }
}

export function PlaylistsScreen() {
  const [resolved, setResolved] = useState<ResolvedPlaylist[] | null>(null)

  useEffect(() => {
    async function load() {
      const playlists = await db.listPlaylists()
      const hasSmart = playlists.some((p) => p.type === 'smart')
      const allItems = hasSmart ? await db.listItems() : []
      setResolved(playlists.map((p) => resolvePlaylist(p, allItems)))
    }
    void load()
  }, [])

  if (!resolved) return <p className="p-4 text-gray-500">Lade …</p>

  if (resolved.length === 0) {
    return (
      <div className="p-6 text-center text-gray-500">
        <div className="text-4xl mb-3">🎶</div>
        Noch keine Playlists. Werden mit dem nächsten Import übernommen.
      </div>
    )
  }

  return (
    <div>
      <div className="p-4 bg-white border-b border-gray-200">
        <h1 className="text-2xl font-bold">Playlists</h1>
        <p className="text-xs text-gray-500">{resolved.length} Playlist(s)</p>
      </div>
      <ul className="divide-y divide-gray-200">
        {resolved.map(({ playlist: p, previewItems, totalCount, isSmart }) => (
          <li key={p.id} className="bg-white p-4">
            <div className="font-medium flex items-center gap-2">
              {p.name}
              {isSmart && (
                <span className="text-xs bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                  Smart
                </span>
              )}
            </div>
            {p.description && (
              <div className="text-sm text-gray-600 mt-1">{p.description}</div>
            )}
            <div className="text-xs text-gray-500 mt-1">
              {totalCount} Einträge
              {p.type && ` · ${p.type}`}
            </div>
            {previewItems.length > 0 && (
              <ul className="mt-2 text-sm text-gray-700 list-disc list-inside">
                {previewItems.map((it) => (
                  <li key={it.key} className="truncate">
                    {it.title}
                  </li>
                ))}
                {totalCount > 5 && (
                  <li className="text-gray-400">… und {totalCount - 5} weitere</li>
                )}
              </ul>
            )}
            {isSmart && p.rules == null && (
              <p className="mt-2 text-xs text-gray-400 italic">
                Keine Regeln vorhanden – bitte Bibliothek erneut importieren.
              </p>
            )}
          </li>
        ))}
      </ul>
    </div>
  )
}
