"""
metadata_v2.py
Erweiterte Metadaten-Fetch-Funktionen für MediaBrain.
- OpenGraph für URLs
- TMDb für Filme/Serien
- OMDb für Filme (Fallback)
- MusicBrainz für Musik (Basis)

Version: 2.0
"""
import logging
import requests
import re
import os
import json
import sqlite3
import hashlib
from pathlib import Path
from datetime import datetime, timedelta
from urllib.parse import parse_qs, urlparse

logger = logging.getLogger(__name__)

# Optionale Imports
try:
    from bs4 import BeautifulSoup
    HAS_BS4 = True
except ImportError:
    HAS_BS4 = False

try:
    from mutagen import File as MutagenFile
    HAS_MUTAGEN = True
except ImportError:
    MutagenFile = None
    HAS_MUTAGEN = False

try:
    from pymediainfo import MediaInfo
    HAS_MEDIAINFO = True
except ImportError:
    MediaInfo = None
    HAS_MEDIAINFO = False

# ============================================================
# Konfiguration - API Keys werden aus Umgebung oder Config geladen
# ============================================================

CONFIG_PATH = Path(__file__).parent / "settings.json"
YOUTUBE_OEMBED_URL = "https://www.youtube.com/oembed"
SPOTIFY_OEMBED_URL = "https://open.spotify.com/oembed"


def _extract_youtube_video_id(url):
    """Extrahiert eine YouTube-Video-ID aus verschiedenen URL-Formen."""
    parsed = urlparse(url)
    host = parsed.netloc.lower()

    if "youtu.be" in host:
        return parsed.path.strip("/").split("/")[0] or None

    if "youtube.com" in host:
        query_id = parse_qs(parsed.query).get("v", [None])[0]
        if query_id:
            return query_id

        parts = [part for part in parsed.path.split("/") if part]
        if len(parts) >= 2 and parts[0] in {"shorts", "embed"}:
            return parts[1]

    return None


def _is_youtube_url(url):
    """Prueft, ob eine URL auf YouTube zeigt."""
    if not url:
        return False
    parsed = urlparse(url)
    host = parsed.netloc.lower()
    return "youtube.com" in host or "youtu.be" in host


def _normalize_youtube_url(url):
    """Gibt eine kanonische YouTube-Watch-URL zurueck, wenn moeglich."""
    video_id = _extract_youtube_video_id(url)
    if not video_id:
        return None
    return f"https://www.youtube.com/watch?v={video_id}"


def _is_spotify_url(url):
    """Prueft, ob eine URL auf Spotify zeigt."""
    if not url:
        return False
    parsed = urlparse(url)
    host = parsed.netloc.lower()
    return "spotify.com" in host or "spotify.link" in host


def _normalize_spotify_url(url=None, provider_subtype=None, provider_id=None):
    """Gibt eine kanonische Spotify-URL fuer oEmbed zurueck, wenn moeglich."""
    if url and _is_spotify_url(url):
        return url

    if provider_id:
        spotify_kind = provider_subtype or "track"
        return f"https://open.spotify.com/{spotify_kind}/{provider_id}"

    return None

def get_api_key(service):
    """Holt API-Key aus settings.json oder Umgebungsvariable."""
    # 1. Umgebungsvariable
    env_key = os.environ.get(f"{service.upper()}_API_KEY")
    if env_key:
        return env_key
    
    # 2. settings.json
    if CONFIG_PATH.exists():
        try:
            with open(CONFIG_PATH, "r", encoding="utf-8") as f:
                config = json.load(f)
                return config.get("api_keys", {}).get(service, "")
        except (json.JSONDecodeError, IOError):
            pass
    
    return ""

# ============================================================
# 1. OpenGraph Metadata (wie bisher)
# ============================================================

def fetch_opengraph(url):
    """Holt OpenGraph-Metadaten von einer URL."""
    if not HAS_BS4:
        return None
    
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        response = requests.get(url, headers=headers, timeout=5)
        
        if response.status_code != 200:
            return None
            
        soup = BeautifulSoup(response.text, 'html.parser')
        data = {}

        # Titel
        og_title = soup.find("meta", property="og:title")
        if og_title and og_title.get("content"):
            title = og_title["content"]
            title = title.replace(" - YouTube", "").replace(" | Netflix", "")
            data["title"] = title
        else:
            data["title"] = soup.title.string if soup.title else "Unbekannter Titel"

        # Beschreibung
        og_desc = soup.find("meta", property="og:description")
        if og_desc:
            data["description"] = og_desc.get("content")

        # Thumbnail
        og_image = soup.find("meta", property="og:image")
        if og_image:
            data["thumbnail_url"] = og_image.get("content")

        return data

    except Exception as e:
        logger.error(f"[Metadata] OpenGraph Fehler bei {url}: {e}")
        return None


