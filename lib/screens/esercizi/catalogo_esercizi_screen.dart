import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exercise_definition.dart';
import '../../services/database_service.dart';
import 'aggiungi_esercizio_personalizzato_screen.dart';
import 'muscle_group_labels.dart';

/// Mostra il catalogo esercizi come bottom sheet a schermo intero.
/// Ritorna l'ExerciseDefinition selezionato, o null se l'utente chiude senza scegliere.
Future<ExerciseDefinition?> showCatalogoEserciziSheet(BuildContext context) {
  return showModalBottomSheet<ExerciseDefinition>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CatalogoEserciziSheet(),
  );
}

class _CatalogoEserciziSheet extends StatefulWidget {
  const _CatalogoEserciziSheet();

  @override
  State<_CatalogoEserciziSheet> createState() => _CatalogoEserciziSheetState();
}

class _CatalogoEserciziSheetState extends State<_CatalogoEserciziSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String? _gruppoSelezionato;
  List<ExerciseDefinition> _risultati = [];
  bool _didInitialSearch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Non in initState: _search() legge Localizations.localeOf(context), che
    // richiede il widget montato nell'albero (initState è troppo presto).
    if (!_didInitialSearch) {
      _didInitialSearch = true;
      _search();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final results = await DatabaseService.instance
        .searchExercises(_searchCtrl.text, muscleGroup: _gruppoSelezionato);
    results.sort((a, b) =>
        a.localizedName(languageCode).compareTo(b.localizedName(languageCode)));
    if (mounted) setState(() => _risultati = results);
  }

  Future<void> _apriAggiungiPersonalizzato() async {
    final created = await Navigator.push<ExerciseDefinition>(
      context,
      MaterialPageRoute(
        builder: (_) => const AggiungiEsercizioPersonalizzatoScreen(),
      ),
    );
    if (created != null && mounted) Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.eserciziCatalogoTitle,
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: p.cardBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onChanged,
                    style: TextStyle(color: p.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: l10n.eserciziCercaHint,
                      hintStyle: TextStyle(color: p.textMuted, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [null, ...muscleGroups].map((g) {
                    final selected = g == _gruppoSelezionato;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(muscleGroupLabel(l10n, g)),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _gruppoSelezionato = g);
                          _search();
                        },
                        selectedColor: p.accent.withValues(alpha: 0.2),
                        labelStyle: TextStyle(color: selected ? p.accent : p.textPrimary),
                        backgroundColor: p.surface,
                        side: BorderSide(color: p.cardBorder),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _risultati.isEmpty
                    ? Center(
                        child: Text(l10n.eserciziNessunRisultato,
                            style: TextStyle(color: p.textMuted)),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _risultati.length,
                        itemBuilder: (context, i) {
                          final e = _risultati[i];
                          return _ExerciseTile(
                            exercise: e,
                            p: p,
                            l10n: l10n,
                            onTap: () => Navigator.pop(context, e),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _apriAggiungiPersonalizzato,
                    icon: Icon(Icons.add_rounded, color: p.accent),
                    label: Text(l10n.eserciziAggiungiPersonalizzato,
                        style: TextStyle(color: p.accent)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ExerciseDefinition exercise;
  final ColorPalette p;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.exercise,
    required this.p,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sottotitolo = [
      muscleGroupLabel(l10n, exercise.muscleGroup),
      if (exercise.equipment != null) exercise.equipment!,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(exercise.localizedName(Localizations.localeOf(context).languageCode),
            style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(sottotitolo, style: TextStyle(color: p.textMuted, fontSize: 12)),
        trailing: exercise.isCustom
            ? Chip(
                label: Text(l10n.eserciziPersonalizzatoBadge,
                    style: TextStyle(color: p.accent, fontSize: 11)),
                backgroundColor: p.accent.withValues(alpha: 0.15),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              )
            : Icon(Icons.add_circle_outline_rounded, color: p.accent),
      ),
    );
  }
}
