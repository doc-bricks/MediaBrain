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

import '../models/models.dart';
import 'database_service.dart';

const String _exportSchema = 'mediabrain-library-v1';

class SyncSummary {
  const SyncSummary({required this.items, this.message});
  final int items;
  final String? message;
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
    final items = await DatabaseService.instance.listItems(limit: 100000);
    return {
      'schema': _exportSchema,
      'schema_version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'source': {
        'app_name': 'MediaBrain Mobile',
        'platform': Platform.operatingSystem,
      },
      'item_count': items.length,
      'items': items.map((m) => m.toMap()).toList(),
    };
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
    return SyncSummary(items: 0, message: 'Share-Sheet geöffnet');
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
    final json = jsonDecode(text) as Map<String, dynamic>;
    return _applyPayload(json);
  }

  Future<SyncSummary> _applyPayload(Map<String, dynamic> json) async {
    final schema = json['schema'] as String?;
    if (schema != _exportSchema) {
      throw _SyncException(
        "Schema '$schema' wird nicht unterstützt — erwartet '$_exportSchema'.",
      );
    }
    final list = (json['items'] as List?) ?? const [];
    final db = await DatabaseService.instance.database;
    int count = 0;
    await db.transaction((txn) async {
      await txn.delete('media_items');
      for (final raw in list) {
        if (raw is! Map) continue;
        final m = MediaItem.fromMap(raw.cast<String, dynamic>());
        await txn.insert(
          'media_items',
          m.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
    });
    return SyncSummary(items: count);
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
    final url = _validatedUrl(cfg.url);
    if (url == null) {
      throw const _SyncException(
        'Kein Server-URL hinterlegt. Trage ihn in den Einstellungen ein.',
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
      throw _SyncException(
        'Server: ${response.statusCode} ${response.body}',
      );
    }
    await _setSetting(settingLastPush, DateTime.now().toIso8601String());
    final items = (payload['items'] as List).length;
    return SyncSummary(items: items, message: 'gepusht');
  }

  Future<SyncSummary> pull() async {
    final cfg = await getServerConfig();
    final url = _validatedUrl(cfg.url);
    if (url == null) {
      throw const _SyncException(
        'Kein Server-URL hinterlegt. Trage ihn in den Einstellungen ein.',
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
      return const SyncSummary(items: 0, message: 'Server hat noch keinen Stand');
    }
    if (response.statusCode >= 400) {
      throw _SyncException(
        'Server: ${response.statusCode} ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final summary = await _applyPayload(json);
    await _setSetting(settingLastPull, DateTime.now().toIso8601String());
    return summary;
  }

  // ─── Helpers ────────────────────────────────────────────────────

  static String? _validatedUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var url = raw.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
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

class _SyncException implements Exception {
  const _SyncException(this.message);
  final String message;
  @override
  String toString() => message;
}
