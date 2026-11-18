/// Dialog zum manuellen Anlegen/Bearbeiten eines Bibliotheks-Eintrags.
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
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
  String? _titleError;

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

  void _save(AppLocalizations loc) {
    final trimmedTitle = _title.text.trim();
    if (trimmedTitle.isEmpty) {
      setState(() => _titleError = loc.fieldRequired);
      return;
    }
    final tags = _tags.text
        .split(',')
        .map(sanitizeTagName)
        .where((t) => t.isNotEmpty)
        .toList();
    final base = widget.initial;
    final newItem = MediaItem(
      id: base?.id ?? const Uuid().v4(),
      title: trimmedTitle,
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
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        widget.initial == null ? loc.dialogTitleNew : loc.dialogTitleEdit,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
              decoration: InputDecoration(
                labelText: loc.fieldTitle,
                errorText: _titleError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              loc.categoryLabel,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: MediaCategory.values
                  .map((c) => ChoiceChip(
                        label: Semantics(
                          label: c.localizedLabel(loc),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ExcludeSemantics(child: Text(c.icon)),
                              const SizedBox(width: 4),
                              Text(c.localizedLabel(loc)),
                            ],
                          ),
                        ),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _artist,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: loc.fieldArtistOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _album,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: loc.fieldAlbumOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _channel,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: loc.fieldChannelOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: loc.fieldDescriptionOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tags,
              decoration: InputDecoration(
                labelText: loc.fieldTags,
                hintText: loc.fieldTagsHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(loc.markAsFavorite),
              value: _favorite,
              onChanged: (v) => setState(() => _favorite = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => _save(loc),
          child: Text(loc.save),
        ),
      ],
    );
  }
}
