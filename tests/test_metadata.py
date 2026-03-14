"""
Tests for metadata_v2.py - MetadataCache and MetadataFetcher.

All external API calls are mocked; no network access required.
Run with: pytest tests/test_metadata.py -v
"""
import sys
import json
import hashlib
import tempfile
from pathlib import Path
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))
from metadata_v2 import MetadataCache, MetadataFetcher, TMDbFetcher, OMDbFetcher


# ============================================================
# Fixtures
# ============================================================

@pytest.fixture
def tmp_cache(tmp_path):
    """MetadataCache backed by a temporary SQLite file."""
    return MetadataCache(db_path=tmp_path / "test_cache.db")


@pytest.fixture
def sample_result():
    """A minimal metadata result dict."""
    return {"title": "Test Film", "year": "2024", "source": "tmdb", "type": "movie"}


# ============================================================
# MetadataCache Tests
# ============================================================

class TestMetadataCacheGet:
    def test_cache_miss_returns_none(self, tmp_cache):
        """cache.get() returns None for unknown key."""
        result = tmp_cache.get("movie", "Unknown Title XYZ")
        assert result is None

    def test_cache_put_and_get(self, tmp_cache, sample_result):
        """Stored result can be retrieved with identical parameters."""
        tmp_cache.put("movie", "Test Film", sample_result)
        retrieved = tmp_cache.get("movie", "Test Film")
        assert retrieved is not None
        assert retrieved["title"] == "Test Film"
        assert retrieved["source"] == "tmdb"

    def test_cache_put_none_is_ignored(self, tmp_cache):
        """put() with result=None stores nothing."""
        tmp_cache.put("movie", "Null Result", None)
        assert tmp_cache.get("movie", "Null Result") is None

    def test_cache_ttl_expiry(self, tmp_cache, sample_result):
        """Expired entries are not returned by get()."""
        key = MetadataCache._make_key("movie", "Expired Film")
        now = datetime.now()
        expired_at = (now - timedelta(days=1)).isoformat()

        import sqlite3
        conn = sqlite3.connect(tmp_cache.db_path)
        conn.execute(
            "INSERT INTO metadata_cache (cache_key, result_json, created_at, expires_at) "
            "VALUES (?, ?, ?, ?)",
            (key, json.dumps(sample_result), now.isoformat(), expired_at)
        )
        conn.commit()
        conn.close()

        result = tmp_cache.get("movie", "Expired Film")
        assert result is None

    def test_cache_with_optional_params(self, tmp_cache, sample_result):
        """Cache differentiates entries by media_type and year."""
        tmp_cache.put("movie", "Film A", sample_result, media_type="movie", year="2022")
        tmp_cache.put("movie", "Film A", {"title": "Film A", "year": "2023"}, media_type="movie", year="2023")

        r2022 = tmp_cache.get("movie", "Film A", media_type="movie", year="2022")
        r2023 = tmp_cache.get("movie", "Film A", media_type="movie", year="2023")
        assert r2022["year"] == "2024"   # from sample_result
        assert r2023["year"] == "2023"

    def test_clear_expired_removes_old_entries(self, tmp_cache, sample_result):
        """clear_expired() removes only expired entries."""
        # Add one valid and one expired entry
        tmp_cache.put("movie", "Valid Film", sample_result, ttl_days=30)

        key_expired = MetadataCache._make_key("movie", "Old Film")
        import sqlite3
        conn = sqlite3.connect(tmp_cache.db_path)
        conn.execute(
            "INSERT INTO metadata_cache (cache_key, result_json, created_at, expires_at) "
            "VALUES (?, ?, ?, ?)",
            (key_expired, json.dumps(sample_result),
             datetime.now().isoformat(),
             (datetime.now() - timedelta(days=1)).isoformat())
        )
        conn.commit()
        conn.close()

        tmp_cache.clear_expired()
        assert tmp_cache.get("movie", "Valid Film") is not None
        assert tmp_cache.get("movie", "Old Film") is None


