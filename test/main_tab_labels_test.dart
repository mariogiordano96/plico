import 'package:flutter_test/flutter_test.dart';
import 'package:plico/l10n/app_localizations_en.dart';
import 'package:plico/l10n/app_localizations_it.dart';
import 'package:plico/screens/main_screen.dart';

void main() {
  group('mainTabLabels', () {
    test('bug: le etichette della bottom nav bar seguono la lingua'
        ' inglese, non restano hardcoded in italiano', () {
      final labels = mainTabLabels(AppLocalizationsEn());
      expect(labels, ['Home', 'Diary', 'Workout', 'Progress', 'Coach']);
    });

    test('in italiano restano le etichette italiane', () {
      final labels = mainTabLabels(AppLocalizationsIt());
      expect(labels, ['Home', 'Diario', 'Allenamento', 'Progressi', 'Coach']);
    });
  });
}
