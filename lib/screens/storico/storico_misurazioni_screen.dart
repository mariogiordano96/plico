import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/measurement_snapshot.dart';
import '../../services/database_service.dart';
import 'add_measurement_screen.dart';

class StoricoMisurazioniScreen extends StatelessWidget {
  const StoricoMisurazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text('MISURAZIONI', style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: StreamBuilder<List<MeasurementSnapshot>>(
        stream: DatabaseService.instance.watchMeasurementSnapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: p.accent));
          final items = snapshot.data!;
          if (items.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _SnapshotCard(
              snapshot: items[i],
              onDelete: () => _confirmDelete(context, items[i].id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMeasurementScreen())),
        backgroundColor: p.accent,
        foregroundColor: p.background,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final p = context.palette;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text('Elimina misurazione', style: TextStyle(color: p.textPrimary)),
        content: Text('Eliminare i dati di questa giornata?', style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annulla', style: TextStyle(color: p.textMuted))),
          TextButton(
            onPressed: () { DatabaseService.instance.deleteMeasurementSnapshot(id); Navigator.pop(ctx); },
            child: Text('Elimina', style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final MeasurementSnapshot snapshot;
  final VoidCallback onDelete;

  const _SnapshotCard({required this.snapshot, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final d = snapshot.data;
    final dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final hasPliche = snapshot.contPliche > 0;
    final hasCirc = snapshot.contCirconferenze > 0;

    return Dismissible(
      key: Key('snap_${snapshot.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async { onDelete(); return false; },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: p.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_outline_rounded, color: p.error),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                Row(
                  children: snapshot.fonti.map((f) => _SourceBadge(fonte: f)).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasPliche) _CountChip(icon: Icons.straighten_rounded, label: '${snapshot.contPliche} pliche', p: p),
                if (hasPliche && hasCirc) const SizedBox(width: 8),
                if (hasCirc) _CountChip(icon: Icons.radio_button_unchecked_rounded, label: '${snapshot.contCirconferenze} circonf.', p: p),
              ],
            ),
            if (hasPliche) ...[
              const SizedBox(height: 12),
              _ValuesRow(snapshot: snapshot, p: p),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValuesRow extends StatelessWidget {
  final MeasurementSnapshot snapshot;
  final ColorPalette p;

  const _ValuesRow({required this.snapshot, required this.p});

  @override
  Widget build(BuildContext context) {
    final values = <_Val>[
      if (snapshot.tricipiteMm != null) _Val('Tric.', '${snapshot.tricipiteMm!.toStringAsFixed(1)}mm'),
      if (snapshot.bicipiteMm != null) _Val('Bic.', '${snapshot.bicipiteMm!.toStringAsFixed(1)}mm'),
      if (snapshot.pettoraleMm != null) _Val('Pett.', '${snapshot.pettoraleMm!.toStringAsFixed(1)}mm'),
      if (snapshot.ascelllareMm != null) _Val('Asc.', '${snapshot.ascelllareMm!.toStringAsFixed(1)}mm'),
      if (snapshot.sottoscapolareMm != null) _Val('Sott.', '${snapshot.sottoscapolareMm!.toStringAsFixed(1)}mm'),
      if (snapshot.sovrailiachMm != null) _Val('Sovr.', '${snapshot.sovrailiachMm!.toStringAsFixed(1)}mm'),
      if (snapshot.addomineMm != null) _Val('Add.', '${snapshot.addomineMm!.toStringAsFixed(1)}mm'),
      if (snapshot.cosciaMm != null) _Val('Cosc.', '${snapshot.cosciaMm!.toStringAsFixed(1)}mm'),
      if (snapshot.polpaccioMm != null) _Val('Polp.', '${snapshot.polpaccioMm!.toStringAsFixed(1)}mm'),
      if (snapshot.vitaCm != null) _Val('Vita', '${snapshot.vitaCm!.toStringAsFixed(1)}cm'),
      if (snapshot.fianchiCm != null) _Val('Fian.', '${snapshot.fianchiCm!.toStringAsFixed(1)}cm'),
      if (snapshot.braccioCm != null) _Val('Brac.', '${snapshot.braccioCm!.toStringAsFixed(1)}cm'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: values.map((v) => _ValueChip(val: v, p: p)).toList(),
    );
  }
}

class _Val { final String label; final String value; const _Val(this.label, this.value); }

class _ValueChip extends StatelessWidget {
  final _Val val;
  final ColorPalette p;
  const _ValueChip({required this.val, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: p.accent.withValues(alpha: 0.2))),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: '${val.label} ', style: TextStyle(color: p.textMuted, fontSize: 10)),
          TextSpan(text: val.value, style: TextStyle(color: p.accent, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorPalette p;
  const _CountChip({required this.icon, required this.label, required this.p});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: p.textMuted, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String fonte;
  const _SourceBadge({required this.fonte});

  static const _labels = {
    'manuale': 'Manuale',
    'durninWomersley': 'D&W',
    'jacksonPollock3': 'J&P 3',
    'jacksonPollock7': 'J&P 7',
    'faulkner': 'Faulkner',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final label = _labels[fonte] ?? fonte;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: p.accentSecondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5), border: Border.all(color: p.accentSecondary.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: p.accentSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent.withValues(alpha: 0.08), border: Border.all(color: p.accent.withValues(alpha: 0.2))),
            child: Icon(Icons.straighten_rounded, color: p.accent, size: 32),
          ),
          const SizedBox(height: 20),
          Text('Nessuna misurazione', style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Le misurazioni appariranno qui\ndopo una sessione o un inserimento manuale.',
              textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, height: 1.5, fontSize: 13)),
        ],
      ),
    );
  }
}
