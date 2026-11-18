// L10n-Tests: DB-frei, prüft DE+EN+ES Strings, ARB-Parität und Abwesenheit
// harter DE/EN-Reste in UI-Dateien.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediabrain/l10n/app_localizations.dart';
import 'package:mediabrain/models/models.dart';

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
  testWidgets('DE nav labels', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.navLibrary, 'Bibliothek');
    expect(loc.navScan, 'Scan');
    expect(loc.navMore, 'Mehr');
    expect(loc.neverText, 'nie');
  });

  testWidgets('EN nav labels', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.navLibrary, 'Library');
    expect(loc.navScan, 'Scan');
    expect(loc.navMore, 'More');
    expect(loc.neverText, 'never');
  });

  testWidgets('DE scanResult parametrized', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final loc = _loc(tester);
    expect(
      loc.scanResult(5, 3),
      'Apps-Scan: 5 Medien-Apps gefunden, 3 Einträge übernommen.',
    );
  });

  testWidgets('EN scanResult parametrized', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pump();
    final loc = _loc(tester);
    expect(
      loc.scanResult(5, 3),
      'App scan: 5 media apps found, 3 entries added.',
    );
  });

  testWidgets('DE usageMinutes', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.usageMinutes(1), '1 Minute');
    expect(loc.usageMinutes(42), '42 Minuten');
    expect(loc.foregroundMinutesLabel(10), '10 Min insgesamt');
  });

  testWidgets('EN usageMinutes', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.usageMinutes(1), '1 minute');
    expect(loc.usageMinutes(42), '42 minutes');
    expect(loc.foregroundMinutesLabel(10), '10 min total');
  });

  testWidgets('DE pushPullStatus', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.pushPullStatus('nie', 'nie'), 'Push: nie · Pull: nie');
  });

  testWidgets('DE seasonEpisode', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.seasonEpisode(2, 5), 'S2 E5');
  });

  testWidgets('ES nav labels', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.navLibrary, 'Biblioteca');
    expect(loc.navScan, 'Escanear');
    expect(loc.navMore, 'Más');
    expect(loc.neverText, 'nunca');
  });

  testWidgets('ES scanResult parametrized', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final loc = _loc(tester);
    expect(
      loc.scanResult(5, 3),
      'Escaneo de apps: 5 apps encontradas, 3 entradas añadidas.',
    );
  });

  testWidgets('ES usageMinutes', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.usageMinutes(1), '1 minuto');
    expect(loc.usageMinutes(42), '42 minutos');
    expect(loc.foregroundMinutesLabel(10), '10 min en total');
  });

  testWidgets('ES pushPullStatus', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.pushPullStatus('nunca', 'nunca'), 'Push: nunca · Pull: nunca');
  });

  testWidgets('ES seasonEpisode', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final loc = _loc(tester);
    expect(loc.seasonEpisode(2, 5), 'T2 E5');
  });

  testWidgets('Kategorien sind in DE, EN und ES vollständig lokalisiert',
      (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('de')));
    await tester.pump();
    final de = _loc(tester);
    expect(MediaCategory.movie.localizedLabel(de), 'Film');
    expect(MediaCategory.audiobook.localizedLabel(de), 'Hörbuch');
    expect(MediaCategory.document.localizedLabel(de), 'Dokument');

    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pump();
    final en = _loc(tester);
    expect(MediaCategory.movie.localizedLabel(en), 'Movie');
    expect(MediaCategory.audiobook.localizedLabel(en), 'Audiobook');
    expect(MediaCategory.document.localizedLabel(en), 'Document');

    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final es = _loc(tester);
    expect(MediaCategory.movie.localizedLabel(es), 'Película');
    expect(MediaCategory.music.localizedLabel(es), 'Música');
    expect(MediaCategory.audiobook.localizedLabel(es), 'Audiolibro');
    expect(MediaCategory.document.localizedLabel(es), 'Documento');
  });

  testWidgets('ES Sync- und Sprachwähler-Strings sind vollständig',
      (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    final es = _loc(tester);
    expect(es.languageTitle, 'Idioma de la aplicación');
    expect(es.languageSystem, 'Predeterminado del sistema');
    expect(es.languageGerman, 'Deutsch');
    expect(es.languageEnglish, 'English');
    expect(es.languageSpanish, 'Español');
    expect(es.syncSummaryItems(1), '1 entrada');
    expect(es.syncSummaryItems(4), '4 entradas');
    expect(es.syncPlaylistsImported(1), '1 lista');
    expect(es.syncPlaylistsImported(2), '2 listas');
    expect(es.minMinutesChip(30), '≥ 30 min');
    expect(es.favoritesLabel, 'Favoritos');
  });

  test('ARB-Dateien DE/EN/ES besitzen exakt dieselben Keys ohne Leerwerte', () {
    Map<String, dynamic> loadArb(String name) =>
        jsonDecode(File('lib/l10n/$name').readAsStringSync())
            as Map<String, dynamic>;

    final de = loadArb('app_de.arb');
    final en = loadArb('app_en.arb');
    final es = loadArb('app_es.arb');

    Set<String> msgKeys(Map<String, dynamic> m) =>
        m.keys.where((k) => !k.startsWith('@')).toSet();

    final deKeys = msgKeys(de);
    final enKeys = msgKeys(en);
    final esKeys = msgKeys(es);

    expect(enKeys, equals(deKeys),
        reason: 'EN ARB muss exakt dieselben Message-Keys wie DE besitzen');
    expect(esKeys, equals(deKeys),
        reason: 'ES ARB muss exakt dieselben Message-Keys wie DE besitzen');

    for (final k in deKeys) {
      expect((de[k] as String).trim(), isNotEmpty, reason: 'DE:$k leer');
      expect((en[k] as String).trim(), isNotEmpty, reason: 'EN:$k leer');
      expect((es[k] as String).trim(), isNotEmpty, reason: 'ES:$k leer');
    }

    // Alle Keys müssen auch in app_localizations.dart deklariert sein.
    final dartSrc = File('lib/l10n/app_localizations.dart').readAsStringSync();
    for (final k in deKeys) {
      final hasGetterOrMethod =
          RegExp('(\\bget $k\\b|\\b$k\\()').hasMatch(dartSrc);
      expect(hasGetterOrMethod, isTrue,
          reason: 'Key $k fehlt in AppLocalizations');
    }
  });

  test('Keine harten DE-UI-Reste in Screens und Dialogen', () {
    final playlistDetailSrc =
        File('lib/screens/playlist_detail_screen.dart').readAsStringSync();
    final playlistDialogSrc =
        File('lib/dialogs/playlist_dialog.dart').readAsStringSync();
    final itemDetailSrc =
        File('lib/screens/item_detail_screen.dart').readAsStringSync();

    expect(playlistDetailSrc.contains("'Favoriten'"), isFalse);
    expect(playlistDialogSrc.contains("Text(' ')"), isFalse);
    expect(playlistDialogSrc.contains("'z.B. anime, sci-fi'"), isFalse);
    expect(itemDetailSrc.contains("'z.B. anime, doku, top10'"), isFalse);
    expect(itemDetailSrc.contains("Uhr'"), isFalse);
  });
}
