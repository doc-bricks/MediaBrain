"""Playlist/Collection system for MediaBrain.

Manages user-created playlists and collections of media items.
Playlists are stored in SQLite alongside media_items.
"""

import json
import sqlite3
import logging
from typing import List, Optional
from dataclasses import dataclass

from query_builder import QueryBuilder

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

    def create_smart_playlist(self, name: str, smart_query: str,
                              description: str = "") -> int:
        """Creates a smart playlist backed by QueryBuilder JSON."""
        return self.create_playlist(
            name=name,
            description=description,
            playlist_type="smart",
            smart_query=smart_query,
        )

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

        playlists = []
        for row in rows:
            item_count = row[7]
            if row[3] == "smart":
                item_count = self._count_smart_items(row[4] or "")
            playlists.append(self._playlist_from_row(row, item_count=item_count))
        return playlists

    def get_playlist(self, playlist_id: int) -> Optional[Playlist]:
        """Returns a single playlist by ID."""
        row = self._get_playlist_row(playlist_id)
        if not row:
            return None
        playlist = self._playlist_from_row(row)
        if playlist.playlist_type == "smart":
            playlist.item_count = self._count_smart_items(playlist.smart_query)
        else:
            playlist.item_count = self._count_manual_items(playlist.id)
        return playlist

    def add_item(self, playlist_id: int, media_id: int):
        """Adds a media item to a playlist."""
        # Position = nächste freie Position
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
        playlist_row = self._get_playlist_row(playlist_id)
        if not playlist_row:
            return []
        if playlist_row[3] == "smart":
            return [self._row_value(row, "id", 0) for row in self._execute_smart_query(
                playlist_row[4] or ""
            )]

        rows = self.conn.execute(
            "SELECT media_id FROM playlist_items WHERE playlist_id = ? ORDER BY position",
            (playlist_id,)
        ).fetchall()
        return [r[0] for r in rows]

    def get_media_rows(self, playlist_id: int) -> List[sqlite3.Row]:
        """Returns full media rows for manual or smart playlists."""
        playlist_row = self._get_playlist_row(playlist_id)
        if not playlist_row:
            return []
        if playlist_row[3] == "smart":
            return self._execute_smart_query(playlist_row[4] or "")
        return self.conn.execute("""
            SELECT m.*
            FROM media_items m
            INNER JOIN playlist_items pi ON m.id = pi.media_id
            WHERE pi.playlist_id = ?
            ORDER BY pi.position
        """, (playlist_id,)).fetchall()

    def reorder_item(self, playlist_id: int, media_id: int, new_position: int):
        """Moves an item to a new position within the playlist."""
        self.conn.execute(
            "UPDATE playlist_items SET position = ? WHERE playlist_id = ? AND media_id = ?",
            (new_position, playlist_id, media_id)
        )
        self.conn.commit()

    def update_smart_query(self, playlist_id: int, smart_query: str):
        """Updates the QueryBuilder JSON of a smart playlist."""
        self.conn.execute(
            """UPDATE playlists
               SET smart_query = ?, playlist_type = 'smart',
                   updated_at = datetime('now')
               WHERE id = ?""",
            (smart_query, playlist_id),
        )
        self.conn.commit()

    def _get_playlist_row(self, playlist_id: int):
        return self.conn.execute(
            "SELECT * FROM playlists WHERE id = ?", (playlist_id,)
        ).fetchone()

    def _playlist_from_row(self, row, item_count: int = 0) -> Playlist:
        """Converts a playlists row to the dataclass used by callers."""
        return Playlist(
            id=row[0], name=row[1], description=row[2],
            playlist_type=row[3], smart_query=row[4] or "",
            created_at=row[5] or "", updated_at=row[6] or "",
            item_count=item_count,
        )

    def _count_manual_items(self, playlist_id: int) -> int:
        row = self.conn.execute(
            "SELECT COUNT(*) FROM playlist_items WHERE playlist_id = ?",
            (playlist_id,),
        ).fetchone()
        return row[0] if row else 0

    def _count_smart_items(self, smart_query: str) -> int:
        query = self._build_smart_query(smart_query)
        if not query:
            return 0
        sql, params = query
        row = self.conn.execute(
            f"SELECT COUNT(*) FROM ({sql}) AS smart_playlist_items",
            params,
        ).fetchone()
        return row[0] if row else 0

    def _execute_smart_query(self, smart_query: str) -> List[sqlite3.Row]:
        query = self._build_smart_query(smart_query)
        if not query:
            return []
        sql, params = query
        return self.conn.execute(sql, params).fetchall()

    def _build_smart_query(self, smart_query: str):
        if not smart_query or not smart_query.strip():
            return None

        try:
            payload = json.loads(smart_query)
        except json.JSONDecodeError as exc:
            logger.warning("Ungueltige Smart-Playlist-Query: %s", exc)
            return None

        if not self._is_valid_smart_payload(payload):
            logger.warning("Ungueltiges Smart-Playlist-Query-Format")
            return None

        builder = QueryBuilder.from_json(smart_query)
        return builder.build()

    def _is_valid_smart_payload(self, payload) -> bool:
        if not isinstance(payload, dict):
            return False

        conditions = payload.get("conditions", [])
        if conditions is None:
            conditions = []
        if not isinstance(conditions, list):
            return False
        for condition in conditions:
            if not isinstance(condition, dict):
                return False
            field = condition.get("field")
            operator = condition.get("operator")
            if field not in QueryBuilder.VALID_FIELDS:
                return False
            if operator not in QueryBuilder.VALID_OPERATORS:
                return False

        order_by = payload.get("order_by")
        if order_by and order_by not in QueryBuilder.ORDERABLE_FIELDS:
            return False

        return True

    def _row_value(self, row, key: str, index: int):
        try:
            return row[key]
        except (IndexError, KeyError, TypeError):
            return row[index]
