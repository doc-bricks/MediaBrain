"""
gui_dialogs.py - Barrierefreie Dialoge für MediaBrain (WCAG 2.1 AA / BITV 2.0)
=============================================================================
Enthält:
- ShortcutsDialog: Tastaturkürzel- und Navigationsübersicht mit Suchfilter
- AboutDialog: Programminformationen, Lizenz, Local-First Reassurance & A11y
"""

from pathlib import Path
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont
from PySide6.QtWidgets import (
    QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,
    QPushButton, QTreeWidget, QTreeWidgetItem, QFrame,
    QHeaderView
)

from version import __version__
from translator import TranslationSystem

ROOT = Path(__file__).resolve().parent
_translator = TranslationSystem("de", app_dir=ROOT)


class ShortcutsDialog(QDialog):
    """Barrierefreier Dialog für Tastaturkürzel und Navigationshilfen (WCAG 2.1 AA / BITV 2.0)."""

    SHORTCUT_GROUPS = [
        (
            "Navigation & Ansichten",
            [
                ("Übersicht (Dashboard)", "Strg+1", "Wechselt zur Start- und Hauptübersicht"),
                ("Filme", "Strg+2", "Öffnet die Film-Bibliothek"),
                ("Serien", "Strg+3", "Öffnet die Serien-Bibliothek"),
                ("Musik", "Strg+4", "Öffnet die Musik-Bibliothek"),
                ("Clips", "Strg+5", "Öffnet die Clip-Bibliothek"),
                ("Favoriten", "Strg+6", "Zeigt alle favorisierten Medien an"),
                ("Blacklist", "Strg+7", "Öffnet die Ausschluss- und Blacklist-Verwaltung"),
                ("Statistiken", "Strg+8", "Öffnet die Medien- und Nutzungsstatistiken"),
                ("Playlists", "Strg+9", "Öffnet die Wiedergabelisten (Smart & Manuell)"),
                ("Globale Suche", "Strg+F", "Fokussiert das Medien- und Suchfeld"),
                ("Nächste Ansicht", "Strg+Tab", "Wechselt zyklisch zur nächsten Ansicht"),
                ("Vorherige Ansicht", "Strg+Umschalt+Tab", "Wechselt zyklisch zur vorherigen Ansicht"),
            ]
        ),
        (
            "Aktionen & Datenverwaltung",
            [
                ("Ansicht aktualisieren", "F5", "Aktualisiert die aktive Bibliotheksansicht"),
                ("Bibliothek exportieren", "Strg+E", "Exportiert die Bibliothek als JSON-Datei"),
                ("Bibliothek importieren", "Strg+O", "Importiert Medien und Playlists aus JSON"),
            ]
        ),
        (
            "Einstellungen & System",
            [
                ("Einstellungen", "Strg+,", "Öffnet das Einstellungsfenster"),
                ("Vollbild umschalten", "F11", "Schaltet den Vollbildmodus ein oder aus"),
                ("Anwendung beenden", "Strg+Q", "Beendet MediaBrain ordnungsgemäß"),
                ("Fenster schließen", "Alt+F4", "Schließt das Anwendungsfenster"),
            ]
        ),
        (
            "Hilfe & Barrierefreiheit",
            [
                ("Tastaturkürzel & Hilfe", "F1", "Öffnet diese Tastenkombinationsübersicht"),
                ("Über MediaBrain", "Umschalt+F1", "Zeigt Version, Lizenz und Barrierefreiheitsdeklaration"),
                ("Dialog schließen", "Esc", "Schließt den aktuellen Dialog"),
            ]
        ),
    ]

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle(_translator.t("Tastaturkürzel & Barrierefreiheit"))
        self.setAccessibleName("Tastaturkürzel und Barrierefreiheit")
        self.setAccessibleDescription("Übersicht aller verfügbaren Tastenkombinationen und Navigationsbefehle in MediaBrain")
        self.setModal(True)
        self.resize(680, 520)

        layout = QVBoxLayout(self)
        layout.setSpacing(10)
        layout.setContentsMargins(16, 16, 16, 16)

        # Header
        header_label = QLabel(_translator.t("Tastaturkürzel & Barrierefreiheit"))
        header_font = QFont()
        header_font.setPointSize(13)
        header_font.setBold(True)
        header_label.setFont(header_font)
        header_label.setAccessibleName("Dialogtitel: Tastaturkürzel und Barrierefreiheit")
        layout.addWidget(header_label)

        sub_label = QLabel("Vollständige Tastatur- und Screenreader-Steuerung für MediaBrain (WCAG 2.1 AA / BITV 2.0).")
        sub_label.setWordWrap(True)
        sub_label.setStyleSheet("color: #666;")
        layout.addWidget(sub_label)

        # Filter
        filter_layout = QHBoxLayout()
        filter_label = QLabel(_translator.t("Filter:"))
        filter_label.setAccessibleName("Suchfilter Beschriftung")
        self.filter_edit = QLineEdit()
        self.filter_edit.setPlaceholderText("Tastaturkürzel durchsuchen (z. B. Strg, Ansicht, Export)...")
        self.filter_edit.setAccessibleName("Tastaturkürzel Suchfeld")
        self.filter_edit.setAccessibleDescription("Tippen Sie hier, um Tastenkombinationen nach Aktion oder Taste zu filtern")
        self.filter_edit.textChanged.connect(self._filter_shortcuts)
        filter_layout.addWidget(filter_label)
        filter_layout.addWidget(self.filter_edit)
        layout.addLayout(filter_layout)

        # Tree
        self.tree = QTreeWidget()
        self.tree.setHeaderLabels(["Aktion / Funktion", "Tastenkombination", "Beschreibung"])
        self.tree.setAccessibleName("Tastaturkürzel Tabelle")
        self.tree.setAccessibleDescription("Hierarchische Übersicht aller Tastenkürzel gegliedert nach Funktionsbereichen")
        self.tree.setAlternatingRowColors(True)
        self.tree.header().setSectionResizeMode(0, QHeaderView.ResizeMode.ResizeToContents)
        self.tree.header().setSectionResizeMode(1, QHeaderView.ResizeMode.ResizeToContents)
        self.tree.header().setSectionResizeMode(2, QHeaderView.ResizeMode.Stretch)

        self._populate_tree()
        layout.addWidget(self.tree)

        # Buttons
        btn_layout = QHBoxLayout()
        btn_layout.addStretch()
        self.btn_close = QPushButton(_translator.t("Schließen"))
        self.btn_close.setAccessibleName("Dialog schließen")
        self.btn_close.setAccessibleDescription("Schließt die Tastaturkürzel-Übersicht")
        self.btn_close.setDefault(True)
        self.btn_close.clicked.connect(self.accept)
        btn_layout.addWidget(self.btn_close)
        layout.addLayout(btn_layout)

        self.filter_edit.setFocus()

    def _populate_tree(self):
        self.tree.clear()
        for group_name, items in self.SHORTCUT_GROUPS:
            group_item = QTreeWidgetItem(self.tree)
            group_item.setText(0, group_name)
            font = QFont()
            font.setBold(True)
            group_item.setFont(0, font)
            group_item.setExpanded(True)
            for action, key, desc in items:
                child = QTreeWidgetItem(group_item)
                child.setText(0, action)
                child.setText(1, key)
                child.setText(2, desc)
                font_key = QFont()
                font_key.setBold(True)
                child.setFont(1, font_key)

    def _filter_shortcuts(self, text: str):
        query = text.strip().lower()
        for i in range(self.tree.topLevelItemCount()):
            group_item = self.tree.topLevelItem(i)
            group_matches = query in group_item.text(0).lower()
            visible_children = 0
            for j in range(group_item.childCount()):
                child = group_item.child(j)
                matches = (
                    group_matches
                    or query in child.text(0).lower()
                    or query in child.text(1).lower()
                    or query in child.text(2).lower()
                )
                child.setHidden(not matches)
                if matches:
                    visible_children += 1
            group_item.setHidden(visible_children == 0 and not group_matches)
            if visible_children > 0 or group_matches:
                group_item.setExpanded(True)

    def keyPressEvent(self, event):
        if event.key() == Qt.Key.Key_Escape:
            self.accept()
            return
        super().keyPressEvent(event)


