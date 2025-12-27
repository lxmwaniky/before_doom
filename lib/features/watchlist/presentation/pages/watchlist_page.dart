import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/util/status_rank.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
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

class WatchlistView extends StatefulWidget {
  const WatchlistView({super.key});

  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCU Watchlist'),
        actions: [
          BlocBuilder<WatchlistBloc, WatchlistState>(            builder: (context, state) {
              if (state is WatchlistLoaded) {
                return _buildProfileButton(context, state.progress);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search movies & shows...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
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
              :final streak,
              :final items
            ) =>
              RefreshIndicator(
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(
                        const WatchlistLoadRequested(),
                      );
                },
                child: _searchQuery.isEmpty
                    ? _buildNormalList(context, progress, streak, items, itemsByMonth)
                    : _buildSearchResults(context, items),
              ),
          };
        },
      ),
    );
  }

  Widget _buildNormalList(
    BuildContext context,
    WatchProgress progress,
    int streak,
    List<WatchlistItem> items,
    Map<String, List<WatchlistItem>> itemsByMonth,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ProgressHeader(
              progress: progress,
              streak: streak,
              scheduleStatus: _calculateScheduleStatus(items),
            ),
          ),
        ),
        for (final entry in itemsByMonth.entries)
          ..._buildMonthSection(context, entry.key, entry.value, items),
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<WatchlistItem> items) {
    final theme = Theme.of(context);
    final query = _searchQuery.toLowerCase();
    final filtered = items
        .where((item) => item.title.toLowerCase().contains(query))
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$_searchQuery"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WatchlistCard(
            item: item,
            allItems: items,
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
    );
  }

  String _calculateScheduleStatus(List<WatchlistItem> items) {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    int shouldBeWatched = 0;
    int actuallyWatched = 0;

    for (final item in items) {
      if (item.targetMonth.compareTo(currentMonth) <= 0) {
        shouldBeWatched++;
        if (item.isWatched) actuallyWatched++;
      }
    }

    if (shouldBeWatched == 0) return 'on_track';

    final expectedProgress = shouldBeWatched;
    final actualProgress = actuallyWatched;

    if (actualProgress < expectedProgress * 0.8) return 'behind';
    if (actualProgress > expectedProgress) return 'ahead';
    return 'on_track';
  }

  List<Widget> _buildMonthSection(
    BuildContext context,
    String month,
    List<WatchlistItem> items,
    List<WatchlistItem> allItems,
  ) {
    final theme = Theme.of(context);
    final monthLabel = _formatMonth(month);

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            monthLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
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
                  allItems: allItems,
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
}
