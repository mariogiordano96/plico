import 'package:flutter_test/flutter_test.dart';
import 'package:plico/services/calorie_estimation_service.dart';

void main() {
  group('metForCardioExercise', () {
    test('esercizio mappato restituisce il MET specifico', () {
      expect(CalorieEstimationService.metForCardioExercise('Running_Treadmill'), 9.5);
      expect(CalorieEstimationService.metForCardioExercise('Rope_Jumping'), 10.0);
    });

    test('esercizio non mappato restituisce il default 6.0', () {
      expect(CalorieEstimationService.metForCardioExercise('custom_1234'), 6.0);
    });
  });

  group('estimateCardioKcal', () {
    test('formula MET × peso × ore, arrotondata all\'intero', () {
      // Running_Treadmill: MET 9.5, 70kg, 1800s (0.5h) -> 9.5*70*0.5 = 332.5 -> 333
      final kcal = CalorieEstimationService.estimateCardioKcal(
        exerciseId: 'Running_Treadmill',
        durationSeconds: 1800,
        bodyWeightKg: 70,
      );
      expect(kcal, 333);
    });

    test('bodyWeightKg null usa defaultBodyWeightKg (75kg)', () {
      final withDefault = CalorieEstimationService.estimateCardioKcal(
        exerciseId: 'Rope_Jumping',
        durationSeconds: 600,
      );
      final explicit = CalorieEstimationService.estimateCardioKcal(
        exerciseId: 'Rope_Jumping',
        durationSeconds: 600,
        bodyWeightKg: CalorieEstimationService.defaultBodyWeightKg,
      );
      expect(withDefault, explicit);
    });

    test('durata zero produce 0 kcal', () {
      final kcal = CalorieEstimationService.estimateCardioKcal(
        exerciseId: 'Running_Treadmill',
        durationSeconds: 0,
        bodyWeightKg: 70,
      );
      expect(kcal, 0);
    });
  });

  group('estimateStrengthKcal', () {
    test('formula MET fisso × peso × ore stimate per serie', () {
      // 4 serie, 2.5min/serie = 10min = 1/6h, MET 4.0, 80kg -> 4*80*(1/6) = 53.33 -> 53
      final kcal = CalorieEstimationService.estimateStrengthKcal(
        workingSetCount: 4,
        bodyWeightKg: 80,
      );
      expect(kcal, 53);
    });

    test('zero serie produce 0 kcal', () {
      final kcal = CalorieEstimationService.estimateStrengthKcal(workingSetCount: 0);
      expect(kcal, 0);
    });

    test('bodyWeightKg null usa il default', () {
      final withDefault = CalorieEstimationService.estimateStrengthKcal(workingSetCount: 3);
      final explicit = CalorieEstimationService.estimateStrengthKcal(
        workingSetCount: 3,
        bodyWeightKg: CalorieEstimationService.defaultBodyWeightKg,
      );
      expect(withDefault, explicit);
    });
  });
}
