import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../models/body_snapshot.dart';
import '../../models/plicometry_session.dart';
import '../../models/measurement_snapshot.dart';
import '../../models/workout_exercise.dart';
import '../../services/database_service.dart';
import '../../services/pdf_export_service.dart';
import '../storico/storico_misurazioni_screen.dart';
import 'record_personali_screen.dart';
import 'volume_settimanale_screen.dart';

// ── Data helpers ───────────────────────────────────────────────

class _Point {
  final DateTime date;
  final double value;
  const _Point(this.date, this.value);
}

enum _Range { month1, month3, month6, year1, all }

extension _RangeExt on _Range {
  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case _Range.month1: return DateTime(now.year, now.month - 1, now.day);
      case _Range.month3: return DateTime(now.year, now.month - 3, now.day);
      case _Range.month6: return DateTime(now.year, now.month - 6, now.day);
      case _Range.year1:  return DateTime(now.year - 1, now.month, now.day);
      case _Range.all:    return null;
    }
  }
}

enum _CompMetric { bf, grassa, magra }

extension _CompMetricExt on _CompMetric {
  String get unit {
    return this == _CompMetric.bf ? '%' : 'kg';
  }
}

String _rangeLabel(_Range r, BuildContext context) => switch (r) {
  _Range.month1 => '1M',
  _Range.month3 => '3M',
  _Range.month6 => '6M',
  _Range.year1  => context.l10n.progressiRange1A,
  _Range.all    => context.l10n.progressiRangeTutto,
};

String _compMetricLabel(_CompMetric m, BuildContext context) => switch (m) {
  _CompMetric.bf     => 'BF%',
  _CompMetric.grassa => context.l10n.progressiMassaGrassa,
  _CompMetric.magra  => context.l10n.progressiMassaMagra,
};

Map<String, String> _getMisureLabels(BuildContext context) => {
  'vitaCm':           context.l10n.misuraVita,
  'fianchiCm':        context.l10n.misuraFianchi,
  'braccioCm':        context.l10n.misuraBraccio,
  'colloCm':          context.l10n.misuraCollo,
  'cosciaCm':         context.l10n.misuraCoscia,
  'polpaccioCm':      context.l10n.misuraPolpaccio,
  'toraceCm':         context.l10n.misuraTorace,
  'spalleCm':         context.l10n.misuraSpalle,
  'tricipiteMm':      context.l10n.misuraTricipite,
  'bicipiteMm':       context.l10n.misuraBicipite,
  'sottoscapolareMm': context.l10n.misuraSottoscap,
  'sovrailiachMm':    context.l10n.misuraSovrailiaca,
  'addomineMm':       context.l10n.misuraAddome,
  'cosciaMm':         context.l10n.misuraCosciaPlica,
};

double? _snapValue(MeasurementSnapshot s, String key) {
  switch (key) {
    case 'vitaCm':           return s.vitaCm;
    case 'fianchiCm':        return s.fianchiCm;
    case 'braccioCm':        return s.braccioCm;
    case 'colloCm':          return s.colloCm;
    case 'cosciaCm':         return s.cosciaCm;
    case 'polpaccioCm':      return s.polpaccioCm;
    case 'toraceCm':         return s.toraceCm;
    case 'spalleCm':         return s.spalleCm;
    case 'tricipiteMm':      return s.tricipiteMm;
    case 'bicipiteMm':       return s.bicipiteMm;
    case 'sottoscapolareMm': return s.sottoscapolareMm;
    case 'sovrailiachMm':    return s.sovrailiachMm;
    case 'addomineMm':       return s.addomineMm;
    case 'cosciaMm':         return s.cosciaMm;
    default:                 return null;
  }
}

String _unitFor(String key) => key.endsWith('Mm') ? 'mm' : 'cm';

// ── Screen ─────────────────────────────────────────────────────

class ProgressiScreen extends StatefulWidget {
  const ProgressiScreen({super.key});

  @override
  State<ProgressiScreen> createState() => _ProgressiScreenState();
}

class _ProgressiScreenState extends State<ProgressiScreen> {
  _Range _range = _Range.month1;
  _CompMetric _compMetric = _CompMetric.bf;
  String _misuraKey = 'vitaCm';

