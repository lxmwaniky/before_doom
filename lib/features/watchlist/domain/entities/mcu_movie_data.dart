import '../entities/movie.dart';

class McuMovieData {
  static const int mcuCollectionId = 131295;
  
  static final List<Map<String, dynamic>> mcuMovies = [
    {'id': 1726, 'phase': 1, 'order': 1, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 1724, 'phase': 1, 'order': 2, 'paths': ['movies', 'completionist']},
    {'id': 10138, 'phase': 1, 'order': 3, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 10195, 'phase': 1, 'order': 4, 'paths': ['movies', 'completionist']},
    {'id': 1771, 'phase': 1, 'order': 5, 'paths': ['movies', 'completionist']},
    {'id': 24428, 'phase': 1, 'order': 6, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 68721, 'phase': 2, 'order': 7, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 76338, 'phase': 2, 'order': 8, 'paths': ['movies', 'completionist']},
    {'id': 100402, 'phase': 2, 'order': 9, 'paths': ['movies', 'completionist']},
    {'id': 118340, 'phase': 2, 'order': 10, 'paths': ['movies', 'completionist']},
    {'id': 99861, 'phase': 2, 'order': 11, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 102899, 'phase': 2, 'order': 12, 'paths': ['movies', 'completionist']},
    {'id': 271110, 'phase': 3, 'order': 13, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 283995, 'phase': 3, 'order': 14, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 284052, 'phase': 3, 'order': 15, 'paths': ['movies', 'completionist']},
    {'id': 315635, 'phase': 3, 'order': 16, 'paths': ['movies', 'completionist']},
    {'id': 284053, 'phase': 3, 'order': 17, 'paths': ['movies', 'completionist']},
    {'id': 211672, 'phase': 3, 'order': 18, 'paths': ['movies', 'completionist']},
    {'id': 284054, 'phase': 3, 'order': 19, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 363088, 'phase': 3, 'order': 20, 'paths': ['movies', 'completionist']},
    {'id': 299536, 'phase': 3, 'order': 21, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 299537, 'phase': 3, 'order': 22, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 429617, 'phase': 3, 'order': 23, 'paths': ['movies', 'completionist']},
    {'id': 497698, 'phase': 4, 'order': 24, 'paths': ['movies', 'completionist']},
    {'id': 524434, 'phase': 4, 'order': 25, 'paths': ['movies', 'completionist']},
    {'id': 566525, 'phase': 4, 'order': 26, 'paths': ['movies', 'completionist']},
    {'id': 634649, 'phase': 4, 'order': 27, 'paths': ['movies', 'completionist']},
    {'id': 453395, 'phase': 4, 'order': 28, 'paths': ['essential', 'movies', 'completionist']},
    {'id': 616037, 'phase': 4, 'order': 29, 'paths': ['movies', 'completionist']},
    {'id': 505642, 'phase': 5, 'order': 30, 'paths': ['movies', 'completionist']},
    {'id': 640146, 'phase': 5, 'order': 31, 'paths': ['movies', 'completionist']},
    {'id': 447365, 'phase': 5, 'order': 32, 'paths': ['movies', 'completionist']},
    {'id': 609681, 'phase': 5, 'order': 33, 'paths': ['movies', 'completionist']},
    {'id': 1003596, 'phase': 5, 'order': 34, 'paths': ['movies', 'completionist']},
    {'id': 986056, 'phase': 6, 'order': 35, 'paths': ['essential', 'movies', 'completionist']},
  ];

  static Map<String, dynamic>? getMovieMetadata(int tmdbId) {
    try {
      return mcuMovies.firstWhere((m) => m['id'] == tmdbId);
    } catch (_) {
      return null;
    }
  }

  static Movie enrichWithMetadata(Movie movie) {
    final metadata = getMovieMetadata(movie.id);
    if (metadata == null) return movie;
    
    return movie.copyWith(
      phase: metadata['phase'] as int,
      order: metadata['order'] as int,
      watchPaths: List<String>.from(metadata['paths'] as List),
    );
  }
}
