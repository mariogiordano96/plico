import '../models/achievement.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;
import 'database_service.dart';
import 'streak_service.dart';

class AchievementService {
  static final AchievementService instance = AchievementService._();
  AchievementService._();

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<int?> currentKcalTarget() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    if (profile == null || snapshot == null) return null;
    final session = await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    final obiettivo = await DatabaseService.instance.getObiettivo();
    final result = calcolaTdee(
      sesso: profile.sesso,
      eta: profile.etaCorrente,
      altezzaCm: profile.altezzaCm,
      pesoKg: snapshot.pesoKg,
      livello: livello,
      metodo: metodo,
      massaMagraKg: session?.risultati.massaMagraKg,
    );
    if (result == null) return null;
    const goalMult = [0.80, 1.0, 1.15];
    return (result.tdee * goalMult[obiettivo.clamp(0, 2)]).round();
  }

  Future<void> checkAll({bool hasNewWorkoutPr = false}) async {
    await _checkFirstKgLost();
    await _checkStreak7();
    await _checkDays30Logged();
    await _checkWeekOnTarget();
    await _checkFirstWorkout();
    await _checkWorkoutStreak7();
    await _checkWorkoutSessions();
    if (hasNewWorkoutPr) {
      await DatabaseService.instance.unlockAchievement(AchievementType.newWorkoutPr);
    }
  }

  Future<void> _checkFirstKgLost() async {
    final snapshots = await DatabaseService.instance.getBodySnapshots(); // desc
    if (snapshots.length < 2) return;
    final earliest = snapshots.last;
    final latest = snapshots.first;
    if (earliest.pesoKg - latest.pesoKg >= 1.0) {
      await DatabaseService.instance.unlockAchievement(AchievementType.firstKgLost);
    }
  }

  Future<void> _checkStreak7() async {
    final streak = await StreakService.instance.currentStreak();
    if (streak >= 7) {
      await DatabaseService.instance.unlockAchievement(AchievementType.streak7);
    }
  }

  Future<void> _checkDays30Logged() async {
    final today = _dayStart(DateTime.now());
    final logs = await DatabaseService.instance
        .getDailyLogsRange(today.subtract(const Duration(days: 730)), today);
    final loggedDays = logs.where((l) => l.entries.isNotEmpty).length;
    if (loggedDays >= 30) {
      await DatabaseService.instance.unlockAchievement(AchievementType.days30Logged);
    }
  }

  Future<void> _checkWeekOnTarget() async {
    final kcalTarget = await currentKcalTarget();
    if (kcalTarget == null || kcalTarget <= 0) return;
    final today = _dayStart(DateTime.now());
    final logs = await DatabaseService.instance
        .getDailyLogsRange(today.subtract(const Duration(days: 6)), today);
    final byDay = {for (final l in logs) _dayStart(l.data): l};
    for (var i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      final log = byDay[day];
      if (log == null) return;
      final pct = log.kcalTotali / kcalTarget;
      if (pct < 0.9 || pct > 1.05) return;
    }
    await DatabaseService.instance.unlockAchievement(AchievementType.weekOnTarget);
  }

  Future<void> _checkFirstWorkout() async {
    final count = await DatabaseService.instance.getTotalWorkoutSessionsCount();
    if (count >= 1) {
      await DatabaseService.instance.unlockAchievement(AchievementType.firstWorkout);
    }
  }

  Future<void> _checkWorkoutStreak7() async {
    final streak = await StreakService.instance.currentWorkoutStreak();
    if (streak >= 7) {
      await DatabaseService.instance.unlockAchievement(AchievementType.workoutStreak7);
    }
  }

  Future<void> _checkWorkoutSessions() async {
    final count = await DatabaseService.instance.getTotalWorkoutSessionsCount();
    if (count >= 10) {
      await DatabaseService.instance.unlockAchievement(AchievementType.workoutSessions10);
    }
    if (count >= 50) {
      await DatabaseService.instance.unlockAchievement(AchievementType.workoutSessions50);
    }
  }
}
