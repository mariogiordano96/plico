import '../models/app_settings.dart';

/// Logica pura (no DB, no rete) per proteggere l'utente dal free tier Gemini
/// (docs/integrazione_flutter_gemma.md, Fase 7): 10 richieste/minuto, 1.500/
/// giorno. La chiave è dell'utente (bring-your-own-key, mai una chiave
/// condivisa Plico), quindi uno sforamento lo pagherebbe lui — questa classe
/// blocca nuove richieste PRIMA di interpellare l'API, non dopo un 429.
class GeminiQuota {
  static const dailyLimit = 1500;
  static const perMinuteLimit = 10;

  /// Azzera il contatore giornaliero in [settings] se [now] cade in un
  /// giorno diverso dall'ultimo salvato. Muta [settings] in place (stesso
  /// pattern del resto del codebase: mutare poi persistere), il chiamante
  /// decide se/quando salvare.
  static void rolloverIfNewDay(AppSettings settings, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (settings.geminiRequestsResetDate != today) {
      settings.geminiRequestsResetDate = today;
      settings.geminiRequestsToday = 0;
    }
  }

  /// Richieste ancora disponibili oggi, dopo l'eventuale rollover. Non muta
  /// [settings]: chiama [rolloverIfNewDay] prima se serve un valore aggiornato
  /// da persistere.
  static int remainingToday(AppSettings settings, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final usedToday = settings.geminiRequestsResetDate == today ? settings.geminiRequestsToday : 0;
    return (dailyLimit - usedToday).clamp(0, dailyLimit);
  }

  static bool dailyLimitReached(AppSettings settings, DateTime now) =>
      remainingToday(settings, now) <= 0;

  /// Vero se, contando anche una nuova richiesta a [now], si supererebbe il
  /// limite per-minuto — [recentRequestTimes] è la lista (già filtrata o da
  /// filtrare qui) dei timestamp delle richieste inviate di recente.
  static bool perMinuteLimitReached(List<DateTime> recentRequestTimes, DateTime now) {
    final withinLastMinute =
        recentRequestTimes.where((t) => now.difference(t) < const Duration(minutes: 1)).length;
    return withinLastMinute >= perMinuteLimit;
  }
}
