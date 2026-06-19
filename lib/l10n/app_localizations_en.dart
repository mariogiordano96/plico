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

  @override
  String get onboardingContinua => 'CONTINUE';

  @override
  String get onboardingIndietro => 'Back';

  @override
  String get onboardingInizia => 'START';

  @override
  String get onboardingWelcomeTitle => 'Welcome.\nTell me your name.';

  @override
  String get onboardingNomeLabel => 'First name';

  @override
  String get onboardingNomeError => 'Enter your first name';

  @override
  String get onboardingCognomeLabel => 'Last name';

  @override
  String get onboardingCognomeError => 'Enter your last name';

  @override
  String get onboardingChiSeiTitle => 'Who are you?';

  @override
  String get onboardingSessoLabel => 'SEX';

  @override
  String get onboardingUomo => 'Male';

  @override
  String get onboardingDonna => 'Female';

  @override
  String get onboardingDataNascitaLabel => 'DATE OF BIRTH';

  @override
  String get onboardingSelezionaData => 'Select date';

  @override
  String get onboardingSessoDataError => 'Please select sex and date of birth';

  @override
  String get onboardingMisureTitle => 'Your measurements';

  @override
  String get onboardingAltezzaLabel => 'Height';

  @override
  String get onboardingAltezzaError => 'Enter your height';

  @override
  String get onboardingAltezzaInvalid => 'Invalid height';

  @override
  String get onboardingPesoLabel => 'Current weight (optional)';

  @override
  String get onboardingPesoInvalid => 'Invalid weight';

  @override
  String get onboardingBodyFatLabel => 'Starting body fat (optional)';

  @override
  String get onboardingBodyFatInvalid => 'Invalid value (1–70%)';

  @override
  String get onboardingMisureNote =>
      'Weight and body fat are optional. If entered, they will be saved as your starting point in the history.';

  @override
  String get onboardingObiettivoTitle => 'What is your\ngoal?';

  @override
  String get onboardingObiettivo0Label => 'Lose weight';

  @override
  String get onboardingObiettivo0Sub => '−20% deficit';

  @override
  String get onboardingObiettivo0Desc =>
      'Gradual reduction of body fat while maintaining muscle mass';

  @override
  String get onboardingObiettivo1Label => 'Maintain';

  @override
  String get onboardingObiettivo1Sub => 'Maintenance';

  @override
  String get onboardingObiettivo1Desc =>
      'Optimise body composition without changing weight';

  @override
  String get onboardingObiettivo2Label => 'Gain muscle';

  @override
  String get onboardingObiettivo2Sub => '+15% surplus';

  @override
  String get onboardingObiettivo2Desc =>
      'Maximise muscle growth with a higher caloric intake';

  @override
  String get onboardingAttivitaTitle => 'How active are you?';

  @override
  String get onboardingAttivitaSubtitle =>
      'Consider your average weekly activity.';

  @override
  String get onboardingAttivita0Label => 'Sedentary';

  @override
  String get onboardingAttivita0Desc => 'Desk job, little or no exercise';

  @override
  String get onboardingAttivita1Label => 'Lightly active';

  @override
  String get onboardingAttivita1Desc => 'Light exercise 1–3 days/week';

  @override
  String get onboardingAttivita2Label => 'Mod. active';

  @override
  String get onboardingAttivita2Desc => 'Moderate exercise 3–5 days/week';

  @override
  String get onboardingAttivita3Label => 'Very active';

  @override
  String get onboardingAttivita3Desc => 'Intense exercise 6–7 days/week';

  @override
  String get onboardingAttivita4Label => 'Athlete';

  @override
  String get onboardingAttivita4Desc =>
      'Intense physical work or double training sessions';

  @override
  String get onboardingTemaTitle => 'Choose your theme';

  @override
  String get onboardingTemaSubtitle =>
      'You can change it at any time from the app.';

  @override
  String get onboardingTemaChiaro => 'Light';

  @override
  String get onboardingTemaScuro => 'Dark';

  @override
  String get homeSalutoBuongiorno => 'Good morning';

  @override
  String get homeSalutoBuonPomeriggio => 'Good afternoon';

  @override
  String get homeSalutoBuonasera => 'Good evening';

  @override
  String get homeFallbackNome => 'Welcome';

  @override
  String get homeDiarioDiOggi => 'TODAY\'S DIARY';

  @override
  String get homePianoLabel => 'MEAL PLAN';

  @override
  String get homePianoSubtitle => 'View and generate your plan';

  @override
  String homeTdeeKcalGiorno(String kcal) {
    return '$kcal kcal/day';
  }

  @override
  String get homeTdeeCalcola => 'Calculate your caloric needs';

  @override
  String get homePesoLabel => 'WEIGHT';

  @override
  String get homeNessunaPesata => 'No weight recorded';

  @override
  String get homeBmiSottopeso => 'Underweight';

  @override
  String get homeBmiNormopeso => 'Normal weight';

  @override
  String get homeBmiSovrappeso => 'Overweight';

  @override
  String get homeBmiObesitaI => 'Obesity I';

  @override
  String get homeBmiObesitaII => 'Obesity II+';

  @override
  String get homePesoObiettivoRaggiunto => 'Goal reached 🎉';

  @override
  String homePesoAlObiettivo(String delta) {
    return '$delta kg from goal';
  }

  @override
  String get homePlicoLabel => 'PLICOMETRY';

  @override
  String get homePlicoMassaGrassa => 'Fat Mass';

  @override
  String get homePlicoMassaMagra => 'Lean Mass';

  @override
  String get homeNessunaSessionePlico => 'No session recorded';

  @override
  String get homePlicoNuovaMisurazione => 'New measurement';

  @override
  String get homeProgressiLabel => 'PROGRESS';

  @override
  String get homeProgressiSubtitle =>
      'Body composition and measurements over time';

  @override
  String get homeRiepilogoSettimanale => 'WEEKLY SUMMARY';

  @override
  String get homeNessunDato => 'No data';

  @override
  String get homeMediaKcal => 'Avg kcal';

  @override
  String homeWeeklyAvgKcal(String kcal) {
    return '$kcal kcal/d';
  }

  @override
  String get homeVariazionePeso => 'Weight change';

  @override
  String get homeAderenzaAlPiano => 'Plan adherence';

  @override
  String get homeAderenzaHeader => 'PLAN ADHERENCE';

  @override
  String get homePastiOggi => 'meals today';

  @override
  String get homeUltimiSetteGiorni => 'last 7 days';

  @override
  String homeStreakGiorni(String count) {
    return '$count days in a row';
  }

  @override
  String get homeStreakInizia => 'Start your streak today';

  @override
  String get homeBadge1KgPerso => '1st kg lost';

  @override
  String get homeBadgeStreak7 => '7-day streak';

  @override
  String get homeBadge30Giorni => '30 days';

  @override
  String get homeBadgeSettimanaTarget => 'Week on target';
}
