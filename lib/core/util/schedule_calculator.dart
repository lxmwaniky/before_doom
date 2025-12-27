import '../../features/watchlist/domain/entities/movie.dart';
import '../constants/app_constants.dart';

class ScheduleCalculator {
  /// Calculates dynamic target months for items based on current date
  /// and distributes unwatched items evenly until Doomsday
  static List<WatchlistItem> assignDynamicSchedule(List<WatchlistItem> items) {
    final now = DateTime.now();
    final doomsday = AppConstants.doomsdayDate;

    // If we're past Doomsday, just return items as-is
    if (now.isAfter(doomsday)) return items;

    // Calculate months remaining (including current month)
    final monthsRemaining = _monthsBetween(now, doomsday);
    if (monthsRemaining <= 0) return items;

    // Separate watched and unwatched items
    final watchedItems = items.where((i) => i.isWatched).toList();
    final unwatchedItems = items.where((i) => !i.isWatched).toList();

    // Assign watched items to current month (they're done)
    final currentMonth = _formatMonth(now);
    final result = watchedItems.map((item) {
      return item.copyWith(targetMonth: currentMonth);
    }).toList();

    // Distribute unwatched items evenly across remaining months
    if (unwatchedItems.isEmpty) return result;

    final itemsPerMonth = (unwatchedItems.length / monthsRemaining).ceil();
    var monthOffset = 0;
    var itemsInCurrentMonth = 0;

    for (final item in unwatchedItems) {
      final targetDate = DateTime(now.year, now.month + monthOffset, 1);
      final targetMonth = _formatMonth(targetDate);

      result.add(item.copyWith(targetMonth: targetMonth));

      itemsInCurrentMonth++;
      if (itemsInCurrentMonth >= itemsPerMonth) {
        monthOffset++;
        itemsInCurrentMonth = 0;
      }
    }

    // Sort by original order
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  /// Get schedule summary for display
  static ScheduleSummary getScheduleSummary(List<WatchlistItem> items) {
    final now = DateTime.now();
    final doomsday = AppConstants.doomsdayDate;
    final daysRemaining = doomsday.difference(now).inDays;

    final unwatchedItems = items.where((i) => !i.isWatched).toList();
    final totalUnwatchedMinutes =
        unwatchedItems.fold(0, (sum, i) => sum + i.runtime);

    // Calculate recommended pace
    final itemsPerWeek = daysRemaining > 0
        ? unwatchedItems.length / (daysRemaining / 7.0)
        : 0.0;

    final hoursPerWeek = daysRemaining > 0
        ? totalUnwatchedMinutes / 60.0 / (daysRemaining / 7.0)
        : 0.0;

    return ScheduleSummary(
      itemsRemaining: unwatchedItems.length,
      daysRemaining: daysRemaining,
      itemsPerWeek: itemsPerWeek,
      hoursPerWeek: hoursPerWeek,
    );
  }

  static int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month) + 1;
  }

  static String _formatMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}

class ScheduleSummary {
  final int itemsRemaining;
  final int daysRemaining;
  final double itemsPerWeek;
  final double hoursPerWeek;

  const ScheduleSummary({
    required this.itemsRemaining,
    required this.daysRemaining,
    required this.itemsPerWeek,
    required this.hoursPerWeek,
  });
}
