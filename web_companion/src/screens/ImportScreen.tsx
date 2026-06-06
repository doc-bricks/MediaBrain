import { useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'

import { db } from '../services/db'
import { parseLibrary } from '../types/media'

export function ImportScreen() {
  const nav = useNavigate()
  const fileRef = useRef<HTMLInputElement>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  async function handleFile(file: File) {
    setBusy(true)
    setError(null)
    setSuccess(null)
    try {
      const text = await file.text()
      const raw = JSON.parse(text)
      const payload = parseLibrary(raw)
      const { items, playlists } = await db.replaceWithExport(payload)
      setSuccess(`Import erfolgreich: ${items} Einträge, ${playlists} Playlist(s).`)
      setTimeout(() => nav('/library'), 1500)
    } catch (e) {
      setError(e instanceof Error ? e.message : String(e))
    } finally {
      setBusy(false)
    }
  }

  async function handlePaste() {
    const text = prompt('JSON hier einfügen:')
    if (!text) return
    const blob = new File([text], 'import.json', { type: 'application/json' })
    handleFile(blob)
  }

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-2">Import</h1>
      <p className="text-gray-600 mb-4">
        Lade einen <code>mediabrain-library-v1.json</code>-Export aus dem Desktop.
        Existierende Companion-Daten werden ersetzt.
      </p>

      <div className="bg-white rounded-xl shadow p-4 space-y-3">
        <button
          disabled={busy}
          className="w-full bg-blue-600 text-white font-semibold py-3 rounded-lg disabled:opacity-50"
          onClick={() => fileRef.current?.click()}
        >
          📁 Export-Datei auswählen
        </button>
        <input
          ref={fileRef}
          type="file"
          accept="application/json,.json"
          className="hidden"
          onChange={(e) => {
            const f = e.target.files?.[0]
            if (f) handleFile(f)
          }}
        />
        <button
          disabled={busy}
          className="w-full bg-gray-100 text-gray-700 py-3 rounded-lg disabled:opacity-50"
          onClick={handlePaste}
        >
          📋 JSON einfügen
        </button>
      </div>

      {busy && <p className="text-gray-500 mt-4">Importiere …</p>}
      {error && (
        <div className="mt-4 bg-red-50 border border-red-200 text-red-800 p-3 rounded">
          {error}
        </div>
      )}
      {success && (
        <div className="mt-4 bg-green-50 border border-green-200 text-green-800 p-3 rounded">
          {success}
        </div>
      )}

      <div className="mt-8 border-t pt-4 text-sm text-gray-600">
        <p className="mb-2 font-medium">Auf dem Desktop:</p>
        <code className="block bg-gray-100 p-2 rounded text-xs">
          MediaBrain → Sidebar → JSON-Export
        </code>
        <p className="mt-3 mb-2 font-medium">Oder per Script:</p>
        <code className="block bg-gray-100 p-2 rounded text-xs">
          python -c "from export_import import MediaExporter; ..."
        </code>
      </div>
    </div>
  )
}
