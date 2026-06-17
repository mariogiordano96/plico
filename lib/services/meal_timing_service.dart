import 'package:flutter/material.dart';

import 'database_service.dart';

class MealTimingService {
  static final MealTimingService instance = MealTimingService._();
  MealTimingService._();

  static const _minSamples = 5;
  static const _historyDays = 30;

  Future<TimeOfDay?> suggestedTime(int pastoTipo) async {
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: _historyDays));
    final logs = await DatabaseService.instance.getDailyLogsRange(from, to);

    final minutes = <int>[];
    for (final log in logs) {
      for (final entry in log.entries) {
        final orario = entry.orarioInserimento;
        if (entry.pastoTipo == pastoTipo && orario != null) {
          minutes.add(orario.hour * 60 + orario.minute);
        }
      }
    }

    if (minutes.length < _minSamples) return null;

    final avgMinutes = minutes.reduce((a, b) => a + b) ~/ minutes.length;
    return TimeOfDay(hour: avgMinutes ~/ 60, minute: avgMinutes % 60);
  }
}
