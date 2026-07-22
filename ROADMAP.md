# MediaBrain – Roadmap und Statusindex

Stand: 2026-07-19

Diese Datei ist der projektweite Statusindex. Sie beschreibt keine zweite, von den
Strangdokumenten abweichende Featureplanung.

## Kanonische Dokumentrollen

| Bereich | Kanonische Quelle | Zweck |
|---|---|---|
| Projektweiter Status | `ROADMAP.md` | Zusammenführung der belegten Desktop-, Flutter- und Web-Stände sowie Verweise auf offene Arbeit. |
| Plattformstrategie | `PORTIERUNGSPLAN.md` | Entscheidungen zu Windows, macOS/Linux, Flutter und Web/PWA; keine parallele Aufgabenliste. |
| Desktop und projektweite Arbeit | `AUFGABEN.txt` plus TASKPLAN-ID | Lokaler Ausführungsstand offener Aufgaben. Die TASKPLAN-ID ist der eindeutige Arbeitsanker. |
| Flutter Mobile | `flutter_port/PORTING_STATUS.md` | Implementierungs- und Verifikationsstand der Flutter-Linie. |
| Web/PWA Companion | `web_companion/PORTING_STATUS.md` | Implementierungsstand des read-mostly Companion. |
| Abgeschlossene Änderungen | `CHANGELOG.md` | Historie umgesetzter Änderungen; keine Quelle für offene Arbeit. |

`web_companion/PORTING_STATUS.md.notes`, Sicherungen und Dateien mit Namen wie
`*.bak` oder `*_FINAL*` sind historische Arbeitsnotizen und nicht kanonisch.

## Verifikationsbegriffe

- **Implementiert:** Der Stand ist in Quelle und Strangdokument belegt. Dieser reine
  Dokumentationsabgleich führt keinen neuen Produktnachweis ein.
- **Lokaler Contract-/Build-Smoke:** Automatisierte Prüfung oder lokaler Build ohne
  Beleg auf dem Zielgerät.
- **Live-Smoke:** Manueller Lauf auf dem genannten Gerät, Emulator oder Betriebssystem
  mit protokolliertem Ergebnis.
- **Externe Prüfgrenze:** Gerät, Betriebssystem, Xcode, Store-Konto oder andere externe
  Voraussetzung fehlt; die zugehörige Aufgabe bleibt offen.

Ein lokaler Contract-/Build-Smoke gilt ausdrücklich nicht als Live-Smoke.

## Belegter Stand

| Strang | Implementiert bzw. lokal belegt | Offene oder externe Prüfgrenze |
|---|---|---|
| Desktop / Windows | Datenbank und MediaManager, acht Provider, WindowWatcher, FileIndexer, Tray, erweiterte Suche und Filter, QueryBuilder/Smart-Playlists, Import/Export, Dateiaktionen, drei Themes sowie die getestete Read-only-CLI sind vorhanden. Der Desktop-Versions-/Python-Vertrag ist seit 2026-07-22 konsolidiert. | Store-Gate und vollständiges Desktop-Englisch bleiben offen. |
| Web/PWA Companion | Import von `mediabrain-library-v1.json`, IndexedDB, Filter, Details, Playlists, Favoriten-Rückexport und PWA-Härtung sind im Strangstatus belegt. Der lokale Mobile-PWA-Contract-Smoke ist seit 2026-07-06 über `web_companion/MOBILE_PWA_SMOKE.md` dokumentiert. | DE/EN-I18N sowie echte Android-Chrome- und iOS-Safari-/Home-Screen-Smokes bleiben offen. Es gibt keinen Gerätefreigabe-Claim. |
| Flutter / Android | App-Scan, UsageStats-Anbindung, SQLite, Bibliothek, Details, DE/EN-L10n und das v1-Dateiaustauschformat sind dokumentiert. Analyze, Tests und Debug-APK wurden am 2026-06-03 im lokalen Mirror belegt; Sync-Tests sind bis 2026-06-14 dokumentiert. | Permission-Fluss, Datei-Sync und großer Bestand auf einem echten Android-Ziel bleiben offen. Kotlin-Plugin-Warnungen sind kein aktueller Build-Fehler, aber vor Upgrades zu prüfen. |
| Flutter / iOS | Das Flutter-Projekt enthält eine iOS-Zielstruktur. | Xcode-Build, Dateiimport und der bewusst reduzierte Trackingumfang sind mangels macOS/Xcode-/iOS-Beleg offen. |
| Desktop / macOS und Linux | Gemeinsame PySide6-Quellbasis vorhanden. | Start, Import/Export, Pfade, Tray und Dateiöffner sind auf den Zielsystemen nicht live belegt. |

## Aktive Folgeaufgaben

TASKPLAN ist der Ausführungsanker; `AUFGABEN.txt` spiegelt Stable-ID und Status. Jede
offene Arbeit wird hier genau über ihre TASKPLAN-ID referenziert:

| TASKPLAN | Stable-ID | Gegenstand | Status |
|---:|---|---|---|
| 935 | TW-MB-01 | Windows-Store-Release-Gate | offen; externe Store-/Toolchain-Anteile möglich |
| 936 | TW-MB-02 | Desktop-Englisch bis zur Parität | offen |
| 937 | TW-MB-03 | Web-Companion DE/EN-I18N | offen |
| 938 | TW-MB-04 | echter Android-PWA-Smoke | offen; Gerät/Emulator und Testhost erforderlich |
| 939 | TW-MB-05 | echter iOS-PWA-Smoke | offen; iOS/Safari und Testhost erforderlich |
| 940 | TW-MB-06 | Flutter-Android-Gerätetest | offen; Android-Ziel erforderlich |
| 941 | TW-MB-07 | Flutter-iOS-Build und Trackinggrenze | offen; macOS/Xcode/iOS erforderlich |
| 942 | TW-MB-08 | Export-/Release-Version und Python-Vertrag | erledigt 2026-07-22; `version.py`, Python 3.10+, Exporttests |
| 943 | TW-MB-09 | Status der headless Read-only-CLI | erledigt 2026-07-22; offiziell read-only, Blacklist-Vertrag und Tests |
| 944 | TW-MB-10 | macOS-/Linux-Source-Smokes | offen; Zielsysteme erforderlich |
| 945 | TW-MB-11 | Flutter-Kotlin-Plugin-Warnungen | offen; kontrolliertes Upgrade-Fenster |

TW-MB-12 / TASKPLAN 946 ist der Dokumentationsabgleich vom 2026-07-19 und wird
nicht als neue Produktfunktion gewertet.

## Langfristige Leitplanken

MediaBrain bleibt lokal, offline-first, modular und datenschutzfreundlich. Windows
ist die Desktop-Hauptplattform. Flutter ist eine eigenständige Mobile-Linie; der
Web/PWA-Companion bleibt read-mostly. Cloud- oder Server-Synchronisierung ist keine
Voraussetzung für den aktuellen Desktop-, Flutter- oder Companion-Stand.
