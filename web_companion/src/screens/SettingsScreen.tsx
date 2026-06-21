import { useEffect, useState } from 'react'

import { db } from '../services/db'

export function SettingsScreen() {
  const [lastImport, setLastImport] = useState<string | null>(null)
  const [counts, setCounts] = useState<{ items: number; playlists: number } | null>(null)
  const [pendingChanges, setPendingChanges] = useState(0)

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
    setPendingChanges(await db.pendingFavoriteChangesCount())
  }

  async function clearAll() {
    if (!confirm('Alle Companion-Daten löschen? Dies betrifft nur das Handy.')) return
    await db.clearAll()
    await refresh()
  }

  async function exportFavoriteChanges() {
    const payload = await db.buildFavoriteChangesPayload()
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `mediabrain-companion-favorites-v1.json`
    document.body.appendChild(a)
    a.click()
    setTimeout(() => {
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    }, 100)
  }

  async function discardFavoriteChanges() {
    if (!confirm('Alle ausstehenden Favoriten-Änderungen verwerfen?')) return
    await db.clearFavoriteChanges()
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

      {pendingChanges > 0 && (
        <section className="bg-white rounded-xl shadow-sm overflow-hidden mb-4">
          <div className="px-4 pt-3 pb-1 text-xs font-bold text-gray-500 uppercase tracking-wide">
            Favoriten-Änderungen
          </div>
          <div className="px-4 py-2 border-t border-gray-100">
            <p className="text-sm text-gray-700 mb-2">
              {pendingChanges} {pendingChanges === 1 ? 'Änderung' : 'Änderungen'} seit dem letzten Import.
            </p>
            <div className="flex gap-2">
              <button
                onClick={exportFavoriteChanges}
                className="flex-1 bg-blue-600 text-white py-2 rounded-lg text-sm font-semibold active:bg-blue-700"
              >
                Exportieren
              </button>
              <button
                onClick={discardFavoriteChanges}
                className="px-4 py-2 rounded-lg text-sm text-gray-600 border border-gray-300 active:bg-gray-50"
              >
                Verwerfen
              </button>
            </div>
          </div>
        </section>
      )}

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
