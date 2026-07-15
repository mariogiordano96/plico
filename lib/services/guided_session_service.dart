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

  /// Esercizio con il turno nel blocco superset: quello, tra i non ancora
  /// completati, con meno unità (serie/cardio) confermate — a parità il primo
  /// del blocco. Deriva il turno solo da `confirmed`/`cardioConfirmed`
  /// (nessun cursore separato: robusto al resume di una sessione interrotta).
  /// Realizza l'alternanza A1,B1,C1,A2,B2,C2... Un esercizio con più o meno
  /// serie degli altri viene semplicemente saltato quando esaurisce le
  /// proprie, senza rompere l'alternanza degli altri. `null` se il blocco è
  /// già completo.
  static WorkoutExercise? turnFor(List<WorkoutExercise> step) {
    WorkoutExercise? turn;
    var bestDone = 1 << 30;
    for (final e in step) {
      final total = e.isCardio ? 1 : e.sets.length;
      final done =
          e.isCardio ? (e.cardioConfirmed ? 1 : 0) : e.sets.where((s) => s.confirmed).length;
      if (done >= total) continue;
      if (done < bestDone) {
        bestDone = done;
        turn = e;
      }
    }
    return turn;
  }

  /// Vero quando il blocco è a esercizio singolo (nessuna restrizione
  /// d'ordine, riposo dopo ogni serie) oppure quando l'intero blocco
  /// superset è completo — condizione per mostrare il timer di riposo solo a
  /// fine blocco, non tra un esercizio e l'altro né tra un round e il
  /// successivo.
  static bool isStepComplete(List<WorkoutExercise> step, bool Function(WorkoutExercise) isDone) =>
      step.length <= 1 || step.every(isDone);

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
