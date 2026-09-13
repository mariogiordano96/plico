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
/// di pianificare "Serie personalizzate" — reps/peso diversi per serie (es.
/// piramide) — e una **Tecnica** (rest-pause, stripping, forzate, super
/// slow) decisa una sola volta a livello di esercizio, applicata identica a
/// ogni serie generata (`WorkoutTemplateExercise.plannedSets`, riproposto
/// via `materializeSets()`). La tecnica non è per-serie: nell'uso reale si
/// decide "questo esercizio lo faccio a rest-pause", non riga per riga.
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

/// Reps/peso di una singola serie pianificata — solo i numeri, la tecnica
/// vive a livello di esercizio in `_TargetEsercizioDialogState`, non qui.
class _PlannedSetState {
  final TextEditingController repsCtrl;
  final TextEditingController kgCtrl;

  _PlannedSetState({int? reps, double? weightKg})
      : repsCtrl = TextEditingController(text: reps?.toString() ?? ''),
        kgCtrl = TextEditingController(text: weightKg?.toString() ?? '');

  void dispose() {
    repsCtrl.dispose();
    kgCtrl.dispose();
  }
}

/// Le serie del target materializzato appaiono "personalizzate" (piramide)
/// quando reps/peso non sono tutti identici — la tecnica non c'entra più
/// (è tracciata separatamente, vedi `_detectTechnique`).
bool _looksCustomSets(List<WorkoutSet> sets) {
  if (sets.length < 2) return false;
  final first = sets.first;
  return sets.any((s) => s.reps != first.reps || s.weightKg != first.weightKg);
}

