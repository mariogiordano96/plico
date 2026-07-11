import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/sync_transfer_service.dart';
import '../../theme/app_theme.dart';

/// Scanner minimale e self-contained per il pairing Wi-Fi (payload
/// [SyncPairing] letto da un QR, non un barcode alimento — per questo non
/// riusa `BarcodeScannerScreen`, già accoppiata alla ricerca Open Food
/// Facts). A successo pop con il [File] scaricato dall'altro device, pronto
/// per `confirmAndImportBackup`; il chiamante decide cosa farne.
class WifiReceiveScreen extends StatefulWidget {
  const WifiReceiveScreen({super.key});

  @override
  State<WifiReceiveScreen> createState() => _WifiReceiveScreenState();
}

class _WifiReceiveScreenState extends State<WifiReceiveScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;
  String? _errorMsg;

  // null = in verifica, true = ok, false = negato definitivamente
  bool? _cameraPermission;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() => _cameraPermission = status.isGranted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    final l10n = context.l10n;
    final pairing = SyncPairing.tryParse(code);
    if (pairing == null) {
      setState(() => _errorMsg = l10n.wifiReceiveErroreQr);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _errorMsg = null);
      return;
    }

    setState(() {
      _processing = true;
      _errorMsg = null;
    });
    await _controller.stop();

    final file = await fetchBackupOverWifi(pairing);
    if (!mounted) return;

    if (file != null) {
      Navigator.pop(context, file);
      return;
    }

    setState(() {
      _errorMsg = l10n.wifiReceiveErroreDownload;
      _processing = false;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _errorMsg = null);
      await _controller.start();
    }
  }

  Widget _buildCameraHardwareError(
      BuildContext context, MobileScannerException error, Widget? child) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 52),
              const SizedBox(height: 20),
              const Text(
                'Impossibile avviare la fotocamera.\nAssicurati che nessuna altra app la stia usando, poi riprova.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () async => _controller.start(),
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white54, size: 52),
              const SizedBox(height: 20),
              const Text(
                'Permesso fotocamera negato.\n\nVai in Impostazioni → Privacy e sicurezza → Fotocamera e abilita Plico.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () async => openAppSettings(),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Apri Impostazioni'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_cameraPermission == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_cameraPermission == false) {
      return _buildPermissionDenied();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.wifiReceiveTitolo.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: _buildCameraHardwareError,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 52),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
              child: _processing
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 12),
                        Text(l10n.wifiReceiveScaricamento,
                            style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    )
                  : _errorMsg != null
                      ? Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFE74C3C), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(_errorMsg!,
                                  style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ],
                        )
                      : Text(
                          l10n.wifiReceiveHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
