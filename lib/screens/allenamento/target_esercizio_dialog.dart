import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../models/workout_exercise.dart';
import '../../models/workout_set.dart';
import '../../models/workout_template_exercise.dart';
import 'widgets/technique_widgets.dart';

/// Dialog per impostare il target (serie/rip/peso o durata) di un esercizio,
/// sia quando si costruisce una scheda sia quando si aggiunge/modifica un
/// esercizio libero nel log del giorno. Se [initial] è fornito, precompila i
/// campi con i suoi valori (modifica) invece dei default (3 serie × 10 rip).
/// Ritorna il WorkoutTemplateExercise compilato.
///
/// Fase 7 (docs/tecniche_allenamento.md): oltre al target uniforme, permette
/// di scegliere una **Progressione** (piramide ascendente/discendente,
/// generata automaticamente da serie/rip/kg + incremento/decremento — Fase
/// 7i, sostituisce le vecchie "serie personalizzate" a compilazione manuale)
/// e una **Tecnica** (rest-pause, stripping, forzate, super slow) decise una
/// sola volta a livello di esercizio, applicate a ogni serie generata
/// (`WorkoutTemplateExercise.plannedSets`, riproposto via `materializeSets()`).
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
    // cresca oltre l'altezza schermo e finisca sotto la status bar/notch —
    // visto su Samsung. Il contenuto resta scrollabile internamente
    // (SingleChildScrollView sotto).
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    builder: (_) => _TargetEsercizioDialog(exercise: exercise, initial: initial),
  );
}

enum _Progressione { normale, piramidale, piramidaleInverso }

/// La tecnica di un esercizio esistente è quella (uniforme, per costruzione:
/// solo questo dialog scrive `plannedSets`, sempre con la stessa tecnica su
/// ogni serie) della prima serie di lavoro.
SetTechnique _detectTechnique(List<WorkoutSet> sets) =>
    sets.isNotEmpty ? sets.first.technique : SetTechnique.normale;

