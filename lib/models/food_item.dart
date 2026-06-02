import 'package:isar/isar.dart';

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

  String? offCode; // Open Food Facts product code (null per alimenti custom)
  bool isCustom = false;
  bool isFavorite = false;
}