def fetch_youtube_oembed(url):
    """Holt Metadaten von YouTube ueber das oEmbed-Endpunkt."""
    watch_url = _normalize_youtube_url(url)
    if not watch_url:
        return None

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        response = requests.get(
            YOUTUBE_OEMBED_URL,
            params={"url": watch_url, "format": "json"},
            headers=headers,
            timeout=5
        )

        if response.status_code != 200:
            return None

        data = response.json()
        if not data:
            return None

        return {
            "title": data.get("title"),
            "thumbnail_url": data.get("thumbnail_url"),
            "channel": data.get("author_name"),
            "author_name": data.get("author_name"),
            "provider_id": _extract_youtube_video_id(watch_url),
            "source": "youtube",
            "metadata_source": "youtube_oembed",
            "type": "clip",
        }

    except Exception as e:
        logger.warning(f"[Metadata] YouTube oEmbed Fehler bei {url}: {e}")
        return None


def fetch_spotify_oembed(url, provider_subtype=None, provider_id=None):
    """Holt Metadaten von Spotify ueber den oEmbed-Endpunkt."""
    spotify_url = _normalize_spotify_url(url, provider_subtype, provider_id) or url
    if not spotify_url or not _is_spotify_url(spotify_url):
        return None

    if not provider_id:
        parsed = urlparse(spotify_url)
        parts = [part for part in parsed.path.split("/") if part]
        if len(parts) >= 2 and parts[0] in {"track", "album", "playlist", "artist", "episode", "show"}:
            provider_subtype = provider_subtype or parts[0]
            provider_id = parts[1]

    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        response = requests.get(
            SPOTIFY_OEMBED_URL,
            params={"url": spotify_url},
            headers=headers,
            timeout=5
        )

        if response.status_code != 200:
            return None

        data = response.json()
        if not data:
            return None

        result = {
            "title": data.get("title"),
            "thumbnail_url": data.get("thumbnail_url"),
            "source": "spotify",
            "metadata_source": "spotify_oembed",
            "type": "music",
        }

        if provider_id:
            result["provider_id"] = provider_id
        if provider_subtype:
            result["provider_subtype"] = provider_subtype
        if data.get("provider_url"):
            result["provider_url"] = data.get("provider_url")

        return result

    except Exception as e:
        logger.warning(f"[Metadata] Spotify oEmbed Fehler bei {url}: {e}")
        return None


LOCAL_SUFFIX_TYPES = {
    # Video
    ".mp4": "movie",
    ".mkv": "movie",
    ".avi": "movie",
    ".mov": "movie",
    ".wmv": "movie",
    ".webm": "clip",
    # Audio
    ".mp3": "music",
    ".flac": "music",
    ".wav": "music",
    ".m4a": "music",
    ".aac": "music",
    ".ogg": "music",
    ".m4b": "audiobook",
    # Dokumente
    ".pdf": "document",
    ".epub": "document",
}


def _local_media_type(path: Path) -> str:
    return LOCAL_SUFFIX_TYPES.get(path.suffix.lower(), "file")


LOCAL_COVER_FILENAMES = ("cover", "folder", "front", "poster", "album", "art", "thumbnail")
LOCAL_COVER_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif")


def _find_local_cover_art(path: Path):
    """Findet ein lokales Coverbild neben der Mediendatei."""
    if not path.exists():
        return None

    search_dir = path if path.is_dir() else path.parent
    candidate_stems = [path.stem] + list(LOCAL_COVER_FILENAMES)

    for stem in candidate_stems:
        for extension in LOCAL_COVER_EXTENSIONS:
            candidate = search_dir / f"{stem}{extension}"
            if candidate.is_file():
                try:
                    return candidate.resolve().as_uri()
                except ValueError:
                    return str(candidate.resolve())

    return None


