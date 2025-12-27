import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/util/status_rank.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/profile_sheet.dart';
import '../widgets/watchlist_grid_tile.dart';
import '../widgets/watchlist_search_results.dart';
import '../widgets/widgets.dart';
import 'item_detail_page.dart';

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
  bool _isGridView = false;

  static const _prefsBox = 'app_preferences';
  static const _gridViewKey = 'is_grid_view';

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    try {
      final box = await Hive.openBox<bool>(_prefsBox);
      final isGrid = box.get(_gridViewKey, defaultValue: false) ?? false;
      if (mounted) {
        setState(() => _isGridView = isGrid);
      }
    } catch (_) {}
  }

  Future<void> _toggleViewMode() async {
    final newValue = !_isGridView;
    setState(() => _isGridView = newValue);
    try {
      final box = await Hive.openBox<bool>(_prefsBox);
      await box.put(_gridViewKey, newValue);
    } catch (_) {}
  }

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
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
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
              :final items,
            ) =>
              RefreshIndicator(
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(
                    const WatchlistLoadRequested(),
                  );
                },
                child: _searchQuery.isEmpty
                    ? (_isGridView
                          ? _buildGridView(
                              context,
                              progress,
                              streak,
                              items,
                              itemsByMonth,
                            )
                          : _buildNormalList(
                              context,
                              progress,
                              streak,
                              items,
                              itemsByMonth,
                            ))
                    : WatchlistSearchResults(
                        items: items,
                        searchQuery: _searchQuery,
                      ),
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
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 500,
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
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildGridView(
    BuildContext context,
    WatchProgress progress,
    int streak,
    List<WatchlistItem> items,
    Map<String, List<WatchlistItem>> itemsByMonth,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 500,
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
          ..._buildGridMonthSection(context, entry.key, entry.value, items),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  List<Widget> _buildGridMonthSection(
    BuildContext context,
    String month,
    List<WatchlistItem> monthItems,
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
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.65,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = monthItems[index];
            return WatchlistGridTile(
              item: item,
              onTap: () => _navigateToDetail(context, item, allItems),
            );
          }, childCount: monthItems.length),
        ),
      ),
    ];
  }

  void _navigateToDetail(
    BuildContext context,
    WatchlistItem item,
    List<WatchlistItem> allItems,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WatchlistBloc>(),
          child: ItemDetailPage(
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
        ),
      ),
    );
  }

  String _calculateScheduleStatus(List<WatchlistItem> items) {
    final totalItems = items.length;
    final watchedItems = items.where((i) => i.isWatched).length;

    if (watchedItems == 0) return 'not_started';
    if (watchedItems == totalItems) return 'ahead';

    // Get current month in format "2025-12"
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Get items scheduled for current month and earlier
    final itemsDueByNow = items.where((item) {
      return item.targetMonth.compareTo(currentMonth) <= 0;
    }).toList();

    if (itemsDueByNow.isEmpty) return 'ahead';

    final itemsDueWatched = itemsDueByNow
        .where((item) => item.isWatched)
        .length;
    final itemsDueTotal = itemsDueByNow.length;

    // Calculate completion percentage for items due by now
    final completionRate = itemsDueWatched / itemsDueTotal;

    if (completionRate >= 1.0) return 'ahead';
    if (completionRate < 0.7) return 'behind';
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
          delegate: SliverChildBuilderDelegate((context, index) {
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
          }, childCount: items.length),
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
      'December',
    ];

    return '${months[monthNum - 1]} $year';
  }

  Widget _buildProfileButton(BuildContext context, WatchProgress progress) {
    final theme = Theme.of(context);
    final rank = StatusRank.fromProgress(progress.progressPercentage);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () {
          final state = context.read<WatchlistBloc>().state;
          String? nextMovie;
          if (state is WatchlistLoaded) {
            final unwatched = state.items
                .where((i) => !i.isWatched && !i.comingSoon)
                .toList();
            if (unwatched.isNotEmpty) {
              nextMovie = unwatched.first.title;
            }
          }
          ProfileSheet.show(
            context,
            progress: progress,
            rank: rank,
            nextMovie: nextMovie,
          );
        },
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(rank.icon, size: 20, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
