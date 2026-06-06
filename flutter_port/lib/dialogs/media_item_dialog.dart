/// Dialog zum manuellen Anlegen/Bearbeiten eines Bibliotheks-Eintrags.
library;

import 'package:flutter/material.dart';

import '../models/models.dart';

class MediaItemDialog extends StatefulWidget {
  const MediaItemDialog({super.key, this.initial});
  final MediaItem? initial;

  static Future<MediaItem?> show(
    BuildContext context, {
    MediaItem? initial,
  }) {
    return showDialog<MediaItem>(
      context: context,
      builder: (_) => MediaItemDialog(initial: initial),
    );
  }

  @override
  State<MediaItemDialog> createState() => _MediaItemDialogState();
}

class _MediaItemDialogState extends State<MediaItemDialog> {
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _album;
  late final TextEditingController _channel;
  late final TextEditingController _description;
  late final TextEditingController _tags;
  late MediaCategory _category;
  late bool _favorite;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _title = TextEditingController(text: i?.title ?? '');
    _artist = TextEditingController(text: i?.artist ?? '');
    _album = TextEditingController(text: i?.album ?? '');
    _channel = TextEditingController(text: i?.channel ?? '');
    _description = TextEditingController(text: i?.description ?? '');
    _tags = TextEditingController(text: (i?.tags ?? const []).join(', '));
    _category = i?.category ?? MediaCategory.movie;
    _favorite = i?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _album.dispose();
    _channel.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final base = widget.initial;
    final newItem = MediaItem(
      id: base?.id ??
          'manual:${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      category: _category,
      source: base?.source ?? 'manual',
      providerId: base?.providerId ?? '',
      artist: _artist.text.trim().isEmpty ? null : _artist.text.trim(),
      album: _album.text.trim().isEmpty ? null : _album.text.trim(),
      channel: _channel.text.trim().isEmpty ? null : _channel.text.trim(),
      season: base?.season,
      episode: base?.episode,
      lengthSeconds: base?.lengthSeconds,
      lastOpenedAt: base?.lastOpenedAt ?? DateTime.now(),
      foregroundMinutes: base?.foregroundMinutes ?? 0,
      isFavorite: _favorite,
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      thumbnailUrl: base?.thumbnailUrl,
      localPath: base?.localPath,
      tags: tags,
    );
    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'Neuer Eintrag' : 'Eintrag bearbeiten',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Titel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Kategorie', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: MediaCategory.values
                  .map((c) => ChoiceChip(
                        label: Text('${c.icon} ${c.label}'),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _artist,
              decoration: const InputDecoration(
                labelText: 'Künstler / Regie (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _album,
              decoration: const InputDecoration(
                labelText: 'Album / Serie (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _channel,
              decoration: const InputDecoration(
                labelText: 'Kanal / Quelle (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (Komma-getrennt)',
                hintText: 'z.B. Dokumentation, Wochenende',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Als Favorit markieren'),
              value: _favorite,
              onChanged: (v) => setState(() => _favorite = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
