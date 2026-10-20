import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/daily_log.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/models/meal_plan.dart';
import 'package:plico/models/personal_record.dart';
import 'package:plico/services/coach_context.dart';

CoachContextData _data({
  DailyLog? log,
  MealPlan? plan,
  List<BodySnapshot> snaps = const [],
  Map<String, double> volume = const {},
  List<PersonalRecord> prs = const [],
  (int?, int?, int?, int?) targets = (null, null, null, null),
}) =>
    CoachContextData(
      now: DateTime(2026, 10, 20),
      obiettivo: 0,
      pesoObiettivo: 72.5,
      targets: targets,
      recentSnapshots: snaps,
      todayLog: log,
      workoutKcalToday: 0,
      plan: plan,
      weeklyVolume: volume,
      personalRecords: prs,
    );

void main() {
  test('senza dati segnala comunque obiettivo e pasti non registrati', () {
    final out = CoachContext.build(_data(), isItalian: true);
    expect(out, contains('deficit calorico'));
    expect(out, contains('72.5 kg'));
    expect(out, contains('non ha ancora registrato pasti'));
    expect(out, isNot(contains('Piano alimentare')));
  });

  test('include target, peso, pasti di oggi, piano con grammature, volume e PR', () {
    final log = DailyLog()
      ..data = DateTime(2026, 10, 20)
      ..entries = [
        MealEntry()
          ..kcalPer100g = 200
          ..proteinPer100g = 10
          ..quantitaG = 150,
      ];
    final plan = MealPlan()
      ..kcalTotali = 2100
      ..pasti = [
        PlanMeal()
          ..tipo = 1
          ..slots = [
            PlanSlot()..principale = (PlanFood()..nome = 'Riso'..quantitaG = 80),
          ],
      ];
    final out = CoachContext.build(
      _data(
        log: log,
        plan: plan,
        snaps: [BodySnapshot()..data = DateTime(2026, 10, 19)..pesoKg = 75],
        volume: {'Gambe': 4200.4},
        prs: [
          PersonalRecord(
            exerciseId: 'sq',
            exerciseName: 'Squat',
            muscleGroup: 'Gambe',
            maxWeightKg: 100,
            achievedAt: DateTime(2026, 10, 1),
          ),
        ],
        targets: (2000, 150, 60, 200),
      ),
      isItalian: true,
    );
    expect(out, contains('2000 kcal, P 150g'));
    expect(out, contains('2026-10-19: 75 kg'));
    expect(out, contains('300 kcal'));
    expect(out, contains('Pranzo: Riso 80g'));
    expect(out, contains('Gambe 4200'));
    expect(out, contains('Squat 100 kg'));
  });

  test('versione inglese', () {
    final out = CoachContext.build(_data(), isItalian: false);
    expect(out, contains('calorie deficit'));
    expect(out, contains('No meals logged yet today.'));
  });
}
