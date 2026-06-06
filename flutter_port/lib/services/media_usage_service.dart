/// MediaUsageService — scant installierte Apps + Foreground-Zeit und
/// ergänzt den lokalen Media-Bestand um erkannte Medien-Apps.
///
/// Spiegelt die Funktion der Desktop-Window-Title-Erkennung auf Mobile.
library;

import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/installed_apps.dart';

import '../models/models.dart';
import 'database_service.dart';
import 'media_app_catalog.dart';

class MediaUsageService {
  MediaUsageService._();
  static final MediaUsageService instance = MediaUsageService._();

  bool get available => Platform.isAndroid;

  Future<bool> probePermission() async {
    if (!available) return false;
    try {
      final until = DateTime.now();
      final since = until.subtract(const Duration(days: 1));
      final usage = await AppUsage().getAppUsage(since, until);
      return usage.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Scant und schreibt erkannte Medien-Apps in die DB.
  /// Returns: (gefunden_apps, neue_einträge_oder_aktualisiert).
  Future<(int, int)> scanAndPersist({int daysBack = 30}) async {
    if (!available) return (0, 0);
    final apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      withIcon: false,
    );
    final until = DateTime.now();
    final since = until.subtract(Duration(days: daysBack));

    Map<String, Duration> usageMinutes = {};
    Map<String, DateTime> lastEnd = {};
    try {
      final usageList = await AppUsage().getAppUsage(since, until);
      for (final u in usageList) {
        usageMinutes[u.packageName] = u.usage;
        lastEnd[u.packageName] = u.endDate;
      }
    } catch (_) {
      // Keine Permission — wir registrieren die Apps trotzdem ohne Usage.
    }

    final newItems = <MediaItem>[];
    int matched = 0;
    for (final app in apps) {
      final media = MediaAppCatalog.match(app.packageName);
      if (media == null) continue;
      matched++;
      final dur = usageMinutes[app.packageName];
      final last = lastEnd[app.packageName];
      newItems.add(MediaItem(
        id: 'app:${app.packageName}',
        title: media.name,
        category: media.category,
        source: media.source,
        providerId: app.packageName,
        lastOpenedAt: last,
        foregroundMinutes: dur?.inMinutes ?? 0,
        description:
            'Auto-erkannt aus installierter App: ${app.packageName}',
        tags: const ['auto-erkannt'],
      ));
    }
    if (newItems.isNotEmpty) {
      await DatabaseService.instance.upsertAll(newItems);
      await DatabaseService.instance.setSetting(
        'last_scan',
        DateTime.now().toIso8601String(),
      );
    }
    return (matched, newItems.length);
  }
}
