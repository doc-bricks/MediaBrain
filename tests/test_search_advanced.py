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


if __name__ == "__main__":
    unittest.main()
