import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _reminderBoxKey = 'reminder_settings';
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _reminderHourKey = 'reminder_hour';
  static const String _reminderMinuteKey = 'reminder_minute';

  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
      return false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {}

  Future<bool> requestPermission() async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }

      if (Platform.isAndroid) {
        final android = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? false;
      } else if (Platform.isIOS) {
        final ios = _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return false;
    } catch (e) {
      debugPrint('NotificationService.requestPermission failed: $e');
      return false;
    }
  }

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? nextMovieTitle,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }

      await cancelReminder();

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const title = 'Time to Watch!';
      final body = nextMovieTitle != null
          ? 'Continue your MCU journey with $nextMovieTitle'
          : 'Your MCU rewatch awaits. Doomsday is coming!';

      await _notifications.zonedSchedule(
        0,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'watch_reminder',
            'Watch Reminders',
            channelDescription: 'Daily reminders to continue your MCU rewatch',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFE23636),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      await _saveReminderSettings(true, hour, minute);
      return true;
    } catch (e) {
      debugPrint('NotificationService.scheduleDailyReminder failed: $e');
      return false;
    }
  }

  Future<bool> cancelReminder() async {
    try {
      if (_isInitialized) {
        await _notifications.cancel(0);
      }
      await _saveReminderSettings(false, 0, 0);
      return true;
    } catch (e) {
      debugPrint('NotificationService.cancelReminder failed: $e');
      return false;
    }
  }

  Future<void> _saveReminderSettings(
      bool enabled, int hour, int minute) async {
    try {
      final box = await Hive.openBox(_reminderBoxKey);
      await box.put(_reminderEnabledKey, enabled);
      await box.put(_reminderHourKey, hour);
      await box.put(_reminderMinuteKey, minute);
    } catch (e) {
      debugPrint('NotificationService._saveReminderSettings failed: $e');
    }
  }

  Future<ReminderSettings> getReminderSettings() async {
    try {
      final box = await Hive.openBox(_reminderBoxKey);
      return ReminderSettings(
        enabled: box.get(_reminderEnabledKey, defaultValue: false),
        hour: box.get(_reminderHourKey, defaultValue: 20),
        minute: box.get(_reminderMinuteKey, defaultValue: 0),
      );
    } catch (e) {
      debugPrint('NotificationService.getReminderSettings failed: $e');
      return const ReminderSettings(enabled: false, hour: 20, minute: 0);
    }
  }

  Future<bool> showTestNotification() async {
    try {
      if (!_isInitialized) {
        final initialized = await init();
        if (!initialized) return false;
      }

      await _notifications.show(
        99,
        'Test Notification',
        'Watch reminders are working!',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'watch_reminder',
            'Watch Reminders',
            channelDescription: 'Daily reminders to continue your MCU rewatch',
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFFE23636),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('NotificationService.showTestNotification failed: $e');
      return false;
    }
  }
}

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
