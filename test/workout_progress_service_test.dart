import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/models/workout_set.dart';
import 'package:plico/services/workout_progress_service.dart';

WorkoutExercise _exercise({
  String id = 'ex',
  DateTime? date,
  List<WorkoutSet>? sets,
}) {
  return WorkoutExercise()
    ..exerciseId = id
    ..exerciseName = id
    ..date = date ?? DateTime(2026, 1, 1)
    ..sets = sets ?? [];
}

WorkoutSet _set({
  int? reps,
  double? weightKg,
  int? rpe,
  bool isWarmup = false,
  List<int>? restPauseClusters,
  List<DropStage>? dropStages,
}) {
  return WorkoutSet()
    ..reps = reps
    ..weightKg = weightKg
    ..rpe = rpe
    ..isWarmup = isWarmup
    ..confirmed = true
    ..restPauseClusters = restPauseClusters
    ..dropStages = dropStages;
}

void main() {
  group('suggestWarmupSets', () {
    test('sotto la soglia di default (20kg) non suggerisce riscaldamento', () {
      expect(WorkoutProgressService.suggestWarmupSets(19), isEmpty);
    });

    test('esattamente alla soglia suggerisce il riscaldamento (confronto stretto)', () {
      expect(WorkoutProgressService.suggestWarmupSets(20), isNotEmpty);
    });

    test('sopra la soglia genera 3 serie con rampa 50/70/90% e rip decrescenti', () {
      final warmup = WorkoutProgressService.suggestWarmupSets(100);
      expect(warmup, hasLength(3));
      expect(warmup.map((s) => s.weightKg), [50, 70, 90]);
      expect(warmup.map((s) => s.reps), [8, 5, 3]);
      expect(warmup.every((s) => s.isWarmup), isTrue);
    });

    test('rispetta una soglia personalizzata', () {
      expect(WorkoutProgressService.suggestWarmupSets(10, skipThresholdKg: 5), isNotEmpty);
      expect(WorkoutProgressService.suggestWarmupSets(3, skipThresholdKg: 5), isEmpty);
    });
  });

  group('neglectedMuscleGroups', () {
    test('nessun gruppo con volume positivo → nessun trascurato', () {
      expect(WorkoutProgressService.neglectedMuscleGroups({'chest': 0, 'back': 0}), isEmpty);
    });

    test('un gruppo molto sotto la media degli altri viene segnalato', () {
      final result = WorkoutProgressService.neglectedMuscleGroups(
        {'chest': 100, 'back': 100, 'legs': 5},
      );
      expect(result, ['legs']);
    });

    test('gruppi vicini alla media non sono trascurati', () {
      final result = WorkoutProgressService.neglectedMuscleGroups(
        {'chest': 100, 'back': 90},
      );
      expect(result, isEmpty);
    });
  });

  group('sessionVolume', () {
    test('somma reps × peso escludendo le serie di riscaldamento', () {
      final e = _exercise(sets: [
        _set(reps: 10, weightKg: 50),
        _set(reps: 8, weightKg: 50),
        _set(reps: 20, weightKg: 999, isWarmup: true),
      ]);
      expect(WorkoutProgressService.sessionVolume(e), 900);
    });

    test('rest-pause: reps è già la somma dei cluster, nessun aggiustamento extra', () {
      // 8+4+3=15 rip già scritte in reps da _confirmSerie prima della persistenza.
      final e = _exercise(sets: [
        _set(reps: 15, weightKg: 50, restPauseClusters: [8, 4, 3]),
      ]);
      expect(WorkoutProgressService.sessionVolume(e), 750); // 15 * 50
    });

    test('stripping: somma anche i gradini di dropStages, non solo il primo', () {
      final e = _exercise(sets: [
        _set(
          reps: 8,
          weightKg: 60, // primo gradino: 8*60 = 480
          dropStages: [
            DropStage()
              ..reps = 6
              ..weightKg = 50, // 6*50 = 300
            DropStage()
              ..reps = 5
              ..weightKg = 40, // 5*40 = 200
          ],
        ),
      ]);
      expect(WorkoutProgressService.sessionVolume(e), 980); // 480+300+200
    });

    test('forzate: forcedReps non è mai incluso nel volume', () {
      final e = _exercise(sets: [
        (_set(reps: 8, weightKg: 50)..forcedReps = 3), // volume = solo 8*50
      ]);
      expect(WorkoutProgressService.sessionVolume(e), 400);
    });
  });

  group('sessionMaxWeight', () {
    test('null se non ci sono serie con peso', () {
      final e = _exercise(sets: [_set(reps: 10)]);
      expect(WorkoutProgressService.sessionMaxWeight(e), isNull);
    });

    test('il massimo tra le serie di lavoro, esclude il riscaldamento', () {
      final e = _exercise(sets: [
        _set(reps: 10, weightKg: 60),
        _set(reps: 8, weightKg: 80),
        _set(reps: 20, weightKg: 999, isWarmup: true),
      ]);
      expect(WorkoutProgressService.sessionMaxWeight(e), 80);
    });
  });

  group('averageRpe', () {
    test('null se nessuna serie ha un rpe', () {
      final e = _exercise(sets: [_set(reps: 10, weightKg: 50)]);
      expect(WorkoutProgressService.averageRpe(e), isNull);
    });

    test('media degli rpe impostati', () {
      final e = _exercise(sets: [
        _set(reps: 10, weightKg: 50, rpe: 7),
        _set(reps: 10, weightKg: 50, rpe: 9),
      ]);
      expect(WorkoutProgressService.averageRpe(e), 8);
    });
  });

  group('estimatedOneRepMax', () {
    test('null se nessuna serie ha reps e peso validi', () {
      final e = _exercise(sets: [_set(reps: 10)]);
      expect(WorkoutProgressService.estimatedOneRepMax(e), isNull);
    });

    test('formula di Epley sulla serie migliore', () {
      final e = _exercise(sets: [
        _set(reps: 5, weightKg: 100), // 100 * (1 + 5/30) = 116.67
        _set(reps: 10, weightKg: 80), // 80 * (1 + 10/30) = 106.67
      ]);
      expect(WorkoutProgressService.estimatedOneRepMax(e), closeTo(116.67, 0.01));
    });

    test('esclude le serie rest-pause: reps è la somma dei cluster, non uno sforzo continuo', () {
      final e = _exercise(sets: [
        // Se non escluso: 100 * (1 + 15/30) = 150, molto sopra il reale 1RM.
        _set(reps: 15, weightKg: 100, restPauseClusters: [8, 4, 3]),
        _set(reps: 5, weightKg: 90), // 90 * (1 + 5/30) = 105
      ]);
      expect(WorkoutProgressService.estimatedOneRepMax(e), closeTo(105, 0.01));
    });

    test('tutte rest-pause → null, come nessuna serie valida', () {
      final e = _exercise(sets: [
        _set(reps: 15, weightKg: 100, restPauseClusters: [8, 4, 3]),
      ]);
      expect(WorkoutProgressService.estimatedOneRepMax(e), isNull);
    });
  });

  group('isNewPersonalRecord', () {
    test('false se il candidato non ha un peso massimo', () {
      final candidate = _exercise(sets: [_set(reps: 10)]);
      expect(WorkoutProgressService.isNewPersonalRecord(candidate, []), isFalse);
    });

    test('true senza storico precedente (se ha un peso)', () {
      final candidate = _exercise(sets: [_set(reps: 5, weightKg: 100)]);
      expect(WorkoutProgressService.isNewPersonalRecord(candidate, []), isTrue);
    });

    test('true se supera il massimo di tutto lo storico', () {
      final candidate = _exercise(sets: [_set(reps: 5, weightKg: 110)]);
      final prior1 = _exercise(sets: [_set(reps: 5, weightKg: 100)]);
      final prior2 = _exercise(sets: [_set(reps: 5, weightKg: 105)]);
      expect(
          WorkoutProgressService.isNewPersonalRecord(candidate, [prior1, prior2]), isTrue);
    });

    test('false se pari o sotto il massimo storico', () {
      final candidate = _exercise(sets: [_set(reps: 5, weightKg: 100)]);
      final prior = _exercise(sets: [_set(reps: 5, weightKg: 100)]);
      expect(WorkoutProgressService.isNewPersonalRecord(candidate, [prior]), isFalse);
    });
  });

  group('suggestNextSession', () {
    test('serie non confermate ignorate: nessun suggerimento da 0 kg', () {
      final last = _exercise(sets: [WorkoutSet()..reps = 10]);
      expect(WorkoutProgressService.hasConfirmedWork(last), isFalse);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.suggestedWeightKg, isNull);
    });

    test('nessuna serie di lavoro → maintain senza valori suggeriti', () {
      final last = _exercise(sets: []);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.direction, OverloadDirection.maintain);
      expect(s.suggestedWeightKg, isNull);
      expect(s.suggestedReps, isNull);
    });

    test('2+ serie sotto il target di rip → maintain, mai una riduzione', () {
      final last = _exercise(sets: [
        _set(reps: 10, weightKg: 100),
        _set(reps: 8, weightKg: 100),
        _set(reps: 7, weightKg: 100),
      ]);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.direction, OverloadDirection.maintain);
      expect(s.suggestedWeightKg, 100);
      expect(s.suggestedReps, 10);
    });

    test('esattamente 1 serie sotto il target → maintain sullo stesso peso', () {
      final last = _exercise(sets: [
        _set(reps: 10, weightKg: 100),
        _set(reps: 10, weightKg: 100),
        _set(reps: 8, weightKg: 100),
      ]);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.direction, OverloadDirection.maintain);
      expect(s.suggestedWeightKg, 100);
      expect(s.suggestedReps, 10);
    });

    test('nessuna serie sotto target ma RPE medio alto (≥8.5) → maintain', () {
      final last = _exercise(sets: [
        _set(reps: 10, weightKg: 100, rpe: 9),
        _set(reps: 10, weightKg: 100, rpe: 9),
      ]);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.direction, OverloadDirection.maintain);
      expect(s.suggestedWeightKg, 100);
    });

    test('target rispettato e RPE basso/assente → increase (+2.5kg)', () {
      final last = _exercise(sets: [
        _set(reps: 10, weightKg: 100),
        _set(reps: 10, weightKg: 100),
      ]);
      final s = WorkoutProgressService.suggestNextSession(last);
      expect(s.direction, OverloadDirection.increase);
      expect(s.suggestedWeightKg, 102.5);
      expect(s.suggestedReps, 10);
    });
  });

  group('needsDeload', () {
    test('meno del numero minimo di settimane di storico → false', () {
      final history = [
        _exercise(date: DateTime(2026, 1, 1), sets: [_set(reps: 5, weightKg: 100)]),
        _exercise(date: DateTime(2026, 1, 8), sets: [_set(reps: 5, weightKg: 100)]),
      ];
      expect(WorkoutProgressService.needsDeload(history), isFalse);
    });

    test('carico massimo settimanale mai diminuito nelle ultime N settimane → true', () {
      final history = [
        _exercise(date: DateTime(2026, 1, 1), sets: [_set(reps: 5, weightKg: 100)]),
        _exercise(date: DateTime(2026, 1, 8), sets: [_set(reps: 5, weightKg: 100)]),
        _exercise(date: DateTime(2026, 1, 15), sets: [_set(reps: 5, weightKg: 105)]),
        _exercise(date: DateTime(2026, 1, 22), sets: [_set(reps: 5, weightKg: 110)]),
      ];
      expect(WorkoutProgressService.needsDeload(history), isTrue);
    });

    test('un calo di carico settimanale interrompe il segnale di scarico', () {
      final history = [
        _exercise(date: DateTime(2026, 1, 1), sets: [_set(reps: 5, weightKg: 100)]),
        _exercise(date: DateTime(2026, 1, 8), sets: [_set(reps: 5, weightKg: 110)]),
        _exercise(date: DateTime(2026, 1, 15), sets: [_set(reps: 5, weightKg: 90)]),
        _exercise(date: DateTime(2026, 1, 22), sets: [_set(reps: 5, weightKg: 100)]),
      ];
      expect(WorkoutProgressService.needsDeload(history), isFalse);
    });
  });

  group('shouldOfferDeload', () {
    final history = [
      _exercise(date: DateTime(2026, 1, 8), sets: [_set(reps: 5, weightKg: 100)]),
      _exercise(date: DateTime(2026, 1, 15), sets: [_set(reps: 5, weightKg: 105)]),
      _exercise(date: DateTime(2026, 1, 22), sets: [_set(reps: 5, weightKg: 110)]),
    ];

    test('3 settimane di progressione consecutive → proposto', () {
      expect(WorkoutProgressService.shouldOfferDeload(history), isTrue);
    });

    test('disattivato meno di 3 settimane fa → non riproposto', () {
      expect(
        WorkoutProgressService.shouldOfferDeload(
          history,
          dismissedAt: DateTime(2026, 1, 25),
          now: DateTime(2026, 2, 10),
        ),
        isFalse,
      );
    });

    test('disattivato 3+ settimane fa → riproposto', () {
      expect(
        WorkoutProgressService.shouldOfferDeload(
          history,
          dismissedAt: DateTime(2026, 1, 25),
          now: DateTime(2026, 2, 15),
        ),
        isTrue,
      );
    });
  });

  group('deloadSuggestion', () {
    test('-40% sul carico massimo, arrotondato, reps della prima serie', () {
      final last = _exercise(sets: [
        _set(reps: 8, weightKg: 100),
        _set(reps: 8, weightKg: 90),
      ]);
      final s = WorkoutProgressService.deloadSuggestion(last);
      expect(s.direction, OverloadDirection.decrease);
      expect(s.isDeload, isTrue);
      expect(s.suggestedWeightKg, 60);
      expect(s.suggestedReps, 8);
    });

    test('nessuna serie di lavoro → nessun valore suggerito ma isDeload true', () {
      final last = _exercise(sets: []);
      final s = WorkoutProgressService.deloadSuggestion(last);
      expect(s.suggestedWeightKg, isNull);
      expect(s.suggestedReps, isNull);
      expect(s.isDeload, isTrue);
    });
  });
}

