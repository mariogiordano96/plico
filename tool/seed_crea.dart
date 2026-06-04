// Standalone Dart script: converte crea_food_composition_tables.csv in assets/data/crea_seed.json
// Eseguire dalla root del progetto: dart tool/seed_crea.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  final csvFile = File('crea_food_composition_tables.csv');
  if (!csvFile.existsSync()) {
    print('File non trovato: crea_food_composition_tables.csv');
    exit(1);
  }

  final lines = csvFile.readAsLinesSync();
  final headers = parseLine(lines[0]);

  final foods = <Map<String, dynamic>>[];

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    final cols = parseLine(line);
    if (cols.length < headers.length) continue;

    final row = <String, String>{};
    for (var j = 0; j < headers.length; j++) {
      row[headers[j]] = j < cols.length ? cols[j].trim() : '';
    }

    final food = _buildFood(row);
    if (food != null) foods.add(food);
  }

  final jsonStr = const JsonEncoder.withIndent('  ').convert(foods);
  File('assets/data/crea_seed.json').writeAsStringSync(jsonStr);
  print('Generati ${foods.length} alimenti -> assets/data/crea_seed.json');
}

Map<String, dynamic>? _buildFood(Map<String, String> r) {
  final nome = r['name'] ?? '';
  if (nome.isEmpty) return null;

  final kcal = _num(r['energy_kcal']);
  final prot = _num(r['proteins']);
  final grassi = _num(r['lipids']);
  final carbs = _num(r['available_carbohydrates']);

  final food = <String, dynamic>{
    'nome': nome,
    'creaCode': r['food_code'] ?? '',
    'categoria': r['category'] ?? '',
    'nomeInglese': r['english_name'] ?? '',
    'imageUrl': r['image'] ?? '',
    'porzione': _num(r['portion']),
    'parteCommestibile': _num(r['edible_part']),
    'kcalPer100g': kcal ?? 0.0,
    'proteinPer100g': prot ?? 0.0,
    'fatPer100g': grassi ?? 0.0,
    'carbsPer100g': carbs ?? 0.0,
  };

  // Composizione prossimale
  _addIfSet(food, 'acqua', _num(r['water']));
  _addIfSet(food, 'energiaKj', _num(r['energy_kj']));
  _addIfSet(food, 'colesterolo', _num(r['cholesterol']));
  _addIfSet(food, 'amido', _num(r['starch']));
  _addIfSet(food, 'zuccheriSolubili', _num(r['soluble_sugars']));
  _addIfSet(food, 'alcol', _num(r['alcohol']));
  _addIfSet(food, 'fibreTotali', _num(r['total_fiber']));
  _addIfSet(food, 'fibreSolubili', _num(r['soluble_fiber']));
  _addIfSet(food, 'fibreInsolubili', _num(r['insoluble_fiber']));

  // Zuccheri specifici
  _addIfSet(food, 'saccarosio', _num(r['sucrose']));
  _addIfSet(food, 'glucosio', _num(r['glucose']));
  _addIfSet(food, 'fruttosio', _num(r['fructose']));
  _addIfSet(food, 'lattosio', _num(r['lactose']));
  _addIfSet(food, 'galattosio', _num(r['galactose']));
  _addIfSet(food, 'maltosio', _num(r['maltose']));
  _addIfSet(food, 'maltotriosio', _num(r['maltotriosium']));
  _addIfSet(food, 'raffinosio', _num(r['raffinose']));

  // Minerali
  _addIfSet(food, 'fluoro', _num(r['fluorine']));
  _addIfSet(food, 'sodio', _num(r['sodium']));
  _addIfSet(food, 'magnesio', _num(r['magnesium']));
  _addIfSet(food, 'fosforo', _num(r['phosphorus']));
  _addIfSet(food, 'cloro', _num(r['chlorine']));
  _addIfSet(food, 'potassio', _num(r['potassium']));
  _addIfSet(food, 'calcio', _num(r['calcium']));
  _addIfSet(food, 'cromo', _num(r['chromium']));
  _addIfSet(food, 'manganese', _num(r['manganese']));
  _addIfSet(food, 'ferro', _num(r['iron']));
  _addIfSet(food, 'nichel', _num(r['nickel']));
  _addIfSet(food, 'rame', _num(r['copper']));
  _addIfSet(food, 'zinco', _num(r['zinc']));
  _addIfSet(food, 'selenio', _num(r['selenium']));
  _addIfSet(food, 'iodio', _num(r['iodine']));

  // Carotenoidi
  _addIfSet(food, 'carotenoidiTotali', _num(r['total_carotenoids']));
  _addIfSet(food, 'alfaCarotene', _num(r['alpha_carotene']));
  _addIfSet(food, 'betaCarotene', _num(r['beta_carotene']));
  _addIfSet(food, 'criptoxantina', _num(r['cryptoxanthin']));
  _addIfSet(food, 'licopene', _num(r['lycopene']));
  _addIfSet(food, 'luteina', _num(r['lutein']));
  _addIfSet(food, 'retinolo', _num(r['retinol']));
  _addIfSet(food, 'zeaxantina', _num(r['zeaxanthin']));

  // Vitamine
  _addIfSet(food, 'vitaminaA', _num(r['vitamin_a_retinol_equivalent']));
  _addIfSet(food, 'tiamina', _num(r['thiamine']));
  _addIfSet(food, 'riboflavina', _num(r['riboflavin']));
  _addIfSet(food, 'niacina', _num(r['niacin']));
  _addIfSet(food, 'acidoPantotenico', _num(r['pantothenic_acid']));
  _addIfSet(food, 'vitaminaB6', _num(r['vitamin_b6']));
  _addIfSet(food, 'biotina', _num(r['biotin']));
  _addIfSet(food, 'folati', _num(r['folate']));
  _addIfSet(food, 'vitaminaB12', _num(r['vitamin_b12']));
  _addIfSet(food, 'vitaminaC', _num(r['vitamin_c']));
  _addIfSet(food, 'vitaminaD', _num(r['vitamin_d']));
  _addIfSet(food, 'vitaminaE', _num(r['vitamin_e']));
  _addIfSet(food, 'alfaTocoferolo', _num(r['alpha_tocopherol']));
  _addIfSet(food, 'betaTocoferolo', _num(r['beta_tocopherol']));
  _addIfSet(food, 'gammaTocoferolo', _num(r['gamma_tocopherol']));
  _addIfSet(food, 'deltaTocoferolo', _num(r['delta_tocopherol']));
  _addIfSet(food, 'vitaminaK', _num(r['vitamin_k']));

  // Acidi grassi - totali
  _addIfSet(food, 'acidiGrassiSaturi', _num(r['Saturated_fatty_acids']));
  _addIfSet(food, 'acidiGrassiMonoinsaturi', _num(r['monounsaturated_fatty_acids']));
  _addIfSet(food, 'acidiGrassiPolinsaturi', _num(r['polyunsaturated_fatty_acids']));
  _addIfSet(food, 'rapportoPolinsaturiSaturi', _num(r['polyunsaturated_saturated']));

  // Acidi grassi saturi specifici
  _addIfSet(food, 'acidiGrassiC4C10', _num(r['C4:0-C10:0']));
  _addIfSet(food, 'acidoButirrico', _num(r['C4:0_butyric_acid']));
  _addIfSet(food, 'acidoCapronico', _num(r['C6:0_capronic_acid']));
  _addIfSet(food, 'acidoEnanterico', _num(r['C7:0_enanthic_acid']));
  _addIfSet(food, 'acidoCaprilico', _num(r['C8:0_caprylic_acid']));
  _addIfSet(food, 'acidoCaprinico', _num(r['C10:0_caprinic_acid']));
  _addIfSet(food, 'acidoLaurico', _num(r['C12:0_lauric_acid']));
  _addIfSet(food, 'acidoTridecanoico', _num(r['C13:0_tridecanoic_acid']));
  _addIfSet(food, 'acidoMiristico', _num(r['C14:0_myristic_acid']));
  _addIfSet(food, 'acidoPentadecanoico', _num(r['C15:0_pentadecanoic_acid']));
  _addIfSet(food, 'acidoPalmitico', _num(r['C16:0_palmitic_acid']));
  _addIfSet(food, 'acidoEptadecanoico', _num(r['C17:0_heptadecanoic_acid']));
  _addIfSet(food, 'acidoStearico', _num(r['C18:0_stearic_acid']));
  _addIfSet(food, 'acidoArachidico', _num(r['C20:0_arachidic_acid']));
  _addIfSet(food, 'acidoBenico', _num(r['C22:0_behenic_acid']));
  _addIfSet(food, 'acidoLignocerico', _num(r['C24:0_lignoceric_acid']));

  // Acidi grassi monoinsaturi specifici
  _addIfSet(food, 'acidoCaproleico', _num(r['C10:1_caproleic_acid']));
  _addIfSet(food, 'acidoLauroleico', _num(r['C12:1_lauroleic_acid']));
  _addIfSet(food, 'acidoTridecenoico', _num(r['C13:1_tridecenoic_acid']));
  _addIfSet(food, 'acidoMiristoleico', _num(r['C14:1_myristoleic_acid']));
  _addIfSet(food, 'acidoPentadecenoico', _num(r['C15:1_pentadecenoic_acid']));
  _addIfSet(food, 'acidoPalmitoleico', _num(r['C16:1 palmitoleic_acid']));
  _addIfSet(food, 'acidoEptadecenoicoMono', _num(r['C17:1_heptadecenoic_acid']));
  _addIfSet(food, 'acidoOleico', _num(r['C18:1_oleic_acid']));
  _addIfSet(food, 'acidoEicosenoico', _num(r['C20:1_eicosenoic_acid']));
  _addIfSet(food, 'acidoErucico', _num(r['C22:1_erucic_acid']));

  // Acidi grassi polinsaturi specifici
  _addIfSet(food, 'acidoLinoleico', _num(r['C18:2_linoleic_acid']));
  _addIfSet(food, 'acidoLinolenico', _num(r['C18:3_linolenic_acid']));
  _addIfSet(food, 'acidoArachidonico', _num(r['C20:4_arachidonic_acid']));
  _addIfSet(food, 'epa', _num(r['C20:5_eicosapentaenoic_acid_EPA']));
  _addIfSet(food, 'dha', _num(r['C22:6_docosahexaenoic_acid_DHA']));

  // Aminoacidi
  _addIfSet(food, 'alanina', _num(r['alanine']));
  _addIfSet(food, 'cisteina', _num(r['cystine']));
  _addIfSet(food, 'acidoAspartico', _num(r['aspartic_acid']));
  _addIfSet(food, 'acidoGlutammico', _num(r['glutamic_acid']));
  _addIfSet(food, 'fenilalanina', _num(r['phenylalanine']));
  _addIfSet(food, 'glicina', _num(r['glycine']));
  _addIfSet(food, 'istidina', _num(r['histidine']));
  _addIfSet(food, 'isoleucina', _num(r['isoleucine']));
  _addIfSet(food, 'lisina', _num(r['lysine']));
  _addIfSet(food, 'leucina', _num(r['leucine']));
  _addIfSet(food, 'metionina', _num(r['methionine']));
  _addIfSet(food, 'prolina', _num(r['proline']));
  _addIfSet(food, 'arginina', _num(r['arginine']));
  _addIfSet(food, 'serina', _num(r['serine']));
  _addIfSet(food, 'treonina', _num(r['threonine']));
  _addIfSet(food, 'valina', _num(r['valine']));
  _addIfSet(food, 'triptofano', _num(r['tryptophan']));
  _addIfSet(food, 'tirosina', _num(r['tyrosine']));
  _addIfSet(food, 'indiceChimico', _num(r['chemical_index']));

  final aminoLimitante = r['limiting_amino_acid'] ?? '';
  if (aminoLimitante.isNotEmpty) {
    food['aminoacidoLimitante'] = aminoLimitante;
  }

  // Polifenoli e altri composti bioattivi
  _addIfSet(food, 'acidoCaffeico', _num(r['caffeic_acid']));
  _addIfSet(food, 'acidoCitrico', _num(r['citric_acid']));
  _addIfSet(food, 'acidoFitico', _num(r['phytic_acid']));
  _addIfSet(food, 'acidoMalico', _num(r['malic_acid']));
  _addIfSet(food, 'apigenina', _num(r['apigenin']));
  _addIfSet(food, 'attivitaAntiossidante', _num(r['antioxidant_activity']));
  _addIfSet(food, 'campferolo', _num(r['campkerol']));
  _addIfSet(food, 'fitosteroli', _num(r['phytosterols']));
  _addIfSet(food, 'fruttooligosaccaridi', _num(r['fructo-oligosaccharides']));
  _addIfSet(food, 'miricetina', _num(r['myricetin']));
  _addIfSet(food, 'polifenoli', _num(r['polyphenols']));
  _addIfSet(food, 'quercetina', _num(r['quercetin']));
  _addIfSet(food, 'violaxantina', _num(r['violaxanthin']));

  return food;
}

double? _num(String? val) {
  if (val == null || val.trim().isEmpty || val.trim() == '0') return null;
  return double.tryParse(val.trim());
}

void _addIfSet(Map<String, dynamic> map, String key, double? val) {
  if (val != null) map[key] = val;
}

List<String> parseLine(String line) {
  final result = <String>[];
  var inQuotes = false;
  final current = StringBuffer();

  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
    } else if (ch == ',' && !inQuotes) {
      result.add(current.toString());
      current.clear();
    } else {
      current.write(ch);
    }
  }
  result.add(current.toString());
  return result;
}
