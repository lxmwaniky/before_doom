import 'package:flutter/material.dart';

import '../../domain/repositories/movie_repository.dart';

class ProgressHeader extends StatelessWidget {
  final WatchProgress progress;
  final int streak;
  final String scheduleStatus;

  const ProgressHeader({
    super.key,
    required this.progress,
    this.streak = 0,
    this.scheduleStatus = 'on_track',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = _getProgressColor(theme);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: progressColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.hoursRemaining.toStringAsFixed(0)}h remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak day${streak > 1 ? 's' : ''}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.progressPercentage / 100,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.watchedItems} of ${progress.totalItems} watched',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${progress.progressPercentage.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(ThemeData theme) {
    return switch (scheduleStatus) {
      'behind' => theme.colorScheme.error,
      'ahead' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.primary,
    };
  }

  IconData _getStatusIcon() {
    return switch (scheduleStatus) {
      'behind' => Icons.warning_amber_rounded,
      'ahead' => Icons.rocket_launch,
      _ => Icons.check_circle_outline,
    };
  }

  String _getStatusText() {
    return switch (scheduleStatus) {
      'behind' => 'Behind Schedule',
      'ahead' => 'Ahead of Schedule',
      _ => 'On Track',
    };
  }
}
