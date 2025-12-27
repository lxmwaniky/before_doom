import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/movie.dart';

abstract class WatchlistLocalDataSource {
  Future<List<WatchlistItem>> getCachedItems();
  Future<void> cacheItems(List<WatchlistItem> items);
  Future<void> updateWatchStatus(String key, bool isWatched);
  Future<void> updateEpisodesWatched(String key, int episodesWatched);
  Future<bool> hasItems();
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

      final existingProgress = <String, Map<String, dynamic>>{};
      for (final item in box.values) {
        existingProgress[item.uniqueKey] = {
          'isWatched': item.isWatched,
          'episodesWatched': item.episodesWatched,
        };
      }

      await box.clear();

      for (final item in items) {
        final existing = existingProgress[item.uniqueKey];
        if (existing != null) {
          item.isWatched = existing['isWatched'] as bool;
          item.episodesWatched = existing['episodesWatched'] as int;
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
}
