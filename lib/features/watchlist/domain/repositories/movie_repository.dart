import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';

abstract class WatchlistRepository {
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist();
  Future<Either<Failure, void>> toggleWatchStatus(String key, bool isWatched);
  Future<Either<Failure, void>> updateEpisodesWatched(String key, int episodesWatched);
  Future<Either<Failure, WatchProgress>> getWatchProgress();
}

class WatchProgress {
  final int totalItems;
  final int watchedItems;
  final int totalMinutes;
  final int watchedMinutes;
  final int remainingMinutes;
  final int totalEpisodes;
  final int watchedEpisodes;

  WatchProgress({
    required this.totalItems,
    required this.watchedItems,
    required this.totalMinutes,
    required this.watchedMinutes,
    required this.remainingMinutes,
    required this.totalEpisodes,
    required this.watchedEpisodes,
  });

  double get progressPercentage =>
      totalItems > 0 ? (watchedItems / totalItems) * 100 : 0;

  double get hoursRemaining => remainingMinutes / 60;
  double get hoursWatched => watchedMinutes / 60;
  double get totalHours => totalMinutes / 60;
}
