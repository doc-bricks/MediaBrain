# MediaBrain — Web/PWA Companion

Vite + React + TypeScript + Tailwind + Capacitor.

## Erste Schritte

```bash
# Empfohlen: lokalen Spiegel ausserhalb OneDrive nutzen
cp -r web_companion ~/dev/mediabrain-companion/
cd ~/dev/mediabrain-companion/

npm install
npm test             # Schema-/Playlist-Regressionen
npm run audit        # kompletter JS-Dependency-Audit
npm run audit:prod   # nur produktive Runtime-Dependencies
npm run dev              # Browser-Dev-Server
npm run build            # Production-Build nach dist/

# Capacitor: native Wrapper
npx cap add android
npm run cap:sync
npm run cap:android      # oeffnet Android Studio
```

## Architektur

- **PWA** via `vite-plugin-pwa` (Service Worker, Manifest)
- **Datenformat:** Import `mediabrain-library-v1.json` aus der Desktop-Quelle
- **Lokaler Speicher:** IndexedDB (per `idb` oder `dexie`) statt SQLite
- **Capacitor:** schlanke native Wrapper fuer Android + iOS

Der aktuelle Parser prüft explizit:

- `schema = mediabrain-library-v1`
- `schema_version = 1`
- Playlist-Felder `playlist_type`, `item_ids`, `item_refs` und `smart_query`

Legacy-Exporte ohne Schema-Marker bleiben weiter importierbar, solange `items` vorhanden ist.

## App-ID / Bundle

`com.lukas.mediabrain` — wird sowohl fuer Capacitor als auch fuer Play/App Store gebraucht.

## Status

Siehe `PORTING_STATUS.md`.
