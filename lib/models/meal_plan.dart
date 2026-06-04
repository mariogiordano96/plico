import 'package:isar/isar.dart';

part 'meal_plan.g.dart';

@embedded
class PlanFood {
  String nome = '';
  int foodItemId = 0;
  double quantitaG = 0;
  double kcal = 0;
  double proteine = 0;
  double grassi = 0;
  double carboidrati = 0;
}

@embedded
class PlanSlot {
  int tipo = 0; // 0=proteina 1=carbo 2=verdura 3=grasso 4=extra
  PlanFood? principale;
  List<PlanFood> alternative = [];
}

@embedded
class PlanMeal {
  int tipo = 0; // 0=colazione 1=pranzo 2=cena 3=spuntino 4=spuntino_postWo
  List<PlanSlot> slots = [];
}

@collection
class MealPlan {
  Id id = 1;
  DateTime dataCreazione = DateTime.fromMillisecondsSinceEpoch(0);
  List<PlanMeal> pasti = [];
  double kcalTotali = 0;
  double proteineTotali = 0;
  double grassiTotali = 0;
  double carbsTotali = 0;
  bool obsoleto = false;
  int livelloAtGenerazione = 2;
  int obiettivoAtGenerazione = 1;
}
