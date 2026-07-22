# MediaBrain Mobile — Sync-Anleitung

Drei Wege, deinen Medien-Verlauf zwischen Geräten zu pflegen:

## 1. Auto-Scan (Standalone, ohne Sync)

**Scan-Tab → "Medien-Apps scannen"**

Findet installierte Medien-Apps (Streaming, Musik, Podcasts, Hörbücher,
Dokumente — 30+ bekannte Apps) und ihre Foreground-Zeit der letzten
30 Tage, schreibt sie als Einträge in die Bibliothek.

Permission: Special-Access `PACKAGE_USAGE_STATS` (führt die App durch).

## 2. Manuell erfassen

**Bibliothek → "+ Eintrag"**

Voller Editor: Titel, Kategorie (8 Typen), Künstler, Album, Kanal,
Beschreibung, Tags, Favorit-Toggle. Für Filme/Serien/Bücher, die nicht
aus einer App stammen.

## 3. Datei-Sync (für sporadischen Abgleich)

**Einstellungen → Datei-Sync**

- **Export per Share** schreibt eine `mediabrain-library-YYYY-MM-DD.json`
  und öffnet das System-Share-Sheet.
- **Import-Datei wählen** überschreibt den lokalen Stand.

Schema: `mediabrain-library-v1`.

## 4. Server-Sync (Mac Studio, 24/7)

**Einstellungen → Server-Sync (Mac Studio)**

Konfiguration:
- **Server-URL**: `https://macstudvonlukas.tail761bc7.ts.net:8443`
- **Bearer-Token**: aus `~/services/syncbox/token`

Buttons:
- **Push** → Server
- **Pull** ← Server

Der Server-Sync akzeptiert ausschließlich HTTPS. Push und Pull laufen nur nach
bewusster Betätigung der jeweiligen Schaltfläche; der Hintergrund-Scan überträgt
keine Bibliotheksdaten. Last-write-wins. Server-Setup: siehe SyncBox-README.
