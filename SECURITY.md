# Security Policy / Sicherheitsrichtlinie

## Supported Versions

| Version | Supported |
| ------- | --------- |
| latest  | yes       |

## Reporting a Vulnerability

Please do not open public issues for security vulnerabilities.

1. Use GitHub private vulnerability reporting when available.
2. Include the affected version, reproduction steps, expected impact, and any relevant logs.
3. Do not include real API keys, private media paths, or personal database exports in the report.

Security fixes are documented in the changelog or release notes once they are available.

## Sicherheitslücken melden

Bitte öffnen Sie für Sicherheitslücken kein öffentliches Issue.

1. Nutzen Sie GitHubs private Vulnerability-Reporting-Funktion, sofern verfügbar.
2. Nennen Sie betroffene Version, Reproduktionsschritte, mögliche Auswirkungen und relevante Logs.
3. Fügen Sie keine echten API-Keys, privaten Medienpfade oder persönlichen Datenbankexporte ein.

Sicherheitskorrekturen werden im Changelog oder in den Release Notes dokumentiert, sobald sie verfügbar sind.

## Scope / Geltungsbereich

- Lokale SQLite-Datenbanken und Konfigurationsdateien
- Optionale TMDb-/OMDb-Metadatenabfragen
- MusicBrainz-Abfragen ohne API-Key
- Clipboard-, Playlist-, Such- und Dateiöffnungsfunktionen
