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
}
