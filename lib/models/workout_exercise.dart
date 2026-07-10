import 'package:isar/isar.dart';
import 'workout_set.dart';

part 'workout_exercise.g.dart';

@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String exerciseId; // ExerciseDefinition.externalId
  late String exerciseName; // snapshot del nome al momento del log

  @Index(type: IndexType.value)
  late DateTime date; // normalizzata a mezzanotte: query dirette per giorno e per storico

  int? supersetGroupId; // Fase 12: esercizi eseguiti in sequenza senza riposo tra loro
  int? restSeconds; // Fase 8: riposo dopo l'ultima serie/il completamento

  // Per cardio
  int? durationSeconds;
  int? met; // valore MET usato per la stima (Fase 5)

  // Per strength — embedded, non IsarLinks: WorkoutSet non ha bisogno di query indipendenti
  List<WorkoutSet> sets = [];

  int? estimatedKcal; // calcolato e persistito al salvataggio (Fase 5)

  // Fase 21: tracciabilità della scheda/programma di provenienza, valorizzati solo
  // quando l'esercizio nasce da startWorkoutFromTemplate (null per il log libero).
  // Snapshot (non solo l'id) così il riferimento resta leggibile anche se la scheda
  // o il programma vengono rinominati o eliminati in seguito.
  int? sourceTemplateId;
  String? sourceTemplateName;
  int? sourceProgramId;
  String? sourceProgramName;
}
