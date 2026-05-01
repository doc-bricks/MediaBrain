"""GUI components for MediaBrain playlists.

Provides:
- SmartPlaylistDialog: Create/edit smart playlists via QueryBuilder JSON.
- ManualPlaylistDialog: Create/rename manual playlists (name + description).
- PlaylistsView: Sidebar-mounted view listing all playlists with item detail.

The dialogs operate on a PlaylistManager (see playlists.py) and a QueryBuilder
(see query_builder.py). They are PySide6-only and never touch the database
directly outside of the manager APIs.
"""

import json
import logging
from typing import Optional

from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex
from PySide6.QtGui import QAction
from PySide6.QtWidgets import (
    QApplication, QCheckBox, QComboBox, QDialog, QDialogButtonBox,
    QFormLayout, QFrame, QHBoxLayout, QInputDialog, QLabel, QLineEdit,
    QListView, QListWidget, QListWidgetItem, QMenu, QMessageBox,
    QPushButton, QScrollArea, QSizePolicy, QSpinBox, QSplitter,
    QStyledItemDelegate, QTextEdit, QVBoxLayout, QWidget,
)

from playlists import Playlist, PlaylistManager
from query_builder import FilterCondition, QueryBuilder

logger = logging.getLogger("MediaBrain.GUIPlaylists")


# ============================================================
# Field metadata used by the dialog UI
# ============================================================

# Operators grouped per category. The dialog filters operators per field type.
_OPS_TEXT = ["contains", "not_contains", "starts_with", "=", "!=",
             "is_empty", "is_not_empty"]
_OPS_NUMERIC = ["=", "!=", ">", ">=", "<", "<="]
_OPS_BOOLEAN = ["=", "!="]
_OPS_TIMESTAMP = [">", ">=", "<", "<=", "=", "!=",
                  "is_empty", "is_not_empty"]
_OPS_TAG = ["contains", "not_contains", "="]

# Field definitions: label, db field name, operator list, value widget kind.
# Values for media type and source come from observed values - the dialog also
# accepts free-text input via the editable ComboBox.
_TYPE_PRESETS = ["movie", "series", "music", "clip", "podcast",
                 "audiobook", "document"]
_SOURCE_PRESETS = ["netflix", "youtube", "spotify", "disney+", "prime",
                   "appletv+", "twitch", "local"]

FIELD_DEFS = [
    # (key, label, operator list, widget kind, presets-or-None)
    ("title",          "Titel",            _OPS_TEXT,      "text",   None),
    ("type",           "Typ",              _OPS_TEXT,      "combo",  _TYPE_PRESETS),
    ("source",         "Quelle (Provider)", _OPS_TEXT,     "combo",  _SOURCE_PRESETS),
    ("artist",         "Kuenstler",        _OPS_TEXT,      "text",   None),
    ("album",          "Album",            _OPS_TEXT,      "text",   None),
    ("channel",        "Kanal",            _OPS_TEXT,      "text",   None),
    ("description",    "Beschreibung",     _OPS_TEXT,      "text",   None),
    ("local_path",     "Lokaler Pfad",     _OPS_TEXT,      "text",   None),
    ("length_seconds", "Laenge (Sekunden)", _OPS_NUMERIC,  "number", None),
    ("season",         "Staffel",          _OPS_NUMERIC,   "number", None),
    ("episode",        "Episode",          _OPS_NUMERIC,   "number", None),
    ("favorite",       "Favorit",          _OPS_BOOLEAN,   "bool",   None),
    ("is_local_file",  "Lokale Datei",     _OPS_BOOLEAN,   "bool",   None),
    ("blacklisted",    "Auf Blacklist",    _OPS_BOOLEAN,   "bool",   None),
    ("created_at",     "Erstellt am",      _OPS_TIMESTAMP, "text",   None),
    ("last_watched",   "Zuletzt geoeffnet", _OPS_TIMESTAMP, "text",  None),
    ("tags",           "Tag",              _OPS_TAG,       "text",   None),
]

# Map UI key to the index in FIELD_DEFS for fast lookup.
_FIELD_BY_KEY = {row[0]: row for row in FIELD_DEFS}

