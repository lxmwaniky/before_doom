import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/movie.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItem>> getCachedItems();
  Future<void> cacheItems(List<WatchlistItem> items);
  Future<void> updateWatchStatus(String key, bool isWatched);
  Future<void> updateEpisodesWatched(String key, int episodesWatched);
  Future<bool> hasItems();
  Future<int> getCachedVersion();
  Future<void> setCachedVersion(int version);
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String _boxName = 'watchlist';

  Future<Box<WatchlistItem>> get _box async =>
      Hive.openBox<WatchlistItem>(_boxName);

  @override
  Future<List<WatchlistItem>> getCachedItems() async {
    try {
      final box = await _box;
      final items = box.values.toList();
      items.sort((a, b) => a.order.compareTo(b.order));
      return items;
    } catch (e) {
      throw CacheException('Failed to get cached items: $e');
    }
  }

  @override
  Future<void> cacheItems(List<WatchlistItem> items) async {
    try {
      final box = await _box;

      // Upsert instead of clear-and-rewrite so user progress is never
      // deleted, even transiently (e.g. if the app dies mid-write).
      final newKeys = items.map((i) => i.uniqueKey).toSet();
      final staleKeys =
          box.keys.where((key) => !newKeys.contains(key)).toList();
      await box.deleteAll(staleKeys);

      for (final item in items) {
        final existing = box.get(item.uniqueKey);
        if (existing != null) {
          item.isWatched = existing.isWatched;
          item.episodesWatched = existing.episodesWatched;
        }
        await box.put(item.uniqueKey, item);
      }
    } catch (e) {
      throw CacheException('Failed to cache items: $e');
    }
  }

  @override
  Future<void> updateWatchStatus(String key, bool isWatched) async {
    try {
      final box = await _box;
      final item = box.get(key);
      if (item != null) {
        item.isWatched = isWatched;
        if (isWatched && item.isTvShow) {
          item.episodesWatched = item.episodeCount;
        }
        await item.save();
      }
    } catch (e) {
      throw CacheException('Failed to update watch status: $e');
    }
  }

  @override
  Future<void> updateEpisodesWatched(String key, int episodesWatched) async {
    try {
      final box = await _box;
      final item = box.get(key);
      if (item != null) {
        item.episodesWatched = episodesWatched;
        item.isWatched = episodesWatched >= item.episodeCount;
        await item.save();
      }
    } catch (e) {
      throw CacheException('Failed to update episodes watched: $e');
    }
  }

  @override
  Future<bool> hasItems() async {
    try {
      final box = await _box;
      return box.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> getCachedVersion() async {
    try {
      final box = await Hive.openBox<int>('app_metadata');
      return box.get('watchlist_version', defaultValue: 0) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> setCachedVersion(int version) async {
    try {
      final box = await Hive.openBox<int>('app_metadata');
      await box.put('watchlist_version', version);
    } catch (_) {}
  }
}
