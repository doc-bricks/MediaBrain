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
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async => _createSchema(db),
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
    await batch.commit();
  }

  // ─── MediaItems ─────────────────────────────────────────────────

  Future<List<MediaItem>> listItems({
    MediaCategory? category,
    bool favoritesOnly = false,
    String? query,
    int? limit,
  }) async {
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
    final items = rows.map(MediaItem.fromMap).toList();
    if (query == null || query.isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            (m.artist ?? '').toLowerCase().contains(q) ||
            (m.album ?? '').toLowerCase().contains(q) ||
            (m.channel ?? '').toLowerCase().contains(q) ||
            (m.description ?? '').toLowerCase().contains(q))
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
    await db.delete('media_items', where: 'id = ?', whereArgs: [id]);
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
  /// matches an existing item, preserving the existing UUID.
  ///
  /// Known v1 limitation: foreground_minutes and last_opened_at are overwritten
  /// with values from the imported payload (desktop exports don't include
  /// foreground_minutes, so it resets to 0 on desktop→Flutter import).
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
        String? existingId;
        if (src.isNotEmpty && pid.isNotEmpty) {
          final found = await txn.query(
            'media_items',
            columns: ['id'],
            where: 'source = ? AND provider_id = ?',
            whereArgs: [src, pid],
            limit: 1,
          );
          if (found.isNotEmpty) existingId = found.first['id'] as String?;
        }

        // Merge pass 2: title + category (heuristic fallback)
        if (existingId == null) {
          final found = await txn.query(
            'media_items',
            columns: ['id'],
            where: 'title = ? AND category = ?',
            whereArgs: [title, catStr],
            limit: 1,
          );
          if (found.isNotEmpty) existingId = found.first['id'] as String?;
        }

        final providedId = (item['id'] ?? '').toString();
        final finalId =
            existingId ?? (_isUuid(providedId) ? providedId : const Uuid().v4());

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
          'last_opened_at': item['last_opened_at'],
          'foreground_minutes': (item['foreground_minutes'] as num?)?.toInt() ?? 0,
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
