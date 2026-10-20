import '../models/body_snapshot.dart';
import '../models/daily_log.dart';
import '../models/meal_plan.dart';
import '../models/user_food_preferences.dart';
import '../models/workout_exercise.dart';
import 'coach_context.dart';
import 'database_service.dart';
import 'target_service.dart';
import 'workout_progress_service.dart';

/// Perché un'azione a bottone del Coach non è disponibile. Il testo
/// localizzato lo sceglie la UI: qui solo i codici, così la soglia resta
/// testabile senza dipendere da `AppLocalizations`.
enum CoachGateReason { noProfile, noWeight, noQuestionnaire, fewSessions, noPlan }

class CoachGate {
  final List<CoachGateReason> missing;
  final int? sessions; // per fewSessions: quante ce ne sono, quante servono sono in CoachHistory
  const CoachGate(this.missing, {this.sessions});
  bool get enabled => missing.isEmpty;
}

/// Contesto delle azioni a bottone del Coach (docs/integrazione_flutter_gemma.md,
/// Fase 8, revisione 2026-10): finestra, soglie e formato sono decisi qui, in
/// modo deterministico, non dal modello. Tutte le funzioni `gate*`/`build*`
/// sono pure; `load*` le alimenta da [DatabaseService].
class CoachHistory {
  static const windowDays = 90;
  static const minWorkoutSessions = 6;
  static const minDiaryDays = 14;
  static const maxExercises = 30;

  static const _livelli = [
    ('sedentario', 'sedentary'),
    ('leggermente attivo', 'lightly active'),
    ('moderatamente attivo', 'moderately active'),
    ('molto attivo', 'very active'),
    ('atleta', 'athlete'),
  ];
  static const _obiettivi = [
    ('deficit calorico', 'calorie deficit'),
    ('mantenimento', 'maintenance'),
    ('surplus calorico', 'calorie surplus'),
  ];

  // ── Soglie ────────────────────────────────────────────────

  static bool isDone(WorkoutExercise e) => WorkoutProgressService.hasConfirmedWork(e);

  /// Giorni distinti con almeno un esercizio di forza realmente svolto.
  static int workoutSessions(List<WorkoutExercise> exercises) =>
      exercises.where(isDone).map((e) => e.date).toSet().length;

  static CoachGate gateWorkout(List<WorkoutExercise> exercises) {
    final n = workoutSessions(exercises);
    return CoachGate(n < minWorkoutSessions ? [CoachGateReason.fewSessions] : [], sessions: n);
  }

  static CoachGate gateNutrition({
    required bool hasProfile,
    required bool hasWeight,
    required UserFoodPreferences? prefs,
  }) =>
      CoachGate([
        if (!hasProfile) CoachGateReason.noProfile,
        if (!hasWeight) CoachGateReason.noWeight,
        if (prefs == null || !prefs.questionarioCompletato) CoachGateReason.noQuestionnaire,
      ]);

  static CoachGate gateRecipes(MealPlan? plan) =>
      CoachGate(plan == null || plan.pasti.isEmpty ? [CoachGateReason.noPlan] : []);

  // ── Aggregazioni ──────────────────────────────────────────

