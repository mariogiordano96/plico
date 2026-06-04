import 'package:isar/isar.dart';

part 'user_food_preferences.g.dart';

@collection
class UserFoodPreferences {
  Id id = 1;
  List<String> restrizioni = [];
  List<int> foodLikedIds = [];
  int numPasti = 3;
  bool haSpuntinoPostWo = false;
  bool questionarioCompletato = false;
}
