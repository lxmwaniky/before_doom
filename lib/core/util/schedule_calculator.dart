import '../../features/watchlist/domain/entities/movie.dart';
import '../constants/app_constants.dart';

class ScheduleCalculator {
  static List<WatchlistItem> assignDynamicSchedule(List<WatchlistItem> items) {
    final now = DateTime.now();
    final doomsday = AppConstants.doomsdayDate;

    if (now.isAfter(doomsday)) return items;

    final monthsRemaining = _monthsBetween(now, doomsday);
    if (monthsRemaining <= 0) return items;

    final watchedItems = items.where((i) => i.isWatched).toList();
    final unwatchedItems = items.where((i) => !i.isWatched).toList();

    final currentMonth = _formatMonth(now);
    final result = watchedItems.map((item) {
      return item.copyWith(targetMonth: currentMonth);
    }).toList();

    if (unwatchedItems.isEmpty) return result;

    final totalMinutes = unwatchedItems.fold(0, (sum, i) => sum + i.runtime);
    final minutesPerMonth = (totalMinutes / monthsRemaining).ceil();

    final daysLeftInMonth = _daysLeftInCurrentMonth(now);
    final currentMonthFraction = daysLeftInMonth / 30.0;
    final currentMonthBudget = (minutesPerMonth * currentMonthFraction).floor();

    var monthOffset = 0;
    var minutesInCurrentMonth = 0;
    var currentBudget = currentMonthBudget;

    for (final item in unwatchedItems) {
      final targetDate = DateTime(now.year, now.month + monthOffset, 1);
      final targetMonth = _formatMonth(targetDate);

      result.add(item.copyWith(targetMonth: targetMonth));

      minutesInCurrentMonth += item.runtime;

      if (minutesInCurrentMonth >= currentBudget) {
        monthOffset++;
        minutesInCurrentMonth = 0;
        currentBudget = minutesPerMonth;
      }
    }

    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  static int _daysLeftInCurrentMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0).day;
    return lastDay - date.day + 1;
  }

  static ScheduleSummary getScheduleSummary(List<WatchlistItem> items) {
    final now = DateTime.now();
    final doomsday = AppConstants.doomsdayDate;
    final daysRemaining = doomsday.difference(now).inDays;

    final unwatchedItems = items.where((i) => !i.isWatched).toList();
    final totalUnwatchedMinutes =
        unwatchedItems.fold(0, (sum, i) => sum + i.runtime);

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
