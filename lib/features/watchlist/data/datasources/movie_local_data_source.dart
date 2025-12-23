import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/movie.dart';

abstract class MovieLocalDataSource {
  Future<List<Movie>> getCachedMovies();
  Future<void> cacheMovies(List<Movie> movies);
  Future<void> updateWatchStatus(int movieId, bool isWatched);
  Future<bool> hasMovies();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const String _boxName = 'movies';

  Future<Box<Movie>> get _box async => Hive.openBox<Movie>(_boxName);

  @override
  Future<List<Movie>> getCachedMovies() async {
    try {
      final box = await _box;
      final movies = box.values.toList();
      movies.sort((a, b) => a.order.compareTo(b.order));
      return movies;
    } catch (e) {
      throw CacheException('Failed to get cached movies: $e');
    }
  }

  @override
  Future<void> cacheMovies(List<Movie> movies) async {
    try {
      final box = await _box;
      await box.clear();
      for (final movie in movies) {
        await box.put(movie.id, movie);
      }
    } catch (e) {
      throw CacheException('Failed to cache movies: $e');
    }
  }

  @override
  Future<void> updateWatchStatus(int movieId, bool isWatched) async {
    try {
      final box = await _box;
      final movie = box.get(movieId);
      if (movie != null) {
        movie.isWatched = isWatched;
        await movie.save();
      }
    } catch (e) {
      throw CacheException('Failed to update watch status: $e');
    }
  }

  @override
  Future<bool> hasMovies() async {
    try {
      final box = await _box;
      return box.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
