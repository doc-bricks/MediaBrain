@echo off
cd /d "%~dp0"
set PYTHONIOENCODING=utf-8
set "LOCAL_BUILD_ROOT=C:\_Local_DEV\codex_build\mediabrain"
set "LOCAL_BUILD=%LOCAL_BUILD_ROOT%\build"
set "LOCAL_DIST=%LOCAL_BUILD_ROOT%\dist"

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
powershell -NoProfile -Command "Remove-Item -LiteralPath '%LOCAL_BUILD_ROOT%' -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force -Path '%LOCAL_BUILD%','%LOCAL_DIST%' | Out-Null; Remove-Item -LiteralPath 'dist\MediaBrain.exe','MediaBrain.exe' -Force -ErrorAction SilentlyContinue"

echo [INFO] Baue MediaBrain.exe als Windows-Launcher...
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
  mediabrain_launcher.py

if errorlevel 1 (
    echo [FEHLER] PyInstaller-Build fehlgeschlagen.
    pause
    exit /b 1
)

if not exist "dist" mkdir "dist"
copy /Y "%LOCAL_DIST%\MediaBrain.exe" "dist\MediaBrain.exe" >nul
copy /Y "%LOCAL_DIST%\MediaBrain.exe" "MediaBrain.exe" >nul

echo.
echo [OK] Build fertig: dist\MediaBrain.exe
echo [HINWEIS] Der Launcher erwartet eine lokale Python-Umgebung mit den Abhaengigkeiten aus requirements.txt.
