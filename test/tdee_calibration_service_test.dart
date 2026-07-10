import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/services/database_service.dart';
import 'package:plico/services/tdee_calibration_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_tdeecal_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> logDay(DateTime day, double kcal) async {
    await DatabaseService.instance.addMealEntry(
      day,
      MealEntry()..kcalPer100g = kcal..quantitaG = 100,
    );
  }

  group('suggestion', () {
    test('meno di 2 snapshot → null', () async {
      final db = DatabaseService.instance;
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = DateTime.now());
      final result = await TdeeCalibrationService.instance.suggestion(2500);
      expect(result, isNull);
    });

    test('snapshot troppo vicini nel tempo (< 14 giorni) → null', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 82..data = now.subtract(const Duration(days: 5)));
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = now);
      final result = await TdeeCalibrationService.instance.suggestion(2500);
      expect(result, isNull);
    });

    test('meno di 10 giorni loggati nel periodo → null', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();
      final oldest = now.subtract(const Duration(days: 20));
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 82..data = oldest);
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = now);
      for (var i = 0; i < 5; i++) {
        await logDay(oldest.add(Duration(days: i)), 2000);
      }
      final result = await TdeeCalibrationService.instance.suggestion(2000);
      expect(result, isNull);
    });

    test('suggerimento entro 50 kcal dal TDEE corrente → null (nessuna calibrazione utile)', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();
      final oldest = now.subtract(const Duration(days: 20));
      // peso invariato → suggestedTdee ≈ avgKcal
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = oldest);
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = now);
      for (var i = 0; i < 10; i++) {
        await logDay(oldest.add(Duration(days: i)), 2000);
      }
      final result = await TdeeCalibrationService.instance.suggestion(2000);
      expect(result, isNull);
    });

    test('con dati sufficienti calcola un nuovo TDEE suggerito', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();
      final oldest = now.subtract(const Duration(days: 20));
      // -2kg in 20 giorni mangiando 2000kcal/giorno → suggestedTdee = 2000 + 2*7700/20 = 2770
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 82..data = oldest);
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 80..data = now);
      for (var i = 0; i < 10; i++) {
        await logDay(oldest.add(Duration(days: i)), 2000);
      }
      final result = await TdeeCalibrationService.instance.suggestion(2000);
      expect(result, isNotNull);
      expect(result!.suggestedTdee, closeTo(2770, 5));
      expect(result.currentTdee, 2000);
      expect(result.days, 20);
    });
  });
}
