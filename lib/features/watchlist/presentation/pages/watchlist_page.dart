import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
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
            WatchlistInitial() => const SizedBox.shrink(),
            WatchlistLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
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
            WatchlistLoaded(:final progress, :final filteredMovies, :final activeFilter) =>
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
                            ProgressHeader(progress: progress),
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
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final movie = filteredMovies[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: MovieCard(
                                movie: movie,
                                onToggle: () {
                                  context.read<WatchlistBloc>().add(
                                        WatchlistMovieToggled(
                                          movieId: movie.id,
                                          isWatched: !movie.isWatched,
                                        ),
                                      );
                                },
                              ),
                            );
                          },
                          childCount: filteredMovies.length,
                        ),
                      ),
                    ),
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
}
