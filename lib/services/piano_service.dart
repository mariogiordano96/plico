import '../models/food_item.dart';
import '../models/meal_plan.dart';
import 'database_service.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;

class PianoService {
  static const _goalMult = [0.80, 1.0, 1.15];
  static const _protMatrix = [
    [1.4, 1.8, 2.3, 2.6, 3.1],  // dimagrimento
    [0.8, 1.2, 1.4, 1.8, 2.0],  // mantenimento
    [1.6, 1.8, 2.0, 2.2, 2.4],  // aumento massa
  ];

  // Slot types
  static const kProteina = 0;
  static const kCarboidrato = 1;
  static const kVerdura = 2;
  static const kGrasso = 3;
  static const kExtra = 4;
  static const kFrutta = 5;

  static const slotLabels = ['Proteina', 'Carboidrati', 'Verdura', 'Grassi', 'Extra', 'Frutta'];
  static const slotEmoji = ['🥩', '🍚', '🥦', '🫒', '🧀', '🍓'];

  // Meal types
  static const kPastoColazione = 0;
  static const kPastoPranzo = 1;
  static const kPastoCena = 2;
  static const kPastoSpuntino = 3;
  static const kPastoSpuntinoPostWo = 4;
  static const kPastoSpuntinoSerale = 5;

  static const pastoLabels = ['Colazione', 'Pranzo', 'Cena', 'Spuntino', 'Post-WO', 'Spuntino serale'];
  static const pastoEmoji = ['☀️', '🍽️', '🌙', '🍎', '💪', '⭐'];

  static const curatedCerealiColazione = [
    "Fiocchi d'avena",
    'Gallette di riso',
    'Muesli',
    'Fette biscottate, integrali',
    'Pane di tipo integrale',
  ];

  static const curatedLatticiniColazione = [
    'Yogurt greco, 0% lipidi',
    'Skyr, naturale',
    'Fiocchi di latte',
    'Ricotta di vacca',
    'Fiocchi di formaggio magro',
    'Latte di vacca, pastorizzato, scremato',
  ];

  static const curatedFruttaColazione = [
    'Banane, fresche',
    'Mele, fresche, golden',
    'Pere, fresche, Abate Fetel',
    'Arance, fresche',
    'Fragole, fresche',
    'Mirtilli, freschi',
    'Kiwi, freschi',
    'Lamponi, freschi',
  ];

  // versione salata
  static const curatedProteineSalataColazione = [
    'Bresaola della Valtellina IGP',
    'Prosciutto cotto, sgrassato',
    'Prosciutto crudo, disossato, sgrassato',
    'Speck dell\'Alto Adige IGP',
    'Salmone, affumicato',
    'Uova di gallina, intero',
    'Ricotta di vacca',
  ];
  static const curatedCerealiSalata = [
    'Pane di tipo integrale',
    'Fette biscottate, integrali',
    'Crackers, integrali',
  ];

  // Solo frutta secca per lo spuntino: olio EVO e avocado non hanno
  // senso come snack standalone.
  static const curatedFruttaSeccaSnack = [
    'Mandorle dolci, secche',
    'Noci, secche',
    'Nocciole, secche',
    'Pistacchi',
    'Arachidi, tostate',
    "Burro d'arachidi",
  ];

  // Leguminose: contengono già ~50-60g di carboidrati per 100g secchi,
  // quindi quando vengono usate come proteina si esclude lo slot carbo.
  static const _leguminoseNames = <String>{
    'Lenticchie, secche',
    'Ceci, secchi',
    'Fagioli, Borlotti, secchi',
    'Fagioli, Cannellini, secchi',
    "Fagioli dall'occhio, secchi",
    'Fave, secche',
    'Piselli, secchi',
    'Lupini, ammollati',
  };

