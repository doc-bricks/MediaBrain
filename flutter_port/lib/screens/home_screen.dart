/// Tab-Hauptscreen.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'library_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final screens = [
      const LibraryScreen(),
      const ScanScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: screens[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.library_books), label: loc.navLibrary),
          NavigationDestination(icon: const Icon(Icons.search), label: loc.navScan),
          NavigationDestination(icon: const Icon(Icons.settings), label: loc.navMore),
        ],
      ),
    );
  }
}
