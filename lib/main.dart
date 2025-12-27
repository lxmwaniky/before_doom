import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/theme/theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/watchlist/domain/entities/movie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemAdapter());

  await initDependencies();

  runApp(const BeforeDoomApp());
}

class BeforeDoomApp extends StatelessWidget {
  const BeforeDoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Before Doom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
