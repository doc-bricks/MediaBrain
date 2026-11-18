/// Dialog zum Anlegen und Bearbeiten von Playlists (manuell und smart).
library;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';

class PlaylistDialog extends StatefulWidget {
  const PlaylistDialog({super.key, this.initial});
  final Playlist? initial;

  static Future<Playlist?> show(
    BuildContext context, {
    Playlist? initial,
  }) {
    return showDialog<Playlist>(
      context: context,
      builder: (_) => PlaylistDialog(initial: initial),
    );
  }

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _smartTag;
  late final TextEditingController _smartSearch;
  late final TextEditingController _smartMinMinutes;

  late PlaylistType _type;
  MediaCategory? _smartCategory;
  late bool _smartFavoritesOnly;
  String? _nameError;
  String? _minMinutesError;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _type = p?.type ?? PlaylistType.manual;

    final q = p?.smartQuery;
    _smartTag = TextEditingController(text: q?.tag ?? '');
    _smartSearch = TextEditingController(text: q?.searchQuery ?? '');
    _smartMinMinutes = TextEditingController(
      text: q?.minForegroundMinutes != null ? q!.minForegroundMinutes.toString() : '',
    );
    _smartCategory = q?.category;
    _smartFavoritesOnly = q?.favoritesOnly ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _smartTag.dispose();
    _smartSearch.dispose();
    _smartMinMinutes.dispose();
    super.dispose();
  }

  void _save(AppLocalizations loc) {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = loc.fieldRequired);
      return;
    }

    int? minMin;
    if (_type == PlaylistType.smart) {
      final rawMin = _smartMinMinutes.text.trim();
      if (rawMin.isNotEmpty) {
        final parsed = int.tryParse(rawMin);
        if (parsed == null || parsed < 0) {
          setState(() => _minMinutesError = loc.invalidNumber);
          return;
        }
        minMin = parsed;
      }
    }

    final now = DateTime.now();
    SmartPlaylistQuery? smartQuery;
    if (_type == PlaylistType.smart) {
      final tag = sanitizeTagName(_smartTag.text);
      final search = _smartSearch.text.trim();
      smartQuery = SmartPlaylistQuery(
        category: _smartCategory,
        tag: tag.isNotEmpty ? tag : null,
        favoritesOnly: _smartFavoritesOnly,
        minForegroundMinutes: minMin,
        searchQuery: search.isNotEmpty ? search : null,
      );
    }

    final p = Playlist(
      id: widget.initial?.id ?? const Uuid().v4(),
      name: name,
      description: _description.text.trim(),
      type: _type,
      smartQuery: smartQuery,
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
      itemCount: widget.initial?.itemCount ?? 0,
    );
    Navigator.of(context).pop(p);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isNew = widget.initial == null;

    return AlertDialog(
      title: Text(isNew ? loc.dialogNewPlaylist : loc.dialogEditPlaylist),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Typ-Auswahl
              Semantics(
                label: loc.fieldPlaylistType,
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<PlaylistType>(
                    segments: [
                      ButtonSegment(
                        value: PlaylistType.manual,
                        label: Text(
                          loc.playlistTypeManual,
                          overflow: TextOverflow.ellipsis,
                        ),
                        icon: const Icon(Icons.queue_music),
                      ),
                      ButtonSegment(
                        value: PlaylistType.smart,
                        label: Text(
                          loc.playlistTypeSmart,
                          overflow: TextOverflow.ellipsis,
                        ),
                        icon: const Icon(Icons.auto_awesome),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (set) =>
                        setState(() => _type = set.first),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                autofocus: true,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: loc.fieldPlaylistName,
                  errorText: _nameError,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: loc.fieldPlaylistDescription,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_type == PlaylistType.smart) ...[
                const SizedBox(height: 16),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    loc.smartFilterCriteria,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                // Kategorie-Chips
                Text(
                  loc.smartFilterCategory,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: Text(loc.filterAll),
                      selected: _smartCategory == null,
                      onSelected: (_) => setState(() => _smartCategory = null),
                    ),
                    ...MediaCategory.values.map((c) => ChoiceChip(
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
                          selected: _smartCategory == c,
                          onSelected: (sel) =>
                              setState(() => _smartCategory = sel ? c : null),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _smartTag,
                  decoration: InputDecoration(
                    labelText: loc.smartFilterTag,
                    hintText: loc.smartFilterTagHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _smartSearch,
                  decoration: InputDecoration(
                    labelText: loc.smartFilterSearch,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _smartMinMinutes,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (_minMinutesError != null) {
                      setState(() => _minMinutesError = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: loc.smartFilterMinMinutes,
                    errorText: _minMinutesError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.timer),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(loc.smartFilterFavoritesOnly),
                  value: _smartFavoritesOnly,
                  onChanged: (val) => setState(() => _smartFavoritesOnly = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
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
