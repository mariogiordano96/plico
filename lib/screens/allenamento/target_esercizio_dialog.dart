import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template_exercise.dart';
import 'genera_piramide_dialog.dart';
import 'widgets/technique_widgets.dart';

/// Dialog per impostare il target (serie/rip/peso o durata) di un esercizio,
/// sia quando si costruisce una scheda sia quando si aggiunge/modifica un
/// esercizio libero nel log del giorno. Se [initial] è fornito, precompila i
/// campi con i suoi valori (modifica) invece dei default (3 serie × 10 rip).
/// Ritorna il WorkoutTemplateExercise compilato.
///
/// Fase 7 (docs/tecniche_allenamento.md): oltre al target uniforme, permette
/// di pianificare "Serie personalizzate" — reps/peso e tecnica (rest-pause,
/// stripping, forzate, super slow, piramide) decisi già in creazione scheda
/// invece che il giorno stesso in sessione guidata (`WorkoutTemplateExercise.
/// plannedSets`, riproposto via `materializeSets()`).
Future<WorkoutTemplateExercise?> showTargetEsercizioDialog(
  BuildContext context,
  ExerciseDefinition exercise, {
  WorkoutExercise? initial,
}) {
  return showModalBottomSheet<WorkoutTemplateExercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Senza un tetto esplicito, `isScrollControlled` lascia che il foglio
    // cresca oltre l'altezza schermo con molte "serie personalizzate" (Fase
    // 7) e finisca sotto la status bar/notch — stesso fix di
    // genera_piramide_dialog.dart. Il contenuto resta scrollabile
    // internamente (SingleChildScrollView sotto).
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    builder: (_) => _TargetEsercizioDialog(exercise: exercise, initial: initial),
  );
}

/// Stato di editing di una singola serie pianificata — stessi campi tecnica
/// di WorkoutSet/WorkoutTemplateSet, costruiti da entrambe le sorgenti
/// possibili di precompilazione (modifica di un esercizio già materializzato,
/// o "Genera piramide"), scritti sull'uno o sull'altro modello solo al
/// salvataggio (`toTemplateSet`), stesso principio di `_SetRow` in
/// sessione_guidata_screen.dart.
class _PlannedSetState {
  final TextEditingController repsCtrl;
  final TextEditingController kgCtrl;
  SetTechnique technique;
  final TextEditingController forcedCtrl;
  final List<TextEditingController> clusterCtrls = [];
  final List<(TextEditingController, TextEditingController)> stageCtrls = [];

  _PlannedSetState({
    int? reps,
    double? weightKg,
    this.technique = SetTechnique.normale,
    int? forcedReps,
    List<int>? restPauseClusters,
    List<DropStage>? dropStages,
  })  : repsCtrl = TextEditingController(text: reps?.toString() ?? ''),
        kgCtrl = TextEditingController(text: weightKg?.toString() ?? ''),
        forcedCtrl = TextEditingController(text: forcedReps?.toString() ?? '') {
    if (restPauseClusters != null && restPauseClusters.length > 1) {
      for (final v in restPauseClusters.skip(1)) {
        clusterCtrls.add(TextEditingController(text: v.toString()));
      }
    }
    if (dropStages != null) {
      for (final d in dropStages) {
        stageCtrls.add((
          TextEditingController(text: d.reps?.toString() ?? ''),
          TextEditingController(text: d.weightKg?.toString() ?? ''),
        ));
      }
    }
  }

  void dispose() {
    repsCtrl.dispose();
    kgCtrl.dispose();
    forcedCtrl.dispose();
    for (final c in clusterCtrls) {
      c.dispose();
    }
    for (final (r, k) in stageCtrls) {
      r.dispose();
      k.dispose();
    }
  }

