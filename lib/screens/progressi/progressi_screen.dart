import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../models/plicometry_session.dart';
import '../../models/measurement_snapshot.dart';
import '../../services/database_service.dart';

// ── Data helpers ───────────────────────────────────────────────

class _Point {
  final DateTime date;
  final double value;
  const _Point(this.date, this.value);
}

enum _Range { month1, month3, month6, year1, all }

extension _RangeExt on _Range {
  String get label {
    switch (this) {
      case _Range.month1: return '1M';
      case _Range.month3: return '3M';
      case _Range.month6: return '6M';
      case _Range.year1:  return '1A';
      case _Range.all:    return 'Tutto';
    }
  }

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
  String get label {
    switch (this) {
      case _CompMetric.bf:     return 'BF%';
      case _CompMetric.grassa: return 'Massa Grassa';
      case _CompMetric.magra:  return 'Massa Magra';
    }
  }

  String get unit {
    return this == _CompMetric.bf ? '%' : 'kg';
  }
}

const _misureLabels = <String, String>{
  'vitaCm':           'Vita',
  'fianchiCm':        'Fianchi',
  'braccioCm':        'Braccio',
  'colloCm':          'Collo',
  'cosciaCm':         'Coscia',
  'polpaccioCm':      'Polpaccio',
  'toraceCm':         'Torace',
  'spalleCm':         'Spalle',
  'tricipiteMm':      'Tricipite',
  'bicipiteMm':       'Bicipite',
  'sottoscapolareMm': 'Sottoscap.',
  'sovrailiachMm':    'Sovrailiaca',
  'addomineMm':       'Addome',
  'cosciaMm':         'Coscia (pl.)',
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final start = _range.startDate;

    return Scaffold(
      appBar: AppBar(
        title: Text('PROGRESSI',
            style: TextStyle(
                color: p.accent,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
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
                    label: r.label,
                    selected: _range == r,
                    onTap: () => setState(() => _range = r),
                    p: p,
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Grafico 1: Composizione ───────────────────
            _SectionLabel('COMPOSIZIONE CORPOREA', p),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _CompMetric.values.map((m) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RangeChip(
                    label: m.label,
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

            // ── Grafico 2: Misurazioni ────────────────────
            _SectionLabel('MISURAZIONI', p),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _misureLabels.entries.map((e) => Padding(
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
          ],
        ),
      ),
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

// ── Chart Box ─────────────────────────────────────────────────

class _ChartBox extends StatelessWidget {
  final List<_Point> points;
  final String unit;
  final Color color;
  final ColorPalette p;

  const _ChartBox({
    required this.points,
    required this.unit,
    required this.color,
    required this.p,
  });

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
              Text('Nessun dato nel periodo selezionato',
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
    final dates = points.map((pt) => _fmtDate(pt.date)).toList();

    final minY = spots.map((s) => s.y).reduce(min);
    final maxY = spots.map((s) => s.y).reduce(max);
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
                          return Text(value.toStringAsFixed(1),
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
                        return LineTooltipItem(
                          '${dates[i]}\n${s.y.toStringAsFixed(1)} $unit',
                          TextStyle(
                              color: p.textPrimary,
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
                    label: 'Ultimo',
                    value: '${last.toStringAsFixed(1)} $unit',
                    color: color,
                    p: p),
                if (delta != null) ...[
                  Container(width: 1, height: 28, color: p.cardBorder),
                  _Stat(
                    label: 'Variazione',
                    value:
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} $unit',
                    color: p.textSecondary,
                    p: p,
                  ),
                ],
                Container(width: 1, height: 28, color: p.cardBorder),
                _Stat(
                    label: 'Rilevazioni',
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