# Order-by choices: every orderable field plus a "no order" entry.
_ORDER_FIELDS = [(key, label) for key, label, *_ in FIELD_DEFS
                 if key in QueryBuilder.ORDERABLE_FIELDS]


# ============================================================
# Single condition row widget
# ============================================================

class ConditionRow(QFrame):
    """A single editable filter condition."""

    def __init__(self, on_remove=None, parent=None):
        super().__init__(parent)
        self.setObjectName("ConditionRow")
        self.setFrameShape(QFrame.Shape.NoFrame)
        self._on_remove = on_remove

        layout = QHBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(6)
        self.setLayout(layout)

        self.conjunction_combo = QComboBox()
        self.conjunction_combo.addItems(["AND", "OR"])
        self.conjunction_combo.setFixedWidth(60)
        layout.addWidget(self.conjunction_combo)

        self.field_combo = QComboBox()
        for key, label, *_ in FIELD_DEFS:
            self.field_combo.addItem(label, key)
        self.field_combo.currentIndexChanged.connect(self._on_field_changed)
        layout.addWidget(self.field_combo, stretch=2)

        self.operator_combo = QComboBox()
        self.operator_combo.currentTextChanged.connect(self._on_operator_changed)
        layout.addWidget(self.operator_combo, stretch=2)

        # Value placeholder, replaced when field/operator changes.
        self.value_widget: QWidget = QLineEdit()
        layout.addWidget(self.value_widget, stretch=3)

        remove_btn = QPushButton("✕")
        remove_btn.setToolTip("Bedingung entfernen")
        remove_btn.setFixedWidth(28)
        remove_btn.clicked.connect(self._handle_remove)
        layout.addWidget(remove_btn)

        # Initial state matches first field.
        self._on_field_changed(0)

    def _handle_remove(self):
        if self._on_remove:
            self._on_remove(self)

    def _on_field_changed(self, _index):
        key = self.field_combo.currentData()
        defn = _FIELD_BY_KEY.get(key)
        if not defn:
            return
        _, _, ops, _kind, _presets = defn

        prev = self.operator_combo.currentText()
        self.operator_combo.blockSignals(True)
        self.operator_combo.clear()
        self.operator_combo.addItems(ops)
        if prev in ops:
            self.operator_combo.setCurrentText(prev)
        else:
            self.operator_combo.setCurrentIndex(0)
        self.operator_combo.blockSignals(False)
        self._on_operator_changed(self.operator_combo.currentText())

    def _on_operator_changed(self, op):
        self._rebuild_value_widget(op)

    def _rebuild_value_widget(self, op):
        # Remove previous value widget from layout.
        layout: QHBoxLayout = self.layout()
        old_widget = self.value_widget
        layout.removeWidget(old_widget)
        old_widget.setParent(None)
        old_widget.deleteLater()

        key = self.field_combo.currentData()
        defn = _FIELD_BY_KEY.get(key)
        kind = defn[3] if defn else "text"
        presets = defn[4] if defn else None

        if op in ("is_empty", "is_not_empty"):
            widget = QLabel("(kein Wert)")
            widget.setEnabled(False)
        elif kind == "bool":
            widget = QComboBox()
            widget.addItem("Ja", True)
            widget.addItem("Nein", False)
        elif kind == "number":
            widget = QSpinBox()
            widget.setRange(-1_000_000, 1_000_000_000)
            widget.setSingleStep(1)
        elif kind == "combo" and presets:
            widget = QComboBox()
            widget.setEditable(True)
            widget.addItems(presets)
        else:
            widget = QLineEdit()

        widget.setSizePolicy(QSizePolicy.Policy.Expanding,
                             QSizePolicy.Policy.Preferred)
        # Insert in the same slot (before the remove button at the end).
        layout.insertWidget(layout.count() - 1, widget, stretch=3)
        self.value_widget = widget

    # ------------------------------------------------------------------
    # Serialization helpers used by the dialog
    # ------------------------------------------------------------------

    def to_condition(self) -> FilterCondition:
        field = self.field_combo.currentData()
        op = self.operator_combo.currentText()
        conjunction = self.conjunction_combo.currentText()
        value = self._value()
        return FilterCondition(field=field, operator=op, value=value,
                               conjunction=conjunction)

    def _value(self):
        widget = self.value_widget
        if isinstance(widget, QLineEdit):
            return widget.text()
        if isinstance(widget, QSpinBox):
            return widget.value()
        if isinstance(widget, QComboBox):
            data = widget.currentData()
            if data is not None:
                return data
            return widget.currentText()
        return None

    def load_condition(self, condition: FilterCondition):
        # Conjunction
        idx = self.conjunction_combo.findText(condition.conjunction or "AND")
        if idx >= 0:
            self.conjunction_combo.setCurrentIndex(idx)

        # Field
        key = condition.field
        idx = self.field_combo.findData(key)
        if idx >= 0:
            self.field_combo.blockSignals(True)
            self.field_combo.setCurrentIndex(idx)
            self.field_combo.blockSignals(False)
            self._on_field_changed(idx)

        # Operator
        idx = self.operator_combo.findText(condition.operator)
        if idx >= 0:
            self.operator_combo.blockSignals(True)
            self.operator_combo.setCurrentIndex(idx)
            self.operator_combo.blockSignals(False)
            self._rebuild_value_widget(condition.operator)

        # Value
        widget = self.value_widget
        value = condition.value
        if isinstance(widget, QLineEdit):
            widget.setText("" if value is None else str(value))
        elif isinstance(widget, QSpinBox):
            try:
                widget.setValue(int(value))
            except (TypeError, ValueError):
                widget.setValue(0)
        elif isinstance(widget, QComboBox):
            if isinstance(value, bool):
                widget.setCurrentIndex(0 if value else 1)
            else:
                idx = widget.findText(str(value))
                if idx >= 0:
                    widget.setCurrentIndex(idx)
                elif widget.isEditable():
                    widget.setEditText("" if value is None else str(value))


