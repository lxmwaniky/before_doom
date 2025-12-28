import 'package:flutter/material.dart';

class EpisodeTrackerCard extends StatelessWidget {
  final int episodesWatched;
  final int totalEpisodes;
  final ValueChanged<int> onEpisodesChanged;

  const EpisodeTrackerCard({
    super.key,
    required this.episodesWatched,
    required this.totalEpisodes,
    required this.onEpisodesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              '$episodesWatched / $totalEpisodes',
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
            value: totalEpisodes > 0 ? episodesWatched / totalEpisodes : 0,
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
              onPressed: episodesWatched > 0
                  ? () => onEpisodesChanged(episodesWatched - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: FilledButton.tonal(
                onPressed: () {
                  final newValue = episodesWatched < totalEpisodes
                      ? episodesWatched + 1
                      : 0;
                  onEpisodesChanged(newValue);
                },
                child: const Text('+1 Episode'),
              ),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: episodesWatched < totalEpisodes
                  ? () => onEpisodesChanged(episodesWatched + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
