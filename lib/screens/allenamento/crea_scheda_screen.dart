import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_exercise.dart' show SupersetRole;
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
      _normalizeGroups(updated);
      _esercizi = updated;
    });
  }

  /// Azzera `supersetGroupId` per i gruppi rimasti con un solo membro, che
  /// possono formarsi dopo la rimozione di un esercizio in mezzo a un gruppo.
  void _normalizeGroups(List<WorkoutTemplateExercise> list) {
    final counts = <int, int>{};
    for (final e in list) {
      final g = e.supersetGroupId;
      if (g != null) counts[g] = (counts[g] ?? 0) + 1;
    }
    for (final e in list) {
      if (e.supersetGroupId != null && counts[e.supersetGroupId] == 1) {
        e.supersetGroupId = null;
      }
    }
  }

  int _nextGroupId() {
    final ids = _esercizi.map((e) => e.supersetGroupId).whereType<int>();
    return ids.isEmpty ? 1 : ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Unisce/separa l'esercizio [i] in superset con quello precedente: i
  /// gruppi sono sempre formati da esercizi consecutivi nell'ordine della
  /// scheda (vedi `GuidedSessionService.groupSteps`).
  void _toggleSuperset(int i) {
    setState(() {
      final updated = [..._esercizi];
      final current = updated[i];
      final prev = updated[i - 1];
      if (current.supersetGroupId != null && current.supersetGroupId == prev.supersetGroupId) {
        current.supersetGroupId = null;
        current.supersetRole = null;
        _normalizeGroups(updated);
      } else {
        final groupId = prev.supersetGroupId ?? _nextGroupId();
        prev.supersetGroupId = groupId;
        current.supersetGroupId = groupId;
      }
      _esercizi = updated;
    });
  }

  /// Fase 3 di docs/tecniche_allenamento.md: assegna/toglie il ruolo
  /// esplosiva/lenta nella variante "superset veloce/lento" — tap sullo
  /// stesso ruolo già selezionato lo azzera (torna al superset semplice).
  void _setSupersetRole(int i, String role) {
    setState(() {
      final e = _esercizi[i];
      e.supersetRole = e.supersetRole == role ? null : role;
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
      body: SafeArea(
        top: false,
        child: ListView(
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
          for (var i = 0; i < _esercizi.length; i++) ...[
            if (i > 0) _SupersetConnector(
              grouped: _esercizi[i].supersetGroupId != null &&
                  _esercizi[i].supersetGroupId == _esercizi[i - 1].supersetGroupId,
              p: p,
              l10n: l10n,
              onTap: () => _toggleSuperset(i),
            ),
            _EsercizioRow(
              esercizio: _esercizi[i],
              p: p,
              l10n: l10n,
              onDelete: () => _rimuoviEsercizio(i),
              onSetRole: (role) => _setSupersetRole(i, role),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _aggiungiEsercizio,
            icon: Icon(Icons.add_rounded, color: p.accent),
            label: Text(l10n.creaSchedaAggiungiEsercizio, style: TextStyle(color: p.accent)),
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.cardBorder)),
          ),
        ],
        ),
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
  final AppLocalizations l10n;
  final VoidCallback onDelete;
  final ValueChanged<String> onSetRole;
  const _EsercizioRow({
    required this.esercizio,
    required this.p,
    required this.l10n,
    required this.onDelete,
    required this.onSetRole,
  });

  @override
  Widget build(BuildContext context) {
    final planned = esercizio.plannedSets;
    final target = esercizio.isCardio
        ? '${esercizio.targetDurationSeconds! ~/ 60} min'
        : planned != null && planned.isNotEmpty
            ? planned
                .map((s) => '${s.reps ?? '-'}×${s.weightKg != null ? '${s.weightKg}kg' : '-'}')
                .join(' · ')
            : '${esercizio.targetSets ?? '-'}×${esercizio.targetReps ?? '-'}'
                '${esercizio.targetWeightKg != null ? ' · ${esercizio.targetWeightKg}kg' : ''}';
    final grouped = esercizio.supersetGroupId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: grouped ? p.accent.withValues(alpha: 0.5) : p.cardBorder),
      ),
      child: Row(
        children: [
          if (grouped) ...[
            Icon(Icons.link_rounded, color: p.accent, size: 16),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(esercizio.exerciseName,
                    style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
                Text(target, style: TextStyle(color: p.textMuted, fontSize: 12)),
                // Fase 3 di docs/tecniche_allenamento.md: ruolo esplosiva/lenta,
                // solo per righe già in un gruppo superset — variante "veloce/
                // lento" della tecnica, opzionale.
                if (grouped) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      _RoleChip(
                        label: l10n.creaSchedaRuoloEsplosiva,
                        selected: esercizio.supersetRole == SupersetRole.esplosiva.name,
                        p: p,
                        onTap: () => onSetRole(SupersetRole.esplosiva.name),
                      ),
                      _RoleChip(
                        label: l10n.creaSchedaRuoloLenta,
                        selected: esercizio.supersetRole == SupersetRole.lenta.name,
                        p: p,
                        onTap: () => onSetRole(SupersetRole.lenta.name),
                      ),
                    ],
                  ),
                ],
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

class _SupersetConnector extends StatelessWidget {
  final bool grouped;
  final ColorPalette p;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  const _SupersetConnector(
      {required this.grouped, required this.p, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(grouped ? Icons.link_rounded : Icons.link_off_rounded,
            size: 16, color: grouped ? p.accent : p.textMuted),
        label: Text(
          grouped ? l10n.creaSchedaSupersetUnito : l10n.creaSchedaSupersetUnisci,
          style: TextStyle(fontSize: 11, color: grouped ? p.accent : p.textMuted),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// Chip compatto per il ruolo esplosiva/lenta (superset veloce/lento,
/// docs/tecniche_allenamento.md Fase 3) — tap sullo stesso ruolo selezionato
/// lo azzera, gestito dal chiamante (`onTap`).
class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ColorPalette p;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label, required this.selected, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.15) : p.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? p.accent : p.cardBorder),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: selected ? p.accent : p.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}
