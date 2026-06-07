// L10n-Tests: DB-frei, prüft DE+EN Strings ohne sqflite.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediabrain/l10n/app_localizations.dart';

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
}
