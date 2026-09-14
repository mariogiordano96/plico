import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/coach_message.dart';
import 'package:plico/services/database_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_coach_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  group('getCoachMessages / addCoachMessage', () {
    test('nessun messaggio salvato: lista vuota', () async {
      final messages = await DatabaseService.instance.getCoachMessages();
      expect(messages, isEmpty);
    });

    test('restituisce i messaggi in ordine di creazione', () async {
      final db = DatabaseService.instance;
      await db.addCoachMessage(CoachMessage()
        ..createdAt = DateTime(2026, 1, 1, 10, 0)
        ..isUser = true
        ..text = 'quante proteine devo mangiare?');
      await db.addCoachMessage(CoachMessage()
        ..createdAt = DateTime(2026, 1, 1, 10, 1)
        ..isUser = false
        ..text = 'Dipende dal tuo obiettivo...');

      final messages = await db.getCoachMessages();
      expect(messages, hasLength(2));
      expect(messages[0].isUser, isTrue);
      expect(messages[0].text, 'quante proteine devo mangiare?');
      expect(messages[1].isUser, isFalse);
      expect(messages[1].isError, isFalse);
    });

    test('persiste il flag isError', () async {
      final db = DatabaseService.instance;
      await db.addCoachMessage(CoachMessage()
        ..createdAt = DateTime(2026, 1, 1)
        ..isUser = false
        ..text = 'Errore di rete'
        ..isError = true);

      final messages = await db.getCoachMessages();
      expect(messages.single.isError, isTrue);
    });
  });

  group('clearCoachMessages', () {
    test('rimuove tutti i messaggi persistiti', () async {
      final db = DatabaseService.instance;
      await db.addCoachMessage(CoachMessage()
        ..createdAt = DateTime(2026, 1, 1)
        ..isUser = true
        ..text = 'ciao');

      await db.clearCoachMessages();

      expect(await db.getCoachMessages(), isEmpty);
    });
  });
}
