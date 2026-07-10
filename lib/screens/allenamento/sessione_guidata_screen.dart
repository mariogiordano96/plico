import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template.dart';
import '../../services/achievement_service.dart';
import '../../services/calorie_estimation_service.dart';
import '../../services/database_service.dart';
import '../../services/guided_session_service.dart';
import '../../services/workout_progress_service.dart';
import 'rest_timer_sheet.dart';
import 'sessione_riepilogo_screen.dart';
import 'sostituisci_esercizio_sheet.dart';

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
      // Gli esercizi passati qui possono arrivare da Isar (log già popolato,
      // "Avvia allenamento") invece che da un oggetto appena creato in memoria
      // (vecchio flusso "Inizia" da scheda): le liste embedded lette da Isar
      // sono a lunghezza fissa, insertAll/add sotto altrimenti lanciano
      // "Cannot add to a fixed-length list".
      e.sets = List.of(e.sets, growable: true);
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
      // Se la prima serie è già confermata (esercizio rivisto con "Avvia
      // allenamento" dopo essere stato davvero completato), non sovrascriverla
      // con un suggerimento/target: mostrerebbe uno spunta piena ma con un
      // valore diverso da quello confermato dall'utente.
      final firstConfirmed = e.sets.isNotEmpty && e.sets.first.confirmed;
      if (history.isNotEmpty) {
        final lastSession = history.first;
        final suggestion = WorkoutProgressService.needsDeload(history)
            ? WorkoutProgressService.deloadSuggestion(lastSession)
            : WorkoutProgressService.suggestNextSession(lastSession);
        _suggestionById[e.id] = suggestion;
        if (e.sets.isNotEmpty && !firstConfirmed) {
          if (suggestion.suggestedReps != null) e.sets.first.reps = suggestion.suggestedReps;
          if (suggestion.suggestedWeightKg != null) {
            e.sets.first.weightKg = suggestion.suggestedWeightKg;
          }
        }
      }

      final targetWeightKg = e.sets.isNotEmpty ? e.sets.first.weightKg : null;
      if (targetWeightKg != null && !firstConfirmed && !e.sets.any((s) => s.isWarmup)) {
        final warmup = WorkoutProgressService.suggestWarmupSets(targetWeightKg);
        if (warmup.isNotEmpty) e.sets.insertAll(0, warmup);
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

  /// Rimuove tutte le serie di riscaldamento suggerite per [e] (step
  /// preliminare saltabile, Fase 15): non persistito, dato che il
  /// riscaldamento non viene mai scritto su DB finché non si conferma
  /// almeno una serie.
  void _skipWarmup(WorkoutExercise e) {
    setState(() {
      final reps = _repsCtrls[e.id]!;
      final kg = _kgCtrls[e.id]!;
      final keptSets = <WorkoutSet>[];
      final keptReps = <TextEditingController>[];
      final keptKg = <TextEditingController>[];
      for (var i = 0; i < e.sets.length; i++) {
        if (e.sets[i].isWarmup) {
          reps[i].dispose();
          kg[i].dispose();
        } else {
          keptSets.add(e.sets[i]);
          keptReps.add(reps[i]);
          keptKg.add(kg[i]);
        }
      }
      e.sets = keptSets;
      _repsCtrls[e.id] = keptReps;
      _kgCtrls[e.id] = keptKg;
    });
  }

  /// All'interno di un blocco superset non si riposa tra un esercizio e il
  /// successivo: il timer scatta solo dopo l'ultimo esercizio del blocco
  /// (gli esercizi singoli, non in superset, mantengono il comportamento
  /// originale: riposo dopo ogni serie).
  bool _isLastInStep(WorkoutExercise e) {
    final step = _steps[_stepIndex];
    return step.length <= 1 || identical(step.last, e);
  }

  bool _isExerciseDone(WorkoutExercise e) =>
      e.sets.isEmpty ? e.cardioConfirmed : e.sets.every((s) => s.confirmed);

  bool get _isLastStep => _stepIndex >= _steps.length - 1;

  /// Vero solo quando tutti gli esercizi di tutta la scheda (non solo dello
  /// step corrente) sono stati confermati — condizione per mostrare
  /// "Termina sessione" come azione attiva sull'ultimo step.
  bool get _allExercisesDone => widget.exercises.every(_isExerciseDone);

  /// Vero quando la conferma appena fatta chiude l'intera sessione (ultimo
  /// step, tutto confermato): non ha senso far partire il timer di recupero
  /// se non c'è più nessun esercizio/serie successivo per cui riposare.
  bool get _sessionComplete => _isLastStep && _allExercisesDone;

  /// Avanza automaticamente allo step successivo quando tutti gli esercizi
  /// dello step corrente sono stati confermati. Sull'ultimo step non fa
  /// nulla: la fine sessione resta un'azione esplicita (pulsante "Termina
  /// sessione", già mostrato da `_next`/`build` quando non ci sono più step).
  void _maybeAdvanceStep() {
    if (!mounted) return;
    if (_stepIndex >= _steps.length - 1) return;
    if (_steps[_stepIndex].every(_isExerciseDone)) {
      setState(() => _stepIndex++);
    }
  }

  Future<void> _confirmSerie(WorkoutExercise e, int setIndex) async {
    final reps = int.tryParse(_repsCtrls[e.id]![setIndex].text);
    final kg = double.tryParse(_kgCtrls[e.id]![setIndex].text.replaceAll(',', '.'));
    e.sets[setIndex]
      ..reps = reps
      ..weightKg = kg
      ..confirmed = true;
    e.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
      workingSetCount: e.sets.where((s) => !s.isWarmup).length,
      bodyWeightKg: _bodyWeightKg,
    );
    await DatabaseService.instance.updateWorkoutExercise(e);
    if (!mounted) return;
    setState(() {});
    if (_isLastInStep(e) && !_sessionComplete) {
      await showRestTimerSheet(context, seconds: e.restSeconds ?? _defaultRestSeconds);
    }
    _maybeAdvanceStep();
  }

  Future<void> _confirmCardio(WorkoutExercise e) async {
    final minuti = int.tryParse(_durataCtrls[e.id]!.text);
    if (minuti == null || minuti <= 0) return;
    e.durationSeconds = minuti * 60;
    e.cardioConfirmed = true;
    e.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
      exerciseId: e.exerciseId,
      durationSeconds: e.durationSeconds!,
      bodyWeightKg: _bodyWeightKg,
    );
    await DatabaseService.instance.updateWorkoutExercise(e);
    if (!mounted) return;
    setState(() {});
    if ((e.restSeconds ?? 0) > 0 && _isLastInStep(e) && !_sessionComplete) {
      await showRestTimerSheet(context, seconds: e.restSeconds!);
    }
    _maybeAdvanceStep();
  }

  Future<void> _sostituisci(WorkoutExercise e) async {
    final alt = await showSostituisciEsercizioSheet(context, e.exerciseId);
    if (alt == null || !mounted) return;

    e.exerciseId = alt.externalId;
    e.exerciseName = alt.nameIt ?? alt.name;

    if (e.durationSeconds != null) {
      e.met = CalorieEstimationService.metForCardioExercise(e.exerciseId).round();
      e.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
        exerciseId: e.exerciseId,
        durationSeconds: e.durationSeconds!,
        bodyWeightKg: _bodyWeightKg,
      );
      await DatabaseService.instance.updateWorkoutExercise(e);
      if (!mounted) return;
      setState(() {});
      return;
    }

    final history = (await DatabaseService.instance.getHistoryForExercise(e.exerciseId))
        .where((h) => h.id != e.id)
        .toList();
    _priorHistoryByExerciseId[e.exerciseId] = history;
    OverloadSuggestion? suggestion;
    if (history.isNotEmpty) {
      final lastSession = history.first;
      suggestion = WorkoutProgressService.needsDeload(history)
          ? WorkoutProgressService.deloadSuggestion(lastSession)
          : WorkoutProgressService.suggestNextSession(lastSession);
    }

    e.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
      workingSetCount: e.sets.where((s) => !s.isWarmup).length,
      bodyWeightKg: _bodyWeightKg,
    );
    await DatabaseService.instance.updateWorkoutExercise(e);
    if (!mounted) return;
    setState(() => _suggestionById[e.id] = suggestion);
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

  Future<void> _termina() async {
    final prs =
        GuidedSessionService.newPersonalRecords(widget.exercises, _priorHistoryByExerciseId);
    await AchievementService.instance.checkAll(hasNewWorkoutPr: prs.isNotEmpty);
    if (!mounted) return;
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
          if (step.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: p.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(l10n.sessioneGuidataSuperset,
                      style: TextStyle(
                          color: p.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ],
              ),
            ),
          for (final e in step) _ExerciseStepCard(
            exercise: e,
            suggestion: _suggestionById[e.id],
            repsCtrls: _repsCtrls[e.id],
            kgCtrls: _kgCtrls[e.id],
            durataCtrl: _durataCtrls[e.id],
            onAddSerie: () => _addSerie(e),
            onConfirmSerie: (i) => _confirmSerie(e, i),
            onConfirmCardio: () => _confirmCardio(e),
            onSostituisci: () => _sostituisci(e),
            onSkipWarmup: () => _skipWarmup(e),
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
                child: _isLastStep && !_allExercisesDone
                    ? FilledButton(
                        onPressed: null,
                        style: FilledButton.styleFrom(
                            backgroundColor: p.cardBorder, disabledBackgroundColor: p.cardBorder),
                        child: Text(l10n.sessioneGuidataCompletaTutto,
                            style: TextStyle(color: p.textMuted, fontWeight: FontWeight.w700)),
                      )
                    : FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(backgroundColor: p.accent),
                        child: Text(
                          _isLastStep ? l10n.sessioneGuidataTermina : l10n.sessioneGuidataSuccessivo,
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
  final VoidCallback onSostituisci;
  final VoidCallback onSkipWarmup;
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
    required this.onSostituisci,
    required this.onSkipWarmup,
    required this.p,
    required this.l10n,
  });

  bool get _isCardio => durataCtrl != null;

  List<int> get _warmupIndices => [
        for (var i = 0; i < exercise.sets.length; i++)
          if (exercise.sets[i].isWarmup) i
      ];

  List<int> get _workIndices => [
        for (var i = 0; i < exercise.sets.length; i++)
          if (!exercise.sets[i].isWarmup) i
      ];

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
          Row(
            children: [
              Expanded(
                child: Text(exercise.exerciseName,
                    style: TextStyle(
                        color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                onPressed: onSostituisci,
                icon: Icon(Icons.swap_horiz_rounded, color: p.textMuted),
                tooltip: l10n.allenamentoSostituisci,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
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
                  icon: Icon(
                    exercise.cardioConfirmed
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: exercise.cardioConfirmed ? p.accent : p.textMuted,
                  ),
                  tooltip: l10n.sessioneGuidataConferma,
                ),
              ],
            )
          else ...[
            if (_warmupIndices.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.whatshot_rounded, color: p.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(l10n.sessioneGuidataRiscaldamento,
                      style: TextStyle(
                          color: p.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const Spacer(),
                  TextButton(
                    onPressed: onSkipWarmup,
                    child: Text(l10n.sessioneGuidataSaltaRiscaldamento,
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                  ),
                ],
              ),
              for (var w = 0; w < _warmupIndices.length; w++)
                _SetRow(
                  label: l10n.sessioneGuidataRiscaldamentoSerieLabel(w + 1),
                  reps: repsCtrls![_warmupIndices[w]],
                  kg: kgCtrls![_warmupIndices[w]],
                  done: exercise.sets[_warmupIndices[w]].confirmed,
                  onConfirm: () => onConfirmSerie(_warmupIndices[w]),
                  p: p,
                ),
              const SizedBox(height: 4),
              Divider(color: p.cardBorder),
              const SizedBox(height: 4),
            ],
            for (var i = 0; i < _workIndices.length; i++)
              _SetRow(
                label: l10n.serieDialogSerieLabel(i + 1),
                reps: repsCtrls![_workIndices[i]],
                kg: kgCtrls![_workIndices[i]],
                done: exercise.sets[_workIndices[i]].confirmed,
                onConfirm: () => onConfirmSerie(_workIndices[i]),
                p: p,
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

class _SetRow extends StatelessWidget {
  final String label;
  final TextEditingController reps;
  final TextEditingController kg;
  final bool done;
  final VoidCallback onConfirm;
  final ColorPalette p;

  const _SetRow({
    required this.label,
    required this.reps,
    required this.kg,
    required this.done,
    required this.onConfirm,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: TextStyle(color: p.textMuted, fontSize: 12)),
          ),
          Expanded(child: _NumberField(controller: reps, hint: l10n.serieDialogRipHint, p: p)),
          const SizedBox(width: 8),
          Expanded(child: _NumberField(controller: kg, hint: l10n.serieDialogKgHint, p: p)),
          IconButton(
            onPressed: onConfirm,
            icon: Icon(
              done ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              color: done ? p.accent : p.textMuted,
            ),
            tooltip: l10n.sessioneGuidataConferma,
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
