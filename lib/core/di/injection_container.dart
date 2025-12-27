import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/countdown/presentation/bloc/countdown_bloc.dart';
import '../../features/watchlist/data/datasources/movie_local_data_source.dart';
import '../../features/watchlist/data/datasources/tmdb_data_source.dart';
import '../../features/watchlist/data/repositories/movie_repository_impl.dart';
import '../../features/watchlist/domain/repositories/movie_repository.dart';
import '../../features/watchlist/presentation/bloc/watchlist_bloc.dart';
import '../services/streak_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // BLoCs
  sl.registerFactory(() => CountdownBloc());
  sl.registerFactory(
    () => WatchlistBloc(repository: sl(), streakService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WatchlistRepository>(
    () =>
        WatchlistRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TmdbDataSource>(
    () => TmdbDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(),
  );

  // Services
  sl.registerLazySingleton<StreakService>(() => StreakServiceImpl());

  // External
  sl.registerLazySingleton(() => http.Client());
}
