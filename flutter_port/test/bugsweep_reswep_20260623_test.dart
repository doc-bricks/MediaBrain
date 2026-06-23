// Regressionstest fuer den Mobile-Bugsweep RE-SWEEP 2026-06-23 (MediaBrain/flutter_port).
//
// Statische Quelltext-Assertion (flutter/dart nicht im PATH). Red-on-revert.
// Befund des Entscheider-Re-Sweeps: usageMinutes(1) -> "1 Minuten" (Plural-1-Bug,
// in der 06-22-Runde uebersehen). Fix: Singular/Plural-Verzweigung.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10nSrc = File('lib/l10n/app_localizations.dart').readAsStringSync();

  test('usageMinutes pluralisiert korrekt (1 = Singular)', () {
    expect(l10nSrc.contains("n == 1 ? 'Minute' : 'Minuten'"), isTrue);
    expect(l10nSrc.contains("n == 1 ? 'minute' : 'minutes'"), isTrue);
    expect(l10nSrc.contains("usageMinutes(int n) => '\$n Minuten'"), isFalse,
        reason: 'alte pluralfeste DE-Form entfernt');
  });
}
