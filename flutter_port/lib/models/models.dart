/// MediaBrain Standalone — Datenmodelle.
///
/// Spiegelt die Tabellen-Struktur aus dem Desktop (core.py) und ergänzt
/// um Mobile-spezifische Felder.
library;

import 'dart:convert';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

const librarySchemaName = 'mediabrain-library-v1';

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

String? _asNullableString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

/// Bereinigt ein einzelnes Tag (entfernt Pipe-Delimiter und Trim).
String sanitizeTagName(String raw) => raw.replaceAll('|', ' ').trim();

class ImportException implements Exception {
  final String message;
  const ImportException(this.message);
  @override
  String toString() => 'ImportException: $message';
}

enum MediaCategory { movie, series, music, clip, podcast, audiobook, document, app }

MediaCategory categoryFromString(String? s) {
  switch (s) {
    case 'series':
      return MediaCategory.series;
    case 'music':
      return MediaCategory.music;
    case 'clip':
      return MediaCategory.clip;
    case 'podcast':
      return MediaCategory.podcast;
    case 'audiobook':
      return MediaCategory.audiobook;
    case 'document':
      return MediaCategory.document;
    case 'app':
      return MediaCategory.app;
    default:
      return MediaCategory.movie;
  }
}

String categoryToString(MediaCategory c) => c.name;

extension CategoryUi on MediaCategory {
  String localizedLabel(AppLocalizations loc) {
    switch (this) {
      case MediaCategory.movie:
        return loc.categoryMovie;
      case MediaCategory.series:
        return loc.categorySeries;
      case MediaCategory.music:
        return loc.categoryMusic;
      case MediaCategory.clip:
        return loc.categoryClip;
      case MediaCategory.podcast:
        return loc.categoryPodcast;
      case MediaCategory.audiobook:
        return loc.categoryAudiobook;
      case MediaCategory.document:
        return loc.categoryDocument;
      case MediaCategory.app:
        return loc.categoryApp;
    }
  }

  String get label {
    switch (this) {
      case MediaCategory.movie:
        return 'Film';
      case MediaCategory.series:
        return 'Serie';
      case MediaCategory.music:
        return 'Musik';
      case MediaCategory.clip:
        return 'Clip';
      case MediaCategory.podcast:
        return 'Podcast';
      case MediaCategory.audiobook:
        return 'Hörbuch';
      case MediaCategory.document:
        return 'Dokument';
      case MediaCategory.app:
        return 'App';
    }
  }

  String get icon {
    switch (this) {
      case MediaCategory.movie:
        return '🎬';
      case MediaCategory.series:
        return '📺';
      case MediaCategory.music:
        return '🎵';
      case MediaCategory.clip:
        return '🎞️';
      case MediaCategory.podcast:
        return '🎙️';
      case MediaCategory.audiobook:
        return '📖';
      case MediaCategory.document:
        return '📄';
      case MediaCategory.app:
        return '📱';
    }
  }

