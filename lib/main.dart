// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/tutorial_screen.dart';
import 'services/database_service.dart';
import 'services/measurement_service.dart';
import 'services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final dbService = DatabaseService();
  await dbService.initialize();
  
  final settingsService = SettingsService();
  await settingsService.init();
  
  // Check if first launch
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('first_launch') ?? true;
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => dbService),
        ChangeNotifierProvider(create: (_) => MeasurementService()),
        ChangeNotifierProvider(create: (_) => settingsService),
      ],
      child: MeasureSnapApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MeasureSnapApp extends StatelessWidget {
  final bool isFirstLaunch;
  
  const MeasureSnapApp({
    super.key,
    required this.isFirstLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'MeasureSnap',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: settings.darkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: isFirstLaunch ? const TutorialWrapper() : const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class TutorialWrapper extends StatelessWidget {
  const TutorialWrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const TutorialScreen();
  }
}