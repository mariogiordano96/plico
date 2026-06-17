import 'package:isar/isar.dart';

import 'meal_entry.dart';

part 'meal_combo.g.dart';

@collection
class MealCombo {
  Id id = Isar.autoIncrement;

  late String nome;
  int pastoTipo = 0;
  List<MealEntry> items = [];
  DateTime createdAt = DateTime.now();
}