  Color get color {
    switch (this) {
      case MediaCategory.movie:
        return const Color(0xFFEF4444);
      case MediaCategory.series:
        return const Color(0xFFF59E0B);
      case MediaCategory.music:
        return const Color(0xFF10B981);
      case MediaCategory.clip:
        return const Color(0xFF8B5CF6);
      case MediaCategory.podcast:
        return const Color(0xFF14B8A6);
      case MediaCategory.audiobook:
        return const Color(0xFFEC4899);
      case MediaCategory.document:
        return const Color(0xFF6B7280);
      case MediaCategory.app:
        return const Color(0xFF3B82F6);
    }
  }
}

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.category,
    this.source = '',
    this.providerId = '',
    this.artist,
    this.album,
    this.channel,
    this.season,
    this.episode,
    this.lengthSeconds,
    this.lastOpenedAt,
    this.foregroundMinutes = 0,
    this.isFavorite = false,
    this.description,
    this.thumbnailUrl,
    this.localPath,
    this.tags = const [],
  });

  final String id;
  final String title;
  final MediaCategory category;
  final String source;       // "spotify", "netflix", "local" etc.
  final String providerId;   // provider-spezifische ID
  final String? artist;
  final String? album;
  final String? channel;
  final int? season;
  final int? episode;
  final int? lengthSeconds;
  final DateTime? lastOpenedAt;
  final int foregroundMinutes;
  final bool isFavorite;
  final String? description;
  final String? thumbnailUrl;
  final String? localPath;
  final List<String> tags;

  factory MediaItem.fromMap(Map<String, dynamic> m) => MediaItem(
        id: _asNullableString(m['id']) ?? '',
        title: _asNullableString(m['title']) ?? '',
        category: categoryFromString(_asNullableString(m['category'])),
        source: _asNullableString(m['source']) ?? '',
        providerId: _asNullableString(m['provider_id']) ?? '',
        artist: _asNullableString(m['artist']),
        album: _asNullableString(m['album']),
        channel: _asNullableString(m['channel']),
        season: _asInt(m['season']),
        episode: _asInt(m['episode']),
        lengthSeconds: _asInt(m['length_seconds']),
        lastOpenedAt: m['last_opened_at'] is String
            ? DateTime.tryParse(m['last_opened_at'] as String)
            : null,
        foregroundMinutes: m['foreground_minutes'] is String
            ? (int.tryParse((m['foreground_minutes'] as String).trim()) ?? 0)
            : (m['foreground_minutes'] as num?)?.toInt() ?? 0,
        isFavorite: m['is_favorite'] == 1 || m['is_favorite'] == true,
        description: _asNullableString(m['description']),
        thumbnailUrl: _asNullableString(m['thumbnail_url']),
        localPath: _asNullableString(m['local_path']),
        tags: (_asNullableString(m['tags']))
                ?.split('|')
                .map(sanitizeTagName)
                .where((s) => s.isNotEmpty)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': categoryToString(category),
        'source': source,
        'provider_id': providerId,
        'artist': artist,
        'album': album,
        'channel': channel,
        'season': season,
        'episode': episode,
        'length_seconds': lengthSeconds,
        'last_opened_at': lastOpenedAt?.toIso8601String(),
        'foreground_minutes': foregroundMinutes,
        'is_favorite': isFavorite ? 1 : 0,
        'description': description,
        'thumbnail_url': thumbnailUrl,
        'local_path': localPath,
        'tags': tags.map(sanitizeTagName).where((s) => s.isNotEmpty).join('|'),
      };

  MediaItem copyWith({
    String? title,
    MediaCategory? category,
    String? source,
    String? providerId,
    String? artist,
    String? album,
    String? channel,
    int? season,
    int? episode,
    int? lengthSeconds,
    bool? isFavorite,
    DateTime? lastOpenedAt,
    int? foregroundMinutes,
    String? description,
    String? thumbnailUrl,
    String? localPath,
    List<String>? tags,
  }) =>
      MediaItem(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        source: source ?? this.source,
        providerId: providerId ?? this.providerId,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        channel: channel ?? this.channel,
        season: season ?? this.season,
        episode: episode ?? this.episode,
        lengthSeconds: lengthSeconds ?? this.lengthSeconds,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
        foregroundMinutes: foregroundMinutes ?? this.foregroundMinutes,
        isFavorite: isFavorite ?? this.isFavorite,
        description: description ?? this.description,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        localPath: localPath ?? this.localPath,
        tags: tags ?? this.tags,
      );
}

/// Tag / Schlagwort mit Häufigkeitszähler.
class MediaTag {
  const MediaTag({required this.name, this.count = 0});
  final String name;
  final int count;

