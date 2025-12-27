import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/util/status_rank.dart';
import '../../../../core/widgets/reminder_settings_sheet.dart';
import '../../../../core/widgets/share_progress_card.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
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
            onPressed: () => setState(() => _isGridView = !_isGridView),
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
              :final items
            ) =>
              RefreshIndicator(
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(
                        const WatchlistLoadRequested(),
                      );
                },
                child: _searchQuery.isEmpty
                    ? (_isGridView
                        ? _buildGridView(context, progress, streak, items, itemsByMonth)
                        : _buildNormalList(context, progress, streak, items, itemsByMonth))
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

  Widget _buildGridView(
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
          ..._buildGridMonthSection(context, entry.key, entry.value, items),
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
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
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = monthItems[index];
              return _buildGridTile(context, item, allItems);
            },
            childCount: monthItems.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildGridTile(
    BuildContext context,
    WatchlistItem item,
    List<WatchlistItem> allItems,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.push(
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
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w300${item.posterPath}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
          ),
          if (item.isWatched)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
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
    // With dynamic scheduling, we're always on track since schedule adjusts
    // to user's pace. Check if they're making any progress.
    final totalItems = items.length;
    final watchedItems = items.where((i) => i.isWatched).length;

    if (watchedItems == 0) return 'on_track';
    if (watchedItems == totalItems) return 'ahead';

    // Calculate expected progress based on time elapsed
    final now = DateTime.now();
    final doomsday = DateTime.utc(2026, 12, 18);
    final startDate = DateTime.utc(2025, 12, 1); // Approximate start

    final totalDays = doomsday.difference(startDate).inDays;
    final daysElapsed = now.difference(startDate).inDays;

    if (daysElapsed <= 0 || totalDays <= 0) return 'on_track';

    final expectedProgress = (daysElapsed / totalDays * totalItems).floor();
    final actualProgress = watchedItems;

    if (actualProgress < expectedProgress * 0.7) return 'behind';
    if (actualProgress > expectedProgress * 1.2) return 'ahead';
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
            final unwatched = state.items.where((i) => !i.isWatched && !i.comingSoon).toList();
            if (unwatched.isNotEmpty) {
              nextMovie = unwatched.first.title;
            }
          }
          _showRankSheet(context, progress, rank, nextMovie);
        },
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            rank.icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _showRankSheet(
      BuildContext context, WatchProgress progress, StatusRank rank, String? nextMovie) {
    final theme = Theme.of(context);
    final nextRank = rank.nextRank;
    final progressToNext = rank.progressToNextRank(progress.progressPercentage);
    final daysUntilDoomsday = DateTime(2026, 12, 18).difference(DateTime.now()).inDays;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
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
            Container(
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
              child: Icon(
                rank.icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              rank.title.toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rank.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(
                    theme, '${progress.watchedItems}', 'Watched'),
                const SizedBox(width: 32),
                _buildStatItem(theme,
                    '${progress.progressPercentage.toStringAsFixed(0)}%', 'Complete'),
                const SizedBox(width: 32),
                _buildStatItem(theme,
                    '${progress.hoursRemaining.toStringAsFixed(0)}h', 'Remaining'),
              ],
            ),
            if (nextRank != null) ...[
              const SizedBox(height: 24),
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
                  valueColor:
                      AlwaysStoppedAnimation(theme.colorScheme.secondary),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRemindersSheet(context, nextMovie);
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
                      _showShareSheet(context, progress, daysUntilDoomsday);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRemindersSheet(BuildContext context, String? nextMovie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReminderSettingsSheet(nextMovieTitle: nextMovie),
    );
  }

  void _showShareSheet(BuildContext context, WatchProgress progress, int daysRemaining) {
    final shareKey = GlobalKey();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.2),
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
      ),
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
}
