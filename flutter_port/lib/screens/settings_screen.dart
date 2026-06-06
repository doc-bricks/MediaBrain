/// Einstellungen: Datei + Server-Sync, Datenstand, Alles löschen.
library;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<MediaCategory, int> _counts = {};
  String? _lastScan;
  String? _serverUrl;
  String? _lastPush;
  String? _lastPull;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final c = await DatabaseService.instance.countByCategory();
    final ls = await DatabaseService.instance.getSetting('last_scan');
    final cfg = await SyncService.instance.getServerConfig();
    final lp = await DatabaseService.instance.getSetting(SyncService.settingLastPush);
    final lpl = await DatabaseService.instance.getSetting(SyncService.settingLastPull);
    if (!mounted) return;
    setState(() {
      _counts = c;
      _lastScan = ls;
      _serverUrl = cfg.url;
      _lastPush = lp;
      _lastPull = lpl;
    });
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alle Bibliotheks-Daten löschen?'),
        content: const Text(
          'Entfernt alle Einträge aus dem lokalen MediaBrain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseService.instance.clearAll();
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bibliothek gelöscht.')),
    );
  }

  Future<void> _exportFile() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.exportViaShare();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export: ${r.message ?? ""}')),
      );
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFile() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.importViaFilePicker();
      if (!mounted) return;
      if (r == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abgebrochen.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import: $r')),
        );
        _reload();
      }
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editServerConfig() async {
    final cfg = await SyncService.instance.getServerConfig();
    if (!mounted) return;
    final url = TextEditingController(text: _serverUrl ?? '');
    final token = TextEditingController(text: cfg.token ?? '');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Server-Sync konfigurieren'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: url,
                decoration: const InputDecoration(
                  labelText: 'Server-URL',
                  hintText: 'z.B. macstudvonlukas:8082',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: token,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Bearer-Token',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Speichern'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await SyncService.instance.setServerConfig(
        url: url.text,
        token: token.text,
      );
      _reload();
    } finally {
      url.dispose();
      token.dispose();
    }
  }

  Future<void> _push() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.push();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Push: $r')));
      _reload();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pull() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.pull();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pull: $r')));
      _reload();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fehler: $msg'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _counts.values.fold<int>(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Einstellungen',
              style: Theme.of(context).textTheme.headlineMedium),
        ),

        _section('Datenstand'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Gesamt-Einträge'),
                trailing: Text('$total'),
              ),
              ...MediaCategory.values
                  .where((c) => (_counts[c] ?? 0) > 0)
                  .map((c) => ListTile(
                        leading:
                            Text(c.icon, style: const TextStyle(fontSize: 24)),
                        title: Text(c.label),
                        trailing: Text('${_counts[c]}'),
                        dense: true,
                      )),
              if (_lastScan != null)
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Letzter Scan'),
                  subtitle: Text(_short(_lastScan)),
                ),
            ],
          ),
        ),

        _section('Datei-Sync'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export per Share'),
                subtitle: const Text(
                  'JSON über Mail, OneDrive, Telegram an dich selbst …',
                ),
                onTap: _busy ? null : _exportFile,
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.download_for_offline),
                title: const Text('Import-Datei wählen'),
                subtitle: const Text('Überschreibt den lokalen Stand'),
                onTap: _busy ? null : _importFile,
              ),
            ],
          ),
        ),

        _section('Server-Sync (Mac Studio)'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(_serverUrl == null || _serverUrl!.isEmpty
                    ? 'Kein Server konfiguriert'
                    : _serverUrl!),
                subtitle: Text(
                  'Push: ${_short(_lastPush)} · Pull: ${_short(_lastPull)}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: _editServerConfig,
              ),
              const Divider(height: 0),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _busy ? null : _push,
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Push'),
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                    child: VerticalDivider(width: 0),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _busy ? null : _pull,
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Pull'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _section('Aktionen'),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Datenstand aktualisieren'),
                onTap: _reload,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Alle Bibliotheks-Daten löschen',
                    style: TextStyle(color: Colors.red)),
                onTap: _clearAll,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Card(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('MediaBrain Mobile'),
            subtitle: Text(
              'Standalone Flutter-App. Erkennt installierte Medien-Apps, '
              'führt manuelle Einträge und syncronisiert per Datei oder Server.',
            ),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.1,
            color: Colors.grey,
          ),
        ),
      );

  String _short(String? iso) {
    if (iso == null || iso.isEmpty) return 'nie';
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}
