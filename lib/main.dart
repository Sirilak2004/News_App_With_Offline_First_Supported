// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Theme & Constants
import 'utils/theme.dart';
import 'utils/constants.dart';

// Screens
import 'screens/home_screen.dart';

// ADD THIS IMPORT for OfflineService
import 'services/offline_service.dart';  // ← This was missing!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('ai_cache');
  await Hive.openBox('saved_articles');

  // Initialize Offline Service (now works with import)
  await OfflineService().init();

  // Load theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool(Constants.themeKey) ?? false;

  runApp(SimpleNewsApp(startDark: isDarkMode));
}

class SimpleNewsApp extends StatefulWidget {
  final bool startDark;
  const SimpleNewsApp({super.key, required this.startDark});

  @override
  State<SimpleNewsApp> createState() => _SimpleNewsAppState();
}

class _SimpleNewsAppState extends State<SimpleNewsApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.startDark;
  }

  void toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeChanged: toggleTheme),
    );
  }
}