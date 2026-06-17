import 'package:isar/isar.dart';

part 'meal_entry.g.dart';

@embedded
class MealEntry {
  String foodNome = '';
  String? foodBrand;
  double kcalPer100g = 0;
  double proteinPer100g = 0;
  double fatPer100g = 0;
  double carbsPer100g = 0;
  double quantitaG = 100;
  int pastoTipo = 1; // PastoTipo index: 0=colazione 1=pranzo 2=cena 3=spuntino
  DateTime? orarioInserimento;

  double get kcal => kcalPer100g * quantitaG / 100;
  double get proteinG => proteinPer100g * quantitaG / 100;
  double get fatG => fatPer100g * quantitaG / 100;
  double get carbsG => carbsPer100g * quantitaG / 100;
}
