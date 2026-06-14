/// Tests für buildExportPayload() und importLibraryBundle().
///
/// Nutzt sqflite_common_ffi mit inMemoryDatabasePath —
/// kein echtes Gerät oder Plugin-Registrierung nötig.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mediabrain/models/models.dart';
import 'package:mediabrain/services/database_service.dart';

// Fixture: typisches Desktop-Export-Format (type statt category, is_favorite als int)
const _desktopFixture = {
  'schema': 'mediabrain-library-v1',
  'schema_version': 1,
  'version': '1.0',
  'app_name': 'MediaBrain Desktop',
  'app_version': 'dev',
  'source': {
    'app_name': 'MediaBrain Desktop',
    'app_version': 'dev',
    'platform': 'windows',
  },
  'exported_at': '2026-06-14T10:00:00+00:00',
  'item_count': 2,
  'items': [
    {
      'id': 42, // Desktop: integer ID (not UUID)
      'title': 'Inception',
      'type': 'movie', // Desktop: "type" not "category"
      'source': 'tmdb',
      'provider_id': 'tt1375666',
      'is_favorite': 1, // Desktop: int boolean
      'tags': ['sci-fi', 'thriller'],
    },
    {
      'id': 43,
      'title': 'The Dark Side of the Moon',
      'type': 'music',
      'source': 'mb',
      'provider_id': 'abc123',
      'artist': 'Pink Floyd',
      'album': 'The Dark Side of the Moon',
      'is_favorite': 0,
      'tags': <String>[],
    },
  ],
};

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseService.overrideDbPath = inMemoryDatabasePath;
  });

  setUp(() async => DatabaseService.instance.close());

  // ── Konstanten & Modelle ──────────────────────────────────────────────────

  test('librarySchemaName hat korrekten Wert', () {
    expect(librarySchemaName, 'mediabrain-library-v1');
  });

  test('ImportException gibt lesbaren String zurück', () {
    const e = ImportException('Test-Fehler');
    expect(e.toString(), contains('Test-Fehler'));
  });

  // ── buildExportPayload — leere Bibliothek ─────────────────────────────────

  test('buildExportPayload gibt korrekten Envelope bei leerer DB zurück',
      () async {
    final svc = DatabaseService.instance;
    final payload = await svc.buildExportPayload();
    expect(payload['schema'], librarySchemaName);
    expect(payload['schema_version'], 1);
    expect(payload['item_count'], 0);
    expect(payload['items'], isEmpty);
    expect(payload.containsKey('exported_at'), isTrue);
    expect(payload.containsKey('source'), isTrue);
  });

  // ── buildExportPayload — mit einem Item ───────────────────────────────────

  Future<void> insertTestItem(DatabaseService svc,
      {String id = 'uuid-001',
      String title = 'Test Film',
      String category = 'movie',
      bool isFavorite = true,
      String tags = 'action|drama'}) async {
    await svc.upsert(MediaItem(
      id: id,
      title: title,
      category: categoryFromString(category),
      source: 'test',
      providerId: 'p001',
      isFavorite: isFavorite,
      tags: tags.split('|').where((s) => s.isNotEmpty).toList(),
    ));
  }

  test('buildExportPayload enthält kein local_path', () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc);
    final payload = await svc.buildExportPayload();
    final item = (payload['items'] as List).first as Map;
    expect(item.containsKey('local_path'), isFalse);
  });

  test('buildExportPayload exportiert is_favorite als bool', () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc, isFavorite: true);
    final payload = await svc.buildExportPayload();
    final item = (payload['items'] as List).first as Map;
    expect(item['is_favorite'], isA<bool>());
    expect(item['is_favorite'], isTrue);
  });

  test('buildExportPayload exportiert tags als List<String>', () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc, tags: 'action|drama');
    final payload = await svc.buildExportPayload();
    final item = (payload['items'] as List).first as Map;
    expect(item['tags'], isA<List>());
    expect(item['tags'], containsAll(['action', 'drama']));
  });

  test('buildExportPayload enthält type == category für Desktop-Kompatibilität',
      () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc, category: 'music');
    final payload = await svc.buildExportPayload();
    final item = (payload['items'] as List).first as Map;
    expect(item['type'], item['category']);
    expect(item['type'], 'music');
  });

  test('buildExportPayload item_count stimmt mit items.length überein',
      () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc, id: 'u1', title: 'Film A');
    await insertTestItem(svc, id: 'u2', title: 'Film B');
    final payload = await svc.buildExportPayload();
    expect(payload['item_count'], 2);
    expect((payload['items'] as List).length, 2);
  });

  // ── importLibraryBundle ───────────────────────────────────────────────────

  test('importLibraryBundle mit leerer items-Liste gibt 0/0 zurück', () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle({
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': <dynamic>[],
    });
    expect(result.imported, 0);
    expect(result.skipped, 0);
  });

  test('importLibraryBundle speichert Item in DB', () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle({
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': [
        {
          'id': 'a1000000-0000-4000-8000-000000000001',
          'title': 'Import Test Film',
          'category': 'movie',
          'source': 'test',
          'provider_id': 'p-import-001',
          'is_favorite': false,
          'tags': ['import'],
        }
      ],
    });
    expect(result.imported, 1);
    final item = await svc.getItem('a1000000-0000-4000-8000-000000000001');
    expect(item, isNotNull);
    expect(item!.title, 'Import Test Film');
    expect(item.tags, contains('import'));
  });

  test('importLibraryBundle akzeptiert Desktop-Format (type statt category)',
      () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle(
        Map<String, dynamic>.from(_desktopFixture));
    expect(result.imported, 2);

    final items = await svc.listItems();
    final inception = items.firstWhere((i) => i.title == 'Inception');
    expect(inception.category, MediaCategory.movie); // type → category
    expect(inception.isFavorite, isTrue); // int 1 → bool
    expect(inception.tags, containsAll(['sci-fi', 'thriller']));

    final floyd = items.firstWhere((i) => i.title == 'The Dark Side of the Moon');
    expect(floyd.category, MediaCategory.music);
    expect(floyd.isFavorite, isFalse);

    // Desktop integer IDs müssen als UUIDs gespeichert werden (kein "42" als PK)
    expect(inception.id, isNot('42'));
    expect(inception.id, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false)));
  });

  test('importLibraryBundle dedupliziert über source+provider_id', () async {
    final svc = DatabaseService.instance;
    const payload = {
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': [
        {
          'id': 'uuid-dedup',
          'title': 'Dedup Film',
          'category': 'movie',
          'source': 'tmdb',
          'provider_id': 'dup-001',
          'is_favorite': false,
          'tags': <String>[],
        }
      ],
    };

    final r1 = await svc.importLibraryBundle(payload);
    expect(r1.imported, 1);
    final firstId = (await svc.listItems()).first.id;

    // Zweiter Import desselben Items — muss gleiche UUID behalten
    final r2 = await svc.importLibraryBundle(payload);
    expect(r2.imported, 1);
    final allItems = await svc.listItems();
    expect(allItems.length, 1); // kein Duplikat
    expect(allItems.first.id, firstId); // UUID erhalten
  });

  test('importLibraryBundle überspringt Items ohne title', () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle({
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': [
        {'id': 'x', 'category': 'movie', 'source': 'test', 'provider_id': 'p1'},
        {'id': '', 'title': '', 'category': 'movie'},
      ],
    });
    expect(result.skipped, 2);
    expect(result.imported, 0);
  });

  test('importLibraryBundle wirft ImportException bei unbekanntem Schema',
      () async {
    final svc = DatabaseService.instance;
    expect(
      () => svc.importLibraryBundle({
        'schema': 'foreign-app-v99',
        'items': <dynamic>[],
      }),
      throwsA(isA<ImportException>()),
    );
  });

  // ── is_favorite bool/int Typflexibilität (Bug #4) ────────────────────────

  test('fromMap akzeptiert is_favorite als bool (JSON-Format)', () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle({
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': [
        {
          'id': 'b1000000-0000-4000-8000-000000000001',
          'title': 'Bool-Favorite Test',
          'category': 'movie',
          'source': 'test',
          'provider_id': 'bool-fav-001',
          'is_favorite': true, // bool statt int — kein TypeError
          'tags': <String>[],
        }
      ],
    });
    expect(result.imported, 1);
    final item = await svc.getItem('b1000000-0000-4000-8000-000000000001');
    expect(item!.isFavorite, isTrue);
  });

  test('fromMap akzeptiert is_favorite als int (SQLite-Format)', () async {
    final svc = DatabaseService.instance;
    final result = await svc.importLibraryBundle({
      'schema': librarySchemaName,
      'schema_version': 1,
      'items': [
        {
          'id': 'b2000000-0000-4000-8000-000000000002',
          'title': 'Int-Favorite Test',
          'category': 'music',
          'source': 'test',
          'provider_id': 'int-fav-002',
          'is_favorite': 1,
          'tags': <String>[],
        }
      ],
    });
    expect(result.imported, 1);
    final item = await svc.getItem('b2000000-0000-4000-8000-000000000002');
    expect(item!.isFavorite, isTrue);
  });

  // ── DB-Singleton Race Condition (Bug #2) ─────────────────────────────────

  test('database getter gibt bei parallelen Aufrufen dieselbe Instanz zurück',
      () async {
    final svc = DatabaseService.instance;
    final futures = List.generate(5, (_) => svc.database);
    final dbs = await Future.wait(futures);
    for (final db in dbs) {
      expect(db, same(dbs.first));
    }
  });

  test('close() setzt Future zurück und erlaubt saubere Neuöffnung', () async {
    final svc = DatabaseService.instance;
    await svc.database; // öffnet DB
    await svc.close(); // schließt + setzt _dbFuture = null
    final db = await svc.database; // muss sauber neu öffnen
    expect(db.isOpen, isTrue);
  });

  // ── Manuell angelegte Items (UUID, Bug #3) ───────────────────────────────

  test('manuell angelegtes Item mit UUID-ID übersteht Export→Import-Roundtrip',
      () async {
    final svc = DatabaseService.instance;
    const manualId = 'c9bf9e57-1685-4c89-bafb-ff5af830be8a';
    await svc.upsert(MediaItem(
      id: manualId,
      title: 'Manueller Eintrag',
      category: MediaCategory.movie,
      source: 'manual',
      providerId: '',
    ));

    final payload = await svc.buildExportPayload();
    await svc.clearAll();

    final result = await svc.importLibraryBundle(payload);
    expect(result.imported, 1);
    final item = await svc.getItem(manualId);
    expect(item, isNotNull);
    expect(item!.id, manualId);
  });

  // ── Roundtrip ─────────────────────────────────────────────────────────────

  test('Export→Import Roundtrip erhält title und tags', () async {
    final svc = DatabaseService.instance;
    await insertTestItem(svc,
        id: 'a1000000-0000-4000-8000-000000000002',
        title: 'Roundtrip Film',
        tags: 'test|roundtrip');

    final payload = await svc.buildExportPayload();
    await svc.clearAll();

    final result = await svc.importLibraryBundle(payload);
    expect(result.imported, 1);

    final item = await svc.getItem('a1000000-0000-4000-8000-000000000002');
    expect(item, isNotNull);
    expect(item!.title, 'Roundtrip Film');
    expect(item.tags, containsAll(['test', 'roundtrip']));
  });
}
