import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/streak_service.dart';
import '../../domain/repositories/movie_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository repository;
  final StreakService streakService;

  WatchlistBloc({
    required this.repository,
    required this.streakService,
  }) : super(const WatchlistInitial()) {
    on<WatchlistLoadRequested>(_onLoadRequested);
    on<WatchlistItemToggled>(_onItemToggled);
    on<WatchlistEpisodesUpdated>(_onEpisodesUpdated);
    on<WatchlistFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    WatchlistLoadRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    final itemsResult = await repository.getWatchlist();

    await itemsResult.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (items) async {
        final progressResult = await repository.getWatchProgress();
        final streak = await streakService.getCurrentStreak();

        progressResult.fold(
          (failure) => emit(WatchlistError(failure.message)),
          (progress) => emit(WatchlistLoaded(
            items: items,
            progress: progress,
            streak: streak,
          )),
        );
      },
    );
  }

  Future<void> _onItemToggled(
    WatchlistItemToggled event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final result = await repository.toggleWatchStatus(
      event.key,
      event.isWatched,
    );

    await result.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (_) async {
        if (event.isWatched) {
          await streakService.recordWatchActivity();
        }

        final updatedItems = currentState.items.map((item) {
          if (item.uniqueKey == event.key) {
            final updated = item.copyWith(isWatched: event.isWatched);
            if (event.isWatched && item.isTvShow) {
              return updated.copyWith(episodesWatched: item.episodeCount);
            }
            return updated;
          }
          return item;
        }).toList();

        final progressResult = await repository.getWatchProgress();
        final streak = await streakService.getCurrentStreak();

        progressResult.fold(
          (failure) => emit(WatchlistError(failure.message)),
          (progress) => emit(currentState.copyWith(
            items: updatedItems,
            progress: progress,
            streak: streak,
          )),
        );
      },
    );
  }

  Future<void> _onEpisodesUpdated(
    WatchlistEpisodesUpdated event,
    Emitter<WatchlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WatchlistLoaded) return;

    final result = await repository.updateEpisodesWatched(
      event.key,
      event.episodesWatched,
    );

    await result.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (_) async {
        if (event.episodesWatched > 0) {
          await streakService.recordWatchActivity();
        }

        final updatedItems = currentState.items.map((item) {
          if (item.uniqueKey == event.key) {
            final isComplete = event.episodesWatched >= item.episodeCount;
            return item.copyWith(
              episodesWatched: event.episodesWatched,
              isWatched: isComplete,
            );
          }
          return item;
        }).toList();

        final progressResult = await repository.getWatchProgress();
        final streak = await streakService.getCurrentStreak();

        progressResult.fold(
          (failure) => emit(WatchlistError(failure.message)),
          (progress) => emit(currentState.copyWith(
            items: updatedItems,
            progress: progress,
            streak: streak,
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
