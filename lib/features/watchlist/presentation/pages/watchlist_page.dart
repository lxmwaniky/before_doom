import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/movie.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/widgets.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WatchlistBloc>()..add(const WatchlistLoadRequested()),
      child: const WatchlistView(),
    );
  }
}

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCU Watchlist'),
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return switch (state) {
            WatchlistInitial() => const WatchlistSkeleton(),
            WatchlistLoading() => const WatchlistSkeleton(),
            WatchlistError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WatchlistBloc>().add(
                                const WatchlistLoadRequested(),
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            WatchlistLoaded(
              :final progress,
              :final itemsByMonth,
              :final activeFilter,
              :final streak
            ) =>
              RefreshIndicator(
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(
                        const WatchlistLoadRequested(),
                      );
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ProgressHeader(
                              progress: progress,
                              streak: streak,
                            ),
                            const SizedBox(height: 16),
                            FilterChips(
                              activeFilter: activeFilter,
                              onFilterChanged: (filter) {
                                context.read<WatchlistBloc>().add(
                                      WatchlistFilterChanged(filter),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final entry in itemsByMonth.entries)
                      ..._buildMonthSection(context, entry.key, entry.value),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  List<Widget> _buildMonthSection(
    BuildContext context,
    String month,
    List<WatchlistItem> items,
  ) {
    final theme = Theme.of(context);
    final monthLabel = _formatMonth(month);
    final status = _getMonthStatus(month);

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                monthLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(context, status),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: WatchlistCard(
                  item: item,
                  onToggle: () {
                    context.read<WatchlistBloc>().add(
                          WatchlistItemToggled(
                            key: item.uniqueKey,
                            isWatched: !item.isWatched,
                          ),
                        );
                  },
                  onEpisodesChanged: item.isTvShow
                      ? (episodes) {
                          context.read<WatchlistBloc>().add(
                                WatchlistEpisodesUpdated(
                                  key: item.uniqueKey,
                                  episodesWatched: episodes,
                                ),
                              );
                        }
                      : null,
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      ),
    ];
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length != 2) return month;

    final year = parts[0];
    final monthNum = int.tryParse(parts[1]) ?? 1;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[monthNum - 1]} $year';
  }

  String _getMonthStatus(String targetMonth) {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    if (targetMonth.compareTo(currentMonth) < 0) return 'past';
    if (targetMonth == currentMonth) return 'current';
    return 'future';
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);

    final (color, text) = switch (status) {
      'past' => (theme.colorScheme.error, 'Past Due'),
      'current' => (theme.colorScheme.primary, 'This Month'),
      _ => (theme.colorScheme.surfaceContainerHighest, 'Upcoming'),
    };

    if (status == 'future') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
