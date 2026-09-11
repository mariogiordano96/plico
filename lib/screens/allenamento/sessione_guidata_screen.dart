import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template.dart';
import '../../services/achievement_service.dart';
import '../../services/calorie_estimation_service.dart';
import '../../services/database_service.dart';
import '../../services/guided_session_service.dart';
import '../../services/notification_service.dart';
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

  // Fase 30: timer incrementale della sessione, parte subito all'apertura
  // (anche durante il caricamento) — la durata viene salvata sul WorkoutLog
  // del giorno sia a fine sessione (_termina) sia, come fallback, se si esce
  // prima (dispose), per non perdere il tempo di una sessione abbandonata.
  final Stopwatch _stopwatch = Stopwatch()..start();
  Timer? _tickTimer;
  bool _durationSaved = false;
  int _tickCount = 0;

  // Tempo già trascorso in un tentativo precedente di questa stessa sessione,
  // interrotto (es. app chiusa) prima di "Termina sessione": letto da
  // `pendingSessionSeconds` in `_prepare` e usato come base per non far
  // ripartire il timer da zero al resume.
  int _baseElapsedSeconds = 0;

  DateTime get _sessionDate =>
      widget.exercises.isNotEmpty ? widget.exercises.first.date : DateTime.now();

  int get _totalElapsedSeconds => _baseElapsedSeconds + _stopwatch.elapsed.inSeconds;

  String get _elapsedLabel {
    final s = _totalElapsedSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  /// Salva un checkpoint intermedio del tempo trascorso (ogni 10s di tick,
  /// vedi `initState`), così se l'app viene chiusa senza passare da
  /// "Termina sessione" il resume riparte da qui invece che da zero.
  Future<void> _checkpointElapsed() async {
    if (_durationSaved) return;
    await DatabaseService.instance.saveSessionCheckpoint(_sessionDate, _totalElapsedSeconds);
  }

  Future<void> _persistElapsedDuration() async {
    if (_durationSaved) return;
    _durationSaved = true;
    _stopwatch.stop();
    await DatabaseService.instance.addSessionDuration(_sessionDate, _totalElapsedSeconds);
  }

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      _tickCount++;
      if (_tickCount >= 10) {
        _tickCount = 0;
        unawaited(_checkpointElapsed());
      }
    });
    _prepare();
    // Il timer di recupero deve poter suonare anche in background, a
    // prescindere dal toggle "Promemoria pasti" nelle impostazioni.
    unawaited(NotificationService.instance.ensureRestTimerPermission());
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    // Fire-and-forget: se l'utente esce senza premere "Termina sessione"
    // (es. back button), salva comunque il tempo trascorso finora.
    unawaited(_persistElapsedDuration());
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
    // Se una sessione precedente lo stesso giorno è stata interrotta prima di
    // "Termina sessione" (es. app chiusa per sbaglio), riparte da qui invece
    // che da zero. Fatto prima possibile, prima degli altri await più lenti,
    // per minimizzare il tempo in cui il timer mostra ancora 0:00.
    final pending = await db.getPendingSessionSeconds(_sessionDate);
    if (mounted) setState(() => _baseElapsedSeconds = pending);
    final settings = await db.getAppSettings();
    final bodySnapshot = await db.getLatestBodySnapshot();

    for (final e in widget.exercises) {
      // Gli esercizi passati qui possono arrivare da Isar (log già popolato,
      // "Avvia allenamento") invece che da un oggetto appena creato in memoria
      // (vecchio flusso "Inizia" da scheda): le liste embedded lette da Isar
      // sono a lunghezza fissa, insertAll/add sotto altrimenti lanciano
      // "Cannot add to a fixed-length list".
      e.sets = List.of(e.sets, growable: true);
      final isCardio = e.isCardio;
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
    final steps = GuidedSessionService.groupSteps(widget.exercises);
    // Riaprendo una sessione parzialmente (o del tutto) già confermata —
    // "Avvia allenamento" può ripartire da esercizi già fatti in una sessione
    // precedente lo stesso giorno — si parte dal primo step non ancora
    // completo invece che sempre dal primo: altrimenti si dovrebbe scorrere
    // a mano gli step già fatti, e ritoccare una spunta già confermata
    // farebbe ripartire il timer di recupero senza motivo (vedi
    // `_sessionComplete`, valido solo sull'ultimo step "vero").
    final firstPending = steps.indexWhere((step) => !step.every(_isExerciseDone));
    setState(() {
      _defaultRestSeconds = settings.restTimerDefaultSeconds;
      _bodyWeightKg = bodySnapshot?.pesoKg;
      _steps = steps;
      _stepIndex = firstPending == -1 ? (steps.isEmpty ? 0 : steps.length - 1) : firstPending;
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
  /// successivo, ma il timer scatta a fine di ogni round (dopo l'ultimo
  /// esercizio rimasto attivo in quel giro, non solo all'ultimissimo round);
  /// gli esercizi singoli, non in superset, mantengono il comportamento
  /// originale: riposo dopo ogni serie. Vedi `GuidedSessionService.isEndOfRound`.
  bool _isLastInStep(WorkoutExercise e) =>
      GuidedSessionService.isEndOfRound(e, _steps[_stepIndex]);

  bool _isExerciseDone(WorkoutExercise e) =>
      e.isCardio ? e.cardioConfirmed : e.sets.every((s) => s.confirmed);

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
    unawaited(_checkpointElapsed());
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
    unawaited(_checkpointElapsed());
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
    e.exerciseName = alt.localizedName(Localizations.localeOf(context).languageCode);

    if (e.isCardio) {
      // durationSeconds può essere ancora null se non è mai stato compilato:
      // niente da stimare finché non c'è un valore.
      if (e.durationSeconds != null) {
        e.met = CalorieEstimationService.metForCardioExercise(e.exerciseId).round();
        e.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
          exerciseId: e.exerciseId,
          durationSeconds: e.durationSeconds!,
          bodyWeightKg: _bodyWeightKg,
        );
      }
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
    final elapsedSeconds = _totalElapsedSeconds;
    await _persistElapsedDuration();
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
          durationSeconds: elapsedSeconds,
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: p.accent),
              const SizedBox(height: 12),
              Text(_elapsedLabel, style: TextStyle(color: p.textMuted)),
            ],
          ),
        ),
      );
    }

    final step = _steps[_stepIndex];
    // Solo nei blocchi superset (più di un esercizio) si applica l'alternanza
    // a turni: negli step a esercizio singolo nessuna restrizione, come oggi.
    final turn = step.length > 1 ? GuidedSessionService.turnFor(step) : null;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, color: p.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(_elapsedLabel,
                      style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
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
            locked: step.length > 1 && !identical(e, turn),
            highlighted: step.length > 1 && identical(e, turn),
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
  /// Vero se questo esercizio fa parte di un blocco superset e non è il suo
  /// turno: le conferme sono disabilitate finché non tocca a lui.
  final bool locked;
  /// Vero se questo esercizio fa parte di un blocco superset ed è il suo
  /// turno: solo la sua serie corrente è confermabile, evidenziata nel bordo.
  final bool highlighted;
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
    required this.locked,
    required this.highlighted,
    required this.p,
    required this.l10n,
  });

  bool get _isCardio => durataCtrl != null;

  // Ricerca YouTube dell'esecuzione dell'esercizio, localizzata: hl/gl
  // orientano i risultati verso YouTube Italia o l'equivalente inglese in
  // base alla lingua dell'app, senza dipendere da una regione fissa.
  Future<void> _openYoutubeSearch(BuildContext context) async {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final query = isItalian
        ? '${exercise.exerciseName} esecuzione corretta'
        : '${exercise.exerciseName} exercise tutorial';
    final uri = Uri.https('www.youtube.com', '/results', {
      'search_query': query,
      'hl': isItalian ? 'it' : 'en',
      'gl': isItalian ? 'IT' : 'US',
    });
    bool ok;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.allenamentoYoutubeErrore)),
      );
    }
  }

  List<int> get _warmupIndices => [
        for (var i = 0; i < exercise.sets.length; i++)
          if (exercise.sets[i].isWarmup) i
      ];

  List<int> get _workIndices => [
        for (var i = 0; i < exercise.sets.length; i++)
          if (!exercise.sets[i].isWarmup) i
      ];

  /// Indice piatto (include riscaldamento) della prossima serie da
  /// confermare per questo esercizio — è l'unica abilitata quando la card è
  /// `highlighted` all'interno di un blocco superset a turni.
  int get _activeSetIndex => exercise.sets.indexWhere((s) => !s.confirmed);

  bool _setEnabled(int flatIndex) => !locked && (!highlighted || flatIndex == _activeSetIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlighted ? p.accent : p.cardBorder, width: highlighted ? 1.5 : 1),
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
                onPressed: () => _openYoutubeSearch(context),
                icon: Icon(Icons.smart_display_rounded, color: p.textMuted),
                tooltip: l10n.allenamentoCercaSuYoutube,
                visualDensity: VisualDensity.compact,
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
                  onPressed: locked ? null : onConfirmCardio,
                  icon: Icon(
                    locked
                        ? Icons.lock_outline_rounded
                        : exercise.cardioConfirmed
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                    color: exercise.cardioConfirmed ? p.accent : p.textMuted,
                  ),
                  tooltip: locked ? l10n.sessioneGuidataAspettaTurno : l10n.sessioneGuidataConferma,
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
                  enabled: _setEnabled(_warmupIndices[w]),
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
                enabled: _setEnabled(_workIndices[i]),
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
  final bool enabled;
  final VoidCallback onConfirm;
  final ColorPalette p;

  const _SetRow({
    required this.label,
    required this.reps,
    required this.kg,
    required this.done,
    required this.enabled,
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
            onPressed: enabled ? onConfirm : null,
            icon: Icon(
              !enabled && !done
                  ? Icons.lock_outline_rounded
                  : done
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
              color: done ? p.accent : p.textMuted,
            ),
            tooltip: !enabled && !done ? l10n.sessioneGuidataAspettaTurno : l10n.sessioneGuidataConferma,
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