def _tag_value_text(value):
    if value is None:
        return None
    if isinstance(value, dict):
        if "text" in value:
            return _tag_value_text(value["text"])
        if "value" in value:
            return _tag_value_text(value["value"])
    if hasattr(value, "text"):
        return _tag_value_text(value.text)
    if isinstance(value, (list, tuple)):
        for item in value:
            text = _tag_value_text(item)
            if text:
                return text
        return None
    text = str(value).strip()
    return text or None


def _tag_lookup(tags, *keys):
    if not tags:
        return None

    for key in keys:
        value = None
        if hasattr(tags, "get"):
            value = tags.get(key)
        else:
            try:
                value = tags[key]
            except Exception:
                value = None

        text = _tag_value_text(value)
        if text:
            return text

    return None


def _extract_mutagen_metadata(path: Path):
    if not HAS_MUTAGEN or MutagenFile is None:
        return None

    try:
        audio = MutagenFile(str(path))
    except Exception as e:
        logger.debug("[Metadata] Mutagen Fehler bei %s: %s", path, e)
        return None

    if not audio:
        return None

    tags = getattr(audio, "tags", None)
    result = {}

    title = _tag_lookup(tags, "TIT2", "\xa9nam", "title", "TITLE")
    if title:
        result["title"] = title

    artist = _tag_lookup(tags, "TPE1", "\xa9ART", "artist", "ARTIST")
    if artist:
        result["artist"] = artist

    album = _tag_lookup(tags, "TALB", "\xa9alb", "album", "ALBUM")
    if album:
        result["album"] = album

    description = _tag_lookup(tags, "COMM", "\xa9cmt", "comment", "description")
    if description:
        result["description"] = description

    year = _tag_lookup(tags, "TDRC", "\xa9day", "date", "year")
    if year:
        result["year"] = year[:4]

    info = getattr(audio, "info", None)
    length = getattr(info, "length", None)
    if length is not None:
        try:
            result["length_seconds"] = int(round(float(length)))
        except (TypeError, ValueError):
            pass

    return result or None


def _extract_mediainfo_metadata(path: Path):
    if not HAS_MEDIAINFO or MediaInfo is None:
        return None

    try:
        media_info = MediaInfo.parse(str(path))
    except Exception as e:
        logger.debug("[Metadata] MediaInfo Fehler bei %s: %s", path, e)
        return None

    result = {}
    for track in getattr(media_info, "tracks", []):
        track_type = getattr(track, "track_type", "").lower()
        if track_type == "general":
            title = getattr(track, "title", None) or getattr(track, "movie_name", None)
            if title:
                result["title"] = title

            artist = getattr(track, "performer", None) or getattr(track, "track_performer", None)
            if artist:
                result["artist"] = artist

            album = getattr(track, "album", None)
            if album:
                result["album"] = album

            description = getattr(track, "comment", None)
            if description:
                result["description"] = description

            duration = getattr(track, "duration", None)
            if duration is not None:
                try:
                    result["length_seconds"] = int(round(float(duration) / 1000.0))
                except (TypeError, ValueError):
                    pass

        elif track_type in {"audio", "video"} and "length_seconds" not in result:
            duration = getattr(track, "duration", None)
            if duration is not None:
                try:
                    result["length_seconds"] = int(round(float(duration) / 1000.0))
                except (TypeError, ValueError):
                    pass

    return result or None


def fetch_local_metadata(file_path):
    """Holt lokale Datei-Metadaten ueber optionale Parser und Sidecar-Cover."""
    path = Path(file_path)
    if not path.exists() or not path.is_file():
        return None

    result = {
        "title": path.stem,
        "type": _local_media_type(path),
        "source": "local",
        "provider_id": str(path.resolve()),
        "is_local_file": True,
        "local_path": str(path.resolve()),
        "has_real_id": True,
    }

    extracted = _extract_mutagen_metadata(path) or _extract_mediainfo_metadata(path) or {}
    for key, value in extracted.items():
        if value is None:
            continue
        if key == "type" and value == "file":
            continue
        result[key] = value

    cover_art = _find_local_cover_art(path)
    if cover_art:
        result["thumbnail_url"] = cover_art

    return result

# ============================================================
# 2. TMDb (The Movie Database)
# ============================================================