  static DateTime weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  static String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _n(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  static double? _maxWorkWeight(WorkoutExercise e) {
    final w = e.sets
        .where((s) => !s.isWarmup && s.confirmed)
        .map((s) => s.weightKg)
        .whereType<double>();
    return w.isEmpty ? null : w.reduce((a, b) => a > b ? a : b);
  }

  static List<String> weightLines(List<BodySnapshot> snaps, {required bool isItalian}) {
    if (snaps.isEmpty) return const [];
    final byWeek = <DateTime, List<double>>{};
    for (final s in snaps) {
      byWeek.putIfAbsent(weekStart(s.data), () => []).add(s.pesoKg);
    }
    final weeks = byWeek.keys.toList()..sort();
    final avg = {
      for (final w in weeks) w: byWeek[w]!.reduce((a, b) => a + b) / byWeek[w]!.length,
    };
    final delta = avg[weeks.last]! - avg[weeks.first]!;
    return [
      isItalian
          ? '[PESO settimanale] sett;kg_medio;n_pesate'
          : '[WEIGHT weekly] week;avg_kg;n_weigh_ins',
      for (final w in weeks) '${date(w)};${_n(avg[w]!)};${byWeek[w]!.length}',
      isItalian
          ? 'Variazione tra prima e ultima settimana: ${delta >= 0 ? '+' : ''}${_n(delta)} kg'
          : 'Change between first and last week: ${delta >= 0 ? '+' : ''}${_n(delta)} kg',
    ];
  }

  static String _header({
    required bool isItalian,
    required DateTime now,
    required int obiettivo,
    required int livello,
  }) {
    final o = _obiettivi[obiettivo.clamp(0, 2)];
    final l = _livelli[livello.clamp(0, 4)];
    return isItalian
        ? 'Oggi è ${date(now)}. Obiettivo: ${o.$1}. Livello di attività: ${l.$1}. '
            'Finestra dati: ultimi $windowDays giorni.'
        : 'Today is ${date(now)}. Goal: ${o.$2}. Activity level: ${l.$2}. '
            'Data window: last $windowDays days.';
  }

  /// Contesto per "Genera nuova scheda": sessioni e volume per settimana,
  /// progressione per esercizio, peso. I nomi degli esercizi sono quelli
  /// realmente usati, per permettere all'utente di ritrovarli nel catalogo.
  static String buildWorkoutContext({
    required DateTime now,
    required int obiettivo,
    required int livello,
    required List<WorkoutExercise> exercises,
    required Map<String, String> muscleGroupById,
    required List<BodySnapshot> snapshots,
    required bool isItalian,
  }) {
    final done = exercises.where(isDone).toList()..sort((a, b) => a.date.compareTo(b.date));
    final lines = <String>[_header(isItalian: isItalian, now: now, obiettivo: obiettivo, livello: livello)];

    final days = <DateTime, Set<DateTime>>{};
    final volume = <DateTime, Map<String, double>>{};
    for (final e in done) {
      final w = weekStart(e.date);
      days.putIfAbsent(w, () => {}).add(e.date);
      final group = muscleGroupById[e.exerciseId] ?? '?';
      final v = volume.putIfAbsent(w, () => {});
      v[group] = (v[group] ?? 0) + WorkoutProgressService.sessionVolume(e);
    }
    lines.add(isItalian
        ? '[ALLENAMENTO settimanale] sett;sessioni;volume_kg per gruppo'
        : '[TRAINING weekly] week;sessions;volume_kg by group');
    for (final w in days.keys.toList()..sort()) {
      final groups = (volume[w]!.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
          .map((g) => '${g.key} ${g.value.round()}')
          .join(', ');
      lines.add('${date(w)};${days[w]!.length};$groups');
    }

    final byExercise = <String, List<WorkoutExercise>>{};
    for (final e in done) {
      byExercise.putIfAbsent(e.exerciseId, () => []).add(e);
    }
    final ranked = byExercise.values.toList()..sort((a, b) => b.length.compareTo(a.length));
    lines.add(isItalian
        ? '[ESERCIZI usati] nome;gruppo;sessioni;kg_max_prima;kg_max_ultima'
        : '[EXERCISES used] name;group;sessions;first_max_kg;last_max_kg');
    for (final list in ranked.take(maxExercises)) {
      final first = _maxWorkWeight(list.first);
      final last = _maxWorkWeight(list.last);
      lines.add('${list.last.exerciseName};${muscleGroupById[list.first.exerciseId] ?? '?'};'
          '${list.length};${first == null ? '-' : _n(first)};${last == null ? '-' : _n(last)}');
    }

    lines.addAll(weightLines(snapshots, isItalian: isItalian));
    return lines.join('\n');
  }

  /// Contesto per "Genera nuova alimentazione": preferenze come vincoli,
  /// target dell'app come valori fissi, piano attuale e — solo se il diario è
  /// abbastanza compilato — aderenza e andamento del peso.
  static String buildNutritionContext({
    required DateTime now,
    required int obiettivo,
    required int livello,
    required (int?, int?, int?, int?) targets,
    required UserFoodPreferences prefs,
    required List<String> likedFoodNames,
    required MealPlan? plan,
    required List<DailyLog> logs,
    required List<BodySnapshot> snapshots,
    required bool isItalian,
  }) {
    String t(String it, String en) => isItalian ? it : en;
    final lines = <String>[_header(isItalian: isItalian, now: now, obiettivo: obiettivo, livello: livello)];

    final (kcal, prot, fat, carb) = targets;
    if (kcal != null) {
      lines.add(t('Target giornalieri FISSI (calcolati dall\'app, non modificarli): $kcal kcal, P ${prot}g, G ${fat}g, C ${carb}g',
          'FIXED daily targets (computed by the app, do not change them): $kcal kcal, P ${prot}g, F ${fat}g, C ${carb}g'));
    }
    lines.add(prefs.restrizioni.isEmpty
        ? t('Restrizioni alimentari: nessuna.', 'Dietary restrictions: none.')
        : t('Restrizioni alimentari (DIVIETI ASSOLUTI, non proporre mai questi alimenti): ${prefs.restrizioni.join(', ')}.',
            'Dietary restrictions (ABSOLUTE BANS, never suggest these foods): ${prefs.restrizioni.join(', ')}.'));
    if (likedFoodNames.isNotEmpty) {
      lines.add(t('Alimenti graditi: ${likedFoodNames.join(', ')}.',
          'Preferred foods: ${likedFoodNames.join(', ')}.'));
    }
    lines.add(t(
        'Pasti al giorno: ${prefs.numPasti}${prefs.haSpuntinoPostWo ? ', con spuntino post-allenamento' : ''}.',
        'Meals per day: ${prefs.numPasti}${prefs.haSpuntinoPostWo ? ', with a post-workout snack' : ''}.'));

    if (plan != null && plan.pasti.isNotEmpty) {
      lines.addAll(CoachContext.planLines(plan, isItalian: isItalian));
    }

    final logged = logs.where((l) => l.entries.isNotEmpty).toList();
    if (logged.length >= minDiaryDays) {
      double avg(double Function(DailyLog) f) => logged.map(f).reduce((a, b) => a + b) / logged.length;
      lines.add(t(
          'Diario: ${logged.length} giorni registrati su $windowDays; media sui giorni registrati '
              '${avg((l) => l.kcalTotali).round()} kcal, P ${avg((l) => l.proteinTotali).round()}g, '
              'G ${avg((l) => l.fatTotali).round()}g, C ${avg((l) => l.carbsTotali).round()}g.',
          'Diary: ${logged.length} days logged out of $windowDays; average over logged days '
              '${avg((l) => l.kcalTotali).round()} kcal, P ${avg((l) => l.proteinTotali).round()}g, '
              'F ${avg((l) => l.fatTotali).round()}g, C ${avg((l) => l.carbsTotali).round()}g.'));
      lines.addAll(weightLines(snapshots, isItalian: isItalian));
    } else {
      lines.add(t('Diario troppo scarso (${logged.length} giorni registrati): non usarlo per valutare l\'aderenza.',
          'Diary too sparse (${logged.length} days logged): do not use it to judge adherence.'));
    }
    return lines.join('\n');
  }

  /// Contesto per "Genera ricette": solo il piano e i divieti.
  static String buildRecipesContext({
    required MealPlan plan,
    required List<String> restrizioni,
    required bool isItalian,
  }) {
    String t(String it, String en) => isItalian ? it : en;
    return [
      ...CoachContext.planLines(plan, isItalian: isItalian),
      restrizioni.isEmpty
          ? t('Restrizioni alimentari: nessuna.', 'Dietary restrictions: none.')
          : t('Restrizioni alimentari (DIVIETI ASSOLUTI): ${restrizioni.join(', ')}.',
              'Dietary restrictions (ABSOLUTE BANS): ${restrizioni.join(', ')}.'),
    ].join('\n');
  }

  // ── Lettura dal DB ────────────────────────────────────────

  static Future<String> loadWorkoutContext({required bool isItalian, DateTime? now}) async {
    final db = DatabaseService.instance;
    final today = now ?? DateTime.now();
    final from = today.subtract(const Duration(days: windowDays));
    final settings = await db.getAppSettings();
    final catalog = await db.getAllExercises();
    return buildWorkoutContext(
      now: today,
      obiettivo: settings.obiettivo,
      livello: settings.livelloAttivita,
      exercises: await db.getWorkoutExercisesRange(from, today),
      muscleGroupById: {for (final e in catalog) e.externalId: e.muscleGroup},
      snapshots: (await db.getBodySnapshots()).where((s) => !s.data.isBefore(from)).toList(),
      isItalian: isItalian,
    );
  }

  static Future<CoachGate> workoutGate({DateTime? now}) async {
    final today = now ?? DateTime.now();
    return gateWorkout(await DatabaseService.instance
        .getWorkoutExercisesRange(today.subtract(const Duration(days: windowDays)), today));
  }

  static Future<CoachGate> nutritionGate() async {
    final db = DatabaseService.instance;
    return gateNutrition(
      hasProfile: await db.getUserProfile() != null,
      hasWeight: await db.getLatestBodySnapshot() != null,
      prefs: await db.getUserFoodPreferences(),
    );
  }

  static Future<CoachGate> recipesGate() async =>
      gateRecipes(await DatabaseService.instance.getMealPlan());

  static Future<String> loadNutritionContext({required bool isItalian, DateTime? now}) async {
    final db = DatabaseService.instance;
    final today = now ?? DateTime.now();
    final from = today.subtract(const Duration(days: windowDays));
    final settings = await db.getAppSettings();
    final prefs = await db.getUserFoodPreferences() ?? UserFoodPreferences();
    final liked = <String>[];
    for (final id in prefs.foodLikedIds) {
      final item = await db.getFoodItemById(id);
      if (item != null) liked.add(item.nome);
    }
    return buildNutritionContext(
      now: today,
      obiettivo: settings.obiettivo,
      livello: settings.livelloAttivita,
      targets: await computeDailyTargets(),
      prefs: prefs,
      likedFoodNames: liked,
      plan: await db.getMealPlan(),
      logs: await db.getDailyLogsRange(from, today),
      snapshots: (await db.getBodySnapshots()).where((s) => !s.data.isBefore(from)).toList(),
      isItalian: isItalian,
    );
  }

  static Future<String?> loadRecipesContext({required bool isItalian}) async {
    final db = DatabaseService.instance;
    final plan = await db.getMealPlan();
    if (plan == null || plan.pasti.isEmpty) return null;
    final prefs = await db.getUserFoodPreferences();
    return buildRecipesContext(
        plan: plan, restrizioni: prefs?.restrizioni ?? const [], isItalian: isItalian);
  }
}