class AboutDialog(QDialog):
    """Barrierefreier Programminformations- und A11y-Dialog für MediaBrain."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle(_translator.t("Über MediaBrain"))
        self.setAccessibleName("Über MediaBrain")
        self.setAccessibleDescription("Programminformationen, Lizenz, Datenschutz und Barrierefreiheitsdeklaration von MediaBrain")
        self.setModal(True)
        self.resize(540, 440)

        layout = QVBoxLayout(self)
        layout.setSpacing(12)
        layout.setContentsMargins(18, 18, 18, 18)

        # Title
        title_label = QLabel(f"MediaBrain v{__version__}")
        font = QFont()
        font.setPointSize(14)
        font.setBold(True)
        title_label.setFont(font)
        title_label.setAccessibleName(f"Anwendungsname MediaBrain Version {__version__}")
        layout.addWidget(title_label)

        sub_label = QLabel("Lokale Medienverwaltung, Video- & Musik-Bibliothek und Streaming-Tracker")
        sub_label.setStyleSheet("color: #555; font-weight: 500;")
        layout.addWidget(sub_label)

        meta_label = QLabel("Autor & Entwickler: Lukas Geiger  •  Lizenz: GNU General Public License v3.0 (GPL-3.0)")
        meta_label.setStyleSheet("color: #777; font-size: 11px;")
        layout.addWidget(meta_label)

        # Card 1: Local-First / Zero-Egress Reassurance
        card1 = QFrame()
        card1.setFrameShape(QFrame.Shape.StyledPanel)
        card1.setStyleSheet("QFrame { background-color: rgba(91, 141, 217, 0.08); border: 1px solid rgba(91, 141, 217, 0.3); border-radius: 6px; padding: 10px; }")
        card1_layout = QVBoxLayout(card1)
        card1_title = QLabel("100% Local-First & Datenschutz (Zero-Egress)")
        card1_title.setStyleSheet("font-weight: bold; color: #2c5282;")
        card1_desc = QLabel(
            "MediaBrain speichert alle Mediendateien, Verläufe, Playlists und Metadaten ausschließlich "
            "in einer lokalen SQLite-Datenbank auf Ihrem Rechner. Es erfolgt keinerlei unautorisierte "
            "Übertragung Ihrer persönlichen Daten an Cloud-Dienste."
        )
        card1_desc.setWordWrap(True)
        card1_layout.addWidget(card1_title)
        card1_layout.addWidget(card1_desc)
        layout.addWidget(card1)

        # Card 2: Accessibility & Ergonomie
        card2 = QFrame()
        card2.setFrameShape(QFrame.Shape.StyledPanel)
        card2.setStyleSheet("QFrame { background-color: rgba(72, 187, 120, 0.08); border: 1px solid rgba(72, 187, 120, 0.3); border-radius: 6px; padding: 10px; }")
        card2_layout = QVBoxLayout(card2)
        card2_title = QLabel("Barrierefreiheit & Zugänglichkeit (WCAG 2.1 AA / BITV 2.0)")
        card2_title.setStyleSheet("font-weight: bold; color: #22543d;")
        card2_desc = QLabel(
            "Entwickelt nach Barrierefreiheitsstandards: Vollständige Tastaturbedienung über Menüs und "
            "Tastenkombinationen (F1), strukturierte Screenreader-Namen, Tastaturfokus-Indikatoren "
            "und Theme-Optionen für optimale Lesbarkeit."
        )
        card2_desc.setWordWrap(True)
        card2_layout.addWidget(card2_title)
        card2_layout.addWidget(card2_desc)
        layout.addWidget(card2)

        layout.addStretch()

        # Buttons
        btn_layout = QHBoxLayout()
        self.btn_shortcuts = QPushButton(_translator.t("Tastaturkürzel (F1)"))
        self.btn_shortcuts.setAccessibleName("Tastaturkürzel anzeigen")
        self.btn_shortcuts.setAccessibleDescription("Öffnet die Übersicht aller Tastenkürzel")
        self.btn_shortcuts.clicked.connect(self._open_shortcuts)
        btn_layout.addWidget(self.btn_shortcuts)

        btn_layout.addStretch()

        self.btn_close = QPushButton(_translator.t("Schließen"))
        self.btn_close.setAccessibleName("Dialog schließen")
        self.btn_close.setAccessibleDescription("Schließt das Infofenster")
        self.btn_close.setDefault(True)
        self.btn_close.clicked.connect(self.accept)
        btn_layout.addWidget(self.btn_close)

        layout.addLayout(btn_layout)

    def _open_shortcuts(self):
        self.accept()
        dlg = ShortcutsDialog(self.parent())
        dlg.exec()

    def keyPressEvent(self, event):
        if event.key() == Qt.Key.Key_Escape:
            self.accept()
            return
        super().keyPressEvent(event)
