"""Playlist/Collection system for MediaBrain.

Manages user-created playlists and collections of media items.
Playlists are stored in SQLite alongside media_items.
"""

import sqlite3
import logging
from datetime import datetime
from typing import List, Optional, Dict
from dataclasses import dataclass, field

logger = logging.getLogger("MediaBrain.Playlists")


@dataclass
class Playlist:
    """A user-created collection of media items."""
    id: int = 0
    name: str = ""
    description: str = ""
    playlist_type: str = "manual"  # "manual", "smart" (query-based)
    smart_query: str = ""  # JSON-encoded query for smart playlists
    created_at: str = ""
    updated_at: str = ""
    item_count: int = 0


class PlaylistManager:
    """Manages playlists and their items in the database."""

    def __init__(self, conn: sqlite3.Connection):
        self.conn = conn
        self._ensure_tables()

    def _ensure_tables(self):
        """Creates playlist tables if they don't exist."""
        self.conn.executescript("""
            CREATE TABLE IF NOT EXISTS playlists (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT DEFAULT '',
                playlist_type TEXT DEFAULT 'manual',
                smart_query TEXT DEFAULT '',
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS playlist_items (
                playlist_id INTEGER NOT NULL,
                media_id INTEGER NOT NULL,
                position INTEGER DEFAULT 0,
                added_at TEXT DEFAULT (datetime('now')),
                PRIMARY KEY (playlist_id, media_id),
                FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
                FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE
            );

            CREATE INDEX IF NOT EXISTS idx_playlist_items_playlist
                ON playlist_items(playlist_id);
        """)
        self.conn.commit()

    def create_playlist(self, name: str, description: str = "",
                       playlist_type: str = "manual", smart_query: str = "") -> int:
        """Creates a new playlist and returns its ID."""
        cursor = self.conn.execute(
            """INSERT INTO playlists (name, description, playlist_type, smart_query)
               VALUES (?, ?, ?, ?)""",
            (name, description, playlist_type, smart_query)
        )
        self.conn.commit()
        logger.info("Playlist erstellt: %s (ID %d)", name, cursor.lastrowid)
        return cursor.lastrowid

    def delete_playlist(self, playlist_id: int):
        """Deletes a playlist and all its item associations."""
        self.conn.execute("DELETE FROM playlists WHERE id = ?", (playlist_id,))
        self.conn.commit()

    def rename_playlist(self, playlist_id: int, new_name: str):
        """Renames a playlist."""
        self.conn.execute(
            "UPDATE playlists SET name = ?, updated_at = datetime('now') WHERE id = ?",
            (new_name, playlist_id)
        )
        self.conn.commit()

    def get_playlists(self) -> List[Playlist]:
        """Returns all playlists with item counts."""
        rows = self.conn.execute("""
            SELECT p.*, COUNT(pi.media_id) as item_count
            FROM playlists p
            LEFT JOIN playlist_items pi ON p.id = pi.playlist_id
            GROUP BY p.id
            ORDER BY p.name
        """).fetchall()

        return [Playlist(
            id=r[0], name=r[1], description=r[2],
            playlist_type=r[3], smart_query=r[4],
            created_at=r[5] or "", updated_at=r[6] or "",
            item_count=r[7]
        ) for r in rows]

    def get_playlist(self, playlist_id: int) -> Optional[Playlist]:
        """Returns a single playlist by ID."""
        row = self.conn.execute(
            "SELECT * FROM playlists WHERE id = ?", (playlist_id,)
        ).fetchone()
        if not row:
            return None
        return Playlist(
            id=row[0], name=row[1], description=row[2],
            playlist_type=row[3], smart_query=row[4],
            created_at=row[5] or "", updated_at=row[6] or ""
        )

    def add_item(self, playlist_id: int, media_id: int):
        """Adds a media item to a playlist."""
        # Position = naechste freie Position
        row = self.conn.execute(
            "SELECT COALESCE(MAX(position), -1) + 1 FROM playlist_items WHERE playlist_id = ?",
            (playlist_id,)
        ).fetchone()
        position = row[0] if row else 0

        self.conn.execute(
            "INSERT OR IGNORE INTO playlist_items (playlist_id, media_id, position) VALUES (?, ?, ?)",
            (playlist_id, media_id, position)
        )
        self.conn.execute(
            "UPDATE playlists SET updated_at = datetime('now') WHERE id = ?",
            (playlist_id,)
        )
        self.conn.commit()

    def remove_item(self, playlist_id: int, media_id: int):
        """Removes a media item from a playlist."""
        self.conn.execute(
            "DELETE FROM playlist_items WHERE playlist_id = ? AND media_id = ?",
            (playlist_id, media_id)
        )
        self.conn.commit()

    def get_items(self, playlist_id: int) -> List[int]:
        """Returns media item IDs in a playlist, ordered by position."""
        rows = self.conn.execute(
            "SELECT media_id FROM playlist_items WHERE playlist_id = ? ORDER BY position",
            (playlist_id,)
        ).fetchall()
        return [r[0] for r in rows]

    def reorder_item(self, playlist_id: int, media_id: int, new_position: int):
        """Moves an item to a new position within the playlist."""
        self.conn.execute(
            "UPDATE playlist_items SET position = ? WHERE playlist_id = ? AND media_id = ?",
            (new_position, playlist_id, media_id)
        )
        self.conn.commit()
