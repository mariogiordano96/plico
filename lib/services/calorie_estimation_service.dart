/// Stima indicativa delle kcal bruciate in allenamento — non un dato medico.
/// Vedi docs/evolutiva_esercizi.md, sezione "Stima calorie bruciate".
class CalorieEstimationService {
  static const defaultBodyWeightKg = 75.0;

  // MET fisso per la forza: euristica semplice, indipendente dal peso sollevato
  // (funziona anche per esercizi a corpo libero, dove weightKg è spesso null).
  static const _strengthMet = 4.0;
  static const _secondsPerSetEstimate = 150; // 2.5 min per serie (lavoro + recupero)

  // MET per esercizio cardio, sui 14 esercizi cardio reali del dataset
  // free-exercise-db (vedi tool/seed_exercises.dart). Fallback su _defaultCardioMet
  // per esercizi cardio custom o non mappati.
  static const Map<String, double> _cardioMet = {
    'Bicycling': 8.0,
    'Bicycling_Stationary': 6.8,
    'Elliptical_Trainer': 5.0,
    'Jogging_Treadmill': 8.0,
    'Prowler_Sprint': 8.0,
    'Recumbent_Bike': 5.0,
    'Rope_Jumping': 10.0,
    'Rowing_Stationary': 7.0,
    'Running_Treadmill': 9.5,
    'Skating': 7.0,
    'Stairmaster': 9.0,
    'Step_Mill': 9.0,
    'Trail_Running_Walking': 6.0,
    'Walking_Treadmill': 3.5,
  };
  static const _defaultCardioMet = 6.0;

  static double metForCardioExercise(String exerciseId) =>
      _cardioMet[exerciseId] ?? _defaultCardioMet;

  static int estimateCardioKcal({
    required String exerciseId,
    required int durationSeconds,
    double? bodyWeightKg,
  }) {
    final met = metForCardioExercise(exerciseId);
    final weight = bodyWeightKg ?? defaultBodyWeightKg;
    final hours = durationSeconds / 3600;
    return (met * weight * hours).round();
  }

  static int estimateStrengthKcal({
    required int workingSetCount,
    double? bodyWeightKg,
  }) {
    final weight = bodyWeightKg ?? defaultBodyWeightKg;
    final hours = (workingSetCount * _secondsPerSetEstimate) / 3600;
    return (_strengthMet * weight * hours).round();
  }
}
