import 'package:isar/isar.dart';

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

  bool get isCardio => targetDurationSeconds != null;
}
