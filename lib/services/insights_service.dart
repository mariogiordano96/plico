import '../models/daily_log.dart';
import 'achievement_service.dart';
import 'database_service.dart';

const _giorniSettimana = [
  'lunedì',
  'martedì',
  'mercoledì',
  'giovedì',
  'venerdì',
  'sabato',
  'domenica',
];

const _pastiSerali = {2, 4, 5}; // cena, post-WO, spuntino serale

class InsightsService {
  static final InsightsService instance = InsightsService._();
  InsightsService._();

  static const _overshootDays = 28;
  static const _minOccorrenze = 3;
  static const _overshootRatio = 2 / 3;
  static const _overshootMargin = 1.15;

  static const _proteinDays = 14;
  static const _minLoggedDaysProtein = 7;
  static const _proteinRatio = 0.7;
  static const _proteinMargin = 0.9;

  Future<List<String>> generate() async {
    final insights = <String>[];

    final overshoot = await _overshootInsight();
    if (overshoot != null) insights.add(overshoot);

    final protein = await _proteinInsight();
    if (protein != null) insights.add(protein);

    return insights;
  }

  Future<String?> _overshootInsight() async {
    final target = await AchievementService.instance.currentKcalTarget();
    if (target == null) return null;

    final to = DateTime.now();
    final from = to.subtract(const Duration(days: _overshootDays));
    final logs = await DatabaseService.instance.getDailyLogsRange(from, to);
    final loggedDays = logs.where((l) => l.entries.isNotEmpty).toList();

    final byWeekday = <int, List<DailyLog>>{};
    for (final log in loggedDays) {
      byWeekday.putIfAbsent(log.data.weekday, () => []).add(log);
    }

    for (final entry in byWeekday.entries) {
      final days = entry.value;
      if (days.length < _minOccorrenze) continue;

      final overDays =
          days.where((l) => l.kcalTotali > target * _overshootMargin).toList();
      if (overDays.length / days.length < _overshootRatio) continue;

      final eveningDriven = overDays.where((l) {
        final eveningKcal = l.entries
            .where((e) => _pastiSerali.contains(e.pastoTipo))
            .fold<double>(0, (s, e) => s + e.kcal);
        return l.kcalTotali > 0 && eveningKcal / l.kcalTotali >= 0.5;
      }).length;

      final giorno = _giorniSettimana[entry.key - 1];
      final isEvening = eveningDriven / overDays.length >= 0.5;
      return isEvening
          ? 'Tendi a sforare il $giorno sera'
          : 'Tendi a sforare il $giorno';
    }
    return null;
  }

  Future<String?> _proteinInsight() async {
    final plan = await DatabaseService.instance.getMealPlan();
    if (plan == null || plan.proteineTotali <= 0) return null;

    final to = DateTime.now();
    final from = to.subtract(const Duration(days: _proteinDays));
    final logs = await DatabaseService.instance.getDailyLogsRange(from, to);
    final loggedDays = logs.where((l) => l.entries.isNotEmpty).toList();
    if (loggedDays.length < _minLoggedDaysProtein) return null;

    final underTarget = loggedDays
        .where((l) => l.proteinTotali < plan.proteineTotali * _proteinMargin)
        .length;
    if (underTarget / loggedDays.length < _proteinRatio) return null;

    return 'La tua proteina è costantemente sotto target.';
  }
}
