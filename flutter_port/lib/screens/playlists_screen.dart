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
  PlaylistType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final list = await DatabaseService.instance.listPlaylists();
    if (!mounted) return;
    setState(() {
      _playlists = list;
      _loading = false;
    });
  }

  Future<void> _createPlaylist() async {
    final created = await PlaylistDialog.show(context);
    if (created != null) {
      await DatabaseService.instance.upsertPlaylist(created);
      _reload();
    }
  }

  Future<void> _editPlaylist(Playlist pl) async {
    final updated = await PlaylistDialog.show(context, initial: pl);
    if (updated != null) {
      await DatabaseService.instance.upsertPlaylist(updated);
      _reload();
    }
  }

  Future<void> _deletePlaylist(Playlist pl) async {
    final loc = AppLocalizations.of(context);
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deletePlaylist(pl.id);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
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
                  onSelected: (sel) =>
                      setState(() => _typeFilter = sel ? PlaylistType.manual : null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(loc.playlistTypeSmart),
                  selected: _typeFilter == PlaylistType.smart,
                  onSelected: (sel) =>
                      setState(() => _typeFilter = sel ? PlaylistType.smart : null),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : displayed.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                loc.emptyPlaylists,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: _createPlaylist,
                                icon: const Icon(Icons.add),
                                label: Text(loc.dialogNewPlaylist),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final pl = displayed[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: pl.isSmart
                                  ? Colors.deepPurple.withValues(alpha: 0.15)
                                  : Colors.blue.withValues(alpha: 0.15),
                              child: Icon(
                                pl.isSmart ? Icons.auto_awesome : Icons.queue_music,
                                color: pl.isSmart ? Colors.deepPurple : Colors.blue,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pl.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    loc.playlistItemCount(pl.itemCount),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              pl.description.isNotEmpty
                                  ? pl.description
                                  : (pl.isSmart ? loc.playlistTypeSmart : loc.playlistTypeManual),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: PopupMenuButton<String>(
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
                                      const Icon(Icons.delete, size: 18, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(loc.delete, style: const TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlaylistDetailScreen(playlist: pl),
                                ),
                              );
                              _reload();
                            },
                          );
                        },
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
