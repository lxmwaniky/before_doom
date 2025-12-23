import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int runtime;

  @HiveField(3)
  final String? posterPath;

  @HiveField(4)
  final String? overview;

  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final int phase;

  @HiveField(7)
  final List<String> watchPaths;

  @HiveField(8)
  bool isWatched;

  @HiveField(9)
  final int order;

  Movie({
    required this.id,
    required this.title,
    required this.runtime,
    this.posterPath,
    this.overview,
    required this.releaseDate,
    required this.phase,
    required this.watchPaths,
    this.isWatched = false,
    required this.order,
  });

  String get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  Movie copyWith({
    int? id,
    String? title,
    int? runtime,
    String? posterPath,
    String? overview,
    String? releaseDate,
    int? phase,
    List<String>? watchPaths,
    bool? isWatched,
    int? order,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      runtime: runtime ?? this.runtime,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      phase: phase ?? this.phase,
      watchPaths: watchPaths ?? this.watchPaths,
      isWatched: isWatched ?? this.isWatched,
      order: order ?? this.order,
    );
  }
}
