# MediaBrain Mobile (Flutter) — Status

**Quelle:** `../core.py` (Python, MediaItem-Schema) + `../web_companion/` (PWA-Patterns)
**Ziel:** Eigenständige Flutter-App (Android + iOS)
**Bundle-ID:** `com.lukas.mediabrain`
**Erstellt:** 2026-05-26 (Migration von PWA auf Flutter)

## Status

| Schritt | Status | Dateien |
|---------|--------|---------|
| 1. Projektgerüst | FERTIG | `flutter create --platforms android,ios` |
| 2. Datenmodell | FERTIG | `lib/models/models.dart` (MediaItem, MediaCategory) |
| 3. SQLite-Schicht | FERTIG | `lib/services/database_service.dart` |
| 4. Mobile-Tracking | FERTIG | `lib/services/media_usage_service.dart` via app_usage + installed_apps |
| 5. Medien-App-Katalog | FERTIG | `lib/services/media_app_catalog.dart` — 30+ Apps in 7 Kategorien |
| 6. Library + Filter | FERTIG | `lib/screens/library_screen.dart` |
| 7. Detail + Favorit | FERTIG | `lib/screens/item_detail_screen.dart` |
| 8. Scan-Screen | FERTIG | `lib/screens/scan_screen.dart` |
| 9. Einstellungen | FERTIG | `lib/screens/settings_screen.dart` |
| 10. App-Icon + Name | FERTIG | flutter_launcher_icons + AndroidManifest |
| 11. Debug-APK | FERTIG | 2026-06-03 im lokalen Mirror mit Flutter 3.44.0 verifiziert (`flutter analyze`, `flutter test`, `flutter build apk --debug`) |
| 12. Flutter L10n DE+EN | FERTIG | 2026-06-07 — handgeschriebene `AppLocalizations` (DE+EN), ARB-Referenzdateien, alle Screens/Dialoge lokalisiert. `flutter analyze` 0 Fehler, 8/8 L10n-Tests + widget_test grün. |
| 13. Sync-Format (Export/Import) | FERTIG | 2026-06-14 — `buildExportPayload()` + `importLibraryBundle()` in `database_service.dart`. Schema `mediabrain-library-v1`, Desktop-kompatibel (`type`↔`category`-Mapping, Fixture-Test). Merge via source+provider_id (Fallback: title+category). UUID-Validierung via `_isUuid()` verhindert Desktop-Integer-IDs als Flutter-PK. `dart analyze lib/` 0 Fehler, 15/15 Tests grün. |

## Was die App macht

Standalone-Variante des Desktop-Tools. Auf dem Handy gibt es kein Window-Title-Tracking,
also nutzen wir stattdessen Android `UsageStatsManager`:

1. **Scan-Tab:** "Medien-Apps scannen" liest installierte Apps und ihre Foreground-Zeit
2. Erkannte Medien-Apps werden in die Bibliothek übernommen (Titel = App-Name,
   Kategorie aus `MediaAppCatalog`)
3. **Bibliothek:** Filter nach Kategorie/Favoriten/Suche, sortiert nach letzter Nutzung
4. **Detail:** Beschreibung, Tags, Play-Store-Link

## Kategorien (8)

🎬 Film · 📺 Serie · 🎵 Musik · 🎞️ Clip · 🎙️ Podcast · 📖 Hörbuch · 📄 Dokument · 📱 App

## Erkannte Medien-Apps (Auszug)

**Streaming:** Netflix, Disney+, Prime Video, Apple TV, WOW/Sky, DAZN, Paramount+, Crunchyroll
**YouTube:** YouTube, YouTube Kids, YouTube Studio
**Musik:** Spotify, Apple Music, YouTube Music, Tidal, Amazon Music, SoundCloud, Deezer
**Podcasts:** Google Podcasts, Pocket Casts, Castbox
**Bücher:** Audible, Kindle
**Dokumente:** Adobe Acrobat, Google Docs, Microsoft Word, Notion, Obsidian, Google Drive

Weitere Apps: einfach `media_app_catalog.dart` erweitern.

## Permission

Wie bei AboTracker — `PACKAGE_USAGE_STATS` ist Special-Access:
**Einstellungen → Apps → Spezieller App-Zugriff → Nutzungsdatenzugriff → MediaBrain.**
Ohne Permission funktioniert der Scan, liefert aber nur Apps ohne Nutzungszeit.

## Bauen (Mac Studio)

```zsh
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"

# Spiegel
rsync -a --exclude='.dart_tool' --exclude='build' \
  .../REL-PUB_MediaBrain/flutter_port/ ~/dev/mediabrain-flutter/

cd ~/dev/mediabrain-flutter
flutter pub get
flutter analyze
flutter build apk --debug
```

## Bestehende `web_companion/` (PWA)

Die PWA-Variante (Vite+React+TS+Capacitor) bleibt im Repository als
"Lese-Companion für Desktop-Export-JSON". Die Flutter-Variante ist Standalone.
Beide Wege funktionieren parallel.

## Offen

- iOS-Build (Xcode)
- [v1-Limitierung Sync-Format] Import überschreibt foreground_minutes + last_opened_at mit Desktop-Werten (Desktop exportiert foreground_minutes nicht → reset auf 0); feldselektives Update für v2 geplant
- Server-Sync (Mac Studio als zentraler Host)
- Manuelles Erfassen einzelner Medien (z.B. ein gerade gesehener Film, der nicht aus einer Tracking-App stammt)
- Smart-Playlists & Tag-System (P2)
- Kotlin-Plugin-Warnungen der Dependencies vor späteren Flutter-Upgrades nachziehen
