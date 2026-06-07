import { useEffect, useState } from 'react'

import { db } from '../services/db'

export function SettingsScreen() {
  const [lastImport, setLastImport] = useState<string | null>(null)
  const [counts, setCounts] = useState<{ items: number; playlists: number } | null>(null)

  useEffect(() => {
    refresh()
  }, [])

  async function refresh() {
    const li = (await db.getMeta('last_import')) ?? null
    setLastImport(li)
    setCounts({
      items: await db.items.count(),
      playlists: await db.playlists.count(),
    })
  }

  async function clearAll() {
    if (!confirm('Alle Companion-Daten löschen? Dies betrifft nur das Handy.')) return
    await db.clearAll()
    await refresh()
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let last: any = null
  if (lastImport) {
    try {
      last = JSON.parse(lastImport)
    } catch {
      last = null
    }
  }

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Einstellungen</h1>

      <section className="bg-white rounded-xl shadow-sm overflow-hidden mb-4">
        <div className="px-4 pt-3 pb-1 text-xs font-bold text-gray-500 uppercase tracking-wide">
          Stand
        </div>
        <div className="px-4 py-2 flex justify-between border-t border-gray-100 first:border-t-0">
          <span>Einträge</span>
          <span className="text-gray-500">{counts?.items ?? '—'}</span>
        </div>
        <div className="px-4 py-2 flex justify-between border-t border-gray-100">
          <span>Playlists</span>
          <span className="text-gray-500">{counts?.playlists ?? '—'}</span>
        </div>
        <div className="px-4 py-2 border-t border-gray-100">
          <div className="text-sm">Letzter Import</div>
          {last ? (
            <div className="text-xs text-gray-500 mt-1">
              Schema: {last.schema || 'legacy'}
              {last.schema_version ? ` v${last.schema_version}` : ''}
              <br />
              Export-App: {last.app_name || 'MediaBrain Desktop'}
              {last.app_version ? ` ${last.app_version}` : ''}
              {last.source_platform ? ` · ${last.source_platform}` : ''}
              <br />
              Export vom: {last.exported_at || '—'}
              <br />
              Importiert: {last.imported_at}
              <br />
              {last.item_count} Einträge, {last.playlist_count} Playlists
            </div>
          ) : (
            <div className="text-xs text-gray-500">Noch kein Import.</div>
          )}
        </div>
      </section>

      <section className="bg-white rounded-xl shadow-sm overflow-hidden mb-4">
        <button
          onClick={clearAll}
          className="block w-full text-left px-4 py-3 text-red-600 active:bg-red-50"
        >
          Alle Companion-Daten löschen
        </button>
      </section>

      <section className="bg-white rounded-xl shadow-sm overflow-hidden">
        <div className="px-4 py-3">
          <div className="font-medium">MediaBrain Companion</div>
          <div className="text-xs text-gray-500 mt-1">
            Lese-Companion zum Desktop-Tool. Daten bleiben lokal. Bundle-ID:
            <code className="ml-1">com.lukas.mediabrain</code>
          </div>
        </div>
      </section>
    </div>
  )
}
