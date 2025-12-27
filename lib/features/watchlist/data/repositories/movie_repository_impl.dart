import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/tmdb_data_source.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final TmdbDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist() async {
    try {
      final jsonVersion = await remoteDataSource.getJsonVersion();
      final cachedVersion = await localDataSource.getCachedVersion();
      final hasCache = await localDataSource.hasItems();

      if (hasCache && cachedVersion == jsonVersion) {
        final cachedItems = await localDataSource.getCachedItems();
        _refreshFromRemote();
        return Right(cachedItems);
      }

      if (cachedVersion != jsonVersion) {
        await localDataSource.clearCache();
      }

      final remoteItems = await remoteDataSource.getWatchlist();
      await localDataSource.cacheItems(remoteItems);
      await localDataSource.setCachedVersion(jsonVersion);
      return Right(remoteItems);
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

  Future<Either<Failure, List<WatchlistItem>>> _fallbackToCache(
    String errorMessage,
  ) async {
    try {
      final cachedItems = await localDataSource.getCachedItems();
      if (cachedItems.isNotEmpty) {
        return Right(cachedItems);
      }
    } catch (_) {}
    return Left(NetworkFailure(errorMessage));
  }

  Future<void> _refreshFromRemote() async {
    try {
      final jsonVersion = await remoteDataSource.getJsonVersion();
      final cachedVersion = await localDataSource.getCachedVersion();

      if (cachedVersion != jsonVersion) {
        await localDataSource.clearCache();
      }

      final remoteItems = await remoteDataSource.getWatchlist();
      await localDataSource.cacheItems(remoteItems);
      await localDataSource.setCachedVersion(jsonVersion);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, void>> toggleWatchStatus(
    String key,
    bool isWatched,
  ) async {
    try {
      await localDataSource.updateWatchStatus(key, isWatched);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEpisodesWatched(
    String key,
    int episodesWatched,
  ) async {
    try {
      await localDataSource.updateEpisodesWatched(key, episodesWatched);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, WatchProgress>> getWatchProgress() async {
    try {
      final items = await localDataSource.getCachedItems();

      final totalItems = items.length;
      final watchedItems = items.where((m) => m.isWatched).length;
      final totalMinutes = items.fold(0, (sum, m) => sum + m.runtime);

      int watchedMinutes = 0;
      int totalEpisodes = 0;
      int watchedEpisodes = 0;

      for (final item in items) {
        if (item.isMovie) {
          if (item.isWatched) watchedMinutes += item.runtime;
        } else {
          totalEpisodes += item.episodeCount;
          watchedEpisodes += item.episodesWatched;
          if (item.episodeCount > 0) {
            final episodeRuntime = item.runtime ~/ item.episodeCount;
            watchedMinutes += item.episodesWatched * episodeRuntime;
          }
        }
      }

      final remainingMinutes = totalMinutes - watchedMinutes;

      return Right(
        WatchProgress(
          totalItems: totalItems,
          watchedItems: watchedItems,
          totalMinutes: totalMinutes,
          watchedMinutes: watchedMinutes,
          remainingMinutes: remainingMinutes,
          totalEpisodes: totalEpisodes,
          watchedEpisodes: watchedEpisodes,
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
