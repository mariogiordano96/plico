import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import 'tracking_mode_switch.dart';

/// Mostra il dialog di log durata per un esercizio cardio.
/// Se [initial] è fornito (Fase 14, modifica di un esercizio già loggato), il
/// dialog pre-compila la durata esistente e ritorna la stessa istanza
/// aggiornata (stesso `Id`) invece di crearne una nuova.
/// Ritorna il WorkoutExercise compilato, `switchTrackingModeSignal` se
/// l'utente ha chiesto di passare al log a serie/ripetizioni, o null se
/// annullato.
Future<Object?> showLogCardioDialog(
  BuildContext context,
  ExerciseDefinition exercise, {
  WorkoutExercise? initial,
}) {
  return showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LogCardioDialog(exercise: exercise, initial: initial),
  );
}

class _LogCardioDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  final WorkoutExercise? initial;
  const _LogCardioDialog({required this.exercise, this.initial});

  @override
  State<_LogCardioDialog> createState() => _LogCardioDialogState();
}

class _LogCardioDialogState extends State<_LogCardioDialog> {
  late final TextEditingController _durataCtrl;

  @override
  void initState() {
    super.initState();
    final minutes = widget.initial?.durationSeconds != null
        ? (widget.initial!.durationSeconds! ~/ 60).toString()
        : '';
    _durataCtrl = TextEditingController(text: minutes);
  }

  @override
  void dispose() {
    _durataCtrl.dispose();
    super.dispose();
  }

  void _salva() {
    final minuti = int.tryParse(_durataCtrl.text);
    if (minuti == null || minuti <= 0) return;

    final result = widget.initial ??
        (WorkoutExercise()
          ..exerciseId = widget.exercise.externalId
          ..exerciseName = widget.exercise.nameIt ?? widget.exercise.name
          ..date = DateTime.now());
    result.durationSeconds = minuti * 60;
    // Un esercizio non deve mai avere sia sets che durationSeconds
    // valorizzati: se `initial` arrivava da un cambio di modalità o da uno
    // stato inconsistente pregresso, questo salvataggio lo corregge.
    result.sets = [];
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.nameIt ?? widget.exercise.name,
                    style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, switchTrackingModeSignal),
                  child: Text(l10n.logDialogTracciaASerie,
                      style: TextStyle(color: p.textMuted, fontSize: 12)),
                ),
              ],
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
      ),
    );
  }
}
