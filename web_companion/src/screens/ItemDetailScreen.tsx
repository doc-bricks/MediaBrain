import { useEffect, useRef, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'

import { db } from '../services/db'
import {
  MEDIA_TYPE_ICON,
  MEDIA_TYPE_LABEL,
  MediaItem,
} from '../types/media'

export function ItemDetailScreen() {
  const { id = '' } = useParams()
  const nav = useNavigate()
  const [item, setItem] = useState<MediaItem | null>(null)
  const mountedRef = useRef(true)

  useEffect(() => {
    mountedRef.current = true
    return () => { mountedRef.current = false }
  }, [])

  useEffect(() => {
    db.getItem(parseInt(id, 10)).then((i) => setItem(i ?? null))
  }, [id])

  if (!item) {
    return <p className="p-4 text-gray-500">Lade …</p>
  }

  async function toggleFav() {
    await db.toggleFavorite(item!.id)
    const fresh = await db.getItem(item!.id)
    if (mountedRef.current) setItem(fresh ?? null)
  }

  function openExternal() {
    if (!item) return
    // Lokale Pfade können von der mobilen App nicht geöffnet werden,
    // aber YouTube/Netflix/Spotify-Links per Source-Schätzung:
    const guess = guessUrl(item)
    if (guess) {
      window.open(guess, '_blank')
    }
  }

  const heroUrl = item.thumbnail_url ?? null

  return (
    <div className="pb-4">
      <div className="bg-white border-b border-gray-200">
        <div className="p-4 flex items-center gap-3">
          <button
            className="text-blue-600 text-2xl leading-none"
            onClick={() => nav(-1)}
          >
            ‹
          </button>
          <div className="flex-1">
            <div className="text-xs text-gray-500">
              {MEDIA_TYPE_LABEL[item.type] ?? item.type}
              {item.source && ` · ${item.source}`}
            </div>
            <h1 className="text-lg font-bold">{item.title}</h1>
          </div>
          <button onClick={toggleFav} className="text-2xl">
            {item.is_favorite ? '⭐' : '☆'}
          </button>
        </div>
      </div>

      {heroUrl && heroUrl.startsWith('http') ? (
        <img
          src={heroUrl}
          alt=""
          className="w-full max-h-72 object-cover bg-gray-200"
          onError={(e) => {
            ;(e.currentTarget as HTMLImageElement).style.display = 'none'
          }}
        />
      ) : (
        <div className="w-full h-32 bg-gray-100 flex items-center justify-center text-5xl">
          {MEDIA_TYPE_ICON[item.type] ?? '🗂️'}
        </div>
      )}

      <div className="p-4 space-y-3">
        {item.description && (
          <Section title="Beschreibung">
            <p className="whitespace-pre-wrap">{item.description}</p>
          </Section>
        )}
        <Section title="Details">
          <DL>
            {item.artist && <Row k="Künstler" v={item.artist} />}
            {item.album && <Row k="Album" v={item.album} />}
            {item.channel && <Row k="Kanal" v={item.channel} />}
            {item.season != null && (
              <Row k="Staffel/Folge" v={`S${item.season}E${item.episode ?? ''}`} />
            )}
            {typeof item.length_seconds === 'number' && (
              <Row k="Länge" v={formatLength(item.length_seconds)} />
            )}
            {item.created_at && (
              <Row k="Erfasst" v={formatDateTime(item.created_at)} />
            )}
            {item.last_opened_at && (
              <Row
                k="Zuletzt geöffnet"
                v={formatDateTime(item.last_opened_at)}
              />
            )}
            {item.local_path && <Row k="Lokaler Pfad" v={item.local_path} />}
            {item.provider_id && (
              <Row k="Provider-ID" v={item.provider_id} />
            )}
          </DL>
        </Section>
        {item.tags && item.tags.length > 0 && (
          <Section title="Tags">
            <div className="flex flex-wrap gap-1">
              {item.tags.map((t) => (
                <span
                  key={t}
                  className="text-xs bg-blue-50 text-blue-700 px-2 py-0.5 rounded-full"
                >
                  {t}
                </span>
              ))}
            </div>
          </Section>
        )}
        {guessUrl(item) && (
          <button
            onClick={openExternal}
            className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold"
          >
            Im Browser öffnen
          </button>
        )}
      </div>
    </div>
  )
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h2 className="text-xs font-bold text-gray-500 uppercase tracking-wide mb-2">
        {title}
      </h2>
      <div className="bg-white rounded-lg p-3 shadow-sm">{children}</div>
    </section>
  )
}

function DL({ children }: { children: React.ReactNode }) {
  return <dl className="space-y-2 text-sm">{children}</dl>
}

function Row({ k, v }: { k: string; v: string }) {
  return (
    <div className="flex">
      <dt className="w-32 text-gray-500">{k}</dt>
      <dd className="flex-1 break-words">{v}</dd>
    </div>
  )
}

function formatLength(sec: number): string {
  if (sec < 60) return `${sec} s`
  const m = Math.floor(sec / 60)
  const r = sec % 60
  if (m < 60) return r === 0 ? `${m} min` : `${m} min ${r} s`
  const h = Math.floor(m / 60)
  const rm = m % 60
  return rm === 0 ? `${h} h` : `${h} h ${rm} min`
}

function formatDateTime(iso: string): string {
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return iso
  return d.toLocaleString('de-DE', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

function guessUrl(item: MediaItem): string | null {
  // Versuche, aus source + provider_id eine URL zu bauen.
  const pid = item.provider_id
  if (!pid) return null
  switch (item.source) {
    case 'youtube':
      return `https://www.youtube.com/watch?v=${pid}`
    case 'spotify':
      // Spotify-IDs: bei Tracks/Albums/Playlists fehlt der Typ — best effort.
      return `https://open.spotify.com/track/${pid}`
    case 'netflix':
      return `https://www.netflix.com/title/${pid}`
    case 'twitch':
      return `https://www.twitch.tv/videos/${pid}`
    case 'prime':
      return `https://www.amazon.com/gp/video/detail/${pid}`
    default:
      return null
  }
}
