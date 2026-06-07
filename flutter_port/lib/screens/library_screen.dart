/// Bibliotheks-Screen mit Filter und Suche.
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
  bool _favorites = false;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<_LibData> _load() async {
    final db = DatabaseService.instance;
    final items = await db.listItems(
      category: _category,
      favoritesOnly: _favorites,
      query: _query,
      limit: 500,
    );
    final counts = await db.countByCategory();
    return _LibData(items: items, counts: counts);
  }

  Future<void> _addManual() async {
    final item = await MediaItemDialog.show(context);
    if (item == null) return;
    await DatabaseService.instance.upsert(item);
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
              Text(loc.screenLibrary, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: loc.searchHint,
                  prefixIcon: const Icon(Icons.search),
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
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip(
                label: loc.filterAll,
                selected: _category == null && !_favorites,
                onSelected: () {
                  setState(() {
                    _category = null;
                    _favorites = false;
                  });
                  _reload();
                },
              ),
              _chip(
                label: loc.filterFavorites,
                selected: _favorites,
                onSelected: () {
                  setState(() => _favorites = !_favorites);
                  _reload();
                },
              ),
              ...MediaCategory.values.map((c) => _chip(
                    label: '${c.icon} ${c.label}',
                    selected: _category == c,
                    onSelected: () {
                      setState(() => _category = _category == c ? null : c);
                      _reload();
                    },
                  )),
            ],
          ),
        ),
        const Divider(height: 8),
        Expanded(
          child: FutureBuilder<_LibData>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text(loc.error('${snap.error}')));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snap.data!;
              if (data.items.isEmpty) {
                return _EmptyState(hasAnyData: data.totalCount > 0);
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.builder(
                  itemCount: data.items.length,
                  itemBuilder: (_, i) => _MediaRow(
                    item: data.items[i],
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(id: data.items[i].id),
                        ),
                      );
                      if (mounted) _reload();
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
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _LibData {
  _LibData({required this.items, required this.counts});
  final List<MediaItem> items;
  final Map<MediaCategory, int> counts;
  int get totalCount => counts.values.fold(0, (a, b) => a + b);
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasAnyData});
  final bool hasAnyData;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📚', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              hasAnyData ? loc.emptyNoMatch : loc.emptyNoItems,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.category.color.withValues(alpha: 0.18),
        foregroundColor: item.category.color,
        child: Text(item.category.icon),
      ),
      title: Text(item.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.category.label}${item.source.isEmpty ? '' : ' · ${item.source}'}',
            style: const TextStyle(fontSize: 12),
          ),
          if (item.foregroundMinutes > 0)
            Text(
              loc.foregroundMinutesLabel(item.foregroundMinutes),
              style: TextStyle(fontSize: 11, color: Colors.green.shade700),
            ),
        ],
      ),
      trailing: item.isFavorite ? const Text('⭐') : null,
      onTap: onTap,
    );
  }
}
