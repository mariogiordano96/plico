import '../models/food_item.dart';
import '../models/meal_plan.dart';
import 'database_service.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;

class PianoService {
  static const _goalMult = [0.80, 1.0, 1.15];
  static const _protMatrix = [
    [1.4, 1.8, 2.3, 2.6, 3.1],
    [0.8, 1.2, 1.4, 1.8, 2.0],
    [0.8, 1.2, 1.6, 1.8, 2.0],
  ];

  // Slot types
  static const kProteina = 0;
  static const kCarboidrato = 1;
  static const kVerdura = 2;
  static const kGrasso = 3;
  static const kExtra = 4;

  static const slotLabels = ['Proteina', 'Carboidrati', 'Verdura', 'Grassi', 'Extra'];
  static const slotEmoji = ['🥩', '🍚', '🥦', '🫒', '🧀'];

  // Meal types
  static const kPastoColazione = 0;
  static const kPastoPranzo = 1;
  static const kPastoCena = 2;
  static const kPastoSpuntino = 3;
  static const kPastoSpuntinoPostWo = 4;

  static const pastoLabels = ['Colazione', 'Pranzo', 'Cena', 'Spuntino', 'Post-WO'];
  static const pastoEmoji = ['☀️', '🍽️', '🌙', '🍎', '💪'];

  static const curatedCerealiColazione = [
    "Fiocchi d'avena",
    'Pane di tipo integrale',
  ];

  static const curatedLatticiniColazione = [
    'Yogurt greco, 0% lipidi',
    'Ricotta di vacca',
    'Latte di vacca, pastorizzato, scremato',
  ];

  // versione salata
  static const curatedProteineSalataColazione = [
    'Uova di gallina, intero',
    'Ricotta di vacca',
  ];
  static const curatedCerealiSalata = [
    'Pane di tipo integrale',
  ];

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
      'Quinoa, cruda',
      'Pane di tipo integrale',
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
      'Ricotta di vacca',
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

    List<PlanSlot> buildMainMealSlots(double share) {
      final slots = <PlanSlot>[];

      final sProt = buildSlot(
        tipo: kProteina,
        foods: pool(['Proteine animali', 'Proteine vegetali'], exclude: usedProtIds),
        altFoods: pool(['Proteine animali', 'Proteine vegetali']),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * share) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 350, minGrams: 50,
      );
      trackPrincipal(sProt, usedProtIds);
      if (sProt != null) slots.add(sProt);

      final sCarbo = buildSlot(
        tipo: kCarboidrato,
        foods: pool(['Cereali'], exclude: usedCarboIds),
        altFoods: pool(['Cereali']),
        gramsFn: (f) => f.carbsPer100g > 0 ? (carbsTarget * share) / (f.carbsPer100g / 100) : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 250, minGrams: 20,
      );
      trackPrincipal(sCarbo, usedCarboIds);
      if (sCarbo != null) slots.add(sCarbo);

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

      final sGrasso = buildSlot(
        tipo: kGrasso,
        foods: pool(['Grassi'], exclude: usedGrassoIds),
        altFoods: pool(['Grassi']),
        gramsFn: (f) => f.fatPer100g > 0 ? (fatTarget * share) / (f.fatPer100g / 100) : 0,
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


      final sCarbo = buildSlot(
        tipo: kCarboidrato,
        foods: poolByNames(curatedCerealiColazione),
        gramsFn: (f) => f.carbsPer100g > 0 ? (carbsTarget * colShare) / (f.carbsPer100g / 100) : 0,
        scoreFn: (f) => f.carbsPer100g,
        maxGrams: 100, minGrams: 20,
      );
      trackPrincipal(sCarbo, usedCarboIds);
      if (sCarbo != null) slots.add(sCarbo);

      final sExtra = buildSlot(
        tipo: kExtra,
        foods: poolByNames(curatedLatticiniColazione),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * colShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 300, minGrams: 80,
      );
      trackPrincipal(sExtra, usedExtraIds);
      if (sExtra != null) slots.add(sExtra);

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

    // ── Pranzo ─────────────────────────────────────────────────
    {
      final slots = buildMainMealSlots(mainShare);
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

      final sSnkGrasso = buildSlot(
        tipo: kGrasso,
        foods: pool(['Grassi'], exclude: usedGrassoIds),
        altFoods: pool(['Grassi']),
        gramsFn: (f) => f.fatPer100g > 0 ? (fatTarget * snkShare) / (f.fatPer100g / 100) : 0,
        scoreFn: (f) => f.fatPer100g,
        maxGrams: 35, minGrams: 10,
      );
      trackPrincipal(sSnkGrasso, usedGrassoIds);
      if (sSnkGrasso != null) snkSlots.add(sSnkGrasso);

      // versione salata (pane + ricotta)
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
        tipo: kExtra,
        foods: poolByNames(['Ricotta di vacca']),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 200, minGrams: 50,
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
      final slots = buildMainMealSlots(mainShare);
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
        tipo: kExtra,
        foods: poolByNames(['Ricotta di vacca']),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * snkShare) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 200, minGrams: 80,
      );
      if (sSnk2 != null) {
        pasti.add(PlanMeal()
          ..tipo = kPastoSpuntino
          ..slots = [sSnk2]
          ..slotsAlternativa = [?sSnk2Sal]);
      }
    }

    // ── Spuntino post-WO ───────────────────────────────────────
    if (haSpuntinoPostWo) {
      final sPostWo = buildSlot(
        tipo: kProteina,
        foods: pool(['Proteine animali', 'Latticini'], exclude: usedProtIds),
        altFoods: pool(['Proteine animali', 'Latticini']),
        gramsFn: (f) => f.proteinPer100g > 0 ? (protTarget * 0.10) / (f.proteinPer100g / 100) : 0,
        scoreFn: (f) => f.proteinPer100g,
        maxGrams: 150, minGrams: 20,
      );
      if (sPostWo != null) {
        pasti.add(PlanMeal()
          ..tipo = kPastoSpuntinoPostWo
          ..slots = [sPostWo]);
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

    final alts = <PlanFood>[];
    for (final f in altPool.take(4)) {
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
