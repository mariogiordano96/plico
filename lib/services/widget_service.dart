import 'package:home_widget/home_widget.dart';

import 'database_service.dart';
import 'target_service.dart';

/// Aggiorna il widget Home Screen (Android/iOS) con il riepilogo di oggi.
class WidgetService {
  static const androidName = 'PlicoWidgetProvider';
  static const iOSName = 'PlicoWidget';
  static const iOSGroupId = 'group.com.maxio96.plico.widget';

  static Future<void> refresh() async {
    final log = await DatabaseService.instance.getDailyLog(DateTime.now());
    final targets = await computeDailyTargets();
    await HomeWidget.saveWidgetData<int>('kcal_consumed', log?.kcalTotali.round() ?? 0);
    await HomeWidget.saveWidgetData<int>('kcal_target', targets.$1 ?? 0);
    await HomeWidget.updateWidget(androidName: androidName, iOSName: iOSName);
  }
}
