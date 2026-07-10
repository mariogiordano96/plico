import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/enums.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/models/meal_plan.dart';
import 'package:plico/models/user_profile.dart';
import 'package:plico/services/database_service.dart';
import 'package:plico/services/insights_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_insights_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> setupProfileForTarget() async {
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
  }

  group('generate — overshoot insight', () {
    test('nessun dato → nessun insight', () async {
      final insights = await InsightsService.instance.generate();
      expect(insights, isEmpty);
    });

    test('sforo ricorrente nello stesso giorno della settimana (3+ volte)', () async {
      await setupProfileForTarget();

      final now = DateTime.now();
      // 3 date nelle ultime 4 settimane con lo stesso weekday di oggi
      final sameWeekday = [7, 14, 21].map((d) => now.subtract(Duration(days: d)));
      for (final day in sameWeekday) {
        await DatabaseService.instance.addMealEntry(
          day,
          MealEntry()..kcalPer100g = 100000..quantitaG = 100, // pasto enorme, sfora qualunque target
        );
      }

      final insights = await InsightsService.instance.generate();
      expect(insights.any((i) => i.contains('Tendi a sforare')), isTrue);
    });
  });

  group('generate — protein insight', () {
    test('nessun piano alimentare → nessun insight proteine', () async {
      final insights = await InsightsService.instance.generate();
      expect(insights.any((i) => i.contains('proteina')), isFalse);
    });

    test('proteine costantemente sotto target (≥7 giorni su 14) → insight', () async {
      final db = DatabaseService.instance;
      await db.saveMealPlan(MealPlan()..proteineTotali = 150);

      final now = DateTime.now();
      for (var i = 0; i < 7; i++) {
        await db.addMealEntry(
          now.subtract(Duration(days: i)),
          MealEntry()..proteinPer100g = 50..quantitaG = 100, // 50g, ben sotto 150*0.9=135
        );
      }

      final insights = await InsightsService.instance.generate();
      expect(insights.any((i) => i.contains('proteina')), isTrue);
    });

    test('meno di 7 giorni loggati → nessun insight proteine', () async {
      final db = DatabaseService.instance;
      await db.saveMealPlan(MealPlan()..proteineTotali = 150);

      final now = DateTime.now();
      for (var i = 0; i < 3; i++) {
        await db.addMealEntry(
          now.subtract(Duration(days: i)),
          MealEntry()..proteinPer100g = 50..quantitaG = 100,
        );
      }

      final insights = await InsightsService.instance.generate();
      expect(insights.any((i) => i.contains('proteina')), isFalse);
    });

    test('proteine sopra target → nessun insight', () async {
      final db = DatabaseService.instance;
      await db.saveMealPlan(MealPlan()..proteineTotali = 100);

      final now = DateTime.now();
      for (var i = 0; i < 7; i++) {
        await db.addMealEntry(
          now.subtract(Duration(days: i)),
          MealEntry()..proteinPer100g = 150..quantitaG = 100, // ben sopra il target
        );
      }

      final insights = await InsightsService.instance.generate();
      expect(insights.any((i) => i.contains('proteina')), isFalse);
    });
  });
}