  static const curatedNames = <String, List<String>>{
    'Proteine animali': [
      'Pollo, petto, crudo',
      'Tacchino, fesa, crudo',
      'Coniglio intero, crudo',
      'Maiale, bistecca, crudo',
      'Bovino adulto o vitellone, fesa, crudo',
      'Agnello, crudo',
      'Salmone, fresco',
      'Tonno in salamoia, sgocciolato',
      'Merluzzo o nasello',
      'Gamberi sgusciati, surgelati',
      'Uova di gallina, intero',
    ],
    'Proteine vegetali': [
      'Lenticchie, secche',
      'Ceci, secchi',
      'Fagioli, Borlotti, secchi',
      'Fagioli, Cannellini, secchi',
      "Fagioli dall'occhio, secchi",
      'Fave, secche',
      'Piselli, secchi',
      'Lupini, ammollati',
      'Tofu, sodo',
      'Tempeh',
      'Seitan',
    ],
    'Cereali': [
      'Riso Basmati, crudo',
      'Riso, integrale',
      'Pasta di semola',
      'Pasta di semola, integrale',
      'Couscous, crudo',
      'Orzo perlato',
      'Farro perlato, crudo',
      "Fiocchi d'avena",
      'Gallette di riso',
      'Muesli',
      'Fette biscottate, integrali',
      'Quinoa, cruda',
      'Pane di tipo integrale',
      'Crackers, integrali',
    ],
    'Verdure': [
      'Spinaci, crudi',
      'Broccolo a testa, crudo',
      'Zucchine, crude',
      'Pomodori, da insalata, freschi',
      'Carote, crude',
      'Cavolfiore, crudo',
      'Peperoni, crudi',
      'Melanzane, crude',
      'Funghi porcini, crudi',
      'Asparagi di serra, crudi',
    ],
    'Latticini': [
      'Yogurt greco, 0% lipidi',
      'Skyr, naturale',
      'Fiocchi di latte',
      'Ricotta di vacca',
      'Fiocchi di formaggio magro',
      'Mozzarella di vacca',
      'Fior di latte',
      'Scamorza',
      'Parmigiano Reggiano DOP',
      'Grana Padano, DOP',
      'Latte di vacca, pastorizzato, scremato',
    ],
    'Grassi': [
      'Olio di oliva extra vergine',
      'Mandorle dolci, secche',
      'Noci, secche',
      'Nocciole, secche',
      'Pistacchi',
      'Arachidi, tostate',
      "Burro d'arachidi",
      'Avocado, fresco',
    ],
  };

  static List<String> excludedByRestrizioni(List<String> restrizioni) {
    final out = <String>{};
    if (restrizioni.contains('vegetariano') || restrizioni.contains('vegano')) {
      out.addAll([
        'Carni fresche',
        'Carni trasformate e conservate',
        'Fast-food a base di carne',
        'Frattaglie',
        'Prodotti della pesca',
      ]);
    }
    if (restrizioni.contains('vegano')) {
      out.addAll(['Latte e yogurt', 'Formaggi e latticini', 'Uova']);
    }
    if (restrizioni.contains('no_lattosio')) {
      out.addAll(['Latte e yogurt', 'Formaggi e latticini']);
    }
    if (restrizioni.contains('no_glutine')) {
      out.add('Cereali e derivati');
    }
    if (restrizioni.contains('no_pesce')) {
      out.add('Prodotti della pesca');
    }
    if (restrizioni.contains('no_fruttaSecca')) {
      out.add('Frutta secca a guscio e semi oleaginosi');
    }
    return out.toList();
  }

