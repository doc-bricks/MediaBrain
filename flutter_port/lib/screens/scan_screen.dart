/// Scan-Screen: erkennt installierte Medien-Apps mit Nutzungsdaten.
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context);
    try {
      if (!MediaUsageService.instance.available) {
        setState(() => _error = loc.scanAndroidOnly);
        return;
      }
      final hasPerm = await MediaUsageService.instance.probePermission();
      if (!mounted) return;
      if (!hasPerm) {
        setState(() => _error = loc.scanPermissionMissing);
      }
      final (matched, persisted) =
          await MediaUsageService.instance.scanAndPersist(daysBack: 30);
      if (!mounted) return;
      setState(() => _result = loc.scanResult(matched, persisted));
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
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
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.bgScanQueued)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.screenScan, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          loc.scanDescription,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: Text(loc.btnAppScan),
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
                title: Text(loc.bgScanTitle),
                subtitle: Text(
                  '${loc.bgScanSubtitle(BackgroundScan.interval.inHours)}\n'
                  '${loc.lastRun(_short(_bgLastRun, loc.neverText))}\n'
                  '${_bgLastResult ?? ""}',
                ),
                isThreeLine: true,
                value: _bgEnabled,
                onChanged: _busy ? null : _toggleBackground,
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.flash_on),
                title: Text(loc.bgScanNow),
                subtitle: Text(loc.bgScanNowSubtitle),
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.detectedTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  loc.detectedApps,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.appScanTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.appScanDescription,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _short(String? iso, String never) {
    if (iso == null || iso.isEmpty) return never;
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}
