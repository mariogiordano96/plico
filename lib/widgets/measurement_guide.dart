import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/enums.dart';

// ──────────────────────────────────────────────
// Layout PNG: 4 colonne uguali
//   col 0 → Male   Front   alignment.x = -1.0
//   col 1 → Male   Back    alignment.x = -1/3
//   col 2 → Female Front   alignment.x =  1/3
//   col 3 → Female Back    alignment.x =  1.0
// ──────────────────────────────────────────────

enum BodyView { front, back }


// ──────────────────────────────────────────────
// Dati siti — point normalizzato (0–1) per colonna
// ──────────────────────────────────────────────

class MeasurementSite {
  final String label;
  final String description;
  final List<String> steps;
  final BodyView bodyView;
  final Offset pointMale;
  final Offset pointFemale;

  // Restituisce il punto corretto in base al sesso
  Offset point(Sesso sesso) =>
      sesso == Sesso.maschio ? pointMale : pointFemale;

  const MeasurementSite({
    required this.label,
    required this.description,
    required this.steps,
    required this.bodyView,
    required this.pointMale,
    required this.pointFemale,
  });
}

// Macro per siti non ancora calibrati per la donna
// (usa gli stessi valori del maschio come placeholder)
const _sites = <String, MeasurementSite>{
  'tricipite': MeasurementSite(
    label: 'Plica Tricipitale', bodyView: BodyView.back,
    pointMale:   Offset(0.241, 0.347),
    pointFemale: Offset(0.336, 0.355), // calibrato
    description: 'Sul tricipite del braccio destro, a metà tra acromion e olecrano.',
    steps: ['Braccio rilassato lungo il fianco.', 'Individua il punto medio tra punta della spalla e gomito.', 'Afferra verticalmente la plica sul retro del braccio e misura.'],
  ),
  'bicipite': MeasurementSite(
    label: 'Plica Bicipitale', bodyView: BodyView.front,
    pointMale:   Offset(0.245, 0.339),
    pointFemale: Offset(0.370, 0.355),
    description: 'Sul bicipite del braccio destro, allo stesso livello della plica tricipitale.',
    steps: ['Braccio rilassato, palmo rivolto in avanti.', 'Stesso livello altitudinale della plica tricipitale.', 'Afferra verticalmente la plica sulla parte anteriore del braccio.'],
  ),
  'pettorale': MeasurementSite(
    label: 'Plica Pettorale', bodyView: BodyView.front,
    pointMale:   Offset(0.63, 0.27),
    pointFemale: Offset(0.447, 0.294),
    description: 'Diagonalmente a metà tra l\'ascella e il capezzolo destro.',
    steps: ['Braccio destro leggermente abdotto.', 'Localizza il punto a metà tra piega ascellare e capezzolo.', 'Afferra la plica a 45° e misura.'],
  ),
  'ascellare': MeasurementSite(
    label: 'Plica Ascellare', bodyView: BodyView.front,
    pointMale:   Offset(0.665, 0.353),
    pointFemale: Offset(0.730, 0.353),
    description: 'Verticalmente sulla linea ascellare media al livello della sesta costa.',
    steps: ['Braccio destro sollevato a 90°.', 'Localizza la linea ascellare media al livello della sesta costa.', 'Afferra verticalmente la plica e misura.'],
  ),
  'sottoscapolare': MeasurementSite(
    label: 'Plica Sottoscapolare', bodyView: BodyView.back,
    pointMale:   Offset(0.632, 0.305),
    pointFemale: Offset(0.623, 0.337),
    description: 'Sotto l\'angolo inferiore della scapola destra, a 45° rispetto alla colonna.',
    steps: ['Braccio destro rilassato lungo il fianco.', 'Individua l\'angolo inferiore della scapola destra.', 'Afferra la plica a 45° verso il basso e l\'esterno.'],
  ),
  'sovrailiaca': MeasurementSite(
    label: 'Plica Sovrailiaca', bodyView: BodyView.front,
    pointMale:   Offset(0.627, 0.460),
    pointFemale: Offset(0.718, 0.459),
    description: 'Appena sopra la cresta iliaca, lungo la linea ascellare anteriore.',
    steps: ['Braccio destro abdotto.', 'Localizza la cresta iliaca (osso del fianco).', 'Afferra la plica diagonalmente 1–2 cm sopra la cresta e misura.'],
  ),
  'addome': MeasurementSite(
    label: 'Plica Addominale', bodyView: BodyView.front,
    pointMale:   Offset(0.412, 0.453),
    pointFemale: Offset(0.516, 0.437),
    description: 'Verticalmente 2 cm lateralmente all\'ombelico destro.',
    steps: ['In piedi, addominali rilassati.', 'Localizza il punto 2 cm a destra dell\'ombelico.', 'Afferra verticalmente la plica e misura.'],
  ),
  'coscia_plica': MeasurementSite(
    label: 'Plica Coscia', bodyView: BodyView.front,
    pointMale:   Offset(0.619, 0.590),
    pointFemale: Offset(0.679, 0.629),
    description: 'Verticalmente sulla faccia anteriore della coscia destra, a metà tra inguine e rotula.',
    steps: ['Seduto o in piedi con peso sul piede sinistro.', 'Individua il punto medio tra piega inguinale e bordo superiore della rotula.', 'Afferra verticalmente la plica e misura.'],
  ),
  'polpaccio_plica': MeasurementSite(
    label: 'Plica Polpaccio', bodyView: BodyView.back,
    pointMale:   Offset(0.645, 0.787),
    pointFemale: Offset(0.645, 0.791),
    description: 'Verticalmente sulla faccia mediale del polpaccio destro.',
    steps: ['Seduto, ginocchio a 90°.', 'Individua il punto di massima circonferenza del polpaccio.', 'Afferra verticalmente la plica sulla parte mediale e misura.'],
  ),
  'collo': MeasurementSite(
    label: 'Circonferenza Collo', bodyView: BodyView.front,
    pointMale:   Offset(0.572, 0.206),
    pointFemale: Offset(0.619, 0.221),
    description: 'Al punto più stretto del collo, appena sotto la laringe (il pomo d\'Adamo negli uomini).',
    steps: ['In piedi, testa eretta e sguardo in avanti.', 'Posiziona il metro appena sotto la laringe.', 'Avvolgi perpendicolarmente all\'asse del collo, senza comprimere.'],
  ),
  'vita': MeasurementSite(
    label: 'Circonferenza Vita', bodyView: BodyView.front,
    pointMale:   Offset(0.641, 0.455),
    pointFemale: Offset(0.696, 0.422),
    description: 'Al punto più stretto del tronco, tra l\'ultima costa e la cresta iliaca.',
    steps: ['In piedi, addome rilassato.', 'Localizza il punto più stretto del tronco.', 'Avvolgi il metro perpendicolare al pavimento senza comprimere.'],
  ),
  'fianchi': MeasurementSite(
    label: 'Circonferenza Fianchi', bodyView: BodyView.back,
    pointMale:   Offset(0.670, 0.493),
    pointFemale: Offset(0.709, 0.500),
    description: 'Al punto di massima protuberanza dei glutei.',
    steps: ['In piedi, piedi uniti.', 'Localizza il punto di massima sporgenza dei glutei.', 'Avvolgi il metro orizzontalmente a quel livello.'],
  ),
  'braccio': MeasurementSite(
    label: 'Circonferenza Braccio', bodyView: BodyView.front,
    pointMale:   Offset(0.249, 0.351),
    pointFemale: Offset(0.378, 0.341),
    description: 'Nel punto di massima circonferenza del bicipite destro.',
    steps: ['Braccio destro rilassato lungo il fianco.', 'Individua il punto di massima circonferenza.', 'Avvolgi il metro perpendicolare all\'asse del braccio.'],
  ),
  'coscia_circ': MeasurementSite(
    label: 'Circonferenza Coscia', bodyView: BodyView.front,
    pointMale:   Offset(0.674, 0.572),
    pointFemale: Offset(0.734, 0.600),
    description: 'Al punto di massima circonferenza della coscia destra.',
    steps: ['In piedi, peso distribuito su entrambi i piedi.', 'Localizza il punto di massima circonferenza della coscia.', 'Avvolgi il metro perpendicolare all\'asse della coscia.'],
  ),
  'polpaccio_circ': MeasurementSite(
    label: 'Circonferenza Polpaccio', bodyView: BodyView.back,
    pointMale:   Offset(0.665, 0.787),
    pointFemale: Offset(0.438, 0.798),
    description: 'Al punto di massima circonferenza del polpaccio destro.',
    steps: ['In piedi.', 'Localizza il punto di massima circonferenza del polpaccio.', 'Avvolgi il metro perpendicolare all\'asse della gamba.'],
  ),
  'torace': MeasurementSite(
    label: 'Circonferenza Torace', bodyView: BodyView.front,
    pointMale:   Offset(0.507, 0.317),
    pointFemale: Offset(0.576, 0.357),
    description: 'Al livello dei capezzoli, a fine espirazione.',
    steps: ['In piedi, braccia leggermente abdotte.', 'Posiziona il metro al livello dei capezzoli.', 'Avvolgi perpendicolare al pavimento. Misura a fine espirazione.'],
  ),
  'spalle': MeasurementSite(
    label: 'Circonferenza Spalle', bodyView: BodyView.back,
    pointMale:   Offset(0.787, 0.270),
    pointFemale: Offset(0.752, 0.273),
    description: 'Al punto di massima larghezza delle spalle (acromion).',
    steps: ['In piedi, braccia rilassate lungo il fianco.', 'Localizza la protuberanza delle spalle (acromion).', 'Avvolgi il metro orizzontalmente passando per entrambi gli acromion.'],
  ),
};