  static Future<(int, int, int, int)?> computeTargets() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    if (profile == null || snapshot == null) return null;
    final session = await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    final obiettivo = await DatabaseService.instance.getObiettivo();
    final result = calcolaTdee(
      sesso: profile.sesso,
      eta: profile.etaCorrente,
      altezzaCm: profile.altezzaCm,
      pesoKg: snapshot.pesoKg,
      livello: livello,
      metodo: metodo,
      massaMagraKg: session?.risultati.massaMagraKg,
    );
    if (result == null) return null;
    final kcal = (result.tdee * _goalMult[obiettivo.clamp(0, 2)]).round();
    final prot = (snapshot.pesoKg * _protMatrix[obiettivo.clamp(0, 2)][livello.clamp(0, 4)]).round();
    final fat = (kcal * 0.25 / 9).round();
    final carbs = ((kcal - prot * 4 - fat * 9) / 4).round().clamp(0, 9999);
    return (kcal, prot, fat, carbs);
  }

  static Future<MealPlan?> generaPiano() async {
    final targets = await computeTargets();
    if (targets == null) return null;
    final protTarget = targets.$2.toDouble();
    final fatTarget = targets.$3.toDouble();
    final carbsTarget = targets.$4.toDouble();

    final prefs = await DatabaseService.instance.getUserFoodPreferences();
    final likedIds = prefs?.foodLikedIds ?? [];
    final excluded = excludedByRestrizioni(prefs?.restrizioni ?? []);
    final numPasti = prefs?.numPasti ?? 3;
    final haSpuntinoPostWo = prefs?.haSpuntinoPostWo ?? false;

    final allCrea = await DatabaseService.instance.getAllCreaFoods();
    final byName = {for (final f in allCrea) f.nome: f};

    List<FoodItem> pool(List<String> groups, {Set<int> exclude = const {}}) => groups
        .expand((g) => curatedNames[g] ?? <String>[])
        .map((n) => byName[n])
        .whereType<FoodItem>()
        .where((f) => f.categoria == null || !excluded.contains(f.categoria))
        .where((f) => !exclude.contains(f.id))
        .toList();

    final livello = await DatabaseService.instance.getLivelloAttivita();
    final obiettivo = await DatabaseService.instance.getObiettivo();

    // Macro share per tipo di pasto
    final (colShare, mainShare, snkShare) = switch (numPasti) {
      4 => (0.20, 0.35, 0.10),
      5 => (0.20, 0.30, 0.10),
      _ => (0.20, 0.40, 0.00),
    };
    final snackCount = (numPasti - 3).clamp(0, 2);

    // Traccia cibi già usati come principale per evitare ripetizioni
    final usedProtIds = <int>{};
    final usedCarboIds = <int>{};
    final usedVerduraIds = <int>{};
    final usedGrassoIds = <int>{};
    final usedExtraIds = <int>{};
    final usedFruttaIds = <int>{};

    PlanSlot? buildSlot({
      required int tipo,
      required List<FoodItem> foods,
      List<FoodItem>? altFoods,
      required double Function(FoodItem) gramsFn,
      required double Function(FoodItem) scoreFn,
      required double maxGrams,
      required double minGrams,
    }) =>
        _buildSlot(
          tipo: tipo,
          foods: foods,
          altFoods: altFoods,
          likedIds: likedIds,
          gramsFn: gramsFn,
          scoreFn: scoreFn,
          maxGrams: maxGrams,
          minGrams: minGrams,
        );

    void trackPrincipal(PlanSlot? s, Set<int> used) {
      final id = s?.principale?.foodItemId;
      if (id != null && id != 0) used.add(id);
    }

    List<PlanSlot> buildMainMealSlots(double share, {double? carbsForMeal, double fruttaCarbs = 0.0}) {
      final slots = <PlanSlot>[];

      // Build carb slot first (tentatively, without tracking) to know its incidental
      // protein and fat — this lets us size the protein and fat slots accurately.
      final effectiveCarbTarget = ((carbsForMeal ?? carbsTarget * share) - fruttaCarbs)
          .clamp(0.0, double.infinity);
      final sCarboTentative = buildSlot(
        tipo: kCarboidrato,
        foods: pool(['Cereali'], exclude: usedCarboIds),
        altFoods: pool(['Cereali']),
        gramsFn: (f) => f.carbsPer100g > 0 ? effectiveCarbTarget / (f.carbsPer100g / 100) : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 300, minGrams: 20,
      );
      final carbIncProt = sCarboTentative?.principale?.proteine ?? 0.0;
      final carbIncFat  = sCarboTentative?.principale?.grassi   ?? 0.0;

      // Protein slot: subtract cereal incidental protein so the total hits the target
      final adjustedProtTarget = (protTarget * share - carbIncProt).clamp(0.0, double.infinity);
      final sProt = buildSlot(
        tipo: kProteina,
        foods: pool(['Proteine animali', 'Proteine vegetali'], exclude: usedProtIds),
        altFoods: pool(['Proteine animali', 'Proteine vegetali']),
        gramsFn: (f) => f.proteinPer100g > 0 ? adjustedProtTarget / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 350, minGrams: 50,
      );
      trackPrincipal(sProt, usedProtIds);
      if (sProt != null) slots.add(sProt);

      // Se la proteina è una leguminosa, i carbs sono già coperti dal legume stesso
      final isLegume = _leguminoseNames.contains(sProt?.principale?.nome ?? '');
      if (!isLegume && sCarboTentative != null) {
        trackPrincipal(sCarboTentative, usedCarboIds);
        slots.add(sCarboTentative);
      }

      final sVerd = buildSlot(
        tipo: kVerdura,
        foods: pool(['Verdure'], exclude: usedVerduraIds),
        altFoods: pool(['Verdure']),
        gramsFn: (_) => 150.0,
        scoreFn: (f) => f.kcalPer100g > 0 ? 1000 / f.kcalPer100g : 0,
        maxGrams: 150, minGrams: 150,
      );
      trackPrincipal(sVerd, usedVerduraIds);
      if (sVerd != null) slots.add(sVerd);

      // Fat slot: subtract incidental fat from cereal and protein food
      final protIncFat = sProt?.principale?.grassi ?? 0.0;
      final adjustedFatTarget = (fatTarget * share - carbIncFat - protIncFat).clamp(0.0, double.infinity);
      final sGrasso = buildSlot(
        tipo: kGrasso,
        foods: pool(['Grassi'], exclude: usedGrassoIds),
        altFoods: pool(['Grassi']),
        gramsFn: (f) => f.fatPer100g > 0 ? adjustedFatTarget / (f.fatPer100g / 100) : 0,
        scoreFn: (f) => f.fatPer100g,
        maxGrams: 50, minGrams: 3,
      );
      trackPrincipal(sGrasso, usedGrassoIds);
      if (sGrasso != null) slots.add(sGrasso);

      return slots;
    }

    List<FoodItem> poolByNames(List<String> names, {Set<int> exclude = const {}}) => names
        .map((n) => byName[n])
        .whereType<FoodItem>()
        .where((f) => f.categoria == null || !excluded.contains(f.categoria))
        .where((f) => !exclude.contains(f.id))
        .toList();

    final pasti = <PlanMeal>[];

    // ── Colazione ──────────────────────────────────────────────
    {
      final slots = <PlanSlot>[];

      // Frutta selezionata prima: i suoi carbs vengono sottratti al cereale
      // così la somma cerale + frutta = target colazione senza sforare
      final sFruttaCol = buildSlot(
        tipo: kFrutta,
        foods: poolByNames(curatedFruttaColazione, exclude: usedFruttaIds),
        gramsFn: (_) => 150.0,
        scoreFn: (_) => 1.0,
        maxGrams: 150, minGrams: 150,
      );
      final fruttaCarbsCol = sFruttaCol?.principale?.carboidrati ?? 0.0;

      final sCarbo = buildSlot(
        tipo: kCarboidrato,
        foods: poolByNames(curatedCerealiColazione),
        gramsFn: (f) => f.carbsPer100g > 0
            ? (carbsTarget * colShare - fruttaCarbsCol).clamp(0.0, double.infinity) / (f.carbsPer100g / 100)
            : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 100, minGrams: 20,
      );
      trackPrincipal(sCarbo, usedCarboIds);
      if (sCarbo != null) slots.add(sCarbo);

      // Latticini: subtract cereal incidental protein so the colazione total hits target
      final colCarbIncProt = sCarbo?.principale?.proteine ?? 0.0;
      final colCarbIncFat  = sCarbo?.principale?.grassi   ?? 0.0;
      final adjustedColProtTarget = (protTarget * colShare - colCarbIncProt).clamp(0.0, double.infinity);

      final sExtra = buildSlot(
        tipo: kExtra,
        foods: poolByNames(curatedLatticiniColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? adjustedColProtTarget / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 200, minGrams: 80,
      );
      trackPrincipal(sExtra, usedExtraIds);
      if (sExtra != null) slots.add(sExtra);

      // Il muesli contiene già frutta/frutta secca: non aggiungere slot frutta né grassi
      final isMuesli = sCarbo?.principale?.nome == 'Muesli';
      if (!isMuesli && sFruttaCol != null) {
        trackPrincipal(sFruttaCol, usedFruttaIds);
        slots.add(sFruttaCol);
      }

      if (!isMuesli) {
        // Frutta secca: subtract incidental fat from cereal and latticini
        final colExtraIncFat = sExtra?.principale?.grassi ?? 0.0;
        final adjustedColFatTarget = (fatTarget * colShare - colCarbIncFat - colExtraIncFat)
            .clamp(0.0, double.infinity);
        final sGrassoCol = buildSlot(
          tipo: kGrasso,
          foods: poolByNames(curatedFruttaSeccaSnack, exclude: usedGrassoIds),
          altFoods: poolByNames(curatedFruttaSeccaSnack),
          gramsFn: (f) => f.fatPer100g > 0 ? adjustedColFatTarget / (f.fatPer100g / 100) : 0,
          scoreFn: (f) => f.fatPer100g,
          maxGrams: 30, minGrams: 5,
        );
        if (sGrassoCol != null) {
          trackPrincipal(sGrassoCol, usedGrassoIds);
          slots.add(sGrassoCol);
        }
      }

      // versione salata (uova + pane)
      final slotsAltColazione = <PlanSlot>[];
      final sProtSal = buildSlot(
        tipo: kProteina,
        foods: poolByNames(curatedProteineSalataColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * colShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 300, minGrams: 50,
      );
      if (sProtSal != null) slotsAltColazione.add(sProtSal);
      final sCarboSal = buildSlot(
        tipo: kCarboidrato,
        foods: poolByNames(curatedCerealiSalata),
        gramsFn: (f) => f.carbsPer100g > 0 ? (carbsTarget * colShare) / (f.carbsPer100g / 100) : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 80, minGrams: 20,
      );
      if (sCarboSal != null) slotsAltColazione.add(sCarboSal);

      if (slots.isNotEmpty) {
        pasti.add(PlanMeal()
          ..tipo = kPastoColazione
          ..slots = slots
          ..slotsAlternativa = slotsAltColazione);
      }
    }

    // Carbs: cena più leggera (70% share), il residuo va interamente al pranzo
    // così la somma colazione + pranzo + spuntini + cena = 100% del target carbs
    final cenaCarbsFactor = mainShare * 0.70;
    final pranzoCarbsFactor = 1.0 - colShare - (snackCount.clamp(0, 1) * snkShare) - cenaCarbsFactor;

    // ── Pranzo ─────────────────────────────────────────────────
    {
      // Frutta selezionata prima per sottrarne i carbs al cereale
      final sFruttaPranzo = buildSlot(
        tipo: kFrutta,
        foods: poolByNames(curatedFruttaColazione, exclude: usedFruttaIds),
        gramsFn: (_) => 150.0,
        scoreFn: (_) => 1.0,
        maxGrams: 150, minGrams: 150,
      );
      final fruttaCarbsPranzo = sFruttaPranzo?.principale?.carboidrati ?? 0.0;

      final slots = buildMainMealSlots(mainShare,
          carbsForMeal: carbsTarget * pranzoCarbsFactor, fruttaCarbs: fruttaCarbsPranzo);

      // Non aggiungere frutta se il pasto è a base di legumi (già ricchi di carbs)
      final isLegumeMeal = slots.any(
        (s) => s.tipo == kProteina && _leguminoseNames.contains(s.principale?.nome ?? ''),
      );
      if (sFruttaPranzo != null && !isLegumeMeal) {
        trackPrincipal(sFruttaPranzo, usedFruttaIds);
        slots.add(sFruttaPranzo);
      }

      if (slots.isNotEmpty) {
        pasti.add(PlanMeal()
          ..tipo = kPastoPranzo
          ..slots = slots);
      }
    }

    // ── Spuntino pomeridiano (numPasti >= 4) ───────────────────
    if (snackCount >= 1) {
      final snkSlots = <PlanSlot>[];

      final sSnkProt = buildSlot(
        tipo: kExtra,
        foods: poolByNames(curatedLatticiniColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 250, minGrams: 80,
      );
      if (sSnkProt != null) snkSlots.add(sSnkProt);

      // Frutta: copre la quota carbs dello spuntino (10% del target giornaliero)
      final sSnkFrutta = buildSlot(
        tipo: kFrutta,
        foods: poolByNames(curatedFruttaColazione, exclude: usedFruttaIds),
        gramsFn: (_) => 150.0,
        scoreFn: (_) => 1.0,
        maxGrams: 150, minGrams: 150,
      );
      if (sSnkFrutta != null) {
        trackPrincipal(sSnkFrutta, usedFruttaIds);
        snkSlots.add(sSnkFrutta);
      }

      // Solo frutta secca per lo spuntino: olio EVO e avocado non hanno
      // senso come snack standalone
      final sSnkGrasso = buildSlot(
        tipo: kGrasso,
        foods: poolByNames(curatedFruttaSeccaSnack, exclude: usedGrassoIds),
        altFoods: poolByNames(curatedFruttaSeccaSnack),
        gramsFn: (f) => f.fatPer100g > 0 ? (fatTarget * snkShare) / (f.fatPer100g / 100) : 0,
        scoreFn: (f) => f.fatPer100g,
        maxGrams: 35, minGrams: 10,
      );
      trackPrincipal(sSnkGrasso, usedGrassoIds);
      if (sSnkGrasso != null) snkSlots.add(sSnkGrasso);

      // versione salata (pane + affettato/ricotta)
      final slotsAltSnk1 = <PlanSlot>[];
      final sSnkCarboSal = buildSlot(
        tipo: kCarboidrato,
        foods: poolByNames(curatedCerealiSalata),
        gramsFn: (f) => f.carbsPer100g > 0 ? (carbsTarget * snkShare) / (f.carbsPer100g / 100) : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 60, minGrams: 20,
      );
      if (sSnkCarboSal != null) slotsAltSnk1.add(sSnkCarboSal);
      final sSnkExtraSal = buildSlot(
        tipo: kProteina,
        foods: poolByNames(curatedProteineSalataColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 120, minGrams: 30,
      );
      if (sSnkExtraSal != null) slotsAltSnk1.add(sSnkExtraSal);

      if (snkSlots.isNotEmpty) {
        pasti.add(PlanMeal()
          ..tipo = kPastoSpuntino
          ..slots = snkSlots
          ..slotsAlternativa = slotsAltSnk1);
      }
    }

    // ── Cena ───────────────────────────────────────────────────
    {
      final slots = buildMainMealSlots(mainShare, carbsForMeal: carbsTarget * cenaCarbsFactor);
      if (slots.isNotEmpty) {
        pasti.add(PlanMeal()
          ..tipo = kPastoCena
          ..slots = slots);
      }
    }

    // ── Spuntino serale (numPasti == 5) ────────────────────────
    if (snackCount >= 2) {
      final sSnk2 = buildSlot(
        tipo: kExtra,
        foods: poolByNames(curatedLatticiniColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 200, minGrams: 80,
      );
      final sSnk2Sal = buildSlot(
        tipo: kProteina,
        foods: poolByNames(curatedProteineSalataColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 120, minGrams: 30,
      );
      if (sSnk2 != null) {
        pasti.add(PlanMeal()
          ..tipo = kPastoSpuntinoSerale
          ..slots = [sSnk2]
          ..slotsAlternativa = [?sSnk2Sal]);
      }
    }

    // ── Spuntino post-WO ───────────────────────────────────────
    if (haSpuntinoPostWo) {
      final postWoSlots = <PlanSlot>[];

      final sPostWoProt = buildSlot(
        tipo: kProteina,
        foods: pool(['Proteine animali', 'Latticini'], exclude: usedProtIds),
        altFoods: pool(['Proteine animali', 'Latticini']),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * 0.10) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 150, minGrams: 20,
      );
      if (sPostWoProt != null) postWoSlots.add(sPostWoProt);

      // Carbo rapido post-allenamento per recupero glicogeno
      final sPostWoFrutta = buildSlot(
        tipo: kFrutta,
        foods: poolByNames(curatedFruttaColazione, exclude: usedFruttaIds),
        gramsFn: (_) => 150.0,
        scoreFn: (_) => 1.0,
        maxGrams: 150, minGrams: 150,
      );
      if (sPostWoFrutta != null) {
        trackPrincipal(sPostWoFrutta, usedFruttaIds);
        postWoSlots.add(sPostWoFrutta);
      }

      if (postWoSlots.isNotEmpty) {
        pasti.add(PlanMeal()
          ..tipo = kPastoSpuntinoPostWo
          ..slots = postWoSlots);
      }
    }

    if (pasti.isEmpty) return null;

    double kcalTot = 0, protTot = 0, fatTot = 0, carbTot = 0;
    for (final pasto in pasti) {
      for (final s in pasto.slots) {
        if (s.principale == null || s.tipo == kVerdura) continue;
        kcalTot += s.principale!.kcal;
        protTot += s.principale!.proteine;
        fatTot += s.principale!.grassi;
        carbTot += s.principale!.carboidrati;
      }
    }

    final plan = MealPlan()
      ..dataCreazione = DateTime.now()
      ..pasti = pasti
      ..kcalTotali = kcalTot
      ..proteineTotali = protTot
      ..grassiTotali = fatTot
      ..carbsTotali = carbTot
      ..obsoleto = false
      ..livelloAtGenerazione = livello
      ..obiettivoAtGenerazione = obiettivo;

    await DatabaseService.instance.saveMealPlan(plan);
    return plan;
  }

  static double _round5(double g) => (g / 5).round() * 5.0;

  static PlanSlot? _buildSlot({
    required int tipo,
    required List<FoodItem> foods,
    List<FoodItem>? altFoods,
    required List<int> likedIds,
    required double Function(FoodItem) gramsFn,
    required double Function(FoodItem) scoreFn,
    required double maxGrams,
    required double minGrams,
  }) {
    if (foods.isEmpty) return null;

    double score(FoodItem f) =>
        scoreFn(f) + (likedIds.contains(f.id) ? 10000 : 0);

    final sorted = [...foods]..sort((a, b) => score(b).compareTo(score(a)));

    PlanFood? buildFood(FoodItem f, double grams) {
      if (grams <= 0 || !grams.isFinite) return null;
      final g = _round5(grams.clamp(minGrams, maxGrams));
      return PlanFood()
        ..nome = f.nome
        ..foodItemId = f.id
        ..quantitaG = g
        ..kcal = f.kcalPer100g * g / 100
        ..proteine = f.proteinPer100g * g / 100
        ..grassi = f.fatPer100g * g / 100
        ..carboidrati = f.carbsPer100g * g / 100;
    }

    final principale = buildFood(sorted.first, gramsFn(sorted.first));
    if (principale == null) return null;

    final principaleId = sorted.first.id;
    final targetKcal = principale.kcal;

    // Alternative dal pool completo (senza esclusioni), escluso solo il principale scelto
    final altPool = altFoods != null
        ? ([...altFoods]..sort((a, b) => score(b).compareTo(score(a))))
            .where((f) => f.id != principaleId)
            .toList()
        : sorted.skip(1).toList();

    // Tutti i cibi liked come alternative (senza cap), poi 3 non-liked per varietà
    final likedAlts = altPool.where((f) => likedIds.contains(f.id)).toList();
    final nonLikedAlts = altPool.where((f) => !likedIds.contains(f.id)).take(3).toList();

    final alts = <PlanFood>[];
    for (final f in [...likedAlts, ...nonLikedAlts]) {
      if (f.kcalPer100g <= 0) continue;
      final g = targetKcal / (f.kcalPer100g / 100);
      final alt = buildFood(f, g);
      if (alt != null) alts.add(alt);
    }

    return PlanSlot()
      ..tipo = tipo
      ..principale = principale
      ..alternative = alts;
  }
}
