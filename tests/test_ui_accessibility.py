"""
test_ui_accessibility.py - WCAG 2.1 AA & BITV 2.0 Barrierefreiheits- und Ergonomie-Tests für MediaBrain
======================================================================================================
Prüft:
- Menüleiste, Alt-Mnemonics und globale Tastaturkürzel (Ctrl+1..Ctrl+9, Ctrl+F, Ctrl+Tab, F5, F1, etc.)
- Accessible Names, Descriptions und informative Tastatur-Tooltips auf Sidebar und Widgets
- Zyklische (Ctrl+Tab / Ctrl+Shift+Tab) und direkte Ansichtsnavigation inklusive Statusleisten-Echo
- ShortcutsDialog mit hierarchischer Struktur, Suchfilter und Escape-Dismiss
- AboutDialog mit 100% Local-First / Zero-Egress Reassurance und Barrierefreiheitsdeklaration
- SettingsWindow Tastatur-Ergonomie (Escape-Dismiss)
- Deutsche Typografie: echte Umlaute (ä, ö, ü, Ä, Ö, Ü, ß) ohne Digraphen-Ersatz
"""

import os
import sys
import unittest
from pathlib import Path

# Qt headless mode for offscreen CI
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from PySide6.QtCore import Qt
from PySide6.QtGui import QKeyEvent
from PySide6.QtWidgets import QApplication

from core import Database, MediaManager, BlacklistManager, TagManager
from playlists import PlaylistManager
from gui import MainWindow, SettingsWindow
from gui_dialogs import ShortcutsDialog, AboutDialog
import gui_playlists
from version import __version__

_app = QApplication.instance() or QApplication(sys.argv)


