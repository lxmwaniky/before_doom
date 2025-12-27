import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/haptic_service.dart';
import '../../../../core/widgets/completion_share_dialog.dart';
import '../../domain/entities/movie.dart';
import '../pages/item_detail_page.dart';

class WatchlistCard extends StatelessWidget {
  final WatchlistItem item;
  final VoidCallback onToggle;
  final ValueChanged<int>? onEpisodesChanged;
  final List<WatchlistItem> allItems;

  const WatchlistCard({
    super.key,
    required this.item,
    required this.onToggle,
    this.onEpisodesChanged,
    this.allItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(context),
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
                        if (item.isTvShow && !item.comingSoon) ...[
                          const SizedBox(height: 8),
                          _buildEpisodeProgress(theme),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!item.comingSoon)
                  GestureDetector(
                    onTap: () {
                      final wasNotWatched = !item.isWatched;
                      if (wasNotWatched) {
                        HapticService.missionComplete();
                      } else {
                        HapticService.lightTap();
                      }
                      onToggle();
                      if (wasNotWatched) {
                        CompletionShareDialog.show(
                          context,
                          title: item.title,
                          isTvShow: item.isTvShow,
                          season: item.season,
                          posterPath: item.posterPath,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        item.isWatched
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: item.isWatched
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
            if (item.comingSoon) _buildComingSoonBadge(theme),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailPage(
          item: item,
          onToggle: onToggle,
          onEpisodesChanged: onEpisodesChanged,
          allItems: allItems,
        ),
      ),
    );
  }

  Widget _buildPoster(ThemeData theme) {
    return SizedBox(
      width: 70,
      height: 100,
      child: item.fullPosterUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: item.fullPosterUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: theme.colorScheme.surfaceContainer),
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
    final text = item.isMovie
        ? '${item.runtime} min'
        : '${item.episodeCount} episodes';

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildEpisodeProgress(ThemeData theme) {
    final progress = item.episodeCount > 0
        ? item.episodesWatched / item.episodeCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              item.isWatched
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${item.episodesWatched}/${item.episodeCount}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
}
