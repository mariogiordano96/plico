import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/services/database_service.dart';
import 'package:plico/services/streak_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_streak_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> logMeal(DateTime day) async {
    await DatabaseService.instance
        .addMealEntry(day, MealEntry()..kcalPer100g = 100..quantitaG = 100);
  }

  Future<void> logWorkout(DateTime day) async {
    await DatabaseService.instance.addWorkoutExercise(
      day,
      WorkoutExercise()..exerciseId = 'x'..exerciseName = 'x',
    );
  }

  group('currentStreak', () {
    test('nessun log → 0', () async {
      expect(await StreakService.instance.currentStreak(), 0);
    });

    test('giorni consecutivi da oggi contano la streak', () async {
      final now = DateTime.now();
      await logMeal(now);
      await logMeal(now.subtract(const Duration(days: 1)));
      await logMeal(now.subtract(const Duration(days: 2)));
      expect(await StreakService.instance.currentStreak(), 3);
    });

    test('un buco nella sequenza interrompe la streak', () async {
      final now = DateTime.now();
      await logMeal(now);
      await logMeal(now.subtract(const Duration(days: 1)));
      // giorno -2 mancante
      await logMeal(now.subtract(const Duration(days: 3)));
      expect(await StreakService.instance.currentStreak(), 2);
    });

    test('oggi non loggato ma ieri sì → la streak riparte da ieri', () async {
      final now = DateTime.now();
      await logMeal(now.subtract(const Duration(days: 1)));
      await logMeal(now.subtract(const Duration(days: 2)));
      expect(await StreakService.instance.currentStreak(), 2);
    });

    test('né oggi né ieri loggati → 0', () async {
      final now = DateTime.now();
      await logMeal(now.subtract(const Duration(days: 2)));
      expect(await StreakService.instance.currentStreak(), 0);
    });
  });

  group('currentWorkoutStreak', () {
    test('nessun allenamento → 0', () async {
      expect(await StreakService.instance.currentWorkoutStreak(), 0);
    });

    test('allenamenti consecutivi contano la streak', () async {
      final now = DateTime.now();
      await logWorkout(now);
      await logWorkout(now.subtract(const Duration(days: 1)));
      expect(await StreakService.instance.currentWorkoutStreak(), 2);
    });
  });
}
