import 'package:isar/isar.dart';

part 'workout_set.g.dart';

/// Tecnica di allenamento applicabile a una singola serie
/// (docs/tecniche_allenamento.md). Piramidale e superset veloce/lento non ci
/// sono: la prima è un generatore a parte (menu esercizio in
/// allenamento_screen.dart), il secondo è una proprietà dell'esercizio
/// (`WorkoutExercise.supersetRole`), non della singola serie.
enum SetTechnique { normale, forzate, restPause, stripping, superSlow }

@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
  int? rpe; // sforzo percepito 1-10 (opzionale, Fase 9)
  bool isWarmup = false; // serie di riscaldamento: esclusa da PR/volume/overload (Fase 15)

  // Fase 23: true solo quando l'utente conferma esplicitamente la serie in
  // modalità guidata (tocca la spunta) — reps/weightKg possono già essere
  // valorizzati prima (target della scheda o suggerimento di overload), senza
  // che la serie sia stata davvero eseguita.
  bool confirmed = false;

  // Tecniche di allenamento (docs/tecniche_allenamento.md, Fase 2) — tutti
  // opzionali/default a "non usato": `null`/`false` per ogni serie già
  // registrata e per chi non usa la tecnica, nessuna migrazione necessaria.

  // Forzate: ripetizioni completate oltre `reps` con l'aiuto di un compagno.
  // Escluse dal volume "pulito" (WorkoutProgressService/database_service),
  // non sono carico sollevato in autonomia.
  int? forcedReps;

  // Super slow: stessa serie, tempo di esecuzione molto lento. Solo
  // presentazionale (badge), nessun impatto sui calcoli.
  bool isSuperSlow = false;

  // Rest-pause: reps di ogni mini-cluster (es. [8, 4, 3] — cedimento, pausa
  // breve, altre reps allo stesso peso, ripetuto). `reps` resta la somma dei
  // cluster: i calcoli esistenti (volume, overload) restano corretti senza
  // modifiche, vedi sezione 5 del doc.
  List<int>? restPauseClusters;

  // Stripping (drop set): gradini successivi a peso decrescente dopo questa
  // stessa serie (che è il primo gradino, a `reps`/`weightKg`). Il volume va
  // sommato su tutti i gradini (WorkoutProgressService/database_service),
  // diversamente da rest-pause.
  List<DropStage>? dropStages;

  /// Tecnica dedotta dai campi valorizzati — priorità forzate > super slow >
  /// rest-pause > stripping, mutuamente esclusive per costruzione (`_SetRow`
  /// in sessione_guidata_screen.dart scrive un solo gruppo di campi per
  /// conferma). Unica fonte di verità per badge/etichette (sessione guidata,
  /// storico, PDF export): centralizzata qui dopo che la stessa priorità si
  /// era duplicata in 4 punti diversi del codice.
  @ignore
  SetTechnique get technique {
    if (forcedReps != null) return SetTechnique.forzate;
    if (isSuperSlow) return SetTechnique.superSlow;
    if (restPauseClusters?.isNotEmpty == true) return SetTechnique.restPause;
    if (dropStages?.isNotEmpty == true) return SetTechnique.stripping;
    return SetTechnique.normale;
  }
}

/// Un gradino di uno stripping/drop set successivo alla serie principale.
@embedded
class DropStage {
  int? reps;
  double? weightKg;
}
