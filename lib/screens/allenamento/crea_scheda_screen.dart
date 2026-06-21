import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_template.dart';
import '../../models/workout_template_exercise.dart';
import '../../services/database_service.dart';
import '../esercizi/catalogo_esercizi_screen.dart';
import 'target_esercizio_dialog.dart';

/// Crea o modifica una scheda (WorkoutTemplate). Se [programId] è specificato,
/// la scheda creata è un giorno di quel programma (con [order]).
class CreaSchedaScreen extends StatefulWidget {
  final WorkoutTemplate? existing;
  final int? programId;
  final int order;

  const CreaSchedaScreen({super.key, this.existing, this.programId, this.order = 0});

  @override
  State<CreaSchedaScreen> createState() => _CreaSchedaScreenState();
}

class _CreaSchedaScreenState extends State<CreaSchedaScreen> {
  late final _nomeCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late List<WorkoutTemplateExercise> _esercizi =
      List.of(widget.existing?.exercises ?? const []);
  String? _errore;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _aggiungiEsercizio() async {
    final exercise = await showCatalogoEserciziSheet(context);
    if (exercise == null || !mounted) return;
    final target = await showTargetEsercizioDialog(context, exercise);
    if (target != null) {
      setState(() => _esercizi = [..._esercizi, target]);
    }
  }

  void _rimuoviEsercizio(int i) {
    setState(() {
      final updated = [..._esercizi];
      updated.removeAt(i);
      _esercizi = updated;
    });
  }

  Future<void> _salva() async {
    final l10n = context.l10n;
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) {
      setState(() => _errore = l10n.creaSchedaNomeObbligatorio);
      return;
    }
    if (_esercizi.isEmpty) {
      setState(() => _errore = l10n.creaSchedaNessunEsercizio);
      return;
    }

    final template = widget.existing ??
        (WorkoutTemplate()
          ..createdAt = DateTime.now()
          ..programId = widget.programId
          ..order = widget.order);
    template
      ..name = nome
      ..exercises = _esercizi;

    await DatabaseService.instance.saveWorkoutTemplate(template);
    if (mounted) Navigator.pop(context, template);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(isEdit ? l10n.creaSchedaTitleModifica : l10n.creaSchedaTitleNuova,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text(l10n.creaSchedaNomeLabel,
              style: TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _nomeCtrl,
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.creaSchedaNomeHint,
              hintStyle: TextStyle(color: p.textMuted),
              filled: true,
              fillColor: p.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.cardBorder),
              ),
            ),
          ),
          if (_errore != null) ...[
            const SizedBox(height: 6),
            Text(_errore!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          for (var i = 0; i < _esercizi.length; i++)
            _EsercizioRow(esercizio: _esercizi[i], p: p, onDelete: () => _rimuoviEsercizio(i)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _aggiungiEsercizio,
            icon: Icon(Icons.add_rounded, color: p.accent),
            label: Text(l10n.creaSchedaAggiungiEsercizio, style: TextStyle(color: p.accent)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.cardBorder)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salva,
        backgroundColor: p.accent,
        foregroundColor: p.background,
        icon: const Icon(Icons.check_rounded),
        label: Text(l10n.eserciziSalva, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EsercizioRow extends StatelessWidget {
  final WorkoutTemplateExercise esercizio;
  final ColorPalette p;
  final VoidCallback onDelete;
  const _EsercizioRow({required this.esercizio, required this.p, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final target = esercizio.targetDurationSeconds != null
        ? '${esercizio.targetDurationSeconds! ~/ 60} min'
        : '${esercizio.targetSets ?? '-'}×${esercizio.targetReps ?? '-'}'
            '${esercizio.targetWeightKg != null ? ' · ${esercizio.targetWeightKg}kg' : ''}';

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esercizio.exerciseName,
                    style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
                Text(target, style: TextStyle(color: p.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.close_rounded, color: p.textMuted, size: 18),
          ),
        ],
      ),
    );
  }
}
