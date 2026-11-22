/// Detail-Screen für einen Bibliotheks-Eintrag mit Tag-Verwaltung und Playlist-Zuweisung.
library;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../dialogs/media_item_dialog.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.id});
  final String id;

  static final RegExp _androidPackagePattern =
      RegExp(r'^[a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)+$');

  static bool isAndroidPackageId(String providerId) =>
      _androidPackagePattern.hasMatch(providerId.trim());

  /// Berechnet eine sichere externe URL für Play Store, Provider-ID oder Direkt-URL.
  static String? guessExternalUrl(MediaItem i) {
    final pid = i.providerId.trim();
    if (pid.isEmpty) return null;
    if (pid.startsWith('https://') || pid.startsWith('http://')) {
      final parsed = Uri.tryParse(pid);
      if (parsed != null && parsed.hasAuthority) return parsed.toString();
      return null;
    }
    if (isAndroidPackageId(pid)) {
      return 'https://play.google.com/store/apps/details?id=${Uri.encodeComponent(pid)}';
    }
    final encoded = Uri.encodeComponent(pid);
    switch (i.source.toLowerCase()) {
      case 'youtube':
        return 'https://www.youtube.com/watch?v=$encoded';
      case 'spotify':
        return 'https://open.spotify.com/track/$encoded';
      case 'netflix':
        return 'https://www.netflix.com/title/$encoded';
      case 'twitch':
        return 'https://www.twitch.tv/$encoded';
      default:
        return null;
    }
  }

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  MediaItem? _item;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant ItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _reload();
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final i = await DatabaseService.instance.getItem(widget.id);
      if (!mounted) return;
      setState(() {
        _item = i;
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

  Future<void> _toggleFav() async {
    await DatabaseService.instance.toggleFavorite(widget.id);
    if (!mounted) return;
    await _reload();
  }

  Future<void> _editItem() async {
    final current = _item;
    if (current == null) return;
    final updated = await MediaItemDialog.show(context, initial: current);
    if (updated == null) return;
    await DatabaseService.instance.upsert(updated);
    if (!mounted) return;
    await _reload();
  }

  Future<void> _deleteItem() async {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteItemTitle),
        content: Text(loc.deleteItemContent),
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
    if (confirm != true) return;
    await DatabaseService.instance.delete(widget.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.itemDeleted)),
    );
    Navigator.of(context).pop();
  }

  Future<void> _addTagPrompt() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTagDialog(),
    );

    if (tag != null && tag.isNotEmpty) {
      await DatabaseService.instance.addTagToItem(widget.id, tag);
      if (!mounted) return;
      await _reload();
    }
  }

  Future<void> _removeTag(String tag) async {
    await DatabaseService.instance.removeTagFromItem(widget.id, tag);
    if (!mounted) return;
    await _reload();
  }

  Future<void> _addToPlaylistPrompt() async {
    final loc = AppLocalizations.of(context);
    final allPlaylists = await DatabaseService.instance.listPlaylists();
    final manualPlaylists = allPlaylists.where((p) => !p.isSmart).toList();

    if (!mounted) return;
    if (manualPlaylists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.noPlaylistsFound)),
      );
      return;
    }

    final selected = await showDialog<Playlist>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.addToPlaylist),
        content: SizedBox(
          width: 350,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: manualPlaylists.length,
            itemBuilder: (ctx, idx) {
              final pl = manualPlaylists[idx];
              return ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(pl.name),
                subtitle: Text(loc.playlistItemCount(pl.itemCount)),
                onTap: () => Navigator.of(ctx).pop(pl),
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
      await DatabaseService.instance.addItemToPlaylist(selected.id, widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.addedToPlaylist)),
      );
    }
  }

  Future<void> _openExternal() async {
    final i = _item;
    if (i == null) return;
    final url = ItemDetailScreen.guessExternalUrl(i);
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkError)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
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
        ),
      );
    }
    final i = _item;
    if (i == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(loc.itemNotFound, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                  child: Text(loc.back),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final catScheme = ColorScheme.fromSeed(
      seedColor: i.category.color,
      brightness: Theme.of(context).brightness,
    );
    final externalUrl = ItemDetailScreen.guessExternalUrl(i);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: catScheme.primaryContainer,
        foregroundColor: catScheme.onPrimaryContainer,
        title: Text(i.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: loc.addToPlaylist,
            onPressed: _addToPlaylistPrompt,
          ),
          Semantics(
            toggled: i.isFavorite,
            child: IconButton(
              icon: Icon(i.isFavorite ? Icons.star : Icons.star_border),
              tooltip: i.isFavorite ? loc.removeFavorite : loc.markAsFavorite,
              onPressed: _toggleFav,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: loc.moreActions,
            onSelected: (val) {
              if (val == 'edit') _editItem();
              if (val == 'delete') _deleteItem();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.editItem),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: cs.error),
                    const SizedBox(width: 8),
                    Text(loc.delete, style: TextStyle(color: cs.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: catScheme.primaryContainer.withValues(alpha: 0.45),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ExcludeSemantics(
                    child: Text(
                      i.category.icon,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i.category.localizedLabel(loc),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: catScheme.onPrimaryContainer,
                    ),
                  ),
                  if (i.source.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      i.source,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (i.description != null && i.description!.isNotEmpty)
            _section(context, loc.detailDescription, Text(i.description!)),
          _section(context, loc.detailDetails, _details(context, i, loc)),
          _section(
            context,
            loc.detailTags,
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...i.tags.map((t) => InputChip(
                      avatar: const Icon(Icons.tag, size: 16),
                      label: Text(t),
                      deleteButtonTooltipMessage: loc.removeTag,
                      onDeleted: () => _removeTag(t),
                    )),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(loc.addTag),
                  onPressed: _addTagPrompt,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addToPlaylistPrompt,
            icon: const Icon(Icons.playlist_add),
            label: Text(loc.addToPlaylist),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          if (externalUrl != null)
            FilledButton.icon(
              onPressed: _openExternal,
              icon: const Icon(Icons.open_in_new),
              label: Text(
                ItemDetailScreen.isAndroidPackageId(i.providerId)
                    ? loc.openPlayStore
                    : loc.openBrowser,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget body) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: body)),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, MediaItem i, AppLocalizations loc) {
    final cs = Theme.of(context).colorScheme;
    final rows = <Widget>[];
    void add(String k, String? v) {
      if (v == null || v.isEmpty) return;
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: TextStyle(color: cs.onSurfaceVariant)),
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
      add(
        loc.fieldLastOpened,
        i.lastOpenedAt!.toLocal().toIso8601String().substring(0, 16).replaceAll('T', ' '),
      );
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

class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog();

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations loc) {
    final clean = sanitizeTagName(_ctrl.text);
    if (clean.isEmpty) {
      setState(() => _error = loc.fieldRequired);
      return;
    }
    Navigator.of(context).pop(clean);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc.addTag),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          hintText: loc.tagExampleHint,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(loc),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => _submit(loc),
          child: Text(loc.save),
        ),
      ],
    );
  }
}