// ──────────────────────────────────────────────
// Entry point
// ──────────────────────────────────────────────

void showMeasurementGuide(BuildContext context, String siteKey, {Sesso sesso = Sesso.maschio}) {
  final site = _sites[siteKey];
  if (site == null) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _MeasurementGuideSheet(site: site, sesso: sesso),
  );
}

// ──────────────────────────────────────────────
// Bottom sheet
// ──────────────────────────────────────────────

class _MeasurementGuideSheet extends StatefulWidget {
  final MeasurementSite site;
  final Sesso sesso;
  const _MeasurementGuideSheet({required this.site, required this.sesso});

  @override
  State<_MeasurementGuideSheet> createState() => _MeasurementGuideSheetState();
}

class _MeasurementGuideSheetState extends State<_MeasurementGuideSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _scaleAnim = Tween<double>(begin: 0.82, end: 1.22)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut));
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DraggableScrollableSheet(
      initialChildSize: 0.74,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
              child: Row(
                children: [
                  const Spacer(),
                  Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: p.textMuted.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(2))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: p.surfaceVariant, border: Border.all(color: p.cardBorder)),
                      child: Icon(Icons.close_rounded, color: p.textMuted, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  Text(widget.site.label,
                      style: TextStyle(color: p.accent, fontSize: 21, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(widget.site.description,
                      style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.55)),
                  const SizedBox(height: 24),

                  Center(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) => _BodyWithIndicator(
                        site: widget.site,
                        sesso: widget.sesso,
                        scaleValue: _scaleAnim.value,
                        ringProgress: _ringAnim.value,
                        accentColor: p.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.site.bodyView == BodyView.front ? Icons.person_rounded : Icons.person_outlined,
                            color: p.textMuted, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.sesso == Sesso.maschio ? 'Uomo' : 'Donna'} · '
                          '${widget.site.bodyView == BodyView.front ? 'Vista frontale' : 'Vista posteriore'}',
                          style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text('COME MISURARE',
                      style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ...widget.site.steps.asMap().entries
                      .map((e) => _StepRow(index: e.key + 1, text: e.value, p: p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Crop della colonna corretta + indicatore
// ──────────────────────────────────────────────

class _BodyWithIndicator extends StatelessWidget {
  final MeasurementSite site;
  final Sesso sesso;
  final double scaleValue;
  final double ringProgress;
  final Color accentColor;

  const _BodyWithIndicator({
    required this.site, required this.sesso,
    required this.scaleValue, required this.ringProgress,
    required this.accentColor,
  });

  int get _colIndex {
    if (sesso == Sesso.maschio && site.bodyView == BodyView.front) return 0;
    if (sesso == Sesso.maschio && site.bodyView == BodyView.back)  return 1;
    if (sesso == Sesso.femmina && site.bodyView == BodyView.front) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    const colW = 150.0;
    const colH = 290.0;

    final p = site.point(sesso);
    final dotX = p.dx * colW;
    final dotY = p.dy * colH;

    return Container(
      width: colW,
      height: colH,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Sposta l'intera immagine a sinistra di colIndex * colW
            // così la colonna giusta si allinea al bordo sinistro del container
            ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: colW * 4,
                maxHeight: colH,
                child: Transform.translate(
                  offset: Offset(-_colIndex * colW, 0),
                  child: Image.asset(
                    'assets/img/all_body_forms.png',
                    width: colW * 4,
                    height: colH,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            // Indicatore animato
            CustomPaint(
              size: const Size(colW, colH),
              painter: _IndicatorPainter(
                center: Offset(dotX, dotY),
                scaleValue: scaleValue,
                ringProgress: ringProgress,
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Indicator painter
// ──────────────────────────────────────────────

class _IndicatorPainter extends CustomPainter {
  final Offset center;
  final double scaleValue;
  final double ringProgress;
  final Color accentColor;

  const _IndicatorPainter({
    required this.center, required this.scaleValue,
    required this.ringProgress, required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r1 = 8.0 + ringProgress * 20.0;
    final o1 = (1.0 - ringProgress).clamp(0.0, 1.0);
    canvas.drawCircle(center, r1, Paint()
      ..color = accentColor.withValues(alpha: o1 * 0.5)
      ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    final p2 = ((ringProgress + 0.45) % 1.0);
    final r2 = 8.0 + p2 * 20.0;
    final o2 = (1.0 - p2).clamp(0.0, 1.0);
    canvas.drawCircle(center, r2, Paint()
      ..color = accentColor.withValues(alpha: o2 * 0.3)
      ..style = PaintingStyle.stroke..strokeWidth = 1.0);

    canvas.drawCircle(center, 8.0 * scaleValue, Paint()
      ..color = accentColor.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawCircle(center, 5.5 * scaleValue, Paint()
      ..color = accentColor..style = PaintingStyle.fill);

    canvas.drawCircle(Offset(center.dx - 1.2, center.dy - 1.2), 1.5,
        Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) =>
      scaleValue != old.scaleValue || ringProgress != old.ringProgress || center != old.center;
}

// ──────────────────────────────────────────────
// Step row
// ──────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  final int index;
  final String text;
  final ColorPalette p;
  const _StepRow({required this.index, required this.text, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: p.accent.withValues(alpha: 0.14),
                border: Border.all(color: p.accent.withValues(alpha: 0.4))),
            child: Center(child: Text('$index', style: TextStyle(color: p.accent, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5)),
          )),
        ],
      ),
    );
  }
}
