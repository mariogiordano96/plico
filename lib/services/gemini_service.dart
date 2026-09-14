import 'dart:convert';
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

  static Future<String> sendMessage({
    required String apiKey,
    required String systemInstruction,
    required List<GeminiTurn> history,
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

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': history.map((t) => t.toJson()).toList(),
    });

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

    if (res.statusCode == 400 || res.statusCode == 403) {
      throw const GeminiException(GeminiErrorType.invalidApiKey);
    }
    if (res.statusCode == 429) {
      throw const GeminiException(GeminiErrorType.quotaExceeded);
    }
    if (res.statusCode != 200) {
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
