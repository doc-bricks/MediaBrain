/// Detail-Screen für einen Bibliotheks-Eintrag.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  MediaItem? _item;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final i = await DatabaseService.instance.getItem(widget.id);
    if (!mounted) return;
    setState(() => _item = i);
  }

  Future<void> _toggleFav() async {
    await DatabaseService.instance.toggleFavorite(widget.id);
    _reload();
  }

  Future<void> _openExternal() async {
    final i = _item;
    if (i == null) return;
    final url = _guessUrl(i);
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).linkError)),
      );
    }
  }

  String? _guessUrl(MediaItem i) {
    if (i.providerId.isEmpty) return null;
    if (i.providerId.contains('.')) {
      return 'https://play.google.com/store/apps/details?id=${i.providerId}';
    }
    switch (i.source) {
      case 'youtube':
        return 'https://www.youtube.com/watch?v=${i.providerId}';
      case 'spotify':
        return 'https://open.spotify.com/track/${i.providerId}';
      case 'netflix':
        return 'https://www.netflix.com/title/${i.providerId}';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final i = _item;
    if (i == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: i.category.color,
        foregroundColor: Colors.white,
        title: Text(i.title),
        actions: [
          IconButton(
            icon: Text(i.isFavorite ? '⭐' : '☆',
                style: const TextStyle(fontSize: 22)),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: i.category.color.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(i.category.icon, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text(
                    i.category.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: i.category.color,
                    ),
                  ),
                  if (i.source.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(i.source, style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ),
          if (i.description != null && i.description!.isNotEmpty)
            _section(loc.detailDescription, Text(i.description!)),
          _section(loc.detailDetails, _details(i, loc)),
          if (i.tags.isNotEmpty)
            _section(
              loc.detailTags,
              Wrap(
                spacing: 6,
                children: i.tags
                    .map((t) => Chip(
                          label: Text(t),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),
          if (_guessUrl(i) != null)
            ElevatedButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_new),
              label: Text(
                i.providerId.contains('.')
                    ? loc.openPlayStore
                    : loc.openBrowser,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 6),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: body)),
        ],
      ),
    );
  }

  Widget _details(MediaItem i, AppLocalizations loc) {
    final rows = <Widget>[];
    void add(String k, String? v) {
      if (v == null || v.isEmpty) return;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(child: Text(v)),
        ],
      ));
    }

    add(loc.fieldArtist, i.artist);
    add(loc.fieldAlbum, i.album);
    add(loc.fieldChannel, i.channel);
    if (i.season != null && i.episode != null) {
      add(loc.fieldSeasonEpisodeLabel, loc.seasonEpisode(i.season!, i.episode!));
    }
    if (i.lengthSeconds != null) {
      add(loc.fieldLength, _formatSec(i.lengthSeconds!));
    }
    if (i.lastOpenedAt != null) {
      add(loc.fieldLastOpened,
          '${i.lastOpenedAt!.toLocal().toIso8601String().substring(0, 16).replaceAll('T', ' ')} Uhr');
    }
    if (i.foregroundMinutes > 0) {
      add(loc.fieldUsage, loc.usageMinutes(i.foregroundMinutes));
    }
    if (i.providerId.isNotEmpty) add(loc.fieldProviderId, i.providerId);
    if (i.localPath != null) add(loc.fieldLocalPath, i.localPath!);
    if (rows.isEmpty) return const SizedBox.shrink();
    final spaced = rows.expand((w) => [w, const SizedBox(height: 6)]).toList()
      ..removeLast();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spaced,
    );
  }

  String _formatSec(int s) {
    final m = s ~/ 60;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    if (m > 0) return '${m}m';
    return '${s}s';
  }
}
