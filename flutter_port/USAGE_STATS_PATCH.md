# Hinweis: `usage_stats` ist historisch

Diese Datei bleibt nur als Verlaufsnotiz im Projekt.

Stand 2026-06-03:

- Das frühere Plugin `usage_stats 1.3.1` ist **nicht mehr Teil** von `pubspec.yaml`.
- Der Android-Build wird deshalb **nicht mehr** über einen lokalen Pub-Cache-Patch repariert.
- Der Mobile-Auto-Scan läuft stattdessen über `app_usage` plus `installed_apps`.

## Frühere Ursache

Das entfernte `usage_stats`-Plugin blockierte Builds unter neueren Android-/Flutter-Versionen durch:

1. `repositories { jcenter() }`
2. veraltete `compileSdkVersion`

## Aktueller Umgang

- Keine Patch-Schritte mehr ausführen.
- Bei Bedarf diese Datei nur als technische Historie lesen.
- Für den aktuellen Build- und Verifikationsweg gilt [README.md](README.md).
