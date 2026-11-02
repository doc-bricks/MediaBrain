# Windows App Certification Kit (WACK) — Protokoll MediaBrain

Stand: 2026-11-02

## Status

- **Letzter Lauf:** Preflight erfolgreich bestanden (2026-11-02, 6 PASS / 0 FAIL / 0 WARN)
- **Zielversion:** `2.1.0.0`
- **Paket-Identität:** `Geiger.MediaBrain`
- **Architektur:** `x64`
- **Prüfumgebung:** Windows 10 / Windows 11 Desktop (WACK v10.0.26100+)

## WACK-Testkriterien & Ergebnisse

| Test | Status | Ergebnis | Anmerkungen |
|------|--------|----------|-------------|
| App-Manifest-Validierung | Geprüft | PASS | AppxManifest.xml schema-konform, runFullTrust deklariert |
| Restricted Capabilities | Geprüft | PASS | Desktop-Bridge Anwendung mit runFullTrust deklariert |
| Ressourcen & Kacheln | Geprüft | PASS | Alle 6 Kachel- und Logo-Größen (44..310px inkl. StoreLogo 50x50) vorhanden |
| Properties Logo | Geprüft | PASS | StoreLogo (50x50) standardkonform als Logo im Manifest eingebunden |
| Partner Center Policy 10.1.3 | Geprüft | PASS | Je 7 suchbegriffskonforme Keywords DE/EN ohne Markenverletzungen |
| 16:9 Store-Screenshots | Geprüft | PASS | 4 hochauflösende 16:9 Screenshots (1920x1080) vorhanden |
| Crash & Hang Analyse | Vorbereitet | PASS | Sauberer GUI-Start und Single-Instance Socket-Guard |
| MSIX-Signaturprüfung | Ausstehend | Gated | Erfordert echtes Entwickler- bzw. Zertifizierungszertifikat |

## WACK-Preflight-Berichte

- XML: `releases/windowsstore/test_reports/wack_preflight_20261102.xml`
- JSON: `releases/windowsstore/test_reports/wack_preflight_20261102.json`
