import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/daily_log.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/models/meal_plan.dart';
import 'package:plico/models/user_food_preferences.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/models/workout_set.dart';
import 'package:plico/services/coach_history.dart';

WorkoutExercise _ex(String id, DateTime date, double kg, {bool confirmed = true}) =>
    WorkoutExercise()
      ..exerciseId = id
      ..exerciseName = 'Nome $id'
      ..date = date
      ..sets = [
        WorkoutSet()
          ..reps = 10
          ..weightKg = kg
          ..confirmed = confirmed,
        WorkoutSet()
          ..reps = 10
          ..weightKg = 20
          ..isWarmup = true
          ..confirmed = true,
      ];

final _now = DateTime(2026, 10, 20); // martedì

void main() {
  group('soglie', () {
    test('scheda: conta solo giorni con lavoro confermato', () {
      final ex = [
        for (var i = 0; i < 5; i++) _ex('sq', DateTime(2026, 10, 1 + i), 60),
        _ex('sq', DateTime(2026, 10, 10), 60, confirmed: false),
        _ex('bp', DateTime(2026, 10, 4), 50), // stesso giorno di un'altra sessione
      ];
      final gate = CoachHistory.gateWorkout(ex);
      expect(gate.enabled, isFalse);
      expect(gate.sessions, 5);
      expect(gate.missing, [CoachGateReason.fewSessions]);
      ex.add(_ex('sq', DateTime(2026, 10, 12), 60));
      expect(CoachHistory.gateWorkout(ex).enabled, isTrue);
    });

    test('alimentazione: serve profilo, peso e questionario', () {
      final g = CoachHistory.gateNutrition(hasProfile: false, hasWeight: false, prefs: null);
      expect(g.missing, [
        CoachGateReason.noProfile,
        CoachGateReason.noWeight,
        CoachGateReason.noQuestionnaire,
      ]);
      final ok = CoachHistory.gateNutrition(
        hasProfile: true,
        hasWeight: true,
        prefs: UserFoodPreferences()..questionarioCompletato = true,
      );
      expect(ok.enabled, isTrue);
    });

    test('ricette: serve un piano con pasti', () {
      expect(CoachHistory.gateRecipes(null).missing, [CoachGateReason.noPlan]);
      expect(CoachHistory.gateRecipes(MealPlan()).enabled, isFalse);
      expect(CoachHistory.gateRecipes(MealPlan()..pasti = [PlanMeal()]).enabled, isTrue);
    });
  });

  group('contesto scheda', () {
    test('tabelle settimanali, progressione e peso; ignora il non svolto e il warmup', () {
      final out = CoachHistory.buildWorkoutContext(
        now: _now,
        obiettivo: 2,
        livello: 3,
        exercises: [
          _ex('sq', DateTime(2026, 10, 5), 80),
          _ex('sq', DateTime(2026, 10, 12), 90),
          _ex('bp', DateTime(2026, 10, 13), 60, confirmed: false),
        ],
        muscleGroupById: {'sq': 'Gambe', 'bp': 'Petto'},
        snapshots: [
          BodySnapshot()..data = DateTime(2026, 10, 5)..pesoKg = 75,
          BodySnapshot()..data = DateTime(2026, 10, 19)..pesoKg = 76,
        ],
        isItalian: true,
      );
      expect(out, contains('surplus calorico'));
      expect(out, contains('molto attivo'));
      expect(out, contains('2026-10-05;1;Gambe 800')); // 10x80, warmup escluso
      expect(out, contains('Nome sq;Gambe;2;80;90'));
      expect(out, isNot(contains('Petto')));
      expect(out, contains('+1 kg'));
    });
  });

  group('contesto alimentazione', () {
    final prefs = UserFoodPreferences()
      ..restrizioni = ['no_lattosio']
      ..numPasti = 4
      ..haSpuntinoPostWo = true;

    DailyLog log(int day) => DailyLog()
      ..data = DateTime(2026, 10, day)
      ..entries = [
        MealEntry()
          ..kcalPer100g = 100
          ..quantitaG = 1000
      ];

    test('target fissi, divieti e preferenze; diario scarso non usato', () {
      final out = CoachHistory.buildNutritionContext(
        now: _now,
        obiettivo: 0,
        livello: 2,
        targets: (2000, 150, 60, 200),
        prefs: prefs,
        likedFoodNames: ['Riso', 'Pollo'],
        plan: null,
        logs: [log(1), log(2)],
        snapshots: const [],
        isItalian: true,
      );
      expect(out, contains('FISSI'));
      expect(out, contains('2000 kcal'));
      expect(out, contains('DIVIETI ASSOLUTI'));
      expect(out, contains('no_lattosio'));
      expect(out, contains('Riso, Pollo'));
      expect(out, contains('spuntino post-allenamento'));
      expect(out, contains('Diario troppo scarso (2 giorni'));
    });

    test('con almeno 14 giorni usa medie sui giorni registrati', () {
      final out = CoachHistory.buildNutritionContext(
        now: _now,
        obiettivo: 1,
        livello: 2,
        targets: (null, null, null, null),
        prefs: prefs,
        likedFoodNames: const [],
        plan: null,
        logs: [for (var d = 1; d <= 14; d++) log(d)],
        snapshots: const [],
        isItalian: false,
      );
      expect(out, contains('14 days logged out of 90'));
      expect(out, contains('1000 kcal'));
      expect(out, isNot(contains('FIXED')));
    });
  });

  test('contesto ricette include piano e divieti', () {
    final plan = MealPlan()
      ..kcalTotali = 1800
      ..pasti = [
        PlanMeal()
          ..tipo = 2
          ..slots = [PlanSlot()..principale = (PlanFood()..nome = 'Salmone'..quantitaG = 150)],
      ];
    final out = CoachHistory.buildRecipesContext(
        plan: plan, restrizioni: ['no_glutine'], isItalian: true);
    expect(out, contains('Cena: Salmone 150g'));
    expect(out, contains('no_glutine'));
  });
}
