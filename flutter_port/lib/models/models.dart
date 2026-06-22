/// MediaBrain Standalone — Datenmodelle.
///
/// Spiegelt die Tabellen-Struktur aus dem Desktop (core.py) und ergänzt
/// um Mobile-spezifische Felder.
library;

import 'package:flutter/material.dart';

const librarySchemaName = 'mediabrain-library-v1';

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
        id: m['id'] as String,
        title: m['title'] as String,
        category: categoryFromString(m['category'] as String?),
        source: (m['source'] as String?) ?? '',
        providerId: (m['provider_id'] as String?) ?? '',
        artist: m['artist'] as String?,
        album: m['album'] as String?,
        channel: m['channel'] as String?,
        season: (m['season'] as num?)?.toInt(),
        episode: (m['episode'] as num?)?.toInt(),
        lengthSeconds: (m['length_seconds'] as num?)?.toInt(),
        lastOpenedAt: m['last_opened_at'] == null
            ? null
            : DateTime.tryParse(m['last_opened_at'] as String),
        foregroundMinutes: (m['foreground_minutes'] as num?)?.toInt() ?? 0,
        isFavorite: m['is_favorite'] == 1 || m['is_favorite'] == true,
        description: m['description'] as String?,
        thumbnailUrl: m['thumbnail_url'] as String?,
        localPath: m['local_path'] as String?,
        tags: (m['tags'] as String?)?.split('|').where((s) => s.isNotEmpty).toList() ??
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
        'tags': tags.join('|'),
      };

  MediaItem copyWith({
    bool? isFavorite,
    DateTime? lastOpenedAt,
    int? foregroundMinutes,
    String? description,
    String? thumbnailUrl,
    List<String>? tags,
  }) =>
      MediaItem(
        id: id,
        title: title,
        category: category,
        source: source,
        providerId: providerId,
        artist: artist,
        album: album,
        channel: channel,
        season: season,
        episode: episode,
        lengthSeconds: lengthSeconds,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
        foregroundMinutes: foregroundMinutes ?? this.foregroundMinutes,
        isFavorite: isFavorite ?? this.isFavorite,
        description: description ?? this.description,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        localPath: localPath,
        tags: tags ?? this.tags,
      );
}
