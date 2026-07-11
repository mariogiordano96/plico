import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

/// Payload codificato nel QR mostrato da chi invia, letto da chi riceve —
/// indirizzo/porta del server locale one-shot e il token che lo sblocca.
class SyncPairing {
  final String ip;
  final int port;
  final String token;

  const SyncPairing({required this.ip, required this.port, required this.token});

  String toJson() => jsonEncode({'ip': ip, 'port': port, 'token': token});

  static SyncPairing? tryParse(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ip = map['ip'] as String?;
      final port = map['port'] as int?;
      final token = map['token'] as String?;
      if (ip == null || port == null || token == null) return null;
      return SyncPairing(ip: ip, port: port, token: token);
    } catch (_) {
      return null;
    }
  }
}

/// Server HTTP locale "one-shot" che serve un singolo file di backup a chi
/// lo richiede con il token corretto sulla stessa rete Wi-Fi, poi si
/// chiude da solo (prima richiesta valida, timeout, o stop esplicito).
class BackupSendServer {
  HttpServer? _server;
  bool _consumed = false;
  Timer? _timeoutTimer;

  /// Avvia il server e ritorna il [SyncPairing] da mostrare come QR, o
  /// null se non è stato possibile determinare l'IP Wi-Fi locale (es.
  /// nessuna rete Wi-Fi attiva).
  Future<SyncPairing?> start({
    required File file,
    required void Function() onTransferred,
    required void Function() onTimeout,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final ip = await NetworkInfo().getWifiIP();
    if (ip == null) return null;

    final token = _generateToken();

    Future<Response> handler(Request request) async {
      if (_consumed || request.url.queryParameters['token'] != token) {
        return Response.forbidden('');
      }
      _consumed = true;
      final bytes = await file.readAsBytes();
      // Ferma il server con un piccolo ritardo, dopo che la risposta è
      // uscita, invece che nello stesso istante in cui viene costruita.
      unawaited(Future.delayed(const Duration(seconds: 1), () {
        onTransferred();
        stop();
      }));
      return Response.ok(bytes, headers: {'content-type': 'application/octet-stream'});
    }

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
    _timeoutTimer = Timer(timeout, () {
      if (!_consumed) {
        onTimeout();
        stop();
      }
    });

    return SyncPairing(ip: ip, port: _server!.port, token: token);
  }

  Future<void> stop() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  static String _generateToken() {
    final rnd = Random.secure();
    return List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

/// Scarica il backup dal device che lo sta condividendo, dato il payload
/// letto dal QR. Ritorna il file scaricato (in una directory temporanea),
/// o null se la richiesta fallisce o va in timeout (es. device non sulla
/// stessa rete).
Future<File?> fetchBackupOverWifi(SyncPairing pairing) async {
  final uri = Uri.parse('http://${pairing.ip}:${pairing.port}/backup?token=${pairing.token}');
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) return null;
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/plico_wifi_backup_${DateTime.now().microsecondsSinceEpoch}.isar');
    await file.writeAsBytes(res.bodyBytes);
    return file;
  } catch (_) {
    return null;
  }
}
