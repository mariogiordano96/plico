import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template.dart';
import '../../services/calorie_estimation_service.dart';
import '../../services/database_service.dart';
import '../../services/guided_session_service.dart';
import '../../services/workout_progress_service.dart';
import 'rest_timer_sheet.dart';
import 'sessione_riepilogo_screen.dart';

/// Modalità esecuzione guidata: schermo singolo che guida l'esecuzione di una
/// scheda esercizio per esercizio, con timer di recupero automatico tra le serie.
/// Vedi docs/evolutiva_esercizi.md, sezione "Modalità esecuzione guidata".
class SessioneGuidataScreen extends StatefulWidget {
  final WorkoutTemplate template;
  final List<WorkoutExercise> exercises;

  const SessioneGuidataScreen({
    super.key,
    required this.template,
    required this.exercises,
  });

  @override
  State<SessioneGuidataScreen> createState() => _SessioneGuidataScreenState();
}

class _SessioneGuidataScreenState extends State<SessioneGuidataScreen> {
  bool _loading = true;
  List<List<WorkoutExercise>> _steps = [];
  int _stepIndex = 0;
  int _defaultRestSeconds = 90;
  double? _bodyWeightKg;

  final Map<int, OverloadSuggestion?> _suggestionById = {};
  final Map<int, List<TextEditingController>> _repsCtrls = {};
  final Map<int, List<TextEditingController>> _kgCtrls = {};
  final Map<int, TextEditingController> _durataCtrls = {};
  final Map<String, List<WorkoutExercise>> _priorHistoryByExerciseId = {};

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    for (final c in _repsCtrls.values.expand((l) => l)) {
      c.dispose();
    }
    for (final c in _kgCtrls.values.expand((l) => l)) {
      c.dispose();
    }
    for (final c in _durataCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _prepare() async {
    final db = DatabaseService.instance;
    final settings = await db.getAppSettings();
    final bodySnapshot = await db.getLatestBodySnapshot();

    for (final e in widget.exercises) {
      final isCardio = e.sets.isEmpty;
      if (isCardio) {
        _durataCtrls[e.id] = TextEditingController(
          text: e.durationSeconds != null ? (e.durationSeconds! ~/ 60).toString() : '',
        );
        continue;
      }

      // Esclude la sessione corrente (già persistita da startWorkoutFromTemplate)
      // dallo storico, altrimenti il suggerimento si baserebbe sui valori appena
      // creati invece che sull'ultima sessione realmente svolta.
      final history =
          (await db.getHistoryForExercise(e.exerciseId)).where((h) => h.id != e.id).toList();
      _priorHistoryByExerciseId[e.exerciseId] = history;
      if (history.isNotEmpty) {
        final lastSession = history.first;
        final suggestion = WorkoutProgressService.needsDeload(history)
            ? WorkoutProgressService.deloadSuggestion(lastSession)
            : WorkoutProgressService.suggestNextSession(lastSession);
        _suggestionById[e.id] = suggestion;
        if (e.sets.isNotEmpty) {
          if (suggestion.suggestedReps != null) e.sets.first.reps = suggestion.suggestedReps;
          if (suggestion.suggestedWeightKg != null) {
            e.sets.first.weightKg = suggestion.suggestedWeightKg;
          }
        }
      }

      _repsCtrls[e.id] = [
        for (final s in e.sets) TextEditingController(text: s.reps?.toString() ?? '')
      ];
      _kgCtrls[e.id] = [
        for (final s in e.sets) TextEditingController(text: s.weightKg?.toString() ?? '')
      ];
    }

    if (!mounted) return;
    setState(() {
      _defaultRestSeconds = settings.restTimerDefaultSeconds;
      _bodyWeightKg = bodySnapshot?.pesoKg;
      _steps = GuidedSessionService.groupSteps(widget.exercises);
      _loading = false;
    });
  }

  void _addSerie(WorkoutExercise e) {
    setState(() {
      e.sets.add(WorkoutSet());
      _repsCtrls[e.id]!.add(TextEditingController());
      _kgCtrls[e.id]!.add(TextEditingController());
    });
  }

  Future<void> _confirmSerie(WorkoutExercise e, int setIndex) async {
    final reps = int.tryParse(_repsCtrls[e.id]![setIndex].text);
    final kg = double.tryParse(_kgCtrls[e.id]![setIndex].text.replaceAll(',', '.'));
    e.sets[setIndex]
      ..reps = reps
      ..weightKg = kg;
    e.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
      workingSetCount: e.sets.where((s) => !s.isWarmup).length,
      bodyWeightKg: _bodyWeightKg,
    );
    await DatabaseService.instance.updateWorkoutExercise(e);
    if (!mounted) return;
    setState(() {});
    await showRestTimerSheet(context, seconds: e.restSeconds ?? _defaultRestSeconds);
  }

