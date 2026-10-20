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

  /// true se la sessione ha almeno una serie di lavoro realmente confermata.
  /// Le sessioni create all'avvio ma mai svolte (serie senza peso/non
  /// confermate) non devono finire nello storico usato per i suggerimenti:
  /// altrimenti `weightKg ?? 0` produce un suggerimento di 0 kg.
  static bool hasConfirmedWork(WorkoutExercise e) =>
      _workSets(e).any((s) => s.confirmed);

  static List<WorkoutSet> _confirmedWorkSets(WorkoutExercise e) =>
      _workSets(e).where((s) => s.confirmed).toList();

  /// Volume (kg sollevati) di una singola serie, tecniche incluse
  /// (docs/tecniche_allenamento.md, Fase 5, sezione 5):
  /// - stripping: somma anche i gradini in `dropStages` (peso diverso a ogni
  ///   gradino, la formula base conterebbe solo il primo)
  /// - rest-pause: nessun aggiustamento, `reps` è già la somma dei cluster
  ///   (scritta da `_SetRow`/`_confirmSerie` in sessione guidata)
  /// - forzate: nessun aggiustamento, `forcedReps` non è mai incluso in
  ///   `reps` (campo separato, non sono ripetizioni sollevate in autonomia)
  static double setVolume(WorkoutSet s) {
    var volume = (s.reps ?? 0).toDouble() * (s.weightKg ?? 0);
    for (final stage in s.dropStages ?? const []) {
      volume += (stage.reps ?? 0).toDouble() * (stage.weightKg ?? 0);
    }
    return volume;
  }

  /// Soglia minima di carico (kg) sotto la quale il riscaldamento non viene
  /// suggerito: carichi leggeri non richiedono una rampa di avvicinamento.
  static const double warmupSkipThresholdKg = 20;

  /// Rampa di riscaldamento (50%/70%/90% di [targetWeightKg], reps decrescenti)
  /// per avvicinarsi al carico di lavoro. Nessun suggerimento se [targetWeightKg]
  /// è sotto [skipThresholdKg] (default [warmupSkipThresholdKg]).
  static List<WorkoutSet> suggestWarmupSets(
    double targetWeightKg, {
    double skipThresholdKg = warmupSkipThresholdKg,
  }) {
    if (targetWeightKg < skipThresholdKg) return [];
    const ramps = [(0.5, 8), (0.7, 5), (0.9, 3)];
    return [
      for (final ramp in ramps)
        WorkoutSet()
          ..isWarmup = true
          ..weightKg = _roundToNearest(targetWeightKg * ramp.$1, 2.5)
          ..reps = ramp.$2,
    ];
  }

  /// Gruppi muscolari (tra le chiavi di [volumeByGroup]) con volume nullo o
  /// molto sotto la media degli altri gruppi allenati — usato per il banner
  /// di avviso del grafico "Volume settimanale" (Fase 18). Un gruppo è
  /// "trascurato" se il suo volume è sotto [thresholdFraction] della media dei
  /// gruppi con volume positivo; se nessun gruppo ha volume positivo non c'è
  /// nulla da segnalare.
  static List<String> neglectedMuscleGroups(
    Map<String, double> volumeByGroup, {
    double thresholdFraction = 0.3,
  }) {
    final trained = volumeByGroup.values.where((v) => v > 0).toList();
    if (trained.isEmpty) return [];
    final avg = trained.reduce((a, b) => a + b) / trained.length;
    return volumeByGroup.entries
        .where((e) => e.value < avg * thresholdFraction)
        .map((e) => e.key)
        .toList();
  }

  static double sessionVolume(WorkoutExercise e) {
    return _workSets(e).fold<double>(0, (sum, s) => sum + setVolume(s));
  }

  static double? sessionMaxWeight(WorkoutExercise e) {
    final weights = _workSets(e).map((s) => s.weightKg).whereType<double>();
    return weights.isEmpty ? null : weights.reduce((a, b) => a > b ? a : b);
  }

  /// RPE medio della sessione (solo serie con `rpe` impostato), o null se nessuna
  /// serie ha un RPE registrato.
  static double? averageRpe(WorkoutExercise e) {
    final rpeValues = _workSets(e).map((s) => s.rpe).whereType<int>();
    if (rpeValues.isEmpty) return null;
    return rpeValues.reduce((a, b) => a + b) / rpeValues.length;
  }

  /// Stima 1RM (formula di Epley) sulla serie migliore della sessione.
  /// Esclude le serie rest-pause (docs/tecniche_allenamento.md, Fase 5,
  /// sezione 8): `reps` è la somma dei cluster, non ripetizioni di uno
  /// sforzo continuo — userebbe la formula di Epley su un valore che la
  /// sovrastimerebbe. Trattate come le serie di riscaldamento, già escluse
  /// da `_workSets`.
  static double? estimatedOneRepMax(WorkoutExercise e) {
    final sets = _workSets(e).where((s) =>
        s.weightKg != null && s.reps != null && (s.restPauseClusters?.isEmpty ?? true));
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
    final sets = _confirmedWorkSets(lastSession);
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

  static DateTime _weekMonday(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// true se nelle ultime [weeks] settimane CONSECUTIVE (default 4) il carico
  /// massimo per settimana non è mai diminuito — segnale che potrebbe servire
  /// una settimana di scarico prima di continuare a progredire. Settimane
  /// senza nessuna sessione registrata interrompono la sequenza: non basta
  /// che esistano N settimane con dati, devono susseguirsi senza salti.
  static bool needsDeload(List<WorkoutExercise> history, {int weeks = 4}) {
    final byWeek = <DateTime, double>{};
    for (final e in history) {
      final maxW = sessionMaxWeight(e);
      if (maxW == null) continue;
      final key = _weekMonday(e.date);
      if (!byWeek.containsKey(key) || maxW > byWeek[key]!) byWeek[key] = maxW;
    }
    final weekStarts = byWeek.keys.toList()..sort();
    if (weekStarts.length < weeks) return false;

    final recent = weekStarts.sublist(weekStarts.length - weeks);
    for (var i = 1; i < recent.length; i++) {
      if (recent[i].difference(recent[i - 1]).inDays != 7) return false;
      if (byWeek[recent[i]]! < byWeek[recent[i - 1]]!) return false;
    }
    return true;
  }

  /// Suggerimento di scarico: -40% sul carico massimo recente.
  static OverloadSuggestion deloadSuggestion(WorkoutExercise lastSession) {
    final sets = _confirmedWorkSets(lastSession);
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
