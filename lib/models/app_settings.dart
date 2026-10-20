import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1; // single record

  bool isDarkMode = false;
  int livelloAttivita = 2; // 0=sedentario 1=legg.attivo 2=mod.attivo 3=molto attivo 4=atleta
  int metodoTdee = 0;     // 0=auto 1=katch-mcArdle 2=mifflin-stJeor 3=harris-benedict
  int obiettivo = 1;      // 0=deficit 1=mantenimento 2=surplus
  bool creaSeeded = false;
  bool exercisesSeeded = false;
  bool workoutPresetsSeeded = false;
  // Migrazione una-tantum: rinomina gli alimenti già in DB secondo i nomi
  // normalizzati correnti (matching per creaCode, stabile) — necessaria per
  // chi aveva installato l'app prima della normalizzazione dei nomi, altrimenti
  // il vecchio nome in Isar non fa più match con `PianoService.curatedNames`.
  bool foodNamesNormalizedV2 = false;
  // Migrazione una-tantum: risincronizza `nomeInglese` sui FoodItem già in
  // DB (matching per creaCode) — la normalizzazione di crea_seed.json
  // (docs/normalizzazione_nomi_alimenti.md) ha cambiato/rimosso molte voci
  // senza che `migrateFoodNamesV2` (che tocca solo `nome`) le risincronizzasse,
  // lasciando `nomeInglese` null per chi aveva già seedato il catalogo:
  // la ricerca in inglese mostrava quindi i nomi italiani come fallback.
  bool foodNomeIngleseSyncedV1 = false;
  // Migrazione una-tantum: risincronizza `nameIt` sugli ExerciseDefinition
  // già in DB (matching per externalId) — il catalogo esercizi è stato
  // tradotto in italiano dopo il primo rilascio, ma `seedExercises` seeda
  // una sola volta: senza questa sincronizzazione chi aveva già installato
  // l'app restava con i nomi in inglese per gli esercizi tradotti dopo.
  bool exerciseNamesItSyncedV1 = false;
  DateTime? goalSetDate;
  double? pesoObiettivo;

  // Promemoria pasti
  bool notificheAttive = false;
  bool notColAttiva = true;
  bool notPranzoAttiva = true;
  bool notCenaAttiva = true;
  bool notSpuntinoAttiva = false;
  bool notPostWoAttiva = false;
  bool notSorAttiva = false;
  int notColMin = 450;      // 7:30
  int notPranzoMin = 750;   // 12:30
  int notCenaMin = 1170;    // 19:30
  int notSpuntinoMin = 630; // 10:30
  int notPostWoMin = 1020;  // 17:00
  int notSorMin = 1260;     // 21:00

  bool tourCompleted = false;

  // Allenamento — Fase 8
  int restTimerDefaultSeconds = 90;

  // Allenamento — Fase 10
  bool notWorkoutAttiva = false;

  // Integrazione smartwatch (docs/integrazione_smartwatch.md): traccia se
  // l'utente ha completato con successo il flusso di autorizzazione — su iOS
  // HealthKit non permette di interrogare lo stato READ per privacy, quindi
  // non c'è altro modo affidabile di sapere se è "connesso".
  bool smartwatchConnected = false;

  // Coach (Gemini, bring-your-own-key — docs/integrazione_flutter_gemma.md,
  // Fase 7): chiave generata dall'utente su Google AI Studio, mai una chiave
  // condivisa di Plico. `geminiRequestsToday`/`geminiRequestsResetDate`
  // tracciano il consumo locale della quota free tier (20/giorno per modello) per
  // bloccare nuove richieste PRIMA che l'utente rischi di sforare e pagare.
  String? geminiApiKey;
  int geminiRequestsToday = 0;
  DateTime? geminiRequestsResetDate;
  // Banner mostrato alla primissima apertura della tab Coach (a prescindere
  // dal fatto che l'utente abbia già una chiave salvata): a differenza del
  // resto di Plico, offline-first, qui i messaggi escono verso Google — va
  // detto prima ancora delle istruzioni per la chiave, non solo nel
  // disclaimer al salvataggio.
  bool coachOnboardingSeen = false;
  // Fase 8: opt-in esplicito a mandare a Google, insieme alla domanda, uno
  // snapshot dei propri dati (peso, pasti di oggi, piano, allenamenti). Off
  // di default: il disclaimer già accettato parlava di "richieste", non di
  // dati personali.
  bool coachShareData = false;
}
