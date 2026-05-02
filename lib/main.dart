import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/facts_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  //await prefs.clear(); // Use to clear user
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  runApp(MyApp(showOnboarding: !onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FactsProvider(),
      child: MaterialApp(
        title: 'CommonSense',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          useMaterial3: true,
        ),
        home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
      ),
    );
  }
}
