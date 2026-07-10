import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/body_snapshot.dart';
import 'package:plico/models/enums.dart';
import 'package:plico/models/food_item.dart';
import 'package:plico/models/user_food_preferences.dart';
import 'package:plico/models/user_profile.dart';
import 'package:plico/screens/tdee/tdee_screen.dart' show calcolaTdee;
import 'package:plico/services/database_service.dart';
import 'package:plico/services/piano_service.dart';

// ─────────────────────────────────────────────────────────
// Helper: seed minimo per generaPiano()
// ─────────────────────────────────────────────────────────

Future<void> _seedDb({
  double pesoKg = 80.0,
  int livello = 2,
  int obiettivo = 1,
  int numPasti = 3,
}) async {
  final db = DatabaseService.instance;

  // Profilo utente: maschio, 30 anni, 175 cm
  final profile = UserProfile()
    ..id = 1
    ..nome = 'Test'
    ..cognome = 'User'
    ..dataNascita = DateTime(DateTime.now().year - 30, 1, 1)
    ..sesso = Sesso.maschio
    ..altezzaCm = 175
    ..createdAt = DateTime.now();
  await db.saveUserProfile(profile);

  // Peso
  final snap = BodySnapshot()
    ..pesoKg = pesoKg
    ..data = DateTime.now();
  await db.addBodySnapshot(snap);

  // Impostazioni
  await db.saveLivelloAttivita(livello);
  await db.saveObiettivo(obiettivo);
  await db.saveMetodoTdee(2); // Mifflin-St Jeor

  // Preferenze pasto
  await db.saveUserFoodPreferences(
    UserFoodPreferences()
      ..numPasti = numPasti
      ..haSpuntinoPostWo = false
      ..restrizioni = []
      ..foodLikedIds = [],
  );

  // Alimenti (nomi esatti usati da PianoService.curatedNames)
  await db.seedTestFoods(_testFoods);
}

