/// MediaBrain Standalone — SQLite-Persistenz.
library;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  // Set in tests to redirect the DB to an in-memory path.
  static String? overrideDbPath;

  Future<Database>? _dbFuture;

  Future<Database> get database async {
    final f = _dbFuture ??= _openDatabase();
    try {
      return await f;
    } catch (_) {
      // Rejected-Future nicht dauerhaft cachen: bei (transientem) Oeffnen-Fehler
      // Cache zuruecksetzen, damit der naechste Zugriff erneut versuchen kann.
      _dbFuture = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final dbPath = overrideDbPath ?? p.join(await getDatabasesPath(), 'mediabrain.db');
    return openDatabase(
      dbPath,
      version: 2,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createPlaylistTables(db);
        }
      },
    );
  }

  Future<void> _createPlaylistTables(DatabaseExecutor db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS playlists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  playlist_type TEXT NOT NULL DEFAULT 'manual',
  smart_query TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
    await db.execute('''
CREATE TABLE IF NOT EXISTS playlist_items (
  playlist_id TEXT NOT NULL,
  media_id TEXT NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  added_at TEXT NOT NULL,
  PRIMARY KEY (playlist_id, media_id),
  FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
  FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE
)
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_playlist_items_playlist ON playlist_items(playlist_id)',
    );
  }

  Future<void> _createSchema(Database db) async {
    final batch = db.batch();
    batch.execute('''
CREATE TABLE IF NOT EXISTS media_items (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'movie',
  source TEXT NOT NULL DEFAULT '',
  provider_id TEXT NOT NULL DEFAULT '',
  artist TEXT,
  album TEXT,
  channel TEXT,
  season INTEGER,
  episode INTEGER,
  length_seconds INTEGER,
  last_opened_at TEXT,
  foreground_minutes INTEGER NOT NULL DEFAULT 0,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  thumbnail_url TEXT,
  local_path TEXT,
  tags TEXT NOT NULL DEFAULT ''
)
''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_category ON media_items(category)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_source ON media_items(source)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_favorite ON media_items(is_favorite)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_last_opened ON media_items(last_opened_at)',
    );

    batch.execute('''
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');

    batch.execute('''
CREATE TABLE IF NOT EXISTS playlists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  playlist_type TEXT NOT NULL DEFAULT 'manual',
  smart_query TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
    batch.execute('''
CREATE TABLE IF NOT EXISTS playlist_items (
  playlist_id TEXT NOT NULL,
  media_id TEXT NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  added_at TEXT NOT NULL,
  PRIMARY KEY (playlist_id, media_id),
  FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
  FOREIGN KEY (media_id) REFERENCES media_items(id) ON DELETE CASCADE
)
''');
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_playlist_items_playlist ON playlist_items(playlist_id)',
    );

    await batch.commit();
  }

  // ─── MediaItems ─────────────────────────────────────────────────

  // ─── MediaItems & Filtering ─────────────────────────────────────

  Future<List<MediaItem>> listItems({
    MediaCategory? category,
    bool favoritesOnly = false,
    String? query,
    String? tag,
    String? playlistId,
    int? limit,
  }) async {
    if (playlistId != null && playlistId.isNotEmpty) {
      final items = await getPlaylistItems(playlistId);
      var filtered = items;
      if (category != null) {
        filtered = filtered.where((m) => m.category == category).toList();
      }
      if (favoritesOnly) {
        filtered = filtered.where((m) => m.isFavorite).toList();
      }
      if (tag != null && tag.trim().isNotEmpty) {
        final tLower = tag.trim().toLowerCase();
        filtered = filtered
            .where((m) => m.tags.map((t) => t.toLowerCase()).contains(tLower))
            .toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered.where((m) =>
            m.title.toLowerCase().contains(q) ||
            (m.artist ?? '').toLowerCase().contains(q) ||
            (m.album ?? '').toLowerCase().contains(q) ||
            (m.channel ?? '').toLowerCase().contains(q) ||
            (m.description ?? '').toLowerCase().contains(q) ||
            m.tags.any((t) => t.toLowerCase().contains(q))).toList();
      }
      if (limit != null && filtered.length > limit) {
        return filtered.sublist(0, limit);
      }
      return filtered;
    }

    final db = await database;
    final wheres = <String>[];
    final args = <Object?>[];
    if (category != null) {
      wheres.add('category = ?');
      args.add(categoryToString(category));
    }
    if (favoritesOnly) {
      wheres.add('is_favorite = 1');
    }
    final rows = await db.query(
      'media_items',
      where: wheres.isEmpty ? null : wheres.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      // NULLS LAST braucht SQLite >= 3.30 (nicht auf allen Android-System-SQLite
      // garantiert). Portabel ueber (col IS NULL) emuliert: non-null zuerst, nulls ans Ende.
      orderBy: '(last_opened_at IS NULL), last_opened_at DESC, title ASC',
      limit: limit,
    );
    var items = rows.map(MediaItem.fromMap).toList();
    if (tag != null && tag.trim().isNotEmpty) {
      final tLower = tag.trim().toLowerCase();
      items = items
          .where((m) => m.tags.map((t) => t.toLowerCase()).contains(tLower))
          .toList();
    }
    if (query == null || query.trim().isEmpty) return items;
    final q = query.trim().toLowerCase();
    return items
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            (m.artist ?? '').toLowerCase().contains(q) ||
            (m.album ?? '').toLowerCase().contains(q) ||
            (m.channel ?? '').toLowerCase().contains(q) ||
            (m.description ?? '').toLowerCase().contains(q) ||
            m.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  Future<MediaItem?> getItem(String id) async {
    final db = await database;
    final rows = await db.query(
      'media_items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MediaItem.fromMap(rows.first);
  }

  Future<void> upsert(MediaItem item) async {
    final db = await database;
    await db.insert(
      'media_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertAll(List<MediaItem> items) async {
    if (items.isEmpty) return;
    final db = await database;
    await db.transaction((txn) async {
      for (final i in items) {
        await txn.insert(
          'media_items',
          i.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> toggleFavorite(String id) async {
    final item = await getItem(id);
    if (item == null) return;
    await upsert(item.copyWith(isFavorite: !item.isFavorite));
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('playlist_items', where: 'media_id = ?', whereArgs: [id]);
      await txn.delete('media_items', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<String>> listCategories() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT category FROM media_items ORDER BY category',
    );
    return rows.map((r) => r['category'] as String).toList();
  }

  Future<Map<MediaCategory, int>> countByCategory() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT category, COUNT(*) AS c FROM media_items GROUP BY category',
    );
    final out = <MediaCategory, int>{};
    for (final r in rows) {
      out[categoryFromString(r['category'] as String?)] = (r['c'] as int);
    }
    return out;
  }

  // ─── Tags ────────────────────────────────────────────────────────

  /// Liefert alle eindeutigen Tags mit ihrer Häufigkeit, sortiert nach Count DESC.
  Future<List<MediaTag>> listTags() async {
    final db = await database;
    final rows = await db.rawQuery("SELECT tags FROM media_items WHERE tags != ''");
    final counts = <String, int>{};
    for (final r in rows) {
      final raw = (r['tags'] as String?) ?? '';
      for (final t in raw.split('|')) {
        final clean = t.trim();
        if (clean.isNotEmpty) {
          counts[clean] = (counts[clean] ?? 0) + 1;
        }
      }
    }
    final sorted = counts.entries
        .map((e) => MediaTag(name: e.key, count: e.value))
        .toList();
    sorted.sort((a, b) {
      final cmp = b.count.compareTo(a.count);
      return cmp != 0 ? cmp : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  /// Fügt einem MediaItem einen Tag hinzu (idempotent).
  Future<void> addTagToItem(String itemId, String tag) async {
    final clean = tag.trim();
    if (clean.isEmpty) return;
    final item = await getItem(itemId);
    if (item == null) return;
    if (item.tags.map((t) => t.toLowerCase()).contains(clean.toLowerCase())) return;
    final newTags = List<String>.from(item.tags)..add(clean);
    await upsert(item.copyWith(tags: newTags));
  }

  /// Entfernt einen Tag von einem MediaItem.
  Future<void> removeTagFromItem(String itemId, String tag) async {
    final clean = tag.trim().toLowerCase();
    final item = await getItem(itemId);
    if (item == null) return;
    final newTags = item.tags.where((t) => t.toLowerCase() != clean).toList();
    await upsert(item.copyWith(tags: newTags));
  }

  // ─── Playlists ───────────────────────────────────────────────────

  /// Liefert alle Playlists mit berechneter Anzahl an Einträgen.
  Future<List<Playlist>> listPlaylists() async {
    final db = await database;
    final rows = await db.rawQuery('''
SELECT p.*, COUNT(pi.media_id) AS item_count
FROM playlists p
LEFT JOIN playlist_items pi ON p.id = pi.playlist_id
GROUP BY p.id
ORDER BY p.name COLLATE NOCASE ASC
''');
    final out = <Playlist>[];
    for (final r in rows) {
      final pl = Playlist.fromMap(r);
      if (pl.isSmart && pl.smartQuery != null) {
        final smartItems = await evaluateSmartPlaylist(pl.smartQuery!);
        out.add(pl.copyWith(itemCount: smartItems.length));
      } else {
        out.add(pl);
      }
    }
    return out;
  }

  /// Liefert eine Playlist per ID.
  Future<Playlist?> getPlaylist(String id) async {
    final db = await database;
    final rows = await db.rawQuery('''
SELECT p.*, COUNT(pi.media_id) AS item_count
FROM playlists p
LEFT JOIN playlist_items pi ON p.id = pi.playlist_id
WHERE p.id = ?
GROUP BY p.id
''', [id]);
    if (rows.isEmpty) return null;
    final pl = Playlist.fromMap(rows.first);
    if (pl.isSmart && pl.smartQuery != null) {
      final smartItems = await evaluateSmartPlaylist(pl.smartQuery!);
      return pl.copyWith(itemCount: smartItems.length);
    }
    return pl;
  }

  /// Legt eine Playlist neu an oder aktualisiert sie.
  Future<void> upsertPlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert(
      'playlists',
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Löscht eine Playlist und ihre Item-Zuordnungen.
  Future<void> deletePlaylist(String id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('playlist_items', where: 'playlist_id = ?', whereArgs: [id]);
      await txn.delete('playlists', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Fügt ein MediaItem einer manuellen Playlist hinzu.
  Future<void> addItemToPlaylist(String playlistId, String mediaId) async {
    final db = await database;
    final maxPosRow = await db.rawQuery(
      'SELECT MAX(position) AS max_pos FROM playlist_items WHERE playlist_id = ?',
      [playlistId],
    );
    final nextPos = ((maxPosRow.first['max_pos'] as num?)?.toInt() ?? -1) + 1;
    await db.insert(
      'playlist_items',
      {
        'playlist_id': playlistId,
        'media_id': mediaId,
        'position': nextPos,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.update(
      'playlists',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Entfernt ein MediaItem aus einer manuellen Playlist.
  Future<void> removeItemFromPlaylist(String playlistId, String mediaId) async {
    final db = await database;
    await db.delete(
      'playlist_items',
      where: 'playlist_id = ? AND media_id = ?',
      whereArgs: [playlistId, mediaId],
    );
    await db.update(
      'playlists',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  /// Liefert alle MediaItems einer Playlist (bei smart: dynamisch evaluiert).
  Future<List<MediaItem>> getPlaylistItems(String playlistId) async {
    final pl = await getPlaylist(playlistId);
    if (pl == null) return [];
    if (pl.isSmart && pl.smartQuery != null) {
      return evaluateSmartPlaylist(pl.smartQuery!);
    }
    final db = await database;
    final rows = await db.rawQuery('''
SELECT m.*
FROM media_items m
INNER JOIN playlist_items pi ON m.id = pi.media_id
WHERE pi.playlist_id = ?
ORDER BY pi.position ASC, pi.added_at ASC
''', [playlistId]);
    return rows.map(MediaItem.fromMap).toList();
  }

  /// Wertet eine Smart-Playlist-Query gegen die gesamte Bibliothek aus.
  Future<List<MediaItem>> evaluateSmartPlaylist(SmartPlaylistQuery query) async {
    final all = await listItems();
    return all.where(query.matches).toList();
  }

  // ─── Settings ───────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('playlist_items');
      await txn.delete('playlists');
      await txn.delete('media_items');
      await txn.delete('settings');
    });
  }

  /// Closes the database and resets the cached instance (used in tests).
  Future<void> close() async {
    final db = await _dbFuture;
    _dbFuture = null;
    await db?.close();
  }

  static bool _asBool(dynamic v) => v == true || v == 1;

  static bool _isUuid(String s) =>
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
              caseSensitive: false)
          .hasMatch(s);

  /// Builds the JSON exchange payload for cross-platform export.
  ///
  /// Envelope mirrors MediaBrain Desktop's `build_export_payload()`.
  /// `local_path` is intentionally omitted — device-local, no raw paths in export.
  /// `foreground_minutes` is included (Flutter-specific, desktop drops it silently).
  Future<Map<String, dynamic>> buildExportPayload() async {
    final db = await database;
    final rows = await db.query('media_items', orderBy: 'title ASC');
    final items = rows.map((r) {
      final tagStr = (r['tags'] as String?) ?? '';
      final tagList = tagStr.split('|').where((s) => s.isNotEmpty).toList();
      return {
        'id': r['id'],
        'title': r['title'],
        'category': r['category'],
        'type': r['category'], // required by desktop importer
        'source': r['source'],
        'provider_id': r['provider_id'],
        'artist': r['artist'],
        'album': r['album'],
        'channel': r['channel'],
        'season': r['season'],
        'episode': r['episode'],
        'length_seconds': r['length_seconds'],
        'last_opened_at': r['last_opened_at'],
        'foreground_minutes': r['foreground_minutes'],
        'is_favorite': (r['is_favorite'] as int?) == 1,
        'description': r['description'],
        'thumbnail_url': r['thumbnail_url'],
        'tags': tagList,
      };
    }).toList();
    return {
      'schema': librarySchemaName,
      'schema_version': 1,
      'version': '1.0', // legacy compatibility field
      'app_name': 'MediaBrain Mobile',
      'source': {
        'app_name': 'MediaBrain Mobile',
        'platform': 'android',
      },
      'exported_at': DateTime.now().toIso8601String(),
      'item_count': items.length,
      'items': items,
    };
  }

  /// Imports a library bundle from a [json] map.
  ///
  /// Accepts both Flutter exports (category field) and Desktop exports (type field).
  /// Merge strategy (v1): replace entire row if source+provider_id or title+category
  /// matches an existing item, preserving the existing UUID. Mobile-only usage
  /// fields are preserved when an imported item omits them; explicitly supplied
  /// values still replace the local values.
  Future<({int imported, int skipped})> importLibraryBundle(
      Map<String, dynamic> json) async {
    final schema = json['schema'];
    if (schema != null && schema != '' && schema != librarySchemaName) {
      throw ImportException(
          "Schema '$schema' nicht unterstützt (erwartet: $librarySchemaName).");
    }
    final schemaVersion = json['schema_version'];
    if (schemaVersion != null && schemaVersion != '' &&
        (int.tryParse(schemaVersion.toString()) ?? 1) != 1) {
      throw ImportException(
          "schema_version $schemaVersion nicht unterstützt (erwartet: 1).");
    }
    final rawItems = json['items'];
    if (rawItems == null || rawItems is! List) {
      throw ImportException('Kein items-Array im Payload gefunden.');
    }

    int imported = 0;
    int skipped = 0;
    final db = await database;

    await db.transaction((txn) async {
      for (final raw in rawItems) {
        if (raw is! Map) {
          skipped++;
          continue;
        }
        final item = raw.cast<String, dynamic>();

        final title = (item['title'] as String?)?.trim() ?? '';
        if (title.isEmpty) {
          skipped++;
          continue;
        }

        // Desktop uses "type"; Flutter uses "category". Accept both.
        final catStr = ((item['category'] as String?) ??
                (item['type'] as String?) ??
                'movie')
            .trim();

        final tagRaw = item['tags'];
        final tagList = tagRaw is List
            ? tagRaw
                .map((t) => t.toString())
                .where((s) => s.isNotEmpty)
                .toList()
            : <String>[];

        final src = (item['source'] as String?) ?? '';
        final pid = (item['provider_id'] as String?) ?? '';

        // Merge pass 1: source + provider_id
        Map<String, Object?>? existingRow;
        if (src.isNotEmpty && pid.isNotEmpty) {
          final found = await txn.query(
            'media_items',
            columns: ['id', 'last_opened_at', 'foreground_minutes'],
            where: 'source = ? AND provider_id = ?',
            whereArgs: [src, pid],
            limit: 1,
          );
          if (found.isNotEmpty) existingRow = found.first;
        }

        // Merge pass 2: title + category (heuristic fallback)
        if (existingRow == null) {
          final found = await txn.query(
            'media_items',
            columns: ['id', 'last_opened_at', 'foreground_minutes'],
            where: 'title = ? AND category = ?',
            whereArgs: [title, catStr],
            limit: 1,
          );
          if (found.isNotEmpty) existingRow = found.first;
        }

        final providedId = (item['id'] ?? '').toString();
        final existingId = existingRow?['id'] as String?;
        final finalId = existingId ??
            (_isUuid(providedId) ? providedId : const Uuid().v4());
        final lastOpenedAt = item.containsKey('last_opened_at')
            ? item['last_opened_at']
            : existingRow?['last_opened_at'];
        final foregroundMinutes = item.containsKey('foreground_minutes')
            ? (item['foreground_minutes'] as num?)?.toInt() ?? 0
            : (existingRow?['foreground_minutes'] as num?)?.toInt() ?? 0;

        final row = <String, dynamic>{
          'id': finalId,
          'title': title,
          'category': catStr,
          'source': src,
          'provider_id': pid,
          'artist': item['artist'],
          'album': item['album'],
          'channel': item['channel'],
          'season': (item['season'] as num?)?.toInt(),
          'episode': (item['episode'] as num?)?.toInt(),
          'length_seconds': (item['length_seconds'] as num?)?.toInt(),
          'last_opened_at': lastOpenedAt,
          'foreground_minutes': foregroundMinutes,
          'is_favorite': _asBool(item['is_favorite']) ? 1 : 0,
          'description': item['description'],
          'thumbnail_url': item['thumbnail_url'],
          // local_path accepted from desktop even though Flutter doesn't export it
          'local_path': item['local_path'],
          'tags': tagList.join('|'),
        };

        await txn.insert(
          'media_items',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        imported++;
      }
    });

    return (imported: imported, skipped: skipped);
  }
}
