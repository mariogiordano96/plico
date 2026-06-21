import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../services/workout_progress_service.dart';

/// Mostra il dialog di log serie per un esercizio di forza. Se [lastSession] è
/// disponibile, mostra il suggerimento di progressive overload (o di scarico, se
/// [suggestion] ha `isDeload = true`) e pre-compila la prima serie.
/// Ritorna il WorkoutExercise compilato, o null se annullato.
Future<WorkoutExercise?> showLogSerieDialog(
  BuildContext context,
  ExerciseDefinition exercise, {
  WorkoutExercise? lastSession,
  OverloadSuggestion? suggestion,
}) {
  return showModalBottomSheet<WorkoutExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LogSerieDialog(
      exercise: exercise,
      lastSession: lastSession,
      suggestion: suggestion,
    ),
  );
}

class _LogSerieDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  final WorkoutExercise? lastSession;
  final OverloadSuggestion? suggestion;
  const _LogSerieDialog({required this.exercise, this.lastSession, this.suggestion});

  @override
  State<_LogSerieDialog> createState() => _LogSerieDialogState();
}

class _LogSerieDialogState extends State<_LogSerieDialog> {
  final List<TextEditingController> _repsCtrls = [];
  final List<TextEditingController> _kgCtrls = [];
  final List<int?> _rpeValues = [];

  @override
  void initState() {
    super.initState();
    _addSerie();
    final s = widget.suggestion;
    if (s != null) {
      if (s.suggestedReps != null) _repsCtrls.first.text = s.suggestedReps.toString();
      if (s.suggestedWeightKg != null) _kgCtrls.first.text = s.suggestedWeightKg.toString();
    }
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
      _rpeValues.add(null);
    });
  }

  void _removeSerie(int i) {
    setState(() {
      _repsCtrls.removeAt(i).dispose();
      _kgCtrls.removeAt(i).dispose();
      _rpeValues.removeAt(i);
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
        ..weightKg = kg
        ..rpe = _rpeValues[i]);
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
            if (widget.lastSession != null || widget.suggestion != null) ...[
              const SizedBox(height: 10),
              _OverloadBanner(lastSession: widget.lastSession, suggestion: widget.suggestion, p: p),
            ],
            const SizedBox(height: 16),
            for (var i = 0; i < _repsCtrls.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: _RpeSelector(
                        value: _rpeValues[i],
                        p: p,
                        label: l10n.serieDialogRpeLabel,
                        onChanged: (v) => setState(() => _rpeValues[i] = v),
                      ),
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

class _OverloadBanner extends StatelessWidget {
  final WorkoutExercise? lastSession;
  final OverloadSuggestion? suggestion;
  final ColorPalette p;
  const _OverloadBanner({required this.lastSession, required this.suggestion, required this.p});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = <Widget>[];

    final last = lastSession;
    if (last != null && last.sets.isNotEmpty) {
      final detail = '${last.sets.length}×${last.sets.first.reps ?? '-'}'
          '${last.sets.first.weightKg != null ? '×${last.sets.first.weightKg}kg' : ''}';
      lines.add(Text(l10n.overloadUltimaVolta(detail),
          style: TextStyle(color: p.textMuted, fontSize: 12)));
    }

    final s = suggestion;
    if (s != null && s.suggestedWeightKg != null) {
      final kg = s.suggestedWeightKg!.toStringAsFixed(
          s.suggestedWeightKg! % 1 == 0 ? 0 : 1);
      String text;
      String icon;
      if (s.isDeload) {
        text = l10n.overloadDeload(4, kg);
        icon = '💡';
      } else {
        switch (s.direction) {
          case OverloadDirection.increase:
            text = l10n.overloadSuggeritoUp(kg);
            icon = '⬆️';
          case OverloadDirection.maintain:
            text = l10n.overloadSuggeritoSame(kg);
            icon = '➡️';
          case OverloadDirection.decrease:
            text = l10n.overloadSuggeritoDown(kg);
            icon = '⬇️';
        }
      }
      lines.add(const SizedBox(height: 2));
      lines.add(Text('$icon $text',
          style: TextStyle(color: p.accent, fontSize: 13, fontWeight: FontWeight.w600)));
    }

    if (lines.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines);
  }
}

class _RpeSelector extends StatelessWidget {
  final int? value;
  final String label;
  final ColorPalette p;
  final ValueChanged<int?> onChanged;

  const _RpeSelector({
    required this.value,
    required this.label,
    required this.p,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, idx) {
                final n = idx + 1;
                final selected = value == n;
                return GestureDetector(
                  onTap: () => onChanged(selected ? null : n),
                  child: Container(
                    width: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? p.accent : p.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selected ? p.accent : p.cardBorder),
                    ),
                    child: Text('$n',
                        style: TextStyle(
                            color: selected ? p.background : p.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          ),
        ],
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
