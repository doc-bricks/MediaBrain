"""
gui.py – Erweiterte GUI für MediaBrain
- Sidebar Navigation
- Globale Suche
- Favoriten-Ansicht
- Einstellungen-Fenster
- Verbesserte MediaItemWidgets
"""

import logging
from threading import Thread

logger = logging.getLogger(__name__)

from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QListWidget, QPushButton, QLineEdit,
    QStackedWidget, QMenu, QScrollArea, QFrame, QSplitter, QTabWidget,
    QComboBox, QCheckBox, QSystemTrayIcon, QFileDialog, QMessageBox
)
from PySide6.QtCore import Qt, QSize, Signal
from PySide6.QtGui import QAction, QIcon, QPixmap, QFont as QGuiFont, QColor as QGuiColor, QPainter as QGuiPainter

from core import MediaManager, MediaItem, BlacklistManager, TagManager
from playlists import PlaylistManager
from export_import import MediaExporter, MediaImporter
import config
from translator import translate as _t, set_default_translation_system, resolve_language
from theme_engine import ThemeEngine

# Erweiterte Suche
from search_advanced import AdvancedSearchBar, SearchEngine, SearchCriteria

# Playlist GUI (extracted to keep gui.py size manageable)
from gui_playlists import PlaylistsView

# Global theme engine instance
_theme_engine = ThemeEngine()

# Tag-Manager Referenz (wird von MainWindow gesetzt, damit alle Views darauf zugreifen können)
_tag_manager: TagManager = None


LANGUAGE_CHOICES = [
    ("de", "Deutsch"), ("en", "English"), ("es", "Español"),
    ("zh", "简体中文"), ("ja", "日本語"), ("ru", "Русский"),
    ("fr", "Français"), ("hi", "हिन्दी"), ("ar", "العربية"),
    ("bn", "বাংলা"), ("pt", "Português"),
]


def _set_standard_message_buttons(box):
    for standard, label in (
        (QMessageBox.StandardButton.Ok, "OK"),
        (QMessageBox.StandardButton.Cancel, "Abbrechen"),
        (QMessageBox.StandardButton.Yes, "Ja"),
        (QMessageBox.StandardButton.No, "Nein"),
        (QMessageBox.StandardButton.Save, "Speichern"),
        (QMessageBox.StandardButton.Close, "Schließen"),
    ):
        button = box.button(standard)
        if button is not None:
            button.setText(_t(label))


def _show_message(icon, parent, title, text, *args):
    buttons = args[0] if args else (
        QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        if icon == QMessageBox.Icon.Question else QMessageBox.StandardButton.Ok
    )
    box = QMessageBox(icon, title, text, buttons, parent)
    _set_standard_message_buttons(box)
    if len(args) > 1 and args[1] != QMessageBox.StandardButton.NoButton:
        box.setDefaultButton(args[1])
    elif icon == QMessageBox.Icon.Question:
        box.setDefaultButton(QMessageBox.StandardButton.No)
    return box.exec()


def _input_text(parent, title, prompt):
    from PySide6.QtWidgets import QInputDialog
    dialog = QInputDialog(parent)
    dialog.setWindowTitle(title)
    dialog.setLabelText(prompt)
    dialog.setInputMode(QInputDialog.InputMode.TextInput)
    dialog.setOkButtonText(_t("OK"))
    dialog.setCancelButtonText(_t("Abbrechen"))
    accepted = dialog.exec() == QInputDialog.DialogCode.Accepted
    return dialog.textValue(), accepted


def _media_type_display(media_type):
    labels = {
        "movie": "Film", "music": "Musik", "series": "Serie",
        "clip": "Clip", "video": "Video", "short": "Kurzvideo",
        "youtube": "YouTube-Clip", "podcast": "Podcast",
        "audiobook": "Hörbuch", "document": "Dokument",
    }
    code = str(media_type or "").lower()
    label = labels.get(code)
    return _t(label) if label else str(media_type or _t("Medium"))


def get_tag_manager() -> TagManager:
    """Returns the global TagManager instance."""
    return _tag_manager

def notify_gui_refresh():
    """Benachrichtigt die GUI über Änderungen, ohne MediaBrain.py zu importieren (verhindert Circular Import)."""
    mw = QApplication.activeWindow()
    # Falls das aktive Fenster nicht das MainWindow ist (z.B. ein Dialog),
    # suchen wir in allen Top-Level-Widgets
    if not mw or not hasattr(mw, "refresh_all_views"):
        for widget in QApplication.topLevelWidgets():
            if hasattr(widget, "refresh_all_views"):
                mw = widget
                break

    if mw and hasattr(mw, "refresh_all_views"):
        mw.refresh_all_views()


def build_online_metadata_fetch_kwargs(item):
    """Ermittelt die Fetch-Parameter für Online-Metadaten aus einem MediaItem."""
    media_type = getattr(item, "type", None) or "movie"
    source = getattr(item, "source", None)
    provider_id = getattr(item, "provider_id", None)

    if media_type in {"clip", "video", "short", "youtube"} or source == "youtube":
        media_type = "clip"

    kwargs = {
        "title": getattr(item, "title", ""),
        "media_type": media_type,
        "artist": getattr(item, "artist", None),
        "source": source,
        "provider_id": provider_id,
        "provider_subtype": getattr(item, "provider_subtype", None),
    }

    local_path = getattr(item, "local_path", None)
    if isinstance(local_path, str) and local_path.startswith(("http://", "https://")):
        kwargs["url"] = local_path

    return kwargs


def format_online_metadata(result, current_description=None, translator=None):
    """Formatiert Metadaten für die Anzeige im Detail-Panel."""
    if not result:
        return [], None, _t("Keine Online-Metadaten gefunden.", translator)

    if "error" in result:
        return [], None, _t("Fehler: {error}", translator, error=result["error"])

    lines = []

    title = result.get("title")
    if title:
        lines.append(_t("Titel: {title}", translator, title=title))

    year = result.get("year")
    if year:
        lines.append(_t("Jahr: {year}", translator, year=year))

    rating = result.get("rating")
    if rating not in (None, ""):
        lines.append(_t("Bewertung: {rating}/10", translator, rating=rating))

    genres = result.get("genres")
    if genres:
        if isinstance(genres, list):
            genres = ", ".join(str(genre) for genre in genres if genre)
        lines.append(_t("Genres: {genres}", translator, genres=genres))

    runtime = result.get("runtime")
    if runtime:
        lines.append(_t("Laufzeit: {runtime} Min", translator, runtime=runtime))

    director = result.get("director")
    if director:
        lines.append(_t("Regie: {director}", translator, director=director))

    channel = result.get("channel") or result.get("author_name")
    if channel:
        lines.append(_t("Kanal: {channel}", translator, channel=channel))

    source = result.get("source")
    if source:
        lines.append(_t("Quelle: {source}", translator, source=source))

    if result.get("thumbnail_url"):
        lines.append(_t("Vorschaubild: verfügbar", translator))

    description = result.get("description")
    if description and description != current_description:
        description = str(description)
        if len(description) > 500:
            description = description[:500].rstrip() + "..."
    else:
        description = None

    if not lines and not description:
        return [], None, _t("Online-Metadaten gefunden, aber keine Felder zum Anzeigen.", translator)

    return lines, description, None


# ============================================================
# 1. Suchleiste
# ============================================================

