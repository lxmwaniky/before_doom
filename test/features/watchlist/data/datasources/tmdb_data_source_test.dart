import 'dart:convert';

import 'package:before_doom/core/error/exceptions.dart';
import 'package:before_doom/features/watchlist/data/datasources/tmdb_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: 'TMDB_API_KEY=test-key');
  });

  // Remote watchlist with a version far above the bundled asset's, so the
  // data source uses this small controlled list instead of the real one.
  final remoteWatchlist = jsonEncode({
    'version': 999999,
    'items': [
      {
        'tmdbId': 100,
        'type': 'movie',
        'title': 'Fetch Succeeds',
        'targetMonth': '2026-01',
        'path': 'movies',
        'order': 1,
      },
      {
        'tmdbId': 200,
        'type': 'movie',
        'title': 'Fetch Fails',
        'targetMonth': '2026-02',
        'path': 'movies',
        'order': 2,
      },
    ],
  });

  TmdbDataSourceImpl buildDataSource({required bool movie100Succeeds}) {
    return TmdbDataSourceImpl(
      client: MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('raw.githubusercontent.com')) {
          return http.Response(remoteWatchlist, 200);
        }
        if (url.contains('/movie/100') && movie100Succeeds) {
          return http.Response(
            jsonEncode({
              'id': 100,
              'title': 'Fetch Succeeds',
              'runtime': 120,
              'poster_path': '/poster.jpg',
              'overview': 'A movie.',
              'release_date': '2020-01-01',
            }),
            200,
          );
        }
        return http.Response('Internal Server Error', 500);
      }),
    );
  }

  group('getWatchlist with partial TMDB failures', () {
    test('keeps failed items using watchlist JSON metadata', () async {
      final dataSource = buildDataSource(movie100Succeeds: true);

      final items = await dataSource.getWatchlist();

      expect(items.length, 2,
          reason: 'an item whose TMDB fetch fails must not be dropped');
      final fallback = items.firstWhere((i) => i.tmdbId == 200);
      expect(fallback.title, 'Fetch Fails');
      expect(fallback.order, 2);
      expect(fallback.watchPath, 'movies');
    });

    test('still throws when every TMDB fetch fails', () async {
      final dataSource = buildDataSource(movie100Succeeds: false);

      expect(dataSource.getWatchlist, throwsA(isA<ServerException>()));
    });
  });
}
