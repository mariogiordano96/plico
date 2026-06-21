import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import 'achievement_service.dart';
import 'database_service.dart';
import 'streak_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  AppLocalizations? _l10n;

  void setL10n(AppLocalizations l10n) => _l10n = l10n;

  static const _channelId = 'pasti_reminders';
  static const _channelName = 'Promemoria pasti';
  static const _recapChannelId = 'evening_recap';
  static const _recapChannelName = 'Riepilogo serale';
  static const _recapId = 200;
  static const _morningRecapChannelId = 'morning_recap';
  static const _morningRecapChannelName = 'Recap mattutino';
  static const _morningRecapId = 201;
  static const _weighInChannelId = 'weigh_in_reminder';
  static const _weighInChannelName = 'Promemoria pesata';
  static const _weighInId = 202;
  static const _weighInThresholdDays = 5;
  static const _restTimerChannelId = 'rest_timer';
  static const _restTimerChannelName = 'Timer di recupero';
  static const _restTimerId = 210;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  Future<bool> requestPermissions() async {
    bool granted = false;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
      await android.requestExactAlarmsPermission();
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      granted =
          await ios.requestPermissions(alert: true, badge: false, sound: true) ??
              false;
    }
    return granted;
  }

  Future<void> scheduleAll(AppSettings s) async {
    await cancelAll();
    if (!s.notificheAttive) return;

    final meals = [
      (100, _l10n?.pastoColazione ?? 'Colazione', s.notColAttiva, s.notColMin),
      (101, _l10n?.pastoPranzo ?? 'Pranzo', s.notPranzoAttiva, s.notPranzoMin),
      (102, _l10n?.pastoCena ?? 'Cena', s.notCenaAttiva, s.notCenaMin),
      (103, _l10n?.pastoSpuntino ?? 'Spuntino', s.notSpuntinoAttiva, s.notSpuntinoMin),
      (104, _l10n?.pastoPostWo ?? 'Post-WO', s.notPostWoAttiva, s.notPostWoMin),
      (105, _l10n?.pastoSpuntinoSerale ?? 'Spuntino serale', s.notSorAttiva, s.notSorMin),
    ];

    for (final (id, label, active, minVal) in meals) {
      if (!active) continue;
      await _scheduleDaily(id, label, minVal ~/ 60, minVal % 60);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _scheduleDaily(
      int id, String label, int hour, int minute) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _l10n?.notifChannelPasti ?? _channelName,
        channelDescription: _l10n?.notifChannelPastiDesc ?? 'Ricordati di registrare i tuoi pasti',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Plico',
      body: _l10n?.notifPastoBody(label.toLowerCase()) ?? 'Hai registrato ${label.toLowerCase()}?',
      scheduledDate: _nextOccurrence(hour, minute),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> refreshEveningRecap() async {
    final settings = await DatabaseService.instance.getAppSettings();
    if (!settings.notificheAttive) {
      await _plugin.cancel(id: _recapId);
      return;
    }
    final streak = await StreakService.instance.currentStreak();
    final kcalTarget = await AchievementService.instance.currentKcalTarget();
    final now = DateTime.now();
    final log = await DatabaseService.instance
        .getDailyLog(DateTime(now.year, now.month, now.day));
    final pct = kcalTarget != null && kcalTarget > 0 && log != null
        ? log.kcalTotali / kcalTarget
        : null;
    final onTargetToday = pct != null && pct >= 0.9 && pct <= 1.05;
    final loggedToday = log != null && log.entries.isNotEmpty;
    await scheduleEveningRecap(
      streak: streak,
      loggedToday: loggedToday,
      onTargetToday: onTargetToday,
    );
  }

  Future<void> scheduleEveningRecap({
    required int streak,
    required bool loggedToday,
    required bool onTargetToday,
  }) async {
    await _plugin.cancel(id: _recapId);

    final now = tz.TZDateTime.now(tz.local);
    final today21 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);
    if (!today21.isAfter(now.add(const Duration(seconds: 30)))) return;

    final body = streak <= 0
        ? (_l10n?.notifRecapNuovaStreak ?? 'Registra i tuoi pasti di oggi per iniziare una nuova streak.')
        : !loggedToday
            ? (_l10n?.notifRecapMantieni(streak) ?? 'Hai registrato ogni giorno per $streak giorni. Vuoi mantenere la streak? 🔥')
            : onTargetToday
                ? (_l10n?.notifRecapObiettivo(streak) ?? 'Oggi hai raggiunto il tuo obiettivo per $streak giorni di fila 🔥')
                : (_l10n?.notifRecapStreak(streak) ?? 'Hai registrato $streak giorni di fila! Continua così 💪');

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _recapChannelId,
        _l10n?.notifChannelRecap ?? _recapChannelName,
        channelDescription: _l10n?.notifChannelRecapDesc ?? 'Riepilogo serale dei tuoi progressi',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: _recapId,
      title: 'Plico',
      body: body,
      scheduledDate: today21,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> refreshMorningRecap() async {
    final settings = await DatabaseService.instance.getAppSettings();
    if (!settings.notificheAttive) {
      await _plugin.cancel(id: _morningRecapId);
      return;
    }
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final log = await DatabaseService.instance.getDailyLog(yesterday);
    if (log == null || log.entries.isEmpty) {
      await _plugin.cancel(id: _morningRecapId);
      return;
    }
    final kcalTarget = await AchievementService.instance.currentKcalTarget();
    await scheduleMorningRecap(kcalYesterday: log.kcalTotali, kcalTarget: kcalTarget);
  }

  Future<void> scheduleMorningRecap({
    required double kcalYesterday,
    required int? kcalTarget,
  }) async {
    await _plugin.cancel(id: _morningRecapId);

    final now = tz.TZDateTime.now(tz.local);
    final today8 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8, 0);
    if (!today8.isAfter(now.add(const Duration(seconds: 30)))) return;

    final kcal = kcalYesterday.round();
    final pct = kcalTarget != null && kcalTarget > 0
        ? kcalYesterday / kcalTarget
        : null;
    final onTarget = pct != null && pct >= 0.9 && pct <= 1.05;
    final body = kcalTarget != null
        ? onTarget
            ? (_l10n?.notifMattinoOnTarget(kcal, kcalTarget) ?? 'Ieri hai mangiato $kcal kcal su $kcalTarget. Ottimo lavoro! 💪')
            : (_l10n?.notifMattinoOffTarget(kcal, kcalTarget) ?? 'Ieri hai registrato $kcal kcal su $kcalTarget di obiettivo.')
        : (_l10n?.notifMattinoNoTarget(kcal) ?? 'Ieri hai registrato $kcal kcal.');

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _morningRecapChannelId,
        _l10n?.notifChannelMattino ?? _morningRecapChannelName,
        channelDescription: _l10n?.notifChannelMattinoDesc ?? 'Riepilogo delle calorie di ieri',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: _morningRecapId,
      title: 'Plico',
      body: body,
      scheduledDate: today8,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> refreshWeighInReminder() async {
    final settings = await DatabaseService.instance.getAppSettings();
    if (!settings.notificheAttive) {
      await _plugin.cancel(id: _weighInId);
      return;
    }
    final latest = await DatabaseService.instance.getLatestBodySnapshot();
    if (latest == null) {
      await _plugin.cancel(id: _weighInId);
      return;
    }
    final today = DateTime.now();
    final lastDay = DateTime(latest.data.year, latest.data.month, latest.data.day);
    final daysSince =
        DateTime(today.year, today.month, today.day).difference(lastDay).inDays;
    if (daysSince < _weighInThresholdDays) {
      await _plugin.cancel(id: _weighInId);
      return;
    }
    await scheduleWeighInReminder(daysSince: daysSince);
  }

  Future<void> scheduleWeighInReminder({required int daysSince}) async {
    await _plugin.cancel(id: _weighInId);

    final now = tz.TZDateTime.now(tz.local);
    final today19 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 0);
    if (!today19.isAfter(now.add(const Duration(seconds: 30)))) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _weighInChannelId,
        _l10n?.notifChannelPesata ?? _weighInChannelName,
        channelDescription: _l10n?.notifChannelPesataDesc ?? 'Ricordati di registrare il tuo peso',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: _weighInId,
      title: 'Plico',
      body: _l10n?.notifPesataBody(daysSince) ?? 'Non ti pesi da $daysSince giorni. Vuoi registrare il tuo peso?',
      scheduledDate: today19,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Notifica locale one-shot a fine riposo, così l'utente è avvisato anche se ha
  /// cambiato schermata o l'app è in background (analogo a un timer di cottura).
  /// Va cancellata (`cancelRestTimer`) se l'utente salta o modifica il riposo prima
  /// che scada da sola.
  Future<void> scheduleRestTimer(Duration remaining) async {
    await _plugin.cancel(id: _restTimerId);
    if (remaining <= Duration.zero) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _restTimerChannelId,
        _l10n?.notifChannelRestTimer ?? _restTimerChannelName,
        channelDescription:
            _l10n?.notifChannelRestTimerDesc ?? 'Avviso a fine riposo tra le serie',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: _restTimerId,
      title: 'Plico',
      body: _l10n?.notifRestTimerBody ?? 'Riposo terminato — pronto per la prossima serie?',
      scheduledDate: tz.TZDateTime.now(tz.local).add(remaining),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelRestTimer() => _plugin.cancel(id: _restTimerId);

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now.add(const Duration(seconds: 30)))) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }
}
