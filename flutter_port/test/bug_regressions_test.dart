import 'dart:io';
import 'package:test/test.dart';

void main() {
  final src = File('lib/screens/item_detail_screen.dart').readAsStringSync();

  test('BUG-F1 regression: launchUrl() ist in try/catch eingeschlossen', () {
    final launchIdx = src.indexOf('await launchUrl(');
    expect(launchIdx, greaterThan(-1),
        reason: 'launchUrl()-Aufruf nicht gefunden');
    final before = src.substring(launchIdx > 300 ? launchIdx - 300 : 0, launchIdx);
    expect(before.contains('try {'), isTrue,
        reason:
            'launchUrl() muss von try/catch umschlossen sein — BUG-F1 (PlatformException)');
  });

  test('BUG-F1 regression: catch-Block nach launchUrl vorhanden', () {
    final launchIdx = src.indexOf('await launchUrl(');
    expect(launchIdx, greaterThan(-1));
    final after = src.substring(launchIdx, launchIdx + 200);
    expect(after.contains('} catch ('), isTrue,
        reason: 'catch-Block nach launchUrl() fehlt — BUG-F1');
  });
}
