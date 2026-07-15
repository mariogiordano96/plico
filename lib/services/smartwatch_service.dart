import 'dart:io' show Platform;

import 'package:health/health.dart';

/// Esito della richiesta di autorizzazione, oltre al semplice bool: distingue
/// il rifiuto dell'utente dal caso "Health Connect non installato" (solo
/// Android 9-13, vedi docs/integrazione_smartwatch.md sezione 7), che la UI
/// dovrà gestire diversamente (link allo store invece di un retry).
enum SmartwatchAuthorizationResult { granted, denied, unavailable }

/// Sessione di allenamento letta da HealthKit/Health Connect, con FC media e
/// kcal attive nella stessa finestra oraria — non ancora un `WorkoutExercise`
/// (mapping e persistenza sono Fase 3, vedi docs/integrazione_smartwatch.md).
class SmartwatchWorkoutSession {
  final HealthWorkoutActivityType activityType;
  final DateTime start;
  final DateTime end;
  final int? energyBurnedKcal;
  final double? avgHeartRateBpm;
  final String sourceName;

  const SmartwatchWorkoutSession({
    required this.activityType,
    required this.start,
    required this.end,
    this.energyBurnedKcal,
    this.avgHeartRateBpm,
    required this.sourceName,
  });

  Duration get duration => end.difference(start);
}

/// Legge dati di allenamento da Apple HealthKit / Google Health Connect
/// tramite il package `health`. Solo lettura, vedi sezione 6 del documento
/// di analisi funzionale.
class SmartwatchService {
  static final SmartwatchService instance = SmartwatchService._();
  SmartwatchService._();

  final Health _health = Health();
  bool _configured = false;

  /// HRV: HealthKit espone SDNN, Health Connect solo RMSSD (vedi
  /// docs/integrazione_smartwatch.md sezione 5.3).
  static HealthDataType get hrvType =>
      Platform.isIOS ? HealthDataType.HEART_RATE_VARIABILITY_SDNN : HealthDataType.HEART_RATE_VARIABILITY_RMSSD;

  /// Sonno: SLEEP_ASLEEP su iOS è il tempo di sonno effettivo; Health Connect
  /// non lo distingue dal tempo a letto, il dato più vicino è la sessione
  /// intera (`SleepSessionRecord`).
  static HealthDataType get sleepType =>
      Platform.isIOS ? HealthDataType.SLEEP_ASLEEP : HealthDataType.SLEEP_SESSION;

  /// Un'unica richiesta di autorizzazione copre sia l'import allenamenti sia
  /// la dashboard Wellness di sola lettura (Fase 6): un solo "Collega Salute"
  /// invece di due permessi separati per lo stesso hub.
  static List<HealthDataType> get _types => [
        HealthDataType.WORKOUT,
        HealthDataType.HEART_RATE,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.RESTING_HEART_RATE,
        HealthDataType.STEPS,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
        hrvType,
        sleepType,
      ];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Su Android, false se Health Connect non è installato (serve reindirizzare
  /// allo store, vedi [installHealthConnect]). Sempre true su iOS.
  Future<bool> isAvailable() async {
    await _ensureConfigured();
    return _health.isHealthConnectAvailable();
  }

  /// Apre lo store per installare Health Connect. No-op su iOS.
  Future<void> installHealthConnect() => _health.installHealthConnect();

  Future<bool> hasPermissions() async {
    await _ensureConfigured();
    if (!await isAvailable()) return false;
    return await _health.hasPermissions(_types) ?? false;
  }

  Future<SmartwatchAuthorizationResult> requestAuthorization() async {
    await _ensureConfigured();
    if (!await isAvailable()) return SmartwatchAuthorizationResult.unavailable;
    try {
      final granted = await _health.requestAuthorization(_types);
      return granted
          ? SmartwatchAuthorizationResult.granted
          : SmartwatchAuthorizationResult.denied;
    } catch (_) {
      return SmartwatchAuthorizationResult.denied;
    }
  }

  /// Sessioni di allenamento nell'intervallo `[start, end]`, ordinate per
  /// orario di inizio. `energyBurnedKcal` preferisce il totale riportato
  /// direttamente dalla sessione; se assente (tipico di Health Connect, che
  /// non lo allega all'`ExerciseSessionRecord`) somma i campioni di kcal
  /// attive ricadenti nella stessa finestra oraria.
  Future<List<SmartwatchWorkoutSession>> fetchWorkoutSessions({
    required DateTime start,
    required DateTime end,
  }) async {
    await _ensureConfigured();

    final workoutPoints = await _health.getHealthDataFromTypes(
      types: const [HealthDataType.WORKOUT],
      startTime: start,
      endTime: end,
    );
    if (workoutPoints.isEmpty) return [];

    final heartRatePoints = await _health.getHealthDataFromTypes(
      types: const [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );
    final activeEnergyPoints = await _health.getHealthDataFromTypes(
      types: const [HealthDataType.ACTIVE_ENERGY_BURNED],
      startTime: start,
      endTime: end,
    );

    final sessions = <SmartwatchWorkoutSession>[];
    for (final point in workoutPoints) {
      final value = point.value;
      if (value is! WorkoutHealthValue) continue;

      final energyFromWorkout = value.totalEnergyBurned;
      final energyKcal = (energyFromWorkout != null && energyFromWorkout > 0)
          ? energyFromWorkout
          : _sumNumericValuesInRange(activeEnergyPoints, point.dateFrom, point.dateTo)
              ?.round();

      sessions.add(SmartwatchWorkoutSession(
        activityType: value.workoutActivityType,
        start: point.dateFrom,
        end: point.dateTo,
        energyBurnedKcal: energyKcal,
        avgHeartRateBpm: _averageNumericValuesInRange(heartRatePoints, point.dateFrom, point.dateTo),
        sourceName: point.sourceName,
      ));
    }

    sessions.sort((a, b) => a.start.compareTo(b.start));
    return sessions;
  }

  double? _sumNumericValuesInRange(List<HealthDataPoint> points, DateTime from, DateTime to) {
    final values = _numericValuesInRange(points, from, to);
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b);
  }

  double? _averageNumericValuesInRange(List<HealthDataPoint> points, DateTime from, DateTime to) {
    final values = _numericValuesInRange(points, from, to);
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  List<double> _numericValuesInRange(List<HealthDataPoint> points, DateTime from, DateTime to) {
    return points
        .where((p) => !p.dateFrom.isBefore(from) && !p.dateTo.isAfter(to))
        .map((p) => p.value)
        .whereType<NumericHealthValue>()
        .map((v) => v.numericValue.toDouble())
        .toList();
  }
}
