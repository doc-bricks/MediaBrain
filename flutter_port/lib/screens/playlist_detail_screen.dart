/// Detailansicht einer Playlist (manuell oder smart).
library;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'item_detail_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});
  final Playlist playlist;

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Playlist _playlist;
  List<MediaItem> _items = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pl = await DatabaseService.instance.getPlaylist(_playlist.id);
      final items = await DatabaseService.instance.getPlaylistItems(_playlist.id);
      if (!mounted) return;
      setState(() {
        if (pl != null) _playlist = pl;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _removeItem(MediaItem item) async {
    try {
      await DatabaseService.instance.removeItemFromPlaylist(_playlist.id, item.id);
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.removedFromPlaylist)),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error('$e'))),
      );
    }
  }

  Future<void> _showAddItemDialog() async {
    final all = await DatabaseService.instance.listItems();
    final currentIds = _items.map((i) => i.id).toSet();
    final available = all.where((i) => !currentIds.contains(i.id)).toList();

    if (!mounted) return;
    final loc = AppLocalizations.of(context);

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.emptyNoItems)),
      );
      return;
    }

    final selected = await showDialog<MediaItem>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.addToPlaylist),
        content: SizedBox(
          width: 400,
          height: 350,
          child: ListView.builder(
            itemCount: available.length,
            itemBuilder: (ctx, idx) {
              final it = available[idx];
              return ListTile(
                leading: ExcludeSemantics(
                  child: Text(
                    it.category.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(it.artist ?? it.category.localizedLabel(loc)),
                onTap: () => Navigator.of(ctx).pop(it),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );

    if (selected != null) {
      await DatabaseService.instance.addItemToPlaylist(_playlist.id, selected.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.addedToPlaylist)),
      );
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist.name),
        actions: [
          if (!_playlist.isSmart)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: loc.addToPlaylist,
              onPressed: _showAddItemDialog,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.refreshData,
            onPressed: _reload,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: 12),
                        Text(loc.error('$_error'), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: Text(loc.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _playlist.isSmart
                                    ? Icons.auto_awesome
                                    : Icons.queue_music,
                                color: _playlist.isSmart
                                    ? cs.tertiary
                                    : cs.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _playlist.isSmart
                                      ? loc.playlistTypeSmart
                                      : loc.playlistTypeManual,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _playlist.isSmart
                                        ? cs.tertiary
                                        : cs.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                loc.playlistItemCount(_items.length),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                          if (_playlist.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              _playlist.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                          if (_playlist.isSmart &&
                              _playlist.smartQuery != null) ...[
                            const SizedBox(height: 10),
                            _buildSmartCriteriaChips(_playlist.smartQuery!, loc),
                          ],
                        ],
                      ),
                    ),
                    // Items List
                    Expanded(
                      child: _items.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  loc.emptyPlaylistItems,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _reload,
                              child: ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return ListTile(
                                    leading: ExcludeSemantics(
                                      child: CircleAvatar(
                                        backgroundColor: item.category.color
                                            .withValues(alpha: 0.15),
                                        child: Text(
                                          item.category.icon,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      [
                                        if (item.artist != null &&
                                            item.artist!.isNotEmpty)
                                          item.artist!,
                                        item.category.localizedLabel(loc),
                                        if (item.tags.isNotEmpty)
                                          item.tags
                                              .take(2)
                                              .map((t) => '#$t')
                                              .join(' '),
                                      ].join(' · '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: _playlist.isSmart
                                        ? const Icon(Icons.chevron_right)
                                        : IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: cs.error,
                                            ),
                                            tooltip: loc.removeFromPlaylist,
                                            onPressed: () => _removeItem(item),
                                          ),
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ItemDetailScreen(id: item.id),
                                        ),
                                      );
                                      if (!mounted) return;
                                      await _reload();
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSmartCriteriaChips(
      SmartPlaylistQuery q, AppLocalizations loc) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (q.category != null)
          Chip(
            avatar: ExcludeSemantics(child: Text(q.category!.icon)),
            label: Text(q.category!.localizedLabel(loc)),
            visualDensity: VisualDensity.compact,
          ),
        if (q.favoritesOnly)
          Chip(
            avatar: Icon(Icons.star, size: 16, color: Colors.amber.shade700),
            label: Text(loc.favoritesLabel),
            visualDensity: VisualDensity.compact,
          ),
        if (q.tag != null && q.tag!.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.tag, size: 16),
            label: Text(q.tag!),
            visualDensity: VisualDensity.compact,
          ),
        if (q.source != null && q.source!.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.source, size: 16),
            label: Text(q.source!),
            visualDensity: VisualDensity.compact,
          ),
        if (q.searchQuery != null && q.searchQuery!.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.search, size: 16),
            label: Text('"${q.searchQuery}"'),
            visualDensity: VisualDensity.compact,
          ),
        if (q.minForegroundMinutes != null)
          Chip(
            avatar: const Icon(Icons.timer, size: 16),
            label: Text(loc.minMinutesChip(q.minForegroundMinutes!)),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
