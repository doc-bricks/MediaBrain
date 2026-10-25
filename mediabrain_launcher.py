from __future__ import annotations

import ctypes
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from translator import TranslationSystem, resolve_language


APP_NAME = "MediaBrain"
SCRIPT_NAME = "MediaBrain.py"


def _project_dir() -> Path:
    if getattr(sys, "frozen", False):
        exe_dir = Path(sys.executable).resolve().parent
        if (exe_dir / SCRIPT_NAME).exists():
            return exe_dir
        if exe_dir.name.lower() == "dist" and (exe_dir.parent / SCRIPT_NAME).exists():
            return exe_dir.parent
        return exe_dir
    return Path(__file__).resolve().parent


def _translation_system(base_dir: Path):
    saved_language = "de"
    settings_path = base_dir / "settings.json"
    try:
        settings = json.loads(settings_path.read_text(encoding="utf-8"))
        saved_language = settings.get("ui", {}).get("language", "de")
    except (OSError, ValueError, AttributeError):
        pass
    language = resolve_language(os.environ.get("MEDIABRAIN_LANG"), saved_language)
    return TranslationSystem(
        language,
        app_dir=base_dir,
        auto_register_missing=False,
    )


def _show_error(message: str, translator=None) -> None:
    try:
        ctypes.windll.user32.MessageBoxW(0, message, APP_NAME, 0x10)
    except Exception:
        print(message, file=sys.stderr)


def _python_command() -> list[str] | None:
    for candidate in ("pythonw.exe", "python.exe"):
        resolved = shutil.which(candidate)
        if resolved:
            return [resolved]
    launcher = shutil.which("py.exe") or shutil.which("py")
    if launcher:
        return [launcher, "-3"]
    return None


def main() -> int:
    base_dir = _project_dir()
    translator = _translation_system(base_dir)
    app_script = base_dir / SCRIPT_NAME
    if not app_script.exists():
        _show_error(translator.t("{script} wurde nicht gefunden:\n{path}", script=SCRIPT_NAME, path=app_script), translator)
        return 1

    python_cmd = _python_command()
    if not python_cmd:
        _show_error(
            translator.t(
                "Python wurde nicht gefunden.\nBitte Python 3.10+ installieren und die Abhängigkeiten aus requirements.txt einrichten."
            ),
            translator,
        )
        return 1

    creationflags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    try:
        subprocess.Popen(
            python_cmd + [str(app_script)],
            cwd=str(base_dir),
            creationflags=creationflags,
        )
    except FileNotFoundError as exc:
        _show_error(translator.t("Start fehlgeschlagen:\n{error}", error=exc), translator)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