  WorkoutTemplateSet toTemplateSet() {
    final ts = WorkoutTemplateSet()
      ..reps = int.tryParse(repsCtrl.text)
      ..weightKg = double.tryParse(kgCtrl.text.replaceAll(',', '.'));
    switch (technique) {
      case SetTechnique.forzate:
        ts.forcedReps = int.tryParse(forcedCtrl.text);
      case SetTechnique.superSlow:
        ts.isSuperSlow = true;
      case SetTechnique.restPause:
        final altri = clusterCtrls.map((c) => int.tryParse(c.text)).whereType<int>().toList();
        if (ts.reps != null) ts.restPauseClusters = [ts.reps!, ...altri];
      case SetTechnique.stripping:
        final stages = [
          for (final (r, k) in stageCtrls)
            if (int.tryParse(r.text) != null)
              DropStage()
                ..reps = int.tryParse(r.text)
                ..weightKg = double.tryParse(k.text.replaceAll(',', '.')),
        ];
        if (stages.isNotEmpty) ts.dropStages = stages;
      case SetTechnique.normale:
        break;
    }
    return ts;
  }

  static List<_PlannedSetState> fromWorkoutSets(List<WorkoutSet> sets) => sets
      .map((s) => _PlannedSetState(
            reps: s.reps,
            weightKg: s.weightKg,
            technique: s.technique,
            forcedReps: s.forcedReps,
            restPauseClusters: s.restPauseClusters,
            dropStages: s.dropStages,
          ))
      .toList();
}

/// Le serie del target materializzato appaiono "personalizzate" quando non
/// sono tutte identiche o quando almeno una usa una tecnica — l'unico modo
/// per riconoscere in `_modifica` (allenamento_screen.dart) che un
/// `WorkoutExercise` già esistente veniva da una pianificazione per-serie,
/// dato che quell'oggetto non porta `plannedSets` (solo il template ce l'ha).
bool _looksCustom(List<WorkoutSet> sets) {
  if (sets.length < 2) return sets.any((s) => s.technique != SetTechnique.normale);
  final first = sets.first;
  return sets.any(
      (s) => s.technique != SetTechnique.normale || s.reps != first.reps || s.weightKg != first.weightKg);
}

class _TargetEsercizioDialog extends StatefulWidget {
  final ExerciseDefinition exercise;
  final WorkoutExercise? initial;
  const _TargetEsercizioDialog({required this.exercise, this.initial});

  @override
  State<_TargetEsercizioDialog> createState() => _TargetEsercizioDialogState();
}

class _TargetEsercizioDialogState extends State<_TargetEsercizioDialog> {
  late final _initialSet =
      widget.initial != null && widget.initial!.sets.isNotEmpty ? widget.initial!.sets.first : null;
  late final _serieCtrl =
      TextEditingController(text: (widget.initial?.sets.length ?? 3).toString());
  late final _ripCtrl =
      TextEditingController(text: (_initialSet?.reps ?? 10).toString());
  late final _kgCtrl = TextEditingController(text: _initialSet?.weightKg?.toString() ?? '');
  late final _durataCtrl = TextEditingController(
      text: (((widget.initial?.durationSeconds ?? 1800)) ~/ 60).toString());

  // Preselezionato dai dati esistenti (in modifica) o dalla categoria del
  // catalogo, ma sempre modificabile: il modello dati supporta target a
  // tempo per qualunque esercizio (vedi i preset con Plank/Mountain
  // Climbers), non solo quelli taggati cardio.
  late bool _isCardio = widget.initial?.isCardio ?? (widget.exercise.category == 'cardio');

  // Fase 7: pianificazione per-serie, opt-in — di default il target resta
  // uniforme come prima, invariato per chi non la usa.
  late bool _custom = widget.initial != null && _looksCustom(widget.initial!.sets);
  late List<_PlannedSetState> _rows =
      _custom ? _PlannedSetState.fromWorkoutSets(widget.initial!.sets) : [];

