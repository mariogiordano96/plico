import '../models/exercise_definition.dart';

/// Ranking puro per la sostituzione esercizio al volo (Fase 13): nessuna
/// query Isar qui dentro, solo ordinamento di liste già caricate.
/// Vedi docs/evolutiva_esercizi.md, sezione "Sostituzione esercizio al volo".
class ExerciseAlternativesService {
  /// Candidati con lo stesso [ExerciseDefinition.muscleGroup] di [source]
  /// (escluso [source] stesso), ordinati per somiglianza decrescente: stesso
  /// `mechanic` e stesso `equipment` valgono più punti rispetto a un solo
  /// criterio in comune.
  static List<ExerciseDefinition> rank(
    ExerciseDefinition source,
    List<ExerciseDefinition> candidates,
  ) {
    final filtered = candidates
        .where((c) =>
            c.externalId != source.externalId && c.muscleGroup == source.muscleGroup)
        .toList();

    int score(ExerciseDefinition c) {
      var s = 0;
      if (source.mechanic != null && c.mechanic == source.mechanic) s += 2;
      if (source.equipment != null && c.equipment == source.equipment) s += 1;
      return s;
    }

    filtered.sort((a, b) => score(b).compareTo(score(a)));
    return filtered;
  }
}
