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

  // Metadati CREA
  String? creaCode;
  String? categoria;
  String? nomeInglese;
  String? imageUrl;
  double? porzione;
  double? parteCommestibile;

  // Dati nutrizionali completi (presenti solo per alimenti CREA)
  NutrizioneCompleta? nutrizione;
}
