"""
Regression tests for QueryBuilder.

The builder must match MediaBrain's real media_items schema and must not copy
UI-provided SQL fragments such as conjunctions or sort directions into SQL.
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import Database, TagManager
from query_builder import QueryBuilder


class TestQueryBuilder(unittest.TestCase):
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.tags = TagManager(self.db)

        self.matrix_id = self._insert_media(
            title="The Matrix",
            media_type="movie",
            source="netflix",
            provider_id="netflix-matrix",
            is_favorite=1,
            length_seconds=8160,
        )
        self.youtube_id = self._insert_media(
            title="Matrix Explained",
            media_type="clip",
            source="youtube",
            provider_id="youtube-matrix",
            is_favorite=0,
            length_seconds=600,
        )
        self._insert_media(
            title="Quiet Jazz",
            media_type="music",
            source="spotify",
            provider_id="spotify-jazz",
            is_favorite=0,
            length_seconds=180,
        )

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    def _insert_media(self, title, media_type, source, provider_id,
                      is_favorite=0, length_seconds=0):
        cursor = self.db.execute(
            """
            INSERT INTO media_items
                (title, type, source, provider_id, is_favorite, length_seconds)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (title, media_type, source, provider_id, is_favorite, length_seconds),
        )
        return cursor.lastrowid

    def _run(self, builder):
        sql, params = builder.build()
        return sql, self.db.fetchall(sql, tuple(params))

    def test_provider_alias_targets_source_column(self):
        builder = QueryBuilder()
        builder.add_condition("provider", "=", "netflix")
        builder.add_condition("is_favorite", "=", True)
        builder.set_order("title", "DESC")

        sql, rows = self._run(builder)

        self.assertIn("source = ?", sql)
        self.assertNotIn("provider = ?", sql)
        self.assertEqual([row["title"] for row in rows], ["The Matrix"])

    def test_tag_filter_executes_against_schema(self):
        tag_id = self.tags.create_tag("SciFi")
        self.tags.add_tag_to_media(self.matrix_id, tag_id)

        builder = QueryBuilder()
        builder.add_condition("tags", "=", "SciFi")

        sql, rows = self._run(builder)

        self.assertIn("media_tags", sql)
        self.assertEqual([row["id"] for row in rows], [self.matrix_id])

    def test_conjunction_is_sanitized(self):
        builder = QueryBuilder()
        builder.add_condition("type", "=", "movie")
        builder.add_condition("title", "contains", "Matrix", conjunction="OR 1=1 --")

        sql, rows = self._run(builder)

        self.assertNotIn("1=1", sql)
        self.assertIn(" AND ", sql)
        self.assertEqual([row["id"] for row in rows], [self.matrix_id])

    def test_order_direction_is_sanitized(self):
        builder = QueryBuilder()
        builder.add_condition("title", "contains", "Matrix")
        builder.set_order("title", "DESC; DROP TABLE media_items")

        sql, rows = self._run(builder)

        self.assertIn("ORDER BY title ASC", sql)
        self.assertNotIn("DROP TABLE", sql)
        self.assertEqual([row["id"] for row in rows], [self.youtube_id, self.matrix_id])

    def test_tags_cannot_be_used_as_order_column(self):
        builder = QueryBuilder()
        builder.add_condition("title", "contains", "Matrix")
        builder.set_order("tags", "DESC")

        sql, rows = self._run(builder)

        self.assertNotIn("ORDER BY tags", sql)
        self.assertEqual(len(rows), 2)

    def test_like_wildcards_in_search_value_are_escaped(self):
        self._insert_media(
            title="100% Natural",
            media_type="movie",
            source="local",
            provider_id="local-natural",
        )
        self._insert_media(
            title="1000 Ways",
            media_type="movie",
            source="local",
            provider_id="local-ways",
        )

        builder = QueryBuilder()
        builder.add_condition("title", "contains", "100%")
        _, rows = self._run(builder)

        titles = [r["title"] for r in rows]
        self.assertIn("100% Natural", titles)
        self.assertNotIn("1000 Ways", titles)

    def test_like_underscore_in_search_value_is_escaped(self):
        self._insert_media(
            title="file_name.mp4",
            media_type="music",
            source="local",
            provider_id="local-filename",
        )
        self._insert_media(
            title="filename.mp4",
            media_type="music",
            source="local",
            provider_id="local-filename2",
        )

        builder = QueryBuilder()
        builder.add_condition("title", "contains", "file_name")
        _, rows = self._run(builder)

        titles = [r["title"] for r in rows]
        self.assertIn("file_name.mp4", titles)
        self.assertNotIn("filename.mp4", titles)

    def test_tag_contains_with_underscore_wildcard_is_escaped(self):
        scifi_id = self._insert_media(
            title="Dune",
            media_type="movie",
            source="local",
            provider_id="local-dune",
        )
        scixfi_id = self._insert_media(
            title="SciXFi Movie",
            media_type="movie",
            source="local",
            provider_id="local-scixfi",
        )
        tag_scifi = self.tags.create_tag("Sci_Fi")
        tag_scixfi = self.tags.create_tag("SciXFi")
        self.tags.add_tag_to_media(scifi_id, tag_scifi)
        self.tags.add_tag_to_media(scixfi_id, tag_scixfi)

        builder = QueryBuilder()
        builder.add_condition("tags", "contains", "Sci_Fi")
        _, rows = self._run(builder)

        ids = [r["id"] for r in rows]
        self.assertIn(scifi_id, ids)
        self.assertNotIn(scixfi_id, ids)


    def test_skipped_first_condition_does_not_produce_where_and(self):
        """If the first condition yields no SQL clause, later conditions must not
        receive a dangling conjunction (e.g. 'WHERE AND type = ?').

        Regression: build() used loop index (i > 0) instead of whether any
        clause had been emitted, causing invalid SQL when condition[0] was
        silently skipped (tags field + unimplemented operator like 'is_empty').
        """
        builder = QueryBuilder()
        builder.add_condition("tags", "is_empty", None)
        builder.add_condition("type", "=", "movie")
        sql, rows = self._run(builder)

        self.assertNotIn("WHERE AND", sql)
        self.assertIn("type = ?", sql)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["title"], "The Matrix")


if __name__ == "__main__":
    unittest.main()
