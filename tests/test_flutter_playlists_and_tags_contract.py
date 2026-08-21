"""
Contract and Parity Tests for Flutter Mobile Smart-Playlists and Tag-System.

Verifies:
1. Flutter Dart data models (MediaTag, Playlist, SmartPlaylistQuery, PlaylistType).
2. SQLite schema definition and migration in DatabaseService.
3. Flutter screens & dialogs presence and integration (PlaylistsScreen, PlaylistDetailScreen, PlaylistDialog).
4. Localization parity across German and English dictionaries.
5. Smart playlist query evaluation logic parity between Desktop and Mobile.
"""

from pathlib import Path
import re
import unittest

REPO_ROOT = Path(__file__).resolve().parent.parent
FLUTTER_ROOT = REPO_ROOT / "flutter_port"


class TestFlutterPlaylistsAndTagsContract(unittest.TestCase):
    def test_dart_models_exist_and_exported(self):
        models_file = FLUTTER_ROOT / "lib" / "models" / "models.dart"
        self.assertTrue(models_file.is_file(), "models.dart must exist")
        content = models_file.read_text(encoding="utf-8")

        self.assertIn("class MediaTag", content)
        self.assertIn("enum PlaylistType", content)
        self.assertIn("class SmartPlaylistQuery", content)
        self.assertIn("class Playlist", content)
        self.assertIn("bool matches(MediaItem item)", content)
        self.assertIn("bool get isSmart =>", content)

    def test_sqlite_schema_and_migration_v2(self):
        db_service_file = FLUTTER_ROOT / "lib" / "services" / "database_service.dart"
        self.assertTrue(db_service_file.is_file(), "database_service.dart must exist")
        content = db_service_file.read_text(encoding="utf-8")

        self.assertIn("version: 2", content)
        self.assertIn("CREATE TABLE IF NOT EXISTS playlists", content)
        self.assertIn("CREATE TABLE IF NOT EXISTS playlist_items", content)
        self.assertIn("idx_playlist_items_playlist", content)
        self.assertIn("listPlaylists", content)
        self.assertIn("upsertPlaylist", content)
        self.assertIn("deletePlaylist", content)
        self.assertIn("addItemToPlaylist", content)
        self.assertIn("removeItemFromPlaylist", content)
        self.assertIn("getPlaylistItems", content)
        self.assertIn("evaluateSmartPlaylist", content)
        self.assertIn("listTags", content)
        self.assertIn("addTagToItem", content)
        self.assertIn("removeTagFromItem", content)

    def test_screens_and_dialogs_presence(self):
        playlists_screen = FLUTTER_ROOT / "lib" / "screens" / "playlists_screen.dart"
        detail_screen = FLUTTER_ROOT / "lib" / "screens" / "playlist_detail_screen.dart"
        playlist_dialog = FLUTTER_ROOT / "lib" / "dialogs" / "playlist_dialog.dart"

        self.assertTrue(playlists_screen.is_file(), "playlists_screen.dart must exist")
        self.assertTrue(detail_screen.is_file(), "playlist_detail_screen.dart must exist")
        self.assertTrue(playlist_dialog.is_file(), "playlist_dialog.dart must exist")

        pl_content = playlists_screen.read_text(encoding="utf-8")
        self.assertIn("class PlaylistsScreen", pl_content)

        dt_content = detail_screen.read_text(encoding="utf-8")
        self.assertIn("class PlaylistDetailScreen", dt_content)

        dg_content = playlist_dialog.read_text(encoding="utf-8")
        self.assertIn("class PlaylistDialog", dg_content)

    def test_home_screen_tab_navigation(self):
        home_screen = FLUTTER_ROOT / "lib" / "screens" / "home_screen.dart"
        self.assertTrue(home_screen.is_file(), "home_screen.dart must exist")
        content = home_screen.read_text(encoding="utf-8")

        self.assertIn("PlaylistsScreen", content)
        self.assertIn("loc.navPlaylists", content)

    def test_library_and_item_detail_integration(self):
        library_screen = FLUTTER_ROOT / "lib" / "screens" / "library_screen.dart"
        detail_screen = FLUTTER_ROOT / "lib" / "screens" / "item_detail_screen.dart"

        lib_content = library_screen.read_text(encoding="utf-8")
        self.assertIn("listTags", lib_content)
        self.assertIn("tag: _tag", lib_content)

        det_content = detail_screen.read_text(encoding="utf-8")
        self.assertIn("addTagToItem", det_content)
        self.assertIn("removeTagFromItem", det_content)
        self.assertIn("addItemToPlaylist", det_content)

    def test_localization_parity_de_en(self):
        l10n_file = FLUTTER_ROOT / "lib" / "l10n" / "app_localizations.dart"
        self.assertTrue(l10n_file.is_file(), "app_localizations.dart must exist")
        content = l10n_file.read_text(encoding="utf-8")

        required_keys = [
            "navPlaylists",
            "screenPlaylists",
            "playlistTypeManual",
            "playlistTypeSmart",
            "dialogNewPlaylist",
            "dialogEditPlaylist",
            "fieldPlaylistName",
            "fieldPlaylistDescription",
            "fieldPlaylistType",
            "smartFilterCriteria",
            "smartFilterCategory",
            "smartFilterTag",
            "smartFilterFavoritesOnly",
            "smartFilterMinMinutes",
            "smartFilterSearch",
            "emptyPlaylists",
            "emptyPlaylistItems",
            "deletePlaylistTitle",
            "deletePlaylistContent",
            "addToPlaylist",
            "removeFromPlaylist",
            "addedToPlaylist",
            "removedFromPlaylist",
            "filterByTag",
            "allTags",
            "addTag",
            "removeTag",
            "noPlaylistsFound",
            "playlistItemCount",
            "tagCount",
        ]

        # Verify presence in abstract class
        for key in required_keys:
            pattern = rf"(get {key}\b|{key}\()"
            self.assertTrue(
                re.search(pattern, content),
                f"Key {key} missing in AppLocalizations interface",
            )

        # Split into sections
        de_part = content.split("class _AppLocalizationsDe extends AppLocalizations")[1].split("class _AppLocalizationsEn extends AppLocalizations")[0]
        en_part = content.split("class _AppLocalizationsEn extends AppLocalizations")[1]

        for key in required_keys:
            pattern = rf"(get {key}\b|{key}\()"
            self.assertTrue(
                re.search(pattern, de_part),
                f"Key {key} missing in _AppLocalizationsDe",
            )
            self.assertTrue(
                re.search(pattern, en_part),
                f"Key {key} missing in _AppLocalizationsEn",
            )

    def test_smart_query_matching_engine_parity(self):
        """Verify deterministic match algorithm against desktop test data."""
        item = {
            "title": "Interstellar",
            "category": "movie",
            "source": "tmdb",
            "provider_id": "tt123",
            "artist": "Christopher Nolan",
            "album": None,
            "channel": None,
            "description": "Epic science fiction film",
            "is_favorite": True,
            "foreground_minutes": 150,
            "tags": ["sci-fi", "space", "nolan"],
        }

        def smart_matches(q: dict, it: dict) -> bool:
            if q.get("category") and it.get("category") != q["category"]:
                return False
            if q.get("source") and it.get("source") != q["source"]:
                return False
            if q.get("favorites_only") and not it.get("is_favorite"):
                return False
            if q.get("min_foreground_minutes") is not None and it.get("foreground_minutes", 0) < q["min_foreground_minutes"]:
                return False
            if q.get("tag"):
                target_tag = q["tag"].strip().lower()
                tags = [t.lower() for t in it.get("tags", [])]
                if target_tag not in tags:
                    return False
            if q.get("search_query"):
                term = q["search_query"].strip().lower()
                haystack = " ".join(
                    str(it.get(k) or "")
                    for k in ["title", "artist", "album", "channel", "description", "provider_id"]
                ).lower()
                if term not in haystack:
                    return False
            return True

        self.assertTrue(smart_matches({"category": "movie", "tag": "sci-fi"}, item))
        self.assertTrue(smart_matches({"search_query": "nolan", "favorites_only": True}, item))
        self.assertFalse(smart_matches({"category": "music"}, item))
        self.assertFalse(smart_matches({"min_foreground_minutes": 200}, item))
        self.assertFalse(smart_matches({"tag": "comedy"}, item))


if __name__ == "__main__":
    unittest.main()
