import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/meal_entry.dart';
import 'package:plico/services/database_service.dart';
import 'package:plico/services/meal_timing_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_mealtiming_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> logPranzo(DateTime day, TimeOfDay ora) async {
    await DatabaseService.instance.addMealEntry(
      day,
      MealEntry()
        ..pastoTipo = 1 // pranzo
        ..orarioInserimento = DateTime(day.year, day.month, day.day, ora.hour, ora.minute),
    );
  }

  group('suggestedTime', () {
    test('meno di 5 campioni → null', () async {
      final today = DateTime.now();
      for (var i = 0; i < 4; i++) {
        await logPranzo(today.subtract(Duration(days: i)), const TimeOfDay(hour: 12, minute: 30));
      }
      final result = await MealTimingService.instance.suggestedTime(1);
      expect(result, isNull);
    });

    test('con almeno 5 campioni restituisce la media degli orari', () async {
      final today = DateTime.now();
      const orari = [
        TimeOfDay(hour: 12, minute: 0),
        TimeOfDay(hour: 12, minute: 10),
        TimeOfDay(hour: 12, minute: 20),
        TimeOfDay(hour: 12, minute: 30),
        TimeOfDay(hour: 12, minute: 40),
      ];
      for (var i = 0; i < orari.length; i++) {
        await logPranzo(today.subtract(Duration(days: i)), orari[i]);
      }
      final result = await MealTimingService.instance.suggestedTime(1);
      expect(result, const TimeOfDay(hour: 12, minute: 20));
    });

    test('ignora i pasti di un altro pastoTipo', () async {
      final today = DateTime.now();
      for (var i = 0; i < 5; i++) {
        await DatabaseService.instance.addMealEntry(
          today.subtract(Duration(days: i)),
          MealEntry()
            ..pastoTipo = 0 // colazione, non pranzo
            ..orarioInserimento = DateTime(today.year, today.month, today.day, 8, 0),
        );
      }
      final result = await MealTimingService.instance.suggestedTime(1);
      expect(result, isNull);
    });
  });
}