# ============================================================
# Smart-Playlist-Dialog
# ============================================================

class SmartPlaylistDialog(QDialog):
    """Dialog for creating or editing a smart playlist.

    The dialog renders a list of editable :class:`ConditionRow` widgets and
    persists the resulting :class:`QueryBuilder` to a JSON string via
    :meth:`smart_query_json`. Manual playlists use :class:`ManualPlaylistDialog`
    instead.
    """

    def __init__(self, parent=None, *, name: str = "", description: str = "",
                 smart_query_json: str = ""):
        super().__init__(parent)
        self.setWindowTitle("Smart-Playlist")
        self.resize(720, 480)

        outer = QVBoxLayout()
        self.setLayout(outer)

        form = QFormLayout()
        self.name_edit = QLineEdit(name)
        self.name_edit.setPlaceholderText("Name der Playlist")
        form.addRow("Name", self.name_edit)

        self.desc_edit = QLineEdit(description)
        self.desc_edit.setPlaceholderText("Optionale Beschreibung")
        form.addRow("Beschreibung", self.desc_edit)
        outer.addLayout(form)

        # Conditions list inside a scroll area.
        outer.addWidget(QLabel("Bedingungen:"))
        self.conditions_container = QWidget()
        self.conditions_layout = QVBoxLayout()
        self.conditions_layout.setContentsMargins(0, 0, 0, 0)
        self.conditions_layout.setSpacing(4)
        self.conditions_container.setLayout(self.conditions_layout)

        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setWidget(self.conditions_container)
        outer.addWidget(scroll, stretch=1)

        add_row_btn = QPushButton("+ Bedingung hinzufuegen")
        add_row_btn.clicked.connect(self._add_condition_row)
        outer.addWidget(add_row_btn, alignment=Qt.AlignmentFlag.AlignLeft)

        # Order + limit row.
        order_form = QFormLayout()
        self.order_combo = QComboBox()
        self.order_combo.addItem("(keine Sortierung)", "")
        for key, label in _ORDER_FIELDS:
            self.order_combo.addItem(label, key)
        order_form.addRow("Sortieren nach", self.order_combo)

        self.order_dir_combo = QComboBox()
        self.order_dir_combo.addItem("Aufsteigend", "ASC")
        self.order_dir_combo.addItem("Absteigend", "DESC")
        order_form.addRow("Richtung", self.order_dir_combo)

        self.limit_spin = QSpinBox()
        self.limit_spin.setRange(0, 100_000)
        self.limit_spin.setSpecialValueText("(unbegrenzt)")
        self.limit_spin.setValue(0)
        order_form.addRow("Limit", self.limit_spin)
        outer.addLayout(order_form)

        # OK / Cancel buttons.
        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok |
            QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self._on_accept)
        buttons.rejected.connect(self.reject)
        outer.addWidget(buttons)

        # Pre-fill conditions when editing an existing playlist.
        if smart_query_json:
            self._load_query(smart_query_json)
        if not self._row_widgets():
            self._add_condition_row()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def name(self) -> str:
        return self.name_edit.text().strip()

    def description(self) -> str:
        return self.desc_edit.text().strip()

    def smart_query_json(self) -> str:
        builder = QueryBuilder()
        for row in self._row_widgets():
            cond = row.to_condition()
            if cond.operator in ("is_empty", "is_not_empty"):
                builder.add_condition(cond.field, cond.operator,
                                       conjunction=cond.conjunction)
            else:
                builder.add_condition(cond.field, cond.operator, cond.value,
                                       conjunction=cond.conjunction)
        order_field = self.order_combo.currentData()
        if order_field:
            builder.set_order(order_field, self.order_dir_combo.currentData())
        if self.limit_spin.value() > 0:
            builder.set_limit(self.limit_spin.value())
        return builder.to_json()

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _row_widgets(self):
        return [self.conditions_layout.itemAt(i).widget()
                for i in range(self.conditions_layout.count())
                if isinstance(self.conditions_layout.itemAt(i).widget(),
                              ConditionRow)]

    def _add_condition_row(self, condition: Optional[FilterCondition] = None):
        row = ConditionRow(on_remove=self._remove_condition_row)
        if condition:
            row.load_condition(condition)
        # First row never starts with "OR" - hide the conjunction combo.
        if not self._row_widgets():
            row.conjunction_combo.setEnabled(False)
        self.conditions_layout.addWidget(row)

    def _remove_condition_row(self, row: ConditionRow):
        self.conditions_layout.removeWidget(row)
        row.deleteLater()
        rows = self._row_widgets()
        # Keep at least one row to make the UI usable.
        if not rows:
            self._add_condition_row()
            return
        # Re-enable conjunction combos and disable on the very first row.
        for i, r in enumerate(rows):
            r.conjunction_combo.setEnabled(i > 0)

    def _load_query(self, smart_query_json: str):
        try:
            payload = json.loads(smart_query_json)
        except json.JSONDecodeError as exc:
            logger.warning("Konnte Smart-Query nicht parsen: %s", exc)
            return
        if not isinstance(payload, dict):
            return

        for raw in payload.get("conditions") or []:
            if not isinstance(raw, dict):
                continue
            field = raw.get("field")
            operator = raw.get("operator")
            if (field not in QueryBuilder.VALID_FIELDS or
                    operator not in QueryBuilder.VALID_OPERATORS):
                continue
            self._add_condition_row(FilterCondition(
                field=field, operator=operator,
                value=raw.get("value"),
                conjunction=raw.get("conjunction", "AND"),
            ))

        order_by = payload.get("order_by")
        if isinstance(order_by, str):
            idx = self.order_combo.findData(order_by)
            if idx < 0:
                # Field is in DB schema but not in our UI list - add it.
                self.order_combo.addItem(order_by, order_by)
                idx = self.order_combo.findData(order_by)
            self.order_combo.setCurrentIndex(idx)
        order_dir = payload.get("order_dir") or "ASC"
        if order_dir in ("ASC", "DESC"):
            self.order_dir_combo.setCurrentIndex(
                0 if order_dir == "ASC" else 1)
        try:
            limit = int(payload.get("limit") or 0)
            self.limit_spin.setValue(max(0, limit))
        except (TypeError, ValueError):
            self.limit_spin.setValue(0)

    def _on_accept(self):
        if not self.name():
            QMessageBox.warning(self, "Name fehlt",
                                "Bitte einen Namen fuer die Playlist angeben.")
            return
        # Validate by serializing - if no conditions are valid the JSON is
        # still well formed but we warn the user explicitly.
        try:
            payload = json.loads(self.smart_query_json())
        except json.JSONDecodeError:
            QMessageBox.warning(self, "Ungueltige Bedingungen",
                                "Die Smart-Query konnte nicht erzeugt werden.")
            return
        if not payload.get("conditions"):
            answer = QMessageBox.question(
                self, "Keine Bedingungen",
                "Diese Smart-Playlist enthaelt keine Bedingungen und liefert "
                "alle Medien zurueck. Trotzdem speichern?",
            )
            if answer != QMessageBox.StandardButton.Yes:
                return
        self.accept()


