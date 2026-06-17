import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';
import 'achievement_service.dart';
import 'database_service.dart';
import 'streak_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pasti_reminders';
  static const _channelName = 'Promemoria pasti';
  static const _recapChannelId = 'evening_recap';
  static const _recapChannelName = 'Riepilogo serale';
  static const _recapId = 200;

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
      (100, 'Colazione', s.notColAttiva, s.notColMin),
      (101, 'Pranzo', s.notPranzoAttiva, s.notPranzoMin),
      (102, 'Cena', s.notCenaAttiva, s.notCenaMin),
      (103, 'Spuntino', s.notSpuntinoAttiva, s.notSpuntinoMin),
      (104, 'Post-WO', s.notPostWoAttiva, s.notPostWoMin),
      (105, 'Spuntino serale', s.notSorAttiva, s.notSorMin),
    ];

    for (final (id, label, active, minVal) in meals) {
      if (!active) continue;
      await _scheduleDaily(id, label, minVal ~/ 60, minVal % 60);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _scheduleDaily(
      int id, String label, int hour, int minute) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Ricordati di registrare i tuoi pasti',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Plico',
      body: 'Hai registrato ${label.toLowerCase()}?',
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
    await scheduleEveningRecap(streak: streak, onTargetToday: onTargetToday);
  }

  Future<void> scheduleEveningRecap(
      {required int streak, required bool onTargetToday}) async {
    await _plugin.cancel(id: _recapId);

    final now = tz.TZDateTime.now(tz.local);
    final today21 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);
    if (!today21.isAfter(now.add(const Duration(seconds: 30)))) return;

    final body = streak <= 0
        ? 'Registra i tuoi pasti di oggi per iniziare una nuova streak.'
        : onTargetToday
            ? 'Oggi hai raggiunto il tuo obiettivo per $streak giorni di fila 🔥'
            : 'Hai una streak di $streak giorni: non lasciarla cadere oggi!';

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _recapChannelId,
        _recapChannelName,
        channelDescription: 'Riepilogo serale dei tuoi progressi',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
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

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now.add(const Duration(seconds: 30)))) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }
}
