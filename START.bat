@echo off
cd /d "%~dp0"
set "APP_EXE=%~dp0dist\MediaBrain.exe"
if exist "%APP_EXE%" (
    start "" "%APP_EXE%"
    exit /b 0
)

if exist "%~dp0MediaBrain.exe" (
    start "" "%~dp0MediaBrain.exe"
    exit /b 0
)

python "MediaBrain.py"
if errorlevel 1 pause
