import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_exercise.dart';
import '../../services/guided_session_service.dart';
import '../../services/workout_progress_service.dart';

/// Riepilogo di fine sessione guidata: kcal stimate e nuovi record personali.
/// Vedi docs/evolutiva_esercizi.md, sezione "Modalità esecuzione guidata".
class SessioneRiepilogoScreen extends StatelessWidget {
  final List<WorkoutExercise> exercises;
  final Map<String, List<WorkoutExercise>> priorHistoryByExerciseId;

  const SessioneRiepilogoScreen({
    super.key,
    required this.exercises,
    required this.priorHistoryByExerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final kcal = GuidedSessionService.totalEstimatedKcal(exercises);
    final prs = GuidedSessionService.newPersonalRecords(exercises, priorHistoryByExerciseId);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.sessioneRiepilogoTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.cardBorder),
            ),
            child: Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  l10n.sessioneRiepilogoKcal(kcal),
                  style: TextStyle(
                      color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.sessioneRiepilogoNuoviRecord,
              style: TextStyle(color: p.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (prs.isEmpty)
            Text(l10n.sessioneRiepilogoNessunRecord, style: TextStyle(color: p.textMuted))
          else
            for (final e in prs)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.sessioneRiepilogoRecordEsercizio(
                          e.exerciseName,
                          WorkoutProgressService.sessionMaxWeight(e)?.toStringAsFixed(
                                  (WorkoutProgressService.sessionMaxWeight(e)! % 1 == 0) ? 0 : 1) ??
                              '',
                        ),
                        style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: p.accent),
            child: Text(l10n.sessioneRiepilogoChiudi,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
