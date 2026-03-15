"""
test_tags.py
Unit Tests for TagManager (tag CRUD, media-tag associations, filtering)

Tests:
- Tag creation (normal, duplicate, empty, too-long)
- Tag deletion (cascading removal of associations)
- Tag renaming
- list_tags with usage counts
- add/remove tag from media
- get_tags_for_media
- get_media_ids_by_tags (AND logic)
- list_by_type_with_tags filtering
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

import unittest
import tempfile
import os
from core import Database, MediaManager, TagManager


class TestTagManager(unittest.TestCase):
    """Tests for TagManager CRUD operations and associations."""

    def setUp(self):
        self.db_fd, self.db_path = tempfile.mkstemp(suffix=".db")
        self.db = Database(self.db_path)
        self.mm = MediaManager(self.db)
        self.tm = TagManager(self.db)

        # Create test media items
        self.mm.add_or_update({
            "type": "movie", "source": "netflix",
            "provider_id": "mov1", "title": "Test Movie"
        })
        self.mm.add_or_update({
            "type": "music", "source": "spotify",
            "provider_id": "mus1", "title": "Test Song"
        })
        self.mm.add_or_update({
            "type": "movie", "source": "youtube",
            "provider_id": "mov2", "title": "Second Movie"
        })
        # Fetch IDs
        rows = self.db.fetchall("SELECT id, title FROM media_items ORDER BY id")
        self.movie1_id = rows[0]["id"]
        self.music1_id = rows[1]["id"]
        self.movie2_id = rows[2]["id"]

    def tearDown(self):
        self.db.close()
        os.close(self.db_fd)
        os.unlink(self.db_path)

    # --- Tag Creation ---

    def test_create_tag_returns_id(self):
        tag_id = self.tm.create_tag("Action")
        self.assertIsInstance(tag_id, int)
        self.assertGreater(tag_id, 0)

    def test_create_duplicate_tag_returns_existing_id(self):
        id1 = self.tm.create_tag("Drama")
        id2 = self.tm.create_tag("drama")  # case-insensitive
        self.assertEqual(id1, id2)

    def test_create_tag_empty_raises(self):
        with self.assertRaises(ValueError):
            self.tm.create_tag("")

    def test_create_tag_whitespace_only_raises(self):
        with self.assertRaises(ValueError):
            self.tm.create_tag("   ")

    def test_create_tag_too_long_raises(self):
        with self.assertRaises(ValueError):
            self.tm.create_tag("x" * 51)

    def test_create_tag_with_color(self):
        tag_id = self.tm.create_tag("Horror", "#FF0000")
        tags = self.tm.list_tags()
        found = [t for t in tags if t["id"] == tag_id]
        self.assertEqual(len(found), 1)
        self.assertEqual(found[0]["color"], "#FF0000")

    # --- Tag Deletion ---

    def test_delete_tag(self):
        tag_id = self.tm.create_tag("ToDelete")
        self.tm.delete_tag(tag_id)
        tags = self.tm.list_tags()
        self.assertEqual(len([t for t in tags if t["id"] == tag_id]), 0)

    def test_delete_tag_cascades_associations(self):
        tag_id = self.tm.create_tag("Cascade")
        self.tm.add_tag_to_media(self.movie1_id, tag_id)
        self.tm.delete_tag(tag_id)
        tags = self.tm.get_tags_for_media(self.movie1_id)
        self.assertEqual(len([t for t in tags if t["id"] == tag_id]), 0)

    # --- Tag Renaming ---

    def test_rename_tag(self):
        tag_id = self.tm.create_tag("OldName")
        self.tm.rename_tag(tag_id, "NewName")
        tags = self.tm.list_tags()
        found = [t for t in tags if t["id"] == tag_id]
        self.assertEqual(found[0]["name"], "NewName")

    # --- List Tags ---

    def test_list_tags_with_counts(self):
        t1 = self.tm.create_tag("Action")
        t2 = self.tm.create_tag("Comedy")
        self.tm.add_tag_to_media(self.movie1_id, t1)
        self.tm.add_tag_to_media(self.movie2_id, t1)
        self.tm.add_tag_to_media(self.movie1_id, t2)

        tags = self.tm.list_tags()
        action_tag = [t for t in tags if t["name"] == "Action"][0]
        comedy_tag = [t for t in tags if t["name"] == "Comedy"][0]
        self.assertEqual(action_tag["count"], 2)
        self.assertEqual(comedy_tag["count"], 1)

    def test_list_tags_sorted_by_usage(self):
        t1 = self.tm.create_tag("Rare")
        t2 = self.tm.create_tag("Popular")
        self.tm.add_tag_to_media(self.movie1_id, t2)
        self.tm.add_tag_to_media(self.movie2_id, t2)
        self.tm.add_tag_to_media(self.movie1_id, t1)

        tags = self.tm.list_tags()
        self.assertEqual(tags[0]["name"], "Popular")

    # --- Media-Tag Associations ---

    def test_add_tag_to_media(self):
        tag_id = self.tm.create_tag("SciFi")
        self.tm.add_tag_to_media(self.movie1_id, tag_id)
        tags = self.tm.get_tags_for_media(self.movie1_id)
        self.assertEqual(len(tags), 1)
        self.assertEqual(tags[0]["name"], "SciFi")

    def test_add_tag_idempotent(self):
        tag_id = self.tm.create_tag("SciFi")
        self.tm.add_tag_to_media(self.movie1_id, tag_id)
        self.tm.add_tag_to_media(self.movie1_id, tag_id)  # Duplicate
        tags = self.tm.get_tags_for_media(self.movie1_id)
        self.assertEqual(len(tags), 1)

    def test_remove_tag_from_media(self):
        tag_id = self.tm.create_tag("ToRemove")
        self.tm.add_tag_to_media(self.movie1_id, tag_id)
        self.tm.remove_tag_from_media(self.movie1_id, tag_id)
        tags = self.tm.get_tags_for_media(self.movie1_id)
        self.assertEqual(len(tags), 0)

    def test_get_tags_for_media_empty(self):
        tags = self.tm.get_tags_for_media(self.movie1_id)
        self.assertEqual(tags, [])

    # --- AND-Logic Filtering ---

    def test_get_media_ids_by_tags_and_logic(self):
        t1 = self.tm.create_tag("Action")
        t2 = self.tm.create_tag("SciFi")
        # movie1 has both tags
        self.tm.add_tag_to_media(self.movie1_id, t1)
        self.tm.add_tag_to_media(self.movie1_id, t2)
        # movie2 has only Action
        self.tm.add_tag_to_media(self.movie2_id, t1)

        # AND: both tags -> only movie1
        ids = self.tm.get_media_ids_by_tags([t1, t2])
        self.assertEqual(ids, [self.movie1_id])

    def test_get_media_ids_by_single_tag(self):
        t1 = self.tm.create_tag("Action")
        self.tm.add_tag_to_media(self.movie1_id, t1)
        self.tm.add_tag_to_media(self.movie2_id, t1)

        ids = self.tm.get_media_ids_by_tags([t1])
        self.assertIn(self.movie1_id, ids)
        self.assertIn(self.movie2_id, ids)

    def test_get_media_ids_by_empty_tags(self):
        ids = self.tm.get_media_ids_by_tags([])
        self.assertEqual(ids, [])

    # --- list_by_type_with_tags ---

    def test_list_by_type_with_tags_filters(self):
        t1 = self.tm.create_tag("Action")
        self.tm.add_tag_to_media(self.movie1_id, t1)
        # movie2 has no tag

        items = self.mm.list_by_type_with_tags("movie", tag_ids=[t1])
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0].id, self.movie1_id)

    def test_list_by_type_with_tags_no_filter(self):
        items = self.mm.list_by_type_with_tags("movie", tag_ids=None)
        self.assertEqual(len(items), 2)  # Both movies


if __name__ == "__main__":
    unittest.main()
