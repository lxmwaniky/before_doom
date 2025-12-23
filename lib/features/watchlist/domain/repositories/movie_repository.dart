import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getMovies();
  Future<Either<Failure, void>> toggleWatchStatus(int movieId, bool isWatched);
  Future<Either<Failure, WatchProgress>> getWatchProgress();
}

class WatchProgress {
  final int totalMovies;
  final int watchedMovies;
  final int totalMinutes;
  final int watchedMinutes;
  final int remainingMinutes;

  WatchProgress({
    required this.totalMovies,
    required this.watchedMovies,
    required this.totalMinutes,
    required this.watchedMinutes,
    required this.remainingMinutes,
  });

  double get progressPercentage =>
      totalMovies > 0 ? (watchedMovies / totalMovies) * 100 : 0;

  double get hoursRemaining => remainingMinutes / 60;
  double get hoursWatched => watchedMinutes / 60;
  double get totalHours => totalMinutes / 60;
}
