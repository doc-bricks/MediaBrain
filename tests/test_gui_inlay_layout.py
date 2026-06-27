"""Fail-first Regression für Qt-Layout-Bug: Inlay-Panels zu klein.

Bug (AUFGABEN.txt 2026-06-15): MediaItemWidget-Inlay-Panels (eingebettet
in DashboardView) zeigen abgeschnittene Icons und zu enge Buttons.

Dieser Test prüft die Mindestgrößen NACH dem Fix:
  - ICON_SIZE muss mindestens 44×44 px sein (war 36×36, kein Spielraum für Emoji-Glyphen)
  - ITEM_MIN_HEIGHT muss mindestens 64 px sein (war 56, zu wenig für Layout-Margins + fav_btn)
  - fav_btn muss mindestens 44×44 px sein (war 40×40 mit 24px-Schrift: kein Platz für Padding)
  - ACTION_BUTTON_MIN_SIZE-Höhe muss mindestens 40 px sein (war 36)

Der Test schlägt fehl, solange die alten Konstanten gelten, und wird grün nach dem Fix.
"""

import os
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

sys.path.insert(0, str(Path(__file__).parent.parent))

from PySide6.QtWidgets import QApplication

from gui import MediaItemWidget

_app = QApplication.instance() or QApplication(sys.argv)


def _make_item(**kwargs):
    defaults = dict(
        id=99,
        title="Inlay-Testfilm",
        type="movie",
        source="netflix",
        provider_id="nf-99",
        artist=None,
        year=2024,
        description=None,
        provider_subtype=None,
        is_favorite=False,
        thumbnail_url=None,
        local_path=None,
    )
    defaults.update(kwargs)
    return SimpleNamespace(**defaults)


class TestInlayPanelMinimumSizes(unittest.TestCase):
    """Prüft, dass Inlay-Widgets nach dem Qt-Layout-Fix ausreichend groß sind."""

    def setUp(self):
        item = _make_item()
        self.widget = MediaItemWidget(
            item,
            SimpleNamespace(db=MagicMock()),
            SimpleNamespace(set_blacklist=lambda *a: None),
        )

    def tearDown(self):
        self.widget.close()
        self.widget.deleteLater()
        _app.processEvents()

    def test_icon_container_wide_enough_for_emoji(self):
        """Typ-Icon-Label muss ≥44 px breit sein, damit Emoji-Glyphen nicht abgeschnitten werden."""
        self.assertGreaterEqual(
            self.widget.type_icon_label.minimumWidth(), 44,
            "ICON_SIZE-Breite zu klein — Emoji-Glyphen können abgeschnitten werden",
        )

    def test_icon_container_tall_enough_for_emoji(self):
        """Typ-Icon-Label muss ≥44 px hoch sein."""
        self.assertGreaterEqual(
            self.widget.type_icon_label.minimumHeight(), 44,
            "ICON_SIZE-Höhe zu klein — Emoji-Glyphen können abgeschnitten werden",
        )

    def test_widget_min_height_accommodates_all_children(self):
        """Gesamt-Widget-Mindesthöhe muss ≥64 px sein (fav_btn 44 + 2×10 px Margin)."""
        self.assertGreaterEqual(
            self.widget.minimumHeight(), 64,
            "ITEM_MIN_HEIGHT zu klein — Kinder-Widgets werden abgequetscht",
        )

    def test_fav_button_not_clipped(self):
        """Favoriten-Button mit 24px-Schrift muss ≥44×44 px sein, damit der Stern sichtbar bleibt."""
        self.assertGreaterEqual(
            self.widget.fav_btn.minimumWidth(), 44,
            "fav_btn zu schmal — Stern-Icon kann abgeschnitten sein",
        )
        self.assertGreaterEqual(
            self.widget.fav_btn.minimumHeight(), 44,
            "fav_btn zu niedrig — Stern-Icon kann abgeschnitten sein",
        )

    def test_action_buttons_tall_enough(self):
        """Aktions-Buttons (Öffnen / Details) müssen ≥40 px hoch sein."""
        self.assertGreaterEqual(
            self.widget.open_btn.minimumHeight(), 40,
            "open_btn Mindesthöhe zu klein",
        )
        self.assertGreaterEqual(
            self.widget.details_btn.minimumHeight(), 40,
            "details_btn Mindesthöhe zu klein",
        )

    def test_class_constants_reflect_minimum_requirements(self):
        """Klassenkonstanten müssen die erhöhten Mindestwerte deklarieren."""
        self.assertGreaterEqual(MediaItemWidget.ITEM_MIN_HEIGHT, 64)
        self.assertGreaterEqual(MediaItemWidget.ICON_SIZE.width(), 44)
        self.assertGreaterEqual(MediaItemWidget.ICON_SIZE.height(), 44)
        self.assertGreaterEqual(MediaItemWidget.ACTION_BUTTON_MIN_SIZE.height(), 40)


if __name__ == "__main__":
    unittest.main()
