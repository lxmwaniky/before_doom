import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/movie.dart';

abstract class TmdbDataSource {
  Future<List<WatchlistItem>> getWatchlist();
}

class TmdbDataSourceImpl implements TmdbDataSource {
  final http.Client client;
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _timeout = Duration(seconds: 10);

  TmdbDataSourceImpl({required this.client});

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  @override
  Future<List<WatchlistItem>> getWatchlist() async {
    if (_apiKey.isEmpty) {
      throw const ServerException('TMDB API key not configured');
    }

    final jsonStr = await rootBundle.loadString('assets/marvel_watchlist.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final jsonItems = data['items'] as List;

    final futures = <Future<WatchlistItem?>>[];

    for (final itemData in jsonItems) {
      final tmdbId = itemData['tmdbId'] as int;
      final type = itemData['type'] as String;
      final comingSoon = itemData['comingSoon'] == true;

      if (comingSoon || tmdbId == 0) {
        futures.add(Future.value(_createComingSoonItem(itemData)));
        continue;
      }

      if (type == 'movie') {
        futures.add(_fetchMovieDetails(itemData));
      } else {
        futures.add(_fetchTvDetails(itemData));
      }
    }

    final results = await Future.wait(futures, eagerError: false);
    final items = results.whereType<WatchlistItem>().toList();

    if (items.isEmpty) {
      throw const ServerException('Failed to fetch watchlist. Check your connection.');
    }

    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  WatchlistItem _createComingSoonItem(Map<String, dynamic> itemData) {
    return WatchlistItem(
      tmdbId: itemData['tmdbId'] as int? ?? 0,
      title: itemData['title'] as String,
      runtime: 0,
      posterPath: null,
      overview: 'Coming soon to the MCU.',
      releaseDate: '',
      targetMonth: itemData['targetMonth'] as String,
      watchPath: itemData['path'] as String,
      order: itemData['order'] as int,
      contentType: itemData['type'] == 'movie' ? 0 : 1,
      season: itemData['season'] as int?,
      comingSoon: true,
    );
  }

  WatchlistItem _createComingSoonItem(Map<String, dynamic> itemData) {
    return WatchlistItem(
      tmdbId: itemData['tmdbId'] as int? ?? 0,
      title: itemData['title'] as String? ?? 'Coming Soon',
      runtime: itemData['runtime'] as int? ?? 0,
      posterPath: null,
      overview: itemData['overview'] as String?,
      releaseDate: itemData['releaseDate'] as String? ?? '',
      targetMonth: itemData['targetMonth'] as String,
      watchPath: itemData['path'] as String,
      order: itemData['order'] as int,
      contentType: itemData['type'] == 'movie' ? 0 : 1,
      season: itemData['season'] as int?,
      episodeCount: itemData['episodes'] as int?,
    );
  }

  Future<WatchlistItem?> _fetchMovieDetails(Map<String, dynamic> itemData) async {
    final tmdbId = itemData['tmdbId'] as int;

    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/movie/$tmdbId?api_key=$_apiKey'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WatchlistItem(
          tmdbId: json['id'] as int,
          title: json['title'] as String,
          runtime: json['runtime'] as int? ?? 0,
          posterPath: json['poster_path'] as String?,
          overview: json['overview'] as String?,
          releaseDate: json['release_date'] as String? ?? '',
          targetMonth: itemData['targetMonth'] as String,
          watchPath: itemData['path'] as String,
          order: itemData['order'] as int,
          contentType: 0,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<WatchlistItem?> _fetchTvDetails(Map<String, dynamic> itemData) async {
    final tmdbId = itemData['tmdbId'] as int;
    final season = itemData['season'] as int?;

    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/tv/$tmdbId?api_key=$_apiKey'))
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      int episodeCount = 0;
      int runtime = 0;

      if (season != null) {
        final seasonData = await _fetchSeasonDetails(tmdbId, season);
        episodeCount = seasonData['episodeCount'] as int? ?? 0;
        runtime = (seasonData['runtime'] as int? ?? 45) * episodeCount;
      } else {
        final seasons = json['seasons'] as List? ?? [];
        for (final s in seasons) {
          if ((s['season_number'] as int? ?? 0) > 0) {
            episodeCount += s['episode_count'] as int? ?? 0;
          }
        }
        runtime = (json['episode_run_time'] as List?)?.firstOrNull as int? ?? 45;
        runtime *= episodeCount;
      }

      return WatchlistItem(
        tmdbId: json['id'] as int,
        title: json['name'] as String,
        runtime: runtime,
        posterPath: json['poster_path'] as String?,
        overview: json['overview'] as String?,
        releaseDate: json['first_air_date'] as String? ?? '',
        targetMonth: itemData['targetMonth'] as String,
        watchPath: itemData['path'] as String,
        order: itemData['order'] as int,
        contentType: 1,
        season: season,
        episodeCount: episodeCount,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchSeasonDetails(int tvId, int seasonNum) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/tv/$tvId/season/$seasonNum?api_key=$_apiKey'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final episodes = json['episodes'] as List? ?? [];
        return {
          'episodeCount': episodes.length,
          'runtime': episodes.isNotEmpty
              ? (episodes.first['runtime'] as int? ?? 45)
              : 45,
        };
      }
    } catch (_) {}
    return {'episodeCount': 0, 'runtime': 45};
  }
}