  Future<void> _confirmCardio(WorkoutExercise e) async {
    final minuti = int.tryParse(_durataCtrls[e.id]!.text);
    if (minuti == null || minuti <= 0) return;
    e.durationSeconds = minuti * 60;
    e.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
      exerciseId: e.exerciseId,
      durationSeconds: e.durationSeconds!,
      bodyWeightKg: _bodyWeightKg,
    );
    await DatabaseService.instance.updateWorkoutExercise(e);
    if (!mounted) return;
    setState(() {});
    if ((e.restSeconds ?? 0) > 0) {
      await showRestTimerSheet(context, seconds: e.restSeconds!);
    }
  }

  void _prev() {
    if (_stepIndex > 0) setState(() => _stepIndex--);
  }

  void _next() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
    } else {
      _termina();
    }
  }

  void _termina() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessioneRiepilogoScreen(
          exercises: widget.exercises,
          priorHistoryByExerciseId: _priorHistoryByExerciseId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    if (_loading) {
      return Scaffold(
        backgroundColor: p.background,
        body: Center(child: CircularProgressIndicator(color: p.accent)),
      );
    }

    final step = _steps[_stepIndex];

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          '${widget.template.name} · ${l10n.sessioneGuidataProgress(_stepIndex + 1, _steps.length)}',
          style: TextStyle(color: p.accent, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          for (final e in step) _ExerciseStepCard(
            exercise: e,
            suggestion: _suggestionById[e.id],
            repsCtrls: _repsCtrls[e.id],
            kgCtrls: _kgCtrls[e.id],
            durataCtrl: _durataCtrls[e.id],
            onAddSerie: () => _addSerie(e),
            onConfirmSerie: (i) => _confirmSerie(e, i),
            onConfirmCardio: () => _confirmCardio(e),
            p: p,
            l10n: l10n,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _stepIndex > 0 ? _prev : null,
                  style: OutlinedButton.styleFrom(side: BorderSide(color: p.cardBorder)),
                  child: Text(l10n.sessioneGuidataPrecedente, style: TextStyle(color: p.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: p.accent),
                  child: Text(
                    _stepIndex < _steps.length - 1
                        ? l10n.sessioneGuidataSuccessivo
                        : l10n.sessioneGuidataTermina,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseStepCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final OverloadSuggestion? suggestion;
  final List<TextEditingController>? repsCtrls;
  final List<TextEditingController>? kgCtrls;
  final TextEditingController? durataCtrl;
  final VoidCallback onAddSerie;
  final void Function(int setIndex) onConfirmSerie;
  final VoidCallback onConfirmCardio;
  final ColorPalette p;
  final dynamic l10n;

  const _ExerciseStepCard({
    required this.exercise,
    required this.suggestion,
    required this.repsCtrls,
    required this.kgCtrls,
    required this.durataCtrl,
    required this.onAddSerie,
    required this.onConfirmSerie,
    required this.onConfirmCardio,
    required this.p,
    required this.l10n,
  });

  bool get _isCardio => durataCtrl != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.exerciseName,
              style: TextStyle(color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          if (suggestion != null) ...[
            const SizedBox(height: 6),
            _SuggestionLine(suggestion: suggestion!, p: p, l10n: l10n),
          ],
          const SizedBox(height: 14),
          if (_isCardio)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durataCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: p.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.cardioDialogDurataLabel,
                      hintStyle: TextStyle(color: p.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: p.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: p.cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onConfirmCardio,
                  icon: Icon(Icons.check_circle_rounded,
                      color: exercise.durationSeconds != null ? p.accent : p.textMuted),
                  tooltip: l10n.sessioneGuidataConferma,
                ),
              ],
            )
          else ...[
            for (var i = 0; i < (repsCtrls?.length ?? 0); i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(l10n.serieDialogSerieLabel(i + 1),
                          style: TextStyle(color: p.textMuted, fontSize: 12)),
                    ),
                    Expanded(
                      child: _NumberField(
                        controller: repsCtrls![i],
                        hint: l10n.serieDialogRipHint,
                        p: p,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        controller: kgCtrls![i],
                        hint: l10n.serieDialogKgHint,
                        p: p,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onConfirmSerie(i),
                      icon: Icon(
                        Icons.check_circle_rounded,
                        color: exercise.sets[i].reps != null ? p.accent : p.textMuted,
                      ),
                      tooltip: l10n.sessioneGuidataConferma,
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              onPressed: onAddSerie,
              icon: Icon(Icons.add_rounded, color: p.accent, size: 18),
              label: Text(l10n.serieDialogAggiungiSerie, style: TextStyle(color: p.accent)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionLine extends StatelessWidget {
  final OverloadSuggestion suggestion;
  final ColorPalette p;
  final dynamic l10n;
  const _SuggestionLine({required this.suggestion, required this.p, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final kg = suggestion.suggestedWeightKg;
    if (kg == null) return const SizedBox.shrink();
    final kgLabel = kg.toStringAsFixed(kg % 1 == 0 ? 0 : 1);
    String text;
    String icon;
    if (suggestion.isDeload) {
      text = l10n.overloadDeload(4, kgLabel);
      icon = '💡';
    } else {
      switch (suggestion.direction) {
        case OverloadDirection.increase:
          text = l10n.overloadSuggeritoUp(kgLabel);
          icon = '⬆️';
        case OverloadDirection.maintain:
          text = l10n.overloadSuggeritoSame(kgLabel);
          icon = '➡️';
        case OverloadDirection.decrease:
          text = l10n.overloadSuggeritoDown(kgLabel);
          icon = '⬇️';
      }
    }
    return Text('$icon $text',
        style: TextStyle(color: p.accent, fontSize: 13, fontWeight: FontWeight.w600));
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
        fillColor: p.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.cardBorder),
        ),
      ),
    );
  }
}
