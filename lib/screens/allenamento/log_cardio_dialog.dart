import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';

/// Mostra il dialog di log durata per un esercizio cardio.
/// Ritorna il WorkoutExercise compilato, o null se annullato.
Future<WorkoutExercise?> showLogCardioDialog(
  BuildContext context,
  ExerciseDefinition exercise,
) {
  return showModalBottomSheet<WorkoutExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LogCardioDialog(exercise: exercise),
  );
}

class _LogCardioDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  const _LogCardioDialog({required this.exercise});

  @override
  State<_LogCardioDialog> createState() => _LogCardioDialogState();
}

class _LogCardioDialogState extends State<_LogCardioDialog> {
  final _durataCtrl = TextEditingController();

  @override
  void dispose() {
    _durataCtrl.dispose();
    super.dispose();
  }

  void _salva() {
    final minuti = int.tryParse(_durataCtrl.text);
    if (minuti == null || minuti <= 0) return;

    final result = WorkoutExercise()
      ..exerciseId = widget.exercise.externalId
      ..exerciseName = widget.exercise.nameIt ?? widget.exercise.name
      ..date = DateTime.now()
      ..durationSeconds = minuti * 60;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Text(
              widget.exercise.nameIt ?? widget.exercise.name,
              style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(l10n.cardioDialogDurataLabel,
                style: TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _durataCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: p.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.cardioDialogDurataHint,
                hintStyle: TextStyle(color: p.textMuted),
                filled: true,
                fillColor: p.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _salva,
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
    );
  }
}
