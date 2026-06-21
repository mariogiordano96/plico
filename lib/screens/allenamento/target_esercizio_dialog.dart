import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_template_exercise.dart';

/// Dialog per impostare il target (serie/rip/peso o durata) di un esercizio
/// quando si costruisce una scheda. Ritorna il WorkoutTemplateExercise compilato.
Future<WorkoutTemplateExercise?> showTargetEsercizioDialog(
  BuildContext context,
  ExerciseDefinition exercise,
) {
  return showModalBottomSheet<WorkoutTemplateExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TargetEsercizioDialog(exercise: exercise),
  );
}

class _TargetEsercizioDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  const _TargetEsercizioDialog({required this.exercise});

  @override
  State<_TargetEsercizioDialog> createState() => _TargetEsercizioDialogState();
}

class _TargetEsercizioDialogState extends State<_TargetEsercizioDialog> {
  final _serieCtrl = TextEditingController(text: '3');
  final _ripCtrl = TextEditingController(text: '10');
  final _kgCtrl = TextEditingController();
  final _durataCtrl = TextEditingController(text: '30');

  bool get _isCardio => widget.exercise.category == 'cardio';

  @override
  void dispose() {
    _serieCtrl.dispose();
    _ripCtrl.dispose();
    _kgCtrl.dispose();
    _durataCtrl.dispose();
    super.dispose();
  }

  void _salva() {
    final result = WorkoutTemplateExercise()
      ..exerciseId = widget.exercise.externalId
      ..exerciseName = widget.exercise.nameIt ?? widget.exercise.name;

    if (_isCardio) {
      final min = int.tryParse(_durataCtrl.text);
      if (min == null || min <= 0) return;
      result.targetDurationSeconds = min * 60;
    } else {
      final serie = int.tryParse(_serieCtrl.text);
      if (serie == null || serie <= 0) return;
      result.targetSets = serie;
      result.targetReps = int.tryParse(_ripCtrl.text);
      result.targetWeightKg = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Padding(
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
              l10n.targetDialogTitle(widget.exercise.nameIt ?? widget.exercise.name),
              style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (_isCardio)
              _Field(label: l10n.targetDialogDurataMin, controller: _durataCtrl, p: p)
            else
              Row(
                children: [
                  Expanded(child: _Field(label: l10n.targetDialogSerie, controller: _serieCtrl, p: p)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: l10n.targetDialogRip, controller: _ripCtrl, p: p)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: l10n.targetDialogKg, controller: _kgCtrl, p: p)),
                ],
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
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ColorPalette p;
  const _Field({required this.label, required this.controller, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: p.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: p.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: p.cardBorder),
            ),
          ),
        ),
      ],
    );
  }
}
