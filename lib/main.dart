import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'providers/pantry_provider.dart';
import 'providers/potion_provider.dart';
import 'providers/theme_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
// import 'presentation/widgets/navigation/bottom_nav_bar.dart';

// For widget tests compatibility
class MyApp extends CauldronApp {
  const MyApp({super.key});
}

void main() {
  runApp(const CauldronApp());
}

class CauldronApp extends StatelessWidget {
  const CauldronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
        ChangeNotifierProvider(create: (_) => PotionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Cauldron',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
          },
          // If you want to use a custom bottom nav bar, you can set home:
          // home: BottomNavBar(),
        ),
      ),
    );
  }
}