  @override
  void dispose() {
    _serieCtrl.dispose();
    _ripCtrl.dispose();
    _kgCtrl.dispose();
    _durataCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _toggleCustom(bool value) {
    setState(() {
      if (value && _rows.isEmpty) {
        final n = int.tryParse(_serieCtrl.text) ?? 3;
        final reps = int.tryParse(_ripCtrl.text);
        final kg = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));
        _rows = List.generate(n.clamp(1, 20), (_) => _PlannedSetState(reps: reps, weightKg: kg));
      }
      _custom = value;
    });
  }

  void _addRow() {
    setState(() {
      final last = _rows.isNotEmpty ? _rows.last : null;
      _rows.add(_PlannedSetState(
          reps: int.tryParse(last?.repsCtrl.text ?? ''),
          weightKg: double.tryParse((last?.kgCtrl.text ?? '').replaceAll(',', '.'))));
    });
  }

  void _removeRow(int i) {
    setState(() {
      _rows.removeAt(i).dispose();
    });
  }

  Future<void> _generaPiramide() async {
    final generated = await showGeneraPiramideSheet(
      context,
      exerciseName:
          widget.exercise.localizedName(Localizations.localeOf(context).languageCode),
    );
    if (generated == null || !mounted) return;
    setState(() {
      for (final r in _rows) {
        r.dispose();
      }
      _rows = generated.map((s) => _PlannedSetState(reps: s.reps, weightKg: s.weightKg)).toList();
      _custom = true;
    });
  }

  void _salva() {
    final result = WorkoutTemplateExercise()
      ..exerciseId = widget.exercise.externalId
      ..exerciseName =
          widget.exercise.localizedName(Localizations.localeOf(context).languageCode);

    if (_isCardio) {
      final min = int.tryParse(_durataCtrl.text);
      if (min == null || min <= 0) return;
      result.targetDurationSeconds = min * 60;
    } else if (_custom) {
      if (_rows.isEmpty) return;
      final planned = _rows.map((r) => r.toTemplateSet()).toList();
      result.plannedSets = planned;
      result.targetSets = planned.length;
      result.targetReps = planned.first.reps;
      result.targetWeightKg = planned.first.weightKg;
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
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.targetDialogTitle(
                  widget.exercise.localizedName(Localizations.localeOf(context).languageCode)),
              style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.targetDialogTipoSerie)),
                ButtonSegment(value: true, label: Text(l10n.targetDialogTipoTempo)),
              ],
              selected: {_isCardio},
              onSelectionChanged: (s) => setState(() => _isCardio = s.first),
            ),
            const SizedBox(height: 16),
            if (_isCardio)
              _Field(label: l10n.targetDialogDurataMin, controller: _durataCtrl, p: p)
            else ...[
              if (!_custom)
                Row(
                  children: [
                    Expanded(child: _Field(label: l10n.targetDialogSerie, controller: _serieCtrl, p: p)),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(label: l10n.targetDialogRip, controller: _ripCtrl, p: p)),
                    const SizedBox(width: 10),
                    Expanded(child: _Field(label: l10n.targetDialogKg, controller: _kgCtrl, p: p)),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < _rows.length; i++)
                      _PlannedSetRow(
                        label: l10n.serieDialogSerieLabel(i + 1),
                        state: _rows[i],
                        p: p,
                        onChanged: () => setState(() {}),
                        onRemove: _rows.length > 1 ? () => _removeRow(i) : null,
                      ),
                    TextButton.icon(
                      onPressed: _addRow,
                      icon: Icon(Icons.add_rounded, size: 16, color: p.accent),
                      label: Text(l10n.serieDialogAggiungiSerie, style: TextStyle(color: p.accent)),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      value: _custom,
                      onChanged: _toggleCustom,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: p.accent,
                      title: Text(l10n.targetDialogSeriePersonalizzate,
                          style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(l10n.targetDialogSeriePersonalizzateHint,
                          style: TextStyle(color: p.textMuted, fontSize: 11)),
                    ),
                  ),
                ],
              ),
              if (_custom) ...[
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: _generaPiramide,
                  icon: Icon(Icons.stairs_rounded, color: p.accent, size: 18),
                  label:
                      Text(l10n.allenamentoGeneraPiramide, style: TextStyle(color: p.accent)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: p.cardBorder)),
                ),
              ],
            ],
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
      ),
    );
  }
}

