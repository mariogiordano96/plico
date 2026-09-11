import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../services/database_service.dart';
import '../../services/pdf_export_service.dart';
import '../../services/workout_progress_service.dart';

class StoricoEsercizioScreen extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  const StoricoEsercizioScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<StoricoEsercizioScreen> createState() => _StoricoEsercizioScreenState();
}

class _StoricoEsercizioScreenState extends State<StoricoEsercizioScreen> {
  List<WorkoutExercise> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await DatabaseService.instance.getHistoryForExercise(widget.exerciseId);
    if (mounted) setState(() {
      _history = history;
      _loading = false;
    });
  }

  Future<void> _exportPdf() async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    try {
      final bytes = await PdfExportService.generateStoricoEsercizio(
        exerciseName: widget.exerciseName,
        history: _history,
        strings: PdfStrings(
          diarioTitle: l10n.pdfDiarioTitle,
          targetLabel: l10n.pdfTargetLabel,
          kcalGiornoUnit: l10n.tdeeKcalGiornoUnit,
          footerPage: l10n.pdfPagina,
          nessunoRegistrato: l10n.pdfNessunDato,
          pastoFallback: l10n.pdfPastoFallback,
          pastoLabels: [
            l10n.pastoColazione, l10n.pastoPranzo, l10n.pastoCena,
            l10n.pastoSpuntino, l10n.pastoPostWo, l10n.pastoSpuntinoSerale,
          ],
          riepilogo: l10n.pdfRiepilogo,
          giorniConDati: l10n.pdfGiorniConDati,
          giorniOnTarget: l10n.pdfGiorniOnTarget,
          mediaLabel: l10n.pdfMediaLabel,
          targetPrefixLabel: l10n.pdfTargetPrefix,
          pianoTitle: l10n.pdfPianoTitle,
          generato: l10n.pdfGenerato,
          pianoSlotLabels: [
            l10n.slotProteina, l10n.slotCarboidrati, l10n.slotVerdura,
            l10n.slotGrassi, l10n.slotExtra, l10n.slotFrutta,
          ],
          schedaPdfTitle: l10n.pdfSchedaTitle,
          programmaPdfTitle: l10n.pdfProgrammaTitle,
          storicoPdfTitle: l10n.pdfStoricoTitle,
          nEsercizi: l10n.schedeNEsercizi,
          nessunaSessione: l10n.storicoNessunaSessione,
          prBadge: l10n.storicoPrBadge,
          durataMin: l10n.allenamentoDurataMin,
          tecnicaForzate: l10n.pdfTecnicaForzate,
          tecnicaRestPause: l10n.pdfTecnicaRestPause,
          tecnicaStripping: l10n.pdfTecnicaStripping,
          tecnicaSuperSlow: l10n.pdfTecnicaSuperSlow,
        ),
        locale: locale,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'plico_storico_esercizio.pdf');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pianoErrorePdf)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final isCardio = _history.isNotEmpty && _history.first.isCardio;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.storicoTitle(widget.exerciseName),
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _exportPdf,
              icon: Icon(Icons.picture_as_pdf_outlined, color: p.accent),
              tooltip: l10n.pianoEsportaPdf,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : _history.isEmpty
              ? Center(
                  child: Text(l10n.storicoNessunaSessione,
                      style: TextStyle(color: p.textMuted)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    if (!isCardio) _WeightChart(history: _history, p: p),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _history.length; i++)
                      _SessionRow(
                        session: _history[i],
                        isPr: !isCardio &&
                            WorkoutProgressService.isNewPersonalRecord(
                                _history[i], _history.sublist(i + 1)),
                        p: p,
                        l10n: l10n,
                      ),
                  ],
                ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WorkoutExercise> history;
  final ColorPalette p;
  const _WeightChart({required this.history, required this.p});

  @override
  Widget build(BuildContext context) {
    // history è in ordine decrescente (più recente prima): il grafico vuole l'ordine
    // cronologico, quindi va invertito.
    final chronological = history.reversed.toList();
    final spots = <FlSpot>[];
    for (var i = 0; i < chronological.length; i++) {
      final maxW = WorkoutProgressService.sessionMaxWeight(chronological[i]);
      if (maxW != null) spots.add(FlSpot(i.toDouble(), maxW));
    }
    if (spots.length < 2) return const SizedBox.shrink();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.2 + 1;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: LineChart(
        LineChartData(
          minY: minY - pad,
          maxY: maxY + pad,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: spots.length > 2,
              curveSmoothness: 0.3,
              color: p.accent,
              barWidth: 2.5,
              belowBarData: BarAreaData(show: true, color: p.accent.withValues(alpha: 0.08)),
              dotData: FlDotData(
                show: spots.length <= 14,
                getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                  radius: 3.5,
                  color: p.accent,
                  strokeWidth: 1.5,
                  strokeColor: p.background,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etichetta di una serie per lo storico, tecnica inclusa
/// (docs/tecniche_allenamento.md, Fase 6) — un solo indicatore per serie,
/// le tecniche sono mutualmente esclusive per costruzione (`_SetRow`,
/// sessione guidata).
String _setLabel(WorkoutSet s) {
  final base = '${s.reps ?? '-'}×${s.weightKg ?? '-'}kg';
  if (s.forcedReps != null) return '$base 💪+${s.forcedReps}';
  if (s.isSuperSlow) return '$base 🐌';
  if (s.restPauseClusters?.isNotEmpty == true) {
    return '$base 🔥${s.restPauseClusters!.join("+")}';
  }
  if (s.dropStages?.isNotEmpty == true) return '$base ⬇️';
  return base;
}

class _SessionRow extends StatelessWidget {
  final WorkoutExercise session;
  final bool isPr;
  final ColorPalette p;
  final AppLocalizations l10n;
  const _SessionRow({
    required this.session,
    required this.isPr,
    required this.p,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dataLabel = DateFormat('d MMM', locale).format(session.date);
    final isCardio = session.isCardio;
    final detail = isCardio
        ? (session.durationSeconds != null
            ? l10n.allenamentoDurataMin(session.durationSeconds! ~/ 60)
            : l10n.allenamentoDurataDaImpostare)
        : session.sets.map(_setLabel).join(', ');
    final avgRpe = isCardio ? null : WorkoutProgressService.averageRpe(session);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(dataLabel, style: TextStyle(color: p.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail, style: TextStyle(color: p.textPrimary, fontSize: 13)),
                if (avgRpe != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(l10n.storicoRpeMedio(avgRpe.toStringAsFixed(1)),
                        style: TextStyle(color: p.textMuted, fontSize: 11)),
                  ),
              ],
            ),
          ),
          if (isPr)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('🏆 ${l10n.storicoPrBadge}',
                  style: TextStyle(color: p.accent, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
