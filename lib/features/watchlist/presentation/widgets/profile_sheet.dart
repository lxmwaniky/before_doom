import 'package:flutter/material.dart';

import '../../../../core/util/status_rank.dart';
import '../../../../core/widgets/reminder_settings_sheet.dart';
import '../../../../core/widgets/share_progress_card.dart';
import '../../domain/repositories/movie_repository.dart';

class ProfileSheet extends StatelessWidget {
  final WatchProgress progress;
  final StatusRank rank;
  final String? nextMovie;

  const ProfileSheet({
    super.key,
    required this.progress,
    required this.rank,
    this.nextMovie,
  });

  static void show(
    BuildContext context, {
    required WatchProgress progress,
    required StatusRank rank,
    String? nextMovie,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ProfileSheet(progress: progress, rank: rank, nextMovie: nextMovie),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextRank = rank.nextRank;
    final progressToNext = rank.progressToNextRank(progress.progressPercentage);
    final daysUntilDoomsday = DateTime(
      2026,
      12,
      18,
    ).difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          const SizedBox(height: 24),
          _buildRankBadge(theme),
          const SizedBox(height: 16),
          _buildRankTitle(theme),
          const SizedBox(height: 4),
          _buildRankSubtitle(theme),
          const SizedBox(height: 24),
          _buildStats(theme),
          if (nextRank != null) ...[
            const SizedBox(height: 24),
            _buildProgressToNext(theme, nextRank, progressToNext),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(context, daysUntilDoomsday),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildRankBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(rank.icon, size: 48, color: theme.colorScheme.primary),
    );
  }

  Widget _buildRankTitle(ThemeData theme) {
    return Text(
      rank.title.toUpperCase(),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildRankSubtitle(ThemeData theme) {
    return Text(
      rank.subtitle,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildStats(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem(theme, '${progress.watchedItems}', 'Watched'),
        const SizedBox(width: 32),
        _buildStatItem(
          theme,
          '${progress.progressPercentage.toStringAsFixed(0)}%',
          'Complete',
        ),
        const SizedBox(width: 32),
        _buildStatItem(
          theme,
          '${progress.hoursRemaining.toStringAsFixed(0)}h',
          'Remaining',
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressToNext(
    ThemeData theme,
    StatusRank nextRank,
    double progressToNext,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Next: ${nextRank.title}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const Spacer(),
            Text(
              '${(progressToNext * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressToNext,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, int daysUntilDoomsday) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRemindersSheet(context);
            },
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('Reminders'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ProgressShareSheet.show(
                context,
                progress: progress,
                daysRemaining: daysUntilDoomsday,
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ),
      ],
    );
  }

  void _showRemindersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReminderSettingsSheet(nextMovieTitle: nextMovie),
    );
  }
}

class ProgressShareSheet extends StatelessWidget {
  final WatchProgress progress;
  final int daysRemaining;

  const ProgressShareSheet({
    super.key,
    required this.progress,
    required this.daysRemaining,
  });

  static void show(
    BuildContext context, {
    required WatchProgress progress,
    required int daysRemaining,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ProgressShareSheet(progress: progress, daysRemaining: daysRemaining),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ShareProgressCard(
            progress: progress,
            daysRemaining: daysRemaining,
            repaintKey: shareKey,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await ShareService.shareProgress(repaintKey: shareKey);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Progress'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
