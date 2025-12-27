import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

abstract class StreakService {
  Future<int> getCurrentStreak();
  Future<void> recordWatchActivity();
  Future<DateTime?> getLastWatchDate();
}

class StreakServiceImpl implements StreakService {
  static const String _boxName = 'streaks';
  static const String _lastWatchKey = 'lastWatchDate';
  static const String _streakKey = 'currentStreak';

  Future<Box<dynamic>> get _box async => Hive.openBox(_boxName);

  @override
  Future<int> getCurrentStreak() async {
    try {
      final box = await _box;
      final lastWatchDate = await getLastWatchDate();

      if (lastWatchDate == null) return 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastWatch = DateTime(
        lastWatchDate.year,
        lastWatchDate.month,
        lastWatchDate.day,
      );

      final difference = today.difference(lastWatch).inDays;

      if (difference > 1) {
        await box.put(_streakKey, 0);
        return 0;
      }

      return box.get(_streakKey, defaultValue: 0) as int;
    } catch (e) {
      debugPrint('StreakService.getCurrentStreak failed: $e');
      return 0;
    }
  }

  @override
  Future<void> recordWatchActivity() async {
    try {
      final box = await _box;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastWatchDate = await getLastWatchDate();

      if (lastWatchDate != null) {
        final lastWatch = DateTime(
          lastWatchDate.year,
          lastWatchDate.month,
          lastWatchDate.day,
        );
        final difference = today.difference(lastWatch).inDays;

        if (difference == 0) {
          return;
        } else if (difference == 1) {
          final currentStreak = box.get(_streakKey, defaultValue: 0) as int;
          await box.put(_streakKey, currentStreak + 1);
        } else {
          await box.put(_streakKey, 1);
        }
      } else {
        await box.put(_streakKey, 1);
      }

      await box.put(_lastWatchKey, now.toIso8601String());
    } catch (e) {
      debugPrint('StreakService.recordWatchActivity failed: $e');
    }
  }

  @override
  Future<DateTime?> getLastWatchDate() async {
    try {
      final box = await _box;
      final dateStr = box.get(_lastWatchKey) as String?;

      if (dateStr == null) return null;

      return DateTime.tryParse(dateStr);
    } catch (e) {
      debugPrint('StreakService.getLastWatchDate failed: $e');
      return null;
    }
  }
}
