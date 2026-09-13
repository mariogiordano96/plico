import 'package:isar/isar.dart';
import 'workout_set.dart'; // DropStage: nested in WorkoutTemplateExercise.plannedSets, isar_generator
                            // ha bisogno dell'import diretto qui, non basta quello transitivo
                            // via workout_template_exercise.dart (DropStageSchema non risolto altrimenti)
import 'workout_template_exercise.dart';

part 'workout_template.g.dart';

/// Una scheda rappresenta una singola sessione (es. "Push Day", o "Upper 1" se è
/// un giorno di un [WorkoutProgram]).
@collection
class WorkoutTemplate {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime createdAt;
  DateTime? lastUsedAt;
  bool isPreset = false; // true per le schede precaricate dall'app (read-only)

  @Index(type: IndexType.value)
  int? programId; // WorkoutProgram.id, null se la scheda è autonoma
  int order = 0; // posizione nella rotazione/visualizzazione del programma

  List<WorkoutTemplateExercise> exercises = [];
}
