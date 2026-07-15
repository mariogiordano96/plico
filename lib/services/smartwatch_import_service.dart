import 'dart:io' show Platform;

import 'package:health/health.dart';

import '../models/workout_exercise.dart';
import 'calorie_estimation_service.dart';
import 'database_service.dart';
import 'smartwatch_service.dart';

/// Attività "pesi" secondo `HealthWorkoutActivityType`: nessun sensore misura
/// il carico, quindi l'entry importata ha `sets` vuoto ma non è cardio (vedi
/// `WorkoutExercise.importedIsStrength`).
const _strengthActivityTypes = {
  HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
  HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
  HealthWorkoutActivityType.STRENGTH_TRAINING,
  HealthWorkoutActivityType.WEIGHTLIFTING,
};

/// Attività "cardio" mappate a un `exerciseId`/nome stabili — non catalogo
/// (`ExerciseDefinition`), sintetici e prefissati `watch_` per non collidere
/// con id reali, sufficienti per storico/PR/streak che raggruppano per id.
/// Le attività non presenti qui (yoga, sport di squadra...) sono fuori scope
/// (vedi docs/integrazione_smartwatch.md sezione 1) e vengono scartate.
const _cardioActivityNames = <HealthWorkoutActivityType, (String, String)>{
  HealthWorkoutActivityType.RUNNING: ('watch_running', 'Corsa'),
  HealthWorkoutActivityType.RUNNING_TREADMILL: ('watch_running_treadmill', 'Corsa (tapis roulant)'),
  HealthWorkoutActivityType.WALKING: ('watch_walking', 'Camminata'),
  HealthWorkoutActivityType.WALKING_TREADMILL: ('watch_walking_treadmill', 'Camminata (tapis roulant)'),
  HealthWorkoutActivityType.HIKING: ('watch_hiking', 'Trekking'),
  HealthWorkoutActivityType.BIKING: ('watch_biking', 'Ciclismo'),
  HealthWorkoutActivityType.BIKING_STATIONARY: ('watch_biking_stationary', 'Ciclismo indoor'),
  HealthWorkoutActivityType.SWIMMING: ('watch_swimming', 'Nuoto'),
  HealthWorkoutActivityType.SWIMMING_POOL: ('watch_swimming', 'Nuoto'),
  HealthWorkoutActivityType.SWIMMING_OPEN_WATER: ('watch_swimming_open_water', 'Nuoto in acque libere'),
  HealthWorkoutActivityType.ELLIPTICAL: ('watch_elliptical', 'Ellittica'),
  HealthWorkoutActivityType.ROWING: ('watch_rowing', 'Vogatore'),
  HealthWorkoutActivityType.ROWING_MACHINE: ('watch_rowing', 'Vogatore'),
  HealthWorkoutActivityType.STAIR_CLIMBING: ('watch_stair_climbing', 'Scale'),
  HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE: ('watch_stair_climbing', 'Scale'),
  HealthWorkoutActivityType.JUMP_ROPE: ('watch_jump_rope', 'Corda'),
};

const _strengthExerciseId = 'watch_strength';
const _strengthExerciseName = 'Allenamento pesi';

/// Converte le sessioni lette da [SmartwatchService] in [WorkoutExercise] e
/// le persiste, con deduplica. Vedi docs/integrazione_smartwatch.md sezione 6.
class SmartwatchImportService {
  static final SmartwatchImportService instance = SmartwatchImportService._();
  SmartwatchImportService._();

  static const _sessionMatchTolerance = Duration(minutes: 5);
  // Le entry manuali non registrano l'orario di inizio (solo il giorno),
  // quindi il confronto con l'orario della sessione watch non è possibile:
  // come proxy si usa la durata, tollerante a un margine di registrazione
  // manuale impreciso (vedi nota "delicato da testare" in sezione 9).
  static const _manualDurationToleranceRatio = 0.15;

