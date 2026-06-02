import 'package:flutter/material.dart';
import '../../models/enums.dart';
import '../../widgets/measurement_guide.dart';

// ──────────────────────────────────────────────
// Schermata di calibrazione TEMPORANEA
// Tocca il punto esatto sul corpo → leggi le coordinate → riportale
// Da rimuovere dopo la calibrazione
// ──────────────────────────────────────────────

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  Sesso _sesso = Sesso.maschio;
  BodyView _view = BodyView.front;
  Offset? _tap;       // coordinate pixel nell'immagine
  Offset? _normalized; // coordinate 0.0–1.0

  static const _colW = 260.0;
  static const _colH = 480.0;

  int get _colIndex {
    if (_sesso == Sesso.maschio && _view == BodyView.front) return 0;
    if (_sesso == Sesso.maschio && _view == BodyView.back)  return 1;
    if (_sesso == Sesso.femmina && _view == BodyView.front) return 2;
    return 3;
  }

  void _onTap(TapDownDetails d) {
    final local = d.localPosition;
    setState(() {
      _tap = local;
      _normalized = Offset(
        (local.dx / _colW).clamp(0.0, 1.0),
        (local.dy / _colH).clamp(0.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1622),
        title: const Text('CALIBRAZIONE', style: TextStyle(color: Color(0xFF00FF88), letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF00FF88)),
      ),
      body: Column(
        children: [
          // Selettori sesso / vista
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _Chip('Uomo', _sesso == Sesso.maschio, () => setState(() { _sesso = Sesso.maschio; _tap = null; })),
                const SizedBox(width: 8),
                _Chip('Donna', _sesso == Sesso.femmina, () => setState(() { _sesso = Sesso.femmina; _tap = null; })),
                const Spacer(),
                _Chip('Frontale', _view == BodyView.front, () => setState(() { _view = BodyView.front; _tap = null; })),
                const SizedBox(width: 8),
                _Chip('Posteriore', _view == BodyView.back, () => setState(() { _view = BodyView.back; _tap = null; })),
              ],
            ),
          ),

          // Immagine tappabile
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapDown: _onTap,
                child: Container(
                  width: _colW,
                  height: _colH,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00FF88), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Corpo
                        ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            maxWidth: _colW * 4,
                            maxHeight: _colH,
                            child: Transform.translate(
                              offset: Offset(-_colIndex * _colW, 0),
                              child: Image.asset(
                                'assets/img/all_body_forms.png',
                                width: _colW * 4,
                                height: _colH,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        // Punto tappato
                        if (_tap != null)
                          Positioned(
                            left: _tap!.dx - 10,
                            top: _tap!.dy - 10,
                            child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00FF88),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withValues(alpha: 0.6), blurRadius: 8)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Coordinate
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF162035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E3A50)),
            ),
            child: _tap == null
                ? const Text('Tocca il punto esatto sul corpo', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF4A6B7A), fontSize: 14))
                : Column(
                    children: [
                      const Text('COORDINATE DA COPIARE', style: TextStyle(color: Color(0xFF4A6B7A), fontSize: 11, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      SelectableText(
                        'point: Offset(${_normalized!.dx.toStringAsFixed(3)}, ${_normalized!.dy.toStringAsFixed(3)}),',
                        style: const TextStyle(
                          color: Color(0xFF00FF88),
                          fontSize: 16,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'pixel: (${_tap!.dx.toStringAsFixed(1)}, ${_tap!.dy.toStringAsFixed(1)})  '
                        'su ${_colW.toInt()}x${_colH.toInt()}',
                        style: const TextStyle(color: Color(0xFF4A6B7A), fontSize: 12),
                      ),
                    ],
                  ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('Cambia sesso/vista per calibrare le diverse silhouette',
                style: TextStyle(color: Color(0xFF4A6B7A), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00FF88).withValues(alpha: 0.15) : const Color(0xFF162035),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? const Color(0xFF00FF88) : const Color(0xFF1E3A50)),
        ),
        child: Text(label, style: TextStyle(
          color: active ? const Color(0xFF00FF88) : const Color(0xFF4A6B7A),
          fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.normal,
        )),
      ),
    );
  }
}
