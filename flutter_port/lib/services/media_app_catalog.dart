/// Katalog bekannter Medien-Apps mit Package-Namen und Kategorisierung.
///
/// Wird vom MediaUsageService genutzt, um aus App-Nutzung Medien-Verlauf
/// zu generieren.
library;

import '../models/models.dart';

class MediaApp {
  const MediaApp({
    required this.packagePrefixes,
    required this.name,
    required this.category,
    this.source = '',
  });

  final List<String> packagePrefixes;
  final String name;
  final MediaCategory category;

  /// "Source"-Wert wie im Desktop-Schema (netflix, spotify, youtube …).
  final String source;

  bool matches(String pkg) {
    final lower = pkg.toLowerCase();
    return packagePrefixes.any((p) => lower.startsWith(p.toLowerCase()));
  }
}

class MediaAppCatalog {
  MediaAppCatalog._();

  static const List<MediaApp> known = [
    // ── Video / Filme / Serien ─────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.netflix'],
      name: 'Netflix',
      category: MediaCategory.movie,
      source: 'netflix',
    ),
    MediaApp(
      packagePrefixes: ['com.disney.disneyplus'],
      name: 'Disney+',
      category: MediaCategory.movie,
      source: 'disney',
    ),
    MediaApp(
      packagePrefixes: ['com.amazon.avod', 'com.amazon.amazonvideo'],
      name: 'Amazon Prime Video',
      category: MediaCategory.movie,
      source: 'prime',
    ),
    MediaApp(
      packagePrefixes: ['com.apple.atve', 'com.apple.tv'],
      name: 'Apple TV',
      category: MediaCategory.movie,
      source: 'appletv',
    ),
    MediaApp(
      packagePrefixes: ['com.bskyb.skygo', 'de.sky.bw'],
      name: 'WOW / Sky',
      category: MediaCategory.movie,
      source: 'sky',
    ),
    MediaApp(
      packagePrefixes: ['tv.twitch.android'],
      name: 'Twitch',
      category: MediaCategory.clip,
      source: 'twitch',
    ),
    MediaApp(
      packagePrefixes: ['com.crunchyroll'],
      name: 'Crunchyroll',
      category: MediaCategory.series,
      source: 'crunchyroll',
    ),
    MediaApp(
      packagePrefixes: ['com.dazn'],
      name: 'DAZN',
      category: MediaCategory.clip,
      source: 'dazn',
    ),
    MediaApp(
      packagePrefixes: ['com.cbs.app', 'com.paramount.paramountplus'],
      name: 'Paramount+',
      category: MediaCategory.movie,
      source: 'paramount',
    ),

    // ── YouTube ─────────────────────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.google.android.youtube'],
      name: 'YouTube',
      category: MediaCategory.clip,
      source: 'youtube',
    ),
    MediaApp(
      packagePrefixes: ['com.google.android.apps.youtube.kids'],
      name: 'YouTube Kids',
      category: MediaCategory.clip,
      source: 'youtube_kids',
    ),
    MediaApp(
      packagePrefixes: ['com.google.android.apps.youtube.creator'],
      name: 'YouTube Studio',
      category: MediaCategory.clip,
      source: 'youtube_creator',
    ),

    // ── Musik ───────────────────────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.spotify.music'],
      name: 'Spotify',
      category: MediaCategory.music,
      source: 'spotify',
    ),
    MediaApp(
      packagePrefixes: ['com.apple.android.music'],
      name: 'Apple Music',
      category: MediaCategory.music,
      source: 'apple_music',
    ),
    MediaApp(
      packagePrefixes: ['com.google.android.apps.youtube.music'],
      name: 'YouTube Music',
      category: MediaCategory.music,
      source: 'youtube_music',
    ),
    MediaApp(
      packagePrefixes: ['com.aspiro.tidal'],
      name: 'Tidal',
      category: MediaCategory.music,
      source: 'tidal',
    ),
    MediaApp(
      packagePrefixes: ['com.amazon.mp3'],
      name: 'Amazon Music',
      category: MediaCategory.music,
      source: 'amazon_music',
    ),
    MediaApp(
      packagePrefixes: ['com.soundcloud.android'],
      name: 'SoundCloud',
      category: MediaCategory.music,
      source: 'soundcloud',
    ),
    MediaApp(
      packagePrefixes: ['com.deezer'],
      name: 'Deezer',
      category: MediaCategory.music,
      source: 'deezer',
    ),

    // ── Podcasts ────────────────────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.google.android.apps.podcasts'],
      name: 'Google Podcasts',
      category: MediaCategory.podcast,
      source: 'google_podcasts',
    ),
    MediaApp(
      packagePrefixes: ['fm.castbox.audiobook.radio.podcast'],
      name: 'Castbox',
      category: MediaCategory.podcast,
      source: 'castbox',
    ),
    MediaApp(
      packagePrefixes: ['au.com.shiftyjelly.pocketcasts'],
      name: 'Pocket Casts',
      category: MediaCategory.podcast,
      source: 'pocketcasts',
    ),
    MediaApp(
      packagePrefixes: ['org.podcastindex.curio'],
      name: 'PodcastIndex',
      category: MediaCategory.podcast,
      source: 'podcastindex',
    ),

    // ── Hörbücher ───────────────────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.audible.application'],
      name: 'Audible',
      category: MediaCategory.audiobook,
      source: 'audible',
    ),
    MediaApp(
      packagePrefixes: ['com.amazon.kindle'],
      name: 'Kindle',
      category: MediaCategory.audiobook, // tatsächlich Books, aber für Mobile am ehesten passend
      source: 'kindle',
    ),
    MediaApp(
      packagePrefixes: ['com.bambuser.social.cliengo', 'com.libreread'],
      name: 'eBook-Reader',
      category: MediaCategory.audiobook,
      source: 'ebook',
    ),

    // ── Dokumente / PDF ────────────────────────────────────────
    MediaApp(
      packagePrefixes: ['com.adobe.reader'],
      name: 'Adobe Acrobat',
      category: MediaCategory.document,
      source: 'pdf',
    ),
    MediaApp(
      packagePrefixes: ['com.google.android.apps.docs.editors.docs'],
      name: 'Google Docs',
      category: MediaCategory.document,
      source: 'gdocs',
    ),
    MediaApp(
      packagePrefixes: ['com.microsoft.office.word'],
      name: 'Microsoft Word',
      category: MediaCategory.document,
      source: 'word',
    ),
    MediaApp(
      packagePrefixes: ['com.google.android.apps.docs'],
      name: 'Google Drive',
      category: MediaCategory.document,
      source: 'gdrive',
    ),
    MediaApp(
      packagePrefixes: ['notion.id'],
      name: 'Notion',
      category: MediaCategory.document,
      source: 'notion',
    ),
    MediaApp(
      packagePrefixes: ['com.obsidian.obsidian', 'md.obsidian'],
      name: 'Obsidian',
      category: MediaCategory.document,
      source: 'obsidian',
    ),
  ];

  static MediaApp? match(String pkg) {
    for (final a in known) {
      if (a.matches(pkg)) return a;
    }
    return null;
  }

  static List<MediaApp> byCategory(MediaCategory c) =>
      known.where((a) => a.category == c).toList();
}
