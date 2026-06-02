import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../models/plicometry_session.dart';
import '../../models/measurement_snapshot.dart';
import '../../services/database_service.dart';

// ── Field registry ─────────────────────────────────────────────

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

enum _Tab { composizione, misurazioni }
enum _CompMetric { bf, grassa, magra }

class ProgressiScreen extends StatefulWidget {
  const ProgressiScreen({super.key});

  @override
  State<ProgressiScreen> createState() => _ProgressiScreenState();
}

class _ProgressiScreenState extends State<ProgressiScreen> {
  _Tab _tab = _Tab.composizione;
  _CompMetric _compMetric = _CompMetric.bf;
  String _misuraKey = 'vitaCm';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text('PROGRESSI',
            style: TextStyle(
                color: p.accent, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: p.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // ── Tab selector ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _Chip(
                  label: 'Composizione',
                  selected: _tab == _Tab.composizione,
                  onTap: () => setState(() => _tab = _Tab.composizione),
                  p: p,
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: 'Misurazioni',
                  selected: _tab == _Tab.misurazioni,
                  onTap: () => setState(() => _tab = _Tab.misurazioni),
                  p: p,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── Sub-selector ─────────────────────────────
          if (_tab == _Tab.composizione)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _Chip(
                    label: 'BF%',
                    selected: _compMetric == _CompMetric.bf,
                    onTap: () => setState(() => _compMetric = _CompMetric.bf),
                    p: p,
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Massa Grassa',
                    selected: _compMetric == _CompMetric.grassa,
                    onTap: () => setState(() => _compMetric = _CompMetric.grassa),
                    p: p,
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Massa Magra',
                    selected: _compMetric == _CompMetric.magra,
                    onTap: () => setState(() => _compMetric = _CompMetric.magra),
                    p: p,
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _misureLabels.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _Chip(
                            label: e.value,
                            selected: _misuraKey == e.key,
                            onTap: () => setState(() => _misuraKey = e.key),
                            p: p,
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 20),
          // ── Chart ─────────────────────────────────────
          Expanded(
            child: _tab == _Tab.composizione
                ? _ComposizioneChart(metric: _compMetric, p: p)
                : _MisurazioniChart(
                    key: ValueKey(_misuraKey),
                    misuraKey: _misuraKey,
                    p: p,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Composizione Chart ─────────────────────────────────────────

class _ComposizioneChart extends StatelessWidget {
  final _CompMetric metric;
  final ColorPalette p;
  const _ComposizioneChart({required this.metric, required this.p});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlicometrySession>>(
      stream: DatabaseService.instance.watchPlicometrySessions(),
      builder: (context, snap) {
        final sessions = [...(snap.data ?? [])]
          ..sort((a, b) => a.data.compareTo(b.data));

        final points = sessions.map((s) {
          final v = switch (metric) {
            _CompMetric.bf     => s.risultati.bodyFatPercent,
            _CompMetric.grassa => s.risultati.massaGrassaKg,
            _CompMetric.magra  => s.risultati.massaMagraKg,
          };
          return (s.data, v);
        }).toList();

        final unit = metric == _CompMetric.bf ? '%' : 'kg';

        return _ChartView(
          points: points,
          unit: unit,
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
  final ColorPalette p;
  const _MisurazioniChart({super.key, required this.misuraKey, required this.p});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MeasurementSnapshot>>(
      stream: DatabaseService.instance.watchMeasurementSnapshots(),
      builder: (context, snap) {
        final snapshots = [...(snap.data ?? [])]
          ..sort((a, b) => a.data.compareTo(b.data));

        final points = snapshots
            .map((s) {
              final v = _snapValue(s, misuraKey);
              return v != null ? (s.data, v) : null;
            })
            .whereType<(DateTime, double)>()
            .toList();

        return _ChartView(
          points: points,
          unit: _unitFor(misuraKey),
          color: const Color(0xFF3B9FF2),
          p: p,
        );
      },
    );
  }
}

// ── Chart View ─────────────────────────────────────────────────

class _ChartView extends StatelessWidget {
  final List<(DateTime, double)> points;
  final String unit;
  final Color color;
  final ColorPalette p;

  const _ChartView({
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, color: p.textMuted, size: 52),
            const SizedBox(height: 12),
            Text('Nessun dato disponibile',
                style: TextStyle(color: p.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Registra delle misurazioni per vedere il grafico',
                style: TextStyle(
                    color: p.textMuted.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
      );
    }

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.$2))
        .toList();

    final dates = points.map((pt) => _fmtDate(pt.$1)).toList();

    final minY = spots.map((s) => s.y).reduce(min);
    final maxY = spots.map((s) => s.y).reduce(max);
    final pad  = max((maxY - minY) * 0.2, 1.5);

    final last  = points.last.$2;
    final prev  = points.length > 1 ? points[points.length - 2].$2 : null;
    final delta = prev != null ? last - prev : null;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 20, 0),
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
                      getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
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
                      reservedSize: 46,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(color: p.textMuted, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: max(1, (spots.length / 5).ceil()).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= dates.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(dates[i],
                              style:
                                  TextStyle(color: p.textMuted, fontSize: 10)),
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
        // ── Stats row ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    label: 'Ultimo',
                    value: '${last.toStringAsFixed(1)} $unit',
                    color: color,
                    p: p),
                if (delta != null) ...[
                  Container(width: 1, height: 32, color: p.cardBorder),
                  _Stat(
                    label: 'Variazione',
                    value:
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} $unit',
                    color: p.textSecondary,
                    p: p,
                  ),
                ],
                Container(width: 1, height: 32, color: p.cardBorder),
                _Stat(
                    label: 'Rilevazioni',
                    value: '${points.length}',
                    color: p.textSecondary,
                    p: p),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorPalette p;

  const _Chip(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

// ── Stat item ─────────────────────────────────────────────────

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
                color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}
