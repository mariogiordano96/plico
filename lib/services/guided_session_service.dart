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

  /// Id degli esercizi di forza che devono avere il riscaldamento: il primo
  /// esercizio di ogni gruppo muscolare incontrato nella sessione (petto e
  /// dorso → uno per ciascuno). Nei blocchi superset la regola vale per ogni
  /// esercizio che li compone. Il cardio è ignorato. Gruppo muscolare
  /// sconosciuto → riscaldamento, per prudenza.
  static Set<int> warmupExerciseIds(
    List<List<WorkoutExercise>> steps,
    Map<String, String> muscleGroupByExerciseId,
  ) {
    final ids = <int>{};
    final seenGroups = <String>{};
    for (final step in steps) {
      for (final e in step) {
        if (e.isCardio) continue;
        final group = muscleGroupByExerciseId[e.exerciseId];
        if (group == null || seenGroups.add(group)) ids.add(e.id);
      }
    }
    return ids;
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
      final total = _total(e);
      final done = _done(e);
      if (done >= total) continue;
      if (done < bestDone) {
        bestDone = done;
        turn = e;
      }
    }
    return turn;
  }

  /// Vero quando [e] chiude un round del blocco: nessun altro esercizio dello
  /// step, tra quelli non ancora esauriti, è rimasto indietro rispetto a
  /// [e] (cioè con meno unità confermate). Su uno step a esercizio singolo è
  /// sempre vero (riposo dopo ogni serie, comportamento invariato). Su un
  /// blocco superset realizza "riposo dopo ogni round" (A1,B1,C1 → riposo;
  /// A2,B2,C2 → riposo; ...), non solo alla fine dell'ultimo round: un
  /// esercizio con più serie degli altri, rimasto a proseguire da solo dopo
  /// che gli altri hanno esaurito le proprie, chiude un "round" (di sé
  /// stesso) a ogni propria serie confermata, tornando così al normale
  /// riposo dopo ogni serie.
  static bool isEndOfRound(WorkoutExercise e, List<WorkoutExercise> step) {
    final done = _done(e);
    for (final f in step) {
      if (identical(f, e)) continue;
      if (_done(f) < _total(f) && _done(f) < done) return false;
    }
    return true;
  }

  static int _total(WorkoutExercise e) => e.isCardio ? 1 : e.sets.length;

  static int _done(WorkoutExercise e) =>
      e.isCardio ? (e.cardioConfirmed ? 1 : 0) : e.sets.where((s) => s.confirmed).length;

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
