import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Nome dell'applicazione
  ///
  /// In it, this message translates to:
  /// **'Plico'**
  String get appName;

  /// Etichetta pasto: colazione
  ///
  /// In it, this message translates to:
  /// **'Colazione'**
  String get pastoColazione;

  /// Etichetta pasto: pranzo
  ///
  /// In it, this message translates to:
  /// **'Pranzo'**
  String get pastoPranzo;

  /// Etichetta pasto: cena
  ///
  /// In it, this message translates to:
  /// **'Cena'**
  String get pastoCena;

  /// Etichetta pasto: spuntino
  ///
  /// In it, this message translates to:
  /// **'Spuntino'**
  String get pastoSpuntino;

  /// Etichetta pasto: spuntino post allenamento
  ///
  /// In it, this message translates to:
  /// **'Post-WO'**
  String get pastoPostWo;

  /// Etichetta pasto: spuntino serale
  ///
  /// In it, this message translates to:
  /// **'Spuntino serale'**
  String get pastoSpuntinoSerale;

  /// Etichetta slot: proteina
  ///
  /// In it, this message translates to:
  /// **'Proteina'**
  String get slotProteina;

  /// Etichetta slot: carboidrati
  ///
  /// In it, this message translates to:
  /// **'Carboidrati'**
  String get slotCarboidrati;

  /// Etichetta slot: verdura
  ///
  /// In it, this message translates to:
  /// **'Verdura'**
  String get slotVerdura;

  /// Etichetta slot: grassi
  ///
  /// In it, this message translates to:
  /// **'Grassi'**
  String get slotGrassi;

  /// Etichetta slot: extra (latticini, formaggi)
  ///
  /// In it, this message translates to:
  /// **'Extra'**
  String get slotExtra;

  /// Etichetta slot: frutta
  ///
  /// In it, this message translates to:
  /// **'Frutta'**
  String get slotFrutta;

  /// Tour: titolo tab Home
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get tourHomeTitle;

  /// Tour: descrizione tab Home
  ///
  /// In it, this message translates to:
  /// **'Il tuo riepilogo quotidiano: kcal consumate, macro, streak e il piano del giorno — tutto a colpo d\'occhio.'**
  String get tourHomeDesc;

  /// Tour: titolo tab Diario
  ///
  /// In it, this message translates to:
  /// **'Diario'**
  String get tourDiarioTitle;

  /// Tour: descrizione tab Diario
  ///
  /// In it, this message translates to:
  /// **'Registra ogni pasto della giornata. Tocca il \"+\" in alto per aggiungere un alimento o scannerizza un barcode.'**
  String get tourDiarioDesc;

  /// Tour: titolo tab Allenamento
  ///
  /// In it, this message translates to:
  /// **'Allenamento'**
  String get tourAllenamentoTitle;

  /// Tour: descrizione tab Allenamento
  ///
  /// In it, this message translates to:
  /// **'Registra i tuoi allenamenti, crea schede e programmi, e monitora il volume settimanale per gruppo muscolare.'**
  String get tourAllenamentoDesc;

  /// Tour: titolo tab Progressi
  ///
  /// In it, this message translates to:
  /// **'Progressi'**
  String get tourProgressiTitle;

  /// Tour: descrizione tab Progressi
  ///
  /// In it, this message translates to:
  /// **'Monitora il tuo peso nel tempo, guarda i badge guadagnati e il riepilogo settimanale.'**
  String get tourProgressiDesc;

  /// Tour: pulsante per saltare il tutorial
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get tourSkip;

  /// Tour: pulsante per andare al passo successivo
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get tourNext;

  /// Tour: pulsante finale per iniziare l'app
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get tourStart;

  /// Pulsante continua nell'onboarding
  ///
  /// In it, this message translates to:
  /// **'CONTINUA'**
  String get onboardingContinua;

  /// Pulsante indietro nell'onboarding
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get onboardingIndietro;

  /// Pulsante finale nell'onboarding
  ///
  /// In it, this message translates to:
  /// **'INIZIA'**
  String get onboardingInizia;

  /// Titolo step 1 onboarding
  ///
  /// In it, this message translates to:
  /// **'Benvenuto.\nDimmi come ti chiami.'**
  String get onboardingWelcomeTitle;

  /// Label campo nome
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get onboardingNomeLabel;

  /// Errore validazione campo nome
  ///
  /// In it, this message translates to:
  /// **'Inserisci il nome'**
  String get onboardingNomeError;

  /// Label campo cognome
  ///
  /// In it, this message translates to:
  /// **'Cognome'**
  String get onboardingCognomeLabel;

  /// Errore validazione campo cognome
  ///
  /// In it, this message translates to:
  /// **'Inserisci il cognome'**
  String get onboardingCognomeError;

  /// Titolo step 2 onboarding
  ///
  /// In it, this message translates to:
  /// **'Chi sei?'**
  String get onboardingChiSeiTitle;

  /// Label sezione sesso
  ///
  /// In it, this message translates to:
  /// **'SESSO'**
  String get onboardingSessoLabel;

  /// Opzione sesso: uomo
  ///
  /// In it, this message translates to:
  /// **'Uomo'**
  String get onboardingUomo;

  /// Opzione sesso: donna
  ///
  /// In it, this message translates to:
  /// **'Donna'**
  String get onboardingDonna;

  /// Label sezione data nascita
  ///
  /// In it, this message translates to:
  /// **'DATA DI NASCITA'**
  String get onboardingDataNascitaLabel;

  /// Placeholder selezione data nascita
  ///
  /// In it, this message translates to:
  /// **'Seleziona la data'**
  String get onboardingSelezionaData;

  /// Errore validazione step 2: sesso/data mancanti
  ///
  /// In it, this message translates to:
  /// **'Seleziona sesso e data di nascita'**
  String get onboardingSessoDataError;

  /// Titolo step 3 onboarding
  ///
  /// In it, this message translates to:
  /// **'Le tue misure'**
  String get onboardingMisureTitle;

  /// Label campo altezza
  ///
  /// In it, this message translates to:
  /// **'Altezza'**
  String get onboardingAltezzaLabel;

  /// Errore validazione altezza vuota
  ///
  /// In it, this message translates to:
  /// **'Inserisci l\'altezza'**
  String get onboardingAltezzaError;

  /// Errore validazione altezza fuori range
  ///
  /// In it, this message translates to:
  /// **'Altezza non valida'**
  String get onboardingAltezzaInvalid;

  /// Label campo peso
  ///
  /// In it, this message translates to:
  /// **'Peso attuale (opzionale)'**
  String get onboardingPesoLabel;

  /// Errore validazione peso fuori range
  ///
  /// In it, this message translates to:
  /// **'Peso non valido'**
  String get onboardingPesoInvalid;

  /// Label campo body fat
  ///
  /// In it, this message translates to:
  /// **'Body fat iniziale (opzionale)'**
  String get onboardingBodyFatLabel;

  /// Errore validazione body fat fuori range
  ///
  /// In it, this message translates to:
  /// **'Valore non valido (1–70%)'**
  String get onboardingBodyFatInvalid;

  /// Nota informativa sotto i campi misure
  ///
  /// In it, this message translates to:
  /// **'Peso e body fat sono opzionali. Se inseriti, verranno salvati come punto di partenza nello storico.'**
  String get onboardingMisureNote;

  /// Titolo step obiettivo
  ///
  /// In it, this message translates to:
  /// **'Qual è il tuo\nobiettivo?'**
  String get onboardingObiettivoTitle;

  /// No description provided for @onboardingObiettivo0Label.
  ///
  /// In it, this message translates to:
  /// **'Perdere peso'**
  String get onboardingObiettivo0Label;

  /// No description provided for @onboardingObiettivo0Sub.
  ///
  /// In it, this message translates to:
  /// **'Deficit −20%'**
  String get onboardingObiettivo0Sub;

  /// No description provided for @onboardingObiettivo0Desc.
  ///
  /// In it, this message translates to:
  /// **'Riduzione graduale del grasso corporeo mantenendo la massa muscolare'**
  String get onboardingObiettivo0Desc;

  /// No description provided for @onboardingObiettivo1Label.
  ///
  /// In it, this message translates to:
  /// **'Mantenermi'**
  String get onboardingObiettivo1Label;

  /// No description provided for @onboardingObiettivo1Sub.
  ///
  /// In it, this message translates to:
  /// **'Mantenimento'**
  String get onboardingObiettivo1Sub;

  /// No description provided for @onboardingObiettivo1Desc.
  ///
  /// In it, this message translates to:
  /// **'Ottimizza la composizione corporea senza cambiare il peso'**
  String get onboardingObiettivo1Desc;

  /// No description provided for @onboardingObiettivo2Label.
  ///
  /// In it, this message translates to:
  /// **'Aumentare massa'**
  String get onboardingObiettivo2Label;

  /// No description provided for @onboardingObiettivo2Sub.
  ///
  /// In it, this message translates to:
  /// **'Surplus +15%'**
  String get onboardingObiettivo2Sub;

  /// No description provided for @onboardingObiettivo2Desc.
  ///
  /// In it, this message translates to:
  /// **'Massimizza la crescita muscolare con un apporto calorico superiore'**
  String get onboardingObiettivo2Desc;

  /// Titolo step livello attività
  ///
  /// In it, this message translates to:
  /// **'Quanto sei attivo?'**
  String get onboardingAttivitaTitle;

  /// Sottotitolo step livello attività
  ///
  /// In it, this message translates to:
  /// **'Considera la tua attività media settimanale.'**
  String get onboardingAttivitaSubtitle;

  /// No description provided for @onboardingAttivita0Label.
  ///
  /// In it, this message translates to:
  /// **'Sedentario'**
  String get onboardingAttivita0Label;

  /// No description provided for @onboardingAttivita0Desc.
  ///
  /// In it, this message translates to:
  /// **'Lavoro sedentario, poco o nessun esercizio'**
  String get onboardingAttivita0Desc;

  /// No description provided for @onboardingAttivita1Label.
  ///
  /// In it, this message translates to:
  /// **'Legg. attivo'**
  String get onboardingAttivita1Label;

  /// No description provided for @onboardingAttivita1Desc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio leggero 1–3 giorni/settimana'**
  String get onboardingAttivita1Desc;

  /// No description provided for @onboardingAttivita2Label.
  ///
  /// In it, this message translates to:
  /// **'Mod. attivo'**
  String get onboardingAttivita2Label;

  /// No description provided for @onboardingAttivita2Desc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio moderato 3–5 giorni/settimana'**
  String get onboardingAttivita2Desc;

  /// No description provided for @onboardingAttivita3Label.
  ///
  /// In it, this message translates to:
  /// **'Molto attivo'**
  String get onboardingAttivita3Label;

  /// No description provided for @onboardingAttivita3Desc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio intenso 6–7 giorni/settimana'**
  String get onboardingAttivita3Desc;

  /// No description provided for @onboardingAttivita4Label.
  ///
  /// In it, this message translates to:
  /// **'Atleta'**
  String get onboardingAttivita4Label;

  /// No description provided for @onboardingAttivita4Desc.
  ///
  /// In it, this message translates to:
  /// **'Lavoro fisico intenso o doppio allenamento'**
  String get onboardingAttivita4Desc;

  /// Titolo step scelta tema
  ///
  /// In it, this message translates to:
  /// **'Scegli il tema'**
  String get onboardingTemaTitle;

  /// Sottotitolo step scelta tema
  ///
  /// In it, this message translates to:
  /// **'Potrai cambiarlo in qualsiasi momento dall\'app.'**
  String get onboardingTemaSubtitle;

  /// Opzione tema chiaro
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get onboardingTemaChiaro;

  /// Opzione tema scuro
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get onboardingTemaScuro;

  /// No description provided for @homeSalutoBuongiorno.
  ///
  /// In it, this message translates to:
  /// **'Buongiorno'**
  String get homeSalutoBuongiorno;

  /// No description provided for @homeSalutoBuonPomeriggio.
  ///
  /// In it, this message translates to:
  /// **'Buon pomeriggio'**
  String get homeSalutoBuonPomeriggio;

  /// No description provided for @homeSalutoBuonasera.
  ///
  /// In it, this message translates to:
  /// **'Buonasera'**
  String get homeSalutoBuonasera;

  /// No description provided for @homeFallbackNome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto'**
  String get homeFallbackNome;

  /// No description provided for @homeDiarioDiOggi.
  ///
  /// In it, this message translates to:
  /// **'DIARIO DI OGGI'**
  String get homeDiarioDiOggi;

  /// No description provided for @homeTdeeKcalGiorno.
  ///
  /// In it, this message translates to:
  /// **'{kcal} kcal/giorno'**
  String homeTdeeKcalGiorno(String kcal);

  /// No description provided for @homePesoLabel.
  ///
  /// In it, this message translates to:
  /// **'PESO'**
  String get homePesoLabel;

  /// No description provided for @homeNessunaPesata.
  ///
  /// In it, this message translates to:
  /// **'Nessuna pesata registrata'**
  String get homeNessunaPesata;

  /// No description provided for @homeBmiSottopeso.
  ///
  /// In it, this message translates to:
  /// **'Sottopeso'**
  String get homeBmiSottopeso;

  /// No description provided for @homeBmiNormopeso.
  ///
  /// In it, this message translates to:
  /// **'Normopeso'**
  String get homeBmiNormopeso;

  /// No description provided for @homeBmiSovrappeso.
  ///
  /// In it, this message translates to:
  /// **'Sovrappeso'**
  String get homeBmiSovrappeso;

  /// No description provided for @homeBmiObesitaI.
  ///
  /// In it, this message translates to:
  /// **'Obesità I'**
  String get homeBmiObesitaI;

  /// No description provided for @homeBmiObesitaII.
  ///
  /// In it, this message translates to:
  /// **'Obesità II+'**
  String get homeBmiObesitaII;

  /// No description provided for @homePesoObiettivoRaggiunto.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo raggiunto 🎉'**
  String get homePesoObiettivoRaggiunto;

  /// No description provided for @homePesoAlObiettivo.
  ///
  /// In it, this message translates to:
  /// **'{delta} kg dall\'obiettivo'**
  String homePesoAlObiettivo(String delta);

  /// No description provided for @homePlicoLabel.
  ///
  /// In it, this message translates to:
  /// **'PLICOMETRIA'**
  String get homePlicoLabel;

  /// No description provided for @homePlicoMassaGrassa.
  ///
  /// In it, this message translates to:
  /// **'Massa Grassa'**
  String get homePlicoMassaGrassa;

  /// No description provided for @homePlicoMassaMagra.
  ///
  /// In it, this message translates to:
  /// **'Massa Magra'**
  String get homePlicoMassaMagra;

  /// No description provided for @homeNessunaSessionePlico.
  ///
  /// In it, this message translates to:
  /// **'Nessuna sessione registrata'**
  String get homeNessunaSessionePlico;

  /// No description provided for @homePlicoCalcolaBtn.
  ///
  /// In it, this message translates to:
  /// **'Calcola Plicometria'**
  String get homePlicoCalcolaBtn;

  /// No description provided for @homeCirconferenzeLabel.
  ///
  /// In it, this message translates to:
  /// **'CIRCONFERENZE'**
  String get homeCirconferenzeLabel;

  /// No description provided for @homeCirconferenzeNessuna.
  ///
  /// In it, this message translates to:
  /// **'Nessuna misurazione registrata'**
  String get homeCirconferenzeNessuna;

  /// No description provided for @homeCirconferenzeNuovaBtn.
  ///
  /// In it, this message translates to:
  /// **'Nuova Misurazione'**
  String get homeCirconferenzeNuovaBtn;

  /// No description provided for @homeRiepilogoSettimanale.
  ///
  /// In it, this message translates to:
  /// **'RIEPILOGO SETTIMANALE'**
  String get homeRiepilogoSettimanale;

  /// No description provided for @homeNessunDato.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato'**
  String get homeNessunDato;

  /// No description provided for @homeMediaKcal.
  ///
  /// In it, this message translates to:
  /// **'Media kcal'**
  String get homeMediaKcal;

  /// No description provided for @homeWeeklyAvgKcal.
  ///
  /// In it, this message translates to:
  /// **'{kcal} kcal/g'**
  String homeWeeklyAvgKcal(String kcal);

  /// No description provided for @homeVariazionePeso.
  ///
  /// In it, this message translates to:
  /// **'Variazione peso'**
  String get homeVariazionePeso;

  /// No description provided for @homeAderenzaAlPiano.
  ///
  /// In it, this message translates to:
  /// **'Aderenza al piano'**
  String get homeAderenzaAlPiano;

  /// No description provided for @homeAderenzaHeader.
  ///
  /// In it, this message translates to:
  /// **'ADERENZA AL PIANO'**
  String get homeAderenzaHeader;

  /// No description provided for @homePastiOggi.
  ///
  /// In it, this message translates to:
  /// **'pasti oggi'**
  String get homePastiOggi;

  /// No description provided for @homeUltimiSetteGiorni.
  ///
  /// In it, this message translates to:
  /// **'ultimi 7 giorni'**
  String get homeUltimiSetteGiorni;

  /// No description provided for @homeStreakTitle.
  ///
  /// In it, this message translates to:
  /// **'Streak'**
  String get homeStreakTitle;

  /// No description provided for @homeBadge1KgPerso.
  ///
  /// In it, this message translates to:
  /// **'1° kg perso'**
  String get homeBadge1KgPerso;

  /// No description provided for @homeBadgeStreak7.
  ///
  /// In it, this message translates to:
  /// **'Streak 7gg'**
  String get homeBadgeStreak7;

  /// No description provided for @homeBadgeStreak30.
  ///
  /// In it, this message translates to:
  /// **'Streak 30gg'**
  String get homeBadgeStreak30;

  /// No description provided for @homeBadgeStreak100.
  ///
  /// In it, this message translates to:
  /// **'Streak 100gg'**
  String get homeBadgeStreak100;

  /// No description provided for @homeBadge30Giorni.
  ///
  /// In it, this message translates to:
  /// **'30 giorni'**
  String get homeBadge30Giorni;

  /// No description provided for @homeBadgeSettimanaTarget.
  ///
  /// In it, this message translates to:
  /// **'Settimana in target'**
  String get homeBadgeSettimanaTarget;

  /// No description provided for @homeBadgePrimaScheda.
  ///
  /// In it, this message translates to:
  /// **'Prima scheda'**
  String get homeBadgePrimaScheda;

  /// No description provided for @homeBadgeStreak7Allenamento.
  ///
  /// In it, this message translates to:
  /// **'7gg allenamento'**
  String get homeBadgeStreak7Allenamento;

  /// No description provided for @homeBadgeStreak30Allenamento.
  ///
  /// In it, this message translates to:
  /// **'30gg allenamento'**
  String get homeBadgeStreak30Allenamento;

  /// No description provided for @homeBadgeStreak100Allenamento.
  ///
  /// In it, this message translates to:
  /// **'100gg allenamento'**
  String get homeBadgeStreak100Allenamento;

  /// No description provided for @homeBadgeNuovoPr.
  ///
  /// In it, this message translates to:
  /// **'Nuovo PR'**
  String get homeBadgeNuovoPr;

  /// No description provided for @homeBadge10Sessioni.
  ///
  /// In it, this message translates to:
  /// **'10 sessioni'**
  String get homeBadge10Sessioni;

  /// No description provided for @homeBadge50Sessioni.
  ///
  /// In it, this message translates to:
  /// **'50 sessioni'**
  String get homeBadge50Sessioni;

  /// No description provided for @diarioTitolo.
  ///
  /// In it, this message translates to:
  /// **'DIARIO'**
  String get diarioTitolo;

  /// No description provided for @diarioTabPiano.
  ///
  /// In it, this message translates to:
  /// **'PIANO'**
  String get diarioTabPiano;

  /// No description provided for @diarioTabDiario.
  ///
  /// In it, this message translates to:
  /// **'DIARIO'**
  String get diarioTabDiario;

  /// No description provided for @diarioTabTdee.
  ///
  /// In it, this message translates to:
  /// **'TDEE'**
  String get diarioTabTdee;

  /// No description provided for @diarioSalvaComePref.
  ///
  /// In it, this message translates to:
  /// **'Salva come preferito'**
  String get diarioSalvaComePref;

  /// No description provided for @diarioSalvaHint.
  ///
  /// In it, this message translates to:
  /// **'Es. La mia colazione'**
  String get diarioSalvaHint;

  /// No description provided for @diarioAnnulla.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get diarioAnnulla;

  /// No description provided for @diarioBtnSalva.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get diarioBtnSalva;

  /// No description provided for @diarioSalvatoComePref.
  ///
  /// In it, this message translates to:
  /// **'Salvato come preferito: {nome}'**
  String diarioSalvatoComePref(String nome);

  /// No description provided for @diarioOggi.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get diarioOggi;

  /// No description provided for @diarioIeri.
  ///
  /// In it, this message translates to:
  /// **'Ieri'**
  String get diarioIeri;

  /// No description provided for @diarioKcalObiettivo.
  ///
  /// In it, this message translates to:
  /// **'di {target} obiettivo'**
  String diarioKcalObiettivo(String target);

  /// No description provided for @diarioNessunObiettivo.
  ///
  /// In it, this message translates to:
  /// **'nessun obiettivo impostato'**
  String get diarioNessunObiettivo;

  /// No description provided for @diarioObiettivoRaggiunto.
  ///
  /// In it, this message translates to:
  /// **'obiettivo raggiunto'**
  String get diarioObiettivoRaggiunto;

  /// No description provided for @diarioKcalRimanenti.
  ///
  /// In it, this message translates to:
  /// **'{kcal} rimanenti'**
  String diarioKcalRimanenti(String kcal);

  /// No description provided for @diarioOttimoLavoro.
  ///
  /// In it, this message translates to:
  /// **'Ottimo lavoro! Sei nei target di oggi.'**
  String get diarioOttimoLavoro;

  /// No description provided for @diarioMacroProteine.
  ///
  /// In it, this message translates to:
  /// **'Proteine'**
  String get diarioMacroProteine;

  /// No description provided for @diarioMacroGrassi.
  ///
  /// In it, this message translates to:
  /// **'Grassi'**
  String get diarioMacroGrassi;

  /// No description provided for @diarioMacroCarbo.
  ///
  /// In it, this message translates to:
  /// **'Carbo'**
  String get diarioMacroCarbo;

  /// No description provided for @diarioNessunAlimento.
  ///
  /// In it, this message translates to:
  /// **'Nessun alimento registrato'**
  String get diarioNessunAlimento;

  /// No description provided for @diarioRipetiIeri.
  ///
  /// In it, this message translates to:
  /// **'Ripeti pasto di ieri'**
  String get diarioRipetiIeri;

  /// No description provided for @aggiuntiA.
  ///
  /// In it, this message translates to:
  /// **'AGGIUNGI A {pasto}'**
  String aggiuntiA(String pasto);

  /// No description provided for @aggiuntiPastiPreferiti.
  ///
  /// In it, this message translates to:
  /// **'I TUOI PASTI PREFERITI'**
  String get aggiuntiPastiPreferiti;

  /// No description provided for @aggiuntiDalPiano.
  ///
  /// In it, this message translates to:
  /// **'DAL TUO PIANO'**
  String get aggiuntiDalPiano;

  /// No description provided for @aggiuntiTuoiAlimenti.
  ///
  /// In it, this message translates to:
  /// **'I TUOI ALIMENTI'**
  String get aggiuntiTuoiAlimenti;

  /// No description provided for @aggiuntiAlimentiSalvati.
  ///
  /// In it, this message translates to:
  /// **'ALIMENTI SALVATI'**
  String get aggiuntiAlimentiSalvati;

  /// No description provided for @aggiuntiRisultatiOFF.
  ///
  /// In it, this message translates to:
  /// **'RISULTATI OPEN FOOD FACTS'**
  String get aggiuntiRisultatiOFF;

  /// No description provided for @aggiuntiNessunRisultato.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato trovato.\nProva a creare un alimento manuale.'**
  String get aggiuntiNessunRisultato;

  /// No description provided for @aggiuntiCreaManuale.
  ///
  /// In it, this message translates to:
  /// **'Crea alimento manuale'**
  String get aggiuntiCreaManuale;

  /// No description provided for @aggiuntiQuantitaG.
  ///
  /// In it, this message translates to:
  /// **'Quantità (g)'**
  String get aggiuntiQuantitaG;

  /// No description provided for @aggiuntiAggiungi.
  ///
  /// In it, this message translates to:
  /// **'AGGIUNGI'**
  String get aggiuntiAggiungi;

  /// No description provided for @aggiuntiCreaAlimento.
  ///
  /// In it, this message translates to:
  /// **'CREA ALIMENTO'**
  String get aggiuntiCreaAlimento;

  /// No description provided for @aggiuntiNome.
  ///
  /// In it, this message translates to:
  /// **'Nome *'**
  String get aggiuntiNome;

  /// No description provided for @aggiuntiBrand.
  ///
  /// In it, this message translates to:
  /// **'Brand (opzionale)'**
  String get aggiuntiBrand;

  /// No description provided for @aggiuntiKcal100g.
  ///
  /// In it, this message translates to:
  /// **'Kcal/100g *'**
  String get aggiuntiKcal100g;

  /// No description provided for @aggiuntiProteine100g.
  ///
  /// In it, this message translates to:
  /// **'Proteine/100g'**
  String get aggiuntiProteine100g;

  /// No description provided for @aggiuntiGrassi100g.
  ///
  /// In it, this message translates to:
  /// **'Grassi/100g'**
  String get aggiuntiGrassi100g;

  /// No description provided for @aggiuntiCarbo100g.
  ///
  /// In it, this message translates to:
  /// **'Carbo/100g'**
  String get aggiuntiCarbo100g;

  /// No description provided for @aggiuntiSalvaAggiungi.
  ///
  /// In it, this message translates to:
  /// **'SALVA E AGGIUNGI'**
  String get aggiuntiSalvaAggiungi;

  /// No description provided for @aggiuntiCercaHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca alimento o marca...'**
  String get aggiuntiCercaHint;

  /// No description provided for @questionarioTitolo.
  ///
  /// In it, this message translates to:
  /// **'PREFERENZE ALIMENTARI'**
  String get questionarioTitolo;

  /// No description provided for @questionarioIndietro.
  ///
  /// In it, this message translates to:
  /// **'INDIETRO'**
  String get questionarioIndietro;

  /// No description provided for @questionarioAvanti.
  ///
  /// In it, this message translates to:
  /// **'AVANTI'**
  String get questionarioAvanti;

  /// No description provided for @questionarioSalvaGenera.
  ///
  /// In it, this message translates to:
  /// **'SALVA E GENERA'**
  String get questionarioSalvaGenera;

  /// No description provided for @questionarioRestrizioni.
  ///
  /// In it, this message translates to:
  /// **'Restrizioni'**
  String get questionarioRestrizioni;

  /// No description provided for @questionarioRestrizioniSub.
  ///
  /// In it, this message translates to:
  /// **'Seleziona eventuali restrizioni dietetiche. Puoi saltare se non hai vincoli.'**
  String get questionarioRestrizioniSub;

  /// No description provided for @questionarioVegetariano.
  ///
  /// In it, this message translates to:
  /// **'Vegetariano'**
  String get questionarioVegetariano;

  /// No description provided for @questionarioVegano.
  ///
  /// In it, this message translates to:
  /// **'Vegano'**
  String get questionarioVegano;

  /// No description provided for @questionarioNoLattosio.
  ///
  /// In it, this message translates to:
  /// **'No lattosio'**
  String get questionarioNoLattosio;

  /// No description provided for @questionarioNoGlutine.
  ///
  /// In it, this message translates to:
  /// **'No glutine'**
  String get questionarioNoGlutine;

  /// No description provided for @questionarioNoPesce.
  ///
  /// In it, this message translates to:
  /// **'No pesce'**
  String get questionarioNoPesce;

  /// No description provided for @questionarioNoFruttaSecca.
  ///
  /// In it, this message translates to:
  /// **'No frutta secca'**
  String get questionarioNoFruttaSecca;

  /// No description provided for @questionarioNessunaRestrizione.
  ///
  /// In it, this message translates to:
  /// **'Nessuna restrizione — ottimo!'**
  String get questionarioNessunaRestrizione;

  /// No description provided for @questionarioPreferenze.
  ///
  /// In it, this message translates to:
  /// **'Preferenze'**
  String get questionarioPreferenze;

  /// No description provided for @questionarioPreferenzeSub.
  ///
  /// In it, this message translates to:
  /// **'Seleziona gli alimenti che ti piacciono. Il piano darà priorità alle tue scelte.'**
  String get questionarioPreferenzeSub;

  /// No description provided for @questionarioStruttura.
  ///
  /// In it, this message translates to:
  /// **'Struttura'**
  String get questionarioStruttura;

  /// No description provided for @questionarioStrutturaSub.
  ///
  /// In it, this message translates to:
  /// **'Come organizzi i tuoi pasti?'**
  String get questionarioStrutturaSub;

  /// No description provided for @questionarioPastiGiorno.
  ///
  /// In it, this message translates to:
  /// **'Pasti al giorno'**
  String get questionarioPastiGiorno;

  /// No description provided for @questionarioSpuntinoPostWo.
  ///
  /// In it, this message translates to:
  /// **'Spuntino post-allenamento'**
  String get questionarioSpuntinoPostWo;

  /// No description provided for @questionarioSpuntinoPostWoSub.
  ///
  /// In it, this message translates to:
  /// **'Include quota proteica extra per il recupero'**
  String get questionarioSpuntinoPostWoSub;

  /// No description provided for @pianoGenerazioneInCorso.
  ///
  /// In it, this message translates to:
  /// **'Generazione piano in corso…'**
  String get pianoGenerazioneInCorso;

  /// No description provided for @pianoPianoAlimentare.
  ///
  /// In it, this message translates to:
  /// **'Piano Alimentare'**
  String get pianoPianoAlimentare;

  /// No description provided for @pianoPromoSub.
  ///
  /// In it, this message translates to:
  /// **'Dicci le tue preferenze alimentari e generiamo un piano personalizzato sui tuoi macro target.'**
  String get pianoPromoSub;

  /// No description provided for @pianoIniziaQuestionario.
  ///
  /// In it, this message translates to:
  /// **'INIZIA QUESTIONARIO'**
  String get pianoIniziaQuestionario;

  /// No description provided for @pianoPreferenzeSalvate.
  ///
  /// In it, this message translates to:
  /// **'Preferenze salvate'**
  String get pianoPreferenzeSalvate;

  /// No description provided for @pianoProntoGenerare.
  ///
  /// In it, this message translates to:
  /// **'Pronto per generare il tuo piano alimentare.'**
  String get pianoProntoGenerare;

  /// No description provided for @pianoGeneraPiano.
  ///
  /// In it, this message translates to:
  /// **'GENERA PIANO'**
  String get pianoGeneraPiano;

  /// No description provided for @pianoModificaPreferenze.
  ///
  /// In it, this message translates to:
  /// **'Modifica preferenze'**
  String get pianoModificaPreferenze;

  /// No description provided for @pianoEsportaPdf.
  ///
  /// In it, this message translates to:
  /// **'Esporta PDF'**
  String get pianoEsportaPdf;

  /// No description provided for @pianoObiettiviCambiati.
  ///
  /// In it, this message translates to:
  /// **'I tuoi obiettivi sono cambiati. Rigenera il piano per aggiornare le grammature.'**
  String get pianoObiettiviCambiati;

  /// No description provided for @pianoRigenera.
  ///
  /// In it, this message translates to:
  /// **'RIGENERA'**
  String get pianoRigenera;

  /// No description provided for @pianoGeneratoIl.
  ///
  /// In it, this message translates to:
  /// **'Generato il {data}'**
  String pianoGeneratoIl(String data);

  /// No description provided for @pianoAttivo.
  ///
  /// In it, this message translates to:
  /// **'ATTIVO'**
  String get pianoAttivo;

  /// No description provided for @pianoGrammatureCrudo.
  ///
  /// In it, this message translates to:
  /// **'Grammature da pesare a crudo'**
  String get pianoGrammatureCrudo;

  /// No description provided for @pianoKcalNote.
  ///
  /// In it, this message translates to:
  /// **'Le kcal del piano possono differire leggermente dal target del diario per via degli arrotondamenti sulle grammature'**
  String get pianoKcalNote;

  /// No description provided for @pianoQbRiferimento.
  ///
  /// In it, this message translates to:
  /// **'q.b.  ·  ~{g} g come riferimento'**
  String pianoQbRiferimento(String g);

  /// No description provided for @pianoQb.
  ///
  /// In it, this message translates to:
  /// **'q.b.  ·  ~{g} g'**
  String pianoQb(String g);

  /// No description provided for @pianoNascondiAlternative.
  ///
  /// In it, this message translates to:
  /// **'Nascondi alternative'**
  String get pianoNascondiAlternative;

  /// No description provided for @pianoNAlternative.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, one{{count} alternativa} other{{count} alternative}}'**
  String pianoNAlternative(int count);

  /// No description provided for @pianoAggiungiAlDiario.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi al diario'**
  String get pianoAggiungiAlDiario;

  /// No description provided for @pianoSuggerito.
  ///
  /// In it, this message translates to:
  /// **'Suggerito'**
  String get pianoSuggerito;

  /// No description provided for @pianoAggiunto.
  ///
  /// In it, this message translates to:
  /// **'Aggiunto a {pasto}'**
  String pianoAggiunto(String pasto);

  /// No description provided for @pianoErrorePdf.
  ///
  /// In it, this message translates to:
  /// **'Errore durante la generazione del PDF'**
  String get pianoErrorePdf;

  /// No description provided for @pianoStileDolce.
  ///
  /// In it, this message translates to:
  /// **'🍯 Dolce'**
  String get pianoStileDolce;

  /// No description provided for @pianoStileSalata.
  ///
  /// In it, this message translates to:
  /// **'🧀 Salata'**
  String get pianoStileSalata;

  /// No description provided for @appElimina.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get appElimina;

  /// No description provided for @progressiTitolo.
  ///
  /// In it, this message translates to:
  /// **'PROGRESSI'**
  String get progressiTitolo;

  /// No description provided for @progressiTooltipEsporta.
  ///
  /// In it, this message translates to:
  /// **'Esporta PDF'**
  String get progressiTooltipEsporta;

  /// No description provided for @progressiTooltipStorico.
  ///
  /// In it, this message translates to:
  /// **'Storico misurazioni'**
  String get progressiTooltipStorico;

  /// No description provided for @progressiTooltipRecord.
  ///
  /// In it, this message translates to:
  /// **'I tuoi record'**
  String get progressiTooltipRecord;

  /// No description provided for @progressiTooltipVolume.
  ///
  /// In it, this message translates to:
  /// **'Volume settimanale'**
  String get progressiTooltipVolume;

  /// No description provided for @progressiSezPeso.
  ///
  /// In it, this message translates to:
  /// **'PESO'**
  String get progressiSezPeso;

  /// No description provided for @progressiSezSalute.
  ///
  /// In it, this message translates to:
  /// **'SALUTE'**
  String get progressiSezSalute;

  /// No description provided for @progressiSaluteSonno.
  ///
  /// In it, this message translates to:
  /// **'Sonno'**
  String get progressiSaluteSonno;

  /// No description provided for @progressiSaluteFcRiposo.
  ///
  /// In it, this message translates to:
  /// **'FC a riposo'**
  String get progressiSaluteFcRiposo;

  /// No description provided for @progressiSaluteHrv.
  ///
  /// In it, this message translates to:
  /// **'HRV'**
  String get progressiSaluteHrv;

  /// No description provided for @progressiSalutePassi.
  ///
  /// In it, this message translates to:
  /// **'Passi'**
  String get progressiSalutePassi;

  /// No description provided for @progressiSaluteKcalTotali.
  ///
  /// In it, this message translates to:
  /// **'Kcal totali'**
  String get progressiSaluteKcalTotali;

  /// No description provided for @progressiSaluteMinutiSettimana.
  ///
  /// In it, this message translates to:
  /// **'{minuti} min questa settimana'**
  String progressiSaluteMinutiSettimana(int minuti);

  /// No description provided for @progressiSezComposizione.
  ///
  /// In it, this message translates to:
  /// **'COMPOSIZIONE CORPOREA'**
  String get progressiSezComposizione;

  /// No description provided for @progressiSezMisurazioni.
  ///
  /// In it, this message translates to:
  /// **'MISURAZIONI'**
  String get progressiSezMisurazioni;

  /// No description provided for @progressiSezAllenamentiPdf.
  ///
  /// In it, this message translates to:
  /// **'ALLENAMENTI'**
  String get progressiSezAllenamentiPdf;

  /// No description provided for @progressiRange1A.
  ///
  /// In it, this message translates to:
  /// **'1A'**
  String get progressiRange1A;

  /// No description provided for @progressiRangeTutto.
  ///
  /// In it, this message translates to:
  /// **'Tutto'**
  String get progressiRangeTutto;

  /// No description provided for @progressiMassaGrassa.
  ///
  /// In it, this message translates to:
  /// **'Massa Grassa'**
  String get progressiMassaGrassa;

  /// No description provided for @progressiMassaMagra.
  ///
  /// In it, this message translates to:
  /// **'Massa Magra'**
  String get progressiMassaMagra;

  /// No description provided for @pdfColData.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get pdfColData;

  /// No description provided for @pdfColPeso.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get pdfColPeso;

  /// No description provided for @pdfColBf.
  ///
  /// In it, this message translates to:
  /// **'BF%'**
  String get pdfColBf;

  /// No description provided for @pdfColEsercizio.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get pdfColEsercizio;

  /// No description provided for @pdfColDettaglio.
  ///
  /// In it, this message translates to:
  /// **'Dettaglio'**
  String get pdfColDettaglio;

  /// No description provided for @progressiProteine.
  ///
  /// In it, this message translates to:
  /// **'Proteine'**
  String get progressiProteine;

  /// No description provided for @progressiGrassi.
  ///
  /// In it, this message translates to:
  /// **'Grassi'**
  String get progressiGrassi;

  /// No description provided for @progressiCarboidrati.
  ///
  /// In it, this message translates to:
  /// **'Carboidrati'**
  String get progressiCarboidrati;

  /// No description provided for @progressiNessunDato.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato nel periodo selezionato'**
  String get progressiNessunDato;

  /// No description provided for @progressiMedia7gg.
  ///
  /// In it, this message translates to:
  /// **'media 7gg: {val} {unit}'**
  String progressiMedia7gg(String val, String unit);

  /// No description provided for @progressiStatUltimo.
  ///
  /// In it, this message translates to:
  /// **'Ultimo'**
  String get progressiStatUltimo;

  /// No description provided for @progressiStatVariazione.
  ///
  /// In it, this message translates to:
  /// **'Variazione'**
  String get progressiStatVariazione;

  /// No description provided for @progressiStatRilevazioni.
  ///
  /// In it, this message translates to:
  /// **'Rilevazioni'**
  String get progressiStatRilevazioni;

  /// No description provided for @progressiGenerazionePdf.
  ///
  /// In it, this message translates to:
  /// **'Generazione PDF...'**
  String get progressiGenerazionePdf;

  /// No description provided for @progressiErrEsportazione.
  ///
  /// In it, this message translates to:
  /// **'Errore nell\'esportazione: {err}'**
  String progressiErrEsportazione(String err);

  /// No description provided for @pesateTitolo.
  ///
  /// In it, this message translates to:
  /// **'PESATE'**
  String get pesateTitolo;

  /// No description provided for @pesateEliminaTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina pesata'**
  String get pesateEliminaTitle;

  /// No description provided for @pesateEliminaSub.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare questa misurazione?'**
  String get pesateEliminaSub;

  /// No description provided for @pesateNessuna.
  ///
  /// In it, this message translates to:
  /// **'Nessuna pesata'**
  String get pesateNessuna;

  /// No description provided for @pesateNessunaSub.
  ///
  /// In it, this message translates to:
  /// **'Premi + per aggiungere\nla prima misurazione'**
  String get pesateNessunaSub;

  /// No description provided for @pesateNuova.
  ///
  /// In it, this message translates to:
  /// **'NUOVA PESATA'**
  String get pesateNuova;

  /// No description provided for @pesateData.
  ///
  /// In it, this message translates to:
  /// **'DATA'**
  String get pesateData;

  /// No description provided for @pesatePeso.
  ///
  /// In it, this message translates to:
  /// **'PESO *'**
  String get pesatePeso;

  /// No description provided for @pesateCampoObb.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get pesateCampoObb;

  /// No description provided for @pesatePesoInvalido.
  ///
  /// In it, this message translates to:
  /// **'Peso non valido'**
  String get pesatePesoInvalido;

  /// No description provided for @pesateAltezzaOpz.
  ///
  /// In it, this message translates to:
  /// **'ALTEZZA (opzionale)'**
  String get pesateAltezzaOpz;

  /// No description provided for @pesateAltezzaHint.
  ///
  /// In it, this message translates to:
  /// **'Solo se diversa dal profilo'**
  String get pesateAltezzaHint;

  /// No description provided for @pesateAltezzaInvalida.
  ///
  /// In it, this message translates to:
  /// **'Altezza non valida'**
  String get pesateAltezzaInvalida;

  /// No description provided for @pesateBodyFatOpz.
  ///
  /// In it, this message translates to:
  /// **'BODY FAT (opzionale)'**
  String get pesateBodyFatOpz;

  /// No description provided for @pesateBodyFatHint.
  ///
  /// In it, this message translates to:
  /// **'Es. da bilancia impedenziometrica'**
  String get pesateBodyFatHint;

  /// No description provided for @pesateBodyFatInvalido.
  ///
  /// In it, this message translates to:
  /// **'Valore non valido (1–70%)'**
  String get pesateBodyFatInvalido;

  /// No description provided for @pesateNoteOpz.
  ///
  /// In it, this message translates to:
  /// **'NOTE (opzionale)'**
  String get pesateNoteOpz;

  /// No description provided for @pesateNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Es. mattina a digiuno...'**
  String get pesateNoteHint;

  /// No description provided for @pesateSalva.
  ///
  /// In it, this message translates to:
  /// **'SALVA PESATA'**
  String get pesateSalva;

  /// No description provided for @storicoMisurazioni.
  ///
  /// In it, this message translates to:
  /// **'MISURAZIONI'**
  String get storicoMisurazioni;

  /// No description provided for @storicoEliminaTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina misurazione'**
  String get storicoEliminaTitle;

  /// No description provided for @storicoEliminaSub.
  ///
  /// In it, this message translates to:
  /// **'Eliminare i dati di questa giornata?'**
  String get storicoEliminaSub;

  /// No description provided for @storicoFonteManuale.
  ///
  /// In it, this message translates to:
  /// **'Manuale'**
  String get storicoFonteManuale;

  /// No description provided for @storicoNessuna.
  ///
  /// In it, this message translates to:
  /// **'Nessuna misurazione'**
  String get storicoNessuna;

  /// No description provided for @storicoNessunaSub.
  ///
  /// In it, this message translates to:
  /// **'Le misurazioni appariranno qui\ndopo una sessione o un inserimento manuale.'**
  String get storicoNessunaSub;

  /// No description provided for @misurazioneNuova.
  ///
  /// In it, this message translates to:
  /// **'NUOVA MISURAZIONE'**
  String get misurazioneNuova;

  /// No description provided for @misurazioneModifica.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get misurazioneModifica;

  /// No description provided for @misurazioneTabPliche.
  ///
  /// In it, this message translates to:
  /// **'PLICHE'**
  String get misurazioneTabPliche;

  /// No description provided for @misurazioneTabCirconferenze.
  ///
  /// In it, this message translates to:
  /// **'CIRCONFERENZE'**
  String get misurazioneTabCirconferenze;

  /// No description provided for @misurazioneSalva.
  ///
  /// In it, this message translates to:
  /// **'SALVA MISURAZIONE'**
  String get misurazioneSalva;

  /// No description provided for @misurazioneInserisciValore.
  ///
  /// In it, this message translates to:
  /// **'Inserisci almeno un valore'**
  String get misurazioneInserisciValore;

  /// No description provided for @misurazioneCalibrazione.
  ///
  /// In it, this message translates to:
  /// **'Calibrazione punti'**
  String get misurazioneCalibrazione;

  /// No description provided for @misurazioneContPliche.
  ///
  /// In it, this message translates to:
  /// **'{count} pliche'**
  String misurazioneContPliche(String count);

  /// No description provided for @misurazioneContCirconferenze.
  ///
  /// In it, this message translates to:
  /// **'{count} circonf.'**
  String misurazioneContCirconferenze(String count);

  /// No description provided for @misuraVita.
  ///
  /// In it, this message translates to:
  /// **'Vita'**
  String get misuraVita;

  /// No description provided for @misuraFianchi.
  ///
  /// In it, this message translates to:
  /// **'Fianchi'**
  String get misuraFianchi;

  /// No description provided for @misuraBraccio.
  ///
  /// In it, this message translates to:
  /// **'Braccio'**
  String get misuraBraccio;

  /// No description provided for @misuraCollo.
  ///
  /// In it, this message translates to:
  /// **'Collo'**
  String get misuraCollo;

  /// No description provided for @misuraCoscia.
  ///
  /// In it, this message translates to:
  /// **'Coscia'**
  String get misuraCoscia;

  /// No description provided for @misuraPolpaccio.
  ///
  /// In it, this message translates to:
  /// **'Polpaccio'**
  String get misuraPolpaccio;

  /// No description provided for @misuraTorace.
  ///
  /// In it, this message translates to:
  /// **'Torace'**
  String get misuraTorace;

  /// No description provided for @misuraSpalle.
  ///
  /// In it, this message translates to:
  /// **'Spalle'**
  String get misuraSpalle;

  /// No description provided for @misuraTricipite.
  ///
  /// In it, this message translates to:
  /// **'Tricipite'**
  String get misuraTricipite;

  /// No description provided for @misuraBicipite.
  ///
  /// In it, this message translates to:
  /// **'Bicipite'**
  String get misuraBicipite;

  /// No description provided for @misuraSottoscap.
  ///
  /// In it, this message translates to:
  /// **'Sottoscap.'**
  String get misuraSottoscap;

  /// No description provided for @misuraSottoscapolare.
  ///
  /// In it, this message translates to:
  /// **'Sottoscapolare'**
  String get misuraSottoscapolare;

  /// No description provided for @misuraSovrailiaca.
  ///
  /// In it, this message translates to:
  /// **'Sovrailiaca'**
  String get misuraSovrailiaca;

  /// No description provided for @misuraAddome.
  ///
  /// In it, this message translates to:
  /// **'Addome'**
  String get misuraAddome;

  /// No description provided for @misuraCosciaPlica.
  ///
  /// In it, this message translates to:
  /// **'Coscia (pl.)'**
  String get misuraCosciaPlica;

  /// No description provided for @misuraPettorale.
  ///
  /// In it, this message translates to:
  /// **'Pettorale'**
  String get misuraPettorale;

  /// No description provided for @misuraAscellare.
  ///
  /// In it, this message translates to:
  /// **'Ascellare'**
  String get misuraAscellare;

  /// No description provided for @tdeeIntroTesto.
  ///
  /// In it, this message translates to:
  /// **'Configura il tuo piano nutrizionale. Una volta attivato, i valori verranno usati nel diario alimentare.'**
  String get tdeeIntroTesto;

  /// No description provided for @tdeeSezObiettivo.
  ///
  /// In it, this message translates to:
  /// **'OBIETTIVO'**
  String get tdeeSezObiettivo;

  /// No description provided for @tdeeSezAttivita.
  ///
  /// In it, this message translates to:
  /// **'LIVELLO DI ATTIVITÀ'**
  String get tdeeSezAttivita;

  /// No description provided for @tdeeSezMetodo.
  ///
  /// In it, this message translates to:
  /// **'METODO DI CALCOLO'**
  String get tdeeSezMetodo;

  /// No description provided for @tdeeSezAnteprima.
  ///
  /// In it, this message translates to:
  /// **'ANTEPRIMA PIANO'**
  String get tdeeSezAnteprima;

  /// No description provided for @tdeeSezRipartizione.
  ///
  /// In it, this message translates to:
  /// **'RIPARTIZIONE MACRO'**
  String get tdeeSezRipartizione;

  /// No description provided for @tdeePesoObiettivo.
  ///
  /// In it, this message translates to:
  /// **'Peso obiettivo (kg)'**
  String get tdeePesoObiettivo;

  /// No description provided for @tdeeNessunaPesata.
  ///
  /// In it, this message translates to:
  /// **'Registra una pesata per calcolare il piano.'**
  String get tdeeNessunaPesata;

  /// No description provided for @tdeeAttivaPiano.
  ///
  /// In it, this message translates to:
  /// **'ATTIVA PIANO'**
  String get tdeeAttivaPiano;

  /// No description provided for @tdeeAggiornaPiano.
  ///
  /// In it, this message translates to:
  /// **'AGGIORNA PIANO'**
  String get tdeeAggiornaPiano;

  /// No description provided for @tdeeKcalGiornoUnit.
  ///
  /// In it, this message translates to:
  /// **'kcal/giorno'**
  String get tdeeKcalGiornoUnit;

  /// No description provided for @tdeePianoAttivoLabel.
  ///
  /// In it, this message translates to:
  /// **'PIANO ATTIVO'**
  String get tdeePianoAttivoLabel;

  /// No description provided for @tdeeAttivatoDal.
  ///
  /// In it, this message translates to:
  /// **'dal {date}'**
  String tdeeAttivatoDal(String date);

  /// No description provided for @tdeeDatiInsufficienti.
  ///
  /// In it, this message translates to:
  /// **'Dati insufficienti'**
  String get tdeeDatiInsufficienti;

  /// No description provided for @tdeeCarbsNote.
  ///
  /// In it, this message translates to:
  /// **'calorie rimanenti'**
  String get tdeeCarbsNote;

  /// No description provided for @tdeeSonoPassati.
  ///
  /// In it, this message translates to:
  /// **'Sono passati {n} giorni'**
  String tdeeSonoPassati(int n);

  /// No description provided for @tdeeBannerSub.
  ///
  /// In it, this message translates to:
  /// **'Potrebbe essere il momento di aggiornare il tuo piano in base ai progressi.'**
  String get tdeeBannerSub;

  /// No description provided for @tdeeRicalcolaObiettivo.
  ///
  /// In it, this message translates to:
  /// **'Ricalcola obiettivo'**
  String get tdeeRicalcolaObiettivo;

  /// No description provided for @tdeeRicalcolaBtn.
  ///
  /// In it, this message translates to:
  /// **'Ricalcola'**
  String get tdeeRicalcolaBtn;

  /// No description provided for @tdeeRicalcolaBody.
  ///
  /// In it, this message translates to:
  /// **'{n, plural, one{Hai attivato il piano {n} giorno fa.} other{Hai attivato il piano {n} giorni fa.}}\n\nPuoi ricalcolarlo in qualsiasi momento, ma ti consigliamo di farlo dopo almeno 30 giorni per valutare i progressi.'**
  String tdeeRicalcolaBody(int n);

  /// No description provided for @tdeeCalibrazione.
  ///
  /// In it, this message translates to:
  /// **'In base ai tuoi dati delle ultime {days} giorni, il tuo TDEE reale potrebbe essere ~{suggested} kcal (stimato: {current} kcal).'**
  String tdeeCalibrazione(String days, String suggested, String current);

  /// No description provided for @tdeePreviewFormula.
  ///
  /// In it, this message translates to:
  /// **'Formula: {nome}  ·  TDEE: {tdee} kcal'**
  String tdeePreviewFormula(String nome, String tdee);

  /// No description provided for @tdeeObjDeficit.
  ///
  /// In it, this message translates to:
  /// **'Deficit'**
  String get tdeeObjDeficit;

  /// No description provided for @tdeeObjMantenimento.
  ///
  /// In it, this message translates to:
  /// **'Mantenimento'**
  String get tdeeObjMantenimento;

  /// No description provided for @tdeeObjSurplus.
  ///
  /// In it, this message translates to:
  /// **'Surplus'**
  String get tdeeObjSurplus;

  /// No description provided for @tdeeObjDeficitBadge.
  ///
  /// In it, this message translates to:
  /// **'Deficit −20%'**
  String get tdeeObjDeficitBadge;

  /// No description provided for @tdeeObjSurplusBadge.
  ///
  /// In it, this message translates to:
  /// **'Surplus +15%'**
  String get tdeeObjSurplusBadge;

  /// No description provided for @tdeeAttSedentario.
  ///
  /// In it, this message translates to:
  /// **'Sedentario'**
  String get tdeeAttSedentario;

  /// No description provided for @tdeeAttLegg.
  ///
  /// In it, this message translates to:
  /// **'Legg. attivo'**
  String get tdeeAttLegg;

  /// No description provided for @tdeeAttMod.
  ///
  /// In it, this message translates to:
  /// **'Mod. attivo'**
  String get tdeeAttMod;

  /// No description provided for @tdeeAttMolto.
  ///
  /// In it, this message translates to:
  /// **'Molto attivo'**
  String get tdeeAttMolto;

  /// No description provided for @tdeeAttAtleta.
  ///
  /// In it, this message translates to:
  /// **'Atleta'**
  String get tdeeAttAtleta;

  /// No description provided for @tdeeAttSedentarioDesc.
  ///
  /// In it, this message translates to:
  /// **'Lavoro sedentario, poco o nessun esercizio'**
  String get tdeeAttSedentarioDesc;

  /// No description provided for @tdeeAttLeggDesc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio leggero 1–3 giorni/settimana'**
  String get tdeeAttLeggDesc;

  /// No description provided for @tdeeAttModDesc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio moderato 3–5 giorni/settimana'**
  String get tdeeAttModDesc;

  /// No description provided for @tdeeAttMoltoDesc.
  ///
  /// In it, this message translates to:
  /// **'Esercizio intenso 6–7 giorni/settimana'**
  String get tdeeAttMoltoDesc;

  /// No description provided for @tdeeAttAtletaDesc.
  ///
  /// In it, this message translates to:
  /// **'Lavoro fisico intenso o doppio allenamento'**
  String get tdeeAttAtletaDesc;

  /// No description provided for @tdeeMetodoAutomaticoNome.
  ///
  /// In it, this message translates to:
  /// **'Automatico'**
  String get tdeeMetodoAutomaticoNome;

  /// No description provided for @tdeeMetodoAutomaticoDesc.
  ///
  /// In it, this message translates to:
  /// **'Usa la formula più precisa disponibile: Katch-McArdle se hai una plicometria, altrimenti Mifflin-St Jeor.'**
  String get tdeeMetodoAutomaticoDesc;

  /// No description provided for @tdeeMetodoKatchDesc.
  ///
  /// In it, this message translates to:
  /// **'BMR = 370 + 21,6 × massa magra. La più precisa: considera solo la massa metabolicamente attiva.'**
  String get tdeeMetodoKatchDesc;

  /// No description provided for @tdeeMetodoMifflinDesc.
  ///
  /// In it, this message translates to:
  /// **'Formula raccomandata dall\'American Dietetic Association. Accurata per la maggior parte delle persone.'**
  String get tdeeMetodoMifflinDesc;

  /// No description provided for @tdeeMetodoHarrisDesc.
  ///
  /// In it, this message translates to:
  /// **'Formula classica revisionata (Roza & Shizgal, 1984). Tende a sovrastimare leggermente.'**
  String get tdeeMetodoHarrisDesc;

  /// No description provided for @tdeeRichiedePlic.
  ///
  /// In it, this message translates to:
  /// **'richiede plicometria'**
  String get tdeeRichiedePlic;

  /// No description provided for @notifChannelPasti.
  ///
  /// In it, this message translates to:
  /// **'Promemoria pasti'**
  String get notifChannelPasti;

  /// No description provided for @notifChannelPastiDesc.
  ///
  /// In it, this message translates to:
  /// **'Ricordati di registrare i tuoi pasti'**
  String get notifChannelPastiDesc;

  /// No description provided for @notifChannelRecap.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo serale'**
  String get notifChannelRecap;

  /// No description provided for @notifChannelRecapDesc.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo serale dei tuoi progressi'**
  String get notifChannelRecapDesc;

  /// No description provided for @notifChannelMattino.
  ///
  /// In it, this message translates to:
  /// **'Recap mattutino'**
  String get notifChannelMattino;

  /// No description provided for @notifChannelMattinoDesc.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo delle calorie di ieri'**
  String get notifChannelMattinoDesc;

  /// No description provided for @notifChannelPesata.
  ///
  /// In it, this message translates to:
  /// **'Promemoria pesata'**
  String get notifChannelPesata;

  /// No description provided for @notifChannelPesataDesc.
  ///
  /// In it, this message translates to:
  /// **'Ricordati di registrare il tuo peso'**
  String get notifChannelPesataDesc;

  /// No description provided for @notifChannelRestTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer di recupero'**
  String get notifChannelRestTimer;

  /// No description provided for @notifChannelRestTimerDesc.
  ///
  /// In it, this message translates to:
  /// **'Avviso a fine riposo tra le serie'**
  String get notifChannelRestTimerDesc;

  /// No description provided for @notifRestTimerBody.
  ///
  /// In it, this message translates to:
  /// **'Riposo terminato — pronto per la prossima serie?'**
  String get notifRestTimerBody;

  /// No description provided for @notifChannelWorkout.
  ///
  /// In it, this message translates to:
  /// **'Promemoria allenamento'**
  String get notifChannelWorkout;

  /// No description provided for @notifChannelWorkoutDesc.
  ///
  /// In it, this message translates to:
  /// **'Ricordati di allenarti'**
  String get notifChannelWorkoutDesc;

  /// No description provided for @notifPastoBody.
  ///
  /// In it, this message translates to:
  /// **'Hai registrato {pasto}?'**
  String notifPastoBody(String pasto);

  /// No description provided for @notifRecapNuovaStreak.
  ///
  /// In it, this message translates to:
  /// **'Registra i tuoi pasti di oggi per iniziare una nuova streak.'**
  String get notifRecapNuovaStreak;

  /// No description provided for @notifRecapMantieni.
  ///
  /// In it, this message translates to:
  /// **'Hai registrato ogni giorno per {streak} giorni. Vuoi mantenere la streak? 🔥'**
  String notifRecapMantieni(int streak);

  /// No description provided for @notifRecapObiettivo.
  ///
  /// In it, this message translates to:
  /// **'Oggi hai raggiunto il tuo obiettivo per {streak} giorni di fila 🔥'**
  String notifRecapObiettivo(int streak);

  /// No description provided for @notifRecapStreak.
  ///
  /// In it, this message translates to:
  /// **'Hai registrato {streak} giorni di fila! Continua così 💪'**
  String notifRecapStreak(int streak);

  /// No description provided for @notifMattinoOnTarget.
  ///
  /// In it, this message translates to:
  /// **'Ieri hai mangiato {kcal} kcal su {target}. Ottimo lavoro! 💪'**
  String notifMattinoOnTarget(int kcal, int target);

  /// No description provided for @notifMattinoOffTarget.
  ///
  /// In it, this message translates to:
  /// **'Ieri hai registrato {kcal} kcal su {target} di obiettivo.'**
  String notifMattinoOffTarget(int kcal, int target);

  /// No description provided for @notifMattinoNoTarget.
  ///
  /// In it, this message translates to:
  /// **'Ieri hai registrato {kcal} kcal.'**
  String notifMattinoNoTarget(int kcal);

  /// No description provided for @notifPesataBody.
  ///
  /// In it, this message translates to:
  /// **'Non ti pesi da {days} giorni. Vuoi registrare il tuo peso?'**
  String notifPesataBody(int days);

  /// No description provided for @notifWorkoutBody.
  ///
  /// In it, this message translates to:
  /// **'Non ti alleni da {days} giorni. Pronto a riprendere?'**
  String notifWorkoutBody(int days);

  /// No description provided for @pdfDiarioTitle.
  ///
  /// In it, this message translates to:
  /// **'Diario Alimentare'**
  String get pdfDiarioTitle;

  /// No description provided for @pdfTargetLabel.
  ///
  /// In it, this message translates to:
  /// **'target'**
  String get pdfTargetLabel;

  /// No description provided for @pdfNessunDato.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato registrato'**
  String get pdfNessunDato;

  /// No description provided for @pdfPastoFallback.
  ///
  /// In it, this message translates to:
  /// **'Pasto'**
  String get pdfPastoFallback;

  /// No description provided for @pdfRiepilogo.
  ///
  /// In it, this message translates to:
  /// **'RIEPILOGO'**
  String get pdfRiepilogo;

  /// No description provided for @pdfGiorniConDati.
  ///
  /// In it, this message translates to:
  /// **'Giorni con dati: {withData}/{days}'**
  String pdfGiorniConDati(int withData, int days);

  /// No description provided for @pdfGiorniOnTarget.
  ///
  /// In it, this message translates to:
  /// **'Giorni on-target (90–105%): {onTarget}/{total}'**
  String pdfGiorniOnTarget(int onTarget, int total);

  /// No description provided for @pdfMediaLabel.
  ///
  /// In it, this message translates to:
  /// **'Media giornaliera:'**
  String get pdfMediaLabel;

  /// No description provided for @pdfTargetPrefix.
  ///
  /// In it, this message translates to:
  /// **'Target:'**
  String get pdfTargetPrefix;

  /// No description provided for @pdfPianoTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano Alimentare'**
  String get pdfPianoTitle;

  /// No description provided for @pdfGenerato.
  ///
  /// In it, this message translates to:
  /// **'Generato il {created}'**
  String pdfGenerato(String created);

  /// No description provided for @pdfSchedaTitle.
  ///
  /// In it, this message translates to:
  /// **'Scheda Allenamento'**
  String get pdfSchedaTitle;

  /// No description provided for @pdfProgrammaTitle.
  ///
  /// In it, this message translates to:
  /// **'Programma di Allenamento'**
  String get pdfProgrammaTitle;

  /// No description provided for @pdfStoricoTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico Esercizio'**
  String get pdfStoricoTitle;

  /// No description provided for @pdfTecnicaForzate.
  ///
  /// In it, this message translates to:
  /// **'forz.'**
  String get pdfTecnicaForzate;

  /// No description provided for @pdfTecnicaRestPause.
  ///
  /// In it, this message translates to:
  /// **'RP'**
  String get pdfTecnicaRestPause;

  /// No description provided for @pdfTecnicaStripping.
  ///
  /// In it, this message translates to:
  /// **'stripping'**
  String get pdfTecnicaStripping;

  /// No description provided for @pdfTecnicaSuperSlow.
  ///
  /// In it, this message translates to:
  /// **'super slow'**
  String get pdfTecnicaSuperSlow;

  /// No description provided for @muscleGroupAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get muscleGroupAll;

  /// No description provided for @muscleGroupChest.
  ///
  /// In it, this message translates to:
  /// **'Petto'**
  String get muscleGroupChest;

  /// No description provided for @muscleGroupBack.
  ///
  /// In it, this message translates to:
  /// **'Dorso'**
  String get muscleGroupBack;

  /// No description provided for @muscleGroupLegs.
  ///
  /// In it, this message translates to:
  /// **'Gambe'**
  String get muscleGroupLegs;

  /// No description provided for @muscleGroupArms.
  ///
  /// In it, this message translates to:
  /// **'Braccia'**
  String get muscleGroupArms;

  /// No description provided for @muscleGroupShoulders.
  ///
  /// In it, this message translates to:
  /// **'Spalle'**
  String get muscleGroupShoulders;

  /// No description provided for @muscleGroupCore.
  ///
  /// In it, this message translates to:
  /// **'Core'**
  String get muscleGroupCore;

  /// No description provided for @muscleGroupCardio.
  ///
  /// In it, this message translates to:
  /// **'Cardio'**
  String get muscleGroupCardio;

  /// No description provided for @eserciziCatalogoTitle.
  ///
  /// In it, this message translates to:
  /// **'Catalogo esercizi'**
  String get eserciziCatalogoTitle;

  /// No description provided for @eserciziCercaHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca esercizio...'**
  String get eserciziCercaHint;

  /// No description provided for @eserciziNessunRisultato.
  ///
  /// In it, this message translates to:
  /// **'Nessun esercizio trovato'**
  String get eserciziNessunRisultato;

  /// No description provided for @eserciziAggiungiPersonalizzato.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio personalizzato'**
  String get eserciziAggiungiPersonalizzato;

  /// No description provided for @eserciziPersonalizzatoBadge.
  ///
  /// In it, this message translates to:
  /// **'Il mio'**
  String get eserciziPersonalizzatoBadge;

  /// No description provided for @eserciziNuovoTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo esercizio'**
  String get eserciziNuovoTitle;

  /// No description provided for @eserciziNomeLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get eserciziNomeLabel;

  /// No description provided for @eserciziNomeHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Spinte alla macchina'**
  String get eserciziNomeHint;

  /// No description provided for @eserciziGruppoMuscolareLabel.
  ///
  /// In it, this message translates to:
  /// **'Gruppo muscolare'**
  String get eserciziGruppoMuscolareLabel;

  /// No description provided for @eserciziTipoLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get eserciziTipoLabel;

  /// No description provided for @eserciziTipoForza.
  ///
  /// In it, this message translates to:
  /// **'Forza'**
  String get eserciziTipoForza;

  /// No description provided for @eserciziTipoCardio.
  ///
  /// In it, this message translates to:
  /// **'Cardio'**
  String get eserciziTipoCardio;

  /// No description provided for @eserciziAttrezzaturaLabel.
  ///
  /// In it, this message translates to:
  /// **'Attrezzatura (opzionale)'**
  String get eserciziAttrezzaturaLabel;

  /// No description provided for @eserciziAttrezzaturaHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Manubri, corpo libero...'**
  String get eserciziAttrezzaturaHint;

  /// No description provided for @eserciziSalva.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get eserciziSalva;

  /// No description provided for @eserciziNomeObbligatorio.
  ///
  /// In it, this message translates to:
  /// **'Il nome è obbligatorio'**
  String get eserciziNomeObbligatorio;

  /// No description provided for @tabHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabDiario.
  ///
  /// In it, this message translates to:
  /// **'Diario'**
  String get tabDiario;

  /// No description provided for @tabAllenamento.
  ///
  /// In it, this message translates to:
  /// **'Allenamento'**
  String get tabAllenamento;

  /// No description provided for @tabProgressi.
  ///
  /// In it, this message translates to:
  /// **'Progressi'**
  String get tabProgressi;

  /// No description provided for @tabCoach.
  ///
  /// In it, this message translates to:
  /// **'Coach'**
  String get tabCoach;

  /// No description provided for @allenamentoVuotoTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun esercizio oggi'**
  String get allenamentoVuotoTitle;

  /// No description provided for @allenamentoVuotoSub.
  ///
  /// In it, this message translates to:
  /// **'Inizia da una scheda per l\'allenamento guidato, oppure registra un esercizio al volo'**
  String get allenamentoVuotoSub;

  /// No description provided for @allenamentoIniziaDaScheda.
  ///
  /// In it, this message translates to:
  /// **'Inizia da una scheda'**
  String get allenamentoIniziaDaScheda;

  /// No description provided for @allenamentoAggiungiEsercizio.
  ///
  /// In it, this message translates to:
  /// **'Esercizio libero'**
  String get allenamentoAggiungiEsercizio;

  /// No description provided for @allenamentoAggiungiEsercizioSub.
  ///
  /// In it, this message translates to:
  /// **'Segui un singolo esercizio al volo, senza crearti una scheda'**
  String get allenamentoAggiungiEsercizioSub;

  /// No description provided for @allenamentoFonteScheda.
  ///
  /// In it, this message translates to:
  /// **'{scheda}'**
  String allenamentoFonteScheda(String scheda);

  /// No description provided for @allenamentoFonteSchedaProgramma.
  ///
  /// In it, this message translates to:
  /// **'{scheda} · {programma}'**
  String allenamentoFonteSchedaProgramma(String scheda, String programma);

  /// No description provided for @allenamentoSerieCount.
  ///
  /// In it, this message translates to:
  /// **'{n} serie'**
  String allenamentoSerieCount(int n);

  /// No description provided for @allenamentoDurataMin.
  ///
  /// In it, this message translates to:
  /// **'{min} min'**
  String allenamentoDurataMin(int min);

  /// No description provided for @allenamentoEliminaTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare l\'esercizio?'**
  String get allenamentoEliminaTitle;

  /// No description provided for @allenamentoEliminaSub.
  ///
  /// In it, this message translates to:
  /// **'L\'esercizio e le serie registrate verranno rimossi.'**
  String get allenamentoEliminaSub;

  /// No description provided for @allenamentoNotaTitle.
  ///
  /// In it, this message translates to:
  /// **'Nota sessione'**
  String get allenamentoNotaTitle;

  /// No description provided for @allenamentoNotaHint.
  ///
  /// In it, this message translates to:
  /// **'Come è andata? Sensazioni, energia, dolori...'**
  String get allenamentoNotaHint;

  /// No description provided for @allenamentoAggiungiNotaButton.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi nota'**
  String get allenamentoAggiungiNotaButton;

  /// No description provided for @allenamentoModificaNotaButton.
  ///
  /// In it, this message translates to:
  /// **'Modifica nota'**
  String get allenamentoModificaNotaButton;

  /// No description provided for @allenamentoAvviaButton.
  ///
  /// In it, this message translates to:
  /// **'Avvia allenamento'**
  String get allenamentoAvviaButton;

  /// No description provided for @allenamentoAvviaButtonSub.
  ///
  /// In it, this message translates to:
  /// **'Avvia la sessione guidata per gli esercizi di oggi'**
  String get allenamentoAvviaButtonSub;

  /// No description provided for @allenamentoSessioneOggiTitle.
  ///
  /// In it, this message translates to:
  /// **'Allenamento di oggi'**
  String get allenamentoSessioneOggiTitle;

  /// No description provided for @allenamentoSostituisci.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci'**
  String get allenamentoSostituisci;

  /// No description provided for @allenamentoSostituisciTitle.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci esercizio'**
  String get allenamentoSostituisciTitle;

  /// No description provided for @allenamentoSostituisciVuoto.
  ///
  /// In it, this message translates to:
  /// **'Nessuna alternativa disponibile'**
  String get allenamentoSostituisciVuoto;

  /// No description provided for @allenamentoCercaSuYoutube.
  ///
  /// In it, this message translates to:
  /// **'Cerca l\'esecuzione su YouTube'**
  String get allenamentoCercaSuYoutube;

  /// No description provided for @allenamentoYoutubeErrore.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire YouTube'**
  String get allenamentoYoutubeErrore;

  /// No description provided for @allenamentoDurataDaImpostare.
  ///
  /// In it, this message translates to:
  /// **'Durata da impostare'**
  String get allenamentoDurataDaImpostare;

  /// No description provided for @allenamentoGeneraPiramide.
  ///
  /// In it, this message translates to:
  /// **'Genera piramide'**
  String get allenamentoGeneraPiramide;

  /// No description provided for @piramideDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Piramide — {nome}'**
  String piramideDialogTitle(String nome);

  /// No description provided for @piramideDialogNumeroSerie.
  ///
  /// In it, this message translates to:
  /// **'Serie'**
  String get piramideDialogNumeroSerie;

  /// No description provided for @piramideDialogPesoIniziale.
  ///
  /// In it, this message translates to:
  /// **'Peso iniziale (kg)'**
  String get piramideDialogPesoIniziale;

  /// No description provided for @piramideDialogRipIniziali.
  ///
  /// In it, this message translates to:
  /// **'Rip iniziali'**
  String get piramideDialogRipIniziali;

  /// No description provided for @piramideDialogIncrementoKg.
  ///
  /// In it, this message translates to:
  /// **'Incremento (kg)'**
  String get piramideDialogIncrementoKg;

  /// No description provided for @piramideDialogDecrementoRip.
  ///
  /// In it, this message translates to:
  /// **'Decremento rip'**
  String get piramideDialogDecrementoRip;

  /// No description provided for @piramideDialogAscendente.
  ///
  /// In it, this message translates to:
  /// **'Ascendente'**
  String get piramideDialogAscendente;

  /// No description provided for @piramideDialogDiscendente.
  ///
  /// In it, this message translates to:
  /// **'Discendente'**
  String get piramideDialogDiscendente;

  /// No description provided for @piramideDialogAnteprima.
  ///
  /// In it, this message translates to:
  /// **'Anteprima'**
  String get piramideDialogAnteprima;

  /// No description provided for @targetDialogTipoSerie.
  ///
  /// In it, this message translates to:
  /// **'Serie e ripetizioni'**
  String get targetDialogTipoSerie;

  /// No description provided for @targetDialogTipoTempo.
  ///
  /// In it, this message translates to:
  /// **'A tempo'**
  String get targetDialogTipoTempo;

  /// No description provided for @logDialogTracciaATempo.
  ///
  /// In it, this message translates to:
  /// **'Traccia a tempo, invece'**
  String get logDialogTracciaATempo;

  /// No description provided for @logDialogTracciaASerie.
  ///
  /// In it, this message translates to:
  /// **'Traccia con serie e ripetizioni, invece'**
  String get logDialogTracciaASerie;

  /// No description provided for @allenamentoModifica.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get allenamentoModifica;

  /// No description provided for @allenamentoEliminaGiornataTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la sessione?'**
  String get allenamentoEliminaGiornataTitle;

  /// No description provided for @allenamentoEliminaGiornataSub.
  ///
  /// In it, this message translates to:
  /// **'Tutti gli esercizi e la nota di questo giorno verranno rimossi.'**
  String get allenamentoEliminaGiornataSub;

  /// No description provided for @recordPersonaliTitle.
  ///
  /// In it, this message translates to:
  /// **'I tuoi record'**
  String get recordPersonaliTitle;

  /// No description provided for @recordPersonaliVuoto.
  ///
  /// In it, this message translates to:
  /// **'Nessun record ancora. Registra un allenamento per iniziare!'**
  String get recordPersonaliVuoto;

  /// No description provided for @recordPersonaliKg.
  ///
  /// In it, this message translates to:
  /// **'{peso} kg'**
  String recordPersonaliKg(String peso);

  /// No description provided for @volumeSettimanaleTitle.
  ///
  /// In it, this message translates to:
  /// **'Volume settimanale'**
  String get volumeSettimanaleTitle;

  /// No description provided for @volumeSettimanaleVuoto.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento ancora questa settimana.'**
  String get volumeSettimanaleVuoto;

  /// No description provided for @volumeSettimanaleTrascurato.
  ///
  /// In it, this message translates to:
  /// **'{gruppo} trascurato questa settimana'**
  String volumeSettimanaleTrascurato(String gruppo);

  /// No description provided for @serieDialogSerieLabel.
  ///
  /// In it, this message translates to:
  /// **'Serie {n}'**
  String serieDialogSerieLabel(int n);

  /// No description provided for @serieDialogRipHint.
  ///
  /// In it, this message translates to:
  /// **'rip'**
  String get serieDialogRipHint;

  /// No description provided for @serieDialogKgHint.
  ///
  /// In it, this message translates to:
  /// **'kg'**
  String get serieDialogKgHint;

  /// No description provided for @serieDialogRpeLabel.
  ///
  /// In it, this message translates to:
  /// **'RPE'**
  String get serieDialogRpeLabel;

  /// No description provided for @serieDialogAggiungiSerie.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi serie'**
  String get serieDialogAggiungiSerie;

  /// No description provided for @cardioDialogDurataLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata (minuti)'**
  String get cardioDialogDurataLabel;

  /// No description provided for @cardioDialogDurataHint.
  ///
  /// In it, this message translates to:
  /// **'30'**
  String get cardioDialogDurataHint;

  /// No description provided for @homeAttivitaTitle.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get homeAttivitaTitle;

  /// No description provided for @homeAttivitaKcalIngerite.
  ///
  /// In it, this message translates to:
  /// **'Kcal ingerite'**
  String get homeAttivitaKcalIngerite;

  /// No description provided for @homeAttivitaKcalBruciate.
  ///
  /// In it, this message translates to:
  /// **'Kcal bruciate'**
  String get homeAttivitaKcalBruciate;

  /// No description provided for @homeAttivitaBilancioNetto.
  ///
  /// In it, this message translates to:
  /// **'Bilancio netto'**
  String get homeAttivitaBilancioNetto;

  /// No description provided for @homeAttivitaKcalDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Stima indicativa, non un dato medico: basata sull\'ultimo peso registrato (o 75 kg di default se non disponibile).'**
  String get homeAttivitaKcalDisclaimer;

  /// No description provided for @schedeTitle.
  ///
  /// In it, this message translates to:
  /// **'Le mie schede'**
  String get schedeTitle;

  /// No description provided for @calendarioTitle.
  ///
  /// In it, this message translates to:
  /// **'Calendario allenamenti'**
  String get calendarioTitle;

  /// No description provided for @calendarioEsercizioLibero.
  ///
  /// In it, this message translates to:
  /// **'Libero'**
  String get calendarioEsercizioLibero;

  /// No description provided for @schedeCreaTooltip.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get schedeCreaTooltip;

  /// No description provided for @schedeSezionePreimpostate.
  ///
  /// In it, this message translates to:
  /// **'Preimpostate'**
  String get schedeSezionePreimpostate;

  /// No description provided for @schedeSezioneMie.
  ///
  /// In it, this message translates to:
  /// **'Le mie schede'**
  String get schedeSezioneMie;

  /// No description provided for @schedeNuovaScheda.
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda'**
  String get schedeNuovaScheda;

  /// No description provided for @schedeInizia.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get schedeInizia;

  /// No description provided for @schedeModifica.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get schedeModifica;

  /// No description provided for @schedeProssimo.
  ///
  /// In it, this message translates to:
  /// **'Prossimo: {giorno}'**
  String schedeProssimo(String giorno);

  /// No description provided for @schedeDuplica.
  ///
  /// In it, this message translates to:
  /// **'Duplica e personalizza'**
  String get schedeDuplica;

  /// No description provided for @schedeNGiorni.
  ///
  /// In it, this message translates to:
  /// **'{n} giorni'**
  String schedeNGiorni(int n);

  /// No description provided for @schedeNEsercizi.
  ///
  /// In it, this message translates to:
  /// **'{n} esercizi'**
  String schedeNEsercizi(int n);

  /// No description provided for @schedeEliminaTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la scheda?'**
  String get schedeEliminaTitle;

  /// No description provided for @schedeEliminaSub.
  ///
  /// In it, this message translates to:
  /// **'L\'azione non è reversibile.'**
  String get schedeEliminaSub;

  /// No description provided for @schedeUltimoGiornoErrore.
  ///
  /// In it, this message translates to:
  /// **'Non puoi eliminare l\'ultimo giorno del programma'**
  String get schedeUltimoGiornoErrore;

  /// No description provided for @creaSchedaTitleNuova.
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda'**
  String get creaSchedaTitleNuova;

  /// No description provided for @creaSchedaTitleModifica.
  ///
  /// In it, this message translates to:
  /// **'Modifica scheda'**
  String get creaSchedaTitleModifica;

  /// No description provided for @creaSchedaNomeLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome scheda'**
  String get creaSchedaNomeLabel;

  /// No description provided for @creaSchedaNomeHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Push Day'**
  String get creaSchedaNomeHint;

  /// No description provided for @creaSchedaAggiungiEsercizio.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio'**
  String get creaSchedaAggiungiEsercizio;

  /// No description provided for @creaSchedaNessunEsercizio.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno un esercizio'**
  String get creaSchedaNessunEsercizio;

  /// No description provided for @creaSchedaNomeObbligatorio.
  ///
  /// In it, this message translates to:
  /// **'Il nome è obbligatorio'**
  String get creaSchedaNomeObbligatorio;

  /// No description provided for @creaSchedaSupersetUnisci.
  ///
  /// In it, this message translates to:
  /// **'Unisci in superset'**
  String get creaSchedaSupersetUnisci;

  /// No description provided for @creaSchedaSupersetUnito.
  ///
  /// In it, this message translates to:
  /// **'Superset'**
  String get creaSchedaSupersetUnito;

  /// No description provided for @creaSchedaRuoloEsplosiva.
  ///
  /// In it, this message translates to:
  /// **'Esplosiva'**
  String get creaSchedaRuoloEsplosiva;

  /// No description provided for @creaSchedaRuoloLenta.
  ///
  /// In it, this message translates to:
  /// **'Lenta'**
  String get creaSchedaRuoloLenta;

  /// No description provided for @creaProgrammaTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo programma'**
  String get creaProgrammaTitle;

  /// No description provided for @creaProgrammaNomeLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome programma'**
  String get creaProgrammaNomeLabel;

  /// No description provided for @creaProgrammaNomeHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Upper/Lower'**
  String get creaProgrammaNomeHint;

  /// No description provided for @programmaDetailAggiungiGiorno.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi giorno'**
  String get programmaDetailAggiungiGiorno;

  /// No description provided for @programmaDetailNessunGiorno.
  ///
  /// In it, this message translates to:
  /// **'Nessun giorno ancora'**
  String get programmaDetailNessunGiorno;

  /// No description provided for @programmaDetailSchedaEsistente.
  ///
  /// In it, this message translates to:
  /// **'Scheda esistente'**
  String get programmaDetailSchedaEsistente;

  /// No description provided for @programmaDetailNessunaSchedaDisponibile.
  ///
  /// In it, this message translates to:
  /// **'Nessuna scheda autonoma disponibile. Creane una da \"Le mie schede\".'**
  String get programmaDetailNessunaSchedaDisponibile;

  /// No description provided for @targetDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Target — {nome}'**
  String targetDialogTitle(String nome);

  /// No description provided for @targetDialogSerie.
  ///
  /// In it, this message translates to:
  /// **'Serie'**
  String get targetDialogSerie;

  /// No description provided for @targetDialogRip.
  ///
  /// In it, this message translates to:
  /// **'Rip'**
  String get targetDialogRip;

  /// No description provided for @targetDialogKg.
  ///
  /// In it, this message translates to:
  /// **'Kg (opzionale)'**
  String get targetDialogKg;

  /// No description provided for @targetDialogDurataMin.
  ///
  /// In it, this message translates to:
  /// **'Durata (minuti)'**
  String get targetDialogDurataMin;

  /// No description provided for @targetDialogTecnicaLabel.
  ///
  /// In it, this message translates to:
  /// **'Tecnica'**
  String get targetDialogTecnicaLabel;

  /// No description provided for @targetDialogTecnicaDescrizioneForzate.
  ///
  /// In it, this message translates to:
  /// **'Applicata a ogni serie: oltre il cedimento, ripetizioni aggiuntive completate con l\'aiuto di un compagno.'**
  String get targetDialogTecnicaDescrizioneForzate;

  /// No description provided for @targetDialogTecnicaDescrizioneRestPause.
  ///
  /// In it, this message translates to:
  /// **'Applicata a ogni serie: cedimento, pausa breve, altre ripetizioni allo stesso peso.'**
  String get targetDialogTecnicaDescrizioneRestPause;

  /// No description provided for @targetDialogTecnicaDescrizioneStripping.
  ///
  /// In it, this message translates to:
  /// **'Applicata a ogni serie: cedimento, il peso si riduce subito senza pausa e si continua.'**
  String get targetDialogTecnicaDescrizioneStripping;

  /// No description provided for @targetDialogTecnicaDescrizioneSuperSlow.
  ///
  /// In it, this message translates to:
  /// **'Applicata a ogni serie: stessa serie, ma con esecuzione molto lenta.'**
  String get targetDialogTecnicaDescrizioneSuperSlow;

  /// No description provided for @targetDialogProgressioneLabel.
  ///
  /// In it, this message translates to:
  /// **'Progressione'**
  String get targetDialogProgressioneLabel;

  /// No description provided for @targetDialogProgressioneNormale.
  ///
  /// In it, this message translates to:
  /// **'Normale'**
  String get targetDialogProgressioneNormale;

  /// No description provided for @targetDialogProgressionePiramidale.
  ///
  /// In it, this message translates to:
  /// **'Piramidale'**
  String get targetDialogProgressionePiramidale;

  /// No description provided for @targetDialogProgressionePiramidaleInverso.
  ///
  /// In it, this message translates to:
  /// **'Piramidale inverso'**
  String get targetDialogProgressionePiramidaleInverso;

  /// No description provided for @targetDialogProgressionePiramidaleDescrizione.
  ///
  /// In it, this message translates to:
  /// **'Peso crescente e ripetizioni calanti serie dopo serie, a partire dai valori sopra.'**
  String get targetDialogProgressionePiramidaleDescrizione;

  /// No description provided for @targetDialogProgressionePiramidaleInversoDescrizione.
  ///
  /// In it, this message translates to:
  /// **'Peso calante e ripetizioni crescenti serie dopo serie, a partire dai valori sopra.'**
  String get targetDialogProgressionePiramidaleInversoDescrizione;

  /// No description provided for @targetDialogKgObbligatorio.
  ///
  /// In it, this message translates to:
  /// **'Kg (richiesto per la piramide)'**
  String get targetDialogKgObbligatorio;

  /// No description provided for @targetDialogErroreSerie.
  ///
  /// In it, this message translates to:
  /// **'Numero di serie non valido.'**
  String get targetDialogErroreSerie;

  /// No description provided for @targetDialogErroreDurata.
  ///
  /// In it, this message translates to:
  /// **'Durata non valida.'**
  String get targetDialogErroreDurata;

  /// No description provided for @targetDialogErrorePiramideKgRip.
  ///
  /// In it, this message translates to:
  /// **'Inserisci ripetizioni e peso iniziali per generare la piramide.'**
  String get targetDialogErrorePiramideKgRip;

  /// No description provided for @targetDialogErrorePiramideIncremento.
  ///
  /// In it, this message translates to:
  /// **'Inserisci incremento e decremento validi.'**
  String get targetDialogErrorePiramideIncremento;

  /// No description provided for @storicoTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico — {nome}'**
  String storicoTitle(String nome);

  /// No description provided for @storicoNessunaSessione.
  ///
  /// In it, this message translates to:
  /// **'Nessuna sessione registrata per questo esercizio'**
  String get storicoNessunaSessione;

  /// No description provided for @storicoPrBadge.
  ///
  /// In it, this message translates to:
  /// **'PR'**
  String get storicoPrBadge;

  /// No description provided for @storicoVolumeSessione.
  ///
  /// In it, this message translates to:
  /// **'Volume: {volume} kg'**
  String storicoVolumeSessione(String volume);

  /// No description provided for @storicoRpeMedio.
  ///
  /// In it, this message translates to:
  /// **'RPE medio: {rpe}'**
  String storicoRpeMedio(String rpe);

  /// No description provided for @overloadUltimaVolta.
  ///
  /// In it, this message translates to:
  /// **'Ultima volta: {detail}'**
  String overloadUltimaVolta(String detail);

  /// No description provided for @overloadSuggeritoUp.
  ///
  /// In it, this message translates to:
  /// **'Suggerito: aumenta a {kg} kg'**
  String overloadSuggeritoUp(String kg);

  /// No description provided for @overloadSuggeritoSame.
  ///
  /// In it, this message translates to:
  /// **'Suggerito: mantieni {kg} kg'**
  String overloadSuggeritoSame(String kg);

  /// No description provided for @overloadSuggeritoDown.
  ///
  /// In it, this message translates to:
  /// **'Suggerito: riduci a {kg} kg'**
  String overloadSuggeritoDown(String kg);

  /// No description provided for @overloadDeload.
  ///
  /// In it, this message translates to:
  /// **'Stai progredendo da {weeks} settimane: valuta uno scarico a {kg} kg'**
  String overloadDeload(int weeks, String kg);

  /// No description provided for @restTimerTitle.
  ///
  /// In it, this message translates to:
  /// **'Recupero'**
  String get restTimerTitle;

  /// No description provided for @restTimerSalta.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get restTimerSalta;

  /// No description provided for @sessioneGuidataProgress.
  ///
  /// In it, this message translates to:
  /// **'Esercizio {current}/{total}'**
  String sessioneGuidataProgress(int current, int total);

  /// No description provided for @sessioneGuidataPrecedente.
  ///
  /// In it, this message translates to:
  /// **'Precedente'**
  String get sessioneGuidataPrecedente;

  /// No description provided for @sessioneGuidataSuccessivo.
  ///
  /// In it, this message translates to:
  /// **'Successivo'**
  String get sessioneGuidataSuccessivo;

  /// No description provided for @sessioneGuidataTermina.
  ///
  /// In it, this message translates to:
  /// **'Termina sessione'**
  String get sessioneGuidataTermina;

  /// No description provided for @sessioneGuidataCompletaTutto.
  ///
  /// In it, this message translates to:
  /// **'Completa tutti gli esercizi'**
  String get sessioneGuidataCompletaTutto;

  /// No description provided for @sessioneGuidataConferma.
  ///
  /// In it, this message translates to:
  /// **'Conferma serie'**
  String get sessioneGuidataConferma;

  /// No description provided for @sessioneGuidataSuperset.
  ///
  /// In it, this message translates to:
  /// **'SUPERSET'**
  String get sessioneGuidataSuperset;

  /// No description provided for @sessioneGuidataRiscaldamento.
  ///
  /// In it, this message translates to:
  /// **'RISCALDAMENTO'**
  String get sessioneGuidataRiscaldamento;

  /// No description provided for @sessioneGuidataSaltaRiscaldamento.
  ///
  /// In it, this message translates to:
  /// **'Salta riscaldamento'**
  String get sessioneGuidataSaltaRiscaldamento;

  /// No description provided for @sessioneGuidataRiscaldamentoSerieLabel.
  ///
  /// In it, this message translates to:
  /// **'Risc. {n}'**
  String sessioneGuidataRiscaldamentoSerieLabel(int n);

  /// No description provided for @sessioneGuidataAspettaTurno.
  ///
  /// In it, this message translates to:
  /// **'Aspetta il turno'**
  String get sessioneGuidataAspettaTurno;

  /// No description provided for @sessioneGuidataErrorePeso.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il peso (anche 0 se a corpo libero)'**
  String get sessioneGuidataErrorePeso;

  /// No description provided for @sessioneGuidataErroreRip.
  ///
  /// In it, this message translates to:
  /// **'Inserisci le ripetizioni'**
  String get sessioneGuidataErroreRip;

  /// No description provided for @sessioneGuidataErroreDurata.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una durata valida'**
  String get sessioneGuidataErroreDurata;

  /// No description provided for @sessioneGuidataTecnicaNormale.
  ///
  /// In it, this message translates to:
  /// **'Normale'**
  String get sessioneGuidataTecnicaNormale;

  /// No description provided for @sessioneGuidataTecnicaForzate.
  ///
  /// In it, this message translates to:
  /// **'Forzate'**
  String get sessioneGuidataTecnicaForzate;

  /// No description provided for @sessioneGuidataTecnicaRestPause.
  ///
  /// In it, this message translates to:
  /// **'Rest-pause'**
  String get sessioneGuidataTecnicaRestPause;

  /// No description provided for @sessioneGuidataTecnicaStripping.
  ///
  /// In it, this message translates to:
  /// **'Stripping'**
  String get sessioneGuidataTecnicaStripping;

  /// No description provided for @sessioneGuidataTecnicaSuperSlow.
  ///
  /// In it, this message translates to:
  /// **'Super slow'**
  String get sessioneGuidataTecnicaSuperSlow;

  /// No description provided for @sessioneGuidataForzateHint.
  ///
  /// In it, this message translates to:
  /// **'+forz.'**
  String get sessioneGuidataForzateHint;

  /// No description provided for @sessioneGuidataClusterLabel.
  ///
  /// In it, this message translates to:
  /// **'Cluster {n}'**
  String sessioneGuidataClusterLabel(int n);

  /// No description provided for @sessioneGuidataAggiungiCluster.
  ///
  /// In it, this message translates to:
  /// **'+ cluster'**
  String get sessioneGuidataAggiungiCluster;

  /// No description provided for @sessioneGuidataGradinoLabel.
  ///
  /// In it, this message translates to:
  /// **'Gradino {n}'**
  String sessioneGuidataGradinoLabel(int n);

  /// No description provided for @sessioneGuidataAggiungiGradino.
  ///
  /// In it, this message translates to:
  /// **'+ gradino'**
  String get sessioneGuidataAggiungiGradino;

  /// No description provided for @sessioneRiepilogoTitle.
  ///
  /// In it, this message translates to:
  /// **'Sessione completata'**
  String get sessioneRiepilogoTitle;

  /// No description provided for @sessioneRiepilogoKcal.
  ///
  /// In it, this message translates to:
  /// **'{kcal} kcal stimate'**
  String sessioneRiepilogoKcal(int kcal);

  /// No description provided for @sessioneRiepilogoNuoviRecord.
  ///
  /// In it, this message translates to:
  /// **'NUOVI RECORD PERSONALI'**
  String get sessioneRiepilogoNuoviRecord;

  /// No description provided for @sessioneRiepilogoNessunRecord.
  ///
  /// In it, this message translates to:
  /// **'Nessun nuovo record questa volta'**
  String get sessioneRiepilogoNessunRecord;

  /// No description provided for @sessioneRiepilogoRecordEsercizio.
  ///
  /// In it, this message translates to:
  /// **'{esercizio}: {kg} kg'**
  String sessioneRiepilogoRecordEsercizio(String esercizio, String kg);

  /// No description provided for @sessioneRiepilogoChiudi.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get sessioneRiepilogoChiudi;

  /// No description provided for @impostazioniTitolo.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get impostazioniTitolo;

  /// No description provided for @impostazioniNotifiche.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get impostazioniNotifiche;

  /// No description provided for @impostazioniNotificheSub.
  ///
  /// In it, this message translates to:
  /// **'Promemoria pasti e allenamento'**
  String get impostazioniNotificheSub;

  /// No description provided for @impostazioniBackup.
  ///
  /// In it, this message translates to:
  /// **'Backup dati'**
  String get impostazioniBackup;

  /// No description provided for @impostazioniBackupSub.
  ///
  /// In it, this message translates to:
  /// **'Esporta o importa i tuoi dati'**
  String get impostazioniBackupSub;

  /// No description provided for @impostazioniSalute.
  ///
  /// In it, this message translates to:
  /// **'Collega Salute'**
  String get impostazioniSalute;

  /// No description provided for @impostazioniSaluteSub.
  ///
  /// In it, this message translates to:
  /// **'Importa allenamenti dal tuo smartwatch'**
  String get impostazioniSaluteSub;

  /// No description provided for @smartwatchTitolo.
  ///
  /// In it, this message translates to:
  /// **'Collega Salute'**
  String get smartwatchTitolo;

  /// No description provided for @smartwatchHubIOS.
  ///
  /// In it, this message translates to:
  /// **'Apple Salute'**
  String get smartwatchHubIOS;

  /// No description provided for @smartwatchHubAndroid.
  ///
  /// In it, this message translates to:
  /// **'Health Connect'**
  String get smartwatchHubAndroid;

  /// No description provided for @smartwatchConnesso.
  ///
  /// In it, this message translates to:
  /// **'Connesso'**
  String get smartwatchConnesso;

  /// No description provided for @smartwatchNonConnesso.
  ///
  /// In it, this message translates to:
  /// **'Non connesso'**
  String get smartwatchNonConnesso;

  /// No description provided for @smartwatchNonDisponibile.
  ///
  /// In it, this message translates to:
  /// **'Health Connect non è installato su questo dispositivo'**
  String get smartwatchNonDisponibile;

  /// No description provided for @smartwatchConnettiButton.
  ///
  /// In it, this message translates to:
  /// **'Connetti'**
  String get smartwatchConnettiButton;

  /// No description provided for @smartwatchDisconnetti.
  ///
  /// In it, this message translates to:
  /// **'Scollega'**
  String get smartwatchDisconnetti;

  /// No description provided for @smartwatchInstallaHealthConnect.
  ///
  /// In it, this message translates to:
  /// **'Installa Health Connect'**
  String get smartwatchInstallaHealthConnect;

  /// No description provided for @smartwatchPermessoNegato.
  ///
  /// In it, this message translates to:
  /// **'Permesso non concesso. Puoi riprovare o autorizzare Plico dalle impostazioni del sistema.'**
  String get smartwatchPermessoNegato;

  /// No description provided for @smartwatchDescrizione.
  ///
  /// In it, this message translates to:
  /// **'Importa automaticamente allenamenti cardio e pesi, frequenza cardiaca e calorie attive registrate dal tuo smartwatch, senza doverli inserire a mano.'**
  String get smartwatchDescrizione;

  /// No description provided for @smartwatchDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'I dati restano solo su questo dispositivo: Plico non li invia a server esterni. Puoi scollegare l\'accesso in qualsiasi momento da questa schermata.'**
  String get smartwatchDisclaimer;

  /// No description provided for @smartwatchImportaButton.
  ///
  /// In it, this message translates to:
  /// **'Importa allenamenti'**
  String get smartwatchImportaButton;

  /// No description provided for @smartwatchImportaSuccesso.
  ///
  /// In it, this message translates to:
  /// **'{count} allenamenti importati'**
  String smartwatchImportaSuccesso(int count);

  /// No description provided for @smartwatchImportaNessuno.
  ///
  /// In it, this message translates to:
  /// **'Nessun nuovo allenamento da importare'**
  String get smartwatchImportaNessuno;

  /// No description provided for @smartwatchBadgeHealthKit.
  ///
  /// In it, this message translates to:
  /// **'Apple Salute'**
  String get smartwatchBadgeHealthKit;

  /// No description provided for @smartwatchBadgeHealthConnect.
  ///
  /// In it, this message translates to:
  /// **'Health Connect'**
  String get smartwatchBadgeHealthConnect;

  /// No description provided for @backupTitolo.
  ///
  /// In it, this message translates to:
  /// **'Backup dati'**
  String get backupTitolo;

  /// No description provided for @backupEsportaTitolo.
  ///
  /// In it, this message translates to:
  /// **'Esporta backup'**
  String get backupEsportaTitolo;

  /// No description provided for @backupEsportaDesc.
  ///
  /// In it, this message translates to:
  /// **'Crea un file con tutti i tuoi dati (diario, allenamenti, pesate, misurazioni, piano e preferenze). Salvalo dove preferisci (Drive, iCloud, email...) per trasferirlo su un nuovo telefono.'**
  String get backupEsportaDesc;

  /// No description provided for @backupEsportaButton.
  ///
  /// In it, this message translates to:
  /// **'Esporta backup'**
  String get backupEsportaButton;

  /// No description provided for @backupEsportaErrore.
  ///
  /// In it, this message translates to:
  /// **'Impossibile creare il backup: {err}'**
  String backupEsportaErrore(String err);

  /// No description provided for @backupImportaTitolo.
  ///
  /// In it, this message translates to:
  /// **'Importa backup'**
  String get backupImportaTitolo;

  /// No description provided for @backupImportaDesc.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un file di backup esportato da Plico su un altro dispositivo. Attenzione: sovrascrive tutti i dati attualmente presenti in questa app.'**
  String get backupImportaDesc;

  /// No description provided for @backupImportaButton.
  ///
  /// In it, this message translates to:
  /// **'Importa backup'**
  String get backupImportaButton;

  /// No description provided for @backupImportaConfermaTitolo.
  ///
  /// In it, this message translates to:
  /// **'Sovrascrivere i dati attuali?'**
  String get backupImportaConfermaTitolo;

  /// No description provided for @backupImportaConfermaBody.
  ///
  /// In it, this message translates to:
  /// **'Questa operazione sostituirà tutti i dati presenti in questa app con quelli del file selezionato. Non può essere annullata.'**
  String get backupImportaConfermaBody;

  /// No description provided for @backupImportaConfermaConferma.
  ///
  /// In it, this message translates to:
  /// **'Sovrascrivi'**
  String get backupImportaConfermaConferma;

  /// No description provided for @backupImportaFileNonValido.
  ///
  /// In it, this message translates to:
  /// **'Il file selezionato non è un backup Plico valido.'**
  String get backupImportaFileNonValido;

  /// No description provided for @backupImportaErrore.
  ///
  /// In it, this message translates to:
  /// **'Impossibile importare il backup: {err}'**
  String backupImportaErrore(String err);

  /// No description provided for @backupImportaSuccesso.
  ///
  /// In it, this message translates to:
  /// **'Dati importati con successo'**
  String get backupImportaSuccesso;

  /// No description provided for @backupWifiTitolo.
  ///
  /// In it, this message translates to:
  /// **'Trasferimento diretto'**
  String get backupWifiTitolo;

  /// No description provided for @backupWifiDesc.
  ///
  /// In it, this message translates to:
  /// **'Trasferisci il backup direttamente a un altro telefono sulla stessa rete Wi-Fi, senza passare da file o cloud.'**
  String get backupWifiDesc;

  /// No description provided for @backupWifiInviaButton.
  ///
  /// In it, this message translates to:
  /// **'Invia a un altro dispositivo'**
  String get backupWifiInviaButton;

  /// No description provided for @backupWifiRiceviButton.
  ///
  /// In it, this message translates to:
  /// **'Ricevi da un altro dispositivo'**
  String get backupWifiRiceviButton;

  /// No description provided for @wifiSendTitolo.
  ///
  /// In it, this message translates to:
  /// **'Invia via Wi-Fi'**
  String get wifiSendTitolo;

  /// No description provided for @wifiSendDesc.
  ///
  /// In it, this message translates to:
  /// **'Assicurati che l\'altro telefono sia sulla stessa rete Wi-Fi, poi apri Plico → Impostazioni → Backup dati → Ricevi da un altro dispositivo e inquadra questo codice.'**
  String get wifiSendDesc;

  /// No description provided for @wifiSendInAttesa.
  ///
  /// In it, this message translates to:
  /// **'In attesa di connessione...'**
  String get wifiSendInAttesa;

  /// No description provided for @wifiSendTrasferito.
  ///
  /// In it, this message translates to:
  /// **'Trasferito!'**
  String get wifiSendTrasferito;

  /// No description provided for @wifiSendTimeout.
  ///
  /// In it, this message translates to:
  /// **'Nessuna connessione ricevuta. Verifica che entrambi i telefoni siano sulla stessa rete Wi-Fi e riprova.'**
  String get wifiSendTimeout;

  /// No description provided for @wifiSendErroreRete.
  ///
  /// In it, this message translates to:
  /// **'Impossibile avviare il trasferimento: verifica di essere connesso a una rete Wi-Fi.'**
  String get wifiSendErroreRete;

  /// No description provided for @wifiSendRiprova.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get wifiSendRiprova;

  /// No description provided for @wifiSendChiudi.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get wifiSendChiudi;

  /// No description provided for @wifiReceiveTitolo.
  ///
  /// In it, this message translates to:
  /// **'Ricevi via Wi-Fi'**
  String get wifiReceiveTitolo;

  /// No description provided for @wifiReceiveHint.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il QR mostrato sull\'altro telefono'**
  String get wifiReceiveHint;

  /// No description provided for @wifiReceiveScaricamento.
  ///
  /// In it, this message translates to:
  /// **'Scaricamento in corso...'**
  String get wifiReceiveScaricamento;

  /// No description provided for @wifiReceiveErroreQr.
  ///
  /// In it, this message translates to:
  /// **'QR non valido. Riprova.'**
  String get wifiReceiveErroreQr;

  /// No description provided for @wifiReceiveErroreDownload.
  ///
  /// In it, this message translates to:
  /// **'Impossibile scaricare il backup. Verifica che entrambi i telefoni siano sulla stessa rete Wi-Fi e riprova.'**
  String get wifiReceiveErroreDownload;

  /// No description provided for @welcomeImportaWifiButton.
  ///
  /// In it, this message translates to:
  /// **'Ricevi da un altro dispositivo (Wi-Fi)'**
  String get welcomeImportaWifiButton;

  /// No description provided for @welcomeTitolo.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto su Plico'**
  String get welcomeTitolo;

  /// No description provided for @welcomeSottotitolo.
  ///
  /// In it, this message translates to:
  /// **'Prima di iniziare, dicci se hai già usato Plico su un altro telefono.'**
  String get welcomeSottotitolo;

  /// No description provided for @welcomeNuovoButton.
  ///
  /// In it, this message translates to:
  /// **'Inizia da zero'**
  String get welcomeNuovoButton;

  /// No description provided for @welcomeNuovoSub.
  ///
  /// In it, this message translates to:
  /// **'Prima volta che usi Plico'**
  String get welcomeNuovoSub;

  /// No description provided for @welcomeImportaButton.
  ///
  /// In it, this message translates to:
  /// **'Ho già usato Plico'**
  String get welcomeImportaButton;

  /// No description provided for @welcomeImportaSub.
  ///
  /// In it, this message translates to:
  /// **'Importa i dati da un altro dispositivo'**
  String get welcomeImportaSub;

  /// No description provided for @welcomeImportaStepTitolo.
  ///
  /// In it, this message translates to:
  /// **'Importa i tuoi dati'**
  String get welcomeImportaStepTitolo;

  /// No description provided for @welcomeImportaStepDesc.
  ///
  /// In it, this message translates to:
  /// **'Sul vecchio telefono: apri Plico → Impostazioni → Backup dati → Esporta backup, poi trasferisci il file su questo telefono (email, Drive, iCloud, AirDrop...). Quando è pronto, selezionalo qui sotto.'**
  String get welcomeImportaStepDesc;

  /// No description provided for @welcomeImportaSelezionaButton.
  ///
  /// In it, this message translates to:
  /// **'Seleziona file di backup'**
  String get welcomeImportaSelezionaButton;

  /// No description provided for @welcomeIndietro.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get welcomeIndietro;

  /// No description provided for @coachTitolo.
  ///
  /// In it, this message translates to:
  /// **'Coach'**
  String get coachTitolo;

  /// No description provided for @coachOnboardingTitolo.
  ///
  /// In it, this message translates to:
  /// **'Coach usa un\'IA esterna'**
  String get coachOnboardingTitolo;

  /// No description provided for @coachOnboardingBody.
  ///
  /// In it, this message translates to:
  /// **'A differenza del resto di Plico — che funziona offline e tiene i tuoi dati solo sul telefono — la sezione Coach invia i tuoi messaggi a un motore di intelligenza artificiale esterno (Google Gemini) per generare le risposte. Questo vale solo qui: nessun\'altra parte dell\'app condivide i tuoi dati con l\'esterno.'**
  String get coachOnboardingBody;

  /// No description provided for @coachOnboardingOk.
  ///
  /// In it, this message translates to:
  /// **'Ho capito'**
  String get coachOnboardingOk;

  /// No description provided for @coachSetupIntro.
  ///
  /// In it, this message translates to:
  /// **'Il Coach è un assistente AI (Gemini di Google) per domande su allenamento e alimentazione. Usa la tua chiave API personale e gratuita: Plico non paga né vede nulla, e tu non spendi nulla restando nel piano gratuito.'**
  String get coachSetupIntro;

  /// No description provided for @coachSetupStep1.
  ///
  /// In it, this message translates to:
  /// **'1. Apri Google AI Studio e crea una chiave API gratuita (nessuna carta richiesta)'**
  String get coachSetupStep1;

  /// No description provided for @coachSetupApriAiStudio.
  ///
  /// In it, this message translates to:
  /// **'Apri Google AI Studio'**
  String get coachSetupApriAiStudio;

  /// No description provided for @coachSetupStep2.
  ///
  /// In it, this message translates to:
  /// **'2. Incolla qui la chiave'**
  String get coachSetupStep2;

  /// No description provided for @coachApiKeyHint.
  ///
  /// In it, this message translates to:
  /// **'Incolla la tua API key Gemini'**
  String get coachApiKeyHint;

  /// No description provided for @coachApiKeyObbligatoria.
  ///
  /// In it, this message translates to:
  /// **'Incolla prima la tua API key'**
  String get coachApiKeyObbligatoria;

  /// No description provided for @coachDisclaimer.
  ///
  /// In it, this message translates to:
  /// **'Le richieste passano direttamente dal tuo telefono a Google, non da un server Plico. Sul piano gratuito, Google dichiara di poter usare le richieste per migliorare i propri modelli. Se in futuro attivi la fatturazione sulla tua chiave, eventuali costi restano a tuo carico: Plico limita in automatico le richieste per restare nel piano gratuito, ma non può garantirlo se cambi le impostazioni della tua chiave su Google.'**
  String get coachDisclaimer;

  /// No description provided for @coachSalvaChiave.
  ///
  /// In it, this message translates to:
  /// **'Salva e continua'**
  String get coachSalvaChiave;

  /// No description provided for @coachVerificaChiave.
  ///
  /// In it, this message translates to:
  /// **'Verifica in corso...'**
  String get coachVerificaChiave;

  /// No description provided for @coachChiaveSalvata.
  ///
  /// In it, this message translates to:
  /// **'Chiave salvata'**
  String get coachChiaveSalvata;

  /// No description provided for @coachModificaChiave.
  ///
  /// In it, this message translates to:
  /// **'Cambia API key'**
  String get coachModificaChiave;

  /// No description provided for @coachRimuoviChiaveTitolo.
  ///
  /// In it, this message translates to:
  /// **'Cambiare API key?'**
  String get coachRimuoviChiaveTitolo;

  /// No description provided for @coachRimuoviChiaveSub.
  ///
  /// In it, this message translates to:
  /// **'La chat attuale non verrà salvata. Potrai incollare una nuova chiave (o la stessa) subito dopo.'**
  String get coachRimuoviChiaveSub;

  /// No description provided for @coachRichiesteRimaste.
  ///
  /// In it, this message translates to:
  /// **'{count} richieste rimaste oggi'**
  String coachRichiesteRimaste(int count);

  /// No description provided for @coachScriviMessaggio.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un messaggio...'**
  String get coachScriviMessaggio;

  /// No description provided for @coachBenvenuto.
  ///
  /// In it, this message translates to:
  /// **'Ciao! Sono il tuo Coach per allenamento e alimentazione — chiedimi pure.'**
  String get coachBenvenuto;

  /// No description provided for @coachErroreChiaveNonValida.
  ///
  /// In it, this message translates to:
  /// **'API key non valida. Controlla di averla copiata per intero da Google AI Studio.'**
  String get coachErroreChiaveNonValida;

  /// No description provided for @coachErroreQuotaEsaurita.
  ///
  /// In it, this message translates to:
  /// **'Quota Gemini esaurita per ora (limite di Google). Riprova tra qualche minuto.'**
  String get coachErroreQuotaEsaurita;

  /// No description provided for @coachErroreLimiteGiornaliero.
  ///
  /// In it, this message translates to:
  /// **'Hai raggiunto il limite di richieste gratuite di oggi. Riprova domani.'**
  String get coachErroreLimiteGiornaliero;

  /// No description provided for @coachErroreLimiteMinuto.
  ///
  /// In it, this message translates to:
  /// **'Troppe richieste ravvicinate, attendi qualche secondo e riprova.'**
  String get coachErroreLimiteMinuto;

  /// No description provided for @coachErroreRete.
  ///
  /// In it, this message translates to:
  /// **'Connessione assente o non riuscita. Controlla la rete e riprova.'**
  String get coachErroreRete;

  /// No description provided for @coachErroreServizioNonDisponibile.
  ///
  /// In it, this message translates to:
  /// **'Il servizio Gemini è momentaneamente sovraccarico lato Google. Riprova tra poco.'**
  String get coachErroreServizioNonDisponibile;

  /// No description provided for @coachRiprovo.
  ///
  /// In it, this message translates to:
  /// **'Modello occupato, riprovo... ({attempt}/2)'**
  String coachRiprovo(int attempt);

  /// No description provided for @coachRiprova.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get coachRiprova;

  /// No description provided for @coachFuoriTema.
  ///
  /// In it, this message translates to:
  /// **'Posso aiutarti solo con allenamento, nutrizione e ricette. Prova a chiedermi qualcosa su questi argomenti!'**
  String get coachFuoriTema;

  /// No description provided for @coachNuovaConversazioneTitolo.
  ///
  /// In it, this message translates to:
  /// **'Nuova conversazione'**
  String get coachNuovaConversazioneTitolo;

  /// No description provided for @coachNuovaConversazioneSub.
  ///
  /// In it, this message translates to:
  /// **'La cronologia della chat verrà cancellata definitivamente. Continuare?'**
  String get coachNuovaConversazioneSub;

  /// No description provided for @coachNuovaConversazioneConferma.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get coachNuovaConversazioneConferma;

  /// No description provided for @coachErroreGenerico.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa è andato storto, riprova.'**
  String get coachErroreGenerico;

  /// No description provided for @sessioneGuidataScaricoTitolo.
  ///
  /// In it, this message translates to:
  /// **'Settimana di scarico consigliata'**
  String get sessioneGuidataScaricoTitolo;

  /// No description provided for @sessioneGuidataScaricoSottotitolo.
  ///
  /// In it, this message translates to:
  /// **'3 settimane di progressione: carichi ridotti del 40%. Disattiva per tornare ai pesi normali (non verrà riproposto per 3 settimane).'**
  String get sessioneGuidataScaricoSottotitolo;

  /// No description provided for @overloadScarico.
  ///
  /// In it, this message translates to:
  /// **'Scarico: {kg} kg'**
  String overloadScarico(String kg);

  /// No description provided for @overloadScaricoConNormale.
  ///
  /// In it, this message translates to:
  /// **'Scarico: {kg} kg (normale: {normalKg} kg)'**
  String overloadScaricoConNormale(String kg, String normalKg);

  /// No description provided for @coachCondividiDatiTooltip.
  ///
  /// In it, this message translates to:
  /// **'Condividi i miei dati con il Coach'**
  String get coachCondividiDatiTooltip;

  /// No description provided for @coachCondividiDatiOn.
  ///
  /// In it, this message translates to:
  /// **'Il Coach ora vede i tuoi dati (peso, pasti di oggi, piano, allenamenti): vengono inviati a Google insieme alla domanda.'**
  String get coachCondividiDatiOn;

  /// No description provided for @coachCondividiDatiOff.
  ///
  /// In it, this message translates to:
  /// **'Il Coach non vede più i tuoi dati.'**
  String get coachCondividiDatiOff;

  /// No description provided for @coachAzioneRicette.
  ///
  /// In it, this message translates to:
  /// **'Ricette dal piano'**
  String get coachAzioneRicette;

  /// No description provided for @coachAzioneRicetteMsg.
  ///
  /// In it, this message translates to:
  /// **'Genera le ricette del mio piano alimentare'**
  String get coachAzioneRicetteMsg;

  /// No description provided for @coachAzioneAnteprimaTitolo.
  ///
  /// In it, this message translates to:
  /// **'Cosa invierò a Google'**
  String get coachAzioneAnteprimaTitolo;

  /// No description provided for @coachAzioneAnteprimaSub.
  ///
  /// In it, this message translates to:
  /// **'Questi dati lasciano il telefono insieme alla richiesta. Nulla viene salvato nell\'app: la risposta compare qui in chat.'**
  String get coachAzioneAnteprimaSub;

  /// No description provided for @coachAzioneInvia.
  ///
  /// In it, this message translates to:
  /// **'Invia'**
  String get coachAzioneInvia;

  /// No description provided for @coachAzioneNonDisponibile.
  ///
  /// In it, this message translates to:
  /// **'Non ancora disponibile'**
  String get coachAzioneNonDisponibile;

  /// No description provided for @coachGateNoProfile.
  ///
  /// In it, this message translates to:
  /// **'Completa il tuo profilo.'**
  String get coachGateNoProfile;

  /// No description provided for @coachGateNoWeight.
  ///
  /// In it, this message translates to:
  /// **'Registra almeno una misurazione di peso.'**
  String get coachGateNoWeight;

  /// No description provided for @coachGateNoQuestionnaire.
  ///
  /// In it, this message translates to:
  /// **'Compila le preferenze alimentari.'**
  String get coachGateNoQuestionnaire;

  /// No description provided for @coachGateFewSessions.
  ///
  /// In it, this message translates to:
  /// **'Servono almeno {needed} allenamenti svolti negli ultimi 90 giorni (ne hai {have}). In alternativa, scrivi qui in chat il tuo livello attuale e cosa vuoi ottenere.'**
  String coachGateFewSessions(int needed, int have);

  /// No description provided for @coachGateNoPlan.
  ///
  /// In it, this message translates to:
  /// **'Genera prima un piano alimentare.'**
  String get coachGateNoPlan;

  /// No description provided for @coachAvvisoAllergie.
  ///
  /// In it, this message translates to:
  /// **'Verifica sempre gli ingredienti rispetto alle tue allergie e intolleranze.'**
  String get coachAvvisoAllergie;

  /// No description provided for @coachAzioneAlimentazione.
  ///
  /// In it, this message translates to:
  /// **'Nuova alimentazione'**
  String get coachAzioneAlimentazione;

  /// No description provided for @coachAzioneAlimentazioneMsg.
  ///
  /// In it, this message translates to:
  /// **'Genera una nuova alimentazione'**
  String get coachAzioneAlimentazioneMsg;

  /// No description provided for @coachAzioneScheda.
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda'**
  String get coachAzioneScheda;

  /// No description provided for @coachAzioneSchedaMsg.
  ///
  /// In it, this message translates to:
  /// **'Genera una nuova scheda di allenamento'**
  String get coachAzioneSchedaMsg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
