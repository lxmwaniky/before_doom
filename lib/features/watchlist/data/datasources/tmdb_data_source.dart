import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/mcu_movie_data.dart';
import '../../domain/entities/movie.dart';

abstract class TmdbDataSource {
  Future<List<Movie>> getMcuMovies();
}

class TmdbDataSourceImpl implements TmdbDataSource {
  final http.Client client;
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _timeout = Duration(seconds: 10);

  TmdbDataSourceImpl({required this.client});

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  @override
  Future<List<Movie>> getMcuMovies() async {
    if (_apiKey.isEmpty) {
      throw const ServerException('TMDB API key not configured');
    }

    final movies = <Movie>[];

    for (final movieData in McuMovieData.mcuMovies) {
      try {
        final movie = await _fetchMovieDetails(movieData['id'] as int);
        if (movie != null) {
          final enrichedMovie = movie.copyWith(
            phase: movieData['phase'] as int,
            order: movieData['order'] as int,
            watchPaths: List<String>.from(movieData['paths'] as List),
          );
          movies.add(enrichedMovie);
        }
      } on SocketException {
        throw const ServerException('No internet connection');
      } on http.ClientException {
        continue;
      } catch (_) {
        continue;
      }
    }

    if (movies.isEmpty) {
      throw const ServerException('Failed to fetch movies. Check your connection.');
    }

    movies.sort((a, b) => a.order.compareTo(b.order));
    return movies;
  }

  Future<Movie?> _fetchMovieDetails(int movieId) async {
    try {
      final response = await client
          .get(Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Movie(
          id: json['id'] as int,
          title: json['title'] as String,
          runtime: json['runtime'] as int? ?? 0,
          posterPath: json['poster_path'] as String?,
          overview: json['overview'] as String?,
          releaseDate: json['release_date'] as String? ?? '',
          phase: 1,
          watchPaths: [],
          order: 0,
        );
      }
      return null;
    } on TimeoutException {
      return null;
    }
  }
}
