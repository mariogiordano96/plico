import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/achievement.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/enums.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/models/user_profile.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/services/achievement_service.dart';
import 'package:plico/services/database_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_achievements_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> logWorkout(DateTime day) async {
    await DatabaseService.instance.addWorkoutExercise(
      day,
      WorkoutExercise()..exerciseId = 'x'..exerciseName = 'x',
    );
  }

  Future<void> logMeal(DateTime day) async {
    await DatabaseService.instance
        .addMealEntry(day, MealEntry()..kcalPer100g = 100..quantitaG = 100);
  }

  test('nessun dato → nessun achievement sbloccato', () async {
    await AchievementService.instance.checkAll();
    expect(await DatabaseService.instance.getUnlockedTypes(), isEmpty);
  });

  test('hasNewWorkoutPr sblocca sempre newWorkoutPr', () async {
    await AchievementService.instance.checkAll(hasNewWorkoutPr: true);
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.newWorkoutPr));
  });

  test('primo allenamento sblocca firstWorkout', () async {
    await logWorkout(DateTime.now());
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.firstWorkout));
  });

  test('7 allenamenti consecutivi sbloccano workoutStreak7', () async {
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      await logWorkout(now.subtract(Duration(days: i)));
    }
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.workoutStreak7));
  });

  test('10 sessioni distinte sbloccano workoutSessions10 ma non workoutSessions50', () async {
    final now = DateTime.now();
    for (var i = 0; i < 10; i++) {
      await logWorkout(now.subtract(Duration(days: i)));
    }
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.workoutSessions10));
    expect(unlocked, isNot(contains(AchievementType.workoutSessions50)));
  });

  test('50 sessioni distinte sbloccano anche workoutSessions50', () async {
    final now = DateTime.now();
    for (var i = 0; i < 50; i++) {
      await logWorkout(now.subtract(Duration(days: i)));
    }
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.workoutSessions50));
  });

  test('perdita di almeno 1kg tra il primo e l\'ultimo snapshot sblocca firstKgLost', () async {
    final db = DatabaseService.instance;
    await db.addBodySnapshot(BodySnapshot()..pesoKg = 82..data = DateTime.now().subtract(const Duration(days: 30)));
    await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = DateTime.now());
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.firstKgLost));
  });

  test('meno di 1kg perso non sblocca firstKgLost', () async {
    final db = DatabaseService.instance;
    await db.addBodySnapshot(BodySnapshot()..pesoKg = 80.5..data = DateTime.now().subtract(const Duration(days: 30)));
    await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = DateTime.now());
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, isNot(contains(AchievementType.firstKgLost)));
  });

  test('7 giorni di log consecutivi sbloccano streak7', () async {
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      await logMeal(now.subtract(Duration(days: i)));
    }
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.streak7));
  });

  test('30 giorni loggati (anche non consecutivi) sbloccano days30Logged', () async {
    final now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      await logMeal(now.subtract(Duration(days: i * 2))); // ogni 2 giorni, entro i 730 di storico
    }
    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.days30Logged));
  });

  test('7 giorni entro il target kcal (90-105%) sbloccano weekOnTarget', () async {
    final db = DatabaseService.instance;
    await db.saveUserProfile(UserProfile()
      ..id = 1
      ..nome = 'Test'
      ..cognome = 'User'
      ..dataNascita = DateTime(1996, 1, 1)
      ..sesso = Sesso.maschio
      ..altezzaCm = 175
      ..createdAt = DateTime.now());
    await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = DateTime.now());
    await db.saveLivelloAttivita(2);
    await db.saveObiettivo(1);
    await db.saveMetodoTdee(2);

    final target = await AchievementService.instance.currentKcalTarget();
    expect(target, isNotNull);

    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      await db.addMealEntry(
        now.subtract(Duration(days: i)),
        MealEntry()..kcalPer100g = target!.toDouble()..quantitaG = 100, // esattamente sul target
      );
    }

    await AchievementService.instance.checkAll();
    final unlocked = await DatabaseService.instance.getUnlockedTypes();
    expect(unlocked, contains(AchievementType.weekOnTarget));
  });
}
