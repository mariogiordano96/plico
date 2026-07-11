import '../models/workout_exercise.dart';
import 'workout_progress_service.dart';

/// Logica pura (no DB) per la modalità esecuzione guidata. Vedi
/// docs/evolutiva_esercizi.md, sezione "Modalità esecuzione guidata (sessione attiva)".
class GuidedSessionService {
  /// Raggruppa gli esercizi in "step" della sessione guidata: esercizi consecutivi
  /// con lo stesso `supersetGroupId` (non null) formano un unico step (blocco
  /// superset), tutti gli altri sono step di un solo esercizio.
  static List<List<WorkoutExercise>> groupSteps(List<WorkoutExercise> exercises) {
    final steps = <List<WorkoutExercise>>[];
    for (final e in exercises) {
      final groupId = e.supersetGroupId;
      final currentStep = steps.isEmpty ? null : steps.last;
      if (groupId != null &&
          currentStep != null &&
          currentStep.first.supersetGroupId == groupId) {
        currentStep.add(e);
      } else {
        steps.add([e]);
      }
    }
    return steps;
  }

  static int totalEstimatedKcal(List<WorkoutExercise> exercises) =>
      exercises.fold<int>(0, (sum, e) => sum + (e.estimatedKcal ?? 0));

  /// Esercizi della sessione che sono un nuovo record personale, confrontati con
  /// [priorHistoryByExerciseId] (lo storico precedente alla sessione corrente,
  /// quindi senza gli stessi `WorkoutExercise` appena creati/aggiornati). Gli
  /// esercizi cardio non hanno un concetto di PR sul carico.
  static List<WorkoutExercise> newPersonalRecords(
    List<WorkoutExercise> session,
    Map<String, List<WorkoutExercise>> priorHistoryByExerciseId,
  ) {
    return session.where((e) {
      if (e.isCardio) return false;
      final prior = priorHistoryByExerciseId[e.exerciseId] ?? const [];
      return WorkoutProgressService.isNewPersonalRecord(e, prior);
    }).toList();
  }
}
