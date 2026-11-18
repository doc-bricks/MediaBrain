/// Verwaltet die gewählte App-Sprache (Systemstandard, DE, EN, ES)
/// inklusive Persistierung in der SQLite-Settings-Tabelle.
library;

import 'package:flutter/material.dart';

import 'database_service.dart';

class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);

  static final LocaleController instance = LocaleController._();
  static const String settingKey = 'app_locale';
  static const List<String> supportedCodes = ['de', 'en', 'es'];

  /// Normalisiert einen Sprachcode; gibt `null` für Systemstandard zurück.
  static Locale? parseLocaleCode(String? code) {
    final clean = code?.trim().toLowerCase();
    if (clean == null || clean.isEmpty || clean == 'system') return null;
    if (!supportedCodes.contains(clean)) return null;
    return Locale(clean);
  }

  /// Lädt die gespeicherte Sprache aus SQLite (bei Fehler: Systemstandard).
  Future<void> loadSavedLocale() async {
    try {
      final saved = await DatabaseService.instance.getSetting(settingKey);
      value = parseLocaleCode(saved);
    } catch (_) {
      // Fallback auf Systemstandard, falls DB beim Start nicht verfügbar ist.
    }
  }

  /// Setzt und persistiert die gewünschte Sprache (`null` = Systemstandard).
  Future<void> setLocaleCode(String? code) async {
    final next = parseLocaleCode(code);
    value = next;
    await DatabaseService.instance.setSetting(settingKey, next?.languageCode ?? '');
  }
}
