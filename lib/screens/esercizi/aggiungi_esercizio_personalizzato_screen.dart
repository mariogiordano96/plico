import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../services/database_service.dart';
import 'muscle_group_labels.dart';

class AggiungiEsercizioPersonalizzatoScreen extends StatefulWidget {
  const AggiungiEsercizioPersonalizzatoScreen({super.key});

  @override
  State<AggiungiEsercizioPersonalizzatoScreen> createState() =>
      _AggiungiEsercizioPersonalizzatoScreenState();
}

class _AggiungiEsercizioPersonalizzatoScreenState
    extends State<AggiungiEsercizioPersonalizzatoScreen> {
  final _nomeCtrl = TextEditingController();
  final _attrezzaturaCtrl = TextEditingController();
  String _gruppo = 'chest';
  String _categoria = 'strength';
  String? _errore;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _attrezzaturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    final nome = _nomeCtrl.text.trim();
    if (nome.isEmpty) {
      setState(() => _errore = context.l10n.eserciziNomeObbligatorio);
      return;
    }

    final exercise = ExerciseDefinition()
      ..externalId = 'custom_${DateTime.now().microsecondsSinceEpoch}'
      ..name = nome
      ..muscleGroup = _categoria == 'cardio' ? 'cardio' : _gruppo
      ..category = _categoria
      ..equipment =
          _attrezzaturaCtrl.text.trim().isEmpty ? null : _attrezzaturaCtrl.text.trim()
      ..isCustom = true;

    await DatabaseService.instance.addCustomExercise(exercise);
    if (mounted) Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.eserciziNuovoTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.eserciziNomeLabel,
              style: TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _nomeCtrl,
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.eserciziNomeHint,
              hintStyle: TextStyle(color: p.textMuted),
              filled: true,
              fillColor: p.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.cardBorder),
              ),
            ),
          ),
          if (_errore != null) ...[
            const SizedBox(height: 6),
            Text(_errore!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          Text(l10n.eserciziTipoLabel,
              style: TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'strength', label: Text(l10n.eserciziTipoForza)),
              ButtonSegment(value: 'cardio', label: Text(l10n.eserciziTipoCardio)),
            ],
            selected: {_categoria},
            onSelectionChanged: (s) => setState(() => _categoria = s.first),
          ),
          if (_categoria == 'strength') ...[
            const SizedBox(height: 20),
            Text(l10n.eserciziGruppoMuscolareLabel,
                style:
                    TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: muscleGroups.where((g) => g != 'cardio').map((g) {
                final selected = g == _gruppo;
                return ChoiceChip(
                  label: Text(muscleGroupLabel(l10n, g)),
                  selected: selected,
                  onSelected: (_) => setState(() => _gruppo = g),
                  selectedColor: p.accent.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: selected ? p.accent : p.textPrimary),
                  backgroundColor: p.surface,
                  side: BorderSide(color: p.cardBorder),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          Text(l10n.eserciziAttrezzaturaLabel,
              style: TextStyle(color: p.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _attrezzaturaCtrl,
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.eserciziAttrezzaturaHint,
              hintStyle: TextStyle(color: p.textMuted),
              filled: true,
              fillColor: p.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _salva,
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.eserciziSalva,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
