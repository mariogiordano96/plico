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

  /// Tour: titolo tab TDEE
  ///
  /// In it, this message translates to:
  /// **'TDEE'**
  String get tourTdeeTitle;

  /// Tour: descrizione tab TDEE
  ///
  /// In it, this message translates to:
  /// **'Il tuo fabbisogno calorico personalizzato, calcolato e aggiornato sui tuoi dati reali.'**
  String get tourTdeeDesc;

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

  /// No description provided for @homePianoLabel.
  ///
  /// In it, this message translates to:
  /// **'PIANO ALIMENTARE'**
  String get homePianoLabel;

  /// No description provided for @homePianoSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Visualizza e genera il piano'**
  String get homePianoSubtitle;

  /// No description provided for @homeTdeeKcalGiorno.
  ///
  /// In it, this message translates to:
  /// **'{kcal} kcal/giorno'**
  String homeTdeeKcalGiorno(String kcal);

  /// No description provided for @homeTdeeCalcola.
  ///
  /// In it, this message translates to:
  /// **'Calcola il tuo fabbisogno'**
  String get homeTdeeCalcola;

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

  /// No description provided for @homePlicoNuovaMisurazione.
  ///
  /// In it, this message translates to:
  /// **'Nuova misurazione'**
  String get homePlicoNuovaMisurazione;

  /// No description provided for @homeProgressiLabel.
  ///
  /// In it, this message translates to:
  /// **'PROGRESSI'**
  String get homeProgressiLabel;

  /// No description provided for @homeProgressiSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Composizione e misurazioni nel tempo'**
  String get homeProgressiSubtitle;

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

  /// No description provided for @homeStreakGiorni.
  ///
  /// In it, this message translates to:
  /// **'{count} giorni di fila'**
  String homeStreakGiorni(String count);

  /// No description provided for @homeStreakInizia.
  ///
  /// In it, this message translates to:
  /// **'Inizia oggi la tua streak'**
  String get homeStreakInizia;

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
