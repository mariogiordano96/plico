import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/app_settings.dart';
import 'package:plico/services/gemini_quota.dart';

void main() {
  group('GeminiQuota.rolloverIfNewDay', () {
    test('azzera il contatore se il giorno salvato è diverso da oggi', () {
      final settings = AppSettings()
        ..geminiRequestsToday = 42
        ..geminiRequestsResetDate = DateTime(2026, 1, 1);
      GeminiQuota.rolloverIfNewDay(settings, DateTime(2026, 1, 2, 10, 30));
      expect(settings.geminiRequestsToday, 0);
      expect(settings.geminiRequestsResetDate, DateTime(2026, 1, 2));
    });

    test('non tocca il contatore se è ancora lo stesso giorno', () {
      final settings = AppSettings()
        ..geminiRequestsToday = 42
        ..geminiRequestsResetDate = DateTime(2026, 1, 1);
      GeminiQuota.rolloverIfNewDay(settings, DateTime(2026, 1, 1, 23, 59));
      expect(settings.geminiRequestsToday, 42);
    });

    test('nessun reset salvato: inizializza a oggi con contatore zero', () {
      final settings = AppSettings();
      GeminiQuota.rolloverIfNewDay(settings, DateTime(2026, 1, 1));
      expect(settings.geminiRequestsToday, 0);
      expect(settings.geminiRequestsResetDate, DateTime(2026, 1, 1));
    });
  });

  group('GeminiQuota.remainingToday / dailyLimitReached', () {
    test('nessuna richiesta ancora oggi: tutta la quota disponibile', () {
      final settings = AppSettings();
      final now = DateTime(2026, 1, 1);
      expect(GeminiQuota.remainingToday(settings, now), GeminiQuota.dailyLimit);
      expect(GeminiQuota.dailyLimitReached(settings, now), isFalse);
    });

    test('quota esaurita oggi: remainingToday zero, limite raggiunto', () {
      final settings = AppSettings()
        ..geminiRequestsToday = GeminiQuota.dailyLimit
        ..geminiRequestsResetDate = DateTime(2026, 1, 1);
      expect(GeminiQuota.remainingToday(settings, DateTime(2026, 1, 1)), 0);
      expect(GeminiQuota.dailyLimitReached(settings, DateTime(2026, 1, 1)), isTrue);
    });

    test('contatore di un giorno passato non conta contro oggi', () {
      final settings = AppSettings()
        ..geminiRequestsToday = GeminiQuota.dailyLimit
        ..geminiRequestsResetDate = DateTime(2026, 1, 1);
      expect(GeminiQuota.remainingToday(settings, DateTime(2026, 1, 2)), GeminiQuota.dailyLimit);
    });
  });

  group('GeminiQuota.perMinuteLimitReached', () {
    test('meno di 10 richieste nell\'ultimo minuto: non raggiunto', () {
      final now = DateTime(2026, 1, 1, 12, 0, 0);
      final recent = List.generate(9, (i) => now.subtract(Duration(seconds: i * 2)));
      expect(GeminiQuota.perMinuteLimitReached(recent, now), isFalse);
    });

    test('10 richieste nell\'ultimo minuto: raggiunto', () {
      final now = DateTime(2026, 1, 1, 12, 0, 0);
      final recent = List.generate(10, (i) => now.subtract(Duration(seconds: i * 2)));
      expect(GeminiQuota.perMinuteLimitReached(recent, now), isTrue);
    });

    test('richieste più vecchie di un minuto non contano', () {
      final now = DateTime(2026, 1, 1, 12, 0, 0);
      final recent = List.generate(10, (i) => now.subtract(const Duration(minutes: 2)));
      expect(GeminiQuota.perMinuteLimitReached(recent, now), isFalse);
    });
  });
}
