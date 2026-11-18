/// SyncService — Datei- und Server-Sync der MediaBrain-Bibliothek.
///
/// Datei: Share-Sheet (Export) + File-Picker (Import).
/// Server: REST gegen `<base>/sync/mediabrain`, Bearer-Token.
library;

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import 'database_service.dart';

const String _exportSchema = 'mediabrain-library-v1';

enum SyncStatusCode { shareOpened, imported, pushed, serverEmpty }

enum SyncErrorCode {
  noUrl,
  httpsRequired,
  invalidUrl,
  invalidFileJson,
  invalidServerJson,
}

class SyncSummary {
  const SyncSummary({
    required this.items,
    this.playlistsImported = 0,
    this.statusCode,
    this.message,
  });

  final int items;
  final int playlistsImported;
  final SyncStatusCode? statusCode;
  final String? message;

  String localizedText(AppLocalizations loc) {
    switch (statusCode) {
      case SyncStatusCode.shareOpened:
        return loc.syncShareOpened;
      case SyncStatusCode.serverEmpty:
        return loc.syncServerEmpty;
      case SyncStatusCode.pushed:
        return '${loc.syncSummaryItems(items)} · ${loc.syncPushed}';
      case SyncStatusCode.imported:
        final base = loc.syncSummaryItems(items);
        if (playlistsImported > 0) {
          return '$base · ${loc.syncPlaylistsImported(playlistsImported)}';
        }
        return base;
      case null:
        final base = loc.syncSummaryItems(items);
        return message == null ? base : '$base · $message';
    }
  }

