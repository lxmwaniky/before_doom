import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/movie_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final MovieRepository repository;

  WatchlistBloc({required this.repository}) : super(const WatchlistInitial()) {
    on<WatchlistLoadRequested>(_onLoadRequested);
    on<WatchlistMovieToggled>(_onMovieToggled);
    on<WatchlistFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    WatchlistLoadRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    final moviesResult = await repository.getMovies();
    
    await moviesResult.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (movies) async {
        final progressResult = await repository.getWatchProgress();
        progressResult.fold(
          (failure) => emit(WatchlistError(failure.message)),
          (progress) => emit(WatchlistLoaded(
            movies: movies,
            progress: progress,
          )),
        );
      },
    );
  }

  Future<void> _onMovieToggled(
    WatchlistMovieToggled event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final result = await repository.toggleWatchStatus(
      event.movieId,
      event.isWatched,
    );

    await result.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (_) async {
        final updatedMovies = currentState.movies.map((movie) {
          if (movie.id == event.movieId) {
            return movie.copyWith(isWatched: event.isWatched);
          }
          return movie;
        }).toList();

        final progressResult = await repository.getWatchProgress();
        progressResult.fold(
          (failure) => emit(WatchlistError(failure.message)),
          (progress) => emit(currentState.copyWith(
            movies: updatedMovies,
            progress: progress,
          )),
        );
      },
    );
  }

  void _onFilterChanged(
    WatchlistFilterChanged event,
    Emitter<WatchlistState> emit,
  ) {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    emit(currentState.copyWith(
      activeFilter: event.filter,
      clearFilter: event.filter == null,
    ));
  }
}
