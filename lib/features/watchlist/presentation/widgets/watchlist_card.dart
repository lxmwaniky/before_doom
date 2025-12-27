import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/movie.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistItem item;
  final VoidCallback onToggle;
  final ValueChanged<int>? onEpisodesChanged;

  const WatchlistCard({
    super.key,
    required this.item,
    required this.onToggle,
    this.onEpisodesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.comingSoon ? null : onToggle,
        onLongPress: item.isTvShow && !item.comingSoon
            ? () => _showEpisodeDialog(context)
            : null,
        child: Stack(
          children: [
            Row(
              children: [
                _buildPoster(theme),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(theme),
                        const SizedBox(height: 4),
                        _buildSubtitle(theme),
                        const SizedBox(height: 4),
                        _buildProgress(theme),
                      ],
                    ),
                  ),
                ),
                if (!item.comingSoon) ...[
                  Checkbox(
                    value: item.isWatched,
                    onChanged: (_) => onToggle(),
                    activeColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            if (item.comingSoon) _buildComingSoonBadge(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(ThemeData theme) {
    return SizedBox(
      width: 80,
      height: 120,
      child: item.fullPosterUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: item.fullPosterUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: theme.colorScheme.surfaceContainer,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholder(theme),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Icon(
        item.isTvShow ? Icons.tv : Icons.movie,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      item.displayTitle,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        decoration: item.isWatched ? TextDecoration.lineThrough : null,
        color: item.comingSoon
            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
            : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    final typeLabel = item.isTvShow ? 'TV Series' : 'Movie';
    final pathLabel = item.watchPath[0].toUpperCase() + item.watchPath.substring(1);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            typeLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          pathLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(ThemeData theme) {
    if (item.isMovie) {
      return Text(
        '${item.runtime} min',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.episodesWatched}/${item.episodeCount} episodes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: item.progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              item.isWatched
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonBadge(ThemeData theme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Coming Soon',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showEpisodeDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        int currentEpisodes = item.episodesWatched;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item.displayTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Episodes Watched',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentEpisodes > 0
                            ? () => setState(() => currentEpisodes--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$currentEpisodes / ${item.episodeCount}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: currentEpisodes < item.episodeCount
                            ? () => setState(() => currentEpisodes++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    onEpisodesChanged?.call(currentEpisodes);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
