import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/enums.dart';
import 'package:plico/models/user_profile.dart';
import 'package:plico/services/database_service.dart';
import 'package:plico/services/target_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_target_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  group('computeDailyTargets', () {
    test('null se il profilo non è ancora configurato', () async {
      final result = await computeDailyTargets();
      expect(result, (null, null, null, null));
    });

    test('null se manca uno snapshot del peso, anche col profilo presente', () async {
      final db = DatabaseService.instance;
      await db.saveUserProfile(UserProfile()
        ..id = 1
        ..nome = 'Test'
        ..cognome = 'User'
        ..dataNascita = DateTime(1996, 1, 1)
        ..sesso = Sesso.maschio
        ..altezzaCm = 175
        ..createdAt = DateTime.now());
      final result = await computeDailyTargets();
      expect(result, (null, null, null, null));
    });

    test('con profilo e peso calcola target kcal/macro coerenti', () async {
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
      await db.saveObiettivo(1); // mantenimento
      await db.saveMetodoTdee(2); // Mifflin-St Jeor

      final (kcal, prot, fat, carbs) = await computeDailyTargets();

      expect(kcal, isNotNull);
      expect(kcal, greaterThan(0));
      expect(prot, greaterThan(0));
      expect(fat, greaterThan(0));
      expect(carbs, greaterThanOrEqualTo(0));
      // Coerenza interna: le kcal dei 3 macro devono avvicinarsi al target totale
      final kcalDaMacro = prot! * 4 + fat! * 9 + carbs! * 4;
      expect(kcalDaMacro, closeTo(kcal!, kcal * 0.05));
    });

    test('obiettivo deficit produce un target kcal inferiore al mantenimento', () async {
      final db = DatabaseService.instance;
      await db.saveUserProfile(UserProfile()
        ..id = 1
        ..nome = 'Test'
        ..cognome = 'User'
        ..dataNascita = DateTime(1996, 1, 1)
        ..sesso = Sesso.femmina
        ..altezzaCm = 165
        ..createdAt = DateTime.now());
      await db.addBodySnapshot(BodySnapshot()..pesoKg = 65..data = DateTime.now());
      await db.saveLivelloAttivita(2);
      await db.saveMetodoTdee(2);

      await db.saveObiettivo(1); // mantenimento
      final (kcalMant, _, _, _) = await computeDailyTargets();

      await db.saveObiettivo(0); // deficit
      final (kcalDeficit, _, _, _) = await computeDailyTargets();

      expect(kcalDeficit!, lessThan(kcalMant!));
    });
  });
}
