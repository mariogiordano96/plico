/// Record personale (peso massimo storico) per un esercizio — calcolato a
/// runtime da [DatabaseService.getAllPersonalRecords], non persistito.
/// Vedi docs/evolutiva_esercizi.md, sezione "Bacheca record personali".
class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final String? muscleGroup;
  final double maxWeightKg;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.maxWeightKg,
    required this.achievedAt,
  });
}
