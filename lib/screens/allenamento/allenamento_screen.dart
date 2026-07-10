import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template.dart';
import '../../services/calorie_estimation_service.dart';
import '../../services/database_service.dart';
import '../esercizi/catalogo_esercizi_screen.dart';
import 'le_mie_schede_screen.dart';
import 'log_cardio_dialog.dart';
import 'log_serie_dialog.dart';
import 'rest_timer_settings_dialog.dart';
import 'sessione_guidata_screen.dart';
import 'sostituisci_esercizio_sheet.dart';
import 'storico_esercizio_screen.dart';

class AllenamentoScreen extends StatefulWidget {
  const AllenamentoScreen({super.key});

  @override
  State<AllenamentoScreen> createState() => _AllenamentoScreenState();
}

class _AllenamentoScreenState extends State<AllenamentoScreen> {
  DateTime _data = _dayStart(DateTime.now());
  String? _nota;

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  bool get _isToday => _data == _dayStart(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadNota();
  }

  void _changeDate(DateTime date) {
    setState(() => _data = date);
    _loadNota();
  }

  Future<void> _loadNota() async {
    final log = await DatabaseService.instance.getWorkoutLog(_data);
    if (mounted) setState(() => _nota = log?.note);
  }

  String _formatDate(DateTime d) {
    final l10n = context.l10n;
    const weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic'
    ];
    final today = _dayStart(DateTime.now());
    if (d == today) return l10n.diarioOggi;
    if (d == today.subtract(const Duration(days: 1))) return l10n.diarioIeri;
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  Future<void> _editNota() async {
    final l10n = context.l10n;
    final p = context.palette;
    final ctrl = TextEditingController(text: _nota ?? '');
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.allenamentoNotaTitle,
                  style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 4,
                style: TextStyle(color: p.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.allenamentoNotaHint,
                  hintStyle: TextStyle(color: p.textMuted),
                  filled: true,
                  fillColor: p.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(backgroundColor: p.accent),
                      child: Text(l10n.eserciziSalva,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
    if (saved == true) {
      final text = ctrl.text.trim();
      await DatabaseService.instance.setWorkoutNote(_data, text.isEmpty ? null : text);
      if (mounted) setState(() => _nota = text.isEmpty ? null : text);
    }
  }

  Future<void> _apriSchede() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeMieSchedeScreen()),
    );
  }

  /// Aggiunge al log del giorno l'esercizio scelto dal catalogo, con target di
  /// default (3 serie vuote) da compilare più tardi in modalità guidata
  /// (`_avviaAllenamento`) — creazione e avvio sono due passi separati, vedi
  /// `_avviaAllenamento`.
  Future<void> _aggiungiEsercizio() async {
    final exercise = await showCatalogoEserciziSheet(context);
    if (exercise == null || !mounted) return;

    final isCardio = exercise.category == 'cardio';
    final workoutExercise = WorkoutExercise()
      ..exerciseId = exercise.externalId
      ..exerciseName = exercise.nameIt ?? exercise.name
      ..sets = isCardio ? [] : List.generate(3, (_) => WorkoutSet());

    await DatabaseService.instance.addWorkoutExercise(_data, workoutExercise);
  }

  bool _isDone(WorkoutExercise e) =>
      e.sets.isEmpty ? e.cardioConfirmed : e.sets.every((s) => s.confirmed);

  /// Avvia la modalità guidata su tutti gli esercizi già presenti nel log del
  /// giorno (aggiunti liberamente o popolati da una scheda/programma con
  /// "Inizia") — l'unico punto in cui parte la sessione interattiva.
  Future<void> _avviaAllenamento(List<WorkoutExercise> esercizi) async {
    final l10n = context.l10n;
    final adHocTemplate = WorkoutTemplate()
      ..name = l10n.allenamentoSessioneOggiTitle
      ..createdAt = DateTime.now();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessioneGuidataScreen(template: adHocTemplate, exercises: esercizi),
      ),
    );
  }

  Future<void> _modifica(WorkoutExercise e) async {
    final stub = ExerciseDefinition()
      ..externalId = e.exerciseId
      ..name = e.exerciseName
      ..muscleGroup = ''
      ..category = e.durationSeconds != null ? 'cardio' : 'strength';

    final updated = e.durationSeconds != null
        ? await showLogCardioDialog(context, stub, initial: e)
        : await showLogSerieDialog(context, stub, initial: e);
    if (updated == null || !mounted) return;

    final bodySnapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final bodyWeightKg = bodySnapshot?.pesoKg;
    if (updated.durationSeconds != null) {
      updated.met = CalorieEstimationService.metForCardioExercise(updated.exerciseId).round();
      updated.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
        exerciseId: updated.exerciseId,
        durationSeconds: updated.durationSeconds!,
        bodyWeightKg: bodyWeightKg,
      );
    } else {
      updated.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
        workingSetCount: updated.sets.length,
        bodyWeightKg: bodyWeightKg,
      );
    }
    await DatabaseService.instance.updateWorkoutExercise(updated);
  }

  Future<void> _elimina(WorkoutExercise e) async {
    final p = context.palette;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.allenamentoEliminaTitle, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.allenamentoEliminaSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.appElimina, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteWorkoutExercise(e.id);
    }
  }

  Future<void> _eliminaGiornata() async {
    final p = context.palette;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title:
            Text(l10n.allenamentoEliminaGiornataTitle, style: TextStyle(color: p.textPrimary)),
        content:
            Text(l10n.allenamentoEliminaGiornataSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.appElimina, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteWorkoutLog(_data);
      if (mounted) setState(() => _nota = null);
    }
  }

  Future<void> _sostituisci(WorkoutExercise e) async {
    final alt = await showSostituisciEsercizioSheet(context, e.exerciseId);
    if (alt == null || !mounted) return;

    e.exerciseId = alt.externalId;
    e.exerciseName = alt.nameIt ?? alt.name;

    final bodySnapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final bodyWeightKg = bodySnapshot?.pesoKg;
    if (e.durationSeconds != null) {
      e.met = CalorieEstimationService.metForCardioExercise(e.exerciseId).round();
      e.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
        exerciseId: e.exerciseId,
        durationSeconds: e.durationSeconds!,
        bodyWeightKg: bodyWeightKg,
      );
    } else {
      e.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
        workingSetCount: e.sets.length,
        bodyWeightKg: bodyWeightKg,
      );
    }
    await DatabaseService.instance.updateWorkoutExercise(e);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    return StreamBuilder<List<WorkoutExercise>>(
      stream: DatabaseService.instance.watchWorkoutExercisesForDay(_data),
      builder: (context, snapshot) {
        final esercizi = snapshot.data ?? [];
        return _buildScaffold(context, p, l10n, snapshot.hasData, esercizi);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, ColorPalette p, AppLocalizations l10n,
      bool hasData, List<WorkoutExercise> esercizi) {
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.tabAllenamento,
            style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showRestTimerSettingsDialog(context),
            icon: Icon(Icons.timer_outlined, color: p.accent),
            tooltip: l10n.restTimerSettingsTitle,
          ),
          IconButton(
            onPressed: _apriSchede,
            icon: Icon(Icons.list_alt_rounded, color: p.accent),
            tooltip: l10n.schedeTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          _DateNav(
            label: _formatDate(_data),
            onPrev: () => _changeDate(_data.subtract(const Duration(days: 1))),
            onNext: _isToday ? null : () => _changeDate(_data.add(const Duration(days: 1))),
            p: p,
          ),
          if (_nota != null && _nota!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GestureDetector(
                onTap: _editNota,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.sticky_note_2_outlined, color: p.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_nota!, style: TextStyle(color: p.textSecondary, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: !hasData
                ? Center(child: CircularProgressIndicator(color: p.accent))
                : esercizi.isEmpty
                    ? _EmptyState(onStartFromScheda: _apriSchede, onAdd: _aggiungiEsercizio)
                    : ListView.separated(
                        // Spazio extra in fondo quando è presente anche il
                        // pulsante "Avvia allenamento"/elimina sopra la riga
                        // nota/esercizio libero, altrimenti l'ultima card
                        // finisce sotto il FAB.
                        padding: EdgeInsets.fromLTRB(
                            16, 16, 16, esercizi.isNotEmpty && !esercizi.every(_isDone) ? 170 : 100),
                        itemCount: esercizi.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final e = esercizi[i];
                          final isGroupStart = e.supersetGroupId != null &&
                              (i == 0 || esercizi[i - 1].supersetGroupId != e.supersetGroupId);
                          final isSourceStart = e.sourceTemplateId != null &&
                              (i == 0 ||
                                  esercizi[i - 1].sourceTemplateId != e.sourceTemplateId ||
                                  esercizi[i - 1].sourceProgramId != e.sourceProgramId);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isSourceStart)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.list_alt_rounded, color: p.textMuted, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          e.sourceProgramName != null
                                              ? l10n.allenamentoFonteSchedaProgramma(
                                                  e.sourceTemplateName!, e.sourceProgramName!)
                                              : l10n.allenamentoFonteScheda(e.sourceTemplateName!),
                                          style: TextStyle(
                                              color: p.textMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (isGroupStart)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.link_rounded, color: p.accent, size: 14),
                                      const SizedBox(width: 6),
                                      Text(l10n.sessioneGuidataSuperset,
                                          style: TextStyle(
                                              color: p.accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              _ExerciseCard(
                                exercise: e,
                                p: p,
                                l10n: l10n,
                                onDelete: () => _elimina(e),
                                onSostituisci: () => _sostituisci(e),
                                onModifica: () => _modifica(e),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (esercizi.isNotEmpty && !esercizi.every(_isDone)) ...[
            FloatingActionButton.extended(
              heroTag: 'allenamentoAvvia',
              onPressed: () => _avviaAllenamento(esercizi),
              backgroundColor: p.accent,
              foregroundColor: p.background,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.allenamentoAvviaButton,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              tooltip: l10n.allenamentoAvviaButtonSub,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isToday && esercizi.isNotEmpty && esercizi.every(_isDone)) ...[
                FloatingActionButton(
                  heroTag: 'allenamentoElimina',
                  onPressed: _eliminaGiornata,
                  backgroundColor: p.error,
                  foregroundColor: p.background,
                  tooltip: l10n.allenamentoEliminaGiornataTitle,
                  child: const Icon(Icons.delete_sweep_rounded),
                ),
                const SizedBox(width: 12),
              ],
              FloatingActionButton.extended(
                heroTag: 'allenamentoNota',
                onPressed: _editNota,
                backgroundColor: p.surface,
                foregroundColor: p.accent,
                elevation: 0,
                tooltip: l10n.allenamentoNotaTitle,
                icon: Icon(
                  _nota != null && _nota!.isNotEmpty
                      ? Icons.edit_note_rounded
                      : Icons.note_add_outlined,
                ),
                label: Text(
                  _nota != null && _nota!.isNotEmpty
                      ? l10n.allenamentoModificaNotaButton
                      : l10n.allenamentoAggiungiNotaButton,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                heroTag: 'allenamentoAggiungiEsercizio',
                onPressed: _aggiungiEsercizio,
                backgroundColor: p.surface,
                foregroundColor: p.accent,
                elevation: 0,
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text(l10n.allenamentoAggiungiEsercizio,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                tooltip: l10n.allenamentoAggiungiEsercizioSub,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartFromScheda;
  final VoidCallback onAdd;
  const _EmptyState({required this.onStartFromScheda, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_rounded, color: p.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(l10n.allenamentoVuotoTitle,
                style: TextStyle(
                    color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.allenamentoVuotoSub,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStartFromScheda,
                style: FilledButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.list_alt_rounded),
                label: Text(l10n.allenamentoIniziaDaScheda,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.playlist_add_rounded, color: p.textMuted, size: 18),
              label: Text(l10n.allenamentoAggiungiEsercizio, style: TextStyle(color: p.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final ColorPalette p;
  final AppLocalizations l10n;
  final VoidCallback onDelete;
  final VoidCallback onSostituisci;
  final VoidCallback onModifica;

  const _ExerciseCard({
    required this.exercise,
    required this.p,
    required this.l10n,
    required this.onDelete,
    required this.onSostituisci,
    required this.onModifica,
  });

  @override
  Widget build(BuildContext context) {
    final isCardio = exercise.durationSeconds != null;
    final sottotitolo = isCardio
        ? l10n.allenamentoDurataMin(exercise.durationSeconds! ~/ 60)
        : exercise.sets
            .map((s) => '${s.reps ?? '-'}×${s.weightKg != null ? '${s.weightKg}kg' : '-'}')
            .join(', ');
    final kcalLabel = exercise.estimatedKcal != null ? '≈ ${exercise.estimatedKcal} kcal' : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoricoEsercizioScreen(
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                  ),
                ),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.exerciseName,
                    style: TextStyle(
                        color: p.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  isCardio
                      ? sottotitolo
                      : (exercise.sets.isEmpty
                          ? l10n.allenamentoSerieCount(0)
                          : sottotitolo),
                  style: TextStyle(color: p.textMuted, fontSize: 13),
                ),
                if (kcalLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(kcalLabel, style: TextStyle(color: p.accent, fontSize: 12)),
                ],
              ],
              ),
            ),
          ),
          PopupMenuButton<_ExerciseCardAction>(
            icon: Icon(Icons.more_vert_rounded, color: p.textMuted),
            color: p.surface,
            onSelected: (action) {
              switch (action) {
                case _ExerciseCardAction.modifica:
                  onModifica();
                case _ExerciseCardAction.sostituisci:
                  onSostituisci();
                case _ExerciseCardAction.elimina:
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ExerciseCardAction.modifica,
                child: Text(l10n.allenamentoModifica, style: TextStyle(color: p.textPrimary)),
              ),
              PopupMenuItem(
                value: _ExerciseCardAction.sostituisci,
                child: Text(l10n.allenamentoSostituisci, style: TextStyle(color: p.textPrimary)),
              ),
              PopupMenuItem(
                value: _ExerciseCardAction.elimina,
                child: Text(l10n.appElimina, style: TextStyle(color: p.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ExerciseCardAction { modifica, sostituisci, elimina }

class _DateNav extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final ColorPalette p;
  const _DateNav({required this.label, required this.onPrev, required this.onNext, required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: p.accent),
            onPressed: onPrev,
          ),
          Text(label,
              style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: onNext != null ? p.accent : p.textMuted),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
