import 'dart:io';

import 'package:before_doom/features/watchlist/data/datasources/movie_local_data_source.dart';
import 'package:before_doom/features/watchlist/domain/entities/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../../helpers/hive_test_helper.dart';

void main() {
  late Directory hiveDir;
  late WatchlistLocalDataSourceImpl dataSource;

  setUp(() async {
    hiveDir = await setUpTestHive();
    dataSource = WatchlistLocalDataSourceImpl();
  });

  tearDown(() async {
    await tearDownTestHive(hiveDir);
  });

  group('cacheItems', () {
    test('preserves progress for items with matching keys', () async {
      await dataSource.cacheItems([makeItem(tmdbId: 1)]);
      await dataSource.updateWatchStatus('1', true);

      await dataSource.cacheItems([makeItem(tmdbId: 1, runtime: 130)]);

      final items = await dataSource.getCachedItems();
      expect(items.single.isWatched, isTrue);
      expect(items.single.runtime, 130,
          reason: 'metadata should be refreshed from the new item');
    });

    test('never deletes a surviving item, even transiently', () async {
      // A destructive clear-then-rewrite briefly removes every item; if the
      // app is killed in that window, progress is gone. Re-caching must not
      // emit a delete event for a key that exists in both old and new lists.
      await dataSource.cacheItems([makeItem(tmdbId: 1)]);
      await dataSource.updateWatchStatus('1', true);

      final box = await Hive.openBox<WatchlistItem>('watchlist');
      final deleteEvents = <BoxEvent>[];
      final subscription = box.watch(key: '1').listen((event) {
        if (event.deleted) deleteEvents.add(event);
      });

      await dataSource.cacheItems([makeItem(tmdbId: 1, runtime: 130)]);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(deleteEvents, isEmpty,
          reason: 'surviving keys must be upserted, not cleared and re-added');
    });

    test('removes only items absent from the new list', () async {
      await dataSource.cacheItems([
        makeItem(tmdbId: 1),
        makeItem(tmdbId: 2, order: 2),
      ]);
      await dataSource.updateWatchStatus('1', true);

      await dataSource.cacheItems([makeItem(tmdbId: 1)]);

      final items = await dataSource.getCachedItems();
      expect(items.map((i) => i.uniqueKey), ['1']);
      expect(items.single.isWatched, isTrue);
    });
  });
}
