/// Bibliotheks-Screen mit Filter, Tag-Filter und Suche.
library;

import 'package:flutter/material.dart';

import '../dialogs/media_item_dialog.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'item_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late Future<_LibData> _future;
  MediaCategory? _category;
  String? _tag;
  bool _favorites = false;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() {
    final next = _load();
    if (mounted) {
      setState(() {
        _future = next;
      });
    }
    return next.then((_) {}, onError: (_) {});
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _category = null;
      _favorites = false;
      _tag = null;
      _query = '';
    });
    _reload();
  }

  Future<_LibData> _load() async {
    final db = DatabaseService.instance;
    final items = await db.listItems(
      category: _category,
      tag: _tag,
      favoritesOnly: _favorites,
      query: _query,
      limit: 500,
    );
    final counts = await db.countByCategory();
    final tags = await db.listTags();
    return _LibData(items: items, counts: counts, tags: tags);
  }

  Future<void> _addManual() async {
    final item = await MediaItemDialog.show(context);
    if (item == null) return;
    try {
      await DatabaseService.instance.upsert(item);
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final hasActiveFilters = _category != null ||
        _favorites ||
        _tag != null ||
        _query.trim().isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManual,
        icon: const Icon(Icons.add),
        label: Text(loc.fabAdd),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.screenLibrary,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: loc.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: loc.clearSearch,
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                              _reload();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    setState(() => _query = v);
                    _reload();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Category Chips (>=48dp Touch-Target)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  label: loc.filterAll,
                  selected: !hasActiveFilters,
                  onSelected: _resetFilters,
                ),
                _chip(
                  label: loc.filterFavorites,
                  semanticLabel: loc.favoritesLabel,
                  selected: _favorites,
                  onSelected: () {
                    setState(() => _favorites = !_favorites);
                    _reload();
                  },
                ),
                ...MediaCategory.values.map((c) => _chip(
                      icon: c.icon,
                      label: c.localizedLabel(loc),
                      semanticLabel: c.localizedLabel(loc),
                      selected: _category == c,
                      onSelected: () {
                        setState(() => _category = _category == c ? null : c);
                        _reload();
                      },
                    )),
              ],
            ),
          ),
          // Tag Chips (if available, >=48dp Touch-Target)
          FutureBuilder<_LibData>(
            future: _future,
            builder: (context, snap) {
              final tags = snap.data?.tags ?? [];
              if (tags.isEmpty) return const SizedBox(height: 2);
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...tags.take(12).map((t) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                            avatar: const Icon(Icons.tag, size: 16),
                            label: Text(
                              loc.tagCount(t.name, t.count),
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: _tag == t.name,
                            onSelected: (sel) {
                              setState(() => _tag = sel ? t.name : null);
                              _reload();
                            },
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 8),
          Expanded(
            child: FutureBuilder<_LibData>(
              future: _future,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: cs.error),
                          const SizedBox(height: 12),
                          Text(
                            loc.error('${snap.error}'),
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
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snap.data!;
                if (data.items.isEmpty) {
                  return _EmptyState(
                    hasAnyData: data.totalCount > 0,
                    onResetFilters: hasActiveFilters ? _resetFilters : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    itemCount: data.items.length,
                    itemBuilder: (_, i) => _MediaRow(
                      item: data.items[i],
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ItemDetailScreen(id: data.items[i].id),
                          ),
                        );
                        if (mounted) await _reload();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    String? icon,
    required String label,
    String? semanticLabel,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: Text(icon)),
              const SizedBox(width: 4),
              Text(label),
            ],
          );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: semanticLabel == null
            ? child
            : Semantics(label: semanticLabel, child: child),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _LibData {
  _LibData({required this.items, required this.counts, required this.tags});
  final List<MediaItem> items;
  final Map<MediaCategory, int> counts;
  final List<MediaTag> tags;
  int get totalCount => counts.values.fold(0, (a, b) => a + b);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasAnyData,
    this.onResetFilters,
  });
  final bool hasAnyData;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ExcludeSemantics(
              child: Text('📚', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 16),
            Text(
              hasAnyData ? loc.emptyNoMatch : loc.emptyNoItems,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
            ),
            if (hasAnyData && onResetFilters != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: Text(loc.resetFilters),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.item, required this.onTap});
  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final catLabel = item.category.localizedLabel(loc);
    return ListTile(
      leading: ExcludeSemantics(
        child: CircleAvatar(
          backgroundColor: item.category.color.withValues(alpha: 0.18),
          foregroundColor: item.category.color,
          child: Text(item.category.icon),
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$catLabel${item.source.isEmpty ? '' : ' · ${item.source}'}',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          if (item.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.tags.take(3).map((t) => '#$t').join(' '),
                style: TextStyle(fontSize: 11, color: cs.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (item.foregroundMinutes > 0)
            Text(
              loc.foregroundMinutesLabel(item.foregroundMinutes),
              style: TextStyle(fontSize: 11, color: cs.primary),
            ),
        ],
      ),
      trailing: item.isFavorite
          ? Icon(
              Icons.star,
              color: Colors.amber.shade700,
              semanticLabel: loc.favoriteLabel,
            )
          : null,
      onTap: onTap,
    );
  }
}