/// Riga di editing di una serie pianificata: reps/peso/tecnica, stesso set di
/// campi extra (forzate/rest-pause/stripping) di `_SetRow` in
/// sessione_guidata_screen.dart, ma scritti su `WorkoutTemplateSet` invece
/// che su una `WorkoutSet` reale — nessuna conferma "a cedimento": qui si
/// pianifica in anticipo, non si esegue.
class _PlannedSetRow extends StatelessWidget {
  final String label;
  final _PlannedSetState state;
  final ColorPalette p;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _PlannedSetRow({
    required this.label,
    required this.state,
    required this.p,
    required this.onChanged,
    required this.onRemove,
  });

  String _techniqueLabel(SetTechnique t, dynamic l10n) => switch (t) {
        SetTechnique.normale => l10n.sessioneGuidataTecnicaNormale,
        SetTechnique.forzate => l10n.sessioneGuidataTecnicaForzate,
        SetTechnique.restPause => l10n.sessioneGuidataTecnicaRestPause,
        SetTechnique.stripping => l10n.sessioneGuidataTecnicaStripping,
        SetTechnique.superSlow => l10n.sessioneGuidataTecnicaSuperSlow,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 48, child: Text(label, style: TextStyle(color: p.textMuted, fontSize: 12))),
              Expanded(child: NumberField(controller: state.repsCtrl, hint: l10n.serieDialogRipHint, p: p)),
              const SizedBox(width: 8),
              Expanded(child: NumberField(controller: state.kgCtrl, hint: l10n.serieDialogKgHint, p: p)),
              if (state.technique == SetTechnique.forzate) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 56,
                  child: NumberField(
                      controller: state.forcedCtrl, hint: l10n.sessioneGuidataForzateHint, p: p),
                ),
              ],
              if (onRemove != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: p.textMuted),
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in SetTechnique.values)
                  TechniqueChip(
                    label: _techniqueLabel(t, l10n),
                    selected: state.technique == t,
                    p: p,
                    onTap: () {
                      state.technique = t;
                      onChanged();
                    },
                  ),
              ],
            ),
          ),
          if (state.technique == SetTechnique.restPause)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < state.clusterCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 64,
                            child: Text(l10n.sessioneGuidataClusterLabel(i + 2),
                                style: TextStyle(color: p.textMuted, fontSize: 11)),
                          ),
                          SizedBox(
                            width: 70,
                            child: NumberField(
                                controller: state.clusterCtrls[i], hint: l10n.serieDialogRipHint, p: p),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, size: 16, color: p.textMuted),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              state.clusterCtrls[i].dispose();
                              state.clusterCtrls.removeAt(i);
                              onChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      state.clusterCtrls.add(TextEditingController());
                      onChanged();
                    },
                    icon: Icon(Icons.add_rounded, size: 14, color: p.accent),
                    label: Text(l10n.sessioneGuidataAggiungiCluster,
                        style: TextStyle(color: p.accent, fontSize: 11)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ],
              ),
            ),
          if (state.technique == SetTechnique.stripping)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < state.stageCtrls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            child: Text(l10n.sessioneGuidataGradinoLabel(i + 2),
                                style: TextStyle(color: p.textMuted, fontSize: 11)),
                          ),
                          SizedBox(
                            width: 56,
                            child: NumberField(
                                controller: state.stageCtrls[i].$1, hint: l10n.serieDialogRipHint, p: p),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 56,
                            child: NumberField(
                                controller: state.stageCtrls[i].$2, hint: l10n.serieDialogKgHint, p: p),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, size: 16, color: p.textMuted),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              state.stageCtrls[i].$1.dispose();
                              state.stageCtrls[i].$2.dispose();
                              state.stageCtrls.removeAt(i);
                              onChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      state.stageCtrls.add((TextEditingController(), TextEditingController()));
                      onChanged();
                    },
                    icon: Icon(Icons.add_rounded, size: 14, color: p.accent),
                    label: Text(l10n.sessioneGuidataAggiungiGradino,
                        style: TextStyle(color: p.accent, fontSize: 11)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ],
              ),
            ),
        ],
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