  /// Esporta in PDF esattamente le sezioni mostrate a schermo (peso,
  /// composizione, misurazioni, log allenamenti), filtrate sullo stesso
  /// range già selezionato in cima alla pagina — nessuna scelta ulteriore
  /// da fare, coerente con "esporta quello che vedo".
  Future<void> _exportPdf() async {
    final db = DatabaseService.instance;
    final from = _range.startDate;
    final to = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final l10n = context.l10n;

    final allBody = await db.getBodySnapshots();
    final body = from != null
        ? allBody.where((s) => !s.data.isBefore(from)).toList()
        : allBody;

    final allComposizione = await db.getPlicometrySessions();
    final composizione = from != null
        ? allComposizione.where((s) => !s.data.isBefore(from)).toList()
        : allComposizione;

    final allMisurazioni = await db.getMeasurementSnapshots();
    final misurazioni = from != null
        ? allMisurazioni.where((s) => !s.data.isBefore(from)).toList()
        : allMisurazioni;

    final workoutExercises = from != null
        ? await db.getWorkoutExercisesRange(from, to)
        : await db.getAllWorkoutExercises();

    final dateFmt = DateFormat.yMd(locale);
    final periodLabel = from != null
        ? '${dateFmt.format(from)} – ${dateFmt.format(to)}'
        : l10n.progressiRangeTutto;

    final strings = PdfStrings(
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
      progressiPdfTitle: l10n.progressiTitolo,
      progressiSezPeso: l10n.progressiSezPeso,
      progressiSezComposizione: l10n.progressiSezComposizione,
      progressiSezMisurazioni: l10n.progressiSezMisurazioni,
      progressiSezAllenamentiPdf: l10n.progressiSezAllenamentiPdf,
      progressiMassaGrassa: l10n.progressiMassaGrassa,
      progressiMassaMagra: l10n.progressiMassaMagra,
      progressiNessunDato: l10n.progressiNessunDato,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PdfLoadingDialog(),
    );

    try {
      final bytes = await PdfExportService.generateProgressi(
        periodLabel: periodLabel,
        bodySnapshots: body,
        plicometrySessions: composizione,
        measurementSnapshots: misurazioni,
        workoutExercises: workoutExercises,
        misuraLabels: _getMisureLabels(context),
        strings: strings,
        locale: locale,
      );
      if (!mounted) return;
      Navigator.pop(context);

      final ts = '${to.year}${to.month.toString().padLeft(2, '0')}${to.day.toString().padLeft(2, '0')}';
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'plico_progressi_$ts.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.progressiErrEsportazione(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final start = _range.startDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.progressiTitolo,
            style: TextStyle(
                color: p.accent,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: p.accent),
            tooltip: context.l10n.progressiTooltipEsporta,
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: Icon(Icons.straighten_rounded, color: p.accent),
            tooltip: context.l10n.progressiTooltipStorico,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const StoricoMisurazioniScreen())),
          ),
          IconButton(
            icon: Icon(Icons.emoji_events_rounded, color: p.accent),
            tooltip: context.l10n.progressiTooltipRecord,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const RecordPersonaliScreen())),
          ),
          IconButton(
            icon: Icon(Icons.bar_chart_rounded, color: p.accent),
            tooltip: context.l10n.progressiTooltipVolume,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const VolumeSettimanaleScreen())),
          ),
        ],
      ),
      backgroundColor: p.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filtro range ──────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _Range.values.map((r) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: _rangeLabel(r, context),
                    selected: _range == r,
                    onTap: () => setState(() => _range = r),
                    p: p,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Grafico 1: Peso ───────────────────────────
            _SectionLabel(context.l10n.progressiSezPeso, p),
            const SizedBox(height: 14),
            _PesoChart(startDate: start, p: p),
            const SizedBox(height: 28),

            // ── Grafico 2: Composizione ───────────────────
            _SectionLabel(context.l10n.progressiSezComposizione, p),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _CompMetric.values.map((m) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: _compMetricLabel(m, context),
                    selected: _compMetric == m,
                    onTap: () => setState(() => _compMetric = m),
                    p: p,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _ComposizioneChart(
              metric: _compMetric,
              startDate: start,
              p: p,
            ),
            const SizedBox(height: 28),

            // ── Grafico 3: Misurazioni ───────────────────
            _SectionLabel(context.l10n.progressiSezMisurazioni, p),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getMisureLabels(context).entries.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: e.value,
                    selected: _misuraKey == e.key,
                    onTap: () => setState(() => _misuraKey = e.key),
                    p: p,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _MisurazioniChart(
              key: ValueKey('$_misuraKey-${_range.name}'),
              misuraKey: _misuraKey,
              startDate: start,
              p: p,
            ),
            const SizedBox(height: 28),

            // ── Cronologia allenamenti (ultimi 7 giorni) ──
            _SectionLabel(context.l10n.progressiSezAllenamenti, p),
            const SizedBox(height: 14),
            _CronologiaAllenamenti(p: p),
          ],
        ),
      ),
    );
  }
}

// ── Peso Chart ────────────────────────────────────────────────

