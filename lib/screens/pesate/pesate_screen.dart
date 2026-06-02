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
        title: Text('PESATE', style: TextStyle(color: p.accent, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
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
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _PesataCard(
              pesata: pesate[i],
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
        title: Text('Elimina pesata', style: TextStyle(color: p.textPrimary)),
        content: Text('Sei sicuro di voler eliminare questa misurazione?', style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annulla', style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () {
              DatabaseService.instance.deleteBodySnapshot(id);
              Navigator.pop(ctx);
            },
            child: Text('Elimina', style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
  }
}

class _PesataCard extends StatelessWidget {
  final BodySnapshot pesata;
  final VoidCallback onDelete;

  const _PesataCard({required this.pesata, required this.onDelete});

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
                      if (pesata.bodyFatManuale != null) ...[
                        const SizedBox(width: 12),
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
          Text('Nessuna pesata', style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Premi + per aggiungere\nla prima misurazione', textAlign: TextAlign.center, style: TextStyle(color: p.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