  @override
  String toString() =>
      '$items Einträge${message == null ? '' : ' · $message'}';
}

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const settingServerUrl = 'sync_server_url';
  static const settingServerToken = 'sync_server_token';
  static const settingLastPush = 'sync_last_push';
  static const settingLastPull = 'sync_last_pull';

  // ─── Datei-Export / -Import ─────────────────────────────────────

  Future<Map<String, dynamic>> _buildPayload() async {
    return DatabaseService.instance.buildExportPayload();
  }

  Future<File> _writeExport() async {
    final dir = await getTemporaryDirectory();
    final fileName =
        'mediabrain-library-${DateTime.now().toIso8601String().substring(0, 10)}.json';
    final file = File('${dir.path}/$fileName');
    final payload = await _buildPayload();
    await file.writeAsString(jsonEncode(payload));
    return file;
  }

  Future<SyncSummary> exportViaShare() async {
    final file = await _writeExport();
    final params = ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      text: 'MediaBrain-Bibliothek ($_exportSchema)',
      subject: 'MediaBrain-Export',
    );
    await SharePlus.instance.share(params);
    return const SyncSummary(
      items: 0,
      statusCode: SyncStatusCode.shareOpened,
      message: 'Share-Sheet geöffnet',
    );
  }

  Future<SyncSummary?> importViaFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return importFromPath(path);
  }

  Future<SyncSummary> importFromPath(String path) async {
    final text = await File(path).readAsString();
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        throw const FormatException('Expected JSON object');
      }
      json = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const SyncException(
        'Datei ist kein gueltiges JSON-Objekt.',
        code: SyncErrorCode.invalidFileJson,
      );
    }
    return _applyPayload(json);
  }

  Future<SyncSummary> _applyPayload(Map<String, dynamic> json) async {
    // Fehlerhafte Eintraege (fehlende/null id oder title) ueberspringen, statt
    // den gesamten Import an einem einzigen Datensatz abbrechen zu lassen:
    // mm['id'] is! String || mm['title'] is! String
    try {
      final res = await DatabaseService.instance.importLibraryBundle(json);
      String? msg;
      if (res.playlistsImported > 0) {
        msg = '${res.playlistsImported} Playlists';
      }
      return SyncSummary(
        items: res.imported,
        playlistsImported: res.playlistsImported,
        statusCode: SyncStatusCode.imported,
        message: msg,
      );
    } on ImportException catch (e) {
      throw SyncException(e.toString());
    }
  }

  // ─── Server-Sync ────────────────────────────────────────────────

  Future<({String? url, String? token})> getServerConfig() async {
    final url = await _setting(settingServerUrl);
    final token = await _setting(settingServerToken);
    return (url: url, token: token);
  }

  Future<void> setServerConfig({String? url, String? token}) async {
    if (url != null) await _setSetting(settingServerUrl, url.trim());
    if (token != null) await _setSetting(settingServerToken, token.trim());
  }

  Future<SyncSummary> push() async {
    final cfg = await getServerConfig();
    final url = validateServerUrl(cfg.url);
    if (url == null) {
      throw const SyncException(
        'Keine Server-URL hinterlegt. Trage sie in den Einstellungen ein.',
        code: SyncErrorCode.noUrl,
      );
    }
    final token = cfg.token ?? '';
    final payload = await _buildPayload();
    final response = await http.post(
      Uri.parse('$url/sync/mediabrain'),
      headers: {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode >= 400) {
      throw SyncException(
        'Server: ${response.statusCode} ${response.body}',
      );
    }
    await _setSetting(settingLastPush, DateTime.now().toIso8601String());
    final items = (payload['items'] as List).length;
    return SyncSummary(
      items: items,
      statusCode: SyncStatusCode.pushed,
      message: 'gepusht',
    );
  }

  Future<SyncSummary> pull() async {
    final cfg = await getServerConfig();
    final url = validateServerUrl(cfg.url);
    if (url == null) {
      throw const SyncException(
        'Keine Server-URL hinterlegt. Trage sie in den Einstellungen ein.',
        code: SyncErrorCode.noUrl,
      );
    }
    final token = cfg.token ?? '';
    final response = await http.get(
      Uri.parse('$url/sync/mediabrain'),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode == 404) {
      return const SyncSummary(
        items: 0,
        statusCode: SyncStatusCode.serverEmpty,
        message: 'Server hat noch keinen Stand',
      );
    }
    if (response.statusCode >= 400) {
      throw SyncException(
        'Server: ${response.statusCode} ${response.body}',
      );
    }
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Expected JSON object');
      }
      json = Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const SyncException(
        'Server-Antwort ist kein gueltiges JSON-Objekt.',
        code: SyncErrorCode.invalidServerJson,
      );
    }
    final summary = await _applyPayload(json);
    await _setSetting(settingLastPull, DateTime.now().toIso8601String());
    return summary;
  }

  // ─── Helpers ────────────────────────────────────────────────────

  static String? validateServerUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var url = raw.trim();
    if (url.contains(RegExp(r'\s'))) {
      throw const SyncException(
        'Ungültige HTTPS-Server-URL.',
        code: SyncErrorCode.invalidUrl,
      );
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.isEmpty) return null;
    if (url.contains('://')) {
      if (url.startsWith('http://')) {
        throw const SyncException(
          'Server-Sync erfordert HTTPS; HTTP würde Token und Bibliothek offen übertragen.',
          code: SyncErrorCode.httpsRequired,
        );
      }
      if (!url.startsWith('https://')) {
        throw const SyncException(
          'Ungültige HTTPS-Server-URL.',
          code: SyncErrorCode.invalidUrl,
        );
      }
    } else {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.isEmpty ||
        uri.scheme != 'https' ||
        uri.host.contains(RegExp(r'[^a-zA-Z0-9.\-:\[\]]'))) {
      throw const SyncException(
        'Ungültige HTTPS-Server-URL.',
        code: SyncErrorCode.invalidUrl,
      );
    }
    return url;
  }

  Future<String?> _setting(String key) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _setSetting(String key, String value) async {
    final db = await DatabaseService.instance.database;
    await db.insert(
      'settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class SyncException implements Exception {
  const SyncException(this.message, {this.code});
  final String message;
  final SyncErrorCode? code;

  String localizedMessage(AppLocalizations loc) {
    switch (code) {
      case SyncErrorCode.noUrl:
        return loc.syncErrorNoUrl;
      case SyncErrorCode.httpsRequired:
        return loc.syncErrorHttpsRequired;
      case SyncErrorCode.invalidUrl:
        return loc.syncErrorInvalidUrl;
      case SyncErrorCode.invalidFileJson:
        return loc.syncErrorInvalidJson;
      case SyncErrorCode.invalidServerJson:
        return loc.syncErrorInvalidServerJson;
      case null:
        return message;
    }
  }

  @override
  String toString() => message;
}
