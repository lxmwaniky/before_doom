import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/watchlist/domain/entities/movie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemAdapter());

  await initDependencies();

  // Initialize notifications
  await NotificationService().init();

  runApp(const BeforeDoomApp());
}

class BeforeDoomApp extends StatefulWidget {
  const BeforeDoomApp({super.key});

  @override
  State<BeforeDoomApp> createState() => _BeforeDoomAppState();
}

class _BeforeDoomAppState extends State<BeforeDoomApp> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissionOnFirstLaunch();
  }

  Future<void> _requestNotificationPermissionOnFirstLaunch() async {
    final box = await Hive.openBox('app_settings');
    final hasRequestedPermission = box.get(
      'notification_permission_requested',
      defaultValue: false,
    );

    if (!hasRequestedPermission) {
      await Future.delayed(const Duration(seconds: 2));
      final notificationService = NotificationService();
      final granted = await notificationService.requestPermission();
      await box.put('notification_permission_requested', true);

      // Auto-enable daily reminder at 8 PM if permission granted
      if (granted) {
        await notificationService.scheduleDailyReminder(hour: 20, minute: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Before Doom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
