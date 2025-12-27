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

  // Load environment variables
  // If .env file is missing, app will still work with limited features
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Some features may be limited.');
  }

  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemAdapter());

  await initDependencies();

  // Non-blocking - notifications are optional
  NotificationService().init();

  runApp(const BeforeDoomApp());
}

class BeforeDoomApp extends StatelessWidget {
  const BeforeDoomApp({super.key});

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
