import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/exercise_definition.dart';
import 'package:plico/services/exercise_alternatives_service.dart';

ExerciseDefinition _exercise({
  required String id,
  required String muscleGroup,
  String? mechanic,
  String? equipment,
}) {
  return ExerciseDefinition()
    ..externalId = id
    ..name = id
    ..muscleGroup = muscleGroup
    ..category = 'strength'
    ..mechanic = mechanic
    ..equipment = equipment;
}

void main() {
  group('ExerciseAlternativesService.rank', () {
    test('esclude la sorgente stessa dai candidati', () {
      final source = _exercise(id: 'squat', muscleGroup: 'legs');
      final result = ExerciseAlternativesService.rank(source, [source]);
      expect(result, isEmpty);
    });

    test('esclude candidati con un muscleGroup diverso', () {
      final source = _exercise(id: 'squat', muscleGroup: 'legs');
      final other = _exercise(id: 'bench', muscleGroup: 'chest');
      final result = ExerciseAlternativesService.rank(source, [other]);
      expect(result, isEmpty);
    });

    test('stesso mechanic ed equipment vale più di un solo criterio in comune', () {
      final source = _exercise(id: 'squat', muscleGroup: 'legs', mechanic: 'compound', equipment: 'barbell');
      final onlyMechanic = _exercise(id: 'lunge', muscleGroup: 'legs', mechanic: 'compound', equipment: 'dumbbell');
      final onlyEquipment = _exercise(id: 'legPress', muscleGroup: 'legs', mechanic: 'isolation', equipment: 'barbell');
      final both = _exercise(id: 'frontSquat', muscleGroup: 'legs', mechanic: 'compound', equipment: 'barbell');
      final neither = _exercise(id: 'legCurl', muscleGroup: 'legs', mechanic: 'isolation', equipment: 'machine');

      final result = ExerciseAlternativesService.rank(
          source, [neither, onlyEquipment, onlyMechanic, both]);

      expect(result.map((e) => e.externalId), ['frontSquat', 'lunge', 'legPress', 'legCurl']);
    });
  });
}
