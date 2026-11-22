/// Playlists-Screen — Übersicht aller manuellen Sammlungen und Smart-Playlists.
library;

import 'package:flutter/material.dart';

import '../dialogs/playlist_dialog.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> _playlists = [];
  bool _loading = true;
  Object? _error;
  PlaylistType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await DatabaseService.instance.listPlaylists();
      if (!mounted) return;
      setState(() {
        _playlists = list;
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

  Future<void> _createPlaylist() async {
    final created = await PlaylistDialog.show(context);
    if (created == null) return;
    try {
      await DatabaseService.instance.upsertPlaylist(created);
      if (!mounted) return;
      await _reload();
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error('$e'))),
      );
    }
  }

  Future<void> _editPlaylist(Playlist pl) async {
    final updated = await PlaylistDialog.show(context, initial: pl);
    if (updated == null) return;
    try {
      await DatabaseService.instance.upsertPlaylist(updated);
      if (!mounted) return;
      await _reload();
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.error('$e'))),
      );
    }
  }

  Future<void> _deletePlaylist(Playlist pl) async {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deletePlaylistTitle),
        content: Text(loc.deletePlaylistContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService.instance.deletePlaylist(pl.id);
        if (!mounted) return;
        await _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.error('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final displayed = _typeFilter == null
        ? _playlists
        : _playlists.where((p) => p.type == _typeFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.screenPlaylists),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: loc.dialogNewPlaylist,
            onPressed: _createPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.refreshData,
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (horizontal scrollbar, >=48dp touch target)
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              children: [
                ChoiceChip(
                  label: Text(loc.filterAll),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.queue_music, size: 16),
                  label: Text(loc.playlistTypeManual),
                  selected: _typeFilter == PlaylistType.manual,
                  onSelected: (sel) => setState(
                      () => _typeFilter = sel ? PlaylistType.manual : null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(loc.playlistTypeSmart),
                  selected: _typeFilter == PlaylistType.smart,
                  onSelected: (sel) => setState(
                      () => _typeFilter = sel ? PlaylistType.smart : null),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: cs.error),
                              const SizedBox(height: 12),
                              Text(
                                loc.error('$_error'),
                                textAlign: TextAlign.center,
                              ),
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
                    : displayed.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.playlist_play,
                                    size: 64,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    loc.emptyPlaylists,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: _createPlaylist,
                                    icon: const Icon(Icons.add),
                                    label: Text(loc.dialogNewPlaylist),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(160, 48),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _reload,
                            child: ListView.separated(
                              itemCount: displayed.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final pl = displayed[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: pl.isSmart
                                        ? cs.tertiaryContainer
                                        : cs.primaryContainer,
                                    child: Icon(
                                      pl.isSmart
                                          ? Icons.auto_awesome
                                          : Icons.queue_music,
                                      color: pl.isSmart
                                          ? cs.onTertiaryContainer
                                          : cs.onPrimaryContainer,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pl.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          loc.playlistItemCount(pl.itemCount),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    pl.description.isNotEmpty
                                        ? pl.description
                                        : (pl.isSmart
                                            ? loc.playlistTypeSmart
                                            : loc.playlistTypeManual),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    tooltip: loc.moreActions,
                                    onSelected: (val) {
                                      if (val == 'edit') _editPlaylist(pl);
                                      if (val == 'delete') _deletePlaylist(pl);
                                    },
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit, size: 18),
                                            const SizedBox(width: 8),
                                            Text(loc.dialogEditPlaylist),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                size: 18, color: cs.error),
                                            const SizedBox(width: 8),
                                            Text(
                                              loc.delete,
                                              style: TextStyle(color: cs.error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlaylistDetailScreen(playlist: pl),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        tooltip: loc.dialogNewPlaylist,
        child: const Icon(Icons.add),
      ),
    );
  }
}
