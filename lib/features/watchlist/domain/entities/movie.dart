import 'package:hive/hive.dart';

part 'movie.g.dart';

enum ContentType { movie, tv }

@HiveType(typeId: 0)
class WatchlistItem extends HiveObject {
  @HiveField(0)
  final int tmdbId;

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
  final String targetMonth;

  @HiveField(7)
  final String watchPath;

  @HiveField(8)
  bool isWatched;

  @HiveField(9)
  final int order;

  @HiveField(10)
  final int contentType;

  @HiveField(11)
  final int? season;

  @HiveField(12)
  final int episodeCount;

  @HiveField(13)
  int episodesWatched;

  @HiveField(14)
  final bool comingSoon;

  WatchlistItem({
    required this.tmdbId,
    required this.title,
    required this.runtime,
    this.posterPath,
    this.overview,
    required this.releaseDate,
    required this.targetMonth,
    required this.watchPath,
    this.isWatched = false,
    required this.order,
    required this.contentType,
    this.season,
    this.episodeCount = 0,
    this.episodesWatched = 0,
    this.comingSoon = false,
  });

  ContentType get type =>
      contentType == 0 ? ContentType.movie : ContentType.tv;

  bool get isMovie => contentType == 0;
  bool get isTvShow => contentType == 1;

  String get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get displayTitle =>
      season != null ? '$title (Season $season)' : title;

  double get progress {
    if (isMovie) return isWatched ? 1.0 : 0.0;
    if (episodeCount == 0) return 0.0;
    return episodesWatched / episodeCount;
  }

  String get uniqueKey => season != null ? '${tmdbId}_s$season' : '$tmdbId';

  WatchlistItem copyWith({
    int? tmdbId,
    String? title,
    int? runtime,
    String? posterPath,
    String? overview,
    String? releaseDate,
    String? targetMonth,
    String? watchPath,
    bool? isWatched,
    int? order,
    int? contentType,
    int? season,
    int? episodeCount,
    int? episodesWatched,
    bool? comingSoon,
  }) {
    return WatchlistItem(
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      runtime: runtime ?? this.runtime,
      posterPath: posterPath ?? this.posterPath,
      overview: overview ?? this.overview,
      releaseDate: releaseDate ?? this.releaseDate,
      targetMonth: targetMonth ?? this.targetMonth,
      watchPath: watchPath ?? this.watchPath,
      isWatched: isWatched ?? this.isWatched,
      order: order ?? this.order,
      contentType: contentType ?? this.contentType,
      season: season ?? this.season,
      episodeCount: episodeCount ?? this.episodeCount,
      episodesWatched: episodesWatched ?? this.episodesWatched,
      comingSoon: comingSoon ?? this.comingSoon,
    );
  }
}
