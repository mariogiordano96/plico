import 'package:isar/isar.dart';

part 'achievement.g.dart';

enum AchievementType {
  firstKgLost,
  streak7,
  days30Logged,
  weekOnTarget,
  firstWorkout,
  workoutStreak7,
  newWorkoutPr,
  workoutSessions10,
  workoutSessions50,
  streak30,
  streak100,
  workoutStreak30,
  workoutStreak100,
}

@collection
class Achievement {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String type; // AchievementType.name

  late DateTime unlockedAt;
}
