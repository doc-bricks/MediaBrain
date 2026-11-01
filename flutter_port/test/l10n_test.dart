// L10n-Tests: DB-frei, prüft DE+EN Strings ohne sqflite.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediabrain/l10n/app_localizations.dart';

Widget _app({Locale locale = const Locale('de')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (ctx) => Text(AppLocalizations.of(ctx).appTitle)),
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
    expect(loc.usageMinutes(42), '42 Minuten');
    expect(loc.foregroundMinutesLabel(10), '10 Min insgesamt');
  });

  testWidgets('EN usageMinutes', (tester) async {
    await tester.pumpWidget(_app(locale: const Locale('en')));
    await tester.pump();
    final loc = _loc(tester);
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

  testWidgets('all 11 generated locales resolve into their own bundle', (
    tester,
  ) async {
    const locales = <Locale>[
      Locale('de'),
      Locale('en'),
      Locale('es'),
      Locale('zh'),
      Locale('ja'),
      Locale('ru'),
      Locale('fr'),
      Locale('hi'),
      Locale('ar'),
      Locale('bn'),
      Locale('pt'),
    ];
    for (final locale in locales) {
      await tester.pumpWidget(_app(locale: locale));
      await tester.pump();
      final context = tester.element(find.byType(Text).first);
      expect(
        Localizations.localeOf(context).languageCode,
        locale.languageCode,
        reason: 'The requested ${locale.languageCode} ARB should resolve.',
      );
      final label = _loc(tester).navLibrary;
      expect(label, isNotEmpty);
      final countLabel = _loc(tester).playlistItemCount(7);
      expect(countLabel, contains('7'));
      expect(countLabel, isNot(contains('#')));
      if (locale.languageCode != 'en') {
        expect(
          label,
          isNot('Library'),
          reason: '${locale.languageCode} must not silently use English.',
        );
      }
    }
  });

  testWidgets(
    'regional locales match language bundles and unknown locale falls back to German',
    (tester) async {
      await tester.pumpWidget(_app(locale: const Locale('es', 'MX')));
      await tester.pump();
      var context = tester.element(find.byType(Text).first);
      expect(Localizations.localeOf(context), const Locale('es'));
      expect(_loc(tester).navLibrary, 'Biblioteca');

      await tester.pumpWidget(_app(locale: const Locale('zz')));
      await tester.pump();
      context = tester.element(find.byType(Text).first);
      expect(Localizations.localeOf(context), const Locale('de'));
      expect(_loc(tester).navLibrary, 'Bibliothek');
    },
  );

  testWidgets('generated placeholders and ICU plurals preserve call behavior', (
    tester,
  ) async {
    await tester.pumpWidget(_app(locale: const Locale('es')));
    await tester.pump();
    var loc = _loc(tester);
    expect(loc.error('offline'), 'Error: offline');
    expect(loc.tagCount('sci-fi', 3), '#sci-fi (3)');
    expect(loc.playlistItemCount(1), contains('elemento'));
    expect(loc.playlistItemCount(2), contains('elementos'));

    await tester.pumpWidget(_app(locale: const Locale('ru')));
    await tester.pump();
    loc = _loc(tester);
    expect(loc.playlistItemCount(1), contains('элемент'));
    expect(loc.playlistItemCount(2), contains('элемента'));
    expect(loc.playlistItemCount(5), contains('элементов'));

    await tester.pumpWidget(_app(locale: const Locale('ar')));
    await tester.pump();
    loc = _loc(tester);
    expect(loc.playlistItemCount(0), contains('عنصر'));
    expect(loc.playlistItemCount(2), contains('عنصران'));
    expect(loc.playlistItemCount(3), contains('عناصر'));
    expect(loc.playlistItemCount(11), contains('عنصرًا'));
  });

  testWidgets('Arabic locale supplies right-to-left text direction', (
    tester,
  ) async {
    await tester.pumpWidget(_app(locale: const Locale('ar')));
    await tester.pump();
    final context = tester.element(find.byType(Text).first);
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
