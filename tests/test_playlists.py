"""
Regression tests for PlaylistManager smart playlists.

Smart playlists store a QueryBuilder JSON query and must evaluate it against
the current media_items table instead of relying on persisted playlist_items.
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import Database, TagManager
from playlists import PlaylistManager
from query_builder import QueryBuilder


class TestPlaylistManager(unittest.TestCase):
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.playlists = PlaylistManager(self.db.conn)
        self.tags = TagManager(self.db)

        self.matrix_id = self._insert_media(
            title="The Matrix",
            media_type="movie",
            source="netflix",
            provider_id="netflix-matrix",
            is_favorite=1,
        )
        self.arrival_id = self._insert_media(
            title="Arrival",
            media_type="movie",
            source="prime",
            provider_id="prime-arrival",
            is_favorite=0,
        )
        self.clip_id = self._insert_media(
            title="Matrix Explained",
            media_type="clip",
            source="youtube",
            provider_id="youtube-matrix",
            is_favorite=1,
        )

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    def _insert_media(self, title, media_type, source, provider_id, is_favorite=0):
        cursor = self.db.execute(
            """
            INSERT INTO media_items
                (title, type, source, provider_id, is_favorite)
            VALUES (?, ?, ?, ?, ?)
            """,
            (title, media_type, source, provider_id, is_favorite),
        )
        return cursor.lastrowid

    def test_manual_playlist_items_still_use_playlist_items_table(self):
        playlist_id = self.playlists.create_playlist("Manual Picks")
        self.playlists.add_item(playlist_id, self.clip_id)
        self.playlists.add_item(playlist_id, self.matrix_id)

        self.assertEqual(
            self.playlists.get_items(playlist_id),
            [self.clip_id, self.matrix_id],
        )

    def test_smart_playlist_uses_query_builder_json(self):
        query = QueryBuilder()
        query.add_condition("type", "=", "movie")
        query.add_condition("favorite", "=", True)
        query.set_order("title", "ASC")

        playlist_id = self.playlists.create_smart_playlist(
            "Favorite Movies",
            query.to_json(),
        )

        self.assertEqual(self.playlists.get_items(playlist_id), [self.matrix_id])

        self.db.execute(
            "UPDATE media_items SET is_favorite = 1 WHERE id = ?",
            (self.arrival_id,),
        )

        self.assertEqual(
            self.playlists.get_items(playlist_id),
            [self.arrival_id, self.matrix_id],
        )

    def test_smart_playlist_count_is_dynamic(self):
        query = QueryBuilder()
        query.add_condition("type", "=", "movie")
        playlist_id = self.playlists.create_smart_playlist(
            "All Movies",
            query.to_json(),
        )

        playlists = self.playlists.get_playlists()

        self.assertEqual(playlists[0].id, playlist_id)
        self.assertEqual(playlists[0].item_count, 2)

    def test_smart_playlist_supports_tag_filters(self):
        tag_id = self.tags.create_tag("SciFi")
        self.tags.add_tag_to_media(self.matrix_id, tag_id)

        query = QueryBuilder()
        query.add_condition("tags", "=", "SciFi")
        playlist_id = self.playlists.create_smart_playlist(
            "Tagged SciFi",
            query.to_json(),
        )

        self.assertEqual(self.playlists.get_items(playlist_id), [self.matrix_id])

    def test_malformed_smart_query_returns_no_items(self):
        playlist_id = self.playlists.create_playlist(
            "Broken Smart",
            playlist_type="smart",
            smart_query="{not-json",
        )

        self.assertEqual(self.playlists.get_items(playlist_id), [])


if __name__ == "__main__":
    unittest.main()
