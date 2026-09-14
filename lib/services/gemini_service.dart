import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'database_service.dart';
import 'gemini_quota.dart';

/// Un turno della conversazione da mandare a Gemini (formato REST
/// `contents[]`, vedi https://ai.google.dev/api/generate-content).
class GeminiTurn {
  final bool isUser;
  final String text;
  const GeminiTurn({required this.isUser, required this.text});

  Map<String, dynamic> toJson() => {
        'role': isUser ? 'user' : 'model',
        'parts': [
          {'text': text}
        ],
      };
}

enum GeminiErrorType {
  invalidApiKey,
  quotaExceeded,
  dailyLimitReached,
  rateLimited,
  network,
  serviceUnavailable,
  unknown,
}

class GeminiException implements Exception {
  final GeminiErrorType type;
  const GeminiException(this.type);
}

/// Chiamata REST diretta all'API Gemini con la chiave dell'utente (bring-
/// your-own-key — docs/integrazione_flutter_gemma.md, Fase 7): nessun backend
/// Plico, nessuna chiave condivisa, nessuna dipendenza da `firebase_ai` (che
/// userebbe un progetto Firebase di Plico, non dell'utente).
class GeminiService {
  static const _model = 'gemini-flash-latest';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  // Solo per il limite per-minuto (sezione "rate limit" del free tier): non
  // ha senso persisterlo, è una finestra scorrevole di 60s.
  static final List<DateTime> _recentRequestTimes = [];

  /// Richieste ancora disponibili oggi secondo il contatore locale — per la
  /// UI ("N richieste rimaste"), non fa chiamate di rete.
  static Future<int> remainingToday() async {
    final settings = await DatabaseService.instance.getAppSettings();
    return GeminiQuota.remainingToday(settings, DateTime.now());
  }

  /// [onRetrying] è chiamato prima di ogni retry per 503 (con il numero del
  /// tentativo, 1-based) — permette alla UI di mostrare "sto riprovando..."
  /// invece di uno spinner muto durante i secondi di attesa.
  static Future<String> sendMessage({
    required String apiKey,
    required String systemInstruction,
    required List<GeminiTurn> history,
    void Function(int attempt)? onRetrying,
  }) async {
    final now = DateTime.now();
    final settings = await DatabaseService.instance.getAppSettings();
    GeminiQuota.rolloverIfNewDay(settings, now);
    if (GeminiQuota.dailyLimitReached(settings, now)) {
      throw const GeminiException(GeminiErrorType.dailyLimitReached);
    }
    if (GeminiQuota.perMinuteLimitReached(_recentRequestTimes, now)) {
      throw const GeminiException(GeminiErrorType.rateLimited);
    }

    // Il conteggio scatta sul tentativo di invio, non solo su una risposta
    // 200: protegge comunque l'utente anche se la richiesta fallisce a metà
    // (es. errore di rete dopo che il pacchetto è partito).
    _recentRequestTimes.add(now);
    settings.geminiRequestsToday += 1;
    await DatabaseService.instance.saveAppSettings(settings);

    // Nomi campo camelCase (mapping JSON del protobuf REST di Google, non
    // snake_case): `systemInstruction`, non `system_instruction` — un nome
    // sbagliato qui dava un 400 "Unknown name" mascherato da noi come "chiave
    // non valida", anche con una chiave corretta.
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': history.map((t) => t.toJson()).toList(),
    });

    // Un 503/UNAVAILABLE ("modello sovraccarico") è transitorio lato Google,
    // non un problema della richiesta o della chiave — osservato dal vivo
    // (2026-09), anche 2-3 volte di fila nella stessa sessione: il free tier
    // ha priorità più bassa di un piano a pagamento nei picchi di domanda.
    // Fino a 2 retry con attesa crescente (2s, poi 4s) prima di arrendersi,
    // non solo un tentativo. Non riconta sulla quota (già incrementata una
    // volta sopra, per questo singolo "invio" logico dell'utente).
    const retryDelays = [Duration(seconds: 2), Duration(seconds: 4)];
    for (var attempt = 0; ; attempt++) {
      try {
        return await _postOnce(apiKey: apiKey, body: body);
      } on GeminiException catch (e) {
        if (e.type != GeminiErrorType.serviceUnavailable || attempt >= retryDelays.length) {
          rethrow;
        }
        onRetrying?.call(attempt + 1);
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
  }

  static Future<String> _postOnce({required String apiKey, required String body}) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$_endpoint?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const GeminiException(GeminiErrorType.network);
    }

    if (res.statusCode != 200) {
      // Log diagnostico (solo logcat/console, niente PII oltre al messaggio
      // d'errore di Google): senza questo, un errore REST inatteso è
      // invisibile — la UI mostra solo un messaggio generico localizzato.
      debugPrint('GeminiService: HTTP ${res.statusCode} — ${res.body}');
      // La chiave non valida arriva come 400 INVALID_ARGUMENT con reason
      // "API_KEY_INVALID" dentro error.details[] (ErrorInfo), non come
      // error.status — verificato live sulla REST API reale (2026-09), non
      // solo dedotto dalla documentazione. Stessa fonte per UNAVAILABLE/503
      // ("modello sovraccarico"), osservato dal vivo lo stesso giorno.
      String? status;
      String? reason;
      try {
        final error =
            (jsonDecode(res.body) as Map<String, dynamic>)['error'] as Map<String, dynamic>?;
        status = error?['status'] as String?;
        final details = error?['details'] as List?;
        reason = details
            ?.map((d) => (d as Map<String, dynamic>)['reason'] as String?)
            .firstWhere((r) => r != null, orElse: () => null);
      } catch (_) {
        // Corpo non-JSON (es. pagina di errore del proxy): status/reason
        // restano null, ricade sull'euristica per status code sotto.
      }
      if (reason == 'API_KEY_INVALID' ||
          status == 'UNAUTHENTICATED' ||
          status == 'PERMISSION_DENIED' ||
          (status == null && reason == null && (res.statusCode == 400 || res.statusCode == 403))) {
        throw const GeminiException(GeminiErrorType.invalidApiKey);
      }
      if (status == 'RESOURCE_EXHAUSTED' || res.statusCode == 429) {
        throw const GeminiException(GeminiErrorType.quotaExceeded);
      }
      if (status == 'UNAVAILABLE' || res.statusCode == 503) {
        throw const GeminiException(GeminiErrorType.serviceUnavailable);
      }
      throw const GeminiException(GeminiErrorType.unknown);
    }

    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      List? parts;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>?;
        parts = content?['parts'] as List?;
      }
      final text = parts?.map((p) => (p as Map<String, dynamic>)['text'] ?? '').join() ?? '';
      if (text.isEmpty) throw const GeminiException(GeminiErrorType.unknown);
      return text;
    } on GeminiException {
      rethrow;
    } catch (_) {
      throw const GeminiException(GeminiErrorType.unknown);
    }
  }

  /// Verifica rapida che la chiave sia valida, usata al salvataggio nella UI
  /// di setup: un messaggio minimo, così un errore emerge subito invece che
  /// alla prima domanda reale in chat.
  static Future<void> validateApiKey(String apiKey) async {
    await sendMessage(
      apiKey: apiKey,
      systemInstruction: 'Rispondi solo con la parola "ok".',
      history: const [GeminiTurn(isUser: true, text: 'ping')],
    );
  }
}
