// Standalone Dart script: converte exercise_db_raw.json (free-exercise-db) in assets/data/exercises_seed.json
// Eseguire dalla root del progetto: dart tool/seed_exercises.dart

import 'dart:convert';
import 'dart:io';

const _muscleGroupMap = {
  'chest': 'chest',
  'lats': 'back',
  'middle back': 'back',
  'lower back': 'back',
  'traps': 'back',
  'quadriceps': 'legs',
  'hamstrings': 'legs',
  'glutes': 'legs',
  'calves': 'legs',
  'adductors': 'legs',
  'abductors': 'legs',
  'biceps': 'arms',
  'triceps': 'arms',
  'forearms': 'arms',
  'abdominals': 'core',
  'shoulders': 'shoulders',
  'neck': 'shoulders',
};

void main() async {
  final rawFile = File('exercise_db_raw.json');
  if (!rawFile.existsSync()) {
    print('File non trovato: exercise_db_raw.json');
    exit(1);
  }

  final overridesFile = File('tool/exercises_it_overrides.json');
  final overrides = overridesFile.existsSync()
      ? (jsonDecode(overridesFile.readAsStringSync()) as Map<String, dynamic>)
          .cast<String, String>()
      : <String, String>{};

  final list = jsonDecode(rawFile.readAsStringSync()) as List<dynamic>;

  final exercises =
      list.map((e) => _buildExercise(e as Map<String, dynamic>, overrides)).toList();

  final jsonStr = const JsonEncoder.withIndent('  ').convert(exercises);
  File('assets/data/exercises_seed.json').writeAsStringSync(jsonStr);
  final translated = exercises.where((e) => e['nameIt'] != null).length;
  print('Generati ${exercises.length} esercizi ($translated tradotti) -> '
      'assets/data/exercises_seed.json');
}

Map<String, dynamic> _buildExercise(Map<String, dynamic> e, Map<String, String> overrides) {
  final category = e['category'] as String;
  final primaryMuscles = (e['primaryMuscles'] as List<dynamic>?)?.cast<String>() ?? [];
  final externalId = e['id'] as String;

  final muscleGroup = category == 'cardio'
      ? 'cardio'
      : (primaryMuscles.isNotEmpty ? _muscleGroupMap[primaryMuscles.first] : null) ?? 'core';

  return {
    'externalId': externalId,
    'name': e['name'] as String,
    'nameIt': overrides[externalId],
    'muscleGroup': muscleGroup,
    'category': category,
    'equipment': e['equipment'] as String?,
    'level': e['level'] as String?,
    'mechanic': e['mechanic'] as String?,
    'instructions': (e['instructions'] as List<dynamic>?)?.cast<String>() ?? [],
  };
}
