import '../models/body_snapshot.dart';
import 'database_service.dart';

class TdeeCalibrationResult {
  final int currentTdee;
  final int suggestedTdee;
  final int days;
  const TdeeCalibrationResult({
    required this.currentTdee,
    required this.suggestedTdee,
    required this.days,
  });
}

class TdeeCalibrationService {
  static final TdeeCalibrationService instance = TdeeCalibrationService._();
  TdeeCalibrationService._();

  static const _kcalPerKg = 7700.0;
  static const _minDays = 14;
  static const _minLoggedDays = 10;

  Future<TdeeCalibrationResult?> suggestion(int currentTdee) async {
    final snapshots = await DatabaseService.instance.getBodySnapshots();
    if (snapshots.length < 2) return null;

    final latest = snapshots.first;
    BodySnapshot? oldest;
    for (final s in snapshots) {
      if (latest.data.difference(s.data).inDays >= _minDays) oldest = s;
    }
    if (oldest == null) return null;

    final days = latest.data.difference(oldest.data).inDays;
    final logs = await DatabaseService.instance
        .getDailyLogsRange(oldest.data, latest.data);
    final loggedDays = logs.where((l) => l.entries.isNotEmpty).toList();
    if (loggedDays.length < _minLoggedDays) return null;

    final avgKcal =
        loggedDays.fold<double>(0, (sum, l) => sum + l.kcalTotali) /
            loggedDays.length;
    final actualChangeKg = latest.pesoKg - oldest.pesoKg;
    final suggestedTdee =
        avgKcal - (actualChangeKg * _kcalPerKg / days);

    if ((suggestedTdee - currentTdee).abs() < 50) return null;

    return TdeeCalibrationResult(
      currentTdee: currentTdee,
      suggestedTdee: suggestedTdee.round(),
      days: days,
    );
  }
}
