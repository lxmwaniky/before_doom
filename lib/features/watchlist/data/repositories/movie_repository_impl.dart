import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/tmdb_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TmdbDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Movie>>> getMovies() async {
    try {
      final hasCache = await localDataSource.hasMovies();
      
      if (hasCache) {
        final cachedMovies = await localDataSource.getCachedMovies();
        _refreshFromRemote();
        return Right(cachedMovies);
      }

      final remoteMovies = await remoteDataSource.getMcuMovies();
      await localDataSource.cacheMovies(remoteMovies);
      return Right(remoteMovies);
    } on SocketException {
      return _fallbackToCache('No internet connection');
    } on ServerException catch (e) {
      return _fallbackToCache(e.message);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return _fallbackToCache('Something went wrong');
    }
  }

  Future<Either<Failure, List<Movie>>> _fallbackToCache(String errorMessage) async {
    try {
      final cachedMovies = await localDataSource.getCachedMovies();
      if (cachedMovies.isNotEmpty) {
        return Right(cachedMovies);
      }
    } catch (_) {}
    return Left(NetworkFailure(errorMessage));
  }

  Future<void> _refreshFromRemote() async {
    try {
      final currentMovies = await localDataSource.getCachedMovies();
      final watchedIds = currentMovies
          .where((m) => m.isWatched)
          .map((m) => m.id)
          .toSet();

      final remoteMovies = await remoteDataSource.getMcuMovies();
      
      for (final movie in remoteMovies) {
        if (watchedIds.contains(movie.id)) {
          movie.isWatched = true;
        }
      }
      
      await localDataSource.cacheMovies(remoteMovies);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, void>> toggleWatchStatus(
    int movieId,
    bool isWatched,
  ) async {
    try {
      await localDataSource.updateWatchStatus(movieId, isWatched);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WatchProgress>> getWatchProgress() async {
    try {
      final movies = await localDataSource.getCachedMovies();
      
      final totalMovies = movies.length;
      final watchedMovies = movies.where((m) => m.isWatched).length;
      final totalMinutes = movies.fold(0, (sum, m) => sum + m.runtime);
      final watchedMinutes = movies
          .where((m) => m.isWatched)
          .fold(0, (sum, m) => sum + m.runtime);
      final remainingMinutes = totalMinutes - watchedMinutes;

      return Right(WatchProgress(
        totalMovies: totalMovies,
        watchedMovies: watchedMovies,
        totalMinutes: totalMinutes,
        watchedMinutes: watchedMinutes,
        remainingMinutes: remainingMinutes,
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
