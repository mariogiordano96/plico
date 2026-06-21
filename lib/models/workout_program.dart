import 'package:isar/isar.dart';

part 'workout_program.g.dart';

/// Raggruppa più [WorkoutTemplate] (i "giorni" del programma, es. Upper/Lower, PPL).
/// I giorni referenziano il programma tramite `WorkoutTemplate.programId` (FK
/// denormalizzata): niente IsarLinks/Backlink, coerente con il resto dell'app
/// (vedi correzione in docs/evolutiva_esercizi.md).
@collection
class WorkoutProgram {
  Id id = Isar.autoIncrement;

  late String name;
  late DateTime createdAt;
  bool isPreset = false;
}
