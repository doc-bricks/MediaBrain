/// Scan-Screen: erkennt installierte Medien-Apps mit Nutzungsdaten.
library;

import 'package:flutter/material.dart';

import '../services/background_scan.dart';
import '../services/media_usage_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _busy = false;
  String? _result;
  String? _error;
  bool _bgEnabled = false;
  String? _bgLastRun;
  String? _bgLastResult;

  @override
  void initState() {
    super.initState();
    _reloadBgState();
  }

  Future<void> _reloadBgState() async {
    final enabled = await BackgroundScan.instance.isEnabled();
    final lr = await BackgroundScan.instance.lastRun();
    final res = await BackgroundScan.instance.lastResult();
    if (!mounted) return;
    setState(() {
      _bgEnabled = enabled;
      _bgLastRun = lr;
      _bgLastResult = res;
    });
  }

  Future<void> _scanApps() async {
    setState(() {
      _busy = true;
      _result = null;
      _error = null;
    });
    try {
      if (!MediaUsageService.instance.available) {
        setState(() {
          _error = 'Scan ist nur unter Android verfügbar.';
        });
        return;
      }
      final hasPerm = await MediaUsageService.instance.probePermission();
      if (!hasPerm) {
        setState(() {
          _error =
              'Nutzungsdatenzugriff fehlt. Bitte in den System-Einstellungen für MediaBrain aktivieren:\n\n'
              'Einstellungen → Apps → Spezieller App-Zugriff → Nutzungsdatenzugriff → MediaBrain.';
        });
      }
      final (matched, persisted) =
          await MediaUsageService.instance.scanAndPersist(daysBack: 30);
      setState(() {
        _result =
            'Apps-Scan: $matched Medien-Apps gefunden, $persisted Einträge übernommen.';
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleBackground(bool value) async {
    setState(() => _busy = true);
    try {
      if (value) {
        await BackgroundScan.instance.enable();
      } else {
        await BackgroundScan.instance.disable();
      }
      await _reloadBgState();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runBgNow() async {
    await BackgroundScan.instance.runOnce();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hintergrund-Scan in der Warteschlange — Resultat in ~1 min sichtbar')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Scan', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Sucht installierte Medien-Apps (Streaming, Musik, Podcasts, '
          'Dokumente) und schreibt sie als Einträge in deine Bibliothek. '
          'Mit aktiviertem Nutzungsdatenzugriff bekommst du zusätzlich die '
          'tatsächliche Nutzungszeit.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text('App-Scan (Aggregat-Nutzung)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: _busy ? null : _scanApps,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Hintergrund-Scan'),
                subtitle: Text(
                  'Alle ~${BackgroundScan.interval.inHours} h scannen, auch wenn die App geschlossen ist.\n'
                  'Letzter Lauf: ${_short(_bgLastRun)}\n'
                  '${_bgLastResult ?? ""}',
                ),
                isThreeLine: true,
                value: _bgEnabled,
                onChanged: _busy ? null : _toggleBackground,
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.flash_on),
                title: const Text('Jetzt einmal im Hintergrund laufen lassen'),
                subtitle: const Text(
                  'Sendet einen One-Off-Task an Android. Resultat erscheint nach 1–2 Minuten.',
                ),
                onTap: _busy ? null : _runBgNow,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_busy)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!,
                  style: TextStyle(color: Colors.amber.shade900)),
            ),
          )
        else if (_result != null)
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_result!,
                  style: TextStyle(color: Colors.green.shade900)),
            ),
          ),
        const SizedBox(height: 24),
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📡 Was wird erkannt?',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text(
                  'Netflix · Disney+ · Prime Video · Apple TV · YouTube · Twitch · '
                  'Spotify · Apple Music · YouTube Music · Tidal · Amazon Music · '
                  'Audible · Kindle · Pocket Casts · Google Podcasts · '
                  'Adobe Acrobat · Google Docs · Notion · Obsidian und weitere.',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  '🔍 App-Scan',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'App-Scan: ein Eintrag pro Medien-App mit Gesamt-Nutzung '
                  'der letzten Tage (über Android-Nutzungsdaten).',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _short(String? iso) {
    if (iso == null || iso.isEmpty) return 'nie';
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}
