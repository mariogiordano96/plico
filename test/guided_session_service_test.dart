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

WorkoutSet _set({int? reps, double? weightKg, bool confirmed = false, bool isWarmup = false}) =>
    WorkoutSet()
      ..reps = reps
      ..weightKg = weightKg
      ..confirmed = confirmed
      ..isWarmup = isWarmup;

List<WorkoutSet> _sets(int count, {int confirmedCount = 0}) => [
      for (var i = 0; i < count; i++) _set(confirmed: i < confirmedCount),
    ];

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

  group('turnFor', () {
    test('blocco appena iniziato: il turno è il primo esercizio', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(3));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(3));
      expect(GuidedSessionService.turnFor([a, b]), same(a));
    });

    test('alterna A1,B1,A2,B2... man mano che si confermano le serie', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(2, confirmedCount: 1));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(2));
      // a ha già confermato 1 serie su 2, b nessuna: tocca a b (meno confermate).
      expect(GuidedSessionService.turnFor([a, b]), same(b));
    });

    test('blocco con 3+ esercizi: il turno segue l\'ordine round-robin', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(3, confirmedCount: 1));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(3, confirmedCount: 1));
      final c = _exercise(id: 'c', supersetGroupId: 1, sets: _sets(3));
      // a e b hanno già fatto il round 1, c no: tocca a c per chiudere il round.
      expect(GuidedSessionService.turnFor([a, b, c]), same(c));
    });

    test('esercizio con meno serie degli altri viene saltato una volta esaurito', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(2, confirmedCount: 2));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(3, confirmedCount: 2));
      // a ha finito le sue 2 serie, b ne ha ancora una: tocca a b anche se
      // il conteggio confermate di a (2) è minore di quello di b.
      expect(GuidedSessionService.turnFor([a, b]), same(b));
    });

    test('mix strength+cardio: il cardio conta come una singola unità', () {
      final cardio = _exercise(id: 'jump', supersetGroupId: 1, durationSeconds: 40);
      final squat = _exercise(id: 'squat', supersetGroupId: 1, sets: _sets(3));
      expect(GuidedSessionService.turnFor([cardio, squat]), same(cardio));
      cardio.cardioConfirmed = true;
      expect(GuidedSessionService.turnFor([cardio, squat]), same(squat));
    });

    test('blocco completo: nessun turno (null)', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(2, confirmedCount: 2));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(2, confirmedCount: 2));
      expect(GuidedSessionService.turnFor([a, b]), isNull);
    });
  });

  group('isStepComplete', () {
    bool isDone(WorkoutExercise e) =>
        e.isCardio ? e.cardioConfirmed : e.sets.every((s) => s.confirmed);

    test('step a esercizio singolo: sempre completo (nessuna restrizione d\'ordine)', () {
      final a = _exercise(id: 'a', sets: _sets(3, confirmedCount: 1));
      expect(GuidedSessionService.isStepComplete([a], isDone), isTrue);
    });

    test('blocco superset: false finché non tutti gli esercizi sono fatti', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(2, confirmedCount: 2));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(2, confirmedCount: 1));
      expect(GuidedSessionService.isStepComplete([a, b], isDone), isFalse);
    });

    test('blocco superset: true quando tutti gli esercizi sono completi', () {
      final a = _exercise(id: 'a', supersetGroupId: 1, sets: _sets(2, confirmedCount: 2));
      final b = _exercise(id: 'b', supersetGroupId: 1, sets: _sets(3, confirmedCount: 3));
      expect(GuidedSessionService.isStepComplete([a, b], isDone), isTrue);
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
