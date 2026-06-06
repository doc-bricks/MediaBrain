import { useEffect, useState } from 'react'

import { db } from '../services/db'
import { Playlist } from '../types/media'

export function PlaylistsScreen() {
  const [playlists, setPlaylists] = useState<Playlist[] | null>(null)

  useEffect(() => {
    db.listPlaylists().then(setPlaylists)
  }, [])

  if (!playlists) return <p className="p-4 text-gray-500">Lade …</p>

  if (playlists.length === 0) {
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
        <p className="text-xs text-gray-500">{playlists.length} Playlist(s)</p>
      </div>
      <ul className="divide-y divide-gray-200">
        {playlists.map((p) => (
          <li key={p.id} className="bg-white p-4">
            <div className="font-medium">{p.name}</div>
            {p.description && (
              <div className="text-sm text-gray-600 mt-1">{p.description}</div>
            )}
            <div className="text-xs text-gray-500 mt-1">
              {p.items?.length ?? p.item_ids?.length ?? 0} Einträge
              {p.type && ` · ${p.type}`}
            </div>
            {p.items && p.items.length > 0 && (
              <ul className="mt-2 text-sm text-gray-700 list-disc list-inside">
                {p.items.slice(0, 5).map((it, index) => (
                  <li
                    key={`${it.media_id ?? index}-${it.provider_id ?? it.title ?? 'playlist-item'}`}
                    className="truncate"
                  >
                    {it.title ?? it.provider_id ?? 'Unbenannter Eintrag'}
                  </li>
                ))}
                {p.items.length > 5 && (
                  <li className="text-gray-400">… und {p.items.length - 5} weitere</li>
                )}
              </ul>
            )}
          </li>
        ))}
      </ul>
    </div>
  )
}
