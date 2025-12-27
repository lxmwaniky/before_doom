import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/completion_share_dialog.dart';
import '../../domain/entities/movie.dart';

class ItemDetailPage extends StatefulWidget {
  final WatchlistItem item;
  final VoidCallback onToggle;
  final ValueChanged<int>? onEpisodesChanged;
  final List<WatchlistItem> allItems;

  const ItemDetailPage({
    super.key,
    required this.item,
    required this.onToggle,
    this.onEpisodesChanged,
    this.allItems = const [],
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late int _episodesWatched;
  late bool _isWatched;

  @override
  void initState() {
    super.initState();
    _episodesWatched = widget.item.episodesWatched;
    _isWatched = widget.item.isWatched;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.fullPosterUrlHD.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.fullPosterUrlHD,
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black45,
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainer,
                      child: Icon(
                        item.isTvShow ? Icons.tv : Icons.movie,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(theme, item),
                  const SizedBox(height: 20),
                  if (item.overview != null && item.overview!.isNotEmpty) ...[
                    Text(
                      'Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.overview!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (item.isTvShow && !item.comingSoon) ...[
                    _buildEpisodeTracker(theme, item),
                    const SizedBox(height: 24),
                  ],
                  if (!item.comingSoon) _buildWatchButton(theme),
                  if (item.comingSoon) _buildComingSoonMessage(theme),
                  const SizedBox(height: 24),
                  _buildRelatedItems(theme, item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(ThemeData theme, WatchlistItem item) {
    final runtimeText = item.isMovie
        ? '${item.runtime} min'
        : '${item.episodeCount} episodes';

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildChip(theme, item.isTvShow ? 'TV Series' : 'Movie'),
        _buildChip(theme, runtimeText),
        if (item.releaseDate.isNotEmpty)
          _buildChip(theme, item.releaseDate.substring(0, 4)),
      ],
    );
  }

  Widget _buildChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEpisodeTracker(ThemeData theme, WatchlistItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episode Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$_episodesWatched / ${item.episodeCount}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: item.episodeCount > 0
                ? _episodesWatched / item.episodeCount
                : 0,
            minHeight: 12,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: _episodesWatched > 0
                  ? () {
                      setState(() => _episodesWatched--);
                      widget.onEpisodesChanged?.call(_episodesWatched);
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _episodesWatched = _episodesWatched < item.episodeCount
                        ? _episodesWatched + 1
                        : 0;
                    _isWatched = _episodesWatched >= item.episodeCount;
                  });
                  widget.onEpisodesChanged?.call(_episodesWatched);
                },
                child: const Text('+1 Episode'),
              ),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: _episodesWatched < item.episodeCount
                  ? () {
                      setState(() => _episodesWatched++);
                      widget.onEpisodesChanged?.call(_episodesWatched);
                    }
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatchButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          final wasNotWatched = !_isWatched;
          setState(() => _isWatched = !_isWatched);
          widget.onToggle();
          if (wasNotWatched) {
            CompletionShareDialog.show(
              context,
              title: widget.item.title,
              isTvShow: widget.item.isTvShow,
              season: widget.item.season,
              posterPath: widget.item.posterPath,
            );
          }
        },
        icon: Icon(_isWatched ? Icons.check_circle : Icons.circle_outlined),
        label: Text(_isWatched ? 'Watched' : 'Mark as Watched'),
        style: FilledButton.styleFrom(
          backgroundColor: _isWatched
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainer,
          foregroundColor: _isWatched
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildComingSoonMessage(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: theme.colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Coming Soon - Not yet released',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedItems(ThemeData theme, WatchlistItem item) {
    final related = widget.allItems
        .where(
          (i) => i.watchPath == item.watchPath && i.uniqueKey != item.uniqueKey,
        )
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final relatedItem = related[index];
              return _buildRelatedCard(theme, relatedItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(ThemeData theme, WatchlistItem relatedItem) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ItemDetailPage(
              item: relatedItem,
              onToggle: () {},
              allItems: widget.allItems,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: relatedItem.fullPosterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: relatedItem.fullPosterUrl,
                      height: 140,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 140,
                      width: 100,
                      color: theme.colorScheme.surfaceContainer,
                      child: Icon(
                        relatedItem.isTvShow ? Icons.tv : Icons.movie,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              relatedItem.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
