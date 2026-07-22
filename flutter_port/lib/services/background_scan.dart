/// Periodischer Hintergrund-Scan via workmanager.
///
/// Android führt den Job in Intervallen von mindestens ~15 Minuten aus (Android-Limit),
/// im Hintergrund auch wenn die App geschlossen ist. Bei aktiver Doze-Mode
/// können die Intervalle länger sein.
///
/// Was der Job tut:
///   1. App-Aggregat-Scan (`MediaUsageService.scanAndPersist`)
///
/// Der Job überträgt keine Bibliotheksdaten. Server-Push und -Pull werden nur
/// nach einer ausdrücklichen Nutzeraktion in den Einstellungen ausgeführt.
///
/// Aktivierung über `BackgroundScan.enable()` (z.B. in Settings-Toggle).
/// Deaktivierung über `BackgroundScan.disable()`.
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:workmanager/workmanager.dart';

import 'database_service.dart';
import 'media_usage_service.dart';

const String _taskName = 'mediabrain-scan';
const String _settingEnabled = 'background_scan_enabled';
const String _settingLastRun = 'background_scan_last_run';
const String _settingLastResult = 'background_scan_last_result';

/// Top-Level-Callback — workmanager benötigt eine **statische** Funktion.
@pragma('vm:entry-point')
void mediabrainCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final (matched, items) =
          await MediaUsageService.instance.scanAndPersist(daysBack: 1);
      final result = 'apps=$matched app-items=$items';

      await DatabaseService.instance.setSetting(
        _settingLastRun,
        DateTime.now().toIso8601String(),
      );
      await DatabaseService.instance.setSetting(_settingLastResult, result);

      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('BackgroundScan failed: $e\n$st');
      }
      await DatabaseService.instance.setSetting(
        _settingLastResult,
        'error: $e',
      );
      return false;
    }
  });
}

class BackgroundScan {
  BackgroundScan._();
  static final BackgroundScan instance = BackgroundScan._();

  static const Duration interval = Duration(hours: 6);

  bool get available => Platform.isAndroid;

  /// Wird einmal in main() aufgerufen. Registriert den Callback,
  /// startet den Job aber NICHT automatisch — das macht der User per Toggle.
  Future<void> initialize() async {
    if (!available) return;
    await Workmanager().initialize(mediabrainCallbackDispatcher);
  }

  Future<bool> isEnabled() async {
    final v = await DatabaseService.instance.getSetting(_settingEnabled);
    return v == 'true';
  }

  Future<String?> lastRun() =>
      DatabaseService.instance.getSetting(_settingLastRun);
  Future<String?> lastResult() =>
      DatabaseService.instance.getSetting(_settingLastResult);

  Future<void> enable() async {
    if (!available) return;
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: interval,
      // Initial delay verhindert sofortigen Start nach Toggle
      initialDelay: const Duration(minutes: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
    await DatabaseService.instance.setSetting(_settingEnabled, 'true');
  }

  Future<void> disable() async {
    if (!available) return;
    await Workmanager().cancelByUniqueName(_taskName);
    await DatabaseService.instance.setSetting(_settingEnabled, 'false');
  }

  /// Einmaliger Sofort-Lauf (für „Jetzt scannen"-Button neben dem Toggle).
  Future<void> runOnce() async {
    if (!available) return;
    await Workmanager().registerOneOffTask(
      '$_taskName-once-${DateTime.now().millisecondsSinceEpoch}',
      _taskName,
      initialDelay: const Duration(seconds: 1),
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
  }
}