# ============================================================
# MetadataFetcher Tests (mocked APIs)
# ============================================================

class TestMetadataFetcherMovie:
    def test_fetch_movie_uses_tmdb_when_available(self):
        """fetch_movie() returns TMDb result when API key is set."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = "fake_key"

        mock_search = {"id": 123, "title": "Inception", "overview": "A dream film."}
        mock_details = {**mock_search, "genres": [{"name": "Sci-Fi"}], "poster_path": "/abc.jpg"}

        with patch.object(fetcher.tmdb, "search_movie", return_value=mock_search):
            with patch.object(fetcher.tmdb, "get_movie_details", return_value=mock_details):
                result = fetcher.fetch_movie("Inception", year=2010)

        assert result is not None
        assert result["title"] == "Inception"
        assert result["source"] == "tmdb"

    def test_fetch_movie_falls_back_to_omdb(self):
        """fetch_movie() falls back to OMDb when TMDb is unavailable."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = ""  # TMDb disabled
        fetcher.omdb.api_key = "fake_omdb"

        omdb_raw = {
            "Response": "True", "Title": "Inception", "Plot": "A film.", "imdbID": "tt1375666",
            "Year": "2010", "Type": "movie", "Poster": "N/A", "imdbRating": "8.8",
            "Genre": "Action, Sci-Fi", "Director": "Nolan", "Actors": "DiCaprio", "Runtime": "148 min"
        }

        with patch.object(fetcher.omdb, "search", return_value=omdb_raw):
            result = fetcher.fetch_movie("Inception")

        assert result is not None
        assert result["source"] == "omdb"
        assert result["title"] == "Inception"

    def test_fetch_movie_returns_none_when_no_api_available(self):
        """fetch_movie() returns None when both TMDb and OMDb keys are missing."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = ""
        fetcher.omdb.api_key = ""
        result = fetcher.fetch_movie("Any Film")
        assert result is None


class TestMetadataFetcherCache:
    def test_fetch_movie_uses_cache_on_second_call(self, tmp_path):
        """Second fetch_movie() call returns cached result without API hit."""
        fetcher = MetadataFetcher(cache_enabled=True)
        fetcher.cache = MetadataCache(db_path=tmp_path / "cache.db")
        fetcher.tmdb.api_key = "fake_key"

        cached_data = {"title": "Cached Film", "source": "tmdb", "type": "movie"}
        fetcher.cache.put("movie", "Cached Film", cached_data, media_type="movie")

        with patch.object(fetcher.tmdb, "search_movie") as mock_search:
            result = fetcher.fetch_movie("Cached Film")
            mock_search.assert_not_called()

        assert result is not None
        assert result["title"] == "Cached Film"


class TestMetadataFetcherMusic:
    def test_fetch_music_via_musicbrainz(self):
        """fetch_music() returns formatted MusicBrainz result."""
        fetcher = MetadataFetcher(cache_enabled=False)

        mb_release = {
            "id": "abc-123",
            "title": "Dark Side of the Moon",
            "artist-credit": [{"artist": {"name": "Pink Floyd"}}],
            "date": "1973"
        }

        with patch.object(fetcher.musicbrainz, "search_release", return_value=mb_release):
            with patch.object(fetcher.musicbrainz, "get_cover_art", return_value=None):
                result = fetcher.fetch_music("Dark Side of the Moon", artist="Pink Floyd")

        assert result is not None
        assert result["title"] == "Dark Side of the Moon"
        assert result["year"] == "1973"
        assert result["type"] == "music"
        assert result["source"] == "musicbrainz"

    def test_fetch_music_no_result_returns_none(self):
        """fetch_music() returns None when MusicBrainz finds nothing."""
        fetcher = MetadataFetcher(cache_enabled=False)
        with patch.object(fetcher.musicbrainz, "search_release", return_value=None):
            result = fetcher.fetch_music("Nonexistent Album XYZ99")
        assert result is None

    def test_fetch_music_cover_art_included(self):
        """fetch_music() includes thumbnail_url when cover art is available."""
        fetcher = MetadataFetcher(cache_enabled=False)
        mb_release = {
            "id": "xyz-456",
            "title": "Abbey Road",
            "artist-credit": [{"artist": {"name": "The Beatles"}}],
            "date": "1969"
        }
        cover_url = "https://coverartarchive.org/release/xyz-456/12345.jpg"

        with patch.object(fetcher.musicbrainz, "search_release", return_value=mb_release):
            with patch.object(fetcher.musicbrainz, "get_cover_art", return_value=cover_url):
                result = fetcher.fetch_music("Abbey Road", artist="The Beatles")

        assert result is not None
        assert result["thumbnail_url"] == cover_url


# ============================================================
# TMDbFetcher.format_result Tests
# ============================================================

class TestTMDbFetcherFormatResult:
    def test_format_movie_basic_fields(self):
        """format_result() maps TMDb movie fields correctly."""
        fetcher = TMDbFetcher(api_key="fake")
        data = {
            "id": 27205,
            "title": "Inception",
            "overview": "A thief who steals corporate secrets.",
            "poster_path": "/abc.jpg",
            "backdrop_path": "/def.jpg",
            "vote_average": 8.8,
            "release_date": "2010-07-16",
            "genres": [{"id": 1, "name": "Sci-Fi"}, {"id": 2, "name": "Thriller"}]
        }
        result = fetcher.format_result(data, "movie")

        assert result["title"] == "Inception"
        assert result["description"] == "A thief who steals corporate secrets."
        assert result["tmdb_id"] == 27205
        assert result["type"] == "movie"
        assert result["source"] == "tmdb"
        assert result["year"] == "2010"
        assert result["rating"] == 8.8
        assert "Sci-Fi" in result["genres"]
        assert result["thumbnail_url"].endswith("/abc.jpg")

    def test_format_series_uses_name_field(self):
        """format_result() for series uses 'name' not 'title'."""
        fetcher = TMDbFetcher(api_key="fake")
        data = {
            "id": 1234,
            "name": "Breaking Bad",
            "overview": "A chemistry teacher becomes a drug lord.",
            "first_air_date": "2008-01-20",
            "vote_average": 9.5,
            "genres": []
        }
        result = fetcher.format_result(data, "series")

        assert result["title"] == "Breaking Bad"
        assert result["year"] == "2008"
        assert result["type"] == "series"

    def test_format_result_none_input_returns_none(self):
        """format_result(None) returns None."""
        fetcher = TMDbFetcher(api_key="fake")
        assert fetcher.format_result(None) is None

    def test_format_result_missing_optional_fields(self):
        """format_result() handles missing optional fields gracefully."""
        fetcher = TMDbFetcher(api_key="fake")
        data = {"id": 999, "title": "Minimal Film"}
        result = fetcher.format_result(data, "movie")

        assert result["title"] == "Minimal Film"
        assert result.get("year") is None
        assert result.get("thumbnail_url") is None
        assert result.get("backdrop_url") is None


# ============================================================
# OMDbFetcher.format_result Tests
# ============================================================

class TestOMDbFetcherFormatResult:
    def test_format_result_movie(self):
        """format_result() maps OMDb movie fields correctly."""
        fetcher = OMDbFetcher(api_key="fake")
        data = {
            "Response": "True",
            "Title": "The Dark Knight",
            "Plot": "Batman vs Joker.",
            "imdbID": "tt0468569",
            "Year": "2008",
            "Type": "movie",
            "Poster": "https://img.example.com/dk.jpg",
            "imdbRating": "9.0",
            "Genre": "Action, Crime, Drama",
            "Director": "Christopher Nolan",
            "Actors": "Christian Bale, Heath Ledger",
            "Runtime": "152 min"
        }
        result = fetcher.format_result(data)

        assert result["title"] == "The Dark Knight"
        assert result["year"] == "2008"
        assert result["source"] == "omdb"
        assert result["type"] == "movie"
        assert result["imdb_id"] == "tt0468569"
        assert result["rating"] == 9.0
        assert "Action" in result["genres"]
        assert result["director"] == "Christopher Nolan"
        assert result["thumbnail_url"] == "https://img.example.com/dk.jpg"

    def test_format_result_series_type(self):
        """format_result() maps 'series' type correctly."""
        fetcher = OMDbFetcher(api_key="fake")
        data = {
            "Title": "Game of Thrones", "Type": "series",
            "Year": "2011", "imdbID": "tt0944947",
            "Plot": "N/A", "imdbRating": "N/A",
            "Genre": "N/A", "Director": "N/A", "Actors": "N/A", "Runtime": "N/A",
            "Poster": "N/A"
        }
        result = fetcher.format_result(data)

        assert result["type"] == "series"
        assert result.get("thumbnail_url") is None
        assert result.get("rating") is None
        assert result.get("director") is None

    def test_format_result_none_input_returns_none(self):
        """format_result(None) returns None."""
        fetcher = OMDbFetcher(api_key="fake")
        assert fetcher.format_result(None) is None


# ============================================================
# MetadataFetcher.fetch_series Tests
# ============================================================

class TestMetadataFetcherSeries:
    def test_fetch_series_via_tmdb(self):
        """fetch_series() returns TMDb result for a TV show."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = "fake_key"

        mock_raw = {"id": 1396, "name": "Breaking Bad", "first_air_date": "2008-01-20", "vote_average": 9.5}
        mock_formatted = {"title": "Breaking Bad", "type": "series", "source": "tmdb", "year": "2008"}

        with patch.object(fetcher.tmdb, "search_tv", return_value=mock_raw):
            with patch.object(fetcher.tmdb, "format_result", return_value=mock_formatted):
                result = fetcher.fetch_series("Breaking Bad")

        assert result is not None
        assert result["source"] == "tmdb"

    def test_fetch_series_falls_back_to_omdb(self):
        """fetch_series() falls back to OMDb when TMDb unavailable."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = ""
        fetcher.omdb.api_key = "fake_omdb"

        omdb_raw = {
            "Response": "True", "Title": "The Wire", "Type": "series",
            "Year": "2002", "imdbID": "tt0306414", "Plot": "Baltimore.",
            "imdbRating": "N/A", "Genre": "N/A", "Director": "N/A", "Actors": "N/A",
            "Runtime": "N/A", "Poster": "N/A"
        }
        with patch.object(fetcher.omdb, "search", return_value=omdb_raw):
            result = fetcher.fetch_series("The Wire")

        assert result is not None
        assert result["source"] == "omdb"

    def test_fetch_series_returns_none_without_apis(self):
        """fetch_series() returns None when no API keys set."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = ""
        fetcher.omdb.api_key = ""
        assert fetcher.fetch_series("Any Show") is None


