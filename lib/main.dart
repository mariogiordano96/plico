import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await DatabaseService.instance.seedCreaFoods();
  final isDark = await DatabaseService.instance.getIsDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  await NotificationService.instance.init();
  final settings = await DatabaseService.instance.getAppSettings();
  await NotificationService.instance.scheduleAll(settings);
  runApp(const PlicoApp());
}

class PlicoApp extends StatelessWidget {
  const PlicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Plico',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('it', 'IT'),
            Locale('en', 'US'),
          ],
          home: FutureBuilder<bool>(
            future: DatabaseService.instance.hasUserProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00FF88)),
                  ),
                );
              }
              return snapshot.data! ? const MainScreen() : const OnboardingScreen();
            },
          ),
        );
      },
    );
  }
}
