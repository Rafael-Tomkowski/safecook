import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/prefs_service.dart';
import 'screens/splash_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/policy_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';
import 'screens/login_page.dart';

final prefsService = PrefsService();

// Controlador global de tema
late AppTheme appTheme;

class AppTheme extends ChangeNotifier {
  ThemeMode themeMode;

  AppTheme({required bool isDark})
      : themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  void setDarkMode(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    prefsService.setDarkMode(isDark);
    notifyListeners();
  }

  bool get isDark => themeMode == ThemeMode.dark;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tcjdvvwiyysvamraqtvm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjamR2dndpeXlzdmFtcmFxdHZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NjcxODcsImV4cCI6MjA4MDQ0MzE4N30.rbYnom59KmyIUTlqle5YxqqUKMDhPsSpgDHY5E9gTdo',
  );

  await prefsService.init();

  final isDark = prefsService.isDarkMode();
  appTheme = AppTheme(isDark: isDark);

  runApp(const SafeCookApp());
}

class SafeCookApp extends StatelessWidget {
  const SafeCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);
    const gray = Color(0xFF374151);
    const cream = Color(0xFFFEF3C7);

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: red,
        primary: red,
        secondary: gray,
        surface: cream,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: gray,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: red,
        primary: red,
        secondary: cream,
        surface: const Color(0xFF020617),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF020617),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF020617),
        foregroundColor: Colors.white,
      ),
    );

    return AnimatedBuilder(
      animation: appTheme,
      builder: (context, _) {
        return MaterialApp(
          title: 'SafeCook',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: appTheme.themeMode,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashPage(),
            '/login': (_) => const LoginPage(),
            '/onboarding': (_) => const OnboardingPage(),
            '/policy': (_) => const PolicyPage(),
            '/home': (_) => const HomePage(),
            '/settings': (_) => const SettingsPage(),
          },
        );
      },
    );
  }
}
