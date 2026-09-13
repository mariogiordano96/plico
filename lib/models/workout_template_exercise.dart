import 'package:isar/isar.dart';
import 'workout_set.dart';

part 'workout_template_exercise.g.dart';

@embedded
class WorkoutTemplateExercise {
  String exerciseId = ''; // ExerciseDefinition.externalId
  String exerciseName = ''; // snapshot

  int? targetSets;
  int? targetReps;
  double? targetWeightKg;
  int? targetDurationSeconds; // per cardio

  int? supersetGroupId; // Fase 12: esercizi eseguiti senza riposo tra loro
  int? restSeconds; // Fase 8: riposo target dopo l'ultima serie/il completamento
  // SupersetRole.name (docs/tecniche_allenamento.md, Fase 3) — abbinamento
  // esplosiva/lenta nel superset, scelta strutturale sulla coppia quindi a
  // livello di template (diversamente dalla piramide, decisa il giorno
  // stesso su WorkoutExercise/WorkoutSet, non qui).
  String? supersetRole;

  // Fase 7 (docs/tecniche_allenamento.md): quando valorizzata, sostituisce il
  // target uniforme (targetSets×targetReps@targetWeightKg) con serie
  // pianificate singolarmente — piramide, rest-pause, stripping ecc. decise
  // già in creazione scheda invece che il giorno stesso. `null`/vuota per
  // ogni scheda già esistente e per chi non pianifica le tecniche in
  // anticipo: nessuna migrazione necessaria, vedi `materializeSets`.
  List<WorkoutTemplateSet>? plannedSets;

  bool get isCardio => targetDurationSeconds != null;

  /// Genera le `WorkoutSet` del log del giorno da questo target — unica
  /// fonte di verità usata da `startWorkoutFromTemplate`,
  /// `_aggiungiEsercizio` e `_modifica` (`allenamento_screen.dart`), che
  /// prima duplicavano lo stesso `List.generate` in 3 punti. Se
  /// [plannedSets] è valorizzato la tecnica pianificata viene copiata
  /// 1:1 sulla serie reale, altrimenti si torna al target uniforme.
  List<WorkoutSet> materializeSets() {
    final planned = plannedSets;
    if (planned != null && planned.isNotEmpty) {
      return planned
          .map((ps) => WorkoutSet()
            ..reps = ps.reps
            ..weightKg = ps.weightKg
            ..forcedReps = ps.forcedReps
            ..isSuperSlow = ps.isSuperSlow
            ..restPauseClusters =
                ps.restPauseClusters != null ? List<int>.from(ps.restPauseClusters!) : null
            ..dropStages = ps.dropStages
                ?.map((d) => DropStage()
                  ..reps = d.reps
                  ..weightKg = d.weightKg)
                .toList())
          .toList();
    }
    return List.generate(
      targetSets ?? 1,
      (_) => WorkoutSet()
        ..reps = targetReps
        ..weightKg = targetWeightKg,
    );
  }
}

/// Una serie pianificata in creazione scheda, con la tecnica già decisa
/// (Fase 7) — stessi campi tecnica di `WorkoutSet`, ma senza `rpe`,
/// `isWarmup`, `confirmed`: concetti che hanno senso solo il giorno
/// dell'esecuzione reale, non nel template riutilizzabile.
@embedded
class WorkoutTemplateSet {
  int? reps;
  double? weightKg;
  int? forcedReps;
  bool isSuperSlow = false;
  List<int>? restPauseClusters;
  List<DropStage>? dropStages;

  /// Stessa logica di priorità di `WorkoutSet.technique` (mutuamente
  /// esclusive per costruzione, un solo gruppo di campi scritto per serie).
  @ignore
  SetTechnique get technique {
    if (forcedReps != null) return SetTechnique.forzate;
    if (isSuperSlow) return SetTechnique.superSlow;
    if (restPauseClusters?.isNotEmpty == true) return SetTechnique.restPause;
    if (dropStages?.isNotEmpty == true) return SetTechnique.stripping;
    return SetTechnique.normale;
  }

  /// Copia profonda — usata da `duplicateTemplate` per non condividere le
  /// liste embedded (`restPauseClusters`/`dropStages`) tra scheda originale
  /// e duplicata prima che entrambe vengano scritte su Isar.
  WorkoutTemplateSet copy() => WorkoutTemplateSet()
    ..reps = reps
    ..weightKg = weightKg
    ..forcedReps = forcedReps
    ..isSuperSlow = isSuperSlow
    ..restPauseClusters = restPauseClusters != null ? List<int>.from(restPauseClusters!) : null
    ..dropStages = dropStages?.map((d) => DropStage()
      ..reps = d.reps
      ..weightKg = d.weightKg).toList();
}
