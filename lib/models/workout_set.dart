import 'package:isar/isar.dart';

part 'workout_set.g.dart';

@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
  int? rpe; // sforzo percepito 1-10 (opzionale, Fase 9)
  bool isWarmup = false; // serie di riscaldamento: esclusa da PR/volume/overload (Fase 15)

  // Fase 23: true solo quando l'utente conferma esplicitamente la serie in
  // modalità guidata (tocca la spunta) — reps/weightKg possono già essere
  // valorizzati prima (target della scheda o suggerimento di overload), senza
  // che la serie sia stata davvero eseguita.
  bool confirmed = false;
}
