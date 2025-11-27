import 'package:flutter/material.dart';
import 'services/prefs_service.dart';
import 'screens/splash_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/policy_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';

final prefsService = PrefsService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prefsService.init();
  runApp(const SafeCookApp());
}

class SafeCookApp extends StatelessWidget {
  const SafeCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);
    const gray = Color(0xFF374151);
    const cream = Color(0xFFFEF3C7);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: red,
        primary: red,
        secondary: gray,
        background: cream,
      ),
      scaffoldBackgroundColor: cream,
    );

    return MaterialApp(
      title: 'SafeCook',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/policy': (_) => const PolicyPage(),
        '/home': (_) => const HomePage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
