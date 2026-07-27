"""Render redacted Microsoft Store screenshots from temporary demo data.

The generator never reads the user's MediaBrain database or settings.  It starts
the real PySide6 window against a temporary SQLite database populated only with
synthetic entries, then captures four representative product views.
"""

from __future__ import annotations

import argparse
import os
import sys
import tempfile
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from PySide6.QtGui import QFont, QFontDatabase
from PySide6.QtWidgets import QApplication

import config
from core import BlacklistManager, Database, MediaManager, TagManager
from gui import MainWindow
from playlists import PlaylistManager


DEFAULT_OUTPUT = ROOT / "screenshots" / "store"
SCREENSHOT_VIEWS = (
    ("overview.png", "dashboard"),
    ("library.png", "movie"),
    ("favorites.png", "favorites"),
    ("statistics.png", "stats_view"),
)
WINDOW_SIZE = (1366, 768)
WINDOWS_UI_FONT = Path(r"C:\Windows\Fonts\segoeui.ttf")


def _add_demo_items(manager: MediaManager) -> None:
    demo_items = (
        {
            "title": "Beispiel-Film: Abendkino",
            "type": "movie",
            "source": "demo",
            "provider_id": "store-demo-movie",
            "description": "Synthetischer Store-Screenshot ohne persönliche Medien.",
            "is_favorite": True,
        },
        {
            "title": "Beispiel-Serie: Wochenendfolge",
            "type": "series",
            "source": "demo",
            "provider_id": "store-demo-series",
            "description": "Demo-Eintrag für die lokale Medienübersicht.",
        },
        {
            "title": "Beispiel-Album: Ruhiger Morgen",
            "type": "music",
            "source": "demo",
            "provider_id": "store-demo-music",
            "artist": "MediaBrain Demo",
            "album": "Beispieldaten",
        },
        {
            "title": "Beispiel-Dokument: Leseliste",
            "type": "document",
            "source": "demo",
            "provider_id": "store-demo-document",
            "description": "Kein lokaler Pfad und keine privaten Metadaten.",
        },
    )
    for item in demo_items:
        manager.add_or_update(item)
    manager.db.execute(
        "UPDATE media_items SET is_favorite = 1 WHERE provider_id = ?",
        ("store-demo-movie",),
    )


def render(output_dir: Path) -> tuple[Path, ...]:
    """Create the complete Store screenshot set and return its paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    app = QApplication.instance() or QApplication(["mediabrain-store-screenshots"])
    if WINDOWS_UI_FONT.is_file():
        font_id = QFontDatabase.addApplicationFont(str(WINDOWS_UI_FONT))
        font_families = QFontDatabase.applicationFontFamilies(font_id)
        if font_families:
            app.setFont(QFont(font_families[0], 10))

    original_settings_path = config.SETTINGS_PATH
    original_config = config.config
    try:
        with tempfile.TemporaryDirectory(prefix="mediabrain-store-") as temp_dir:
            temp_root = Path(temp_dir)
            config.SETTINGS_PATH = temp_root / "settings.json"
            config.config = config.Config()
            config.config.set("ui.system_tray", False)
            config.config.set("ui.window_width", WINDOW_SIZE[0])
            config.config.set("ui.window_height", WINDOW_SIZE[1])

            database = Database(temp_root / "demo.db")
            manager = MediaManager(database)
            _add_demo_items(manager)
            window = MainWindow(
                manager,
                BlacklistManager(database),
                TagManager(database),
                PlaylistManager(database.conn),
            )
            window.resize(*WINDOW_SIZE)
            window.show()
            app.processEvents()
            try:
                captured: list[Path] = []
                for filename, view_name in SCREENSHOT_VIEWS:
                    if view_name == "movie":
                        window._switch_library_type("movie")
                    else:
                        window._switch_view(getattr(window, view_name))
                    app.processEvents()
                    destination = output_dir / filename
                    if not window.grab().save(str(destination), "PNG"):
                        raise RuntimeError(
                            f"Screenshot konnte nicht geschrieben werden: {destination}"
                        )
                    captured.append(destination)
                return tuple(captured)
            finally:
                window.close()
                window.deleteLater()
                app.processEvents()
                database.close()
    finally:
        config.SETTINGS_PATH = original_settings_path
        config.config = original_config


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    for path in render(args.output):
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
