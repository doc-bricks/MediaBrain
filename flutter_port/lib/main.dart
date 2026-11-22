/// MediaBrain — Mobile Standalone-App.
///
/// Sammelt Medien-Verlauf aus genutzten Apps (Musik/Video/Podcast/Dokumente)
/// und stellt eine Bibliothek mit Filter, Favoriten und Detail-Ansicht bereit.
library;

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/background_scan.dart';
import 'services/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // workmanager-Callback registrieren (idempotent, ohne Job zu starten).
  await BackgroundScan.instance.initialize();
  await LocaleController.instance.loadSavedLocale();
  runApp(const MediaBrainApp());
}

class MediaBrainApp extends StatelessWidget {
  const MediaBrainApp({super.key});

  static ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance,
      builder: (context, selectedLocale, _) {
        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          debugShowCheckedModeBanner: false,
          locale: selectedLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
