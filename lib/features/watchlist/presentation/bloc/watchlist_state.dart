import 'package:flutter/foundation.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

@immutable
sealed class WatchlistState {
  const WatchlistState();
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final List<Movie> movies;
  final WatchProgress progress;
  final String? activeFilter;

  const WatchlistLoaded({
    required this.movies,
    required this.progress,
    this.activeFilter,
  });

  List<Movie> get filteredMovies {
    if (activeFilter == null) return movies;
    return movies.where((m) => m.watchPaths.contains(activeFilter)).toList();
  }

  WatchlistLoaded copyWith({
    List<Movie>? movies,
    WatchProgress? progress,
    String? activeFilter,
    bool clearFilter = false,
  }) {
    return WatchlistLoaded(
      movies: movies ?? this.movies,
      progress: progress ?? this.progress,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);
}
