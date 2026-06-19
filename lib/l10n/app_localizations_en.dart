// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Plico';

  @override
  String get pastoColazione => 'Breakfast';

  @override
  String get pastoPranzo => 'Lunch';

  @override
  String get pastoCena => 'Dinner';

  @override
  String get pastoSpuntino => 'Snack';

  @override
  String get pastoPostWo => 'Post-WO';

  @override
  String get pastoSpuntinoSerale => 'Evening snack';

  @override
  String get slotProteina => 'Protein';

  @override
  String get slotCarboidrati => 'Carbs';

  @override
  String get slotVerdura => 'Vegetables';

  @override
  String get slotGrassi => 'Fats';

  @override
  String get slotExtra => 'Extra';

  @override
  String get slotFrutta => 'Fruit';

  @override
  String get tourHomeTitle => 'Home';

  @override
  String get tourHomeDesc =>
      'Your daily summary: calories consumed, macros, streak and the day\'s plan — all at a glance.';

  @override
  String get tourDiarioTitle => 'Diary';

  @override
  String get tourDiarioDesc =>
      'Log every meal of the day. Tap \"+\" at the top to add a food or scan a barcode.';

  @override
  String get tourProgressiTitle => 'Progress';

  @override
  String get tourProgressiDesc =>
      'Track your weight over time, view earned badges and your weekly summary.';

  @override
  String get tourTdeeTitle => 'TDEE';

  @override
  String get tourTdeeDesc =>
      'Your personalised caloric needs, calculated and updated based on your real data.';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourStart => 'Start';
}
