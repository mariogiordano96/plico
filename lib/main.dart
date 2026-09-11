import 'dart:async';

import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/diario/aggiunta_alimento_screen.dart';
import 'services/achievement_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/smartwatch_import_service.dart';
import 'services/widget_service.dart';
import 'utils/locale_utils.dart';
import 'widgets/dismiss_keyboard_on_tap.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
/// Lingua attiva, fissata una volta all'avvio (vedi [_initialLocale])
/// e modificabile solo esplicitamente (es. bandiera debug in HomeScreen).
/// Passata sempre non-null a `MaterialApp.locale` per evitare che l'app
/// segua reattivamente i cambi di lingua di sistema durante la sessione
/// (su iOS, cambiare la lingua della tastiera aggiorna le preferred
/// languages di sistema e farebbe cambiare lingua all'app da sola).
final localeNotifier = ValueNotifier<Locale?>(null);
final navigatorKey = GlobalKey<NavigatorState>();

/// Lingua di sistema al cold start (vedi [resolveInitialLocale]).
Locale _initialLocale() => resolveInitialLocale(
    WidgetsBinding.instance.platformDispatcher.locales, AppLocalizations.supportedLocales);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  localeNotifier.value = _initialLocale();
  await DatabaseService.instance.init();
  await DatabaseService.instance.seedCreaFoods();
  await DatabaseService.instance.migrateFoodNamesV2();
  await DatabaseService.instance.syncFoodNomeInglese();
  await DatabaseService.instance.seedExercises();
  await DatabaseService.instance.syncExerciseNamesIt();
  await DatabaseService.instance.seedWorkoutPresets();
  final isDark = await DatabaseService.instance.getIsDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  await NotificationService.instance.init();
  final settings = await DatabaseService.instance.getAppSettings();
  await NotificationService.instance.scheduleAll(settings);
  await AchievementService.instance.checkAll();
  await NotificationService.instance.refreshEveningRecap();
  await NotificationService.instance.refreshMorningRecap();
  await NotificationService.instance.refreshWeighInReminder();
  await NotificationService.instance.refreshWorkoutReminder();
  await HomeWidget.setAppGroupId(WidgetService.iOSGroupId);
  await WidgetService.refresh();
  // Sync opportunistica: solo quando l'app è già aperta, mai in vero
  // background (docs/integrazione_smartwatch.md, Fase 5 — nessun impatto
  // batteria aggiuntivo, nessuna infrastruttura nativa nuova). Non awaited:
  // non deve ritardare l'avvio dell'app.
  if (settings.smartwatchConnected) {
    unawaited(SmartwatchImportService.instance.importWorkoutSessions(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    ));
  }
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
      NotificationService.instance.refreshWorkoutReminder();
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
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Plico',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          locale: locale,
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
            return DismissKeyboardOnTap(child: child);
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
              return snapshot.data! ? const MainScreen() : const WelcomeScreen();
            },
          ),
        );
          },
        );
      },
    );
  }
}
