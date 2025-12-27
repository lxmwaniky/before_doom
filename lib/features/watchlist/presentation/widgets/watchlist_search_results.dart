import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/movie.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import 'watchlist_card.dart';

class WatchlistSearchResults extends StatelessWidget {
  const WatchlistSearchResults({
    super.key,
    required this.items,
    required this.searchQuery,
  });

  final List<WatchlistItem> items;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = searchQuery.toLowerCase();
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
              'No results for "$searchQuery"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 500,
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
}
