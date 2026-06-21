import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_exercise.dart';
import '../../services/database_service.dart';
import '../esercizi/catalogo_esercizi_screen.dart';
import 'log_cardio_dialog.dart';
import 'log_serie_dialog.dart';

class AllenamentoScreen extends StatefulWidget {
  const AllenamentoScreen({super.key});

  @override
  State<AllenamentoScreen> createState() => _AllenamentoScreenState();
}

class _AllenamentoScreenState extends State<AllenamentoScreen> {
  final _oggi = DateTime.now();

  Future<void> _aggiungiEsercizio() async {
    final exercise = await showCatalogoEserciziSheet(context);
    if (exercise == null || !mounted) return;

    final workoutExercise = exercise.category == 'cardio'
        ? await showLogCardioDialog(context, exercise)
        : await showLogSerieDialog(context, exercise);

    if (workoutExercise != null) {
      await DatabaseService.instance.addWorkoutExercise(_oggi, workoutExercise);
    }
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dataLabel = DateFormat('d MMMM', locale).format(_oggi);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text('${l10n.tabAllenamento} · $dataLabel',
            style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<WorkoutExercise>>(
        stream: DatabaseService.instance.watchWorkoutExercisesForDay(_oggi),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: p.accent));
          }
          final esercizi = snapshot.data!;
          if (esercizi.isEmpty) {
            return _EmptyState(onAdd: _aggiungiEsercizio);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: esercizi.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ExerciseCard(
              exercise: esercizi[i],
              p: p,
              l10n: l10n,
              onDelete: () => _elimina(esercizi[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _aggiungiEsercizio,
        backgroundColor: p.accent,
        foregroundColor: p.background,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.allenamentoAggiungiEsercizio,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

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

  const _ExerciseCard({
    required this.exercise,
    required this.p,
    required this.l10n,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCardio = exercise.durationSeconds != null;
    final sottotitolo = isCardio
        ? l10n.allenamentoDurataMin(exercise.durationSeconds! ~/ 60)
        : exercise.sets
            .map((s) => '${s.reps ?? '-'}×${s.weightKg != null ? '${s.weightKg}kg' : '-'}')
            .join(', ');

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
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: p.textMuted),
          ),
        ],
      ),
    );
  }
}
