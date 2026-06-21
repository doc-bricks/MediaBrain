# MediaBrain Companion — Status

**Quelle:** `../` (Python/PySide6, core.py + export_import.py)
**Ziel:** Web/PWA + Capacitor (Android jetzt, iOS später)
**Bundle-ID:** `com.lukas.mediabrain`
**Aktualisiert:** 2026-06-22 (Favoriten-Rück-Sync: Change-Tracking + Export-Payload)

## Status

| Schritt | Status | Dateien |
|---------|--------|---------|
| 1. Projektgerüst | FERTIG | Vite + React + TS + Tailwind + Capacitor |
| 2. Datentypen | FERTIG | `src/types/media.ts` (MediaItem, Playlist, LibraryExport) |
| 3. IndexedDB | FERTIG | `src/services/db.ts` (Dexie v2, items + playlists + meta + favoriteChanges) |
| 4. Import MediaExporter JSON | FERTIG | tolerantes Parsen via `parseLibrary()` mit Schema-Prüfung |
| 5. Bibliotheks-Liste | FERTIG | Filter nach Typ, Favoriten, Suche, Thumbnails |
| 6. Item-Detail | FERTIG | Beschreibung, Tags, Provider-URL-Schätzung |
| 7. Playlists | FERTIG | Read-only Vorschau mit `item_refs` aus aktuellem Desktop-Export |
| 8. Einstellungen | FERTIG | Stand letzter Import, Schema-/Export-Metadaten, Alles löschen |
| 9. Regressionen | FERTIG | `npm test` via Vitest für Schema und Playlist-Mapping |
| 10. Mobile PWA-Härtung | FERTIG | `viewport-fit=cover`, Apple-Web-App-Metadaten, Safe-Area-Layout, 44px-Touch-Ziele und Android-/iOS-Install-Hinweise |

## Companion-Screens

| Screen | Inhalt |
|---|---|
| **Bibliothek** | Liste mit Thumbnails, Filter-Chips (Typ + Favoriten), Suche, Tags |
| **Detail** | Cover (falls thumbnail_url), Beschreibung, Details, "Im Browser öffnen" für Online-Quellen |
| **Playlists** | Read-only Vorschau aller Playlists |
| **Import** | Datei-Picker + Paste, ersetzt lokalen Stand |
| **Einstellungen** | Stand, Favoriten-Änderungen exportieren, Alles löschen |

## Was wird *nicht* portiert

Die Companion ist **bewusst Read+Filter**, nicht Schreiben:
- Window-Tracking ist lokal-Desktop-Funktion (nicht auf Mobile)
- Blacklist-Verwaltung: nur Lesen
- File-Indexierung: keine lokalen Pfade auf dem Handy
- Smart-Playlist-Regeln: nicht ausgewertet, nur Anzeige falls vorhanden

## Workflow

```
Desktop                              Companion (Handy)
─────                                ─────────────────
MediaBrain → Export JSON          →  Datei wählen / einfügen
(export_import.MediaExporter)        → IndexedDB lokal
                                     → Liste mit Filter ansehen
                                     → Favoriten markieren (lokal)
                                     → Online-Items im Browser öffnen
```

## Bauen

```bash
# Lokaler Spiegel
rsync -a --exclude='node_modules' --exclude='android' --exclude='dist' \
  .../REL-PUB_MediaBrain/web_companion/ ~/dev/mediabrain-companion/

cd ~/dev/mediabrain-companion
npm install
npm run dev        # Browser: http://localhost:5173

# Android (Capacitor 7 braucht JDK 21!)
usejdk21
npm run build && npx cap sync android
cd android && ./gradlew assembleDebug
```

## Offen (P3)

- ~~Rück-Sync der Favoriten-Änderungen~~ FERTIG (2026-06-22, Change-Tracking + `mediabrain-companion-favorites-v1` Export)
- Smart-Playlist-Regel-Engine (Companion-Seite)
- iOS-Build nach Xcode-Installation
- Android-/iOS-PWA-Installationssmokes mit echter Exportdatei und großem Bibliotheksstand
- Dependency-Audit der JS-Toolchain (`npm audit`) ohne unnötige Breaking Changes
