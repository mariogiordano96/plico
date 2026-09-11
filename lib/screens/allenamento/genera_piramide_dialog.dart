import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_set.dart';

/// Fase 1 di docs/tecniche_allenamento.md: genera una progressione piramidale
/// di serie (peso che sale/scende, ripetizioni che scendono/salgono di
/// conseguenza) e sovrascrive le [WorkoutSet] esistenti di un esercizio del
/// log — nessuna modifica al modello dati, la piramide è solo un modo
/// alternativo di compilare serie che già supportano reps/peso indipendenti.
/// Ritorna la lista di [WorkoutSet] generata, o null se l'utente annulla.
Future<List<WorkoutSet>?> showGeneraPiramideSheet(
  BuildContext context, {
  required String exerciseName,
}) {
  return showModalBottomSheet<List<WorkoutSet>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GeneraPiramideSheet(exerciseName: exerciseName),
  );
}

class _GeneraPiramideSheet extends StatefulWidget {
  final String exerciseName;
  const _GeneraPiramideSheet({required this.exerciseName});

  @override
  State<_GeneraPiramideSheet> createState() => _GeneraPiramideSheetState();
}

class _GeneraPiramideSheetState extends State<_GeneraPiramideSheet> {
  final _serieCtrl = TextEditingController(text: '4');
  final _pesoCtrl = TextEditingController(text: '40');
  final _ripCtrl = TextEditingController(text: '12');
  final _incrementoCtrl = TextEditingController(text: '5');
  final _decrementoCtrl = TextEditingController(text: '2');
  bool _ascendente = true;

  late final _controllers = [_serieCtrl, _pesoCtrl, _ripCtrl, _incrementoCtrl, _decrementoCtrl];

  @override
  void initState() {
    super.initState();
    // Ricalcola l'anteprima a ogni carattere digitato in uno qualunque dei campi.
    for (final c in _controllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onFieldChanged);
    }
    _serieCtrl.dispose();
    _pesoCtrl.dispose();
    _ripCtrl.dispose();
    _incrementoCtrl.dispose();
    _decrementoCtrl.dispose();
    super.dispose();
  }

  /// Serie generate con i valori correnti dei campi, o null se non ancora
  /// validi (usato sia per l'anteprima live sia per il salvataggio finale).
  List<WorkoutSet>? _generate() {
    final numeroSerie = int.tryParse(_serieCtrl.text);
    final pesoIniziale = double.tryParse(_pesoCtrl.text.replaceAll(',', '.'));
    final repsIniziali = int.tryParse(_ripCtrl.text);
    final incremento = double.tryParse(_incrementoCtrl.text.replaceAll(',', '.'));
    final decremento = int.tryParse(_decrementoCtrl.text);
    if (numeroSerie == null || numeroSerie <= 0) return null;
    if (pesoIniziale == null || repsIniziali == null) return null;
    if (incremento == null || decremento == null) return null;

    return [
      for (var i = 0; i < numeroSerie; i++)
        WorkoutSet()
          ..weightKg = _ascendente
              ? pesoIniziale + i * incremento
              : (pesoIniziale - i * incremento).clamp(0, double.infinity)
          ..reps = _ascendente
              ? (repsIniziali - i * decremento).clamp(1, 1000).toInt()
              : repsIniziali + i * decremento,
    ];
  }

  void _salva() {
    final sets = _generate();
    if (sets == null) return;
    Navigator.pop(context, sets);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final anteprima = _generate();

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
              Text(
                l10n.piramideDialogTitle(widget.exerciseName),
                style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.piramideDialogAscendente)),
                  ButtonSegment(value: false, label: Text(l10n.piramideDialogDiscendente)),
                ],
                selected: {_ascendente},
                onSelectionChanged: (s) => setState(() => _ascendente = s.first),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                        label: l10n.piramideDialogNumeroSerie, controller: _serieCtrl, p: p),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                        label: l10n.piramideDialogPesoIniziale, controller: _pesoCtrl, p: p),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _Field(label: l10n.piramideDialogRipIniziali, controller: _ripCtrl, p: p),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                        label: l10n.piramideDialogIncrementoKg,
                        controller: _incrementoCtrl,
                        p: p),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                        label: l10n.piramideDialogDecrementoRip,
                        controller: _decrementoCtrl,
                        p: p),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (anteprima != null) ...[
                Text(l10n.piramideDialogAnteprima,
                    style: TextStyle(color: p.textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  anteprima.map((s) => '${s.reps}×${s.weightKg?.toStringAsFixed(1)}kg').join('  ·  '),
                  style: TextStyle(color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
              ],
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
                      onPressed: anteprima == null ? null : _salva,
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