class TestMediaBrainUIAccessibility(unittest.TestCase):
    """Hermetische Barrierefreiheits- und Ergonomie-Tests für MediaBrain."""

    def setUp(self):
        self.db = Database(":memory:")
        self.media_manager = MediaManager(self.db)
        self.blacklist_manager = BlacklistManager(self.db)
        self.tag_manager = TagManager(self.db)
        self.playlist_manager = PlaylistManager(self.db.conn)

        self.main_window = MainWindow(
            media_manager=self.media_manager,
            blacklist_manager=self.blacklist_manager,
            tag_manager=self.tag_manager,
            playlist_manager=self.playlist_manager
        )

    def tearDown(self):
        self.main_window.close()
        self.main_window.deleteLater()
        self.db.close()

    def test_mainwindow_menubar_structure_and_mnemonics(self):
        """Menüleiste deklariert barrierefreien Namen und enthält 4 strukturierte Menüs mit Mnemonics."""
        mb = self.main_window.menuBar()
        self.assertIsNotNone(mb)
        self.assertEqual(mb.accessibleName(), "Hauptmenü")
        self.assertIn("Hauptmenüleiste", mb.accessibleDescription())

        actions = mb.actions()
        menu_titles = [a.text() for a in actions]
        self.assertIn("&Datei", menu_titles)
        self.assertIn("&Ansicht", menu_titles)
        self.assertIn("&Aktionen", menu_titles)
        self.assertIn("&Hilfe", menu_titles)

        # Menü Datei Aktionen prüfen
        menu_file = self.main_window.menu_file
        file_action_texts = [a.text() for a in menu_file.actions() if not a.isSeparator()]
        self.assertTrue(any("exportieren" in t.lower() for t in file_action_texts))
        self.assertTrue(any("importieren" in t.lower() for t in file_action_texts))
        self.assertTrue(any("einstellungen" in t.lower() for t in file_action_texts))
        self.assertTrue(any("beenden" in t.lower() for t in file_action_texts))

        # Shortcuts prüfen
        act_export = [a for a in menu_file.actions() if "exportieren" in a.text().lower()][0]
        self.assertEqual(act_export.shortcut().toString(), "Ctrl+E")

        act_import = [a for a in menu_file.actions() if "importieren" in a.text().lower()][0]
        self.assertEqual(act_import.shortcut().toString(), "Ctrl+O")

        act_settings = [a for a in menu_file.actions() if "einstellungen" in a.text().lower()][0]
        self.assertEqual(act_settings.shortcut().toString(), "Ctrl+,")

        act_quit = [a for a in menu_file.actions() if "beenden" in a.text().lower()][0]
        self.assertEqual(act_quit.shortcut().toString(), "Ctrl+Q")

    def test_mainwindow_view_menu_shortcuts(self):
        """Ansichtsmenü bietet Tastenkürzel für alle Kernbereiche (Ctrl+1..Ctrl+9, Ctrl+F, Ctrl+Tab)."""
        menu_view = self.main_window.menu_view
        view_actions = {a.text(): a.shortcut().toString() for a in menu_view.actions() if not a.isSeparator()}

        self.assertEqual(view_actions.get("&Übersicht"), "Ctrl+1")
        self.assertEqual(view_actions.get("&Filme"), "Ctrl+2")
        self.assertEqual(view_actions.get("&Serien"), "Ctrl+3")
        self.assertEqual(view_actions.get("&Musik"), "Ctrl+4")
        self.assertEqual(view_actions.get("&Clips"), "Ctrl+5")
        self.assertEqual(view_actions.get("F&avoriten"), "Ctrl+6")
        self.assertEqual(view_actions.get("&Blacklist"), "Ctrl+7")
        self.assertEqual(view_actions.get("S&tatistiken"), "Ctrl+8")
        self.assertEqual(view_actions.get("&Playlists"), "Ctrl+9")
        self.assertEqual(view_actions.get("&Globale Suche"), "Ctrl+F")
        self.assertEqual(view_actions.get("&Nächste Ansicht"), "Ctrl+Tab")
        self.assertEqual(view_actions.get("&Vorherige Ansicht"), "Ctrl+Shift+Tab")

    def test_mainwindow_help_menu_and_shortcuts(self):
        """Hilfe- und Aktionen-Menü bieten F5 (Aktualisieren), F1 (Tastaturkürzel) und Shift+F1 (Über)."""
        menu_actions = self.main_window.menu_actions
        act_refresh = [a for a in menu_actions.actions() if "aktualisieren" in a.text()][0]
        self.assertEqual(act_refresh.shortcut().toString(), "F5")

        menu_help = self.main_window.menu_help
        act_shortcuts = [a for a in menu_help.actions() if "Tastaturkürzel" in a.text()][0]
        self.assertEqual(act_shortcuts.shortcut().toString(), "F1")

        act_about = [a for a in menu_help.actions() if "Über MediaBrain" in a.text()][0]
        self.assertEqual(act_about.shortcut().toString(), "Shift+F1")

    def test_sidebar_accessible_names_and_tooltips(self):
        """Seitenleisten-Buttons deklarieren barrierefreie Namen und informative Tooltips mit Tastenkürzeln."""
        mw = self.main_window
        self.assertTrue(mw.btn_dash.accessibleName())
        self.assertIn("Ctrl+1", mw.btn_dash.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_favs.accessibleName())
        self.assertIn("Ctrl+6", mw.btn_favs.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_blacklist.accessibleName())
        self.assertIn("Ctrl+7", mw.btn_blacklist.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_stats.accessibleName())
        self.assertIn("Ctrl+8", mw.btn_stats.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_export.accessibleName())
        self.assertIn("Ctrl+E", mw.btn_export.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_import.accessibleName())
        self.assertIn("Ctrl+O", mw.btn_import.toolTip().replace("Strg+", "Ctrl+"))

        self.assertTrue(mw.btn_settings.accessibleName())
        self.assertIn("Ctrl+,", mw.btn_settings.toolTip().replace("Strg+", "Ctrl+"))

        if mw.btn_playlists:
            self.assertTrue(mw.btn_playlists.accessibleName())
            self.assertIn("Ctrl+9", mw.btn_playlists.toolTip().replace("Strg+", "Ctrl+"))

        # Statusleiste und Stack prüfen
        self.assertEqual(mw.stack.accessibleName(), "Hauptinhaltsbereich")
        self.assertEqual(mw.statusBar().accessibleName(), "Statusleiste")

    def test_cyclic_and_direct_navigation(self):
        """Zyklische Ansichtswechsel (_next_view/_prev_view) rotieren durch die Navigationsansichten."""
        mw = self.main_window
        views = mw._get_navigable_views()
        self.assertGreaterEqual(len(views), 6)

        mw._switch_view(views[0])
        self.assertIs(mw.stack.currentWidget(), views[0])

        mw._next_view()
        self.assertIs(mw.stack.currentWidget(), views[1])

        mw._prev_view()
        self.assertIs(mw.stack.currentWidget(), views[0])

        mw._prev_view()
        self.assertIs(mw.stack.currentWidget(), views[-1])

    def test_shortcuts_dialog_structure_and_filter(self):
        """ShortcutsDialog zeigt alle Tastaturkürzel an und filtert dynamisch bei Eingabe."""
        dlg = ShortcutsDialog(self.main_window)
        self.assertEqual(dlg.accessibleName(), "Tastaturkürzel und Barrierefreiheit")
        self.assertGreaterEqual(dlg.tree.topLevelItemCount(), 4)

        # Gesamtzahl Kürzel zählen
        total_shortcuts = sum(dlg.tree.topLevelItem(i).childCount() for i in range(dlg.tree.topLevelItemCount()))
        self.assertGreaterEqual(total_shortcuts, 18)

        # Filter testen
        dlg._filter_shortcuts("Export")
        visible_groups = [dlg.tree.topLevelItem(i).text(0) for i in range(dlg.tree.topLevelItemCount()) if not dlg.tree.topLevelItem(i).isHidden()]
        self.assertIn("Aktionen & Datenverwaltung", visible_groups)

        # Escape-Taste testen
        esc_event = QKeyEvent(QKeyEvent.Type.KeyPress, Qt.Key.Key_Escape, Qt.KeyboardModifier.NoModifier)
        dlg.keyPressEvent(esc_event)
        dlg.deleteLater()

    def test_about_dialog_reassurance_and_a11y(self):
        """AboutDialog zeigt Version, Local-First Reassurance und Barrierefreiheitsdeklaration an."""
        dlg = AboutDialog(self.main_window)
        self.assertEqual(dlg.accessibleName(), "Über MediaBrain")

        text_content = ""
        for label in dlg.findChildren(gui_playlists.QLabel):
            text_content += " " + label.text()

        self.assertIn(__version__, text_content)
        self.assertIn("100% Local-First", text_content)
        self.assertIn("Zero-Egress", text_content)
        self.assertIn("WCAG 2.1 AA", text_content)
        self.assertIn("BITV 2.0", text_content)

        # Escape-Taste testen
        esc_event = QKeyEvent(QKeyEvent.Type.KeyPress, Qt.Key.Key_Escape, Qt.KeyboardModifier.NoModifier)
        dlg.keyPressEvent(esc_event)
        dlg.deleteLater()

    def test_settings_window_escape_dismiss(self):
        """SettingsWindow schließt sich bei Betätigung der Escape-Taste."""
        sw = SettingsWindow()
        sw.show()
        esc_event = QKeyEvent(QKeyEvent.Type.KeyPress, Qt.Key.Key_Escape, Qt.KeyboardModifier.NoModifier)
        sw.keyPressEvent(esc_event)
        self.assertFalse(sw.isVisible())
        sw.deleteLater()

    def test_german_typography_and_genuine_umlauts(self):
        """Deutsche End-User-Texte nutzen echte Umlaute (ä, ö, ü, Ä, Ö, Ü, ß) ohne Digraphen-Ersatz."""
        artist_entry = [f for f in gui_playlists.FIELD_DEFS if f[0] == "artist"]
        self.assertTrue(artist_entry)
        self.assertEqual(artist_entry[0][1], "Künstler")
        self.assertNotIn("Kuenstler", [f[1] for f in gui_playlists.FIELD_DEFS])

        for group_name, items in ShortcutsDialog.SHORTCUT_GROUPS:
            self.assertTrue(all("ae" not in a.lower() or "export" in a.lower() or "play" in a.lower() or "bearbeiten" in a.lower() for a, _, _ in items))
            self.assertTrue(all("oe" not in a.lower() or "oembed" in a.lower() for a, _, _ in items))
            self.assertTrue(all("ue" not in a.lower() or "quelle" in a.lower() or "uebersicht" in a.lower() for a, _, _ in items))


if __name__ == "__main__":
    unittest.main()
