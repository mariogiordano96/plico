import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database_service.dart';
import '../../services/workout_progress_service.dart';
import '../esercizi/muscle_group_labels.dart';

/// "Volume settimanale per gruppo muscolare" (Fase 18): grafico a barre del
/// volume (Σ rip × peso) della settimana corrente per gruppo, con banner di
/// avviso per i gruppi trascurati. Vedi docs/evolutiva_esercizi.md, sezione
/// "Volume settimanale per gruppo muscolare".
class VolumeSettimanaleScreen extends StatefulWidget {
  const VolumeSettimanaleScreen({super.key});

  @override
  State<VolumeSettimanaleScreen> createState() => _VolumeSettimanaleScreenState();
}

class _VolumeSettimanaleScreenState extends State<VolumeSettimanaleScreen> {
  // Solo i gruppi allenabili con carico: la voce "cardio" del catalogo non
  // ha senso in un grafico di volume (Σ rip × peso).
  static final _gruppi = muscleGroups.where((g) => g != 'cardio').toList();

  Map<String, double> _volumeByGroup = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final volume = await DatabaseService.instance.getWeeklyVolumeByMuscleGroup(monday);
    if (mounted) {
      setState(() {
        _volumeByGroup = volume;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final neglected = WorkoutProgressService.neglectedMuscleGroups(_volumeByGroup);
    final maxVolume = _gruppi
        .map((g) => _volumeByGroup[g] ?? 0)
        .fold<double>(0, (max, v) => v > max ? v : max);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.volumeSettimanaleTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (maxVolume == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(l10n.volumeSettimanaleVuoto,
                          style: TextStyle(color: p.textMuted),
                          textAlign: TextAlign.center),
                    ),
                  )
                else ...[
                  _VolumeChart(
                    gruppi: _gruppi,
                    volumeByGroup: _volumeByGroup,
                    maxVolume: maxVolume,
                    p: p,
                    l10n: l10n,
                  ),
                  if (neglected.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final g in neglected)
                      _NeglectedBanner(label: muscleGroupLabel(l10n, g), p: p, l10n: l10n),
                  ],
                ],
              ],
            ),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  final List<String> gruppi;
  final Map<String, double> volumeByGroup;
  final double maxVolume;
  final ColorPalette p;
  final AppLocalizations l10n;
  const _VolumeChart({
    required this.gruppi,
    required this.volumeByGroup,
    required this.maxVolume,
    required this.p,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVolume * 1.2 + 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= gruppi.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      muscleGroupLabel(l10n, gruppi[i]),
                      style: TextStyle(color: p.textMuted, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < gruppi.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: volumeByGroup[gruppi[i]] ?? 0,
                    color: p.accent,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NeglectedBanner extends StatelessWidget {
  final String label;
  final ColorPalette p;
  final AppLocalizations l10n;
  const _NeglectedBanner({required this.label, required this.p, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.volumeSettimanaleTrascurato(label),
              style: TextStyle(color: p.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
