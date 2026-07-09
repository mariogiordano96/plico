import 'package:isar/isar.dart';

import 'nutrizione_completa.dart';

part 'food_item.g.dart';

@collection
class FoodItem {
  Id id = Isar.autoIncrement;

  late String nome;
  String? brand;
  double kcalPer100g = 0;
  double proteinPer100g = 0;
  double fatPer100g = 0;
  double carbsPer100g = 0;

  String? offCode;
  bool isCustom = false;
  bool isFavorite = false;
  DateTime? lastUsedAt;

  // Metadati CREA
  String? creaCode;
  String? categoria;
  String? nomeInglese;
  String? imageUrl;
  double? porzione;
  double? parteCommestibile;

  // Dati nutrizionali completi (presenti solo per alimenti CREA)
  NutrizioneCompleta? nutrizione;

  /// Nome da mostrare per la lingua corrente. Gli alimenti CREA hanno solo
  /// `nome` (italiano) e `nomeInglese` (nome del dataset originale, unica
  /// alternativa disponibile) — non esiste una traduzione curata per le
  /// altre lingue, quindi si ricade su `nome`. Gli alimenti custom
  /// (`isCustom`) non hanno `nomeInglese` e restano nel nome scritto
  /// dall'utente, coerente con `docs/internazionalizzazione.md`.
  String localizedName(String languageCode) {
    if (languageCode == 'en' && nomeInglese != null && nomeInglese!.isNotEmpty) {
      return nomeInglese!;
    }
    return nome;
  }
}
