# MediaBrain - Windows Store Build- & Packaging-Anleitung

## Voraussetzungen

1. Python 3.10+ mit PySide6
2. PyInstaller für den Desktop-EXE-Build
3. Windows 10/11 SDK mit makeappx.exe, signtool.exe und appcert.exe
4. Lokaler Schreibpfad außerhalb synchronisierter Cloud-Ordner, z. B. C:\_Local_DEV\codex_build\mediabrain-store

## Schritt 0: Store-Metadaten & Screenshots validieren

```powershell
Set-Location C:\_Local_DEV\repos\MediaBrain
python scripts\check_store_readiness.py
python scripts\run_windows_wack.py
```

Erwartetes Ergebnis:
- Alle Manifeste, Kacheln und Metadaten PASS (0 Fehler)
- WACK-Preflight-Report generiert unter releases\windowsstore\test_reports\

## Schritt 1: Desktop-EXE bauen

```powershell
pyinstaller --clean -y MediaBrain.spec
```

Erzeugt: dist\MediaBrain.exe

## Schritt 2: MSIX-Paket erstellen & signieren

```powershell
$outputDir = "C:\_Local_DEV\codex_build\mediabrain-store"
New-Item -ItemType Directory -Force -Path $outputDir
& "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe" pack /d store_package\MediaBrain /p "$outputDir\MediaBrain.msix"
```

Signieren mit Entwickler- oder Partner-Center-Zertifikat:
```powershell
& "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe" sign /fd SHA256 /a /f cert.pfx /p "$certPassword" "$outputDir\MediaBrain.msix"
```

## Schritt 3: Lokalen WACK-Test durchführen

```powershell
python scripts\run_windows_wack.py --msix "$outputDir\MediaBrain.msix"
```