  factory MediaTag.fromMap(Map<String, dynamic> m) => MediaTag(
        name: _asNullableString(m['name']) ?? '',
        count: _asInt(m['count']) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'count': count,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTag && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Typ einer Playlist: manuell oder smart (dynamische Abfrage).
enum PlaylistType { manual, smart }

PlaylistType playlistTypeFromString(String? s) {
  switch (s) {
    case 'smart':
      return PlaylistType.smart;
    case 'manual':
    default:
      return PlaylistType.manual;
  }
}

String playlistTypeToString(PlaylistType t) => t.name;

/// Dynamische Filterkriterien für eine Smart-Playlist.
class SmartPlaylistQuery {
  const SmartPlaylistQuery({
    this.category,
    this.tag,
    this.favoritesOnly = false,
    this.minForegroundMinutes,
    this.searchQuery,
    this.source,
  });

  final MediaCategory? category;
  final String? tag;
  final bool favoritesOnly;
  final int? minForegroundMinutes;
  final String? searchQuery;
  final String? source;

  /// Prüft, ob ein MediaItem den Kriterien entspricht.
  bool matches(MediaItem item) {
    if (category != null && item.category != category) return false;
    if (favoritesOnly && !item.isFavorite) return false;
    if (tag != null &&
        tag!.trim().isNotEmpty &&
        !item.tags.map((t) => t.toLowerCase()).contains(tag!.trim().toLowerCase())) {
      return false;
    }
    if (minForegroundMinutes != null && item.foregroundMinutes < minForegroundMinutes!) {
      return false;
    }
    if (source != null &&
        source!.trim().isNotEmpty &&
        item.source.toLowerCase() != source!.trim().toLowerCase()) {
      return false;
    }
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      final q = searchQuery!.trim().toLowerCase();
      final inTitle = item.title.toLowerCase().contains(q);
      final inArtist = (item.artist ?? '').toLowerCase().contains(q);
      final inAlbum = (item.album ?? '').toLowerCase().contains(q);
      final inChannel = (item.channel ?? '').toLowerCase().contains(q);
      final inDescription = (item.description ?? '').toLowerCase().contains(q);
      final inTags = item.tags.any((t) => t.toLowerCase().contains(q));
      if (!inTitle && !inArtist && !inAlbum && !inChannel && !inDescription && !inTags) {
        return false;
      }
    }
    return true;
  }

  factory SmartPlaylistQuery.fromMap(Map<String, dynamic> m) => SmartPlaylistQuery(
        category: m['category'] == null
            ? null
            : categoryFromString(_asNullableString(m['category'])),
        tag: _asNullableString(m['tag']),
        favoritesOnly: m['favorites_only'] == 1 || m['favorites_only'] == true,
        minForegroundMinutes: _asInt(m['min_foreground_minutes']),
        searchQuery: _asNullableString(m['search_query']),
        source: _asNullableString(m['source']),
      );

  Map<String, dynamic> toMap() => {
        if (category != null) 'category': categoryToString(category!),
        if (tag != null && tag!.isNotEmpty) 'tag': tag,
        'favorites_only': favoritesOnly ? 1 : 0,
        if (minForegroundMinutes != null) 'min_foreground_minutes': minForegroundMinutes,
        if (searchQuery != null && searchQuery!.isNotEmpty) 'search_query': searchQuery,
        if (source != null && source!.isNotEmpty) 'source': source,
      };

  factory SmartPlaylistQuery.fromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return const SmartPlaylistQuery();
    }
    try {
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return SmartPlaylistQuery.fromMap(decoded);
    } catch (_) {
      return const SmartPlaylistQuery();
    }
  }

  String toJsonString() => json.encode(toMap());
}

/// Playlist-Modell (manuell zusammengestellt oder smart per Abfrage).
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.type = PlaylistType.manual,
    this.smartQuery,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final PlaylistType type;
  final SmartPlaylistQuery? smartQuery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  bool get isSmart => type == PlaylistType.smart;

  factory Playlist.fromMap(Map<String, dynamic> m, {int itemCount = 0}) {
    final rawSq = m['smart_query'];
    SmartPlaylistQuery? smartQuery;
    if (rawSq is Map<String, dynamic>) {
      smartQuery = SmartPlaylistQuery.fromMap(rawSq);
    } else if (rawSq is Map) {
      smartQuery = SmartPlaylistQuery.fromMap(Map<String, dynamic>.from(rawSq));
    } else if (rawSq is String && rawSq.trim().isNotEmpty) {
      smartQuery = SmartPlaylistQuery.fromJsonString(rawSq);
    }

    return Playlist(
      id: _asNullableString(m['id']) ?? '',
      name: _asNullableString(m['name']) ?? '',
      description: _asNullableString(m['description']) ?? '',
      type: playlistTypeFromString(_asNullableString(m['playlist_type'])),
      smartQuery: smartQuery,
      createdAt: m['created_at'] is String
          ? DateTime.tryParse(m['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: m['updated_at'] is String
          ? DateTime.tryParse(m['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      itemCount: _asInt(m['item_count']) ?? itemCount,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'playlist_type': playlistTypeToString(type),
        'smart_query': smartQuery?.toJsonString() ?? '',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Playlist copyWith({
    String? name,
    String? description,
    PlaylistType? type,
    SmartPlaylistQuery? smartQuery,
    DateTime? updatedAt,
    int? itemCount,
  }) =>
      Playlist(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        type: type ?? this.type,
        smartQuery: smartQuery ?? this.smartQuery,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        itemCount: itemCount ?? this.itemCount,
      );
}
