import 'coach_history.dart';

/// Azioni a bottone della chat Coach (docs/integrazione_flutter_gemma.md,
/// Fase 8, revisione 2026-10). Il contesto lo decide l'app (`CoachHistory`),
/// il modello scrive solo il testo: nessuna scrittura nel database, l'utente
/// aggiunge a mano ciò che gli interessa.
enum CoachAction { recipes, nutrition, workout }

class CoachActionRequest {
  /// Istruzioni specifiche dell'azione, da accodare al system prompt.
  final String instruction;

  /// Dati dell'utente nel formato di `CoachHistory`: è esattamente ciò che
  /// parte verso Google, consultabile nella modale di conferma.
  final String context;

  /// Elenco in linguaggio semplice di cosa parte verso Google, per la modale
  /// di conferma: il testo tecnico in [context] resta consultabile ma non è
  /// la prima cosa che l'utente legge.
  final List<String> summary;
  const CoachActionRequest({
    required this.instruction,
    required this.context,
    required this.summary,
  });

  String get systemSuffix => '$instruction\n\n$context';
}

class CoachActions {
  static Future<CoachGate> gate(CoachAction action) => switch (action) {
        CoachAction.recipes => CoachHistory.recipesGate(),
        CoachAction.nutrition => CoachHistory.nutritionGate(),
        CoachAction.workout => CoachHistory.workoutGate(),
      };

  /// null se non c'è nulla da inviare (il gate dovrebbe già averlo impedito).
  static Future<CoachActionRequest?> load(CoachAction action, {required bool isItalian}) async {
    switch (action) {
      case CoachAction.recipes:
        final context = await CoachHistory.loadRecipesContext(isItalian: isItalian);
        if (context == null) return null;
        return CoachActionRequest(
          instruction: instruction(action, isItalian),
          context: context,
          summary: summary(action, isItalian),
        );
      case CoachAction.nutrition:
        return CoachActionRequest(
          instruction: instruction(action, isItalian),
          context: await CoachHistory.loadNutritionContext(isItalian: isItalian),
          summary: summary(action, isItalian),
        );
      case CoachAction.workout:
        return CoachActionRequest(
          instruction: instruction(action, isItalian),
          context: await CoachHistory.loadWorkoutContext(isItalian: isItalian),
          summary: summary(action, isItalian),
        );
    }
  }

  static List<String> summary(CoachAction action, bool isItalian) => switch (action) {
        CoachAction.recipes => isItalian
            ? ['Il tuo piano alimentare attuale', 'Le tue restrizioni alimentari']
            : ['Your current meal plan', 'Your dietary restrictions'],
        CoachAction.nutrition => isItalian
            ? [
                'Obiettivo, livello di attività e target calorici',
                'Restrizioni, alimenti graditi e numero di pasti',
                'Il tuo piano alimentare attuale',
                'Diario alimentare e peso degli ultimi 3 mesi (solo se compilato abbastanza)',
              ]
            : [
                'Goal, activity level and calorie targets',
                'Restrictions, preferred foods and meals per day',
                'Your current meal plan',
                'Food diary and weight of the last 3 months (only if filled in enough)',
              ],
        CoachAction.workout => isItalian
            ? [
                'Obiettivo e livello di attività',
                'Allenamenti degli ultimi 3 mesi (esercizi, carichi, volume)',
                'Peso degli ultimi 3 mesi',
              ]
            : [
                'Goal and activity level',
                'Workouts of the last 3 months (exercises, loads, volume)',
                'Weight of the last 3 months',
              ],
      };

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
        CoachAction.nutrition => isItalian
            ? 'COMPITO: proponi una nuova alimentazione giornaliera come variante del piano attuale '
                '(se presente). I target di kcal e macro sono FISSI: la somma dei pasti deve '
                'rispettarli, indica per ogni pasto alimenti e grammature e il totale di kcal/macro '
                'della giornata. Rispetta le preferenze e i pasti al giorno indicati, usa gli alimenti '
                'graditi dove possibile e NON proporre mai alimenti vietati dalle restrizioni. Se il '
                'diario e il peso lo permettono, spiega in 2-3 righe cosa cambi e perché; se il '
                'diario è scarso non giudicare l\'aderenza. Formato Markdown.'
            : 'TASK: propose a new daily eating plan as a variation of the current plan (if any). '
                'The kcal and macro targets are FIXED: the meals must add up to them; for each meal '
                'list foods and grams, plus the day\'s kcal/macro total. Respect the preferences and '
                'meals per day given, use preferred foods where possible and NEVER suggest foods '
                'banned by the restrictions. If the diary and weight allow it, explain in 2-3 lines '
                'what you change and why; if the diary is sparse do not judge adherence. Markdown '
                'format.',
        CoachAction.workout => isItalian
            ? 'COMPITO: proponi una nuova scheda di allenamento in base allo storico qui sotto, '
                'all\'obiettivo e al livello. Usa preferibilmente gli esercizi già usati (stessi '
                'nomi) e aggiungine di nuovi solo se serve a coprire un gruppo muscolare trascurato '
                'o ad assicurare varietà. Parti dai carichi e dal volume reali dell\'utente: '
                'progressioni graduali, nessun salto improvviso. Per ogni giorno: esercizi, serie, '
                'ripetizioni, riposo; poi 2-3 righe che spiegano le scelte rispetto allo storico. '
                'Se il volume di un gruppo è molto sotto agli altri, segnalalo. Formato Markdown.'
            : 'TASK: propose a new workout plan based on the history below, the goal and the level. '
                'Prefer exercises already used (same names) and add new ones only to cover a '
                'neglected muscle group or ensure variety. Start from the user\'s real loads and '
                'volume: gradual progressions, no sudden jumps. For each day: exercises, sets, reps, '
                'rest; then 2-3 lines explaining the choices relative to the history. If a group\'s '
                'volume is far below the others, point it out. Markdown format.',
      };
}