class _PesoChart extends StatelessWidget {
  final DateTime? startDate;
  final ColorPalette p;
  const _PesoChart({required this.startDate, required this.p});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BodySnapshot>>(
      stream: DatabaseService.instance.watchBodySnapshots(),
      builder: (context, snap) {
        final allSorted = [...(snap.data ?? [])]
          ..sort((a, b) => a.data.compareTo(b.data));
        final filtered = startDate != null
            ? allSorted.where((s) => !s.data.isBefore(startDate!)).toList()
            : allSorted;
        final points =
            filtered.map((s) => _Point(s.data, s.pesoKg)).toList();
        final trendValues = filtered.map((s) {
          final windowStart = s.data.subtract(const Duration(days: 6));
          final window = allSorted.where((x) =>
              !x.data.isBefore(windowStart) && !x.data.isAfter(s.data));
          final sum = window.fold(0.0, (acc, x) => acc + x.pesoKg);
          return sum / window.length;
        }).toList();
        return _ChartBox(
          points: points,
          trendValues: trendValues,
          unit: 'kg',
          color: const Color(0xFF4CAF8E),
          p: p,
        );
      },
    );
  }
}

// ── Composizione Chart ─────────────────────────────────────────

class _ComposizioneChart extends StatelessWidget {
  final _CompMetric metric;
  final DateTime? startDate;
  final ColorPalette p;
  const _ComposizioneChart(
      {required this.metric, required this.startDate, required this.p});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlicometrySession>>(
      stream: DatabaseService.instance.watchPlicometrySessions(),
      builder: (context, snap) {
        var sessions = [...(snap.data ?? [])]
          ..sort((a, b) => a.data.compareTo(b.data));

        if (startDate != null) {
          sessions = sessions.where((s) => !s.data.isBefore(startDate!)).toList();
        }

        final List<_Point> points = [];
        for (final s in sessions) {
          final double v;
          switch (metric) {
            case _CompMetric.bf:
              v = s.risultati.bodyFatPercent;
            case _CompMetric.grassa:
              v = s.risultati.massaGrassaKg;
            case _CompMetric.magra:
              v = s.risultati.massaMagraKg;
          }
          points.add(_Point(s.data, v));
        }

        return _ChartBox(
          points: points,
          unit: metric.unit,
          color: p.accent,
          p: p,
        );
      },
    );
  }
}

// ── Misurazioni Chart ─────────────────────────────────────────

class _MisurazioniChart extends StatelessWidget {
  final String misuraKey;
  final DateTime? startDate;
  final ColorPalette p;
  const _MisurazioniChart(
      {super.key,
      required this.misuraKey,
      required this.startDate,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MeasurementSnapshot>>(
      stream: DatabaseService.instance.watchMeasurementSnapshots(),
      builder: (context, snap) {
        var snapshots = [...(snap.data ?? [])]
          ..sort((a, b) => a.data.compareTo(b.data));

        if (startDate != null) {
          snapshots =
              snapshots.where((s) => !s.data.isBefore(startDate!)).toList();
        }

        final List<_Point> points = [];
        for (final s in snapshots) {
          final v = _snapValue(s, misuraKey);
          if (v != null) points.add(_Point(s.data, v));
        }

        return _ChartBox(
          points: points,
          unit: _unitFor(misuraKey),
          color: const Color(0xFF3B9FF2),
          p: p,
        );
      },
    );
  }
}

// ── Cronologia allenamenti (ultimi 7 giorni) ───────────────────

class _CronologiaAllenamenti extends StatelessWidget {
  final ColorPalette p;
  const _CronologiaAllenamenti({required this.p});

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final today = _dayOnly(DateTime.now());
    final from = today.subtract(const Duration(days: 6));

    return StreamBuilder<List<WorkoutExercise>>(
      stream: DatabaseService.instance.watchWorkoutExercisesRange(from, today),
      builder: (context, snap) {
        final byDay = <DateTime, List<WorkoutExercise>>{};
        for (final e in snap.data ?? <WorkoutExercise>[]) {
          byDay.putIfAbsent(e.date, () => []).add(e);
        }

        final days = List.generate(7, (i) => today.subtract(Duration(days: i)));
        final locale = Localizations.localeOf(context).toString();
        final fmt = DateFormat.MMMd(locale);

        return Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < days.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: i == days.length - 1
                      ? null
                      : BoxDecoration(
                          border: Border(bottom: BorderSide(color: p.cardBorder)),
                        ),
                  child: _CronologiaRow(
                    label: fmt.format(days[i]),
                    esercizi: byDay[days[i]] ?? const [],
                    p: p,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CronologiaRow extends StatelessWidget {
  final String label;
  final List<WorkoutExercise> esercizi;
  final ColorPalette p;
  const _CronologiaRow({required this.label, required this.esercizi, required this.p});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fatto = esercizi.isNotEmpty;
    final kcal = esercizi.fold<int>(0, (s, e) => s + (e.estimatedKcal ?? 0));

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fatto ? p.accent : p.cardBorder,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: p.textPrimary, fontSize: 13)),
        ),
        Text(
          fatto ? l10n.schedeNEsercizi(esercizi.length) : l10n.progressiNessunAllenamento,
          style: TextStyle(color: p.textMuted, fontSize: 12),
        ),
        if (fatto && kcal > 0) ...[
          const SizedBox(width: 8),
          Text('≈ $kcal kcal', style: TextStyle(color: p.accent, fontSize: 12)),
        ],
      ],
    );
  }
}

