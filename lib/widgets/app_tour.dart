import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';

class _TourStep {
  final int tabIndex;
  final String title;
  final String description;
  const _TourStep(this.tabIndex, this.title, this.description);
}

const _steps = [
  _TourStep(0, 'Home', 'Il tuo riepilogo quotidiano: kcal consumate, macro, streak e il piano del giorno — tutto a colpo d\'occhio.'),
  _TourStep(1, 'Diario', 'Registra ogni pasto della giornata. Tocca il "+" in alto per aggiungere un alimento o scannerizza un barcode.'),
  _TourStep(2, 'Progressi', 'Monitora il tuo peso nel tempo, guarda i badge guadagnati e il riepilogo settimanale.'),
  _TourStep(3, 'TDEE', 'Il tuo fabbisogno calorico personalizzato, calcolato e aggiornato sui tuoi dati reali.'),
];

class AppTour extends StatefulWidget {
  final Widget child;
  final void Function(int) onSwitchTab;

  const AppTour({super.key, required this.child, required this.onSwitchTab});

  @override
  State<AppTour> createState() => _AppTourState();
}

class _AppTourState extends State<AppTour> with SingleTickerProviderStateMixin {
  OverlayEntry? _entry;
  final _stepNotifier = ValueNotifier<int>(0);
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStart());
  }

  @override
  void dispose() {
    _entry?.remove();
    _stepNotifier.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _checkAndStart() async {
    final done = await DatabaseService.instance.getTourCompleted();
    if (!done && mounted) _showOverlay();
  }

  void _showOverlay() {
    _entry = OverlayEntry(
      builder: (_) => ValueListenableBuilder<int>(
        valueListenable: _stepNotifier,
        builder: (ctx, step, __) => _TourUI(
          step: step,
          pulseAnim: _pulseAnim,
          onNext: _next,
          onSkip: _finish,
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _next() {
    if (_stepNotifier.value < _steps.length - 1) {
      _stepNotifier.value++;
      widget.onSwitchTab(_steps[_stepNotifier.value].tabIndex);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    _entry?.remove();
    _entry = null;
    await DatabaseService.instance.setTourCompleted();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _TourUI extends StatelessWidget {
  final int step;
  final Animation<double> pulseAnim;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourUI({
    required this.step,
    required this.pulseAnim,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    const navH = 56.0;
    final bottomPad = mq.padding.bottom;
    final itemW = screenW / _steps.length;
    final ts = _steps[step];
    final spotCx = itemW * ts.tabIndex + itemW / 2;
    final spotCy = mq.size.height - bottomPad - navH / 2;
    const spotR = 32.0;
    final p = context.palette;

    return Stack(
      children: [
        // Dark overlay with spotlight hole
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SpotlightPainter(cx: spotCx, cy: spotCy, r: spotR),
            ),
          ),
        ),
        // Pulsing ring
        Positioned(
          left: spotCx - spotR,
          top: spotCy - spotR,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: pulseAnim.value,
                child: Container(
                  width: spotR * 2,
                  height: spotR * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: p.accent, width: 2.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Tooltip card
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomPad + navH + 12,
          child: Material(
            color: Colors.transparent,
            child: _TourCard(
              step: step,
              total: _steps.length,
              title: ts.title,
              description: ts.description,
              onNext: onNext,
              onSkip: onSkip,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final double cx;
  final double cy;
  final double r;

  const _SpotlightPainter({required this.cx, required this.cy, required this.r});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.72);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.cx != cx || old.cy != cy;
}

class _TourCard extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TourCard({
    required this.step,
    required this.total,
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isLast = step == total - 1;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16)],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p.textPrimary)),
              const Spacer(),
              Text('${step + 1}/$total',
                  style: TextStyle(fontSize: 13, color: p.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(
                  fontSize: 14, color: p.textPrimary.withValues(alpha: 0.75), height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: onSkip,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text('Salta', style: TextStyle(color: p.textMuted, fontSize: 14)),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isLast ? 'Inizia' : 'Avanti',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: p.background),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
