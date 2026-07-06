# MediaBrain Mobile PWA Smoke

Stand: 2026-07-06

Dieses Runbook trennt den lokalen Contract-Smoke vom echten Geräte-Smoke für den Web/PWA-Companion.

## Lokaler Contract-Smoke

```powershell
npm --prefix web_companion exec vitest run src/platform/mobilePwaSmoke.test.ts src/platform/pwa.test.ts
```

Der lokale Smoke prüft:

- Android-Chrome- und iOS-Safari-Erkennung für den Installationshinweis
- Import eines großen `mediabrain-library-v1.json`-Desktop-Exports
- IndexedDB-Persistenz in einer isolierten Companion-Datenbank
- Tags, Typfilter, Playlists und Import-Metadaten
- Favoriten-Rückexport als `mediabrain-companion-favorites-v1`

## Echter Android-Smoke

1. Desktop-Export `mediabrain-library-v1.json` mit großem Bibliotheksbestand erzeugen.
2. `npm --prefix web_companion run build` ausführen und die PWA lokal oder auf einem Testhost bereitstellen.
3. Android Chrome öffnen, PWA installieren und Import über Datei-Auswahl durchführen.
4. Offline-Modus aktivieren und Bibliothek, Suche, Playlists und Detailansicht öffnen.
5. Mindestens zwei Favoriten ändern und den Favoriten-Rückexport herunterladen.

## Echter iOS-Smoke

1. Dieselbe Exportdatei über Dateien/iCloud/Downloads für Safari verfügbar machen.
2. PWA in Safari öffnen und über Teilen -> Zum Home-Bildschirm installieren.
3. Import über Datei-Auswahl durchführen und die IndexedDB-Persistenz nach App-Neustart prüfen.
4. Offline-Modus testen und Favoriten-Rückexport herunterladen.

## Grenzen

Der lokale Contract-Smoke ersetzt keinen Geräte- oder Emulatorlauf. Er beweist nur, dass Import, lokale Persistenz, Installationshinweise und Rückexport ohne Browser-/Geräteabhängigkeit zusammenpassen.
