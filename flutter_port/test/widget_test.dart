// Smoke-Test: prüft, dass die MediaBrain-App fehlerfrei aufbaut.
//
// Bewusst kein DB-abhängiger Test (sqflite ist im Test-VM nicht verfügbar):
// ein einzelner pumpWidget-Frame reicht, um Build-/Layout-Fehler zu finden.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediabrain/main.dart';

void main() {
  testWidgets('MediaBrainApp baut ohne Fehler auf', (WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('de')];
    addTearDown(() => tester.platformDispatcher.clearLocalesTestValue());
    await tester.pumpWidget(const MediaBrainApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
