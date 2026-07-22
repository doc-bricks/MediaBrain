@echo off
cd /d "%~dp0"
set PYTHONIOENCODING=utf-8
set "LOCAL_BUILD_ROOT=C:\_Local_DEV\codex_build\mediabrain"
set "LOCAL_BUILD=%LOCAL_BUILD_ROOT%\build"
set "LOCAL_DIST=%LOCAL_BUILD_ROOT%\dist"
set "SCANNER=%~dp0..\..\_tools\build_exclude_scanner.py"

python --version >nul 2>&1
if errorlevel 1 (
    echo [FEHLER] Python wurde nicht gefunden. Bitte Python 3.10+ installieren.
    pause
    exit /b 1
)

python -c "import PyInstaller" >nul 2>&1
if errorlevel 1 (
    echo [FEHLER] PyInstaller ist nicht installiert.
    echo Bitte ausfuehren: python -m pip install pyinstaller
    pause
    exit /b 1
)

echo [INFO] Bereinige alte Build-Artefakte...
powershell -NoProfile -Command "Remove-Item -LiteralPath '%LOCAL_BUILD_ROOT%' -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force -Path '%LOCAL_BUILD%','%LOCAL_DIST%' | Out-Null"

set "EXCLUDES="
if exist "%SCANNER%" (
    echo [INFO] Ermittle PyInstaller-Excludes...
    for /f "delims=" %%E in ('python "%SCANNER%" --project "%~dp0" --emit pyinstaller 2^>nul') do set "EXCLUDES=%%E"
) else (
    echo [HINWEIS] Zentraler Exclude-Scanner nicht gefunden; Build laeuft ohne optionale Excludes.
)

REM FIX 2026-06-27: Entry von mediabrain_launcher.py auf MediaBrain.py geaendert,
REM damit das Haupt-Script direkt ins Bundle kommt (EXE startet eigenstaendig).
echo [INFO] Baue MediaBrain.exe (Entry: MediaBrain.py)...
python -m PyInstaller ^
  --noconfirm ^
  --clean ^
  --onefile ^
  --windowed ^
  --name MediaBrain ^
  --workpath "%LOCAL_BUILD%" ^
  --distpath "%LOCAL_DIST%" ^
  --specpath "%LOCAL_BUILD_ROOT%" ^
  --icon "%cd%\MediaBrain.ico" ^
  --noupx ^
  %EXCLUDES% ^
  MediaBrain.py

if errorlevel 1 (
    echo [FEHLER] PyInstaller-Build fehlgeschlagen.
    pause
    exit /b 1
)

echo.
echo [OK] Build fertig: %LOCAL_DIST%\MediaBrain.exe
echo [HINWEIS] Das eigenstaendige EXE-Artefakt bleibt ausserhalb von OneDrive.
