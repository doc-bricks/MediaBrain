// Regressionstests fuer den Mobile-Bugsweep 2026-06-22 (MediaBrain/flutter_port).
//
// Statische Quelltext-Assertions, da `flutter`/`dart` auf der Workstation nicht im
// PATH ist (kein Laufzeit-Harness). Laut /bugsweep-Skill sind statische Assertions
// in diesem Fall valide. Jeder Test ist "red on revert": gegen das PRE-Backup
// (lib_BUGSWEEP_PRE_20260622) wuerde er fehlschlagen.
import 'dart:io';
import 'package:test/test.dart';

void main() {
  final dbSrc = File('lib/services/database_service.dart').readAsStringSync();
  final modelsSrc = File('lib/models/models.dart').readAsStringSync();
  final syncSrc = File('lib/services/sync_service.dart').readAsStringSync();
  final settingsSrc = File('lib/screens/settings_screen.dart').readAsStringSync();

  test('B1: kein "NULLS LAST" mehr (SQLite-<3.30-Portabilitaet)', () {
    expect(dbSrc.contains('NULLS LAST'), isFalse,
        reason: 'NULLS LAST crasht alte Android-System-SQLite (<3.30)');
    expect(dbSrc.contains('(last_opened_at IS NULL)'), isTrue,
        reason: 'portable NULL-Sortierung muss vorhanden sein');
  });

  test('B2: foreground_minutes wird tolerant als num gecastet', () {
    expect(
        modelsSrc.contains("(m['foreground_minutes'] as num?)?.toInt()"), isTrue,
        reason: 'JSON-double (z.B. 5.0) darf keinen TypeError werfen');
    expect(modelsSrc.contains("(m['foreground_minutes'] as int?)"), isFalse,
        reason: 'harter int?-Cast wurde entfernt');
  });

  test('B3: _applyPayload ueberspringt Eintraege ohne valide id/title', () {
    expect(
        syncSrc.contains("mm['id'] is! String || mm['title'] is! String"),
        isTrue,
        reason: 'malformer Eintrag darf nicht den ganzen Import abbrechen');
  });

  test('B4: database-Getter cached kein rejected Future (Reset bei Fehler)', () {
    final idx = dbSrc.indexOf('get database');
    expect(idx, greaterThan(-1));
    final block = dbSrc.substring(idx, idx + 400);
    expect(block.contains('catch') && block.contains('_dbFuture = null'), isTrue,
        reason: 'bei Open-Fehler muss der Future-Cache zurueckgesetzt werden');
  });

  test('B5: jsonDecode ist in beiden Pfaden gegen _SyncException abgesichert', () {
    // pull() + importFromPath() — beide werfen jetzt _SyncException statt FormatException.
    final jsonGuards = 'gueltiges JSON-Objekt'.allMatches(syncSrc).length;
    expect(jsonGuards, greaterThanOrEqualTo(2),
        reason: 'jsonDecode in pull() und importFromPath() muss gefangen sein');
  });

  test('A1 (Konsistenz): mounted-Guard vor _reload() in _editServerConfig', () {
    final idx = settingsSrc.indexOf('await SyncService.instance.setServerConfig(');
    expect(idx, greaterThan(-1));
    final after = settingsSrc.substring(idx, idx + 200);
    expect(after.contains('if (!mounted) return;'), isTrue,
        reason: 'Defense-in-Depth-Konsistenz mit den uebrigen Methoden der Klasse');
  });
}
