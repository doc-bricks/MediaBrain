# MediaBrain Mobile (Flutter)

Eigenständige Mobile-Linie von MediaBrain für Android und iOS. Die App scannt installierte Medien-Apps, liest unter Android die aggregierte Nutzungsdauer über `app_usage`, speichert den Bestand lokal in SQLite und bietet Bibliothek, Detailansicht, Scan-Screen und Einstellungen.

## Zweck

- Mobile Ergänzung zur Desktop-Zentrale
- Lokaler Auto-Scan bekannter Medien-Apps
- Datei- und optionaler Server-Sync für sporadischen Abgleich
- Keine Desktop-Watcher, keine lokalen Dateiaktionen, keine Tray-Funktionen

## Setup

Voraussetzungen:

- Flutter 3.44.0
- Dart 3.12.0
- JDK 17
- Android SDK unter `C:\dev\Android\Sdk` oder äquivalent

Typischer lokaler Build außerhalb von OneDrive:

```powershell
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot'
$env:ANDROID_HOME='C:\dev\Android\Sdk'
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
$env:PATH="C:\dev\flutter\bin;$env:ANDROID_HOME\platform-tools;$env:JAVA_HOME\bin;$env:PATH"

flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Verifizierter Stand

- 2026-06-03 im lokalen Mirror `C:\_Local_DEV\codex_build\mediabrain_flutter_port` geprüft
- `flutter pub get` grün
- `flutter analyze` grün
- `flutter test` grün
- `flutter build apk --debug` grün
- Artefakt: `build\app\outputs\flutter-apk\app-debug.apk`

## Hinweise

- Der frühere `usage_stats`-Blocker ist entfernt. Der Auto-Scan läuft jetzt nur noch über `app_usage` plus `installed_apps`.
- Beim Build gibt Flutter derzeit nur noch Kotlin-Plugin-Warnungen für einige Abhängigkeiten aus; das ist als Folgeaufgabe dokumentiert, aber aktuell kein Build-Blocker.
- Details zu Datenfluss und Sync stehen in [PORTING_STATUS.md](PORTING_STATUS.md) und [SYNC_GUIDE.md](SYNC_GUIDE.md).
