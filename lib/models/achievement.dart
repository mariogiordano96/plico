import 'package:isar/isar.dart';

part 'achievement.g.dart';

enum AchievementType { firstKgLost, streak7, days30Logged, weekOnTarget }

@collection
class Achievement {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String type; // AchievementType.name

  late DateTime unlockedAt;
}
