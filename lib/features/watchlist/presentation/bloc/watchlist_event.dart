import 'package:flutter/foundation.dart';

@immutable
sealed class WatchlistEvent {
  const WatchlistEvent();
}

class WatchlistLoadRequested extends WatchlistEvent {
  const WatchlistLoadRequested();
}

class WatchlistItemToggled extends WatchlistEvent {
  final String key;
  final bool isWatched;

  const WatchlistItemToggled({
    required this.key,
    required this.isWatched,
  });
}

class WatchlistEpisodesUpdated extends WatchlistEvent {
  final String key;
  final int episodesWatched;

  const WatchlistEpisodesUpdated({
    required this.key,
    required this.episodesWatched,
  });
}

class WatchlistFilterChanged extends WatchlistEvent {
  final String? filter;

  const WatchlistFilterChanged(this.filter);
}