# ============================================================
# MetadataFetcher.auto_fetch Tests
# ============================================================

class TestMetadataFetcherAutoFetch:
    def test_auto_fetch_movie_type(self):
        """auto_fetch() with media_type='movie' calls fetch_movie()."""
        fetcher = MetadataFetcher(cache_enabled=False)
        expected = {"title": "Inception", "type": "movie", "source": "tmdb"}

        with patch.object(fetcher, "fetch_movie", return_value=expected) as mock_fm:
            result = fetcher.auto_fetch("Inception", media_type="movie")

        mock_fm.assert_called_once_with("Inception", None)
        assert result["type"] == "movie"

    def test_auto_fetch_series_type(self):
        """auto_fetch() with media_type='series' calls fetch_series()."""
        fetcher = MetadataFetcher(cache_enabled=False)
        expected = {"title": "Breaking Bad", "type": "series", "source": "tmdb"}

        with patch.object(fetcher, "fetch_series", return_value=expected) as mock_fs:
            result = fetcher.auto_fetch("Breaking Bad", media_type="tv")

        mock_fs.assert_called_once()
        assert result["type"] == "series"

    def test_auto_fetch_music_type(self):
        """auto_fetch() with media_type='music' calls fetch_music()."""
        fetcher = MetadataFetcher(cache_enabled=False)
        expected = {"title": "Abbey Road", "type": "music", "source": "musicbrainz"}

        with patch.object(fetcher, "fetch_music", return_value=expected) as mock_fm:
            result = fetcher.auto_fetch("Abbey Road", media_type="album", artist="The Beatles")

        mock_fm.assert_called_once_with("Abbey Road", "The Beatles")
        assert result["type"] == "music"

    def test_auto_fetch_unknown_type_tries_movie_first(self):
        """auto_fetch() with unknown type tries fetch_movie() first."""
        fetcher = MetadataFetcher(cache_enabled=False)
        movie_result = {"title": "Unknown Media", "type": "movie", "source": "tmdb"}

        with patch.object(fetcher, "fetch_movie", return_value=movie_result):
            with patch.object(fetcher, "fetch_series") as mock_series:
                result = fetcher.auto_fetch("Unknown Media", media_type="clip")

        mock_series.assert_not_called()
        assert result["type"] == "movie"

    def test_auto_fetch_unknown_type_falls_back_to_series(self):
        """auto_fetch() falls back to fetch_series() when fetch_movie() returns None."""
        fetcher = MetadataFetcher(cache_enabled=False)
        series_result = {"title": "Some Show", "type": "series", "source": "omdb"}

        with patch.object(fetcher, "fetch_movie", return_value=None):
            with patch.object(fetcher, "fetch_series", return_value=series_result):
                result = fetcher.auto_fetch("Some Show", media_type="clip")

        assert result["type"] == "series"


