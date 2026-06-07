import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_settings.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pasti_reminders';
  static const _channelName = 'Promemoria pasti';

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

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now.add(const Duration(seconds: 30)))) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }
}
