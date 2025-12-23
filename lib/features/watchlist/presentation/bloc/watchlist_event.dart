import 'package:flutter/foundation.dart';

@immutable
sealed class WatchlistEvent {
  const WatchlistEvent();
}

class WatchlistLoadRequested extends WatchlistEvent {
  const WatchlistLoadRequested();
}

class WatchlistMovieToggled extends WatchlistEvent {
  final int movieId;
  final bool isWatched;

  const WatchlistMovieToggled({
    required this.movieId,
    required this.isWatched,
  });
}

class WatchlistFilterChanged extends WatchlistEvent {
  final String? filter;

  const WatchlistFilterChanged(this.filter);
}