# ============================================================
# MetadataFetcher.get_status Tests
# ============================================================

class TestMetadataFetcherStatus:
    def test_get_status_with_keys(self):
        """get_status() returns True for configured API keys."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = "fake_tmdb"
        fetcher.omdb.api_key = "fake_omdb"
        status = fetcher.get_status()

        assert status["tmdb"] is True
        assert status["omdb"] is True
        assert status["musicbrainz"] is True  # always True

    def test_get_status_without_keys(self):
        """get_status() returns False for missing API keys."""
        fetcher = MetadataFetcher(cache_enabled=False)
        fetcher.tmdb.api_key = ""
        fetcher.omdb.api_key = ""
        status = fetcher.get_status()

        assert status["tmdb"] is False
        assert status["omdb"] is False
        assert status["musicbrainz"] is True  # no key needed


# ============================================================
# MetadataCache._make_key Tests
# ============================================================

class TestMetadataCacheMakeKey:
    def test_key_is_deterministic(self):
        """Same inputs always produce the same cache key."""
        k1 = MetadataCache._make_key("movie", "Inception", media_type="movie", year="2010")
        k2 = MetadataCache._make_key("movie", "Inception", media_type="movie", year="2010")
        assert k1 == k2

    def test_key_differs_by_year(self):
        """Different year produces different cache key."""
        k1 = MetadataCache._make_key("movie", "Inception", year="2010")
        k2 = MetadataCache._make_key("movie", "Inception", year="2011")
        assert k1 != k2

    def test_key_differs_by_source(self):
        """Different source produces different cache key."""
        k1 = MetadataCache._make_key("movie", "Inception")
        k2 = MetadataCache._make_key("series", "Inception")
        assert k1 != k2

    def test_key_is_case_insensitive(self):
        """Cache key is case-insensitive for query and source."""
        k1 = MetadataCache._make_key("movie", "Inception")
        k2 = MetadataCache._make_key("MOVIE", "INCEPTION")
        assert k1 == k2
