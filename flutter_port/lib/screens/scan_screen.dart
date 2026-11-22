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
    try {
      final enabled = await BackgroundScan.instance.isEnabled();
      final lr = await BackgroundScan.instance.lastRun();
      final res = await BackgroundScan.instance.lastResult();
      if (!mounted) return;
      setState(() {
        _bgEnabled = enabled;
        _bgLastRun = lr;
        _bgLastResult = res;
      });
    } catch (_) {
      // Ignorieren, falls DB/Plugin im aktuellen Kontext nicht aktiv ist.
    }
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
        return;
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
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error('$e'))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runBgNow() async {
    try {
      await BackgroundScan.instance.runOnce();
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.bgScanQueued)),
      );
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(loc.screenScan, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          loc.scanDescription,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.search),
          label: Text(loc.btnAppScan),
          style: FilledButton.styleFrom(
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
                  '${loc.lastRun(_short(_bgLastRun, loc.neverText))}'
                  '${_bgLastResult == null || _bgLastResult!.isEmpty ? '' : '\n$_bgLastResult'}',
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
          Semantics(
            liveRegion: true,
            child: Card(
              color: cs.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: cs.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_result != null)
          Semantics(
            liveRegion: true,
            child: Card(
              color: cs.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: cs.onSecondaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _result!,
                        style: TextStyle(color: cs.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Card(
          color: cs.primaryContainer.withValues(alpha: 0.45),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.detectedTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.detectedApps,
                  style: TextStyle(fontSize: 13, color: cs.onSurface),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.appScanTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.appScanDescription,
                  style: TextStyle(fontSize: 13, color: cs.onSurface),
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
