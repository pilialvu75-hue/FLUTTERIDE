import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/database/hive_database.dart';
import 'ui/screens/dashboard_screen.dart';

Future<void> main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local database (Hive) — fully offline, no network needed
  await HiveDatabase.init();

  runApp(const MobileIdeApp());
}

class MobileIdeApp extends StatefulWidget {
  const MobileIdeApp({super.key});

  @override
  State<MobileIdeApp> createState() => _MobileIdeAppState();
}

class _MobileIdeAppState extends State<MobileIdeApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobileIde',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: DashboardScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
