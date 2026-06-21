import 'package:isar/isar.dart';

part 'workout_set.g.dart';

@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
  int? rpe; // sforzo percepito 1-10 (opzionale, Fase 9)
  bool isWarmup = false; // serie di riscaldamento: esclusa da PR/volume/overload (Fase 15)
}
