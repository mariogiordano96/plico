import 'dart:async';

import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/diario/aggiunta_alimento_screen.dart';
import 'services/achievement_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await DatabaseService.instance.seedCreaFoods();
  await DatabaseService.instance.seedExercises();
  final isDark = await DatabaseService.instance.getIsDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  await NotificationService.instance.init();
  final settings = await DatabaseService.instance.getAppSettings();
  await NotificationService.instance.scheduleAll(settings);
  await AchievementService.instance.checkAll();
  await NotificationService.instance.refreshEveningRecap();
  await NotificationService.instance.refreshMorningRecap();
  await NotificationService.instance.refreshWeighInReminder();
  await HomeWidget.setAppGroupId(WidgetService.iOSGroupId);
  await WidgetService.refresh();
  runApp(const PlicoApp());
}

/// Slot pasto suggerito in base all'ora corrente, usato quando l'utente apre
/// l'app toccando il widget Home Screen.
int _currentPastoTipo() {
  final hour = DateTime.now().hour;
  if (hour < 10) return 0; // colazione
  if (hour < 15) return 1; // pranzo
  if (hour < 18) return 3; // spuntino
  if (hour < 21) return 2; // cena
  return 3; // spuntino serale
}

class PlicoApp extends StatefulWidget {
  const PlicoApp({super.key});

  @override
  State<PlicoApp> createState() => _PlicoAppState();
}

class _PlicoAppState extends State<PlicoApp> with WidgetsBindingObserver {
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _widgetClickSub = HomeWidget.widgetClicked.listen(_handleWidgetUri);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetUri);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClickSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService.instance.refreshEveningRecap();
      NotificationService.instance.refreshMorningRecap();
      NotificationService.instance.refreshWeighInReminder();
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    if (uri.scheme == 'plico' && uri.host == 'add-meal') {
      await _handleWidgetUri(uri);
      return true;
    }
    return super.didPushRouteInformation(routeInformation);
  }

  Future<void> _handleWidgetUri(Uri? uri) async {
    if (uri == null) return;
    final hasProfile = await DatabaseService.instance.hasUserProfile();
    if (!hasProfile) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AggiuntaAlimentoScreen(
          pastoTipo: _currentPastoTipo(),
          date: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Plico',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            final l10n = AppLocalizations.of(context);
            if (l10n != null) NotificationService.instance.setL10n(l10n);
            return child!;
          },
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
