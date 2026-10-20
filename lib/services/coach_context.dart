import '../models/app_settings.dart';
import '../models/body_snapshot.dart';
import '../models/daily_log.dart';
import '../models/meal_plan.dart';
import '../models/personal_record.dart';
import 'database_service.dart';
import 'target_service.dart';

/// Snapshot dei dati dell'utente che il Coach riceve come contesto
/// (docs/integrazione_flutter_gemma.md, Fase 8). Niente function calling:
/// ogni tool call sarebbe una richiesta in più sulla quota free tier della
/// chiave dell'utente, quindi i dati si leggono in locale PRIMA della
/// richiesta e si scrivono nel system prompt come testo.
class CoachContextData {
  final DateTime now;
  final int obiettivo; // AppSettings.obiettivo
  final double? pesoObiettivo;
  final (int?, int?, int?, int?) targets; // kcal, proteine, grassi, carbo
  final List<BodySnapshot> recentSnapshots; // dal più recente
  final DailyLog? todayLog;
  final int workoutKcalToday;
  final MealPlan? plan;
  final Map<String, double> weeklyVolume;
  final List<PersonalRecord> personalRecords;

  const CoachContextData({
    required this.now,
    required this.obiettivo,
    required this.pesoObiettivo,
    required this.targets,
    required this.recentSnapshots,
    required this.todayLog,
    required this.workoutKcalToday,
    required this.plan,
    required this.weeklyVolume,
    required this.personalRecords,
  });
}

class CoachContext {
  static const maxSnapshots = 5;
  static const maxRecords = 8;

  static const _pasti = {
    0: ('Colazione', 'Breakfast'),
    1: ('Pranzo', 'Lunch'),
    2: ('Cena', 'Dinner'),
    3: ('Spuntino', 'Snack'),
    4: ('Spuntino post-allenamento', 'Post-workout snack'),
    5: ('Spuntino serale', 'Evening snack'),
  };
  static const _obiettivi = [
    ('deficit calorico', 'calorie deficit'),
    ('mantenimento', 'maintenance'),
    ('surplus calorico', 'calorie surplus'),
  ];

  /// Legge i dati da [DatabaseService]; ogni sezione è indipendente, un errore
  /// su una non deve togliere il Coach all'utente.
  static Future<CoachContextData> load({DateTime? now}) async {
    final db = DatabaseService.instance;
    final today = now ?? DateTime.now();
    final AppSettings settings = await db.getAppSettings();
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final snapshots = await db.getBodySnapshots();
    snapshots.sort((a, b) => b.data.compareTo(a.data));
    final records = await db.getAllPersonalRecords();
    return CoachContextData(
      now: today,
      obiettivo: settings.obiettivo,
      pesoObiettivo: settings.pesoObiettivo,
      targets: await computeDailyTargets(),
      recentSnapshots: snapshots.take(maxSnapshots).toList(),
      todayLog: await db.getDailyLog(today),
      workoutKcalToday: await db.getWorkoutKcalForDay(today),
      plan: await db.getMealPlan(),
      weeklyVolume: await db.getWeeklyVolumeByMuscleGroup(monday),
      personalRecords: records.take(maxRecords).toList(),
    );
  }

  /// Testo da accodare al system prompt. Stringa vuota se non c'è nessun dato.
  static String build(CoachContextData d, {required bool isItalian}) {
    String t(String it, String en) => isItalian ? it : en;
    final lines = <String>[];

    final obiettivo = _obiettivi[d.obiettivo.clamp(0, 2)];
    final (kcal, prot, fat, carb) = d.targets;
    lines.add(t('Obiettivo: ${obiettivo.$1}', 'Goal: ${obiettivo.$2}') +
        (d.pesoObiettivo != null
            ? t(', peso obiettivo ${_n(d.pesoObiettivo!)} kg', ', target weight ${_n(d.pesoObiettivo!)} kg')
            : ''));
    if (kcal != null) {
      lines.add(t(
          'Target giornaliero: $kcal kcal, P ${prot}g, G ${fat}g, C ${carb}g',
          'Daily target: $kcal kcal, P ${prot}g, F ${fat}g, C ${carb}g'));
    }

    if (d.recentSnapshots.isNotEmpty) {
      final s = d.recentSnapshots.map((s) => '${_date(s.data)}: ${_n(s.pesoKg)} kg').join('; ');
      lines.add(t('Peso (dal più recente): $s', 'Weight (most recent first): $s'));
    }

    final log = d.todayLog;
    if (log != null && log.entries.isNotEmpty) {
      lines.add(t(
          'Oggi ha mangiato: ${log.kcalTotali.round()} kcal, P ${log.proteinTotali.round()}g, '
              'G ${log.fatTotali.round()}g, C ${log.carbsTotali.round()}g',
          'Eaten today: ${log.kcalTotali.round()} kcal, P ${log.proteinTotali.round()}g, '
              'F ${log.fatTotali.round()}g, C ${log.carbsTotali.round()}g'));
    } else {
      lines.add(t('Oggi non ha ancora registrato pasti.', 'No meals logged yet today.'));
    }
    if (d.workoutKcalToday > 0) {
      lines.add(t('Kcal bruciate in allenamento oggi: ${d.workoutKcalToday}',
          'Kcal burned in training today: ${d.workoutKcalToday}'));
    }

    final plan = d.plan;
    if (plan != null && plan.pasti.isNotEmpty) {
      lines.add(t(
          'Piano alimentare attivo (${plan.kcalTotali.round()} kcal/giorno'
              '${plan.obsoleto ? ', segnato come obsoleto' : ''}):',
          'Active meal plan (${plan.kcalTotali.round()} kcal/day'
              '${plan.obsoleto ? ', flagged as outdated' : ''}):'));
      for (final meal in plan.pasti) {
        final name = _pasti[meal.tipo];
        final foods = [
          for (final s in meal.slots)
            if (s.principale != null)
              '${s.principale!.nome} ${s.principale!.quantitaG.round()}g',
        ];
        if (foods.isEmpty) continue;
        lines.add('- ${name == null ? '?' : t(name.$1, name.$2)}: ${foods.join(', ')}');
      }
    }

    if (d.weeklyVolume.isNotEmpty) {
      final v = (d.weeklyVolume.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .map((e) => '${e.key} ${e.value.round()}')
          .join(', ');
      lines.add(t('Volume allenamento questa settimana (kg totali sollevati) per gruppo: $v',
          'Training volume this week (total kg lifted) by muscle group: $v'));
    }

    if (d.personalRecords.isNotEmpty) {
      final r = d.personalRecords
          .map((r) => '${r.exerciseName} ${_n(r.maxWeightKg)} kg (${_date(r.achievedAt)})')
          .join('; ');
      lines.add(t('Record personali recenti: $r', 'Recent personal records: $r'));
    }

    if (lines.isEmpty) return '';
    final header = t(
        'Dati dell\'utente (oggi è ${_date(d.now)}). Usali per rispondere in modo '
            'personalizzato, senza inventare dati che non compaiono qui; se un dato manca, dillo. '
            'Quando citi quantità del piano, rispetta le grammature indicate.',
        'User data (today is ${_date(d.now)}). Use it to personalise answers, without '
            'inventing data that is not listed here; if something is missing, say so. '
            'When quoting plan quantities, keep the grams given.');
    return '$header\n${lines.join('\n')}';
  }

  static String _n(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
