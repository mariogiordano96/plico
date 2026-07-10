import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/models/workout_set.dart';
import 'package:plico/services/guided_session_service.dart';

WorkoutExercise _exercise({
  required String id,
  int? supersetGroupId,
  int? estimatedKcal,
  int? durationSeconds,
  List<WorkoutSet>? sets,
}) {
  return WorkoutExercise()
    ..exerciseId = id
    ..exerciseName = id
    ..date = DateTime(2026, 1, 1)
    ..supersetGroupId = supersetGroupId
    ..estimatedKcal = estimatedKcal
    ..durationSeconds = durationSeconds
    ..sets = sets ?? [];
}

WorkoutSet _set({int? reps, double? weightKg}) =>
    WorkoutSet()..reps = reps..weightKg = weightKg;

void main() {
  group('groupSteps', () {
    test('esercizi senza supersetGroupId sono ciascuno un proprio step', () {
      final a = _exercise(id: 'a');
      final b = _exercise(id: 'b');
      final steps = GuidedSessionService.groupSteps([a, b]);
      expect(steps, [
        [a],
        [b],
      ]);
    });

    test('esercizi consecutivi con lo stesso supersetGroupId formano uno step', () {
      final a = _exercise(id: 'a', supersetGroupId: 1);
      final b = _exercise(id: 'b', supersetGroupId: 1);
      final c = _exercise(id: 'c');
      final steps = GuidedSessionService.groupSteps([a, b, c]);
      expect(steps, [
        [a, b],
        [c],
      ]);
    });

    test('stesso supersetGroupId non consecutivo NON si riunisce nello stesso step', () {
      final a = _exercise(id: 'a', supersetGroupId: 1);
      final b = _exercise(id: 'b', supersetGroupId: 2);
      final c = _exercise(id: 'c', supersetGroupId: 1);
      final steps = GuidedSessionService.groupSteps([a, b, c]);
      expect(steps, [
        [a],
        [b],
        [c],
      ]);
    });

    test('lista vuota produce nessuno step', () {
      expect(GuidedSessionService.groupSteps([]), isEmpty);
    });
  });

  group('totalEstimatedKcal', () {
    test('somma estimatedKcal trattando null come 0', () {
      final exercises = [
        _exercise(id: 'a', estimatedKcal: 100),
        _exercise(id: 'b', estimatedKcal: null),
        _exercise(id: 'c', estimatedKcal: 50),
      ];
      expect(GuidedSessionService.totalEstimatedKcal(exercises), 150);
    });

    test('lista vuota produce 0', () {
      expect(GuidedSessionService.totalEstimatedKcal([]), 0);
    });
  });

  group('newPersonalRecords', () {
    test('esercizio cardio non è mai un PR', () {
      final cardio = _exercise(id: 'run', durationSeconds: 600);
      final result = GuidedSessionService.newPersonalRecords([cardio], {});
      expect(result, isEmpty);
    });

    test('senza storico precedente, un esercizio con peso è un PR', () {
      final e = _exercise(id: 'squat', sets: [_set(reps: 5, weightKg: 100)]);
      final result = GuidedSessionService.newPersonalRecords([e], {});
      expect(result, [e]);
    });

    test('con storico, un carico maggiore del massimo precedente è un PR', () {
      final prior = _exercise(id: 'squat', sets: [_set(reps: 5, weightKg: 100)]);
      final current = _exercise(id: 'squat', sets: [_set(reps: 5, weightKg: 110)]);
      final result = GuidedSessionService.newPersonalRecords(
        [current],
        {'squat': [prior]},
      );
      expect(result, [current]);
    });

    test('un carico pari o inferiore al massimo precedente non è un PR', () {
      final prior = _exercise(id: 'squat', sets: [_set(reps: 5, weightKg: 100)]);
      final current = _exercise(id: 'squat', sets: [_set(reps: 5, weightKg: 90)]);
      final result = GuidedSessionService.newPersonalRecords(
        [current],
        {'squat': [prior]},
      );
      expect(result, isEmpty);
    });
  });
}
