import '../entities/movie.dart';

class McuMovieData {
  static const int mcuCollectionId = 131295;

  // MCU Movies in TIMELINE order (story chronology)
  // Essential = must-watch for Doomsday context (Multiverse + key Avengers)
  static final List<Map<String, dynamic>> mcuMovies = [
    // Phase 1
    {'id': 13475, 'phase': 1, 'order': 1, 'paths': ['movies', 'completionist']}, // Captain America: The First Avenger
    {'id': 271110, 'phase': 1, 'order': 2, 'paths': ['movies', 'completionist']}, // Captain Marvel
    {'id': 1726, 'phase': 1, 'order': 3, 'paths': ['essential', 'movies', 'completionist']}, // Iron Man
    {'id': 1724, 'phase': 1, 'order': 4, 'paths': ['movies', 'completionist']}, // Iron Man 2
    {'id': 10195, 'phase': 1, 'order': 5, 'paths': ['movies', 'completionist']}, // Thor
    {'id': 1771, 'phase': 1, 'order': 6, 'paths': ['movies', 'completionist']}, // The Incredible Hulk
    {'id': 24428, 'phase': 1, 'order': 7, 'paths': ['essential', 'movies', 'completionist']}, // The Avengers

    // Phase 2
    {'id': 68721, 'phase': 2, 'order': 8, 'paths': ['essential', 'movies', 'completionist']}, // Iron Man 3
    {'id': 76338, 'phase': 2, 'order': 9, 'paths': ['movies', 'completionist']}, // Thor: The Dark World
    {'id': 100402, 'phase': 2, 'order': 10, 'paths': ['movies', 'completionist']}, // Captain America: The Winter Soldier
    {'id': 118340, 'phase': 2, 'order': 11, 'paths': ['movies', 'completionist']}, // Guardians of the Galaxy
    {'id': 283995, 'phase': 2, 'order': 12, 'paths': ['movies', 'completionist']}, // Guardians of the Galaxy Vol. 2
    {'id': 99861, 'phase': 2, 'order': 13, 'paths': ['essential', 'movies', 'completionist']}, // Avengers: Age of Ultron
    {'id': 102899, 'phase': 2, 'order': 14, 'paths': ['movies', 'completionist']}, // Ant-Man

    // Phase 3
    {'id': 130634, 'phase': 3, 'order': 15, 'paths': ['essential', 'movies', 'completionist']}, // Captain America: Civil War
    {'id': 284052, 'phase': 3, 'order': 16, 'paths': ['movies', 'completionist']}, // Doctor Strange
    {'id': 315635, 'phase': 3, 'order': 17, 'paths': ['movies', 'completionist']}, // Spider-Man: Homecoming
    {'id': 211672, 'phase': 3, 'order': 18, 'paths': ['movies', 'completionist']}, // Black Panther
    {'id': 284053, 'phase': 3, 'order': 19, 'paths': ['movies', 'completionist']}, // Thor: Ragnarok
    {'id': 284054, 'phase': 3, 'order': 20, 'paths': ['movies', 'completionist']}, // Ant-Man and the Wasp
    {'id': 299536, 'phase': 3, 'order': 21, 'paths': ['essential', 'movies', 'completionist']}, // Avengers: Infinity War
    {'id': 299537, 'phase': 3, 'order': 22, 'paths': ['essential', 'movies', 'completionist']}, // Avengers: Endgame

    // Phase 4
    {'id': 497698, 'phase': 4, 'order': 23, 'paths': ['movies', 'completionist']}, // Black Widow
    {'id': 566525, 'phase': 4, 'order': 24, 'paths': ['movies', 'completionist']}, // Shang-Chi
    {'id': 524434, 'phase': 4, 'order': 25, 'paths': ['movies', 'completionist']}, // Eternals
    {'id': 634649, 'phase': 4, 'order': 26, 'paths': ['movies', 'completionist']}, // Spider-Man: No Way Home
    {'id': 453395, 'phase': 4, 'order': 27, 'paths': ['essential', 'movies', 'completionist']}, // Doctor Strange in the Multiverse of Madness
    {'id': 616037, 'phase': 4, 'order': 28, 'paths': ['movies', 'completionist']}, // Thor: Love and Thunder
    {'id': 505642, 'phase': 4, 'order': 29, 'paths': ['movies', 'completionist']}, // Black Panther: Wakanda Forever

    // Phase 5
    {'id': 640146, 'phase': 5, 'order': 30, 'paths': ['movies', 'completionist']}, // Ant-Man and the Wasp: Quantumania
    {'id': 447365, 'phase': 5, 'order': 31, 'paths': ['movies', 'completionist']}, // Guardians of the Galaxy Vol. 3
    {'id': 609681, 'phase': 5, 'order': 32, 'paths': ['movies', 'completionist']}, // The Marvels
    {'id': 822119, 'phase': 5, 'order': 33, 'paths': ['movies', 'completionist']}, // Deadpool & Wolverine
    {'id': 986056, 'phase': 5, 'order': 34, 'paths': ['essential', 'movies', 'completionist']}, // Thunderbolts*
    {'id': 948549, 'phase': 6, 'order': 35, 'paths': ['essential', 'movies', 'completionist']}, // Blade
    {'id': 617126, 'phase': 6, 'order': 36, 'paths': ['essential', 'movies', 'completionist']}, // Fantastic Four: First Steps
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
