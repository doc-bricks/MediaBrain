# Portierungsplan MediaBrain

Stand: 2026-05-24

## Ergebnis des Checks

Für MediaBrain gab es bisher keinen eigenständigen Portierungsplan. Vorhanden sind jedoch drei wichtige Grundlagen:

- Die Desktop-App läuft als PySide6-Anwendung mit lokaler SQLite-Datenbank.
- README und Roadmap nennen bereits Windows, Linux und macOS als mögliche Laufzeitumgebungen.
- JSON-Export und -Import sind vorhanden und enthalten Medien, Tags und Playlists.

Die sinnvolle Plattformstrategie ist deshalb kein vollständiger Mobile-Clone. MediaBrain soll als Desktop-Zentrale erhalten bleiben; Web, Android und iOS bekommen zuerst einen schlanken Web/PWA-Companion über ein stabiles Austauschformat.

## Begründung

MediaBrain lebt von lokalen Desktop-Funktionen: aktives Fenster erkennen, lokale Dateien indexieren, Explorer-/Dateiaktionen ausführen und optionale Tray-Nutzung. Diese Funktionen sind auf Android, iOS und im Browser nur eingeschränkt oder gar nicht verfügbar.

Gleichzeitig ist der mobile Bedarf real: Watchlists, Favoriten, Playlists, Tags und zuletzt gesehene Medien werden häufig auf dem Sofa, unterwegs oder auf einem zweiten Gerät geprüft. Dafür reicht ein Companion, der die Desktop-Bibliothek importiert, filtert und später Änderungen wieder exportiert. Das reduziert Aufwand und Risiko, ohne den Nutzen der Plattformerweiterung zu verlieren.

## Zielbild

- Desktop bleibt die autoritative Offline-First-Zentrale.
- Windows Store ist der primäre öffentliche Desktop-Kanal.
- macOS und Linux werden als Smoke-Test- und Build-Ziele aus derselben PySide6-Codebasis geführt.
- Web/PWA ist die gemeinsame Linie für Browser, Android und iOS.
- Native Android- oder iOS-Apps werden erst geprüft, wenn der PWA-Companion echten Nutzungsbedarf zeigt.
- Austausch zwischen Desktop und Companion läuft über `mediabrain-library-v1.json`.

## Plattformbewertung

| Plattform | Entscheidung | Begründung | Nächster Schritt |
|---|---|---|---|
| Windows Store | Ja, primärer Desktop-Kanal | PySide6 und MIT-Lizenz sind Store-tauglich; MediaBrain ist bereits ein Desktop-Produkt | Store-Screenshots, Store-Listing und Lizenzhinweise final prüfen |
| Android | PWA zuerst, keine native App jetzt | Mobile Nutzung ist sinnvoll, aber lokale Desktop-Watcher sind nicht portierbar | PWA auf Android mit Import/Filter/Favoriten testen |
| Webapp | Ja, bevorzugte Companion-Linie | Ein Web-Companion kann denselben Codepfad für Desktop-Browser, Android und iOS bedienen | Minimalen Import-Viewer für `mediabrain-library-v1.json` planen |
| iOS | PWA zuerst | Native iOS-Entwicklung hätte hohen Aufwand und keinen Zugriff auf Desktop-Integrationen | Safari-PWA-Installierbarkeit und Offline-Cache prüfen |
| Mac App | P3-Smoke-Ziel | PySide6 ist grundsätzlich möglich; Dateisystem- und Tray-Verhalten müssen geprüft werden | Start- und Import/Export-Smoke auf macOS dokumentieren |
| Linux Version | P3-Smoke-Ziel | PySide6 und lokale SQLite-Datenhaltung passen; Tray/Dateiöffner können abweichen | Source-Start, Import/Export und Dateipfade unter Linux testen |

## Umsetzungslinie

### Phase 0: Austauschformat stabilisieren

Das bestehende JSON-Exportformat wird als `mediabrain-library-v1.json` stabilisiert. Die aktuelle Exportlogik enthält bereits Medien, Tags, Playlists und stabile Medienreferenzen. Offen ist eine dokumentierte Schemagarantie mit `schema_version`, `app_version`, optionalen Capabilities und klaren Kompatibilitätsregeln.

### Phase 1: Windows Store vorbereiten

MediaBrain bleibt Windows-first. Vor der Store-Einreichung müssen Store-Screenshots, Store-Listing, Datenschutz-/Support-URLs, MSIX/WACK und die Lizenzdarstellung konsistent sein. Aktuell sollte zusätzlich geprüft werden, ob README und zentrale Pipeline denselben Lizenzstand nennen.

### Phase 2: Web/PWA-Companion

Der Companion startet als reine Import-Anwendung:

- JSON-Datei laden
- Bibliothek durchsuchen und filtern
- Favoriten, Tags und Playlists anzeigen
- Offline über IndexedDB speichern
- später optional Änderungen als Delta oder vollständigen Export zurückgeben

Nicht in den ersten Companion gehören automatische Desktop-Erkennung, lokale Dateiaktionen, Provider-Scraping oder Hintergrund-Watcher.

### Phase 3: Mobile und Desktop-Smokes

Android und iOS werden über die PWA getestet. Native Apps bleiben zurückgestellt. macOS und Linux erhalten nur Smoke-Tests aus derselben Desktop-Codebasis, bis konkrete Nachfrage oder Paketierungsgründe entstehen.

## Offene Risiken

- Desktop-Funktionen wie WindowWatcher, Tray und Dateiaktionen sind nicht 1:1 mobil oder im Browser abbildbar.
- Ein bidirektionaler Sync kann Konflikte erzeugen; für den Start ist Import/Export sicherer als Live-Sync.
- Store-Readiness hängt neben der Plattformstrategie weiterhin an Listing, Screenshots, Paketierung und konsistenter Lizenzdokumentation.
