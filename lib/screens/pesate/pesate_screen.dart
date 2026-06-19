import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/body_snapshot.dart';
import '../../services/database_service.dart';
import 'add_pesata_screen.dart';

class PesateScreen extends StatelessWidget {
  const PesateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pesateTitolo, style: TextStyle(color: p.accent, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: StreamBuilder<List<BodySnapshot>>(
        stream: DatabaseService.instance.watchBodySnapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: context.palette.accent));
          }
          final pesate = snapshot.data!;
          if (pesate.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: pesate.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _PesataCard(
              pesata: pesate[i],
              delta: i + 1 < pesate.length
                  ? pesate[i].pesoKg - pesate[i + 1].pesoKg
                  : null,
              onDelete: () => _confirmDelete(context, pesate[i].id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPesataScreen())),
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
        title: Text(context.l10n.pesateEliminaTitle, style: TextStyle(color: p.textPrimary)),
        content: Text(context.l10n.pesateEliminaSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.instance.deleteBodySnapshot(id);
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.appElimina, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
  }
}

class _PesataCard extends StatelessWidget {
  final BodySnapshot pesata;
  final double? delta;
  final VoidCallback onDelete;

  const _PesataCard({required this.pesata, required this.delta, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final data = pesata.data;
    final dataStr = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

    return Dismissible(
      key: Key('pesata_${pesata.id}'),
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
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: p.accent.withValues(alpha: 0.25))),
              child: Icon(Icons.monitor_weight_outlined, color: p.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dataStr, style: TextStyle(color: p.textMuted, fontSize: 12, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${pesata.pesoKg.toStringAsFixed(1)} kg',
                          style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                      if (delta != null) ...[
                        const SizedBox(width: 10),
                        _DeltaBadge(delta: delta!),
                      ],
                      if (pesata.bodyFatManuale != null) ...[
                        const SizedBox(width: 8),
                        _Badge(label: '${pesata.bodyFatManuale!.toStringAsFixed(1)}% BF'),
                      ],
                    ],
                  ),
                  if (pesata.note != null && pesata.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(pesata.note!, style: TextStyle(color: p.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.accentSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.accentSecondary.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: p.accentSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  final double delta;
  const _DeltaBadge({required this.delta});

  @override
  Widget build(BuildContext context) {
    final up = delta > 0;
    final color = up ? const Color(0xFFE74C3C) : const Color(0xFF00C48C);
    final sign = up ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 10, color: color),
          const SizedBox(width: 2),
          Text('$sign${delta.toStringAsFixed(1)} kg',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
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
            child: Icon(Icons.monitor_weight_outlined, color: p.accent, size: 32),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.pesateNessuna, style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(context.l10n.pesateNessunaSub, textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