# ============================================================
# Manual playlist dialog (name + description only)
# ============================================================

class ManualPlaylistDialog(QDialog):
    """Tiny dialog that captures name + description for a manual playlist."""

    def __init__(self, parent=None, *, name: str = "", description: str = ""):
        super().__init__(parent)
        self.setWindowTitle("Playlist")
        layout = QVBoxLayout()
        self.setLayout(layout)

        form = QFormLayout()
        self.name_edit = QLineEdit(name)
        self.name_edit.setPlaceholderText("Name der Playlist")
        form.addRow("Name", self.name_edit)

        self.desc_edit = QTextEdit(description)
        self.desc_edit.setFixedHeight(80)
        form.addRow("Beschreibung", self.desc_edit)
        layout.addLayout(form)

        buttons = QDialogButtonBox(
            QDialogButtonBox.StandardButton.Ok |
            QDialogButtonBox.StandardButton.Cancel
        )
        buttons.accepted.connect(self._on_accept)
        buttons.rejected.connect(self.reject)
        layout.addWidget(buttons)

    def name(self) -> str:
        return self.name_edit.text().strip()

    def description(self) -> str:
        return self.desc_edit.toPlainText().strip()

    def _on_accept(self):
        if not self.name():
            QMessageBox.warning(self, "Name fehlt",
                                "Bitte einen Namen fuer die Playlist angeben.")
            return
        self.accept()


