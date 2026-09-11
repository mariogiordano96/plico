import 'package:isar/isar.dart';
import 'workout_set.dart';

part 'workout_exercise.g.dart';

/// Sorgente di un'entry importata da smartwatch (vedi
/// docs/integrazione_smartwatch.md sezione 6). Il log manuale non ha
/// bisogno di un valore: [WorkoutExercise.source] resta null in quel caso.
enum WorkoutSource { healthKit, healthConnect }

/// Ruolo nella variante "superset veloce/lento" (docs/tecniche_allenamento.md,
/// Fase 2): due esercizi consecutivi senza riposo, uno a carico alto eseguito
/// esplosivo, uno a carico più basso eseguito lento. Non è un nuovo
/// meccanismo di raggruppamento — usa lo stesso `supersetGroupId` del
/// superset semplice, questo campo resta null per quello.
enum SupersetRole { esplosiva, lenta }

@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String exerciseId; // ExerciseDefinition.externalId
  late String exerciseName; // snapshot del nome al momento del log

  @Index(type: IndexType.value)
  late DateTime date; // normalizzata a mezzanotte: query dirette per giorno e per storico

  int? supersetGroupId; // Fase 12: esercizi eseguiti in sequenza senza riposo tra loro
  int? restSeconds; // Fase 8: riposo dopo l'ultima serie/il completamento
  String? supersetRole; // SupersetRole.name, vedi sopra

  // Per cardio
  int? durationSeconds;
  int? met; // valore MET usato per la stima (Fase 5)
  // Fase 23: true solo quando l'utente conferma esplicitamente in modalità
  // guidata — durationSeconds può già essere valorizzato prima (target della
  // scheda) senza che l'esercizio sia stato davvero eseguito.
  bool cardioConfirmed = false;

  // Per strength — embedded, non IsarLinks: WorkoutSet non ha bisogno di query indipendenti
  List<WorkoutSet> sets = [];

  int? estimatedKcal; // calcolato e persistito al salvataggio (Fase 5)

  // Import smartwatch (vedi docs/integrazione_smartwatch.md sezione 6): tutti
  // null/false per il log manuale, valorizzati solo per le entry importate.
  String? source; // WorkoutSource.name
  DateTime? sourceStartTime;
  DateTime? sourceEndTime;
  double? avgHeartRate;
  // Un allenamento pesi rilevato dal watch ha sets=[] come il cardio (nessun
  // sensore misura il carico su un bilanciere), ma non è cardio: senza questo
  // flag `isCardio` lo classificherebbe erroneamente, rompendo sessione
  // guidata, PDF export, storico e la card lista giorno.
  bool importedIsStrength = false;

  /// Per il log manuale resta affidabile fin dalla creazione (sia
  /// `_aggiungiEsercizio` sia `startWorkoutFromTemplate` impostano `sets=[]`
  /// solo per cardio), a differenza di `durationSeconds`, che può restare
  /// null anche per un esercizio cardio non ancora compilato dall'utente.
  bool get isCardio => sets.isEmpty && !importedIsStrength;

  // Fase 21: tracciabilità della scheda/programma di provenienza, valorizzati solo
  // quando l'esercizio nasce da startWorkoutFromTemplate (null per il log libero).
  // Snapshot (non solo l'id) così il riferimento resta leggibile anche se la scheda
  // o il programma vengono rinominati o eliminati in seguito.
  int? sourceTemplateId;
  String? sourceTemplateName;
  int? sourceProgramId;
  String? sourceProgramName;
}
