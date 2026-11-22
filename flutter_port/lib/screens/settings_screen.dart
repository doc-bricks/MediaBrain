/// Einstellungen: Sprache, Datei + Server-Sync, Datenstand, Alles löschen.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/locale_controller.dart';
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
    try {
      final c = await DatabaseService.instance.countByCategory();
      final ls = await DatabaseService.instance.getSetting('last_scan');
      final cfg = await SyncService.instance.getServerConfig();
      final lp =
          await DatabaseService.instance.getSetting(SyncService.settingLastPush);
      final lpl =
          await DatabaseService.instance.getSetting(SyncService.settingLastPull);
      if (!mounted) return;
      setState(() {
        _counts = c;
        _lastScan = ls;
        _serverUrl = cfg.url;
        _lastPush = lp;
        _lastPull = lpl;
      });
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _chooseLanguage() async {
    final loc = AppLocalizations.of(context);
    final currentCode = LocaleController.instance.value?.languageCode;
    final options = <(String?, String)>[
      (null, loc.languageSystem),
      ('de', loc.languageGerman),
      ('en', loc.languageEnglish),
      ('es', loc.languageSpanish),
    ];

    final picked = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(loc.languageTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final code = opt.$1;
              final label = opt.$2;
              final selected = currentCode == code;
              return Semantics(
                selected: selected,
                child: ListTile(
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  title: Text(label),
                  onTap: () => Navigator.of(ctx).pop(code ?? 'system'),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.cancel),
            ),
          ],
        );
      },
    );
    if (picked == null) return;
    try {
      await LocaleController.instance
          .setLocaleCode(picked == 'system' ? null : picked);
    } catch (e) {
      _showError(e);
    }
  }

  String _currentLanguageLabel(AppLocalizations loc, Locale? locale) {
    switch (locale?.languageCode) {
      case 'de':
        return loc.languageGerman;
      case 'en':
        return loc.languageEnglish;
      case 'es':
        return loc.languageSpanish;
      default:
        return loc.languageSystem;
    }
  }

  Future<void> _clearAll() async {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteAllTitle),
        content: Text(loc.deleteAllContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await DatabaseService.instance.clearAll();
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).libraryCleared)),
      );
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _exportFile() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.exportViaShare();
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.exportResult(r.localizedText(loc)))),
      );
    } catch (e) {
      _showError(e);
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
          SnackBar(content: Text(loc.importResult(r.localizedText(loc)))),
        );
        await _reload();
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editServerConfig() async {
    final cfg = await SyncService.instance.getServerConfig();
    if (!mounted) return;
    final res = await showDialog<({String url, String token})>(
      context: context,
      builder: (_) => _ServerConfigDialog(
        initialUrl: _serverUrl ?? '',
        initialToken: cfg.token ?? '',
      ),
    );
    if (res == null) return;
    try {
      await SyncService.instance.setServerConfig(
        url: res.url,
        token: res.token,
      );
      if (!mounted) return;
      await _reload();
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _push() async {
    setState(() => _busy = true);
    try {
      final r = await SyncService.instance.push();
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.actionPush}: ${r.localizedText(loc)}')),
      );
      await _reload();
    } catch (e) {
      _showError(e);
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
        SnackBar(content: Text('${loc.actionPull}: ${r.localizedText(loc)}')),
      );
      await _reload();
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final msg = error is SyncException
        ? error.localizedMessage(loc)
        : '$error';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.error(msg),
          style: TextStyle(color: cs.onError),
        ),
        backgroundColor: cs.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final total = _counts.values.fold<int>(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            loc.screenSettings,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),

        _section(context, loc.sectionAppearance),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ValueListenableBuilder<Locale?>(
            valueListenable: LocaleController.instance,
            builder: (context, selectedLocale, _) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(loc.languageTitle),
                subtitle: Text(_currentLanguageLabel(loc, selectedLocale)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _chooseLanguage,
              );
            },
          ),
        ),

        _section(context, loc.sectionDataStatus),
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
                        leading: ExcludeSemantics(
                          child: Text(
                            c.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(c.localizedLabel(loc)),
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

        _section(context, loc.sectionFileSync),
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

        _section(context, loc.sectionServerSync),
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
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
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
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _section(context, loc.sectionActions),
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
                leading: Icon(Icons.delete_forever, color: cs.error),
                title: Text(
                  loc.deleteAllData,
                  style: TextStyle(color: cs.error),
                ),
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

  Widget _section(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }

  String _short(String? iso, String never) {
    if (iso == null || iso.isEmpty) return never;
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}

class _ServerConfigDialog extends StatefulWidget {
  const _ServerConfigDialog({
    required this.initialUrl,
    required this.initialToken,
  });

  final String initialUrl;
  final String initialToken;

  @override
  State<_ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<_ServerConfigDialog> {
  late final TextEditingController _url;
  late final TextEditingController _token;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.initialUrl);
    _token = TextEditingController(text: widget.initialToken);
  }

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc.serverConfigTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: loc.fieldServerUrl,
              hintText: loc.fieldServerUrlHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _token,
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            (url: _url.text, token: _token.text),
          ),
          child: Text(loc.save),
        ),
      ],
    );
  }
}