// Alimenti di test con valori nutrizionali realistici (per 100g).
// Nomi allineati a PianoService.curatedNames/curated*Colazione dopo la
// normalizzazione dei nomi CREA (docs/normalizzazione_nomi_alimenti.md) — i
// vecchi nomi verbosi (es. "Pollo, petto, crudo") non combaciano più con le
// liste curate ("Petto di pollo"), causando un pool quasi vuoto e piani
// generati con kcal/macro molto sotto target.
const _testFoods = [
  // Proteine animali
  _TF('Petto di pollo',               kcal: 110, prot: 23.0, fat:  1.2, carbs:  0.0, cat: 'Carni fresche'),
  _TF('Fesa di tacchino',             kcal: 107, prot: 21.9, fat:  1.2, carbs:  0.0, cat: 'Carni fresche'),
  _TF('Tonno al naturale',            kcal: 103, prot: 23.5, fat: 1.0, carbs: 0.0, cat: 'Prodotti della pesca'),
  _TF('Uovo intero',                  kcal: 128, prot: 12.4, fat:  8.7, carbs:  0.7, cat: 'Uova'),
  // Proteine vegetali
  _TF('Lenticchie, secche',           kcal: 291, prot: 22.7, fat:  1.3, carbs: 46.1, cat: 'Legumi'),
  _TF('Tofu',                         kcal:  76, prot:  8.0, fat:  4.8, carbs:  1.9, cat: 'Legumi'),
  // Latticini
  _TF('Yogurt greco, 0% lipidi',       kcal:  57, prot: 10.0, fat:  0.4, carbs:  4.0, cat: 'Latte e yogurt'),
  _TF('Fiocchi di latte',              kcal:  98, prot: 11.0, fat:  4.3, carbs:  3.3, cat: 'Formaggi e latticini'),
  _TF('Ricotta di vacca',              kcal: 146, prot:  8.8, fat: 10.9, carbs:  3.5, cat: 'Formaggi e latticini'),
  _TF('Skyr, naturale',                kcal:  63, prot: 11.0, fat:  0.2, carbs:  4.0, cat: 'Latte e yogurt'),
  _TF('Latte di vacca, pastorizzato, scremato', kcal: 36, prot: 3.6, fat: 0.1, carbs: 5.0, cat: 'Latte e yogurt'),
  _TF('Fiocchi di formaggio magro',   kcal:  80, prot: 10.0, fat:  1.5, carbs:  5.0, cat: 'Formaggi e latticini'),
  // Cereali
  _TF('Pasta',                         kcal: 353, prot: 11.0, fat:  1.8, carbs: 72.0, cat: 'Cereali e derivati'),
  _TF('Riso Basmati',                  kcal: 361, prot:  7.5, fat:  0.9, carbs: 78.0, cat: 'Cereali e derivati'),
  _TF("Fiocchi d'avena",              kcal: 375, prot: 13.0, fat:  7.0, carbs: 61.0, cat: 'Cereali e derivati'),
  _TF('Gallette di riso',             kcal: 381, prot:  8.0, fat:  3.5, carbs: 78.0, cat: 'Cereali e derivati'),
  _TF('Pane di tipo integrale',       kcal: 224, prot:  7.5, fat:  1.3, carbs: 43.0, cat: 'Cereali e derivati'),
  _TF('Pane integrale',               kcal: 224, prot:  7.5, fat:  1.3, carbs: 43.0, cat: 'Cereali e derivati'),
  _TF('Muesli',                       kcal: 368, prot:  9.9, fat:  7.6, carbs: 64.0, cat: 'Cereali e derivati'),
  _TF('Fette biscottate, integrali',  kcal: 380, prot: 10.0, fat:  5.0, carbs: 72.0, cat: 'Cereali e derivati'),
  _TF('Crackers, integrali',          kcal: 380, prot: 10.0, fat:  8.0, carbs: 64.0, cat: 'Cereali e derivati'),
  // Verdure
  _TF('Spinaci',                      kcal:  23, prot:  2.9, fat:  0.4, carbs:  2.9, cat: 'Verdure e ortaggi'),
  _TF('Zucchine',                     kcal:  17, prot:  1.3, fat:  0.2, carbs:  2.6, cat: 'Verdure e ortaggi'),
  _TF('Broccoli',                     kcal:  34, prot:  2.9, fat:  0.4, carbs:  5.0, cat: 'Verdure e ortaggi'),
  _TF('Pomodori da insalata',          kcal: 18, prot: 0.9, fat: 0.2, carbs: 3.5, cat: 'Verdure e ortaggi'),
  // Grassi
  _TF("Olio extravergine d'oliva",    kcal: 899, prot:  0.0, fat: 99.9, carbs:  0.0, cat: null),
  _TF('Mandorle',                     kcal: 603, prot: 22.0, fat: 53.0, carbs: 19.0, cat: 'Frutta secca a guscio e semi oleaginosi'),
  _TF('Noci',                         kcal: 689, prot: 15.2, fat: 65.2, carbs:  7.0, cat: 'Frutta secca a guscio e semi oleaginosi'),
  _TF('Nocciole',                     kcal: 655, prot: 15.0, fat: 60.8, carbs: 10.6, cat: 'Frutta secca a guscio e semi oleaginosi'),
  _TF('Burro di arachidi',            kcal: 589, prot: 25.0, fat: 50.0, carbs: 16.0, cat: 'Frutta secca a guscio e semi oleaginosi'),
  _TF('Avocado',                      kcal: 160, prot:  2.0, fat: 15.0, carbs:  1.8, cat: null),
  // Frutta (per slot frutta e colazione)
  _TF('Mela',                         kcal:  57, prot:  0.3, fat:  0.1, carbs: 14.9, cat: 'Frutta'),
  _TF('Banana',                       kcal:  89, prot:  1.1, fat:  0.3, carbs: 22.8, cat: 'Frutta'),
  _TF('Pera',                         kcal:  55, prot:  0.4, fat:  0.3, carbs: 13.8, cat: 'Frutta'),
  _TF('Fragole',                      kcal:  30, prot:  0.7, fat:  0.4, carbs:  6.5, cat: 'Frutta'),
  _TF('Kiwi',                        kcal:  55, prot:  1.1, fat:  0.6, carbs: 12.0, cat: 'Frutta'),
  // Proteine salata colazione
  _TF('Bresaola della Valtellina IGP', kcal: 151, prot: 31.4, fat: 2.7, carbs: 0.0, cat: 'Carni trasformate e conservate'),
  _TF('Prosciutto cotto magro',        kcal: 136, prot: 20.2, fat: 5.8, carbs: 1.0, cat: 'Carni trasformate e conservate'),
  _TF('Salmone, affumicato',           kcal: 142, prot: 20.0, fat: 7.0, carbs: 0.0, cat: 'Prodotti della pesca'),
];

