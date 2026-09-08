import 'dart:io';

import 'package:before_doom/features/watchlist/data/datasources/movie_local_data_source.dart';
import 'package:before_doom/features/watchlist/data/datasources/tmdb_data_source.dart';
import 'package:before_doom/features/watchlist/data/repositories/movie_repository_impl.dart';
import 'package:before_doom/features/watchlist/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/hive_test_helper.dart';

class FakeTmdbDataSource implements TmdbDataSource {
  FakeTmdbDataSource({required this.version, required this.itemsBuilder});

  final int version;
  final List<WatchlistItem> Function() itemsBuilder;

  @override
  Future<int> getJsonVersion() async => version;

  @override
  Future<List<WatchlistItem>> getWatchlist() async => itemsBuilder();
}

void main() {
  late Directory hiveDir;
  late WatchlistLocalDataSourceImpl localDataSource;

  setUp(() async {
    hiveDir = await setUpTestHive();
    localDataSource = WatchlistLocalDataSourceImpl();
  });

  tearDown(() async {
    await tearDownTestHive(hiveDir);
  });

  group('getWatchlist on watchlist version bump', () {
    test('preserves watch progress for items that still exist', () async {
      // Seed cache at version 1 with progress.
      await localDataSource.cacheItems([
        makeItem(tmdbId: 1, title: 'Iron Man'),
        makeItem(
          tmdbId: 2,
          title: 'Loki',
          contentType: 1,
          season: 1,
          episodeCount: 6,
          order: 2,
        ),
      ]);
      await localDataSource.setCachedVersion(1);
      await localDataSource.updateWatchStatus('1', true);
      await localDataSource.updateEpisodesWatched('2_s1', 3);

      // Remote now serves version 2 with the same items (fresh instances,
      // no progress) — simulating a watchlist JSON update.
      final repository = WatchlistRepositoryImpl(
        remoteDataSource: FakeTmdbDataSource(
          version: 2,
          itemsBuilder: () => [
            makeItem(tmdbId: 1, title: 'Iron Man'),
            makeItem(
              tmdbId: 2,
              title: 'Loki',
              contentType: 1,
              season: 1,
              episodeCount: 6,
              order: 2,
            ),
          ],
        ),
        localDataSource: localDataSource,
      );

      final result = await repository.getWatchlist();

      final items = result.getOrElse(() => fail('expected Right, got $result'));
      final ironMan = items.firstWhere((i) => i.uniqueKey == '1');
      final loki = items.firstWhere((i) => i.uniqueKey == '2_s1');
      expect(ironMan.isWatched, isTrue,
          reason: 'movie progress must survive a version bump');
      expect(loki.episodesWatched, 3,
          reason: 'episode progress must survive a version bump');

      final cached = await localDataSource.getCachedItems();
      expect(cached.firstWhere((i) => i.uniqueKey == '1').isWatched, isTrue,
          reason: 'preserved progress must also be persisted');
      expect(await localDataSource.getCachedVersion(), 2);
    });

    test('removes items that no longer exist in the new watchlist', () async {
      await localDataSource.cacheItems([
        makeItem(tmdbId: 1, title: 'Iron Man'),
        makeItem(tmdbId: 3, title: 'Removed Movie', order: 3),
      ]);
      await localDataSource.setCachedVersion(1);

      final repository = WatchlistRepositoryImpl(
        remoteDataSource: FakeTmdbDataSource(
          version: 2,
          itemsBuilder: () => [makeItem(tmdbId: 1, title: 'Iron Man')],
        ),
        localDataSource: localDataSource,
      );

      final result = await repository.getWatchlist();

      expect(result.isRight(), isTrue);
      final cached = await localDataSource.getCachedItems();
      expect(cached.map((i) => i.uniqueKey), ['1']);
    });
  });
}
