import 'coach_history.dart';

/// Azioni a bottone della chat Coach (docs/integrazione_flutter_gemma.md,
/// Fase 8, revisione 2026-10). Il contesto lo decide l'app (`CoachHistory`),
/// il modello scrive solo il testo: nessuna scrittura nel database, l'utente
/// aggiunge a mano ciò che gli interessa.
enum CoachAction { recipes }

class CoachActionRequest {
  /// Istruzioni specifiche dell'azione, da accodare al system prompt.
  final String instruction;

  /// Dati dell'utente nel formato di `CoachHistory`: è esattamente ciò che
  /// parte verso Google, mostrato così com'è nell'anteprima.
  final String context;
  const CoachActionRequest({required this.instruction, required this.context});

  String get systemSuffix => '$instruction\n\n$context';
}

class CoachActions {
  static Future<CoachGate> gate(CoachAction action) => switch (action) {
        CoachAction.recipes => CoachHistory.recipesGate(),
      };

  /// null se non c'è nulla da inviare (il gate dovrebbe già averlo impedito).
  static Future<CoachActionRequest?> load(CoachAction action, {required bool isItalian}) async {
    switch (action) {
      case CoachAction.recipes:
        final context = await CoachHistory.loadRecipesContext(isItalian: isItalian);
        if (context == null) return null;
        return CoachActionRequest(instruction: instruction(action, isItalian), context: context);
    }
  }

  static String instruction(CoachAction action, bool isItalian) => switch (action) {
        CoachAction.recipes => isItalian
            ? 'COMPITO: scrivi una ricetta per ciascun pasto del piano alimentare qui sotto. '
                'Usa SOLO gli alimenti del pasto e le grammature indicate, senza cambiarle né '
                'aggiungere altri alimenti: sono ammessi solo acqua, sale, spezie, erbe e aceto/limone '
                'in quantità trascurabile. Non usare mai alimenti vietati dalle restrizioni. '
                'Formato Markdown, per ogni pasto: titolo, elenco ingredienti con le grammature del '
                'piano, procedimento in pochi passi numerati. Non aggiungere calcoli di kcal diversi '
                'da quelli del piano.'
            : 'TASK: write one recipe for each meal of the meal plan below. Use ONLY the foods of '
                'that meal with the grams given, without changing them or adding other foods: only '
                'water, salt, spices, herbs and vinegar/lemon in negligible amounts are allowed. '
                'Never use foods banned by the restrictions. Markdown format, for each meal: title, '
                'ingredient list with the plan\'s grams, method in a few numbered steps. Do not add '
                'kcal figures different from the plan\'s.',
      };
}
