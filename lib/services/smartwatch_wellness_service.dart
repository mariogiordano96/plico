import 'package:health/health.dart';

import 'smartwatch_service.dart';

/// Un valore aggregato per giorno di calendario — sonno (ore), FC a riposo,
/// HRV, passi, kcal totali (docs/integrazione_smartwatch.md sezione 5.3).
class DailyMetric {
  final DateTime day;
  final double value;
  const DailyMetric(this.day, this.value);
}

/// Legge le metriche wellness di sola lettura da HealthKit/Health Connect —
/// nessuna persistenza (i dati restano sull'hub, letti al volo ogni volta
/// che la dashboard viene aperta), nessun impatto su TDEE/kcal/target
/// esistenti (vedi docs/integrazione_smartwatch.md sezione 5.3). Riusa il
/// permesso già concesso a [SmartwatchService] — stesso "Collega Salute".
class SmartwatchWellnessService {
  static final SmartwatchWellnessService instance = SmartwatchWellnessService._();
  SmartwatchWellnessService._();

  final Health _health = Health();

  /// VO2max non è supportato dal package `health` (nessun `HealthDataType`
  /// corrispondente in v13.3.1), quindi resta fuori scope nonostante
  /// elencato in sezione 5.3 del documento — non un'omissione, un limite
  /// della libreria scelta.

  Future<List<HealthDataPoint>> _fetchRange(HealthDataType type, int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return _health.getHealthDataFromTypes(types: [type], startTime: start, endTime: end);
  }

  DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  /// Somma la durata (`dateTo - dateFrom`) dei campioni per giorno — per il
  /// sonno, dove il dato utile è l'intervallo, non il valore numerico.
  List<DailyMetric> _sumDurationByDay(List<HealthDataPoint> points) {
    final byDay = <DateTime, double>{};
    for (final p in points) {
      final hours = p.dateTo.difference(p.dateFrom).inMinutes / 60;
      final day = _dayOf(p.dateFrom);
      byDay.update(day, (v) => v + hours, ifAbsent: () => hours);
    }
    return _sortedEntries(byDay);
  }

  /// Media giornaliera dei valori numerici — per FC a riposo e HRV, dove più
  /// campioni nello stesso giorno vanno mediati, non sommati.
  List<DailyMetric> _averageByDay(List<HealthDataPoint> points) {
    final byDay = <DateTime, List<double>>{};
    for (final p in points) {
      final v = p.value;
      if (v is! NumericHealthValue) continue;
      byDay.putIfAbsent(_dayOf(p.dateFrom), () => []).add(v.numericValue.toDouble());
    }
    final avg = byDay.map((day, values) => MapEntry(day, values.reduce((a, b) => a + b) / values.length));
    return _sortedEntries(avg);
  }

  /// Somma giornaliera dei valori numerici — per passi e kcal totali.
  List<DailyMetric> _sumByDay(List<HealthDataPoint> points) {
    final byDay = <DateTime, double>{};
    for (final p in points) {
      final v = p.value;
      if (v is! NumericHealthValue) continue;
      final day = _dayOf(p.dateFrom);
      byDay.update(day, (s) => s + v.numericValue.toDouble(), ifAbsent: () => v.numericValue.toDouble());
    }
    return _sortedEntries(byDay);
  }

  List<DailyMetric> _sortedEntries(Map<DateTime, double> byDay) {
    final result = byDay.entries.map((e) => DailyMetric(e.key, e.value)).toList();
    result.sort((a, b) => a.day.compareTo(b.day));
    return result;
  }

  /// Ore di sonno per notte, negli ultimi [days] giorni.
  Future<List<DailyMetric>> sleepHoursByDay({int days = 30}) async {
    final points = await _fetchRange(SmartwatchService.sleepType, days);
    return _sumDurationByDay(points);
  }

  Future<List<DailyMetric>> restingHeartRateByDay({int days = 30}) async {
    final points = await _fetchRange(HealthDataType.RESTING_HEART_RATE, days);
    return _averageByDay(points);
  }

  Future<List<DailyMetric>> hrvByDay({int days = 30}) async {
    final points = await _fetchRange(SmartwatchService.hrvType, days);
    return _averageByDay(points);
  }

  Future<List<DailyMetric>> stepsByDay({int days = 30}) async {
    final points = await _fetchRange(HealthDataType.STEPS, days);
    return _sumByDay(points);
  }

  /// Kcal totali giornaliere. Preferisce `TOTAL_CALORIES_BURNED` (il dato
  /// diretto su Health Connect); se assente prova la somma basale+attive
  /// (il percorso che HealthKit espone davvero, vedi sezione 5.3 — su
  /// Android non esiste un fallback equivalente, resta solo il dato diretto).
  Future<List<DailyMetric>> totalKcalByDay({int days = 30}) async {
    final total = await _fetchRange(HealthDataType.TOTAL_CALORIES_BURNED, days);
    if (total.isNotEmpty) return _sumByDay(total);

    final basal = await _fetchRange(HealthDataType.BASAL_ENERGY_BURNED, days);
    final active = await _fetchRange(HealthDataType.ACTIVE_ENERGY_BURNED, days);
    return _sumByDay([...basal, ...active]);
  }

  /// Minuti di attività della settimana corrente (lunedì-oggi), aggregati
  /// dalle sessioni di allenamento del watch — stesso dato di
  /// [SmartwatchService.fetchWorkoutSessions], nessuna nuova lettura.
  Future<int> weeklyActivityMinutes() async {
    final now = DateTime.now();
    final weekStart = _dayOf(now).subtract(Duration(days: now.weekday - 1));
    final sessions =
        await SmartwatchService.instance.fetchWorkoutSessions(start: weekStart, end: now);
    final totalSeconds = sessions.fold<int>(0, (s, e) => s + e.duration.inSeconds);
    return totalSeconds ~/ 60;
  }
}
