import '../models/workout_exercise.dart';
import '../models/workout_set.dart';

enum OverloadDirection { increase, maintain, decrease }

class OverloadSuggestion {
  final OverloadDirection direction;
  final double? suggestedWeightKg;
  final int? suggestedReps;

  /// true se il suggerimento deriva da [WorkoutProgressService.needsDeload]
  /// (riduzione più marcata, -40% invece di -5/-10%), non da una sessione
  /// sotto il target.
  final bool isDeload;

  const OverloadSuggestion({
    required this.direction,
    this.suggestedWeightKg,
    this.suggestedReps,
    this.isDeload = false,
  });
}

/// Metriche derivate e suggerimenti di progressive overload — calcolati a runtime,
/// nessuno di questi valori è persistito. Vedi docs/evolutiva_esercizi.md,
/// sezione "Storico progressi e progressive overload".
class WorkoutProgressService {
  static List<WorkoutSet> _workSets(WorkoutExercise e) =>
      e.sets.where((s) => !s.isWarmup).toList();

  static double sessionVolume(WorkoutExercise e) {
    return _workSets(e).fold<double>(
        0, (sum, s) => sum + (s.reps ?? 0) * (s.weightKg ?? 0));
  }

  static double? sessionMaxWeight(WorkoutExercise e) {
    final weights = _workSets(e).map((s) => s.weightKg).whereType<double>();
    return weights.isEmpty ? null : weights.reduce((a, b) => a > b ? a : b);
  }

  /// Stima 1RM (formula di Epley) sulla serie migliore della sessione.
  static double? estimatedOneRepMax(WorkoutExercise e) {
    final sets = _workSets(e).where((s) => s.weightKg != null && s.reps != null);
    if (sets.isEmpty) return null;
    double best = 0;
    for (final s in sets) {
      final orm = s.weightKg! * (1 + s.reps! / 30);
      if (orm > best) best = orm;
    }
    return best;
  }

  /// true se [candidate] supera il carico massimo di tutte le sessioni in
  /// [priorHistory] (sessioni precedenti a [candidate], escluse dal confronto).
  static bool isNewPersonalRecord(
      WorkoutExercise candidate, List<WorkoutExercise> priorHistory) {
    final candidateMax = sessionMaxWeight(candidate);
    if (candidateMax == null) return false;
    double? priorMax;
    for (final e in priorHistory) {
      final m = sessionMaxWeight(e);
      if (m != null && (priorMax == null || m > priorMax)) priorMax = m;
    }
    return priorMax == null || candidateMax > priorMax;
  }

  static double _roundToNearest(double value, double step) {
    return (value / step).round() * step;
  }

  /// Suggerimento per la prossima sessione, basato sull'ultima sessione registrata
  /// per lo stesso esercizio. Usa la prima serie come riferimento del "target"
  /// (i preset prescrivono rip uniformi tra le serie, es. "3×8").
  static OverloadSuggestion suggestNextSession(WorkoutExercise lastSession) {
    final sets = _workSets(lastSession);
    if (sets.isEmpty) {
      return const OverloadSuggestion(direction: OverloadDirection.maintain);
    }

    final baselineReps = sets.first.reps;
    final maxWeight = sets.map((s) => s.weightKg ?? 0).reduce((a, b) => a > b ? a : b);
    final underperforming =
        sets.where((s) => baselineReps != null && (s.reps ?? 0) < baselineReps).length;

    final rpeValues = sets.map((s) => s.rpe).whereType<int>();
    final avgRpe =
        rpeValues.isEmpty ? null : rpeValues.reduce((a, b) => a + b) / rpeValues.length;

    if (underperforming >= 2) {
      return OverloadSuggestion(
        direction: OverloadDirection.decrease,
        suggestedWeightKg: _roundToNearest(maxWeight * 0.925, 2.5),
        suggestedReps: baselineReps,
      );
    }
    if (underperforming == 1) {
      return OverloadSuggestion(
        direction: OverloadDirection.maintain,
        suggestedWeightKg: maxWeight,
        suggestedReps: baselineReps,
      );
    }
    if (avgRpe != null && avgRpe >= 8.5) {
      return OverloadSuggestion(
        direction: OverloadDirection.maintain,
        suggestedWeightKg: maxWeight,
        suggestedReps: baselineReps,
      );
    }
    return OverloadSuggestion(
      direction: OverloadDirection.increase,
      suggestedWeightKg: _roundToNearest(maxWeight + 2.5, 2.5),
      suggestedReps: baselineReps,
    );
  }

  static String _weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  /// true se nelle ultime [weeks] settimane (default 4) il carico massimo per
  /// settimana non è mai diminuito — segnale che potrebbe servire una settimana
  /// di scarico prima di continuare a progredire.
  static bool needsDeload(List<WorkoutExercise> history, {int weeks = 4}) {
    final byWeek = <String, double>{};
    for (final e in history) {
      final maxW = sessionMaxWeight(e);
      if (maxW == null) continue;
      final key = _weekKey(e.date);
      if (!byWeek.containsKey(key) || maxW > byWeek[key]!) byWeek[key] = maxW;
    }
    final weekKeys = byWeek.keys.toList()..sort();
    if (weekKeys.length < weeks) return false;

    final recent = weekKeys.sublist(weekKeys.length - weeks);
    for (var i = 1; i < recent.length; i++) {
      if (byWeek[recent[i]]! < byWeek[recent[i - 1]]!) return false;
    }
    return true;
  }

  /// Suggerimento di scarico: -40% sul carico massimo recente.
  static OverloadSuggestion deloadSuggestion(WorkoutExercise lastSession) {
    final sets = _workSets(lastSession);
    final maxWeight =
        sets.isEmpty ? null : sets.map((s) => s.weightKg ?? 0).reduce((a, b) => a > b ? a : b);
    return OverloadSuggestion(
      direction: OverloadDirection.decrease,
      suggestedWeightKg: maxWeight != null ? _roundToNearest(maxWeight * 0.6, 2.5) : null,
      suggestedReps: sets.isNotEmpty ? sets.first.reps : null,
      isDeload: true,
    );
  }
}
