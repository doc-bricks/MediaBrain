/// Bugsweep- und UX/Design/A11y-Regressionstests für MediaBrain Mobile.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mediabrain/dialogs/playlist_dialog.dart';
import 'package:mediabrain/l10n/app_localizations.dart';
import 'package:mediabrain/main.dart';
import 'package:mediabrain/models/models.dart';
import 'package:mediabrain/screens/item_detail_screen.dart';
import 'package:mediabrain/screens/library_screen.dart';
import 'package:mediabrain/screens/playlist_detail_screen.dart';
import 'package:mediabrain/screens/playlists_screen.dart';
import 'package:mediabrain/screens/settings_screen.dart';
import 'package:mediabrain/services/database_service.dart';
import 'package:mediabrain/services/locale_controller.dart';
import 'package:mediabrain/services/sync_service.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('es')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    DatabaseService.overrideDbPath = inMemoryDatabasePath;
  });

  setUp(() async {
    await DatabaseService.instance.close();
    await DatabaseService.instance.database;
    LocaleController.instance.value = null;
  });

  group('Datenmodelle & SQLite Edge Cases', () {
    test('sanitizeTagName entfernt Pipe-Trennzeichen und trimmt', () {
      expect(sanitizeTagName('  sci|fi  '), 'sci fi');
      expect(sanitizeTagName('|||'), '');
    });

    test('addTagToItem speichert Tag mit Pipe als einzelnes Tag', () async {
      final svc = DatabaseService.instance;
      await svc.upsert(const MediaItem(
        id: 'tag-pipe-1',
        title: 'Pipe Test',
        category: MediaCategory.music,
      ));
      await svc.addTagToItem('tag-pipe-1', 'rock|pop');
      final item = await svc.getItem('tag-pipe-1');
      expect(item?.tags, ['rock pop']);
    });

    test('listTags gruppiert Tags case-insensitiv ohne Dubletten', () async {
      final svc = DatabaseService.instance;
      await svc.upsert(const MediaItem(
        id: 't1',
        title: 'Film 1',
        category: MediaCategory.movie,
        tags: ['Sci-Fi'],
      ));
      await svc.upsert(const MediaItem(
        id: 't2',
        title: 'Film 2',
        category: MediaCategory.movie,
        tags: ['sci-fi'],
      ));
      final tags = await svc.listTags();
      expect(tags.length, 1);
      expect(tags.first.count, 2);
    });

    test('fromMap verarbeitet String-Zahlen und Map smart_query ohne TypeError',
        () {
      final item = MediaItem.fromMap({
        'id': 'm1',
        'title': 'Test',
        'category': 'music',
        'season': '2',
        'episode': 5,
        'foreground_minutes': '45',
        'is_favorite': true,
      });
      expect(item.season, 2);
      expect(item.episode, 5);
      expect(item.foregroundMinutes, 45);
      expect(item.isFavorite, isTrue);

      final pl = Playlist.fromMap({
        'id': 'p1',
        'name': 'Smart Map',
        'playlist_type': 'smart',
        'smart_query': {'category': 'movie', 'min_foreground_minutes': '10'},
      });
      expect(pl.isSmart, isTrue);
      expect(pl.smartQuery?.category, MediaCategory.movie);
      expect(pl.smartQuery?.minForegroundMinutes, 10);
    });

    test('importLibraryBundle lehnt nicht-numerische schema_version ab',
        () async {
      final svc = DatabaseService.instance;
      expect(
        () => svc.importLibraryBundle({
          'schema': librarySchemaName,
          'schema_version': 'invalid',
          'items': <dynamic>[],
        }),
        throwsA(isA<ImportException>()),
      );
    });

    test('importLibraryBundle überlebt nicht-String title und null item_ids',
        () async {
      final svc = DatabaseService.instance;
      final res = await svc.importLibraryBundle({
        'schema': librarySchemaName,
        'schema_version': 1,
        'items': [
          {'id': 'bad-1', 'title': 12345, 'category': 'movie'},
          {'id': 'ok-1', 'title': 'Gültig', 'category': 'movie'},
        ],
        'playlists': [
          {
            'id': 'pl-null-id',
            'name': 'Mix',
            'playlist_type': 'manual',
            'item_ids': [null, 'ok-1'],
          }
        ],
      });
      expect(res.imported, 1);
      expect(res.skipped, 1);
      expect(res.playlistsImported, 1);
    });
  });

  group('URL-Validierung & External Launch', () {
    test('SyncService.validateServerUrl prüft HTTPS, Whitespace und Schemas',
        () {
      expect(SyncService.validateServerUrl(null), isNull);
      expect(SyncService.validateServerUrl('   '), isNull);
      expect(
        SyncService.validateServerUrl('macstudvonlukas:8082/'),
        'https://macstudvonlukas:8082',
      );
      expect(
        () => SyncService.validateServerUrl('http://example.com'),
        throwsA(predicate<SyncException>(
            (e) => e.code == SyncErrorCode.httpsRequired)),
      );
      expect(
        () => SyncService.validateServerUrl('ftp://example.com'),
        throwsA(predicate<SyncException>(
            (e) => e.code == SyncErrorCode.invalidUrl)),
      );
      expect(
        () => SyncService.validateServerUrl('https://bad host'),
        throwsA(predicate<SyncException>(
            (e) => e.code == SyncErrorCode.invalidUrl)),
      );
    });

    test('ItemDetailScreen.guessExternalUrl unterscheidet URLs, Apps und Provider',
        () {
      expect(
        ItemDetailScreen.guessExternalUrl(const MediaItem(
          id: '1',
          title: 'Web',
          category: MediaCategory.clip,
          providerId: 'https://example.org/watch?v=1',
        )),
        'https://example.org/watch?v=1',
      );
      expect(
        ItemDetailScreen.guessExternalUrl(const MediaItem(
          id: '2',
          title: 'Spotify App',
          category: MediaCategory.music,
          providerId: 'com.spotify.music',
        )),
        'https://play.google.com/store/apps/details?id=com.spotify.music',
      );
      expect(
        ItemDetailScreen.guessExternalUrl(const MediaItem(
          id: '3',
          title: 'YT',
          category: MediaCategory.clip,
          source: 'youtube',
          providerId: 'dQw4w9WgXcQ',
        )),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(
        ItemDetailScreen.guessExternalUrl(const MediaItem(
          id: '4',
          title: 'Local',
          category: MediaCategory.document,
          source: 'manual',
          providerId: 'not a valid id',
        )),
        isNull,
      );
    });
  });

  group('LocaleController & Settings Sprachwähler', () {
    test('LocaleController persistiert und lädt Sprache in SQLite', () async {
      expect(LocaleController.parseLocaleCode('system'), isNull);
      expect(LocaleController.parseLocaleCode('ES'), const Locale('es'));
      expect(LocaleController.parseLocaleCode('fr'), isNull);

      await LocaleController.instance.setLocaleCode('es');
      expect(LocaleController.instance.value, const Locale('es'));

      LocaleController.instance.value = null;
      await LocaleController.instance.loadSavedLocale();
      expect(LocaleController.instance.value, const Locale('es'));

      await LocaleController.instance.setLocaleCode(null);
      expect(LocaleController.instance.value, isNull);
    });

    testWidgets('Sprachwähler in Settings wechselt gesamte App live auf Spanisch',
        (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('de')];
      addTearDown(() => tester.platformDispatcher.clearLocalesTestValue());

      await tester.pumpWidget(const MediaBrainApp());
      for (var i = 0; i < 40; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)));
        await tester.pump();
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
      }

      // Auf Settings-Tab wechseln
      await tester.tap(find.text('Mehr'));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(find.text('App-Sprache'), findsOneWidget);
      await tester.tap(find.text('App-Sprache'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español'));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();

      expect(LocaleController.instance.value, const Locale('es'));
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Idioma de la aplicación'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
    });
  });

  group('Widget-UX, ES-Vollständigkeit & A11y', () {
    Future<void> settleDbWidget(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.pump();
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)));
      }
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    testWidgets('PlaylistDialog zeigt alle 8 Kategorien auf Spanisch (kein Leer-Chip)',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Scaffold(body: PlaylistDialog()),
          locale: const Locale('es'),
        ),
      );
      await tester.pumpAndSettle();

      // Auf Smart-Typ umschalten
      await tester.tap(find.text('Inteligente (filtro dinámico)'));
      await tester.pumpAndSettle();

      expect(find.text('Película'), findsOneWidget);
      expect(find.text('Música'), findsOneWidget);
      expect(find.text('Audiolibro'), findsOneWidget);
      expect(find.text('Documento'), findsOneWidget);
      expect(find.text(' '), findsNothing);

      // Leerer Name zeigt Validierungsfehler statt stilles Nichts-Tun
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Este campo no puede estar vacío.'), findsOneWidget);
    });

    testWidgets('PlaylistDetailScreen zeigt spanische Smart-Chips statt "Favoriten"',
        (tester) async {
      final svc = DatabaseService.instance;
      final now = DateTime.now();
      const item = MediaItem(
        id: 'es-m1',
        title: 'Canción Uno',
        category: MediaCategory.music,
        isFavorite: true,
        foregroundMinutes: 45,
      );
      final pl = Playlist(
        id: 'es-pl1',
        name: 'Top Música',
        type: PlaylistType.smart,
        smartQuery: const SmartPlaylistQuery(
          category: MediaCategory.music,
          favoritesOnly: true,
          minForegroundMinutes: 30,
        ),
        createdAt: now,
        updatedAt: now,
      );
      await tester.runAsync(() async {
        await svc.upsert(item);
        await svc.upsertPlaylist(pl);
      });

      await tester.pumpWidget(
        _wrap(PlaylistDetailScreen(playlist: pl), locale: const Locale('es')),
      );
      await settleDbWidget(tester);

      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Favoriten'), findsNothing);
      expect(find.text('≥ 30 min'), findsOneWidget);
      expect(find.text('Música'), findsWidgets);
    });

    testWidgets('PlaylistsScreen läuft auf schmalem Screen (360px) auf ES ohne Overflow',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(const PlaylistsScreen(), locale: const Locale('es')),
      );
      await settleDbWidget(tester);

      expect(find.text('Listas y colecciones'), findsOneWidget);
      expect(find.text('Inteligente (filtro dinámico)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ItemDetailScreen zeigt Not-Found-State und lokalisierten Tag-Dialog',
        (tester) async {
      // Fehlender Eintrag -> kein Endlos-Spinner
      await tester.pumpWidget(
        _wrap(const ItemDetailScreen(id: 'missing-id'),
            locale: const Locale('es')),
      );
      await settleDbWidget(tester);
      expect(find.text('Entrada no encontrada.'), findsOneWidget);
      expect(find.text('Atrás'), findsOneWidget);

      // Vorhandener Eintrag -> lokalisiert, ohne "Uhr", Tag-Dialog validiert
      final svc = DatabaseService.instance;
      await tester.runAsync(() async {
        await svc.upsert(MediaItem(
          id: 'es-item-1',
          title: 'Documental',
          category: MediaCategory.movie,
          lastOpenedAt: DateTime(2026, 11, 18, 14, 30),
          foregroundMinutes: 15,
        ));
      });

      await tester.pumpWidget(
        _wrap(const ItemDetailScreen(id: 'es-item-1'),
            locale: const Locale('es')),
      );
      await settleDbWidget(tester);

      expect(find.text('Película'), findsOneWidget);
      expect(find.textContaining('Uhr'), findsNothing);
      expect(find.text('15 minutos'), findsOneWidget);

      // Touch-Target >= 48dp auf Playlist-Button
      final btnSize = tester.getSize(find.widgetWithText(OutlinedButton, 'Añadir a lista'));
      expect(btnSize.height, greaterThanOrEqualTo(48));

      // Tag-Dialog öffnen, leer absenden -> Pflichtfeld, dann gültiges Tag speichern
      await tester.tap(find.text('Añadir etiqueta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Este campo no puede estar vacío.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'estreno');
      await tester.tap(find.text('Guardar'));
      await settleDbWidget(tester);
      expect(find.widgetWithText(InputChip, 'estreno'), findsOneWidget);
    });

    testWidgets('LibraryScreen Suche-Löschen und Filter-Zurücksetzen auf ES',
        (tester) async {
      final svc = DatabaseService.instance;
      await tester.runAsync(() async {
        await svc.upsert(const MediaItem(
          id: 'lib-1',
          title: 'Película Ejemplo',
          category: MediaCategory.movie,
        ));
      });

      await tester.pumpWidget(
        _wrap(const LibraryScreen(), locale: const Locale('es')),
      );
      await settleDbWidget(tester);

      expect(find.text('Película Ejemplo'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'no-existe');
      await settleDbWidget(tester);

      expect(find.text('No hay resultados para tus filtros.'), findsOneWidget);
      expect(find.text('Restablecer filtros'), findsOneWidget);

      await tester.tap(find.text('Restablecer filtros'));
      await settleDbWidget(tester);
      expect(find.text('Película Ejemplo'), findsOneWidget);
    });

    testWidgets('SettingsScreen zeigt lokalisierte Sync-Zusammenfassung',
        (tester) async {
      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: const Locale('es')),
      );
      await tester.pumpAndSettle();
      final loc = AppLocalizations.of(
          tester.element(find.byType(SettingsScreen)));

      const summary = SyncSummary(
        items: 3,
        playlistsImported: 1,
        statusCode: SyncStatusCode.imported,
      );
      expect(summary.localizedText(loc), '3 entradas · 1 lista');
      expect(
        const SyncException('x', code: SyncErrorCode.noUrl)
            .localizedMessage(loc),
        'No hay ninguna URL de servidor configurada. Introdúcela en Ajustes.',
      );
    });
  });
}
