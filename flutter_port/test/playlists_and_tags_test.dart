/// Tests für Smart-Playlists und Tag-System in MediaBrain Mobile.
///
/// Nutzt sqflite_common_ffi mit inMemoryDatabasePath.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mediabrain/l10n/app_localizations.dart';
import 'package:mediabrain/models/models.dart';
import 'package:mediabrain/services/database_service.dart';

Widget _app({Locale locale = const Locale('de')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (ctx) => Text(AppLocalizations.of(ctx).appTitle),
    ),
  );
}

AppLocalizations _loc(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Text).first));

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseService.overrideDbPath = inMemoryDatabasePath;
  });

  setUp(() async => DatabaseService.instance.close());

  group('Modelle & Smart-Matching Engine', () {
    test('MediaTag serialization and equality', () {
      const tag1 = MediaTag(name: 'sci-fi', count: 5);
      final map = tag1.toMap();
      expect(map['name'], 'sci-fi');
      expect(map['count'], 5);

      final from = MediaTag.fromMap(map);
      expect(from, equals(tag1));
      expect(from.hashCode, equals(tag1.hashCode));
    });

    test('PlaylistType string helper', () {
      expect(playlistTypeFromString('manual'), PlaylistType.manual);
      expect(playlistTypeFromString('smart'), PlaylistType.smart);
      expect(playlistTypeFromString('unknown'), PlaylistType.manual);

      expect(playlistTypeToString(PlaylistType.manual), 'manual');
      expect(playlistTypeToString(PlaylistType.smart), 'smart');
    });

    test('SmartPlaylistQuery matches category, tag, fav, minutes, and search', () {
      final item = MediaItem(
        id: 'item-1',
        title: 'Interstellar Voyage',
        category: MediaCategory.movie,
        source: 'tmdb',
        providerId: 'm123',
        artist: 'Christopher Nolan',
        isFavorite: true,
        foregroundMinutes: 120,
        tags: const ['sci-fi', 'space', 'epic'],
      );

      // Matches all
      const q1 = SmartPlaylistQuery(
        category: MediaCategory.movie,
        tag: 'sci-fi',
        favoritesOnly: true,
        minForegroundMinutes: 60,
        searchQuery: 'Interstellar',
      );
      expect(q1.matches(item), isTrue);

      // Category mismatch
      const q2 = SmartPlaylistQuery(category: MediaCategory.music);
      expect(q2.matches(item), isFalse);

      // Tag mismatch
      const q3 = SmartPlaylistQuery(tag: 'comedy');
      expect(q3.matches(item), isFalse);

      // Favorites only mismatch
      final nonFav = item.copyWith(isFavorite: false);
      const q4 = SmartPlaylistQuery(favoritesOnly: true);
      expect(q4.matches(nonFav), isFalse);

      // Min minutes mismatch
      const q5 = SmartPlaylistQuery(minForegroundMinutes: 150);
      expect(q5.matches(item), isFalse);

      // Search match in artist
      const q6 = SmartPlaylistQuery(searchQuery: 'nolan');
      expect(q6.matches(item), isTrue);
    });

    test('Playlist serialization roundtrip', () {
      final now = DateTime.utc(2026, 8, 21, 12, 0, 0);
      final pl = Playlist(
        id: 'pl-100',
        name: 'Sci-Fi Hits',
        description: 'Beste Sci-Fi Filme',
        type: PlaylistType.smart,
        smartQuery: const SmartPlaylistQuery(
          category: MediaCategory.movie,
          tag: 'sci-fi',
          favoritesOnly: true,
        ),
        createdAt: now,
        updatedAt: now,
        itemCount: 4,
      );

      final map = pl.toMap();
      expect(map['id'], 'pl-100');
      expect(map['playlist_type'], 'smart');
      expect(map['smart_query'], isNotNull);

      final reconstructed = Playlist.fromMap(map);
      expect(reconstructed.id, pl.id);
      expect(reconstructed.name, pl.name);
      expect(reconstructed.type, PlaylistType.smart);
      expect(reconstructed.isSmart, isTrue);
      expect(reconstructed.smartQuery?.category, MediaCategory.movie);
      expect(reconstructed.smartQuery?.tag, 'sci-fi');
      expect(reconstructed.smartQuery?.favoritesOnly, isTrue);
    });
  });

  group('DatabaseService Playlists & Tags Integration', () {
    test('Manuelle Playlist Lifecycle', () async {
      final svc = DatabaseService.instance;

      final itemA = MediaItem(
        id: 'item-a',
        title: 'Song A',
        category: MediaCategory.music,
        source: 'spotify',
        providerId: 's1',
      );
      final itemB = MediaItem(
        id: 'item-b',
        title: 'Song B',
        category: MediaCategory.music,
        source: 'spotify',
        providerId: 's2',
      );

      await svc.upsert(itemA);
      await svc.upsert(itemB);

      final now = DateTime.now();
      final pl = Playlist(
        id: 'pl-manual-1',
        name: 'Lieblingslieder',
        description: 'Meine Favoriten',
        type: PlaylistType.manual,
        createdAt: now,
        updatedAt: now,
      );

      await svc.upsertPlaylist(pl);

      var playlists = await svc.listPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.name, 'Lieblingslieder');
      expect(playlists.first.itemCount, 0);

      // Add items
      await svc.addItemToPlaylist('pl-manual-1', 'item-a');
      await svc.addItemToPlaylist('pl-manual-1', 'item-b');

      playlists = await svc.listPlaylists();
      expect(playlists.first.itemCount, 2);

      var items = await svc.getPlaylistItems('pl-manual-1');
      expect(items.length, 2);
      expect(items[0].id, 'item-a');
      expect(items[1].id, 'item-b');

      // Filter listItems by playlistId
      final plItems = await svc.listItems(playlistId: 'pl-manual-1');
      expect(plItems.length, 2);

      // Remove item
      await svc.removeItemFromPlaylist('pl-manual-1', 'item-a');
      items = await svc.getPlaylistItems('pl-manual-1');
      expect(items.length, 1);
      expect(items.first.id, 'item-b');

      // Delete playlist
      await svc.deletePlaylist('pl-manual-1');
      playlists = await svc.listPlaylists();
      expect(playlists, isEmpty);

      // Items still exist in library
      final libraryItems = await svc.listItems();
      expect(libraryItems.length, 2);
    });

    test('Smart Playlist Dynamic Evaluation', () async {
      final svc = DatabaseService.instance;

      final doc1 = MediaItem(
        id: 'doc-1',
        title: 'Plan D Architektur',
        category: MediaCategory.document,
        source: 'pdf',
        providerId: 'p1',
        isFavorite: true,
        tags: const ['system', 'plan-d'],
      );
      final doc2 = MediaItem(
        id: 'doc-2',
        title: 'Einkaufsliste',
        category: MediaCategory.document,
        source: 'note',
        providerId: 'p2',
        isFavorite: false,
        tags: const ['notiz'],
      );
      final movie1 = MediaItem(
        id: 'mov-1',
        title: 'System Crash Movie',
        category: MediaCategory.movie,
        source: 'netflix',
        providerId: 'm1',
        isFavorite: true,
        tags: const ['system'],
      );

      await svc.upsert(doc1);
      await svc.upsert(doc2);
      await svc.upsert(movie1);

      final now = DateTime.now();
      final smartPl = Playlist(
        id: 'pl-smart-1',
        name: 'Wichtige Systemdokumente',
        description: 'Automatisch gefiltert',
        type: PlaylistType.smart,
        smartQuery: const SmartPlaylistQuery(
          category: MediaCategory.document,
          tag: 'system',
          favoritesOnly: true,
        ),
        createdAt: now,
        updatedAt: now,
      );

      await svc.upsertPlaylist(smartPl);

      final playlists = await svc.listPlaylists();
      expect(playlists.first.itemCount, 1);

      final matchedItems = await svc.getPlaylistItems('pl-smart-1');
      expect(matchedItems.length, 1);
      expect(matchedItems.first.id, 'doc-1');
    });

    test('Tag-Verwaltung und Suche per Tag', () async {
      final svc = DatabaseService.instance;

      final item = MediaItem(
        id: 'item-tag-test',
        title: 'Podcast Episode 42',
        category: MediaCategory.podcast,
        source: 'rss',
        providerId: 'pod42',
        tags: const ['tech', 'flutter'],
      );
      await svc.upsert(item);

      var tags = await svc.listTags();
      expect(tags.length, 2);
      expect(tags.map((t) => t.name), containsAll(['tech', 'flutter']));

      // Add new tag
      await svc.addTagToItem('item-tag-test', 'ai');
      tags = await svc.listTags();
      expect(tags.length, 3);
      expect(tags.map((t) => t.name), contains('ai'));

      // Filter items by tag
      final flutterItems = await svc.listItems(tag: 'flutter');
      expect(flutterItems.length, 1);
      expect(flutterItems.first.id, 'item-tag-test');

      // Remove tag
      await svc.removeTagFromItem('item-tag-test', 'flutter');
      final updated = await svc.getItem('item-tag-test');
      expect(updated?.tags, containsAll(['tech', 'ai']));
      expect(updated?.tags.contains('flutter'), isFalse);
    });
  });

  group('L10n Lokalisierungs-Parität für Playlists & Tags', () {
    testWidgets('DE Playlists und Tags Lokalisierung', (tester) async {
      await tester.pumpWidget(_app(locale: const Locale('de')));
      await tester.pump();
      final loc = _loc(tester);

      expect(loc.navPlaylists, 'Playlists');
      expect(loc.screenPlaylists, 'Playlists & Sammlungen');
      expect(loc.playlistTypeManual, 'Manuell');
      expect(loc.playlistTypeSmart, 'Smart (Dynamischer Filter)');
      expect(loc.dialogNewPlaylist, 'Neue Playlist');
      expect(loc.dialogEditPlaylist, 'Playlist bearbeiten');
      expect(loc.playlistItemCount(1), '1 Eintrag');
      expect(loc.playlistItemCount(5), '5 Einträge');
      expect(loc.tagCount('sci-fi', 3), '#sci-fi (3)');
      expect(loc.addToPlaylist, 'Zu Playlist hinzufügen');
      expect(loc.removeFromPlaylist, 'Aus Playlist entfernen');
    });

    testWidgets('EN Playlists und Tags Lokalisierung', (tester) async {
      await tester.pumpWidget(_app(locale: const Locale('en')));
      await tester.pump();
      final loc = _loc(tester);

      expect(loc.navPlaylists, 'Playlists');
      expect(loc.screenPlaylists, 'Playlists & Collections');
      expect(loc.playlistTypeManual, 'Manual');
      expect(loc.playlistTypeSmart, 'Smart (Dynamic Filter)');
      expect(loc.dialogNewPlaylist, 'New Playlist');
      expect(loc.dialogEditPlaylist, 'Edit Playlist');
      expect(loc.playlistItemCount(1), '1 item');
      expect(loc.playlistItemCount(5), '5 items');
      expect(loc.tagCount('sci-fi', 3), '#sci-fi (3)');
      expect(loc.addToPlaylist, 'Add to playlist');
      expect(loc.removeFromPlaylist, 'Remove from playlist');
    });
  });
}
