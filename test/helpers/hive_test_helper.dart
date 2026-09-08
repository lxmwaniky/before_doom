import 'dart:io';

import 'package:before_doom/features/watchlist/domain/entities/movie.dart';
import 'package:hive/hive.dart';

Future<Directory> setUpTestHive() async {
  final dir = await Directory.systemTemp.createTemp('before_doom_test');
  Hive.init(dir.path);
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(WatchlistItemAdapter());
  }
  return dir;
}

Future<void> tearDownTestHive(Directory dir) async {
  await Hive.deleteFromDisk();
  await Hive.close();
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

WatchlistItem makeItem({
  int tmdbId = 1,
  String title = 'Test Movie',
  int runtime = 120,
  int order = 1,
  int contentType = 0,
  int? season,
  int episodeCount = 0,
  bool isWatched = false,
  int episodesWatched = 0,
}) {
  return WatchlistItem(
    tmdbId: tmdbId,
    title: title,
    runtime: runtime,
    releaseDate: '2020-01-01',
    targetMonth: '2026-01',
    watchPath: 'movies',
    order: order,
    contentType: contentType,
    season: season,
    episodeCount: episodeCount,
    isWatched: isWatched,
    episodesWatched: episodesWatched,
  );
}
