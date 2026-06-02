import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../models/plicometry_session.dart';
import '../../services/plicometry_calculator.dart';

class PlicometryResultScreen extends StatelessWidget {
  final PlicometrySession session;
  final PlicometryResult result;
  final Sesso sesso;

  const PlicometryResultScreen({
    super.key,
    required this.session,
    required this.result,
    required this.sesso,
  });

  String _methodLabel(MetodoPlicometria m) {
    switch (m) {
      case MetodoPlicometria.durninWomersley: return 'Durnin & Womersley';
      case MetodoPlicometria.jacksonPollock3: return 'Jackson & Pollock 3';
      case MetodoPlicometria.jacksonPollock7: return 'Jackson & Pollock 7';
      case MetodoPlicometria.faulkner:        return 'Faulkner';
      case MetodoPlicometria.usNavy:          return 'US Navy';
    }
  }

  Color _catColor(BfCategory cat, ColorPalette p) {
    switch (cat) {
      case BfCategory.grassoEssenziale: return const Color(0xFF3B9FF2);
      case BfCategory.atleta:           return p.accent;
      case BfCategory.fitness:          return const Color(0xFF26C9A7);
      case BfCategory.accettabile:      return const Color(0xFFFF8C42);
      case BfCategory.obeso:            return p.error;
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cat = PlicometryCalculator.categoria(result.bodyFatPercent, sesso);
    final catColor = _catColor(cat, p);

    return Scaffold(
      appBar: AppBar(
        title: Text('RISULTATO',
            style: TextStyle(
                color: p.accent, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  // ── BF% card ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.cardBorder),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [p.surface, p.accent.withValues(alpha: 0.04)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('BODY FAT',
                            style: TextStyle(
                                color: p.textMuted, fontSize: 11, letterSpacing: 2.5)),
                        const SizedBox(height: 8),
                        Text(
                          '${result.bodyFatPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                              color: p.accent,
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              height: 1.0),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: catColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            cat.label.toUpperCase(),
                            style: TextStyle(
                                color: catColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Massa grassa / magra ───────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Massa Grassa',
                          value: '${result.massaGrassaKg.toStringAsFixed(1)} kg',
                          p: p,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Massa Magra',
                          value: '${result.massaMagraKg.toStringAsFixed(1)} kg',
                          p: p,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Dettagli ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Metodo', value: _methodLabel(session.metodo), p: p),
                        _DetailRow(label: 'Data', value: _fmt(session.data), p: p),
                        _DetailRow(label: 'Peso', value: '${session.pesoKg.toStringAsFixed(1)} kg', p: p),
                        if (result.sommaPlicheMm > 0)
                          _DetailRow(
                            label: 'Somma pliche',
                            value: '${result.sommaPlicheMm.toStringAsFixed(1)} mm',
                            p: p,
                          ),
                        if (result.densitaCorporea != null)
                          _DetailRow(
                            label: 'Densità corporea',
                            value: result.densitaCorporea!.toStringAsFixed(4),
                            p: p,
                            isLast: true,
                          )
                        else
                          _DetailRow(
                              label: 'Formula', value: 'Siri (1956)', p: p, isLast: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('TORNA ALLA HOME'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final ColorPalette p;
  const _StatCard({required this.label, required this.value, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: p.textPrimary, fontSize: 19, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorPalette p;
  final bool isLast;
  const _DetailRow(
      {required this.label, required this.value, required this.p, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: p.textMuted, fontSize: 13)),
              Text(value,
                  style: TextStyle(
                      color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (!isLast) Divider(color: p.cardBorder, height: 1),
      ],
    );
  }
}
