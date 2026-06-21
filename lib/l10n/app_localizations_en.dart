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

  @override
  String get diarioTitolo => 'DIARY';

  @override
  String get diarioTabPiano => 'PLAN';

  @override
  String get diarioTabDiario => 'DIARY';

  @override
  String get diarioSalvaComePref => 'Save as favourite';

  @override
  String get diarioSalvaHint => 'E.g. My breakfast';

  @override
  String get diarioAnnulla => 'Cancel';

  @override
  String get diarioBtnSalva => 'Save';

  @override
  String diarioSalvatoComePref(String nome) {
    return 'Saved as favourite: $nome';
  }

  @override
  String get diarioOggi => 'Today';

  @override
  String get diarioIeri => 'Yesterday';

  @override
  String diarioKcalObiettivo(String target) {
    return 'of $target goal';
  }

  @override
  String get diarioNessunObiettivo => 'no goal set';

  @override
  String get diarioObiettivoRaggiunto => 'goal reached';

  @override
  String diarioKcalRimanenti(String kcal) {
    return '$kcal remaining';
  }

  @override
  String get diarioOttimoLavoro => 'Great job! You\'re on target today.';

  @override
  String get diarioMacroProteine => 'Protein';

  @override
  String get diarioMacroGrassi => 'Fats';

  @override
  String get diarioMacroCarbo => 'Carbs';

  @override
  String get diarioNessunAlimento => 'No food logged';

  @override
  String get diarioRipetiIeri => 'Repeat yesterday\'s meal';

  @override
  String aggiuntiA(String pasto) {
    return 'ADD TO $pasto';
  }

  @override
  String get aggiuntiPastiPreferiti => 'YOUR FAVOURITE MEALS';

  @override
  String get aggiuntiDalPiano => 'FROM YOUR PLAN';

  @override
  String get aggiuntiTuoiAlimenti => 'YOUR FOODS';

  @override
  String get aggiuntiAlimentiSalvati => 'SAVED FOODS';

  @override
  String get aggiuntiRisultatiOFF => 'OPEN FOOD FACTS RESULTS';

  @override
  String get aggiuntiNessunRisultato =>
      'No results found.\nTry creating a food manually.';

  @override
  String get aggiuntiCreaManuale => 'Create manual food';

  @override
  String get aggiuntiQuantitaG => 'Quantity (g)';

  @override
  String get aggiuntiAggiungi => 'ADD';

  @override
  String get aggiuntiCreaAlimento => 'CREATE FOOD';

  @override
  String get aggiuntiNome => 'Name *';

  @override
  String get aggiuntiBrand => 'Brand (optional)';

  @override
  String get aggiuntiKcal100g => 'Kcal/100g *';

  @override
  String get aggiuntiProteine100g => 'Protein/100g';

  @override
  String get aggiuntiGrassi100g => 'Fats/100g';

  @override
  String get aggiuntiCarbo100g => 'Carbs/100g';

  @override
  String get aggiuntiSalvaAggiungi => 'SAVE & ADD';

  @override
  String get aggiuntiCercaHint => 'Search food or brand...';

  @override
  String get questionarioTitolo => 'DIETARY PREFERENCES';

  @override
  String get questionarioIndietro => 'BACK';

  @override
  String get questionarioAvanti => 'NEXT';

  @override
  String get questionarioSalvaGenera => 'SAVE & GENERATE';

  @override
  String get questionarioRestrizioni => 'Restrictions';

  @override
  String get questionarioRestrizioniSub =>
      'Select any dietary restrictions. You can skip if you have none.';

  @override
  String get questionarioVegetariano => 'Vegetarian';

  @override
  String get questionarioVegano => 'Vegan';

  @override
  String get questionarioNoLattosio => 'No lactose';

  @override
  String get questionarioNoGlutine => 'No gluten';

  @override
  String get questionarioNoPesce => 'No fish';

  @override
  String get questionarioNoFruttaSecca => 'No nuts';

  @override
  String get questionarioNessunaRestrizione => 'No restrictions — great!';

  @override
  String get questionarioPreferenze => 'Preferences';

  @override
  String get questionarioPreferenzeSub =>
      'Select foods you like. The plan will prioritise your choices.';

  @override
  String get questionarioStruttura => 'Structure';

  @override
  String get questionarioStrutturaSub => 'How do you organise your meals?';

  @override
  String get questionarioPastiGiorno => 'Meals per day';

  @override
  String get questionarioSpuntinoPostWo => 'Post-workout snack';

  @override
  String get questionarioSpuntinoPostWoSub =>
      'Includes extra protein for recovery';

  @override
  String get pianoGenerazioneInCorso => 'Generating plan…';

  @override
  String get pianoPianoAlimentare => 'Meal Plan';

  @override
  String get pianoPromoSub =>
      'Tell us your food preferences and we\'ll generate a personalised plan based on your macro targets.';

  @override
  String get pianoIniziaQuestionario => 'START QUESTIONNAIRE';

  @override
  String get pianoPreferenzeSalvate => 'Preferences saved';

  @override
  String get pianoProntoGenerare => 'Ready to generate your meal plan.';

  @override
  String get pianoGeneraPiano => 'GENERATE PLAN';

  @override
  String get pianoModificaPreferenze => 'Edit preferences';

  @override
  String get pianoEsportaPdf => 'Export PDF';

  @override
  String get pianoObiettiviCambiati =>
      'Your goals have changed. Regenerate the plan to update the quantities.';

  @override
  String get pianoRigenera => 'REGENERATE';

  @override
  String pianoGeneratoIl(String data) {
    return 'Generated on $data';
  }

  @override
  String get pianoAttivo => 'ACTIVE';

  @override
  String get pianoGrammatureCrudo => 'Quantities to weigh raw';

  @override
  String get pianoKcalNote =>
      'Plan kcal may differ slightly from the diary target due to rounding of quantities';

  @override
  String pianoQbRiferimento(String g) {
    return 'to taste  ·  ~$g g as reference';
  }

  @override
  String pianoQb(String g) {
    return 'to taste  ·  ~$g g';
  }

  @override
  String get pianoNascondiAlternative => 'Hide alternatives';

  @override
  String pianoNAlternative(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alternatives',
      one: '$count alternative',
    );
    return '$_temp0';
  }

  @override
  String get pianoAggiungiAlDiario => 'Add to diary';

  @override
  String get pianoSuggerito => 'Suggested';

  @override
  String pianoAggiunto(String pasto) {
    return 'Added to $pasto';
  }

  @override
  String get pianoErrorePdf => 'Error generating PDF';

  @override
  String get pianoStileDolce => '🍯 Sweet';

  @override
  String get pianoStileSalata => '🧀 Savoury';

  @override
  String get appElimina => 'Delete';

  @override
  String get progressiTitolo => 'PROGRESS';

  @override
  String get progressiTooltipEsporta => 'Export PDF';

  @override
  String get progressiTooltipStorico => 'Measurements history';

  @override
  String get progressiSezPeso => 'WEIGHT';

  @override
  String get progressiSezDiario => 'DIARY';

  @override
  String get progressiSezComposizione => 'BODY COMPOSITION';

  @override
  String get progressiSezMisurazioni => 'MEASUREMENTS';

  @override
  String get progressiRange1A => '1Y';

  @override
  String get progressiRangeTutto => 'All';

  @override
  String get progressiMassaGrassa => 'Fat Mass';

  @override
  String get progressiMassaMagra => 'Lean Mass';

  @override
  String get progressiProteine => 'Protein';

  @override
  String get progressiGrassi => 'Fats';

  @override
  String get progressiCarboidrati => 'Carbs';

  @override
  String get progressiNessunDato => 'No data in the selected period';

  @override
  String progressiMedia7gg(String val, String unit) {
    return '7d avg: $val $unit';
  }

  @override
  String get progressiStatUltimo => 'Last';

  @override
  String get progressiStatMedia => 'Avg';

  @override
  String get progressiStatVariazione => 'Change';

  @override
  String get progressiStatGiorni => 'Days';

  @override
  String get progressiStatRilevazioni => 'Readings';

  @override
  String get progressiGenerazionePdf => 'Generating PDF...';

  @override
  String get progressiEsportaDiario => 'Export Diary';

  @override
  String get progressiEsportaSub => 'Select the period to export as PDF';

  @override
  String get progressiUltimaSettimana => 'Last week';

  @override
  String get progressiUltimoMese => 'Last month';

  @override
  String get progressi7Giorni => '7 days';

  @override
  String get progressi30Giorni => '30 days';

  @override
  String progressiErrEsportazione(String err) {
    return 'Export error: $err';
  }

  @override
  String get pesateTitolo => 'WEIGH-INS';

  @override
  String get pesateEliminaTitle => 'Delete weigh-in';

  @override
  String get pesateEliminaSub =>
      'Are you sure you want to delete this measurement?';

  @override
  String get pesateNessuna => 'No weigh-ins';

  @override
  String get pesateNessunaSub => 'Tap + to add\nyour first measurement';

  @override
  String get pesateNuova => 'NEW WEIGH-IN';

  @override
  String get pesateData => 'DATE';

  @override
  String get pesatePeso => 'WEIGHT *';

  @override
  String get pesateCampoObb => 'Required field';

  @override
  String get pesatePesoInvalido => 'Invalid weight';

  @override
  String get pesateAltezzaOpz => 'HEIGHT (optional)';

  @override
  String get pesateAltezzaHint => 'Only if different from profile';

  @override
  String get pesateAltezzaInvalida => 'Invalid height';

  @override
  String get pesateBodyFatOpz => 'BODY FAT (optional)';

  @override
  String get pesateBodyFatHint => 'E.g. from smart scale';

  @override
  String get pesateBodyFatInvalido => 'Invalid value (1–70%)';

  @override
  String get pesateNoteOpz => 'NOTES (optional)';

  @override
  String get pesateNoteHint => 'E.g. morning, fasted...';

  @override
  String get pesateSalva => 'SAVE WEIGH-IN';

  @override
  String get storicoMisurazioni => 'MEASUREMENTS';

  @override
  String get storicoEliminaTitle => 'Delete measurement';

  @override
  String get storicoEliminaSub => 'Delete data for this day?';

  @override
  String get storicoFonteManuale => 'Manual';

  @override
  String get storicoNessuna => 'No measurements';

  @override
  String get storicoNessunaSub =>
      'Measurements will appear here\nafter a session or manual entry.';

  @override
  String get misurazioneNuova => 'NEW MEASUREMENT';

  @override
  String get misurazioneModifica => 'Edit';

  @override
  String get misurazioneTabPliche => 'SKINFOLDS';

  @override
  String get misurazioneTabCirconferenze => 'CIRCUMFERENCES';

  @override
  String get misurazioneSalva => 'SAVE MEASUREMENT';

  @override
  String get misurazioneInserisciValore => 'Enter at least one value';

  @override
  String get misurazioneCalibrazione => 'Point calibration';

  @override
  String misurazioneContPliche(String count) {
    return '$count skinfolds';
  }

  @override
  String misurazioneContCirconferenze(String count) {
    return '$count circ.';
  }

  @override
  String get misuraVita => 'Waist';

  @override
  String get misuraFianchi => 'Hips';

  @override
  String get misuraBraccio => 'Arm';

  @override
  String get misuraCollo => 'Neck';

  @override
  String get misuraCoscia => 'Thigh';

  @override
  String get misuraPolpaccio => 'Calf';

  @override
  String get misuraTorace => 'Chest';

  @override
  String get misuraSpalle => 'Shoulders';

  @override
  String get misuraTricipite => 'Triceps';

  @override
  String get misuraBicipite => 'Biceps';

  @override
  String get misuraSottoscap => 'Subscap.';

  @override
  String get misuraSottoscapolare => 'Subscapular';

  @override
  String get misuraSovrailiaca => 'Suprailiac';

  @override
  String get misuraAddome => 'Abdomen';

  @override
  String get misuraCosciaPlica => 'Thigh (SK)';

  @override
  String get misuraPettorale => 'Pectoral';

  @override
  String get misuraAscellare => 'Axillary';

  @override
  String get tdeeTitolo => 'MY PLAN';

  @override
  String get tdeeIntroTesto =>
      'Configure your nutrition plan. Once activated, these values will be used in the food diary.';

  @override
  String get tdeeSezObiettivo => 'GOAL';

  @override
  String get tdeeSezAttivita => 'ACTIVITY LEVEL';

  @override
  String get tdeeSezMetodo => 'CALCULATION METHOD';

  @override
  String get tdeeSezAnteprima => 'PLAN PREVIEW';

  @override
  String get tdeeSezRipartizione => 'MACRO BREAKDOWN';

  @override
  String get tdeePesoObiettivo => 'Target weight (kg)';

  @override
  String get tdeeNessunaPesata => 'Log a weigh-in to calculate your plan.';

  @override
  String get tdeeAttivaPiano => 'ACTIVATE PLAN';

  @override
  String get tdeeAggiornaPiano => 'UPDATE PLAN';

  @override
  String get tdeeKcalGiornoUnit => 'kcal/day';

  @override
  String get tdeePianoAttivoLabel => 'ACTIVE PLAN';

  @override
  String tdeeAttivatoDal(String date) {
    return 'since $date';
  }

  @override
  String get tdeeDatiInsufficienti => 'Insufficient data';

  @override
  String get tdeeCarbsNote => 'remaining calories';

  @override
  String tdeeSonoPassati(int n) {
    return '$n days have passed';
  }

  @override
  String get tdeeBannerSub =>
      'It might be time to update your plan based on your progress.';

  @override
  String get tdeeRicalcolaObiettivo => 'Recalculate goal';

  @override
  String get tdeeRicalcolaBtn => 'Recalculate';

  @override
  String tdeeRicalcolaBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You activated the plan $n days ago.',
      one: 'You activated the plan $n day ago.',
    );
    return '$_temp0\n\nYou can recalculate at any time, but we recommend doing so after at least 30 days to evaluate progress.';
  }

  @override
  String tdeeCalibrazione(String days, String suggested, String current) {
    return 'Based on your last $days days of data, your real TDEE might be ~$suggested kcal (estimated: $current kcal).';
  }

  @override
  String tdeePreviewFormula(String nome, String tdee) {
    return 'Formula: $nome  ·  TDEE: $tdee kcal';
  }

  @override
  String get tdeeObjDeficit => 'Deficit';

  @override
  String get tdeeObjMantenimento => 'Maintenance';

  @override
  String get tdeeObjSurplus => 'Surplus';

  @override
  String get tdeeObjDeficitBadge => 'Deficit −20%';

  @override
  String get tdeeObjSurplusBadge => 'Surplus +15%';

  @override
  String get tdeeAttSedentario => 'Sedentary';

  @override
  String get tdeeAttLegg => 'Lightly active';

  @override
  String get tdeeAttMod => 'Moderately active';

  @override
  String get tdeeAttMolto => 'Very active';

  @override
  String get tdeeAttAtleta => 'Athlete';

  @override
  String get tdeeAttSedentarioDesc => 'Sedentary job, little or no exercise';

  @override
  String get tdeeAttLeggDesc => 'Light exercise 1–3 days/week';

  @override
  String get tdeeAttModDesc => 'Moderate exercise 3–5 days/week';

  @override
  String get tdeeAttMoltoDesc => 'Intense exercise 6–7 days/week';

  @override
  String get tdeeAttAtletaDesc => 'Intense physical job or double training';

  @override
  String get tdeeMetodoAutomaticoNome => 'Automatic';

  @override
  String get tdeeMetodoAutomaticoDesc =>
      'Uses the most accurate formula available: Katch-McArdle if you have skinfold data, otherwise Mifflin-St Jeor.';

  @override
  String get tdeeMetodoKatchDesc =>
      'BMR = 370 + 21.6 × lean mass. The most accurate: considers only metabolically active mass.';

  @override
  String get tdeeMetodoMifflinDesc =>
      'Formula recommended by the American Dietetic Association. Accurate for most people.';

  @override
  String get tdeeMetodoHarrisDesc =>
      'Revised classic formula (Roza & Shizgal, 1984). Tends to slightly overestimate.';

  @override
  String get tdeeRichiedePlic => 'requires skinfold test';

  @override
  String get notifChannelPasti => 'Meal reminders';

  @override
  String get notifChannelPastiDesc => 'Remember to log your meals';

  @override
  String get notifChannelRecap => 'Evening recap';

  @override
  String get notifChannelRecapDesc => 'Evening summary of your progress';

  @override
  String get notifChannelMattino => 'Morning recap';

  @override
  String get notifChannelMattinoDesc => 'Yesterday\'s calorie summary';

  @override
  String get notifChannelPesata => 'Weigh-in reminder';

  @override
  String get notifChannelPesataDesc => 'Remember to log your weight';

  @override
  String notifPastoBody(String pasto) {
    return 'Did you log $pasto?';
  }

  @override
  String get notifRecapNuovaStreak =>
      'Log your meals today to start a new streak.';

  @override
  String notifRecapMantieni(int streak) {
    return 'You\'ve logged every day for $streak days. Keep your streak going? 🔥';
  }

  @override
  String notifRecapObiettivo(int streak) {
    return 'Today you hit your goal for $streak days in a row 🔥';
  }

  @override
  String notifRecapStreak(int streak) {
    return 'You\'ve logged $streak days in a row! Keep it up 💪';
  }

  @override
  String notifMattinoOnTarget(int kcal, int target) {
    return 'Yesterday you ate $kcal kcal out of $target. Great job! 💪';
  }

  @override
  String notifMattinoOffTarget(int kcal, int target) {
    return 'Yesterday you logged $kcal kcal out of $target target.';
  }

  @override
  String notifMattinoNoTarget(int kcal) {
    return 'Yesterday you logged $kcal kcal.';
  }

  @override
  String notifPesataBody(int days) {
    return 'You haven\'t weighed in for $days days. Want to log your weight?';
  }

  @override
  String get pdfDiarioTitle => 'Food Diary';

  @override
  String get pdfTargetLabel => 'target';

  @override
  String pdfPagina(int page, int total) {
    return 'page $page of $total';
  }

  @override
  String get pdfNessunDato => 'No data recorded';

  @override
  String get pdfPastoFallback => 'Meal';

  @override
  String get pdfRiepilogo => 'SUMMARY';

  @override
  String pdfGiorniConDati(int withData, int days) {
    return 'Days with data: $withData/$days';
  }

  @override
  String pdfGiorniOnTarget(int onTarget, int total) {
    return 'Days on-target (90–105%): $onTarget/$total';
  }

  @override
  String get pdfMediaLabel => 'Daily average:';

  @override
  String get pdfTargetPrefix => 'Target:';

  @override
  String get pdfPianoTitle => 'Meal Plan';

  @override
  String pdfGenerato(String created) {
    return 'Generated on $created';
  }

  @override
  String get muscleGroupAll => 'All';

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupBack => 'Back';

  @override
  String get muscleGroupLegs => 'Legs';

  @override
  String get muscleGroupArms => 'Arms';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get muscleGroupCardio => 'Cardio';

  @override
  String get eserciziCatalogoTitle => 'Exercise catalog';

  @override
  String get eserciziCercaHint => 'Search exercise...';

  @override
  String get eserciziNessunRisultato => 'No exercise found';

  @override
  String get eserciziAggiungiPersonalizzato => 'Add custom exercise';

  @override
  String get eserciziPersonalizzatoBadge => 'Mine';

  @override
  String get eserciziNuovoTitle => 'New exercise';

  @override
  String get eserciziNomeLabel => 'Name';

  @override
  String get eserciziNomeHint => 'E.g. Machine chest press';

  @override
  String get eserciziGruppoMuscolareLabel => 'Muscle group';

  @override
  String get eserciziTipoLabel => 'Type';

  @override
  String get eserciziTipoForza => 'Strength';

  @override
  String get eserciziTipoCardio => 'Cardio';

  @override
  String get eserciziAttrezzaturaLabel => 'Equipment (optional)';

  @override
  String get eserciziAttrezzaturaHint => 'E.g. Dumbbells, bodyweight...';

  @override
  String get eserciziSalva => 'Save';

  @override
  String get eserciziNomeObbligatorio => 'Name is required';

  @override
  String get tabAllenamento => 'Workout';

  @override
  String get allenamentoVuotoTitle => 'No exercise today';

  @override
  String get allenamentoVuotoSub => 'Add your first exercise to get started';

  @override
  String get allenamentoAggiungiEsercizio => 'Add exercise';

  @override
  String allenamentoSerieCount(int n) {
    return '$n sets';
  }

  @override
  String allenamentoDurataMin(int min) {
    return '$min min';
  }

  @override
  String get allenamentoEliminaTitle => 'Delete exercise?';

  @override
  String get allenamentoEliminaSub =>
      'The exercise and its logged sets will be removed.';

  @override
  String serieDialogSerieLabel(int n) {
    return 'Set $n';
  }

  @override
  String get serieDialogRipHint => 'reps';

  @override
  String get serieDialogKgHint => 'kg';

  @override
  String get serieDialogAggiungiSerie => 'Add set';

  @override
  String get cardioDialogDurataLabel => 'Duration (minutes)';

  @override
  String get cardioDialogDurataHint => '30';

  @override
  String get homeAttivitaTitle => 'Activity';

  @override
  String get homeAttivitaKcalIngerite => 'Calories eaten';

  @override
  String get homeAttivitaKcalBruciate => 'Calories burned';

  @override
  String get homeAttivitaBilancioNetto => 'Net balance';
}
