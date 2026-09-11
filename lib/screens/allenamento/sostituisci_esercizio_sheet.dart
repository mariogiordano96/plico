import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise_definition.dart';
import '../../services/database_service.dart';
import '../esercizi/muscle_group_labels.dart';

/// Bottom sheet per la sostituzione esercizio al volo (Fase 13): mostra le
/// alternative già ordinate da [DatabaseService.getAlternatives], senza
/// ricerca/filtri — scelta rapida durante l'allenamento.
/// Ritorna l'[ExerciseDefinition] scelto, o null se l'utente chiude senza scegliere.
Future<ExerciseDefinition?> showSostituisciEsercizioSheet(
  BuildContext context,
  String exerciseId,
) async {
  final alternatives = await DatabaseService.instance.getAlternatives(exerciseId);
  if (!context.mounted) return null;
  return showModalBottomSheet<ExerciseDefinition>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SostituisciEsercizioSheet(alternatives: alternatives),
  );
}

class _SostituisciEsercizioSheet extends StatelessWidget {
  final List<ExerciseDefinition> alternatives;
  const _SostituisciEsercizioSheet({required this.alternatives});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return DraggableScrollableSheet(
      initialChildSize: alternatives.isEmpty ? 0.35 : 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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
                  l10n.allenamentoSostituisciTitle,
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: alternatives.isEmpty
                    ? Center(
                        child: Text(l10n.allenamentoSostituisciVuoto,
                            style: TextStyle(color: p.textMuted)),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: alternatives.length,
                        itemBuilder: (context, i) {
                          final e = alternatives[i];
                          final sottotitolo = [
                            muscleGroupLabel(l10n, e.muscleGroup),
                            if (e.equipment != null) e.equipment!,
                          ].join(' · ');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: p.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: p.cardBorder),
                            ),
                            child: ListTile(
                              onTap: () => Navigator.pop(context, e),
                              title: Text(
                                  e.localizedName(Localizations.localeOf(context).languageCode),
                                  style: TextStyle(
                                      color: p.textPrimary, fontWeight: FontWeight.w600)),
                              subtitle: Text(sottotitolo,
                                  style: TextStyle(color: p.textMuted, fontSize: 12)),
                              trailing: Icon(Icons.swap_horiz_rounded, color: p.accent),
                            ),
                          );
                        },
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
