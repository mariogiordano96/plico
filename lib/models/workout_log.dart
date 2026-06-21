import 'package:isar/isar.dart';

part 'workout_log.g.dart';

/// Un record per giorno (normalizzato a mezzanotte), come [DailyLog].
/// Gli esercizi del giorno NON sono linkati qui: si interrogano direttamente
/// `WorkoutExercise.filter().dateEqualTo(day)`, evitando IsarLinks dato che
/// `WorkoutExercise.date` è già denormalizzata per le query di storico (vedi
/// docs/evolutiva_esercizi.md).
@collection
class WorkoutLog {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime date;

  String? note; // Fase 9: nota libera sulla sessione
}
