import 'package:isar/isar.dart';

part 'exercise_definition.g.dart';

@collection
class ExerciseDefinition {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String externalId; // id originale yuhonas, o UUID per i custom

  late String name; // nome originale inglese
  String? nameIt; // override italiano (null -> mostra name)

  @Index(type: IndexType.value)
  late String muscleGroup; // chest | back | legs | arms | core | shoulders | cardio

  late String category; // strength | cardio | stretching | plyometrics | powerlifting | ...
  String? equipment;
  String? level; // beginner | intermediate | expert
  String? mechanic; // compound | isolation

  List<String> instructions = [];

  bool isCustom = false;
  bool isDeleted = false;

  /// Nome da mostrare per la lingua corrente. Il dataset esterno ha solo
  /// `name` (inglese, originale) e `nameIt` (traduzione italiana curata, non
  /// ancora completa per tutti gli esercizi) — con locale inglese va sempre
  /// mostrato `name`, anche quando esiste una `nameIt`, altrimenti un utente
  /// EN vedrebbe nomi in italiano.
  String localizedName(String languageCode) {
    if (languageCode == 'it' && nameIt != null && nameIt!.isNotEmpty) {
      return nameIt!;
    }
    return name;
  }
}