// ── Chart Box ─────────────────────────────────────────────────

class _ChartBox extends StatelessWidget {
  final List<_Point> points;
  final String unit;
  final Color color;
  final ColorPalette p;
  final List<double>? trendValues;

  const _ChartBox({
    required this.points,
    required this.unit,
    required this.color,
    required this.p,
    this.trendValues,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    String fmtDate(DateTime d) => DateFormat.Md(locale).format(d);
    final nf = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1);
    String fmt(double v) => nf.format(v);

    if (points.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.cardBorder),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart_rounded, color: p.textMuted, size: 36),
              const SizedBox(height: 8),
              Text(context.l10n.progressiNessunDato,
                  style: TextStyle(color: p.textMuted, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final dates = points.map((pt) => fmtDate(pt.date)).toList();

    final showTrend =
        trendValues != null && trendValues!.length == points.length;
    final trendSpots = showTrend
        ? trendValues!
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList()
        : const <FlSpot>[];

    final allY = [...spots.map((s) => s.y), ...trendSpots.map((s) => s.y)];
    final minY = allY.reduce(min);
    final maxY = allY.reduce(max);
    final pad = max((maxY - minY) * 0.2, 1.5);

    final last = points.last.value;
    final prev = points.length > 1 ? points[points.length - 2].value : null;
    final delta = prev != null ? last - prev : null;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          // Chart
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
              child: LineChart(
                LineChartData(
                  minY: minY - pad,
                  maxY: maxY + pad,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: spots.length > 2,
                      curveSmoothness: 0.3,
                      color: color,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.07),
                      ),
                      dotData: FlDotData(
                        show: spots.length <= 14,
                        getDotPainter: (spot, pct, bar, idx) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: color,
                          strokeWidth: 1.5,
                          strokeColor: p.background,
                        ),
                      ),
                    ),
                    if (showTrend)
                      LineChartBarData(
                        spots: trendSpots,
                        isCurved: trendSpots.length > 2,
                        curveSmoothness: 0.3,
                        color: p.textSecondary.withValues(alpha: 0.6),
                        barWidth: 1.5,
                        dashArray: [6, 4],
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(fmt(value),
                              style: TextStyle(
                                  color: p.textMuted, fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval:
                            max(1, (spots.length / 4).ceil()).toDouble(),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(dates[i],
                                style: TextStyle(
                                    color: p.textMuted, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: p.cardBorder.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => p.surface,
                      tooltipBorder: BorderSide(color: p.cardBorder),
                      getTooltipItems: (ts) => ts.map((s) {
                        final i = s.spotIndex;
                        final isTrend = s.barIndex == 1;
                        return LineTooltipItem(
                          isTrend
                              ? context.l10n.progressiMedia7gg(fmt(s.y), unit)
                              : '${dates[i]}\n${fmt(s.y)} $unit',
                          TextStyle(
                              color: isTrend ? p.textMuted : p.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Stats row
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: p.cardBorder)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    label: context.l10n.progressiStatUltimo,
                    value: '${fmt(last)} $unit',
                    color: color,
                    p: p),
                if (delta != null) ...[
                  Container(width: 1, height: 28, color: p.cardBorder),
                  _Stat(
                    label: context.l10n.progressiStatVariazione,
                    value: '${delta >= 0 ? '+' : ''}${fmt(delta)} $unit',
                    color: p.textSecondary,
                    p: p,
                  ),
                ],
                Container(width: 1, height: 28, color: p.cardBorder),
                _Stat(
                    label: context.l10n.progressiStatRilevazioni,
                    value: '${points.length}',
                    color: p.textSecondary,
                    p: p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorPalette p;
  const _SectionLabel(this.text, this.p);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600));
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorPalette p;

  const _RangeChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.accent : p.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? p.background : p.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ColorPalette p;

  const _Stat(
      {required this.label,
      required this.value,
      required this.color,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}

// ── Export helpers ─────────────────────────────────────────────

class _PdfLoadingDialog extends StatelessWidget {
  const _PdfLoadingDialog();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Dialog(
      backgroundColor: p.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: p.accent),
            ),
            const SizedBox(width: 16),
            Text(context.l10n.progressiGenerazionePdf,
                style: TextStyle(color: p.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
