import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/open_food_facts_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;
  String? _errorMsg;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCameraError(
      BuildContext context, MobileScannerException error, Widget? child) {
    final msg = error.errorDetails?.message ?? '';
    final bool isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied ||
            msg.toLowerCase().contains('authorized') ||
            msg.toLowerCase().contains('permission');

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPermission
                    ? Icons.no_photography_outlined
                    : Icons.videocam_off_outlined,
                color: Colors.white54,
                size: 52,
              ),
              const SizedBox(height: 20),
              Text(
                isPermission
                    ? 'Permesso fotocamera negato.\n\nVai in Impostazioni → Privacy e sicurezza → Fotocamera e abilita Plico.'
                    : 'Impossibile avviare la fotocamera.\nAssicurati che nessuna altra app stia usando la fotocamera, poi riprova.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 28),
              if (isPermission)
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text('Chiudi',
                      style: TextStyle(color: Colors.white70)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38)),
                )
              else
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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() {
      _processing = true;
      _errorMsg = null;
    });
    await _controller.stop();

    final food = await OpenFoodFactsService.searchByBarcode(code);
    if (!mounted) return;

    if (food != null) {
      Navigator.pop(context, food);
      return;
    }

    // Prodotto non trovato: mostra errore e riprendi dopo 3s
    setState(() {
      _errorMsg = 'Prodotto non trovato nel database.\nProva a cercarlo per nome.';
      _processing = false;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _errorMsg = null);
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'SCANSIONA BARCODE',
          style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: _buildCameraError,
          ),

          // Overlay con frame di scansione
          const _ScanFrame(),

          // Banner di stato in basso
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: _processing
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text('Ricerca in corso...',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ],
                    )
                  : _errorMsg != null
                      ? Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFE74C3C), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Inquadra il barcode del prodotto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay con angoli ─────────────────────────────────────────

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutW = size.width * 0.75;
    final cutH = cutW * 0.52;
    final left = (size.width - cutW) / 2;
    final top = size.height * 0.27;
    final cutout = Rect.fromLTWH(left, top, cutW, cutH);
    final rr = RRect.fromRectAndRadius(cutout, const Radius.circular(12));

    // Sfondo scuro con ritaglio
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rr),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Angoli bianchi
    const cl = 22.0; // corner length
    const cw = 3.0;  // corner width
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = cw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(left, top + cl), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cl, top), paint);
    // Top-right
    canvas.drawLine(Offset(left + cutW - cl, top), Offset(left + cutW, top), paint);
    canvas.drawLine(Offset(left + cutW, top), Offset(left + cutW, top + cl), paint);
    // Bottom-left
    canvas.drawLine(Offset(left, top + cutH - cl), Offset(left, top + cutH), paint);
    canvas.drawLine(Offset(left, top + cutH), Offset(left + cl, top + cutH), paint);
    // Bottom-right
    canvas.drawLine(Offset(left + cutW - cl, top + cutH), Offset(left + cutW, top + cutH), paint);
    canvas.drawLine(Offset(left + cutW, top + cutH - cl), Offset(left + cutW, top + cutH), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
