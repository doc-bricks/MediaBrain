// Regressionstest fuer den Mobile-Bugsweep RE-SWEEP 2026-06-23 (MediaBrain/flutter_port).
//
// Statische Quelltext-Assertion (flutter/dart nicht im PATH). Red-on-revert.
// Befund: usageMinutes(1) -> "1 Minuten" (Plural-1-Bug). Fix: ICU-Plural in den
// ARB-Katalogen (DE/EN) und im generierten Code; die Singular/Plural-Verzweigung
// lebt seit der Elf-Sprachen-Lokalisierung nicht mehr in app_localizations.dart.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usageMinutes pluralisiert korrekt (1 = Singular)', () {
    final de = File('lib/l10n/app_de.arb').readAsStringSync();
    final en = File('lib/l10n/app_en.arb').readAsStringSync();
    expect(de.contains('"usageMinutes": "{n, plural, one {{n} Minute} other {{n} Minuten}}"'), isTrue);
    expect(en.contains('"usageMinutes": "{n, plural, one {{n} minute} other {{n} minutes}}"'), isTrue);

    final deGen = File('lib/l10n/app_localizations_de.dart').readAsStringSync();
    final enGen = File('lib/l10n/app_localizations_en.dart').readAsStringSync();
    expect(deGen.contains("one: '\$n Minute'"), isTrue);
    expect(enGen.contains("one: '\$n minute'"), isTrue);
    expect(deGen.contains("String usageMinutes(int n) {\n    return '\$n Minuten';"), isFalse,
        reason: 'alte pluralfeste DE-Form entfernt');
  });
}
