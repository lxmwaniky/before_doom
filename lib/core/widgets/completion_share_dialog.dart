import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_constants.dart';

class CompletionShareDialog extends StatelessWidget {
  final String title;
  final bool isTvShow;
  final int? season;
  final String? posterPath;

  const CompletionShareDialog({
    super.key,
    required this.title,
    this.isTvShow = false,
    this.season,
    this.posterPath,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    bool isTvShow = false,
    int? season,
    String? posterPath,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CompletionShareDialog(
        title: title,
        isTvShow: isTvShow,
        season: season,
        posterPath: posterPath,
      ),
    );
  }

  String get _displayTitle {
    if (isTvShow && season != null) {
      return '$title (Season $season)';
    }
    return title;
  }

  int get _hoursUntilDoomsday {
    final now = DateTime.now();
    final difference = AppConstants.doomsdayDate.difference(now);
    return difference.inHours;
  }

  String get _shareText {
    final hours = _hoursUntilDoomsday;
    final days = hours ~/ 24;

    if (days > 0) {
      return 'Just finished watching $_displayTitle! '
          '$hours hours ($days days) until Avengers: Doomsday. '
          'My MCU rewatch is on track! 🎬 #BeforeDoom #Doomsday';
    }
    return 'Just finished watching $_displayTitle! '
        '$hours hours until Avengers: Doomsday. '
        'Almost there! 🎬 #BeforeDoom #Doomsday';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = _hoursUntilDoomsday;
    final days = hours ~/ 24;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nice!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You finished $_displayTitle',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$hours hours',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' ($days days) to Doomsday',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your progress?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        FilledButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            await Share.share(_shareText);
          },
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
        ),
      ],
    );
  }
}
