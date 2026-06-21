import 'database_service.dart';

class StreakService {
  static final StreakService instance = StreakService._();
  StreakService._();

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  int _streakFromLoggedDays(Set<DateTime> loggedDays) {
    var cursor = _dayStart(DateTime.now());
    if (!loggedDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (loggedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> currentStreak() async {
    final today = _dayStart(DateTime.now());
    final logs = await DatabaseService.instance
        .getDailyLogsRange(today.subtract(const Duration(days: 365)), today);
    final loggedDays = logs
        .where((l) => l.entries.isNotEmpty)
        .map((l) => _dayStart(l.data))
        .toSet();
    return _streakFromLoggedDays(loggedDays);
  }

  Stream<int> watchCurrentStreak() {
    return DatabaseService.instance.watchDailyLogs().map((logs) {
      final loggedDays = logs
          .where((l) => l.entries.isNotEmpty)
          .map((l) => _dayStart(l.data))
          .toSet();
      return _streakFromLoggedDays(loggedDays);
    });
  }

  Future<int> currentWorkoutStreak() async {
    final today = _dayStart(DateTime.now());
    final days = await DatabaseService.instance
        .getWorkoutDaysRange(today.subtract(const Duration(days: 365)), today);
    return _streakFromLoggedDays(days);
  }

  Stream<int> watchCurrentWorkoutStreak() {
    return DatabaseService.instance
        .watchWorkoutDays()
        .map((days) => _streakFromLoggedDays(days));
  }
}