class SearchBar(QWidget):
    def __init__(self, placeholder="Suchen...", on_search=None, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.on_search = on_search

        layout = QHBoxLayout()
        self.setLayout(layout)

        self.input = QLineEdit()
        self.input.setPlaceholderText(_t(placeholder))
        self.input.textChanged.connect(self._trigger_search)

        layout.addWidget(self.input)

    def _trigger_search(self):
        if self.on_search:
            self.on_search(self.input.text())


# ============================================================
# 2. Collapsible Panel
# ============================================================

class CollapsiblePanel(QWidget):
    def __init__(self, title="Details", content_widget=None, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)

        self.is_open = False
        self._title = _t(title)

        self.main_layout = QVBoxLayout()
        self.setLayout(self.main_layout)

        self.header = QPushButton(f"▶  {_t(title)}")
        self.header.setCheckable(True)
        self.header.setStyleSheet("text-align: left; font-size: 14px; padding: 6px 12px;")
        self.header.clicked.connect(self.toggle)
        self.main_layout.addWidget(self.header)

        self.content = content_widget or QLabel(_t("Keine Details verfügbar"))
        self.content.setVisible(False)
        self.main_layout.addWidget(self.content)

    def toggle(self):
        self.is_open = not self.is_open
        self.content.setVisible(self.is_open)
        arrow = "\u25BC" if self.is_open else "\u25B6"
        self.header.setText(f"{arrow}  {self._title}")


# ============================================================
# 3. MediaItemWidget (verbessert)
# ============================================================

class MediaItemWidget(QFrame):
    # Qt-Layout-Fix 2026-06-28: Mindestgrößen erhöht, damit Emoji-Icons und Buttons
    # auf allen DPI-Stufen vollständig sichtbar bleiben (Bug AUFGABEN 2026-06-15).
    ITEM_MIN_HEIGHT = 64           # war 56 — zu wenig Spielraum für fav_btn + Margins
    ICON_SIZE = QSize(44, 44)      # war 36×36 — Emoji-Glyphen können 36px überschreiten
    ACTION_BUTTON_MIN_SIZE = QSize(96, 40)  # war QSize(88, 36) — Höhe für komfortables Touch-Target

    def __init__(self, item: MediaItem, media_manager: MediaManager, blacklist_manager: BlacklistManager, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.item = item
        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager

        self.setFrameStyle(QFrame.Shape.StyledPanel | QFrame.Shadow.Plain)
        self.setMinimumHeight(self.ITEM_MIN_HEIGHT)
        # Styling handled by central QSS theme

        layout = QHBoxLayout()
        layout.setContentsMargins(8, 6, 8, 6)
        layout.setSpacing(8)
        self.setLayout(layout)

        # Icon
        type_icons = {"movie": "🎬", "music": "🎵", "series": "📺", "clip": "🎞"}
        icon_text = type_icons.get(item.type, "📄")
        icon = QLabel(icon_text)
        icon.setObjectName("mediaItemIcon")
        icon.setFixedSize(self.ICON_SIZE)
        icon.setAlignment(Qt.AlignmentFlag.AlignCenter)
        icon.setStyleSheet("font-size: 22px;")  # war 20px — passt besser zu 44px-Container
        media_type_label = self._media_type_label()
        icon.setToolTip(media_type_label)
        icon.setAccessibleName(_t('Medientyp: {media_type}', media_type=(media_type_label)))
        icon.setAccessibleDescription(
            _t('Zeigt den Medientyp für {title} an.', title=(self.item.title))
        )
        layout.addWidget(icon)
        self.type_icon_label = icon

        # Titel + Source
        title_label = QLabel(f"<b>{item.title}</b>  <span style='color: gray; font-size: 11px;'>({item.source})</span>")
        title_label.setTextFormat(Qt.TextFormat.RichText)
        title_label.setWordWrap(True)
        title_label.setMinimumHeight(36)
        layout.addWidget(title_label, 1)
        self.title_label = title_label

        # Buttons kompakt
        self.fav_btn = QPushButton("\u2605" if item.is_favorite else "\u2606")
        self.fav_btn.setFixedSize(QSize(44, 44))  # war 40×40 — 24px-Schrift braucht mehr Spielraum
        self.fav_btn.setToolTip(_t("Favorit entfernen") if item.is_favorite else _t("Als Favorit markieren"))
        action_name = self._favorite_action_name()
        self.fav_btn.setAccessibleName(action_name)
        self.fav_btn.setAccessibleDescription(
            _t('Ändert den Favoritenstatus für {title}.', title=(self.item.title))
        )
        fav_color = "#FFC107" if item.is_favorite else "#888888"
        self.fav_btn.setStyleSheet(f"font-size: 24px; color: {fav_color}; border: none; background: transparent; padding: 0px;")
        self.fav_btn.clicked.connect(self.toggle_favorite)
        layout.addWidget(self.fav_btn)

        self.open_btn = QPushButton("▶ " + _t("öffnen"))
        self.open_btn.setMinimumSize(self.ACTION_BUTTON_MIN_SIZE)
        self.open_btn.clicked.connect(self.open_item)
        layout.addWidget(self.open_btn)

        self.details_btn = QPushButton("ℹ " + _t("Details anzeigen"))
        self.details_btn.setMinimumSize(self.ACTION_BUTTON_MIN_SIZE)
        self.details_btn.clicked.connect(self.open_detail_page)
        layout.addWidget(self.details_btn)

        # Kontextmenü
        self.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.customContextMenuRequested.connect(self.open_context_menu)

    def _favorite_action_name(self) -> str:
        if self.item.is_favorite:
            return _t("{title} aus Favoriten entfernen", title=self.item.title)
        return _t("{title} als Favorit markieren", title=self.item.title)

    def _media_type_label(self) -> str:
        labels = {
            "movie": "Film",
            "music": "Musik",
            "series": "Serie",
            "clip": "Clip",
            "video": "Video",
            "short": "Kurzvideo",
            "youtube": "YouTube-Clip",
            "podcast": "Podcast",
            "audiobook": "Hörbuch",
            "document": "Dokument",
        }
        label = labels.get(str(getattr(self.item, "type", "") or "").lower())
        return _t(label) if label else _t("Medium")

    def open_item(self):
        try:
            from core import OpenHandler
            handler = OpenHandler(self.media_manager)
            handler.open_item(self.item)
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Konnte Medium nicht öffnen: {error}', error=(e)))

    def open_detail_page(self):
        try:
            mw = QApplication.activeWindow()
            if hasattr(mw, "open_detail"):
                mw.open_detail(self.item)
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Detailseite konnte nicht geöffnet werden: {error}', error=(e)))

    def toggle_favorite(self):
        try:
            new_value = 0 if self.item.is_favorite else 1
            self.media_manager.db.execute(
                "UPDATE media_items SET is_favorite = ? WHERE id = ?",
                (new_value, self.item.id)
            )
            notify_gui_refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Favorit konnte nicht geändert werden: {error}', error=(e)))


    def toggle_details(self):
        self.details_panel.toggle()
    def show_in_explorer(self):
        try:
            import subprocess
            import platform
            import os
            path = self.item.local_path

            system = platform.system()
            if system == "Windows":
                subprocess.Popen(["explorer", "/select,", path])
            elif system == "Darwin":
                subprocess.Popen(["open", "-R", path])
            else:
                folder = os.path.dirname(path)
                subprocess.Popen(["xdg-open", folder])
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Konnte Datei nicht im Explorer anzeigen: {error}', error=(e)))

    def delete_file(self):
        try:
            from PySide6.QtWidgets import QMessageBox
            import os

            reply = _show_message(QMessageBox.Icon.Question,
                self, _t("Datei löschen"),
                _t('Soll die Datei wirklich unwiderruflich gelöscht werden?\n\n{path}', path=(self.item.local_path)),
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
                QMessageBox.StandardButton.No
            )
            if reply != QMessageBox.StandardButton.Yes:
                return

            if os.path.exists(self.item.local_path):
                os.remove(self.item.local_path)

            self.media_manager.db.execute(
                "DELETE FROM media_items WHERE id = ?",
                (self.item.id,)
            )
            notify_gui_refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Datei konnte nicht gelöscht werden: {error}', error=(e)))

    def refresh_metadata(self):
        # Später: ID3/MP4 neu einlesen
        logger.debug("[Meta] Metadaten aktualisieren (noch nicht implementiert)")

    def open_context_menu(self, pos):
        menu = QMenu(self)

        fav_action = QAction("Favorit entfernen" if self.item.is_favorite else "Als Favorit markieren")
        fav_action.triggered.connect(self.toggle_favorite)
        menu.addAction(fav_action)

        temp_delete_action = QAction(_t("Temporär ausblenden"))
        temp_delete_action.triggered.connect(self.temp_delete)
        menu.addAction(temp_delete_action)

        blacklist_menu = menu.addMenu("Blacklist…")
        for code, label in [
            (1, "1 Tag"),
            (2, "1 Woche"),
            (3, "1 Monat"),
            (4, "3 Monate"),
            (5, "1 Jahr"),
            (6, "Für immer")
        ]:
            act = QAction(label)
            act.triggered.connect(lambda _, c=code: self.blacklist(c))
            blacklist_menu.addAction(act)

        if self.item.blacklist_flag == 1:
            unblack = QAction(_t("Blacklist entfernen"))
            unblack.triggered.connect(lambda: (self.blacklist_manager.set_blacklist(self.item.id, False), notify_gui_refresh()))
            menu.addAction(unblack)

        menu.addSeparator()

        # Datei-Aktionen (nur für lokale Dateien)
        if self.item.is_local_file:
            show_action = QAction(_t("Im Explorer anzeigen"))
            show_action.triggered.connect(self.show_in_explorer)
            menu.addAction(show_action)

            if config.config.get("allow_file_deletion"):
                delete_action = QAction(_t("Datei löschen"))
                delete_action.triggered.connect(self.delete_file)
                menu.addAction(delete_action)

            meta_action = QAction(_t("Lokale Metadaten aktualisieren"))
            meta_action.triggered.connect(self.refresh_metadata)
            menu.addAction(meta_action)

        # Online-Metadaten abrufen (NEU!)
        online_meta_action = QAction(_t("🌐 Online-Metadaten abrufen"))
        online_meta_action.triggered.connect(self.fetch_online_metadata)
        menu.addAction(online_meta_action)

        menu.exec(self.mapToGlobal(pos))

    def temp_delete(self):
        try:
            from datetime import datetime
            self.media_manager.db.execute(
                "UPDATE media_items SET blacklist_flag = 1, procedure_code = 1, blacklisted_at = ? WHERE id = ?",
                (datetime.now().isoformat(), self.item.id)
            )
            notify_gui_refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Temporäres Ausblenden fehlgeschlagen: {error}', error=(e)))

    def blacklist(self, code):
        try:
            self.blacklist_manager.set_blacklist(self.item.id, True, code)
            notify_gui_refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Blacklist-Aktion fehlgeschlagen: {error}', error=(e)))

    def fetch_online_metadata(self):
        """Holt Online-Metadaten von TMDb/OMDb/MusicBrainz und aktualisiert den DB-Eintrag."""
        from metadata_v2 import MetadataFetcher
        from PySide6.QtWidgets import QMessageBox

        try:
            fetcher = MetadataFetcher()

            # Status prüfen
            status = fetcher.get_status()
            needs_api_keys = self.item.type in {"movie", "series"}
            has_required_api = status.get("tmdb") or status.get("omdb")
            if needs_api_keys and not has_required_api:
                _show_message(QMessageBox.Icon.Warning, self, _t("API nicht verfügbar"),
                    _t("Keine API-Keys konfiguriert. Bitte in settings.json eintragen."))
                return

            # Metadaten basierend auf Typ abrufen
            result = fetcher.auto_fetch(
                title=self.item.title,
                media_type=self.item.type,
                year=getattr(self.item, 'year', None),
                artist=getattr(self.item, 'artist', None),
                source=getattr(self.item, 'source', None),
                provider_id=getattr(self.item, 'provider_id', None),
                provider_subtype=getattr(self.item, 'provider_subtype', None)
            )

            if not result:
                _show_message(QMessageBox.Icon.Information, self, _t("Keine Ergebnisse"),
                    _t("Keine Online-Metadaten gefunden für '{title}'", title=(self.item.title)))
                return

            # Datenbank aktualisieren
            updates = []
            params = []

            if result.get("description") and result["description"] != self.item.description:
                updates.append("description = ?")
                params.append(result["description"])

            if result.get("thumbnail_url"):
                updates.append("thumbnail_url = ?")
                params.append(result["thumbnail_url"])

            if result.get("channel") and result.get("channel") != getattr(self.item, "channel", None):
                updates.append("channel = ?")
                params.append(result["channel"])

            if updates:
                params.append(self.item.id)
                query = f"UPDATE media_items SET {', '.join(updates)} WHERE id = ?"
                self.media_manager.db.execute(query, tuple(params))

                _show_message(QMessageBox.Icon.Information, self, _t("Metadaten aktualisiert"),
                    _t("Metadaten für '{title}' wurden aktualisiert.\nQuelle: {source}", title=(result.get('title', self.item.title)), source=(result.get('source', 'unbekannt'))))

                # GUI aktualisieren
                notify_gui_refresh()
            else:
                _show_message(QMessageBox.Icon.Information, self, _t("Keine neuen Daten"),
                    _t("Die gefundenen Metadaten sind bereits identisch."))
        except Exception as e:
            _show_message(QMessageBox.Icon.Critical, self, _t("Fehler"),
                _t('Metadaten konnten nicht abgerufen werden: {error}', error=(e)))


# Duplikat blacklist() entfernt - existiert bereits in Zeile 285 mit Error-Handling


from PySide6.QtCore import QAbstractListModel, QModelIndex, QRect
from PySide6.QtWidgets import QListView, QStyledItemDelegate, QStyle
from PySide6.QtGui import QPainter, QFont, QColor, QPen, QFontMetrics

# --- 1. Das Daten-Modell (Hält die Daten effizient im Speicher) ---
class MediaListModel(QAbstractListModel):
    """Model for virtualized media item lists.

    Stores MediaItem objects and exposes them via Qt roles.
    Supports efficient bulk-updates via beginResetModel/endResetModel.
    """
    def __init__(self, media_items=None):
        super().__init__()
        self.media_items = media_items or []

    def data(self, index, role):
        if not index.isValid() or index.row() >= len(self.media_items):
            return None

        item = self.media_items[index.row()]

        if role == Qt.ItemDataRole.DisplayRole:
            fav_mark = "★ " if item.is_favorite else ""
            return f"{fav_mark}{item.title} ({item.source})"

        if role == Qt.ItemDataRole.ToolTipRole:
            desc = item.description or ""
            tags_str = ""
            tm = get_tag_manager()
            if tm:
                tags = tm.get_tags_for_media(item.id)
                if tags:
                    tags_str = "\n" + _t("Tags: {tags}", tags=", ".join(t["name"] for t in tags))
            return f"{desc}\n" + _t("Quelle: {source}", source=item.source) + tags_str

        if role == Qt.ItemDataRole.UserRole:
            return item

        return None

    def rowCount(self, index=QModelIndex()):
        return len(self.media_items)

    def update_data(self, new_items):
        """Replaces the entire dataset efficiently."""
        self.beginResetModel()
        self.media_items = new_items
        self.endResetModel()


# --- 1b. Custom Delegate für reichere Darstellung ---
class MediaItemDelegate(QStyledItemDelegate):
    """Paints media items with icon, title, source, and tag chips.

    Replaces the old approach of creating individual QFrame widgets
    per item. Qt only creates delegate instances for visible rows,
    so this scales to thousands of items without slowdown.
    """

    TYPE_ICONS = {
        "movie": "\U0001f3ac", "music": "\U0001f3b5",
        "series": "\U0001f4fa", "clip": "\U0001f39e",
        "podcast": "\U0001f399", "audiobook": "\U0001f4da",
        "document": "\U0001f4c4", "file": "\U0001f4c4",
    }

    ROW_HEIGHT = 52

    def __init__(self, parent=None):
        super().__init__(parent)
        self._tag_cache = {}  # media_id -> list of tag dicts

    def invalidate_tag_cache(self):
        """Clears the tag cache. Call after tag changes."""
        self._tag_cache.clear()

    def _get_tags(self, media_id):
        """Lazy-loads tags for a media item with caching."""
        if media_id not in self._tag_cache:
            tm = get_tag_manager()
            if tm:
                self._tag_cache[media_id] = tm.get_tags_for_media(media_id)
            else:
                self._tag_cache[media_id] = []
        return self._tag_cache[media_id]

    def sizeHint(self, option, index):
        return option.rect.size() if option.rect.height() >= self.ROW_HEIGHT else \
            QSize(option.rect.width(), self.ROW_HEIGHT)

    def paint(self, painter: QPainter, option, index):
        painter.save()

        item = index.data(Qt.ItemDataRole.UserRole)
        if not item:
            super().paint(painter, option, index)
            painter.restore()
            return

        # Background (selection / alternating)
        if option.state & QStyle.StateFlag.State_Selected:
            painter.fillRect(option.rect, option.palette.highlight())
            text_color = option.palette.highlightedText().color()
        else:
            if index.row() % 2 == 1:
                painter.fillRect(option.rect, option.palette.alternateBase())
            text_color = option.palette.text().color()

        rect = option.rect.adjusted(6, 4, -6, -4)
        x = rect.x()
        y = rect.y()

        # Icon
        icon_text = self.TYPE_ICONS.get(item.type, "\U0001f4c4")
        icon_font = QFont(painter.font())
        icon_font.setPointSize(14)
        painter.setFont(icon_font)
        painter.setPen(QPen(text_color))
        painter.drawText(x, y, 24, rect.height(), Qt.AlignmentFlag.AlignCenter, icon_text)
        x += 30

        # Fav star
        if item.is_favorite:
            fav_font = QFont(painter.font())
            fav_font.setPointSize(15)
            painter.setFont(fav_font)
            painter.setPen(QPen(QColor("#FFC107")))
            painter.drawText(x, y, 22, rect.height(), Qt.AlignmentFlag.AlignCenter, "\u2605")
            x += 26

        # Title (bold)
        title_font = QFont(option.font)
        title_font.setBold(True)
        painter.setFont(title_font)
        painter.setPen(QPen(text_color))
        fm = QFontMetrics(title_font)
        title_text = fm.elidedText(item.title or "Unbekannt", Qt.TextElideMode.ElideRight, rect.width() - (x - rect.x()) - 150)
        painter.drawText(x, y, rect.width(), rect.height() // 2, Qt.AlignmentFlag.AlignVCenter, title_text)
        title_width = fm.horizontalAdvance(title_text)

        # Source (gray, smaller)
        source_font = QFont(option.font)
        source_font.setPointSize(max(option.font.pointSize() - 1, 8))
        painter.setFont(source_font)
        painter.setPen(QPen(QColor("#888888")))
        source_text = f"  ({item.source})"
        painter.drawText(x + title_width, y, rect.width(), rect.height() // 2, Qt.AlignmentFlag.AlignVCenter, source_text)

        # Tags (bottom row, small colored chips)
        tags = self._get_tags(item.id)
        if tags:
            tag_font = QFont(option.font)
            tag_font.setPointSize(max(option.font.pointSize() - 2, 7))
            painter.setFont(tag_font)
            tag_x = x
            tag_y = y + rect.height() // 2 + 2
            tag_fm = QFontMetrics(tag_font)

            for tag in tags[:5]:  # Max 5 tags shown
                tag_name = tag["name"]
                tag_color = QColor(tag.get("color", "#607D8B"))
                tw = tag_fm.horizontalAdvance(tag_name) + 10
                th = tag_fm.height() + 4

                if tag_x + tw > rect.right():
                    break

                # Chip background
                chip_rect = QRect(tag_x, tag_y, tw, th)
                painter.setPen(Qt.PenStyle.NoPen)
                light_color = QColor(tag_color)
                light_color.setAlpha(40)
                painter.setBrush(light_color)
                painter.drawRoundedRect(chip_rect, 3, 3)

                # Chip text
                painter.setPen(QPen(tag_color))
                painter.drawText(chip_rect, Qt.AlignmentFlag.AlignCenter, tag_name)

                tag_x += tw + 4

        painter.restore()


# --- Helper: Shared context menu builder for QListView-based views ---
def _build_item_context_menu(parent_widget, item: MediaItem, media_manager, blacklist_manager, refresh_callback, translator=None):
    """Builds a standard context menu for a media item.

    Used by LibraryView, FavoritesView, GlobalSearchView to avoid code duplication.
    Returns the QMenu (caller must exec it).
    """
    if translator is not None:
        set_default_translation_system(translator)
    menu = QMenu(parent_widget)

    # Open
    act_open = QAction(_t("öffnen"), parent_widget)
    act_open.triggered.connect(lambda: _open_media_item(item, media_manager))
    menu.addAction(act_open)

    # Details
    act_details = QAction(_t("Details anzeigen"), parent_widget)
    act_details.triggered.connect(lambda: _show_detail(item))
    menu.addAction(act_details)

    menu.addSeparator()

    # Favorite toggle
    fav_text = "Favorit entfernen" if item.is_favorite else "Zu Favoriten"
    act_fav = QAction(fav_text, parent_widget)
    act_fav.triggered.connect(lambda: (_toggle_fav(item, media_manager), refresh_callback()))
    menu.addAction(act_fav)

    # Blacklist submenu
    bl_menu = menu.addMenu("Auf Blacklist setzen")
    for code, label in [(1, "1 Tag"), (2, "1 Woche"), (3, "1 Monat"),
                         (4, "3 Monate"), (5, "1 Jahr"), (6, "Für immer")]:
        act = QAction(label, parent_widget)
        act.triggered.connect(lambda _, c=code: (blacklist_manager.set_blacklist(item.id, True, c), refresh_callback()))
        bl_menu.addAction(act)

    if item.blacklist_flag == 1:
        act_unbl = QAction(_t("Blacklist entfernen"), parent_widget)
        act_unbl.triggered.connect(lambda: (blacklist_manager.set_blacklist(item.id, False), refresh_callback()))
        menu.addAction(act_unbl)

    # Tags submenu
    tm = get_tag_manager()
    if tm:
        menu.addSeparator()
        tag_menu = menu.addMenu("Tags")
        current_tags = tm.get_tags_for_media(item.id)
        current_tag_ids = {t["id"] for t in current_tags}
        all_tags = tm.list_tags()

        for tag in all_tags:
            act_tag = QAction(tag["name"], parent_widget)
            act_tag.setCheckable(True)
            act_tag.setChecked(tag["id"] in current_tag_ids)
            act_tag.triggered.connect(
                lambda checked, t_id=tag["id"]: (
                    tm.add_tag_to_media(item.id, t_id) if checked
                    else tm.remove_tag_from_media(item.id, t_id),
                    refresh_callback()
                )
            )
            tag_menu.addAction(act_tag)

        if all_tags:
            tag_menu.addSeparator()

        act_new_tag = QAction(_t("+ Neuer Tag..."), parent_widget)
        act_new_tag.triggered.connect(lambda: _create_and_assign_tag(parent_widget, item.id, refresh_callback, translator))
        tag_menu.addAction(act_new_tag)

    # Local file actions
    if item.is_local_file:
        menu.addSeparator()
        act_explorer = QAction(_t("Im Explorer anzeigen"), parent_widget)
        act_explorer.triggered.connect(lambda: _show_in_explorer(item))
        menu.addAction(act_explorer)

    return menu


def _open_media_item(item, media_manager):
    """Opens a media item via OpenHandler."""
    try:
        from core import OpenHandler
        handler = OpenHandler(media_manager)
        handler.open_item(item)
    except Exception as e:
        logger.error("Could not open item: %s", e)


def _show_detail(item):
    """Opens the detail view for an item."""
    mw = QApplication.activeWindow()
    if hasattr(mw, "open_detail"):
        mw.open_detail(item)


def _toggle_fav(item, media_manager):
    """Toggles favorite status in DB."""
    new_val = 0 if item.is_favorite else 1
    media_manager.db.execute("UPDATE media_items SET is_favorite=? WHERE id=?", (new_val, item.id))


def _show_in_explorer(item):
    """Opens the file location in OS file manager."""
    try:
        import subprocess
        import platform
        import os
        path = item.local_path
        system = platform.system()
        if system == "Windows":
            subprocess.Popen(["explorer", "/select,", path])
        elif system == "Darwin":
            subprocess.Popen(["open", "-R", path])
        else:
            subprocess.Popen(["xdg-open", os.path.dirname(path)])
    except Exception as e:
        logger.error("Could not show in explorer: %s", e)


def _create_and_assign_tag(parent_widget, media_id, refresh_callback, translator=None):
    """Shows an input dialog to create a new tag and assign it to a media item."""
    from PySide6.QtWidgets import QInputDialog
    tm = get_tag_manager()
    if not tm:
        return
    name, ok = _input_text(parent_widget, _t("Neuer Tag", translator), _t("Tag-Name:", translator))
    if ok and name.strip():
        try:
            tag_id = tm.create_tag(name.strip())
            tm.add_tag_to_media(media_id, tag_id)
            refresh_callback()
        except ValueError as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, parent_widget, _t("Fehler"), str(e))


# --- 2. Die optimierte View (Zeigt die Liste an) ---
class LibraryView(QWidget):
    """Virtualized library view for a specific media type.

    Uses QListView + MediaListModel + MediaItemDelegate for efficient
    rendering of large media collections. Supports search, tag filtering,
    and context menu actions.
    """

    def __init__(self, media_type, media_manager: MediaManager, blacklist_manager: BlacklistManager, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.media_type = media_type
        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager
        self._needs_refresh = True

        layout = QVBoxLayout()
        self.setLayout(layout)

        # Search bar
        self.search_bar = AdvancedSearchBar(translator=getattr(self, "translator", None))
        self.search_bar.search_triggered.connect(self.apply_search)
        layout.addWidget(self.search_bar)

        # Tag filter row
        tag_row = QHBoxLayout()
        tag_row.addWidget(QLabel(_t("Tag-Filter:")))
        self.tag_combo = QComboBox()
        self.tag_combo.addItem(_t("Alle"), None)
        self.tag_combo.currentIndexChanged.connect(lambda: self.refresh())
        tag_row.addWidget(self.tag_combo, 1)
        layout.addLayout(tag_row)

        # Virtualized list
        self.list_view = QListView()
        self.model = MediaListModel()
        self.delegate = MediaItemDelegate(self)
        self.list_view.setModel(self.model)
        self.list_view.setItemDelegate(self.delegate)
        self.list_view.setAlternatingRowColors(True)
        self.list_view.doubleClicked.connect(self._on_double_click)
        self.list_view.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.list_view.customContextMenuRequested.connect(self._on_context_menu)
        layout.addWidget(self.list_view)

        self.refresh()

    def _refresh_tag_combo(self):
        """Updates the tag filter combo box with current tags."""
        tm = get_tag_manager()
        if not tm:
            return
        current_data = self.tag_combo.currentData()
        self.tag_combo.blockSignals(True)
        self.tag_combo.clear()
        self.tag_combo.addItem(_t("Alle"), None)
        for tag in tm.list_tags():
            self.tag_combo.addItem(f"{tag['name']} ({tag['count']})", tag["id"])
        # Restore selection
        if current_data is not None:
            for i in range(self.tag_combo.count()):
                if self.tag_combo.itemData(i) == current_data:
                    self.tag_combo.setCurrentIndex(i)
                    break
        self.tag_combo.blockSignals(False)

    def refresh(self):
        self._refresh_tag_combo()
        self.delegate.invalidate_tag_cache()
        selected_tag_id = self.tag_combo.currentData()
        tag_ids = [selected_tag_id] if selected_tag_id else None
        items = self.media_manager.list_by_type_with_tags(self.media_type, tag_ids=tag_ids)
        self.model.update_data(items)

    def apply_search(self, criteria: SearchCriteria):
        self.delegate.invalidate_tag_cache()
        engine = SearchEngine(self.media_manager.db)
        criteria.media_type = self.media_type
        results = engine.search(criteria)
        self.model.update_data(results)

    def _on_double_click(self, index):
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if item:
            _open_media_item(item, self.media_manager)

    def _on_context_menu(self, pos):
        index = self.list_view.indexAt(pos)
        if not index.isValid():
            return
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if not item:
            return
        menu = _build_item_context_menu(self, item, self.media_manager, self.blacklist_manager, self.refresh, self.translator)
        menu.exec(self.list_view.mapToGlobal(pos))
# ============================================================
# 5. FavoritenView
# ============================================================

class FavoritesView(QWidget):
    """Virtualized favorites view using QListView + Model/Delegate pattern."""

    def __init__(self, media_manager: MediaManager, blacklist_manager: BlacklistManager, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager
        self._needs_refresh = True

        layout = QVBoxLayout()
        self.setLayout(layout)

        layout.addWidget(QLabel(_t("Favoriten")))

        self.list_view = QListView()
        self.model = MediaListModel()
        self.delegate = MediaItemDelegate(self)
        self.list_view.setModel(self.model)
        self.list_view.setItemDelegate(self.delegate)
        self.list_view.setAlternatingRowColors(True)
        self.list_view.doubleClicked.connect(self._on_double_click)
        self.list_view.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.list_view.customContextMenuRequested.connect(self._on_context_menu)
        layout.addWidget(self.list_view)

        self.refresh()

    def refresh(self):
        try:
            self.delegate.invalidate_tag_cache()
            items = self.media_manager.list_favorites(limit=100)
            self.model.update_data(items)
        except Exception as e:
            logger.error("FavoritesView.refresh() error: %s", e)

    def _on_double_click(self, index):
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if item:
            from core import OpenHandler
            handler = OpenHandler(self.media_manager)
            handler.open_item(item)

    def _on_context_menu(self, pos):
        index = self.list_view.indexAt(pos)
        if not index.isValid():
            return
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if not item:
            return
        menu = _build_item_context_menu(self, item, self.media_manager, self.blacklist_manager, self.refresh, self.translator)
        menu.exec(self.list_view.mapToGlobal(pos))


# ============================================================
# 6. Globale Suche
# ============================================================

class GlobalSearchView(QWidget):
    """Virtualized global search view using QListView + Model/Delegate pattern."""

    def __init__(self, media_manager: MediaManager, blacklist_manager: BlacklistManager, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager
        self._needs_refresh = False

        layout = QVBoxLayout()
        self.setLayout(layout)

        self.search_bar = AdvancedSearchBar(translator=getattr(self, "translator", None))
        self.search_bar.search_triggered.connect(self.apply_search)
        layout.addWidget(self.search_bar)

        self.result_label = QLabel("")
        self.result_label.setObjectName("mutedLabel")
        layout.addWidget(self.result_label)

        self.list_view = QListView()
        self.model = MediaListModel()
        self.delegate = MediaItemDelegate(self)
        self.list_view.setModel(self.model)
        self.list_view.setItemDelegate(self.delegate)
        self.list_view.setAlternatingRowColors(True)
        self.list_view.doubleClicked.connect(self._on_double_click)
        self.list_view.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.list_view.customContextMenuRequested.connect(self._on_context_menu)
        layout.addWidget(self.list_view)

    def apply_search(self, criteria: SearchCriteria):
        try:
            if not criteria.text.strip() and not criteria.provider and not criteria.media_type:
                self.model.update_data([])
                self.result_label.setText("")
                return

            self.delegate.invalidate_tag_cache()
            engine = SearchEngine(self.media_manager.db)
            results = engine.search(criteria)
            self.model.update_data(results)
            self.result_label.setText(_t('{count} Ergebnisse gefunden', count=(len(results))))
        except Exception as e:
            logger.error("GlobalSearchView.apply_search() error: %s", e)
            self.result_label.setText(_t('Suchfehler: {error}', error=(e)))

    def refresh(self):
        """No-op: search results are not auto-refreshed."""
        pass

    def _on_double_click(self, index):
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if item:
            from core import OpenHandler
            handler = OpenHandler(self.media_manager)
            handler.open_item(item)

    def _on_context_menu(self, pos):
        index = self.list_view.indexAt(pos)
        if not index.isValid():
            return
        item = self.model.data(index, Qt.ItemDataRole.UserRole)
        if not item:
            return
        menu = _build_item_context_menu(self, item, self.media_manager, self.blacklist_manager,
                                         lambda: self.search_bar._trigger_search(), self.translator)
        menu.exec(self.list_view.mapToGlobal(pos))


# ============================================================
# 7. Einstellungen-Fenster
# ============================================================

class SettingsWindow(QWidget):
    def __init__(self, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.setWindowTitle(_t("Einstellungen"))
        self.resize(600, 400)

        layout = QVBoxLayout()
        self.setLayout(layout)

        tabs = QTabWidget()
        layout.addWidget(tabs)

        # Allgemein
        general = QWidget()
        g_layout = QVBoxLayout()
        general.setLayout(g_layout)

        language_label = QLabel(_t("Sprache der Oberfläche:"))
        self.language_select = QComboBox()
        for code, native_name in LANGUAGE_CHOICES:
            self.language_select.addItem(native_name, code)
        saved_language = resolve_language(
            getattr(translator, "get_language", lambda: None)(),
            config.config.get("ui.language", "de"),
        )
        self.language_select.setCurrentIndex(self.language_select.findData(saved_language))
        self.language_select.currentIndexChanged.connect(self._on_language_change)
        g_layout.addWidget(language_label)
        g_layout.addWidget(self.language_select)

        theme_label = QLabel(_t("Theme:"))
        theme_select = QComboBox()
        for key, name in _theme_engine.list_themes():
            theme_select.addItem(_t(name), key)
        # Set current
        current_theme = config.config.get("ui.theme", "light")
        for i in range(theme_select.count()):
            if theme_select.itemData(i) == current_theme:
                theme_select.setCurrentIndex(i)
                break
        def on_theme_change(index):
            theme_key = theme_select.itemData(index)
            if theme_key:
                config.config.set("ui.theme", theme_key)
                for widget in QApplication.topLevelWidgets():
                    if hasattr(widget, "apply_theme"):
                        widget.apply_theme()
        theme_select.currentIndexChanged.connect(on_theme_change)

        g_layout.addWidget(theme_label)
        g_layout.addWidget(theme_select)

        # System Tray
        tray_checkbox = QCheckBox(_t("System Tray aktivieren (Minimieren statt Beenden)"))
        tray_checkbox.setChecked(config.config.get("ui.system_tray", False))
        def on_tray_change(state):
            enabled = bool(state)
            config.config.set("ui.system_tray", enabled)
            # MainWindow benachrichtigen
            for widget in QApplication.topLevelWidgets():
                if hasattr(widget, "update_system_tray"):
                    widget.update_system_tray(enabled)
        tray_checkbox.stateChanged.connect(on_tray_change)
        g_layout.addWidget(tray_checkbox)

        media_types_label = QLabel(_t("Sichtbare Medientypen:"))
        g_layout.addWidget(media_types_label)

        enabled_media_types = config.config.get_enabled_media_types()
        self.media_type_checkboxes = {}
        for entry in config.MEDIA_TYPE_DEFINITIONS:
            media_type = entry["key"]
            checkbox = QCheckBox(_t(entry["label"]))
            checkbox.setObjectName(f"mediaType_{media_type}")
            checkbox.setChecked(enabled_media_types.get(media_type, True))
            checkbox.setToolTip(
                _t("{media_type} in der MediaBrain-Bibliotheks-Navigation anzeigen", media_type=_t(entry["label"]))
            )
            checkbox.stateChanged.connect(
                lambda state, media_type=media_type: self._on_media_type_change(media_type, state)
            )
            self.media_type_checkboxes[media_type] = checkbox
            g_layout.addWidget(checkbox)

        g_layout.addStretch()

        tabs.addTab(general, _t("Allgemein"))

        # Provider
        provider = QWidget()
        p_layout = QVBoxLayout()
        provider.setLayout(p_layout)

        for name in config.config.get("providers", {}).keys():
            label = QLabel(_t('{name} Öffnen mit:', name=(name)))
            combo = QComboBox()
            for method in ("browser", "app", "local", "auto"):
                combo.addItem(_t(method), method)
            saved_method = config.config.get(f"providers.{name}.preferred_open_method", "auto")
            combo.setCurrentIndex(combo.findData(saved_method))
            combo.currentIndexChanged.connect(
                lambda index, n=name, c=combo: config.config.set(
                    f"providers.{n}.preferred_open_method", c.itemData(index)
                )
            )
            p_layout.addWidget(label)
            p_layout.addWidget(combo)

        p_layout.addStretch()
        tabs.addTab(provider, _t("Provider"))

        # Sicherheit
        security = QWidget()
        s_layout = QVBoxLayout()
        security.setLayout(s_layout)

        delete_checkbox = QCheckBox(_t("Löschen lokaler Dateien erlauben"))
        delete_checkbox.setChecked(config.config.get("allow_file_deletion", False))
        delete_checkbox.stateChanged.connect(
            lambda v: config.config.set("allow_file_deletion", bool(v))
        )

        s_layout.addWidget(delete_checkbox)
        s_layout.addStretch()

        tabs.addTab(security, _t("Sicherheit"))

    def _on_language_change(self, index):
        language = self.language_select.itemData(index)
        if language not in {code for code, _name in LANGUAGE_CHOICES}:
            return
        config.config.set("ui.language", language)
        _show_message(
            QMessageBox.Icon.Information,
            self,
            _t("Anzeigesprache gespeichert"),
            _t("Die Änderung der Anzeigesprache wird nach einem Neustart wirksam."),
        )

    def _on_media_type_change(self, media_type, state):
        checked = state == Qt.CheckState.Checked or state == Qt.CheckState.Checked.value
        config.config.set_media_type_enabled(media_type, checked)
        for widget in QApplication.topLevelWidgets():
            if hasattr(widget, "apply_media_type_visibility"):
                widget.apply_media_type_visibility()



# ============================================================
# DashboardView – zentrale Startseite
# ============================================================

# In gui.py

class DashboardView(QWidget):
    def __init__(self, media_manager: MediaManager, blacklist_manager: BlacklistManager, open_settings_callback=None, open_blacklist_callback=None, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)

        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager

        # SearchEngine für erweiterte Suche
        self.search_engine = SearchEngine(self.media_manager.db)

        # Callbacks speichern
        self.open_settings_callback = open_settings_callback
        self.open_blacklist_callback = open_blacklist_callback

        layout = QVBoxLayout()
        self.setLayout(layout)

        # 1. Erweiterte Suche (ersetzt alte SearchBar)
        self.search_bar = AdvancedSearchBar(translator=getattr(self, "translator", None))
        self.search_bar.search_triggered.connect(self.apply_search)
        layout.addWidget(self.search_bar)

        # 2. Quick Actions (Statisch - wird nicht neu geladen -> KEIN FLACKERN MEHR)
        actions_layout = QHBoxLayout()

        btn_scan = QPushButton(_t("Bibliothek scannen"))
        # btn_scan.clicked.connect(...) # Später Funktion einbauen
        actions_layout.addWidget(btn_scan)

        btn_settings = QPushButton(_t("Einstellungen"))
        if self.open_settings_callback:
            btn_settings.clicked.connect(self.open_settings_callback)
        actions_layout.addWidget(btn_settings)

        btn_bl = QPushButton(_t("Blacklist anzeigen"))
        if self.open_blacklist_callback:
            btn_bl.clicked.connect(self.open_blacklist_callback)
        actions_layout.addWidget(btn_bl)

        actions_layout.addStretch()
        layout.addLayout(actions_layout)

        # 3. Scrollbereich für dynamischen Inhalt
        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        self.scroll.setFrameShape(QFrame.Shape.NoFrame)
        self.scroll.viewport().setStyleSheet("background-color: transparent;")
        layout.addWidget(self.scroll)

        self._init_container()
        self.refresh()

    def _init_container(self):
        """Erstellt einen neuen Container für den Scrollbereich."""
        self.container = QWidget()
        self.container.setStyleSheet("background-color: transparent;")
        self.container_layout = QVBoxLayout()
        self.container_layout.setContentsMargins(4, 4, 4, 4)
        self.container.setLayout(self.container_layout)
        self.scroll.setWidget(self.container)

    def refresh(self):
        try:
            # Alten Container komplett ersetzen (verhindert Scroll-Artefakte)
            old = self.scroll.takeWidget()
            if old:
                old.deleteLater()
            self._init_container()

            # --- A. Favoriten ---
            fav_label = QLabel(_t("Favoriten"))
            fav_label.setObjectName("sectionHeader")
            self.container_layout.addWidget(fav_label)

            # Optimiert: Nutzt MediaManager-Methoden statt raw Queries
            fav_items = self.media_manager.list_favorites(limit=5)

            if fav_items:
                for item in fav_items:
                    widget = MediaItemWidget(item, self.media_manager, self.blacklist_manager, translator=self.translator)
                    self.container_layout.addWidget(widget)
            else:
                self.container_layout.addWidget(QLabel(_t("Keine Favoriten markiert.")))

            # --- B. Zuletzt geöffnet ---
            recent_label = QLabel(_t("Zuletzt geöffnet"))
            recent_label.setObjectName("sectionHeader")
            self.container_layout.addWidget(recent_label)

            recent_items = self.media_manager.list_recent(limit=10)

            if recent_items:
                for item in recent_items:
                    widget = MediaItemWidget(item, self.media_manager, self.blacklist_manager, translator=self.translator)
                    self.container_layout.addWidget(widget)
            else:
                self.container_layout.addWidget(QLabel(_t("Noch keine Aktivitäten.")))

            self.container_layout.addStretch()
        except Exception as e:
            self.container_layout.addWidget(QLabel(_t('Fehler beim Laden des Dashboards: {error}', error=(e))))

    def apply_search(self, criteria: SearchCriteria):
        """Führt erweiterte Suche basierend auf SearchCriteria aus."""
        # Container komplett ersetzen
        old = self.scroll.takeWidget()
        if old:
            old.deleteLater()
        self._init_container()

        # Prüfe ob Filter aktiv sind
        has_filters = (
            criteria.text.strip() or
            criteria.media_type or
            criteria.provider or
            criteria.favorites_only or
            criteria.time_filter_days or
            criteria.tags
        )

        if not has_filters:
            self.refresh()
            return

        # Suchinfo anzeigen
        filter_parts = []
        if criteria.text:
            filter_parts.append(f'"{criteria.text}"')
        if criteria.media_type:
            filter_parts.append(_t("Typ: {type}", type=_media_type_display(criteria.media_type)))
        if criteria.provider:
            filter_parts.append(_t("Provider: {provider}", provider=_t(criteria.provider)))
        if criteria.favorites_only:
            filter_parts.append("⭐ Favoriten")
        if criteria.time_filter_days:
            filter_parts.append(_t("Letzte {days} Tage", days=criteria.time_filter_days))

        search_info = " | ".join(filter_parts) if filter_parts else "Alle"
        search_label = QLabel(_t('Suche: {filters}', filters=(search_info)))
        search_label.setObjectName("sectionHeader")
        self.container_layout.addWidget(search_label)

        # Suche ausführen via SearchEngine
        results = self.search_engine.search(criteria)

        if results:
            count_label = QLabel(_t('{count} Ergebnisse gefunden', count=(len(results))))
            count_label.setObjectName("mutedLabel")
            self.container_layout.addWidget(count_label)

            for media_item in results:
                widget = MediaItemWidget(media_item, self.media_manager, self.blacklist_manager, translator=self.translator)
                self.container_layout.addWidget(widget)
        else:
            no_results = QLabel(_t("Keine Treffer gefunden."))
            no_results.setObjectName("mutedLabel")
            self.container_layout.addWidget(no_results)

        self.container_layout.addStretch()
# ============================================================
# BlacklistView – vollständige Verwaltung
# ============================================================

from datetime import datetime, timedelta
from PySide6.QtWidgets import (
    QWidget, QFrame
)

class BlacklistView(QWidget):
    def __init__(self, media_manager: MediaManager, blacklist_manager: BlacklistManager, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)

        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager

        layout = QVBoxLayout()
        self.setLayout(layout)

        title = QLabel(_t("Blacklist-Verwaltung"))
        title.setObjectName("pageTitle")
        layout.addWidget(title)

        # -------------------------------------------------------
        # Filterleiste
        # -------------------------------------------------------
        filter_row = QHBoxLayout()

        self.provider_filter = QComboBox()
        self.provider_filter.addItem(_t("Alle Provider"), None)
        for provider in ["netflix", "youtube", "spotify", "local"]:
            self.provider_filter.addItem(_t(provider), provider)
        self.provider_filter.currentIndexChanged.connect(self.refresh)
        filter_row.addWidget(self.provider_filter)

        self.duration_filter = QComboBox()
        self.duration_filter.addItem(_t("Alle Dauern"), None)
        for label, code in (("1 Tag", 1), ("1 Woche", 2), ("1 Monat", 3),
                            ("3 Monate", 4), ("1 Jahr", 5), ("Für immer", 6)):
            self.duration_filter.addItem(_t(label), code)
        self.duration_filter.currentIndexChanged.connect(self.refresh)
        filter_row.addWidget(self.duration_filter)

        self.expiry_filter = QComboBox()
        self.expiry_filter.addItem(_t("Alle"), None)
        self.expiry_filter.addItem(_t("Nur abgelaufen"), "expired")
        self.expiry_filter.addItem(_t("Nur aktiv"), "active")
        self.expiry_filter.currentIndexChanged.connect(self.refresh)
        filter_row.addWidget(self.expiry_filter)

        layout.addLayout(filter_row)

        # -------------------------------------------------------
        # Buttons
        # -------------------------------------------------------
        btn_row = QHBoxLayout()

        btn_clear_expired = QPushButton(_t("Abgelaufene entfernen"))
        btn_clear_expired.clicked.connect(self._remove_expired)
        btn_row.addWidget(btn_clear_expired)

        btn_clear_all = QPushButton(_t("Alle entfernen"))
        btn_clear_all.clicked.connect(self._remove_all)
        btn_row.addWidget(btn_clear_all)

        btn_row.addStretch()
        layout.addLayout(btn_row)

        # -------------------------------------------------------
        # Scrollbereich
        # -------------------------------------------------------
        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        self.scroll.setFrameShape(QFrame.Shape.NoFrame)
        self.scroll.viewport().setStyleSheet("background-color: transparent;")
        layout.addWidget(self.scroll)

        self._init_container()
        self.refresh()

    def _init_container(self):
        """Erstellt einen neuen Container für den Scrollbereich."""
        self.container = QWidget()
        self.container.setStyleSheet("background-color: transparent;")
        self.container_layout = QVBoxLayout()
        self.container_layout.setContentsMargins(4, 4, 4, 4)
        self.container.setLayout(self.container_layout)
        self.scroll.setWidget(self.container)

    # -----------------------------------------------------------
    # Ablaufdatum berechnen
    # -----------------------------------------------------------
    def _expiry_date(self, start: datetime, code: int):
        if code == 1:
            return start + timedelta(days=1)
        if code == 2:
            return start + timedelta(weeks=1)
        if code == 3:
            return start + timedelta(days=30)
        if code == 4:
            return start + timedelta(days=90)
        if code == 5:
            return start + timedelta(days=365)
        if code == 6:
            return None
        return None

    # -----------------------------------------------------------
    # Blacklist-Ansicht aktualisieren
    # -----------------------------------------------------------
    def refresh(self):
        # Container komplett ersetzen (verhindert Scroll-Artefakte)
        old = self.scroll.takeWidget()
        if old:
            old.deleteLater()
        self._init_container()

        # Filter-Werte ermitteln
        source = self.provider_filter.currentData()
        procedure_code = self.duration_filter.currentData()
        expiry_filter = self.expiry_filter.currentData()

        # Optimiert: Filter in SQL statt Python-Iteration über alle Items
        items = self.media_manager.list_blacklisted(
            source=source,
            procedure_code=procedure_code,
            limit=200
        )

        for item in items:
            # Ablauf-Filter (muss in Python bleiben wegen Datumsberechnung)
            if item.blacklisted_at:
                start = datetime.fromisoformat(item.blacklisted_at)
                expiry = self._expiry_date(start, item.procedure_code)
                expired = expiry and datetime.now() > expiry
            else:
                expired = False
                expiry = None

            if expiry_filter == "expired" and not expired:
                continue
            if expiry_filter == "active" and expired:
                continue

            # Widget erzeugen
            widget = self._create_blacklist_widget(item, expired, expiry)
            self.container_layout.addWidget(widget)

        self.container_layout.addStretch()

    # -----------------------------------------------------------
    # Einzelnes Blacklist-Widget
    # -----------------------------------------------------------
    def _create_blacklist_widget(self, item: MediaItem, expired: bool, expiry):
        frame = QFrame()
        frame.setFrameStyle(QFrame.Shape.Panel | QFrame.Shadow.Raised)
        layout = QVBoxLayout()
        frame.setLayout(layout)

        title = QLabel(f"{item.title} ({item.source})")
        title.setObjectName("sectionHeader")
        layout.addWidget(title)

        layout.addWidget(QLabel(_t('Sperrcode: {code}', code=(item.procedure_code))))
        layout.addWidget(QLabel(_t('Seit: {date}', date=(item.blacklisted_at))))

        if expiry:
            layout.addWidget(QLabel(_t('Ablaufdatum: {expiry}', expiry=(expiry))))
        else:
            layout.addWidget(QLabel(_t("Ablaufdatum: Nie")))

        if expired:
            expired_label = QLabel(_t("Status: Abgelaufen"))
            expired_label.setObjectName("dangerLabel")
            layout.addWidget(expired_label)
        else:
            layout.addWidget(QLabel(_t("Status: Aktiv")))

        # Buttons
        btn_row = QHBoxLayout()

        btn_remove = QPushButton(_t("Entfernen"))
        btn_remove.clicked.connect(lambda: self._remove_single(item.id))
        btn_row.addWidget(btn_remove)

        btn_change = QPushButton(_t("Dauer ändern"))
        btn_change.clicked.connect(lambda: self._change_duration(item.id))
        btn_row.addWidget(btn_change)

        btn_row.addStretch()
        layout.addLayout(btn_row)

        return frame

    # -----------------------------------------------------------
    # Aktionen
    # -----------------------------------------------------------
    def _remove_single(self, item_id):
        try:
            self.blacklist_manager.set_blacklist(item_id, False)
            self.refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Blacklist-Eintrag konnte nicht entfernt werden: {error}', error=(e)))

    def _change_duration(self, item_id):
        try:
            self.blacklist_manager.set_blacklist(item_id, True, 2)
            self.refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Dauer konnte nicht geändert werden: {error}', error=(e)))

    def _remove_expired(self):
        """Entfernt alle abgelaufenen Blacklist-Einträge in einem Batch-UPDATE."""
        try:
            rows = self.media_manager.db.fetchall("""
                SELECT id, blacklisted_at, procedure_code
                FROM media_items
                WHERE blacklist_flag = 1 AND procedure_code < 6 AND blacklisted_at IS NOT NULL
            """)

            expired_ids = []
            now = datetime.now()
            for row in rows:
                start = datetime.fromisoformat(row["blacklisted_at"])
                expiry = self._expiry_date(start, row["procedure_code"])
                if expiry and now > expiry:
                    expired_ids.append(row["id"])

            if expired_ids:
                placeholders = ",".join("?" * len(expired_ids))
                self.media_manager.db.execute(f"""
                    UPDATE media_items
                    SET blacklist_flag = 0,
                        procedure_code = 0,
                        blacklisted_at = NULL
                    WHERE id IN ({placeholders})
                """, tuple(expired_ids))

            self.refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Abgelaufene konnten nicht entfernt werden: {error}', error=(e)))

    def _remove_all(self):
        try:
            self.media_manager.db.execute("""
                UPDATE media_items
                SET blacklist_flag = 0,
                    blacklisted_at = NULL,
                    procedure_code = 0
                WHERE blacklist_flag = 1
            """)
            self.refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Blacklist konnte nicht geleert werden: {error}', error=(e)))

class MediaDetailView(QWidget):
    online_metadata_loaded = Signal(object)

    def __init__(self, item: MediaItem, media_manager: MediaManager, blacklist_manager: BlacklistManager, back_callback, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)

        self.item = item
        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager
        self.back_callback = back_callback

        layout = QVBoxLayout()
        self.setLayout(layout)

        # Titel
        title = QLabel(item.title)
        title.setObjectName("pageTitle")
        layout.addWidget(title)

        # Thumbnail
        if item.thumbnail_url:
            thumb = QLabel(_t('[Thumbnail: {url}]', url=(item.thumbnail_url)))
            layout.addWidget(thumb)

        # Beschreibung
        desc = QLabel(item.description or _t("Keine Beschreibung verfügbar."))
        desc.setWordWrap(True)
        layout.addWidget(desc)

        # Metadaten
        meta = QLabel(
            _t("Typ: {type}", type=_media_type_display(item.type)) + "\n"
            + _t("Provider: {provider}", provider=item.source) + "\n"
            + _t("Provider-ID: {provider_id}", provider_id=item.provider_id) + "\n"
            + _t("Erstellt am: {created_at}", created_at=item.created_at) + "\n"
            + _t("Zuletzt geöffnet: {last_opened_at}", last_opened_at=item.last_opened_at) + "\n"
            + _t("Öffnungsmethode: {open_method}", open_method=_t(item.open_method or "-"))
        )
        layout.addWidget(meta)

        # Online-Metadaten
        online_label = QLabel(_t("Online-Metadaten:"))
        online_label.setObjectName("sectionHeader")
        layout.addWidget(online_label)

        self.online_meta_container = QVBoxLayout()
        self.online_meta_container.setContentsMargins(0, 0, 0, 0)
        self.online_meta_status = QLabel(_t("Lade Online-Metadaten..."))
        self.online_meta_status.setWordWrap(True)
        self.online_meta_status.setStyleSheet("color: #888; padding-left: 10px;")
        self.online_meta_container.addWidget(self.online_meta_status)
        layout.addLayout(self.online_meta_container)

        # Buttons
        btn_row = QHBoxLayout()

        open_btn = QPushButton(_t("Öffnen"))
        open_btn.clicked.connect(self.open_item)
        btn_row.addWidget(open_btn)

        fav_btn = QPushButton("Favorit" if not item.is_favorite else "Favorit entfernen")
        fav_btn.clicked.connect(self.toggle_favorite)
        btn_row.addWidget(fav_btn)

        refresh_btn = QPushButton(_t("Metadaten neu laden"))
        refresh_btn.clicked.connect(self._load_online_metadata)
        btn_row.addWidget(refresh_btn)

        back_btn = QPushButton(_t("Zurück"))
        back_btn.clicked.connect(self.back_callback)
        btn_row.addWidget(back_btn)

        btn_row.addStretch()
        layout.addLayout(btn_row)
        layout.addStretch()

        self.online_metadata_loaded.connect(self._update_online_metadata)
        self._load_online_metadata()

    def _clear_online_metadata(self):
        while self.online_meta_container.count():
            item = self.online_meta_container.takeAt(0)
            widget = item.widget()
            if widget is not None:
                widget.deleteLater()

    def _load_online_metadata(self):
        """Lädt Online-Metadaten asynchron im Hintergrund."""

        def fetch():
            try:
                from metadata_v2 import MetadataFetcher

                fetcher = MetadataFetcher()
                kwargs = build_online_metadata_fetch_kwargs(self.item)
                result = fetcher.auto_fetch(**kwargs)
            except Exception as exc:
                result = {"error": str(exc)}
            try:
                self.online_metadata_loaded.emit(result)
            except RuntimeError:
                pass  # widget destroyed while fetch was in flight

        self._clear_online_metadata()
        self.online_meta_status = QLabel(_t("Lade Online-Metadaten..."))
        self.online_meta_status.setWordWrap(True)
        self.online_meta_status.setStyleSheet("color: #888; padding-left: 10px;")
        self.online_meta_container.addWidget(self.online_meta_status)
        Thread(target=fetch, daemon=True).start()

    def _update_online_metadata(self, result):
        """Aktualisiert die Online-Metadaten-Anzeige."""
        self._clear_online_metadata()

        lines, description, message = format_online_metadata(result, self.item.description, self.translator)

        if message:
            label = QLabel(message)
            label.setWordWrap(True)
            label.setStyleSheet("padding-left: 10px; color: #888;")
            self.online_meta_container.addWidget(label)
            return

        if lines:
            meta_text = "\n".join(f"  {line}" for line in lines)
            label = QLabel(meta_text)
            label.setWordWrap(True)
            label.setStyleSheet("padding-left: 10px; font-family: monospace;")
            self.online_meta_container.addWidget(label)

        if description:
            desc_label = QLabel(_t("Online-Beschreibung:"))
            desc_label.setStyleSheet("font-weight: bold; margin-top: 10px; padding-left: 10px;")
            self.online_meta_container.addWidget(desc_label)

            desc = QLabel(description)
            desc.setWordWrap(True)
            desc.setStyleSheet("padding-left: 20px; color: #555;")
            self.online_meta_container.addWidget(desc)

        if not lines and not description:
            label = QLabel(_t("Online-Metadaten gefunden, aber keine Felder zum Anzeigen."))
            label.setWordWrap(True)
            label.setStyleSheet("padding-left: 10px; color: #888;")
            self.online_meta_container.addWidget(label)

    def open_item(self):
        try:
            from core import OpenHandler
            handler = OpenHandler(self.media_manager)
            handler.open_item(self.item)
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Konnte Medium nicht öffnen: {error}', error=(e)))

    def toggle_favorite(self):
        try:
            new_value = 0 if self.item.is_favorite else 1
            self.media_manager.db.execute(
                "UPDATE media_items SET is_favorite = ? WHERE id = ?",
                (new_value, self.item.id)
            )
            notify_gui_refresh()
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('Favorit konnte nicht geändert werden: {error}', error=(e)))
# ============================================================
# 8. Statistik-View
# ============================================================

class StatsView(QWidget):
    """Statistik-Panel für MediaBrain.

    Zeigt:
    - Gesamtanzahl Medien in der Bibliothek
    - Medien pro Typ (movie, series, music, clip, etc.)
    - Geschätzter Speicherverbrauch lokaler Dateien
    - Top 5 zuletzt hinzugefügte Medien
    """

    def __init__(self, media_manager: MediaManager, parent=None, translator=None):
        super().__init__(parent)
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)
        self.media_manager = media_manager
        self._needs_refresh = True
        self._build_ui()

    def _build_ui(self):
        """Erstellt das Layout des Statistik-Panels."""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(20, 20, 20, 20)
        layout.setSpacing(16)

        header = QLabel(_t("<h2>📊 Statistiken & Dashboard</h2>"))
        layout.addWidget(header)

        # --- Kennzahlen-Grid ---
        self.lbl_total = QLabel(_t("Gesamtanzahl Medien: --"))
        self.lbl_total.setObjectName("sectionHeader")
        layout.addWidget(self.lbl_total)

        self.lbl_storage = QLabel(_t("Geschätzter Speicher (lokal): –"))
        layout.addWidget(self.lbl_storage)

        # --- Medien pro Typ ---
        layout.addWidget(QLabel(_t("<b>Medien nach Typ:</b>")))
        self.type_list = QListWidget()
        self.type_list.setMaximumHeight(160)
        layout.addWidget(self.type_list)

        # --- Zuletzt hinzugefuegt ---
        layout.addWidget(QLabel(_t("<b>Zuletzt hinzugefügt (Top 5):</b>")))
        self.recent_list = QListWidget()
        self.recent_list.setMaximumHeight(150)
        layout.addWidget(self.recent_list)

        btn_refresh = QPushButton(_t("🔄 Aktualisieren"))
        btn_refresh.clicked.connect(self.refresh)
        layout.addWidget(btn_refresh)

        layout.addStretch()

    def refresh(self):
        """Laedt die Statistiken neu aus der Datenbank."""
        import os
        db = self.media_manager.db

        try:
            # 1. Gesamtanzahl
            total_row = db.conn.execute(
                "SELECT COUNT(*) AS cnt FROM media_items WHERE blacklist_flag = 0"
            ).fetchone()
            total = total_row["cnt"] if total_row else 0
            self.lbl_total.setText(_t('Gesamtanzahl Medien: {count}', count=(total)))

            # 2. Medien pro Typ
            type_rows = db.conn.execute(
                "SELECT type, COUNT(*) AS cnt FROM media_items WHERE blacklist_flag = 0 GROUP BY type ORDER BY cnt DESC"
            ).fetchall()
            self.type_list.clear()
            type_icons = {
                "movie": "🎬", "series": "📺", "music": "🎵",
                "clip": "🎞️", "podcast": "🎙️", "audiobook": "📚", "document": "📄"
            }
            for row in type_rows:
                icon = type_icons.get(row["type"], "▪")
                self.type_list.addItem(_t('  {icon}  {type}: {count}', icon=(icon), type=(_media_type_display(row["type"])), count=(row['cnt'])))

            # 3. Speicherverbrauch lokaler Dateien
            local_rows = db.conn.execute(
                "SELECT local_path FROM media_items WHERE is_local_file = 1 AND local_path IS NOT NULL AND local_path != ''"
            ).fetchall()
            total_bytes = 0
            for r in local_rows:
                try:
                    sz = os.path.getsize(r["local_path"])
                    total_bytes += sz
                except OSError:
                    pass
            if total_bytes > 0:
                total_gb = total_bytes / (1024 ** 3)
                self.lbl_storage.setText(_t("Geschätzter Speicher (lokal): {size_gb} GB ({file_count} Dateien)", size_gb=f"{total_gb:.2f}", file_count=len(local_rows)))
            else:
                self.lbl_storage.setText(_t("Geschätzter Speicher (lokal): Keine lokalen Dateien erfasst"))

            # 4. Zuletzt hinzugefuegt (Top 5)
            recent_rows = db.conn.execute(
                "SELECT title, type, created_at FROM media_items ORDER BY created_at DESC LIMIT 5"
            ).fetchall()
            self.recent_list.clear()
            for r in recent_rows:
                date_str = (r["created_at"] or "")[:10]
                self.recent_list.addItem(_t('  {date}  [{type}]  {title}', date=(date_str), type=(_media_type_display(r["type"])), title=(r['title'])))

        except Exception as e:
            logger.error(f"StatsView.refresh() Fehler: {e}")

        self._needs_refresh = False


# ============================================================
# 9. MainWindow mit Sidebar
# ============================================================

class MainWindow(QMainWindow):
    def __init__(self, media_manager: MediaManager, blacklist_manager: BlacklistManager,
                 tag_manager: TagManager = None,
                 playlist_manager: PlaylistManager = None, translator=None):
        super().__init__()
        self.translator = translator
        if translator is not None:
            set_default_translation_system(translator)

        self.media_manager = media_manager
        self.blacklist_manager = blacklist_manager
        self.tag_manager = tag_manager
        self.playlist_manager = playlist_manager
        self.library_views = {}
        self.library_buttons = {}

        # Set global tag_manager reference for all views
        global _tag_manager
        _tag_manager = tag_manager

        self.setWindowTitle("MediaBrain")
        self.resize(
            config.config.get("ui.window_width", 1200),
            config.config.get("ui.window_height", 800)
        )

        # Hauptlayout: Sidebar + Content
        splitter = QSplitter()
        self.setCentralWidget(splitter)

        # Sidebar
        sidebar = QWidget()
        sidebar_layout = QVBoxLayout()
        sidebar.setLayout(sidebar_layout)
        sidebar.setObjectName("Sidebar") # Für CSS Styling

        btn_dash = QPushButton(_t("Übersicht"))
        btn_dash.clicked.connect(lambda: self._switch_view(self.dashboard))
        sidebar_layout.addWidget(btn_dash)

        for entry in config.MEDIA_TYPE_DEFINITIONS:
            media_type = entry["key"]
            button = QPushButton(_t(entry["label"]))
            button.clicked.connect(
                lambda checked=False, media_type=media_type: self._switch_library_type(media_type)
            )
            self.library_buttons[media_type] = button
            sidebar_layout.addWidget(button)

        btn_favs = QPushButton(_t("Favoriten"))
        btn_favs.clicked.connect(lambda: self._switch_view(self.favorites))
        sidebar_layout.addWidget(btn_favs)

        btn_blacklist = QPushButton(_t("Blacklist"))
        btn_blacklist.clicked.connect(lambda: self._switch_view(self.blacklist_view))
        sidebar_layout.addWidget(btn_blacklist)

        btn_stats = QPushButton(_t("📊 Statistiken"))
        btn_stats.clicked.connect(lambda: self._switch_view(self.stats_view))
        sidebar_layout.addWidget(btn_stats)

        if self.playlist_manager is not None:
            btn_playlists = QPushButton(_t("Playlists"))
            btn_playlists.clicked.connect(lambda: self._switch_view(self.playlists_view))
            sidebar_layout.addWidget(btn_playlists)

        btn_export = QPushButton(_t("Export (JSON)"))
        btn_export.clicked.connect(self._export_library_json)
        sidebar_layout.addWidget(btn_export)

        btn_import = QPushButton(_t("Import (JSON)"))
        btn_import.clicked.connect(self._import_library_json)
        sidebar_layout.addWidget(btn_import)

        btn_settings = QPushButton(_t("Einstellungen"))
        btn_settings.clicked.connect(self.open_settings)
        sidebar_layout.addWidget(btn_settings)

        sidebar_layout.addStretch()

        splitter.addWidget(sidebar)

        # Content Stack
        self.stack = QStackedWidget()
        splitter.addWidget(self.stack)

        # --- Views Initialisieren ---

        # 1. Dashboard (Korrigiert: Echte View statt QLabel)
        self.dashboard = DashboardView(
            media_manager,
            blacklist_manager,
            open_settings_callback=self.open_settings,
            open_blacklist_callback=lambda: self.stack.setCurrentWidget(self.blacklist_view),
            translator=self.translator,
        )
        self.stack.addWidget(self.dashboard)

        # 2. Libraries
        for entry in config.MEDIA_TYPE_DEFINITIONS:
            media_type = entry["key"]
            view = LibraryView(media_type, media_manager, blacklist_manager, translator=self.translator)
            self.library_views[media_type] = view
            self.stack.addWidget(view)

        self.library_movies = self.library_views["movie"]
        self.library_series = self.library_views["series"]
        self.library_music = self.library_views["music"]
        self.library_clips = self.library_views["clip"]

        # 3. Favoriten
        self.favorites = FavoritesView(media_manager, blacklist_manager, translator=self.translator)
        self.stack.addWidget(self.favorites)

        # 4. Blacklist (Korrigiert: Echte View statt QLabel)
        self.blacklist_view = BlacklistView(media_manager, blacklist_manager, translator=self.translator)
        self.stack.addWidget(self.blacklist_view)

        # 5. Statistiken
        self.stats_view = StatsView(media_manager, translator=self.translator)
        self.stack.addWidget(self.stats_view)

        # 6. Playlists (optional - only when a PlaylistManager was injected)
        self.playlists_view = None
        if self.playlist_manager is not None:
            self.playlists_view = PlaylistsView(self.playlist_manager,
                                                 media_manager=media_manager,
                                                 translator=self.translator)
            self.stack.addWidget(self.playlists_view)

        # 7. Suche
        self.global_search = GlobalSearchView(media_manager, blacklist_manager, translator=self.translator)
        self.stack.addWidget(self.global_search)

        # Theme anwenden
        self.apply_media_type_visibility()
        self.apply_theme()

        # Detail View Platzhalter
        self.detail_view = None

        # System Tray
        self.tray_icon = None
        if config.config.get("ui.system_tray", False):
            self._setup_system_tray()

    def open_detail(self, item):
        # Alte Detail-View entfernen um Memory Leak zu vermeiden
        if self.detail_view is not None:
            self.stack.removeWidget(self.detail_view)
            self.detail_view.deleteLater()

        self.detail_view = MediaDetailView(
            item,
            self.media_manager,
            self.blacklist_manager,
            back_callback=lambda: self.stack.setCurrentWidget(self.dashboard),
            translator=self.translator,
        )
        self.stack.addWidget(self.detail_view)
        self.stack.setCurrentWidget(self.detail_view)

    def refresh_all_views(self):
        """Aktualisiert Views - optimiert: nur sichtbare View sofort, Rest lazy.

        Statt alle 7 Views gleichzeitig zu refreshen (7+ DB-Queries),
        wird nur die aktuell sichtbare View sofort aktualisiert.
        Die anderen Views werden beim nächsten Anzeigen refreshed (dirty-Flag).
        """
        try:
            current = self.stack.currentWidget()

            # Alle Views als 'dirty' markieren
            all_views = [
                self.dashboard, *self.library_views.values(), self.favorites,
                self.blacklist_view, self.stats_view
            ]
            if self.playlists_view is not None:
                all_views.append(self.playlists_view)
            for view in all_views:
                view._needs_refresh = True

            # Nur die aktuelle View sofort refreshen
            if current and hasattr(current, 'refresh'):
                current.refresh()
                current._needs_refresh = False
        except Exception as e:
            from PySide6.QtWidgets import QMessageBox
            _show_message(QMessageBox.Icon.Warning, self, _t("Fehler"), _t('GUI konnte nicht vollständig aktualisiert werden: {error}', error=(e)))

    def _switch_view(self, view):
        """Wechselt zur gewünschten View und refreshed sie, falls sie dirty ist."""
        self.stack.setCurrentWidget(view)
        if getattr(view, '_needs_refresh', False) and hasattr(view, 'refresh'):
            view.refresh()
            view._needs_refresh = False

    def _switch_library_type(self, media_type):
        view = self.library_views.get(media_type)
        if view is not None:
            self._switch_view(view)

    def apply_media_type_visibility(self):
        """Blendet Library-Buttons anhand der gespeicherten Medientyp-Einstellungen ein oder aus."""
        enabled_media_types = config.config.get_enabled_media_types()
        current = self.stack.currentWidget()
        for media_type, button in self.library_buttons.items():
            enabled = enabled_media_types.get(media_type, True)
            button.setVisible(enabled)
            if not enabled and current is self.library_views.get(media_type):
                self._switch_view(self.dashboard)

    def _export_library_json(self):
        path, _ = QFileDialog.getSaveFileName(
            self,
            _t("MediaBrain Export speichern"),
            "",
            _t("JSON-Datei (*.json)")
        )
        if not path:
            return
        if not path.lower().endswith(".json"):
            path = f"{path}.json"
        try:
            exporter = MediaExporter(self.media_manager.db.conn)
            count = exporter.export_json(path, include_tags=True, include_playlists=True)
            _show_message(QMessageBox.Icon.Information,
                self,
                _t("Export abgeschlossen"),
                _t('{count} Medien exportiert nach:\n{path}', count=(count), path=(path))
            )
        except Exception as e:
            _show_message(QMessageBox.Icon.Warning, self, _t("Export fehlgeschlagen"), str(e))

    def _import_library_json(self):
        path, _ = QFileDialog.getOpenFileName(
            self,
            _t("MediaBrain Export laden"),
            "",
            _t("JSON-Datei (*.json)")
        )
        if not path:
            return

        reply = _show_message(QMessageBox.Icon.Question,
            self,
            _t("Import-Modus"),
            (
                _t("Bestehende Einträge mit gleicher Quelle + Provider-ID überspringen?\n"
                "Nein = vorhandene Datensätze ersetzen.")
            ),
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.Yes
        )
        merge = reply == QMessageBox.StandardButton.Yes

        try:
            importer = MediaImporter(self.media_manager.db.conn)
            stats = importer.import_json(path, merge=merge)
            self.refresh_all_views()
            _show_message(QMessageBox.Icon.Information,
                self,
                _t("Import abgeschlossen"),
                (
                    _t('Importiert: {imported}\nÜbersprungen: {skipped}\nFehler: {errors}', imported=(stats.get('imported', 0)), skipped=(stats.get('skipped', 0)), errors=(stats.get('errors', 0)))
                )
            )
        except Exception as e:
            _show_message(QMessageBox.Icon.Warning, self, _t("Import fehlgeschlagen"), str(e))

    def open_settings(self):
        self.settings_window = SettingsWindow(self.translator)
        self.settings_window.show()

    def _setup_system_tray(self):
        """Erstellt das System-Tray-Icon mit Kontextmenu."""
        if self.tray_icon is not None:
            return

        # Einfaches Tray-Icon erstellen (blauer Kreis mit M)
        pixmap = QPixmap(64, 64)
        pixmap.fill(QGuiColor(0, 0, 0, 0))
        painter = QGuiPainter(pixmap)
        painter.setRenderHint(QGuiPainter.RenderHint.Antialiasing)
        painter.setBrush(QGuiColor("#5b8dd9"))
        painter.setPen(Qt.PenStyle.NoPen)
        painter.drawEllipse(2, 2, 60, 60)
        font = QGuiFont("Segoe UI", 30, QGuiFont.Weight.Bold)
        painter.setFont(font)
        painter.setPen(QGuiColor("white"))
        painter.drawText(pixmap.rect(), Qt.AlignmentFlag.AlignCenter, "M")
        painter.end()

        self.tray_icon = QSystemTrayIcon(QIcon(pixmap), self)
        self.tray_icon.setToolTip("MediaBrain")

        # Kontextmenu
        tray_menu = QMenu(self)
        act_show = QAction(_t("MediaBrain öffnen"), self)
        act_show.triggered.connect(self._restore_from_tray)
        tray_menu.addAction(act_show)

        tray_menu.addSeparator()

        act_quit = QAction(_t("Beenden"), self)
        act_quit.triggered.connect(self._quit_app)
        tray_menu.addAction(act_quit)

        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.activated.connect(self._on_tray_activated)
        self.tray_icon.show()

    def _remove_system_tray(self):
        """Entfernt das System-Tray-Icon."""
        if self.tray_icon is not None:
            self.tray_icon.hide()
            self.tray_icon.deleteLater()
            self.tray_icon = None

    def update_system_tray(self, enabled):
        """Aktiviert oder deaktiviert den System Tray."""
        if enabled:
            self._setup_system_tray()
        else:
            self._remove_system_tray()

    def _restore_from_tray(self):
        """Stellt das Fenster aus dem System Tray wieder her."""
        self.showNormal()
        self.activateWindow()
        self.raise_()

    def _on_tray_activated(self, reason):
        """Doppelklick auf Tray-Icon öffnet das Fenster."""
        if reason == QSystemTrayIcon.ActivationReason.DoubleClick:
            self._restore_from_tray()

    def _quit_app(self):
        """Beendet die Anwendung vollständig."""
        self._remove_system_tray()
        QApplication.instance().quit()

    def closeEvent(self, event):
        """Minimiert ins Tray statt zu schließen (wenn Tray aktiv)."""
        if self.tray_icon is not None and self.tray_icon.isVisible():
            event.ignore()
            self.hide()
            self.tray_icon.showMessage(
                "MediaBrain",
                _t("MediaBrain läuft im Hintergrund weiter.\nDoppelklick auf das Tray-Icon zum öffnen."),
                QSystemTrayIcon.MessageIcon.Information,
                2000
            )
        else:
            event.accept()

    def apply_theme(self):
        """Applies the current theme from config using ThemeEngine.

        Generates a complete QSS stylesheet and applies it to the
        entire application. Theme changes take effect immediately.
        """
        theme_key = config.config.get("ui.theme", "light")
        try:
            qss = _theme_engine.get_stylesheet(theme_key)
            QApplication.instance().setStyleSheet(qss)
        except Exception as e:
            logger.error("Failed to apply theme '%s': %s", theme_key, e)