/// Deduce la progressione e i suoi parametri da due serie consecutive di un
/// esercizio esistente (Fase 7i) — non c'è più uno stato "serie
/// personalizzate" salvato a parte da poter rileggere: se le prime due serie
/// hanno reps/peso diversi, si assume fossero una piramide e si ricostruisce
/// incremento/decremento dalla differenza, così riaprire per modificare
/// un esercizio già pianificato precompila qualcosa di sensato invece di
/// azzerare la progressione.
(_Progressione, double incremento, int decremento) _detectProgressione(List<WorkoutSet> sets) {
  if (sets.length < 2) return (_Progressione.normale, 5, 2);
  final a = sets[0], b = sets[1];
  if (a.reps == b.reps && a.weightKg == b.weightKg) return (_Progressione.normale, 5, 2);
  final deltaKg = (b.weightKg ?? 0) - (a.weightKg ?? 0);
  final deltaReps = (a.reps ?? 0) - (b.reps ?? 0);
  final ascendente = deltaKg >= 0;
  return (
    ascendente ? _Progressione.piramidale : _Progressione.piramidaleInverso,
    deltaKg.abs(),
    deltaReps.abs(),
  );
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
  // Un esercizio cardio esistente non ha `sets` (lista sempre vuota): usare
  // .length darebbe "0" come numero di serie precompilato passando a
  // "Serie", un valore che fallisce subito la validazione al salvataggio
  // senza che l'utente abbia toccato quel campo.
  late final _serieCtrl = TextEditingController(
      text: (widget.initial != null && widget.initial!.sets.isNotEmpty
              ? widget.initial!.sets.length
              : 3)
          .toString());
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

  // Fase 7i: progressione piramidale generata automaticamente da serie/rip/kg
  // + incremento/decremento — sostituisce le vecchie "serie personalizzate"
  // a compilazione manuale (troppi click per un caso che si riduce sempre
  // a una progressione aritmetica).
  late _Progressione _progressione;
  late final TextEditingController _incrementoCtrl;
  late final TextEditingController _decrementoCtrl;

  // Fase 7h: tecnica a livello di esercizio (non per-serie) — applicata
  // identica a ogni serie generata, sia dal target uniforme sia dalla
  // progressione piramidale.
  late SetTechnique _tecnica =
      widget.initial != null ? _detectTechnique(widget.initial!.sets) : SetTechnique.normale;
  late final TextEditingController _forzateCtrl;
  final List<TextEditingController> _clusterCtrls = [];
  final List<(TextEditingController, TextEditingController)> _stageCtrls = [];

  @override
  void initState() {
    super.initState();
    final (progressione, incremento, decremento) =
        widget.initial != null ? _detectProgressione(widget.initial!.sets) : (_Progressione.normale, 5.0, 2);
    _progressione = progressione;
    _incrementoCtrl = TextEditingController(text: incremento == 0 ? '5' : incremento.toString());
    _decrementoCtrl = TextEditingController(text: decremento == 0 ? '2' : decremento.toString());

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
    _incrementoCtrl.dispose();
    _decrementoCtrl.dispose();
    _forzateCtrl.dispose();
    for (final c in _clusterCtrls) {
      c.dispose();
    }
    for (final (r, k) in _stageCtrls) {
      r.dispose();
      k.dispose();
    }
    super.dispose();
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

  /// Errore di validazione mostrato sotto i campi, invece di un fallimento
  /// silenzioso di `_salva` — es. peso mancante con la piramide selezionata,
  /// dove il campo Kg smette di essere opzionale ma non lo comunicava.
  String? _errore;

  void _salva() {
    final l10n = context.l10n;
    setState(() => _errore = null);
    final result = WorkoutTemplateExercise()
      ..exerciseId = widget.exercise.externalId
      ..exerciseName =
          widget.exercise.localizedName(Localizations.localeOf(context).languageCode);

    if (_isCardio) {
      final min = int.tryParse(_durataCtrl.text);
      if (min == null || min <= 0) {
        setState(() => _errore = l10n.targetDialogErroreDurata);
        return;
      }
      result.targetDurationSeconds = min * 60;
      Navigator.pop(context, result);
      return;
    }

    final numeroSerie = int.tryParse(_serieCtrl.text);
    if (numeroSerie == null || numeroSerie <= 0) {
      setState(() => _errore = l10n.targetDialogErroreSerie);
      return;
    }
    final reps = int.tryParse(_ripCtrl.text);
    final kg = double.tryParse(_kgCtrl.text.replaceAll(',', '.'));

    final List<WorkoutTemplateSet> baseSets;
    if (_progressione == _Progressione.normale) {
      baseSets = List.generate(
          numeroSerie, (_) => WorkoutTemplateSet()
            ..reps = reps
            ..weightKg = kg);
    } else {
      if (reps == null || kg == null) {
        setState(() => _errore = l10n.targetDialogErrorePiramideKgRip);
        return;
      }
      final incremento = double.tryParse(_incrementoCtrl.text.replaceAll(',', '.'));
      final decremento = int.tryParse(_decrementoCtrl.text);
      if (incremento == null || decremento == null) {
        setState(() => _errore = l10n.targetDialogErrorePiramideIncremento);
        return;
      }
      final ascendente = _progressione == _Progressione.piramidale;
      baseSets = [
        for (var i = 0; i < numeroSerie; i++)
          WorkoutTemplateSet()
            ..weightKg = ascendente
                ? kg + i * incremento
                : (kg - i * incremento).clamp(0, double.infinity)
            ..reps =
                ascendente ? (reps - i * decremento).clamp(1, 1000).toInt() : reps + i * decremento,
      ];
    }
    _applyTecnica(baseSets);

    result.targetSets = baseSets.length;
    result.targetReps = baseSets.first.reps;
    result.targetWeightKg = baseSets.first.weightKg;
    // plannedSets serve solo quando c'è qualcosa di diverso dal target
    // uniforme da preservare (piramide e/o tecnica) — altrimenti si lascia
    // il percorso semplice di sempre, invariato per chi non usa nessuna
    // delle due.
    if (_progressione != _Progressione.normale || _tecnica != SetTechnique.normale) {
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

  String _progressioneLabel(_Progressione p, dynamic l10n) => switch (p) {
        _Progressione.normale => l10n.targetDialogProgressioneNormale,
        _Progressione.piramidale => l10n.targetDialogProgressionePiramidale,
        _Progressione.piramidaleInverso => l10n.targetDialogProgressionePiramidaleInverso,
      };

  String? _progressioneDescription(_Progressione p, dynamic l10n) => switch (p) {
        _Progressione.normale => null,
        _Progressione.piramidale => l10n.targetDialogProgressionePiramidaleDescrizione,
        _Progressione.piramidaleInverso => l10n.targetDialogProgressionePiramidaleInversoDescrizione,
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

  Widget _buildProgressioneSection(ColorPalette p, dynamic l10n) {
    final description = _progressioneDescription(_progressione, l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.targetDialogProgressioneLabel,
            style: TextStyle(color: p.textMuted, fontSize: 11)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final prog in _Progressione.values)
              TechniqueChip(
                label: _progressioneLabel(prog, l10n),
                selected: _progressione == prog,
                p: p,
                onTap: () => setState(() => _progressione = prog),
              ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: p.textMuted, fontSize: 11)),
        ],
        if (_progressione != _Progressione.normale) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _Field(
                      label: l10n.piramideDialogIncrementoKg, controller: _incrementoCtrl, p: p)),
              const SizedBox(width: 10),
              Expanded(
                  child: _Field(
                      label: l10n.piramideDialogDecrementoRip, controller: _decrementoCtrl, p: p)),
            ],
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
              // Fase 7h: la tecnica si decide una volta sola per l'esercizio,
              // sopra i campi serie/rip/kg — non riga per riga.
              _buildTecnicaSection(p, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Field(label: l10n.targetDialogSerie, controller: _serieCtrl, p: p)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: l10n.targetDialogRip, controller: _ripCtrl, p: p)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Field(
                          // Con la piramide selezionata Kg e Rip smettono di
                          // essere opzionali (servono come punto di partenza
                          // della progressione) — la label lo comunica,
                          // altrimenti il salvataggio fallisce senza che sia
                          // chiaro perché.
                          label: _progressione == _Progressione.normale
                              ? l10n.targetDialogKg
                              : l10n.targetDialogKgObbligatorio,
                          controller: _kgCtrl,
                          p: p)),
                ],
              ),
              const SizedBox(height: 16),
              // Fase 7i: piramide generata automaticamente dai campi sopra +
              // incremento/decremento, sostituisce le vecchie "serie
              // personalizzate" a compilazione manuale (meno click, meno
              // sezioni).
              _buildProgressioneSection(p, l10n),
            ],
            if (_errore != null) ...[
              const SizedBox(height: 8),
              Text(_errore!, style: const TextStyle(color: Colors.red, fontSize: 12)),
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
