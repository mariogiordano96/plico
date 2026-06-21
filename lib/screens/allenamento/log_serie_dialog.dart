import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';

/// Mostra il dialog di log serie per un esercizio di forza.
/// Ritorna il WorkoutExercise compilato, o null se annullato.
Future<WorkoutExercise?> showLogSerieDialog(
  BuildContext context,
  ExerciseDefinition exercise,
) {
  return showModalBottomSheet<WorkoutExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LogSerieDialog(exercise: exercise),
  );
}

class _LogSerieDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  const _LogSerieDialog({required this.exercise});

  @override
  State<_LogSerieDialog> createState() => _LogSerieDialogState();
}

class _LogSerieDialogState extends State<_LogSerieDialog> {
  final List<TextEditingController> _repsCtrls = [];
  final List<TextEditingController> _kgCtrls = [];

  @override
  void initState() {
    super.initState();
    _addSerie();
  }

  @override
  void dispose() {
    for (final c in _repsCtrls) {
      c.dispose();
    }
    for (final c in _kgCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSerie() {
    setState(() {
      _repsCtrls.add(TextEditingController());
      _kgCtrls.add(TextEditingController());
    });
  }

  void _removeSerie(int i) {
    setState(() {
      _repsCtrls.removeAt(i).dispose();
      _kgCtrls.removeAt(i).dispose();
    });
  }

  void _salva() {
    final sets = <WorkoutSet>[];
    for (var i = 0; i < _repsCtrls.length; i++) {
      final reps = int.tryParse(_repsCtrls[i].text);
      final kg = double.tryParse(_kgCtrls[i].text.replaceAll(',', '.'));
      if (reps == null && kg == null) continue;
      sets.add(WorkoutSet()
        ..reps = reps
        ..weightKg = kg);
    }
    if (sets.isEmpty) return;

    final result = WorkoutExercise()
      ..exerciseId = widget.exercise.externalId
      ..exerciseName = widget.exercise.nameIt ?? widget.exercise.name
      ..date = DateTime.now()
      ..sets = sets;
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
            for (var i = 0; i < _repsCtrls.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(l10n.serieDialogSerieLabel(i + 1),
                          style: TextStyle(color: p.textMuted, fontSize: 13)),
                    ),
                    Expanded(child: _NumberField(controller: _repsCtrls[i], hint: l10n.serieDialogRipHint, p: p)),
                    const SizedBox(width: 10),
                    Expanded(child: _NumberField(controller: _kgCtrls[i], hint: l10n.serieDialogKgHint, p: p)),
                    IconButton(
                      onPressed: _repsCtrls.length > 1 ? () => _removeSerie(i) : null,
                      icon: Icon(Icons.close_rounded, color: p.textMuted, size: 18),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: _addSerie,
              icon: Icon(Icons.add_rounded, color: p.accent, size: 18),
              label: Text(l10n.serieDialogAggiungiSerie, style: TextStyle(color: p.accent)),
            ),
            const SizedBox(height: 12),
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

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ColorPalette p;
  const _NumberField({required this.controller, required this.hint, required this.p});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: p.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textMuted),
        isDense: true,
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.cardBorder),
        ),
      ),
    );
  }
}
