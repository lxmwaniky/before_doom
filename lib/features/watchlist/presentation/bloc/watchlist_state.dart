import 'package:flutter/foundation.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

@immutable
sealed class WatchlistState {
  const WatchlistState();
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final List<WatchlistItem> items;
  final WatchProgress progress;
  final String? activeFilter;
  final int streak;

  const WatchlistLoaded({
    required this.items,
    required this.progress,
    this.activeFilter,
    this.streak = 0,
  });

  List<WatchlistItem> get filteredItems {
    if (activeFilter == null) return items;
    return items.where((m) => m.watchPath == activeFilter).toList();
  }

  Map<String, List<WatchlistItem>> get itemsByMonth {
    final result = <String, List<WatchlistItem>>{};
    for (final item in filteredItems) {
      result.putIfAbsent(item.targetMonth, () => []).add(item);
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  WatchlistLoaded copyWith({
    List<WatchlistItem>? items,
    WatchProgress? progress,
    String? activeFilter,
    bool clearFilter = false,
    int? streak,
  }) {
    return WatchlistLoaded(
      items: items ?? this.items,
      progress: progress ?? this.progress,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      streak: streak ?? this.streak,
    );
  }
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);
}