# ============================================================
# Playlist sidebar list model
# ============================================================

class _PlaylistListModel(QAbstractListModel):
    """Simple list model that renders playlist name + item count."""

    NameRole = Qt.ItemDataRole.UserRole + 1
    PlaylistRole = Qt.ItemDataRole.UserRole + 2

    def __init__(self, playlists=None, parent=None):
        super().__init__(parent)
        self._playlists = list(playlists or [])

    def rowCount(self, parent=QModelIndex()):
        if parent.isValid():
            return 0
        return len(self._playlists)

    def data(self, index, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid() or index.row() >= len(self._playlists):
            return None
        playlist: Playlist = self._playlists[index.row()]
        if role == Qt.ItemDataRole.DisplayRole:
            kind = "Smart" if playlist.playlist_type == "smart" else "Manuell"
            return f"{playlist.name} ({kind}, {playlist.item_count})"
        if role == self.NameRole:
            return playlist.name
        if role == self.PlaylistRole:
            return playlist
        return None

    def set_playlists(self, playlists):
        self.beginResetModel()
        self._playlists = list(playlists or [])
        self.endResetModel()

    def playlist_at(self, row) -> Optional[Playlist]:
        if 0 <= row < len(self._playlists):
            return self._playlists[row]
        return None


# ============================================================
# Playlists view
# ============================================================

class PlaylistsView(QWidget):
    """Two-pane view: playlists on the left, media items on the right.

    The view is intentionally lightweight: it relies on PlaylistManager for
    item resolution (manual + smart) and uses a plain QListWidget on the
    right side so it does not depend on the rich MediaItemDelegate from
    gui.py. The detail pane shows title, type and source per row, which is
    enough for users to verify their playlist contents.
    """

    def __init__(self, playlist_manager: PlaylistManager,
                 media_manager=None, parent=None):
        super().__init__(parent)
        self.playlist_manager = playlist_manager
        self.media_manager = media_manager
        self._needs_refresh = False
        self._current_playlist_id: Optional[int] = None

        outer = QVBoxLayout()
        self.setLayout(outer)

        title = QLabel("Playlists")
        title.setObjectName("pageTitle")
        outer.addWidget(title)

        # Toolbar
        toolbar = QHBoxLayout()
        new_manual_btn = QPushButton("Neue Playlist")
        new_manual_btn.clicked.connect(self._on_new_manual)
        toolbar.addWidget(new_manual_btn)

        new_smart_btn = QPushButton("Neue Smart-Playlist")
        new_smart_btn.clicked.connect(self._on_new_smart)
        toolbar.addWidget(new_smart_btn)

        edit_btn = QPushButton("Bearbeiten")
        edit_btn.clicked.connect(self._on_edit)
        toolbar.addWidget(edit_btn)
        self._edit_btn = edit_btn

        delete_btn = QPushButton("Loeschen")
        delete_btn.clicked.connect(self._on_delete)
        toolbar.addWidget(delete_btn)
        self._delete_btn = delete_btn

        toolbar.addStretch()
        outer.addLayout(toolbar)

        # Splitter with playlists list (left) and detail (right).
        splitter = QSplitter()
        outer.addWidget(splitter, stretch=1)

        self.playlists_list = QListView()
        self.playlists_model = _PlaylistListModel()
        self.playlists_list.setModel(self.playlists_model)
        self.playlists_list.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.playlists_list.customContextMenuRequested.connect(
            self._show_playlist_context_menu)
        sel_model = self.playlists_list.selectionModel()
        if sel_model is not None:
            sel_model.currentChanged.connect(self._on_selection_changed)
        splitter.addWidget(self.playlists_list)

        right = QWidget()
        right_layout = QVBoxLayout()
        right.setLayout(right_layout)
        self.detail_label = QLabel("Keine Playlist ausgewaehlt.")
        right_layout.addWidget(self.detail_label)
        self.items_list = QListWidget()
        right_layout.addWidget(self.items_list, stretch=1)
        splitter.addWidget(right)
        splitter.setStretchFactor(0, 1)
        splitter.setStretchFactor(1, 2)

        self.refresh()

    # ------------------------------------------------------------------
    # Public refresh API used by MainWindow.refresh_all_views()
    # ------------------------------------------------------------------

    def refresh(self):
        playlists = self.playlist_manager.get_playlists()
        self.playlists_model.set_playlists(playlists)

        # Re-select current playlist if it still exists, else clear detail.
        if self._current_playlist_id is not None:
            for row, p in enumerate(playlists):
                if p.id == self._current_playlist_id:
                    index = self.playlists_model.index(row)
                    self.playlists_list.setCurrentIndex(index)
                    self._populate_items(p)
                    return
            self._current_playlist_id = None
        self._populate_items(None)

    # ------------------------------------------------------------------
    # Internal handlers
    # ------------------------------------------------------------------

    def _selected_playlist(self) -> Optional[Playlist]:
        index = self.playlists_list.currentIndex()
        if not index.isValid():
            return None
        return self.playlists_model.playlist_at(index.row())

    def _on_selection_changed(self, current, _previous):
        playlist = self.playlists_model.playlist_at(current.row()) if current.isValid() else None
        self._current_playlist_id = playlist.id if playlist else None
        self._populate_items(playlist)

    def _populate_items(self, playlist: Optional[Playlist]):
        self.items_list.clear()
        if playlist is None:
            self.detail_label.setText("Keine Playlist ausgewaehlt.")
            return
        kind = "Smart" if playlist.playlist_type == "smart" else "Manuell"
        desc = playlist.description or "(keine Beschreibung)"
        self.detail_label.setText(
            f"{playlist.name} | {kind} | {playlist.item_count} Eintraege\n{desc}"
        )
        try:
            rows = self.playlist_manager.get_media_rows(playlist.id)
        except Exception as exc:
            logger.error("Konnte Playlist-Items nicht laden: %s", exc)
            self.items_list.addItem(f"Fehler: {exc}")
            return

        if not rows:
            self.items_list.addItem("(keine Treffer)")
            return

        for row in rows:
            title = self._row_value(row, "title", default="(ohne Titel)")
            mtype = self._row_value(row, "type", default="?")
            source = self._row_value(row, "source", default="?")
            self.items_list.addItem(f"{title}    [{mtype} | {source}]")

    @staticmethod
    def _row_value(row, key, default=None):
        try:
            value = row[key]
        except (IndexError, KeyError, TypeError):
            return default
        return default if value is None else value

    # --- Toolbar actions -----------------------------------------------

    def _on_new_manual(self):
        dialog = ManualPlaylistDialog(self)
        if dialog.exec() == QDialog.DialogCode.Accepted:
            try:
                self.playlist_manager.create_playlist(
                    dialog.name(), dialog.description(), playlist_type="manual"
                )
            except Exception as exc:
                QMessageBox.warning(self, "Fehler", str(exc))
                return
            self.refresh()

    def _on_new_smart(self):
        dialog = SmartPlaylistDialog(self)
        if dialog.exec() == QDialog.DialogCode.Accepted:
            try:
                self.playlist_manager.create_smart_playlist(
                    dialog.name(),
                    dialog.smart_query_json(),
                    description=dialog.description(),
                )
            except Exception as exc:
                QMessageBox.warning(self, "Fehler", str(exc))
                return
            self.refresh()

    def _on_edit(self):
        playlist = self._selected_playlist()
        if not playlist:
            return
        if playlist.playlist_type == "smart":
            self._edit_smart(playlist)
        else:
            self._edit_manual(playlist)

    def _edit_manual(self, playlist: Playlist):
        dialog = ManualPlaylistDialog(
            self, name=playlist.name, description=playlist.description
        )
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return
        new_name = dialog.name()
        if new_name and new_name != playlist.name:
            self.playlist_manager.rename_playlist(playlist.id, new_name)
        # Description is currently not persisted by rename_playlist; update via
        # raw SQL through the manager's connection.
        try:
            self.playlist_manager.conn.execute(
                "UPDATE playlists SET description = ?, updated_at = datetime('now') WHERE id = ?",
                (dialog.description(), playlist.id),
            )
            self.playlist_manager.conn.commit()
        except Exception as exc:
            logger.error("Konnte Beschreibung nicht aktualisieren: %s", exc)
        self.refresh()

    def _edit_smart(self, playlist: Playlist):
        dialog = SmartPlaylistDialog(
            self,
            name=playlist.name,
            description=playlist.description,
            smart_query_json=playlist.smart_query,
        )
        if dialog.exec() != QDialog.DialogCode.Accepted:
            return
        new_name = dialog.name()
        if new_name and new_name != playlist.name:
            self.playlist_manager.rename_playlist(playlist.id, new_name)
        try:
            self.playlist_manager.conn.execute(
                "UPDATE playlists SET description = ?, updated_at = datetime('now') WHERE id = ?",
                (dialog.description(), playlist.id),
            )
            self.playlist_manager.conn.commit()
        except Exception as exc:
            logger.error("Konnte Beschreibung nicht aktualisieren: %s", exc)
        self.playlist_manager.update_smart_query(playlist.id,
                                                  dialog.smart_query_json())
        self.refresh()

    def _on_delete(self):
        playlist = self._selected_playlist()
        if not playlist:
            return
        answer = QMessageBox.question(
            self, "Playlist loeschen",
            f"Playlist '{playlist.name}' wirklich loeschen?\n"
            "Manuelle Eintraege werden ebenfalls entfernt; die Mediendateien "
            "bleiben unangetastet."
        )
        if answer != QMessageBox.StandardButton.Yes:
            return
        try:
            self.playlist_manager.delete_playlist(playlist.id)
        except Exception as exc:
            QMessageBox.warning(self, "Fehler", str(exc))
            return
        self._current_playlist_id = None
        self.refresh()

    def _show_playlist_context_menu(self, pos):
        index = self.playlists_list.indexAt(pos)
        if not index.isValid():
            return
        self.playlists_list.setCurrentIndex(index)
        playlist = self.playlists_model.playlist_at(index.row())
        if not playlist:
            return
        menu = QMenu(self)
        menu.addAction(QAction("Bearbeiten", self,
                               triggered=lambda: self._on_edit()))
        menu.addAction(QAction("Loeschen", self,
                               triggered=lambda: self._on_delete()))
        menu.exec(self.playlists_list.viewport().mapToGlobal(pos))
