import 'package:flutter/material.dart';

import '../../domain/repositories/movie_repository.dart';

class ProgressHeader extends StatelessWidget {
  final WatchProgress progress;
  final int streak;

  const ProgressHeader({
    super.key,
    required this.progress,
    this.streak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WATCH PROGRESS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  if (streak > 0) ...[
                    Icon(
                      Icons.local_fire_department,
                      size: 20,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    '${progress.watchedItems}/${progress.totalItems}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.progressPercentage / 100,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Watched',
                  value: '${progress.hoursWatched.toStringAsFixed(1)}h',
                  theme: theme,
                ),
                const SizedBox(width: 24),
                _StatItem(
                  label: 'Remaining',
                  value: '${progress.hoursRemaining.toStringAsFixed(1)}h',
                  theme: theme,
                  isPrimary: true,
                ),
                const SizedBox(width: 24),
                _StatItem(
                  label: 'Total',
                  value: '${progress.totalHours.toStringAsFixed(1)}h',
                  theme: theme,
                ),
                if (progress.totalEpisodes > 0) ...[
                  const SizedBox(width: 24),
                  _StatItem(
                    label: 'Episodes',
                    value: '${progress.watchedEpisodes}/${progress.totalEpisodes}',
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isPrimary;

  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isPrimary
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