// ─────────────────────────────────────────────────────────
// Record helper per i dati di test
// ─────────────────────────────────────────────────────────

class _TF {
  final String nome;
  final double kcal, prot, fat, carbs;
  final String? cat;
  const _TF(this.nome, {required this.kcal, required this.prot, required this.fat, required this.carbs, required this.cat});
}

// ─────────────────────────────────────────────────────────
// Suite
// ─────────────────────────────────────────────────────────

void main() {
  // ── 1. calcolaTdee — funzione pura ───────────────────────

  group('calcolaTdee', () {
    test('uomo 30y 80kg 175cm livello2 Mifflin', () {
      final r = calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm: 175, pesoKg: 80, livello: 2, metodo: 2);
      expect(r, isNotNull);
      expect(r!.bmr, 1749);   // 10*80 + 6.25*175 - 5*30 + 5
      expect(r.tdee, 2711);   // 1749 * 1.55
    });

    test('donna 25y 60kg 165cm livello1 Mifflin', () {
      final r = calcolaTdee(sesso: Sesso.femmina, eta: 25, altezzaCm: 165, pesoKg: 60, livello: 1, metodo: 2);
      expect(r, isNotNull);
      expect(r!.bmr, 1345);   // 10*60 + 6.25*165 - 5*25 - 161 = 600+1031.25-125-161
      expect(r.tdee, 1850);   // raw_bmr(1345.25) * 1.375 = 1849.72 → rounds to 1850
    });

    test('valori invalidi restituiscono null', () {
      expect(calcolaTdee(sesso: Sesso.maschio, eta: 0,  altezzaCm: 175, pesoKg: 80, livello: 2, metodo: 2), isNull);
      expect(calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm:   0, pesoKg: 80, livello: 2, metodo: 2), isNull);
      expect(calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm: 175, pesoKg:  0, livello: 2, metodo: 2), isNull);
    });

    test('Harris-Benedict produce un valore diverso da Mifflin', () {
      final mifflin = calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm: 175, pesoKg: 80, livello: 2, metodo: 2);
      final harris  = calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm: 175, pesoKg: 80, livello: 2, metodo: 3);
      expect(mifflin!.tdee, isNot(harris!.tdee));
    });
  });

  // ── 2. Formula macro — invarianti matematiche ─────────────

  group('macro targets math', () {
    // Replica la logica di PianoService.computeTargets per un profilo fisso
    // e verifica che la somma calorica sia coerente.
    void checkMacros(int obiettivo, int livello) {
      const pesoKg = 80.0;
      const goalMult = [0.80, 1.0, 1.15];
      const protMatrix = [
        [1.4, 1.8, 2.3, 2.6, 3.1],
        [0.8, 1.2, 1.4, 1.8, 2.0],
        [1.6, 1.8, 2.0, 2.2, 2.4],
      ];

      final tdeeResult = calcolaTdee(sesso: Sesso.maschio, eta: 30, altezzaCm: 175, pesoKg: pesoKg, livello: livello, metodo: 2);
      expect(tdeeResult, isNotNull, reason: 'TDEE calcolo fallito');

      final kcal  = (tdeeResult!.tdee * goalMult[obiettivo]).round();
      final prot  = (pesoKg * protMatrix[obiettivo][livello]).round();
      final fat   = (kcal * 0.25 / 9).round();
      final carbs = ((kcal - prot * 4 - fat * 9) / 4).round().clamp(0, 9999);

      expect(prot,  greaterThan(0));
      expect(fat,   greaterThan(0));
      expect(carbs, greaterThanOrEqualTo(0));

      // La somma prot*4 + fat*9 + carbs*4 deve essere entro ±5 kcal dal target
      final kcalSum = prot * 4 + fat * 9 + carbs * 4;
      expect(kcalSum, closeTo(kcal, 5),
          reason: 'obiettivo=$obiettivo livello=$livello: '
              'sum=$kcalSum target=$kcal diff=${(kcalSum - kcal).abs()}');
    }

    for (final obiettivo in [0, 1, 2]) {
      for (final livello in [0, 1, 2, 3, 4]) {
        test('obiettivo=$obiettivo livello=$livello', () => checkMacros(obiettivo, livello));
      }
    }

    test('aumento massa livello0: proteine ≥ 1.6 g/kg', () {
      const protMatrix = [[1.4,1.8,2.3,2.6,3.1],[0.8,1.2,1.4,1.8,2.0],[1.6,1.8,2.0,2.2,2.4]];
      expect(protMatrix[2][0], greaterThanOrEqualTo(1.6));
    });

    test('carbs sempre ≥ 0 con target aggressivo', () {
      // dimagrimento livello4: caso peggiore per carbs residui
      const pesoKg = 100.0;
      final tdee = calcolaTdee(sesso: Sesso.maschio, eta: 25, altezzaCm: 180, pesoKg: pesoKg, livello: 4, metodo: 2)!;
      final kcal  = (tdee.tdee * 0.80).round();
      final prot  = (pesoKg * 3.1).round();
      final fat   = (kcal * 0.25 / 9).round();
      final carbs = ((kcal - prot * 4 - fat * 9) / 4).round().clamp(0, 9999);
      expect(carbs, greaterThanOrEqualTo(0));
    });
  });

  // ── 3. Redistribuzione carbs — invariante delle share ────

  group('carbs redistribution share invariant', () {
    void checkShares(int numPasti) {
      final (colShare, mainShare, snkShare) = switch (numPasti) {
        4 => (0.20, 0.35, 0.10),
        5 => (0.20, 0.30, 0.10),
        _ => (0.20, 0.40, 0.00),
      };
      final snackCount = (numPasti - 3).clamp(0, 2);
      final cenaCarbsFactor  = mainShare * 0.70;
      final pranzoCarbsFactor = 1.0 - colShare - (snackCount.clamp(0, 1) * snkShare) - cenaCarbsFactor;

      final total = colShare
          + pranzoCarbsFactor
          + (snackCount.clamp(0, 1) * snkShare)
          + cenaCarbsFactor;

      expect(total, closeTo(1.0, 1e-9),
          reason: 'numPasti=$numPasti total=${total.toStringAsFixed(6)}');
      expect(pranzoCarbsFactor, greaterThan(0),
          reason: 'pranzo deve avere carbs > 0');
      expect(cenaCarbsFactor, lessThan(mainShare),
          reason: 'cena deve avere meno carbs di mainShare puro');
    }

    test('3 pasti: col + pranzo + cena = 1.0', () => checkShares(3));
    test('4 pasti: col + pranzo + snk + cena = 1.0', () => checkShares(4));
    test('5 pasti: col + pranzo + snk1 + cena = 1.0 (snk2 no carbs)', () => checkShares(5));

    test('pranzo sempre più ricco di carbs della cena', () {
      for (final n in [3, 4, 5]) {
        final (colShare, mainShare, snkShare) = switch (n) {
          4 => (0.20, 0.35, 0.10),
          5 => (0.20, 0.30, 0.10),
          _ => (0.20, 0.40, 0.00),
        };
        final snackCount = (n - 3).clamp(0, 2);
        final cenaCarbsFactor   = mainShare * 0.70;
        final pranzoCarbsFactor = 1.0 - colShare - (snackCount.clamp(0, 1) * snkShare) - cenaCarbsFactor;
        expect(pranzoCarbsFactor, greaterThan(cenaCarbsFactor),
            reason: 'numPasti=$n');
      }
    });
  });

  // ── 4. Integrazione — generaPiano() con Isar reale ───────

  group('generaPiano integration', () {
    late Directory tempDir;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('plico_test_');
      await DatabaseService.instance.initForTest(tempDir.path);
    });

    tearDown(() async {
      await DatabaseService.instance.close();
      tempDir.deleteSync(recursive: true);
    });

    Future<({int kcal, int prot, int fat, int carbs})> targets() async {
      final t = await PianoService.computeTargets();
      expect(t, isNotNull, reason: 'computeTargets ha restituito null');
      return (kcal: t!.$1, prot: t.$2, fat: t.$3, carbs: t.$4);
    }

    test('piano non null con dati minimi', () async {
      await _seedDb();
      final plan = await PianoService.generaPiano();
      expect(plan, isNotNull);
      expect(plan!.pasti, isNotEmpty);
    });

    test('kcal piano entro ±15% del target (3 pasti, mantenimento)', () async {
      await _seedDb(livello: 2, obiettivo: 1, numPasti: 3);
      final t = await targets();
      final plan = await PianoService.generaPiano();
      expect(plan, isNotNull);
      expect(plan!.kcalTotali, closeTo(t.kcal, t.kcal * 0.15),
          reason: 'target=${t.kcal} piano=${plan.kcalTotali.round()}');
    });

    test('proteine entro ±15% del target (3 pasti, mantenimento)', () async {
      await _seedDb(livello: 2, obiettivo: 1, numPasti: 3);
      final t = await targets();
      final plan = await PianoService.generaPiano();
      expect(plan!.proteineTotali, closeTo(t.prot, t.prot * 0.15),
          reason: 'target=${t.prot} piano=${plan.proteineTotali.round()}');
    });

    test('grassi entro ±15% del target (3 pasti, mantenimento)', () async {
      await _seedDb(livello: 2, obiettivo: 1, numPasti: 3);
      final t = await targets();
      final plan = await PianoService.generaPiano();
      expect(plan!.grassiTotali, closeTo(t.fat, t.fat * 0.15),
          reason: 'target=${t.fat} piano=${plan.grassiTotali.round()}');
    });

    test('somma slot kcal = piano.kcalTotali (coerenza interna)', () async {
      await _seedDb();
      final plan = await PianoService.generaPiano();
      expect(plan, isNotNull);

      // La verdura è esclusa dal totale in generaPiano() — replica la stessa logica
      double expectedKcal = 0;
      for (final pasto in plan!.pasti) {
        for (final slot in pasto.slots) {
          if (slot.principale == null || slot.tipo == PianoService.kVerdura) continue;
          expectedKcal += slot.principale!.kcal;
        }
      }
      expect(plan.kcalTotali, closeTo(expectedKcal, 0.1));
    });

    test('4 pasti: kcal entro ±20% (spuntino aggiunto)', () async {
      await _seedDb(livello: 2, obiettivo: 1, numPasti: 4);
      final t = await targets();
      final plan = await PianoService.generaPiano();
      expect(plan, isNotNull);
      expect(plan!.kcalTotali, closeTo(t.kcal, t.kcal * 0.20),
          reason: 'target=${t.kcal} piano=${plan.kcalTotali.round()}');
    });

    test('dimagrimento: kcal piano < kcal mantenimento', () async {
      await _seedDb(livello: 2, obiettivo: 0);
      final planDiet = await PianoService.generaPiano();

      await DatabaseService.instance.close();
      final tempDir2 = Directory.systemTemp.createTempSync('plico_test2_');
      await DatabaseService.instance.initForTest(tempDir2.path);
      await _seedDb(livello: 2, obiettivo: 1);
      final planMaint = await PianoService.generaPiano();
      await DatabaseService.instance.close();
      tempDir2.deleteSync(recursive: true);
      // ri-apri il db originale per tearDown
      await DatabaseService.instance.initForTest(tempDir.path);

      expect(planDiet!.kcalTotali, lessThan(planMaint!.kcalTotali));
    });

    test('aumento massa: kcal piano > kcal mantenimento', () async {
      await _seedDb(livello: 2, obiettivo: 2);
      final planSurplus = await PianoService.generaPiano();

      await DatabaseService.instance.close();
      final tempDir2 = Directory.systemTemp.createTempSync('plico_test3_');
      await DatabaseService.instance.initForTest(tempDir2.path);
      await _seedDb(livello: 2, obiettivo: 1);
      final planMaint = await PianoService.generaPiano();
      await DatabaseService.instance.close();
      tempDir2.deleteSync(recursive: true);
      await DatabaseService.instance.initForTest(tempDir.path);

      expect(planSurplus!.kcalTotali, greaterThan(planMaint!.kcalTotali));
    });
  });
}

// ─────────────────────────────────────────────────────────
// Estensione DatabaseService per seed dei cibi di test
// ─────────────────────────────────────────────────────────

extension _DbTestExtension on DatabaseService {
  Future<void> seedTestFoods(List<_TF> foods) async {
    final items = foods.map((f) {
      final item = FoodItem()
        ..nome = f.nome
        ..kcalPer100g = f.kcal
        ..proteinPer100g = f.prot
        ..fatPer100g = f.fat
        ..carbsPer100g = f.carbs
        ..categoria = f.cat
        ..creaCode = f.nome.hashCode.toString(); // non-null → incluso in getAllCreaFoods
      return item;
    }).toList();
    await saveFoodItemsBatch(items);
  }
}
