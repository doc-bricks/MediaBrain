/// MediaBrain Standalone — SQLite-Persistenz.
library;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'mediabrain.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async => _createSchema(db),
    );
    return _db!;
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
      orderBy: 'last_opened_at DESC NULLS LAST, title ASC',
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
}
