import 'package:isar/isar.dart';
import 'meal_entry.dart';

part 'daily_log.g.dart';

@collection
class DailyLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime data; // normalizzato a mezzanotte

  List<MealEntry> entries = [];

  double get kcalTotali =>
      entries.fold(0, (sum, e) => sum + e.kcal);
  double get proteinTotali =>
      entries.fold(0, (sum, e) => sum + e.proteinG);
  double get fatTotali =>
      entries.fold(0, (sum, e) => sum + e.fatG);
  double get carbsTotali =>
      entries.fold(0, (sum, e) => sum + e.carbsG);
}
