/// Einstellungen: Datei + Server-Sync, Datenstand, Alles löschen.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.deleteAllTitle),
        content: Text(loc.deleteAllContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.delete,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseService.instance.clearAll();
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).libraryCleared)),
    );
  }

  Future<void> _exportFile() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.exportViaShare();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).exportResult(r.message ?? ''))),
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
      final loc = AppLocalizations.of(context);
      if (r == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.cancelled)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.importResult('$r'))),
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
    final loc = AppLocalizations.of(context);
    final url = TextEditingController(text: _serverUrl ?? '');
    final token = TextEditingController(text: cfg.token ?? '');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.serverConfigTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: url,
                decoration: InputDecoration(
                  labelText: loc.fieldServerUrl,
                  hintText: loc.fieldServerUrlHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: token,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.fieldBearerToken,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(loc.save),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await SyncService.instance.setServerConfig(
        url: url.text,
        token: token.text,
      );
      if (!mounted) return;
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
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.actionPush}: $r')),
      );
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
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.actionPull}: $r')),
      );
      _reload();
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.error(msg)),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final total = _counts.values.fold<int>(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(loc.screenSettings,
              style: Theme.of(context).textTheme.headlineMedium),
        ),

        _section(loc.sectionDataStatus),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.library_books),
                title: Text(loc.settingsTotalEntries),
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
                  title: Text(loc.settingsLastScan),
                  subtitle: Text(_short(_lastScan, loc.neverText)),
                ),
            ],
          ),
        ),

        _section(loc.sectionFileSync),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(loc.exportTitle),
                subtitle: Text(loc.exportSubtitle),
                onTap: _busy ? null : _exportFile,
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.download_for_offline),
                title: Text(loc.importTitle),
                subtitle: Text(loc.importSubtitle),
                onTap: _busy ? null : _importFile,
              ),
            ],
          ),
        ),

        _section(loc.sectionServerSync),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(_serverUrl == null || _serverUrl!.isEmpty
                    ? loc.noServerConfigured
                    : _serverUrl!),
                subtitle: Text(
                  loc.pushPullStatus(
                    _short(_lastPush, loc.neverText),
                    _short(_lastPull, loc.neverText),
                  ),
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
                      label: Text(loc.actionPush),
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
                      label: Text(loc.actionPull),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _section(loc.sectionActions),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(loc.refreshData),
                onTap: _reload,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(loc.deleteAllData,
                    style: const TextStyle(color: Colors.red)),
                onTap: _clearAll,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(loc.aboutTitle),
            subtitle: Text(loc.aboutSubtitle),
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

  String _short(String? iso, String never) {
    if (iso == null || iso.isEmpty) return never;
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}