/// La tecnica di un esercizio esistente è quella (uniforme, per costruzione:
/// solo questo dialog scrive `plannedSets`, sempre con la stessa tecnica su
/// ogni serie) della prima serie di lavoro.
SetTechnique _detectTechnique(List<WorkoutSet> sets) =>
    sets.isNotEmpty ? sets.first.technique : SetTechnique.normale;

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

  // Fase 7: pianificazione per-serie (piramide), opt-in — di default il
  // target resta uniforme come prima, invariato per chi non la usa.
  late bool _custom = widget.initial != null && _looksCustomSets(widget.initial!.sets);
  late List<_PlannedSetState> _rows = _custom
      ? widget.initial!.sets.map((s) => _PlannedSetState(reps: s.reps, weightKg: s.weightKg)).toList()
      : [];

  // Fase 7g: tecnica a livello di esercizio (non per-serie) — applicata
  // identica a ogni serie generata, sia dal target uniforme sia dalle serie
  // personalizzate.
  late SetTechnique _tecnica =
      widget.initial != null ? _detectTechnique(widget.initial!.sets) : SetTechnique.normale;
  late final TextEditingController _forzateCtrl;
  final List<TextEditingController> _clusterCtrls = [];
  final List<(TextEditingController, TextEditingController)> _stageCtrls = [];

  @override
  void initState() {
    super.initState();
    final firstSet = _initialSet;
    _forzateCtrl = TextEditingController(text: firstSet?.forcedReps?.toString() ?? '');
    if (firstSet?.restPauseClusters != null && firstSet!.restPauseClusters!.length > 1) {
      for (final v in firstSet.restPauseClusters!.skip(1)) {
        _clusterCtrls.add(TextEditingController(text: v.toString()));
      }
    }
    if (firstSet?.dropStages != null) {
      for (final d in firstSet!.dropStages!) {
        _stageCtrls.add((
          TextEditingController(text: d.reps?.toString() ?? ''),
          TextEditingController(text: d.weightKg?.toString() ?? ''),
        ));
      }
    }
  }

  @override
  void dispose() {
    _serieCtrl.dispose();
    _ripCtrl.dispose();
    _kgCtrl.dispose();
    _durataCtrl.dispose();
    _forzateCtrl.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    for (final c in _clusterCtrls) {
      c.dispose();
    }
    for (final (r, k) in _stageCtrls) {
      r.dispose();
      k.dispose();
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

  /// Applica `_tecnica` (scelta una sola volta per l'esercizio) a ogni serie
  /// di [baseSets] — stessa tecnica, cluster/gradini/reps-forzate identici
  /// su tutte, coerente con come si usano davvero in palestra ("questo
  /// esercizio lo faccio a rest-pause", non riga per riga).
  void _applyTecnica(List<WorkoutTemplateSet> baseSets) {
    if (_tecnica == SetTechnique.normale) return;
    final altriCluster = _clusterCtrls.map((c) => int.tryParse(c.text)).whereType<int>().toList();
    final stageValues = [
      for (final (r, k) in _stageCtrls)
        if (int.tryParse(r.text) != null)
          (reps: int.tryParse(r.text), weightKg: double.tryParse(k.text.replaceAll(',', '.'))),
    ];
    for (final s in baseSets) {
      switch (_tecnica) {
        case SetTechnique.forzate:
          s.forcedReps = int.tryParse(_forzateCtrl.text);
        case SetTechnique.superSlow:
          s.isSuperSlow = true;
        case SetTechnique.restPause:
          if (s.reps != null) s.restPauseClusters = [s.reps!, ...altriCluster];
        case SetTechnique.stripping:
          if (stageValues.isNotEmpty) {
            s.dropStages = stageValues
                .map((v) => DropStage()
                  ..reps = v.reps
                  ..weightKg = v.weightKg)
                .toList();
          }
        case SetTechnique.normale:
          break;
      }
    }
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
      Navigator.pop(context, result);
      return;
    }

    final List<WorkoutTemplateSet> baseSets;
    if (_custom) {
      if (_rows.isEmpty) return;
      baseSets = _rows
          .map((r) => WorkoutTemplateSet()
            ..reps = int.tryParse(r.repsCtrl.text)
            ..weightKg = double.tryParse(r.kgCtrl.text.replaceAll(',', '.')))
          .toList();
    } else {
      final serie = int.tryParse(_serieCtrl.text);
      if (serie == null || serie <= 0) return;
      final reps = int.tryParse(_ripCtrl.text);
      final kg = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));
      baseSets = List.generate(
          serie, (_) => WorkoutTemplateSet()
            ..reps = reps
            ..weightKg = kg);
    }
    _applyTecnica(baseSets);

    result.targetSets = baseSets.length;
    result.targetReps = baseSets.first.reps;
    result.targetWeightKg = baseSets.first.weightKg;
    // plannedSets serve solo quando c'è qualcosa di diverso dal target
    // uniforme da preservare (piramide e/o tecnica) — altrimenti si lascia
    // il percorso semplice di sempre, invariato per chi non usa nessuna
    // delle due.
    if (_custom || _tecnica != SetTechnique.normale) {
      result.plannedSets = baseSets;
    }
    Navigator.pop(context, result);
  }

  String _techniqueLabel(SetTechnique t, dynamic l10n) => switch (t) {
        SetTechnique.normale => l10n.sessioneGuidataTecnicaNormale,
        SetTechnique.forzate => l10n.sessioneGuidataTecnicaForzate,
        SetTechnique.restPause => l10n.sessioneGuidataTecnicaRestPause,
        SetTechnique.stripping => l10n.sessioneGuidataTecnicaStripping,
        SetTechnique.superSlow => l10n.sessioneGuidataTecnicaSuperSlow,
      };

  String? _techniqueDescription(SetTechnique t, dynamic l10n) => switch (t) {
        SetTechnique.forzate => l10n.targetDialogTecnicaDescrizioneForzate,
        SetTechnique.restPause => l10n.targetDialogTecnicaDescrizioneRestPause,
        SetTechnique.stripping => l10n.targetDialogTecnicaDescrizioneStripping,
        SetTechnique.superSlow => l10n.targetDialogTecnicaDescrizioneSuperSlow,
        SetTechnique.normale => null,
      };

  Widget _buildTecnicaSection(ColorPalette p, dynamic l10n) {
    final description = _techniqueDescription(_tecnica, l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.targetDialogTecnicaLabel,
            style: TextStyle(color: p.textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final t in SetTechnique.values)
              TechniqueChip(
                label: _techniqueLabel(t, l10n),
                selected: _tecnica == t,
                p: p,
                onTap: () => setState(() => _tecnica = t),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: p.textMuted, fontSize: 11)),
        ],
        if (_tecnica == SetTechnique.forzate) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: NumberField(
                controller: _forzateCtrl, hint: l10n.sessioneGuidataForzateHint, p: p),
          ),
        ],
        if (_tecnica == SetTechnique.restPause) ...[
          const SizedBox(height: 8),
          for (var i = 0; i < _clusterCtrls.length; i++)
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
                        controller: _clusterCtrls[i], hint: l10n.serieDialogRipHint, p: p),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 16, color: p.textMuted),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      _clusterCtrls[i].dispose();
                      _clusterCtrls.removeAt(i);
                    }),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _clusterCtrls.add(TextEditingController())),
            icon: Icon(Icons.add_rounded, size: 14, color: p.accent),
            label: Text(l10n.sessioneGuidataAggiungiCluster,
                style: TextStyle(color: p.accent, fontSize: 11)),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ],
        if (_tecnica == SetTechnique.stripping) ...[
          const SizedBox(height: 8),
          for (var i = 0; i < _stageCtrls.length; i++)
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
                        controller: _stageCtrls[i].$1, hint: l10n.serieDialogRipHint, p: p),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 56,
                    child: NumberField(
                        controller: _stageCtrls[i].$2, hint: l10n.serieDialogKgHint, p: p),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 16, color: p.textMuted),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      _stageCtrls[i].$1.dispose();
                      _stageCtrls[i].$2.dispose();
                      _stageCtrls.removeAt(i);
                    }),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () =>
                setState(() => _stageCtrls.add((TextEditingController(), TextEditingController()))),
            icon: Icon(Icons.add_rounded, size: 14, color: p.accent),
            label: Text(l10n.sessioneGuidataAggiungiGradino,
                style: TextStyle(color: p.accent, fontSize: 11)),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ],
      ],
    );
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
              // Fase 7g: la tecnica si decide una volta sola per l'esercizio,
              // sopra l'elenco delle serie — non riga per riga.
              _buildTecnicaSection(p, l10n),
              const SizedBox(height: 16),
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

/// Riga di editing di una singola serie pianificata: solo reps/peso — la
/// tecnica vive a livello di esercizio (`_TargetEsercizioDialogState`, Fase
/// 7g), non qui.
class _PlannedSetRow extends StatelessWidget {
  final String label;
  final _PlannedSetState state;
  final ColorPalette p;
  final VoidCallback? onRemove;

  const _PlannedSetRow({
    required this.label,
    required this.state,
    required this.p,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(label, style: TextStyle(color: p.textMuted, fontSize: 12))),
          Expanded(child: NumberField(controller: state.repsCtrl, hint: l10n.serieDialogRipHint, p: p)),
          const SizedBox(width: 8),
          Expanded(child: NumberField(controller: state.kgCtrl, hint: l10n.serieDialogKgHint, p: p)),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 18, color: p.textMuted),
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
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
