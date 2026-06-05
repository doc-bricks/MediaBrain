"""
Regression tests for SearchEngine.

The engine must escape LIKE wildcards in user-supplied text so that
'%' and '_' are treated as literals, not SQL pattern metacharacters.
"""

import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import Database
from search_advanced import SearchEngine, SearchCriteria


class TestSearchEngineLikeEscaping(unittest.TestCase):
    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.engine = SearchEngine(self.db)

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    def _insert(self, title, provider_id):
        self.db.conn.execute(
            "INSERT INTO media_items (title, type, source, provider_id) VALUES (?, 'movie', 'local', ?)",
            (title, provider_id),
        )
        self.db.conn.commit()

    def _search_titles(self, text):
        c = SearchCriteria()
        c.text = text
        c.exclude_blacklist = False
        return [r.title for r in self.engine.search(c)]

    def test_percent_wildcard_in_text_is_escaped(self):
        """'100%' must not match '1000 Ways' — % must be literal."""
        self._insert("100% Natural", "id-natural")
        self._insert("1000 Ways", "id-ways")

        titles = self._search_titles("100%")

        self.assertIn("100% Natural", titles)
        self.assertNotIn("1000 Ways", titles)

    def test_underscore_wildcard_in_text_is_escaped(self):
        """'file_name' must not match 'filename' — _ must be literal."""
        self._insert("file_name.mp4", "id-underscore")
        self._insert("filename.mp4", "id-nounderscore")

        titles = self._search_titles("file_name")

        self.assertIn("file_name.mp4", titles)
        self.assertNotIn("filename.mp4", titles)

    def test_get_suggestions_percent_is_escaped(self):
        """get_suggestions must also escape % so it's treated as literal."""
        self._insert("100% Natural", "id-natural2")
        self._insert("1000 Ways", "id-ways2")

        suggestions = self.engine.get_suggestions("100%")

        self.assertIn("100% Natural", suggestions)
        self.assertNotIn("1000 Ways", suggestions)


class TestSearchEngineTagFilter(unittest.TestCase):
    """Regression: criteria.tags wurde in search() ignoriert — Tag-Filter hatte keinen Effekt."""

    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        from core import TagManager
        self.tag_manager = TagManager(self.db)
        self.engine = SearchEngine(self.db)

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    def _insert(self, title, provider_id):
        self.db.conn.execute(
            "INSERT INTO media_items (title, type, source, provider_id) VALUES (?, 'movie', 'local', ?)",
            (title, provider_id),
        )
        self.db.conn.commit()
        row = self.db.conn.execute(
            "SELECT id FROM media_items WHERE provider_id = ?", (provider_id,)
        ).fetchone()
        return row["id"]

    def test_tag_filter_excludes_items_without_tag(self):
        """search() mit criteria.tags muss Items ohne den Tag herausfiltern.

        'Reaction Movie' hat den Tag 'Reaction' — ein LIKE-Substring-Match würde
        'Action' in 'Reaction' finden und es fälschlicherweise einschließen.
        Exakter Match darf es nicht zurückgeben.
        """
        id1 = self._insert("Action Movie", "id-action")
        id2 = self._insert("Drama Movie", "id-drama")
        id3 = self._insert("Reaction Movie", "id-reaction")

        tag_action = self.tag_manager.create_tag("Action")
        tag_reaction = self.tag_manager.create_tag("Reaction")
        self.tag_manager.add_tag_to_media(id1, tag_action)
        self.tag_manager.add_tag_to_media(id3, tag_reaction)

        c = SearchCriteria()
        c.tags = ["Action"]
        c.exclude_blacklist = False

        results = self.engine.search(c)
        titles = [r.title for r in results]

        self.assertIn("Action Movie", titles)
        self.assertNotIn("Drama Movie", titles)
        self.assertNotIn("Reaction Movie", titles)


if __name__ == "__main__":
    unittest.main()