  /// Importa le sessioni nell'intervallo indicato, saltando quelle già
  /// importate in precedenza (stessa finestra oraria già presente) e i tipi
  /// di attività fuori scope. Ritorna il numero di sessioni importate.
  Future<int> importWorkoutSessions({required DateTime start, required DateTime end}) async {
    final sessions = await SmartwatchService.instance.fetchWorkoutSessions(start: start, end: end);
    if (sessions.isEmpty) return 0;

    final bodySnapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final bodyWeightKg = bodySnapshot?.pesoKg;

    var imported = 0;
    for (final session in sessions) {
      final mapped = _mapSession(session, bodyWeightKg);
      if (mapped == null) continue;

      final existing = await DatabaseService.instance.getWorkoutExercisesForDay(session.start);

      final alreadyImported = existing.any((e) =>
          e.sourceStartTime != null &&
          (e.sourceStartTime!.difference(session.start)).abs() <= _sessionMatchTolerance);
      if (alreadyImported) continue;

      if (mapped.isCardio && _duplicatesManualCardioLog(mapped, existing)) continue;

      await DatabaseService.instance.addWorkoutExercise(session.start, mapped);
      imported++;
    }
    return imported;
  }

  /// True se tra [existing] c'è già un log manuale cardio con durata
  /// compatibile (stesso giorno, entrambi impliciti dato che `existing` è già
  /// filtrato per giorno) — proxy per "stessa corsa già loggata a mano".
  bool _duplicatesManualCardioLog(WorkoutExercise imported, List<WorkoutExercise> existing) {
    final importedDuration = imported.durationSeconds;
    if (importedDuration == null) return false;

    return existing.any((e) {
      if (e.source != null || !e.isCardio) return false;
      final d = e.durationSeconds;
      if (d == null) return false;
      final diff = (d - importedDuration).abs();
      return diff <= importedDuration * _manualDurationToleranceRatio;
    });
  }

  WorkoutExercise? _mapSession(SmartwatchWorkoutSession session, double? bodyWeightKg) {
    final cardio = _cardioActivityNames[session.activityType];
    final isStrength = _strengthActivityTypes.contains(session.activityType);
    if (cardio == null && !isStrength) return null;

    final source = Platform.isIOS ? WorkoutSource.healthKit : WorkoutSource.healthConnect;
    final (exerciseId, exerciseName) = cardio ?? (_strengthExerciseId, _strengthExerciseName);
    final durationSeconds = session.duration.inSeconds;

    // Il watch a volte riporta solo la frequenza cardiaca senza le kcal
    // attive (es. sensore ottico senza stima energetica): invece di scartare
    // la sessione, si stima con lo stesso MET fisso usato per il log
    // manuale, dalla durata reale (vedi docs/integrazione_smartwatch.md,
    // Fase 5). Nessun MET quando le kcal sono reali: `met` resta null.
    final hasRealKcal = session.energyBurnedKcal != null;
    final estimatedKcal = hasRealKcal
        ? session.energyBurnedKcal
        : (isStrength
            ? CalorieEstimationService.estimateStrengthKcalFromDuration(
                durationSeconds: durationSeconds, bodyWeightKg: bodyWeightKg)
            : CalorieEstimationService.estimateCardioKcal(
                exerciseId: exerciseId, durationSeconds: durationSeconds, bodyWeightKg: bodyWeightKg));
    final met = (!hasRealKcal && !isStrength)
        ? CalorieEstimationService.metForCardioExercise(exerciseId).round()
        : null;

    return WorkoutExercise()
      ..exerciseId = exerciseId
      ..exerciseName = exerciseName
      ..date = session.start
      ..durationSeconds = durationSeconds
      ..estimatedKcal = estimatedKcal
      ..met = met
      ..avgHeartRate = session.avgHeartRateBpm
      ..source = source.name
      ..sourceStartTime = session.start
      ..sourceEndTime = session.end
      ..importedIsStrength = isStrength
      // Una sessione watch rappresenta un allenamento già svolto, non un
      // target da eseguire: senza questo la modalità guidata la offrirebbe
      // come step cardio ancora da confermare (cardioConfirmed default false).
      ..cardioConfirmed = !isStrength
      ..sets = [];
  }
}
