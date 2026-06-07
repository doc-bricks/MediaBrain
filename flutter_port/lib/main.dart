/// MediaBrain — Mobile Standalone-App.
///
/// Sammelt Medien-Verlauf aus genutzten Apps (Musik/Video/Podcast/Dokumente)
/// und stellt eine Bibliothek mit Filter, Favoriten und Detail-Ansicht bereit.
library;

import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/background_scan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // workmanager-Callback registrieren (idempotent, ohne Job zu starten).
  await BackgroundScan.instance.initialize();
  runApp(const MediaBrainApp());
}

class MediaBrainApp extends StatelessWidget {
  const MediaBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