class TMDbFetcher:
    """Holt Metadaten von The Movie Database (TMDb)."""
    
    BASE_URL = "https://api.themoviedb.org/3"
    IMAGE_BASE = "https://image.tmdb.org/t/p"
    
    def __init__(self, api_key=None):
        self.api_key = api_key or get_api_key("tmdb")
        
    def is_available(self):
        """Prüft ob API-Key vorhanden ist."""
        return bool(self.api_key)
    
    def search_movie(self, title, year=None):
        """Sucht nach einem Film."""
        if not self.is_available():
            return None
            
        try:
            params = {
                "api_key": self.api_key,
                "query": title,
                "language": "de-DE"
            }
            if year:
                params["year"] = year
                
            response = requests.get(
                f"{self.BASE_URL}/search/movie",
                params=params,
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("results"):
                    return data["results"][0]  # Bester Treffer
                    
        except Exception as e:
            logger.error(f"[TMDb] Suche fehlgeschlagen: {e}")

        return None

    def search_tv(self, title, year=None):
        """Sucht nach einer Serie."""
        if not self.is_available():
            return None
            
        try:
            params = {
                "api_key": self.api_key,
                "query": title,
                "language": "de-DE"
            }
            if year:
                params["first_air_date_year"] = year
                
            response = requests.get(
                f"{self.BASE_URL}/search/tv",
                params=params,
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("results"):
                    return data["results"][0]
                    
        except Exception as e:
            logger.error(f"[TMDb] TV-Suche fehlgeschlagen: {e}")

        return None
    
    def get_movie_details(self, movie_id):
        """Holt detaillierte Film-Informationen."""
        if not self.is_available():
            return None
            
        try:
            response = requests.get(
                f"{self.BASE_URL}/movie/{movie_id}",
                params={"api_key": self.api_key, "language": "de-DE"},
                timeout=5
            )
            
            if response.status_code == 200:
                return response.json()
                
        except Exception as e:
            logger.error(f"[TMDb] Details fehlgeschlagen: {e}")

        return None
    
    def format_result(self, tmdb_data, media_type="movie"):
        """Formatiert TMDb-Ergebnis für MediaBrain."""
        if not tmdb_data:
            return None
            
        result = {
            "title": tmdb_data.get("title") or tmdb_data.get("name"),
            "description": tmdb_data.get("overview"),
            "tmdb_id": tmdb_data.get("id"),
            "type": media_type,
            "source": "tmdb"
        }
        
        # Poster
        poster = tmdb_data.get("poster_path")
        if poster:
            result["thumbnail_url"] = f"{self.IMAGE_BASE}/w500{poster}"
        
        # Backdrop
        backdrop = tmdb_data.get("backdrop_path")
        if backdrop:
            result["backdrop_url"] = f"{self.IMAGE_BASE}/original{backdrop}"
        
        # Rating
        result["rating"] = tmdb_data.get("vote_average")
        
        # Release-Jahr
        release = tmdb_data.get("release_date") or tmdb_data.get("first_air_date")
        if release:
            result["year"] = release[:4]
        
        # Genres
        genres = tmdb_data.get("genres", [])
        if genres:
            result["genres"] = [g["name"] for g in genres]
        
        return result

# ============================================================
# 3. OMDb (Open Movie Database) - Fallback
# ============================================================

class OMDbFetcher:
    """Holt Metadaten von OMDb (IMDb-basiert)."""
    
    BASE_URL = "http://www.omdbapi.com/"
    
    def __init__(self, api_key=None):
        self.api_key = api_key or get_api_key("omdb")

    def is_available(self):
        """Prüft ob API-Key vorhanden ist."""
        return bool(self.api_key)
    
    def search(self, title, year=None, media_type=None):
        """Sucht nach einem Film/Serie."""
        if not self.is_available():
            return None
            
        try:
            params = {
                "apikey": self.api_key,
                "t": title,
                "plot": "short"
            }
            if year:
                params["y"] = year
            if media_type:
                params["type"] = media_type  # movie, series, episode
                
            response = requests.get(self.BASE_URL, params=params, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("Response") == "True":
                    return data
                    
        except Exception as e:
            logger.error(f"[OMDb] Suche fehlgeschlagen: {e}")

        return None
    
    def format_result(self, omdb_data):
        """Formatiert OMDb-Ergebnis für MediaBrain."""
        if not omdb_data:
            return None
            
        result = {
            "title": omdb_data.get("Title"),
            "description": omdb_data.get("Plot"),
            "imdb_id": omdb_data.get("imdbID"),
            "year": omdb_data.get("Year"),
            "source": "omdb"
        }
        
        # Typ
        media_type = omdb_data.get("Type", "movie")
        result["type"] = "series" if media_type == "series" else "movie"
        
        # Poster
        poster = omdb_data.get("Poster")
        if poster and poster != "N/A":
            result["thumbnail_url"] = poster
        
        # Rating
        rating = omdb_data.get("imdbRating")
        if rating and rating != "N/A":
            result["rating"] = float(rating)
        
        # Genres
        genres = omdb_data.get("Genre")
        if genres and genres != "N/A":
            result["genres"] = [g.strip() for g in genres.split(",")]
        
        # Weitere Infos
        result["director"] = omdb_data.get("Director") if omdb_data.get("Director") != "N/A" else None
        result["actors"] = omdb_data.get("Actors") if omdb_data.get("Actors") != "N/A" else None
        result["runtime"] = omdb_data.get("Runtime") if omdb_data.get("Runtime") != "N/A" else None
        
        return result

# ============================================================
# 4. MusicBrainz (Basis-Implementation)
# ============================================================

class MusicBrainzFetcher:
    """Holt Metadaten von MusicBrainz (keine API-Key nötig)."""
    
    BASE_URL = "https://musicbrainz.org/ws/2"
    COVER_URL = "https://coverartarchive.org"
    
    def search_artist(self, name):
        """Sucht nach einem Künstler."""
        try:
            response = requests.get(
                f"{self.BASE_URL}/artist",
                params={"query": name, "fmt": "json", "limit": 1},
                headers={"User-Agent": "MediaBrain/2.0"},
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("artists"):
                    return data["artists"][0]
                    
        except Exception as e:
            logger.error(f"[MusicBrainz] Suche fehlgeschlagen: {e}")

        return None
    
    def search_release(self, title, artist=None):
        """Sucht nach einem Album/Release."""
        try:
            query = f'release:"{title}"'
            if artist:
                query += f' AND artist:"{artist}"'
                
            response = requests.get(
                f"{self.BASE_URL}/release",
                params={"query": query, "fmt": "json", "limit": 1},
                headers={"User-Agent": "MediaBrain/2.0"},
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("releases"):
                    return data["releases"][0]
                    
        except Exception as e:
            logger.error(f"[MusicBrainz] Release-Suche fehlgeschlagen: {e}")

        return None
    
    def get_cover_art(self, release_id):
        """Holt Cover-Art URL für ein Release."""
        try:
            response = requests.get(
                f"{self.COVER_URL}/release/{release_id}",
                headers={"User-Agent": "MediaBrain/2.0"},
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                images = data.get("images", [])
                if images:
                    return images[0].get("image")

        except Exception as e:
            logger.error(f"[MusicBrainz] Cover-Art Fehler fuer {release_id}: {e}")

        return None

# ============================================================
# 5. Metadata Cache (SQLite-basiert)
# ============================================================

class MetadataCache:
    """SQLite-basierter Cache für Metadaten-API-Antworten."""

    DEFAULT_TTL_DAYS = 30

    def __init__(self, db_path=None):
        if db_path is None:
            db_path = Path(__file__).parent / "metadata_cache.db"
        self.db_path = str(db_path)
        self._setup()

    def _setup(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS metadata_cache (
                cache_key TEXT PRIMARY KEY,
                result_json TEXT NOT NULL,
                created_at TEXT NOT NULL,
                expires_at TEXT NOT NULL
            )
        """)
        conn.commit()
        conn.close()

    @staticmethod
    def _make_key(source, query, media_type=None, year=None, artist=None):
        parts = [source, query, media_type or "", year or "", artist or ""]
        raw = "|".join(str(p).lower().strip() for p in parts)
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    def get(self, source, query, media_type=None, year=None, artist=None):
        key = self._make_key(source, query, media_type, year, artist)
        conn = sqlite3.connect(self.db_path)
        row = conn.execute(
            "SELECT result_json, expires_at FROM metadata_cache WHERE cache_key = ?",
            (key,)
        ).fetchone()
        conn.close()

        if row is None:
            return None

        if datetime.fromisoformat(row[1]) < datetime.now():
            self.delete(key)
            return None

        return json.loads(row[0])

    def put(self, source, query, result, media_type=None, year=None, artist=None, ttl_days=None):
        if result is None:
            return
        key = self._make_key(source, query, media_type, year, artist)
        now = datetime.now()
        expires = now + timedelta(days=ttl_days or self.DEFAULT_TTL_DAYS)
        conn = sqlite3.connect(self.db_path)
        conn.execute(
            "INSERT OR REPLACE INTO metadata_cache (cache_key, result_json, created_at, expires_at) VALUES (?, ?, ?, ?)",
            (key, json.dumps(result, ensure_ascii=False), now.isoformat(), expires.isoformat())
        )
        conn.commit()
        conn.close()

    def delete(self, key):
        conn = sqlite3.connect(self.db_path)
        conn.execute("DELETE FROM metadata_cache WHERE cache_key = ?", (key,))
        conn.commit()
        conn.close()

    def clear_expired(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute("DELETE FROM metadata_cache WHERE expires_at < ?", (datetime.now().isoformat(),))
        conn.commit()
        conn.close()


# ============================================================
# 6. Unified Metadata Fetcher
# ============================================================

class MetadataFetcher:
    """
    Einheitlicher Metadaten-Fetcher für MediaBrain.
    Kombiniert alle Quellen mit Fallback-Logik.
    """
    
    def __init__(self, cache_enabled=True):
        self.tmdb = TMDbFetcher()
        self.omdb = OMDbFetcher()
        self.musicbrainz = MusicBrainzFetcher()
        self.cache = MetadataCache() if cache_enabled else None

    def _cache_get(self, source, query, media_type=None, year=None, artist=None):
        """
        Holt Metadaten aus Cache (falls aktiviert).

        Args:
            source: Quelle (movie, series, music)
            query: Suchbegriff
            media_type: Medientyp (optional)
            year: Jahr (optional)
            artist: Künstler für Musik (optional)

        Returns:
            Gecachte Metadaten oder None
        """
        if self.cache:
            return self.cache.get(source, query, media_type, year, artist)
        return None

    def _cache_put(self, source, query, result, media_type=None, year=None, artist=None):
        """
        Speichert Metadaten in Cache (falls aktiviert und result nicht None).

        Args:
            source: Quelle (movie, series, music)
            query: Suchbegriff
            result: Metadaten-Dict zum Cachen
            media_type: Medientyp (optional)
            year: Jahr (optional)
            artist: Künstler für Musik (optional)
        """
        if self.cache and result:
            self.cache.put(source, query, result, media_type, year, artist)

    def fetch_movie(self, title, year=None):
        """Holt Film-Metadaten (Cache → TMDb → OMDb Fallback)."""
        cached = self._cache_get("movie", title, "movie", str(year) if year else None)
        if cached:
            return cached

        result = None
        # 1. TMDb versuchen
        if self.tmdb.is_available():
            raw = self.tmdb.search_movie(title, year)
            if raw:
                details = self.tmdb.get_movie_details(raw["id"])
                if details:
                    result = self.tmdb.format_result(details, "movie")
                else:
                    result = self.tmdb.format_result(raw, "movie")

        # 2. OMDb Fallback
        if result is None and self.omdb.is_available():
            raw = self.omdb.search(title, year, "movie")
            if raw:
                result = self.omdb.format_result(raw)

        self._cache_put("movie", title, result, "movie", str(year) if year else None)
        return result

    def fetch_series(self, title, year=None):
        """Holt Serien-Metadaten (Cache → TMDb → OMDb Fallback)."""
        cached = self._cache_get("series", title, "series", str(year) if year else None)
        if cached:
            return cached

        result = None
        # 1. TMDb
        if self.tmdb.is_available():
            raw = self.tmdb.search_tv(title, year)
            if raw:
                result = self.tmdb.format_result(raw, "series")

        # 2. OMDb Fallback
        if result is None and self.omdb.is_available():
            raw = self.omdb.search(title, year, "series")
            if raw:
                result = self.omdb.format_result(raw)

        self._cache_put("series", title, result, "series", str(year) if year else None)
        return result

    def fetch_music(self, title, artist=None, source=None, provider_id=None, provider_subtype=None, url=None):
        """Holt Musik-Metadaten (Spotify oEmbed -> MusicBrainz)."""
        spotify_url = _normalize_spotify_url(url, provider_subtype, provider_id)
        if source == "spotify" and not spotify_url:
            spotify_url = _normalize_spotify_url(None, provider_subtype, provider_id)

        if spotify_url:
            cached = self._cache_get("spotify", spotify_url, "music")
            if cached:
                return cached

            result = fetch_spotify_oembed(
                spotify_url,
                provider_subtype=provider_subtype,
                provider_id=provider_id
            )
            if result:
                if title and not result.get("title"):
                    result["title"] = title
                if artist and not result.get("artist"):
                    result["artist"] = artist
                self._cache_put("spotify", spotify_url, result, "music")
                return result

        cached = self._cache_get("musicbrainz", title, "music", artist=artist)
        if cached:
            return cached

        raw = self.musicbrainz.search_release(title, artist)
        result = None
        if raw:
            release_id = raw.get("id")
            result = {
                "title": raw.get("title"),
                "artist": (raw.get("artist-credit") or [{}])[0].get("name"),
                "year": raw.get("date", "")[:4] if raw.get("date") else None,
                "thumbnail_url": self.musicbrainz.get_cover_art(release_id) if release_id else None,
                "type": "music",
                "source": "musicbrainz"
            }

        self._cache_put("musicbrainz", title, result, "music", artist=artist)
        return result

    def fetch_clip(self, title, source=None, provider_id=None, url=None):
        """Holt Clip-Metadaten, bevorzugt via YouTube oEmbed."""
        cache_query = url or provider_id or title
        cached = self._cache_get("clip", cache_query, "clip", artist=source)
        if cached:
            return cached

        result = None

        candidate_url = url
        if not candidate_url and source == "youtube" and provider_id:
            candidate_url = f"https://www.youtube.com/watch?v={provider_id}"
        if not candidate_url and _is_youtube_url(title):
            candidate_url = title

        if candidate_url and _is_youtube_url(candidate_url):
            result = fetch_youtube_oembed(candidate_url)
            if result and not result.get("title"):
                result["title"] = title
        elif title:
            result = fetch_opengraph(title)

        if result:
            result["type"] = "clip"
            if source:
                result["source"] = source
            if provider_id and not result.get("provider_id"):
                result["provider_id"] = provider_id
            if title and not result.get("title"):
                result["title"] = title

        self._cache_put("clip", cache_query, result, "clip", artist=source)
        return result

    def auto_fetch(self, title, media_type="movie", year=None, artist=None, source=None, provider_id=None, provider_subtype=None, url=None):
        """
        Automatischer Fetch basierend auf Medientyp.
        
        Args:
            title: Titel des Mediums
            media_type: movie, series, music, clip
            year: Erscheinungsjahr (optional)
            artist: Künstler für Musik (optional)
        """
        if media_type in ["movie", "film"]:
            return self.fetch_movie(title, year)
        elif media_type in ["series", "show", "tv"]:
            return self.fetch_series(title, year)
        elif media_type in ["music", "song", "album"]:
            return self.fetch_music(
                title,
                artist,
                source=source,
                provider_id=provider_id,
                provider_subtype=provider_subtype,
                url=url
            )
        elif media_type in ["clip", "video", "short", "youtube"]:
            return self.fetch_clip(title, source=source, provider_id=provider_id, url=url)
        else:
            # Versuche Film zuerst
            result = self.fetch_movie(title, year)
            if result:
                return result
            return self.fetch_series(title, year)
    
    def get_status(self):
        """Gibt Status der API-Verbindungen zurück."""
        return {
            "tmdb": self.tmdb.is_available(),
            "omdb": self.omdb.is_available(),
            "musicbrainz": True  # Keine API-Key nötig
        }

# ============================================================
# Legacy-Kompatibilität
# ============================================================

def fetch_metadata(url):
    """Legacy-Funktion für Abwärtskompatibilität."""
    if _is_spotify_url(url):
        result = fetch_spotify_oembed(url)
        if result:
            return result

    if _is_youtube_url(url):
        result = fetch_youtube_oembed(url)
        if result:
            return result
    return fetch_opengraph(url)

# ============================================================
# Test
# ============================================================

if __name__ == "__main__":
    fetcher = MetadataFetcher()
    
    print("API Status:", fetcher.get_status())
    
    # Test Film
    print("\n--- Film-Test ---")
    result = fetcher.fetch_movie("Inception")
    if result:
        print(f"Titel: {result.get('title')}")
        print(f"Jahr: {result.get('year')}")
        print(f"Rating: {result.get('rating')}")
    else:
        print("Keine API-Keys konfiguriert oder keine Ergebnisse")
    
    # Test MusicBrainz (kein API-Key nötig)
    print("\n--- Musik-Test ---")
    result = fetcher.fetch_music("Abbey Road", "The Beatles")
    if result:
        print(f"Album: {result.get('title')}")
        print(f"Artist: {result.get('artist')}")
