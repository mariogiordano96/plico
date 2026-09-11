# Tecniche di Allenamento — Analisi Funzionale

> Obiettivo: estendere il modello "serie = reps + peso" con le tecniche di
> intensità più usate da chi allena da intermedio in su — oggi Plico supporta
> solo il superset semplice (`WorkoutExercise.supersetGroupId`, esercizi in
> sequenza senza riposo tra loro). Manca tutto il resto: piramidale, forzate,
> rest-pause, stripping (drop set), super slow, superset veloce/lento.

---

## 1. Scope

Tecniche da coprire, con la definizione usata in questo documento:

| Tecnica | Definizione |
|---|---|
| **Piramidale** | Più serie dello stesso esercizio con peso che sale (o scende) e ripetizioni che scendono (o salgono) di conseguenza |
| **Forzate** | Oltre il cedimento, ripetizioni aggiuntive completate con l'aiuto di un compagno |
| **Rest-pause** | Cedimento, pausa breve (10-15s), altre ripetizioni allo stesso peso — ripetuto 2-3 volte, contato come una sola serie |
| **Stripping (drop set)** | Cedimento, il peso si riduce subito senza pausa e si continua — anche a cascata (doppio/triplo drop) |
| **Super slow** | Serie normale ma con tempo di esecuzione molto lento (es. 10s salita/10s discesa) |
| **Superset veloce/lento** | Due esercizi consecutivi senza riposo: uno con carico alto eseguito esplosivo, uno con carico più basso eseguito lento |

Fuori scope v1: metronomo/guida al tempo per il super slow (serve solo il tag,
non un timer dedicato); editor di piramidi con progressioni non lineari
(bastano incrementi costanti).

---

## 2. Classificazione per impatto

Non tutte le tecniche richiedono di toccare il modello dati — alcune sono già
rappresentabili con `WorkoutSet` (reps/peso indipendenti per serie), altre
rompono l'assunzione "una serie = una coppia reps/peso".

**Basso impatto — nessuna o piccola modifica al modello:**
- **Piramidale** — nessuna modifica: già rappresentabile con serie esistenti a
  reps/peso diversi. Manca solo un helper di generazione in fase di creazione
  scheda.
- **Forzate** — un campo in più per le ripetizioni assistite.
- **Super slow** — un flag booleano, puramente presentazionale.
- **Superset veloce/lento** — estende `supersetGroupId` già esistente con un
  ruolo per esercizio ("esplosiva"/"lenta"), nessuna nuova struttura di
  raggruppamento.

**Impatto strutturale — la serie diventa una sequenza, non una coppia:**
- **Rest-pause** — una serie è in realtà più mini-cluster di ripetizioni
  (es. 8+4+3) con lo stesso peso.
- **Stripping** — una serie è più "gradini" con peso decrescente a ogni
  gradino.

---

## 3. Modello dati attuale

```dart
// lib/models/workout_set.dart — @embedded, non una collection propria
class WorkoutSet {
  int? reps;
  double? weightKg;
  int? rpe;            // sforzo percepito 1-10, opzionale
  bool isWarmup = false;
  bool confirmed = false;
}

// lib/models/workout_exercise.dart — @collection
class WorkoutExercise {
  ...
  int? supersetGroupId; // esercizi in sequenza senza riposo tra loro
  int? restSeconds;     // riposo dopo l'ultima serie/il completamento
  List<WorkoutSet> sets = [];
  ...
}
```

`rpe` è già un precedente utile: un campo opzionale per serie, che non tocca
nessun calcolo esistente quando è `null`. Lo stesso principio vale per i campi
nuovi proposti sotto — tutti opzionali, `null` per le sessioni già registrate
e per chi non usa la tecnica.

---

## 4. Modello dati proposto

### `WorkoutSet` — nuovi campi

```dart
int? forcedReps;               // ripetizioni forzate oltre `reps`, assistite
bool isSuperSlow = false;      // tempo di esecuzione molto lento

List<int>? restPauseClusters;  // es. [8, 4, 3] — reps di ogni mini-cluster.
                                // `reps` resta la somma (8+4+3=15): i calcoli
                                // esistenti (volume, overload) continuano a
                                // funzionare senza modifiche, vedi sezione 5.

List<DropStage>? dropStages;   // gradini successivi dello stripping, il
                                // primo gradino è `reps`/`weightKg` di questa
                                // stessa WorkoutSet.
```

```dart
@embedded
class DropStage {
  int? reps;
  double? weightKg;
}
```

### `WorkoutExercise` — nuovo campo

```dart
String? supersetRole; // 'esplosiva' | 'lenta' — solo per esercizi in un
                       // supersetGroupId che usano la variante veloce/lenta;
                       // null per il superset semplice esistente
```

Nessun campo su `WorkoutTemplateExercise` (il target nella scheda): le
tecniche si scelgono/registrano a livello di singola serie durante la
creazione scheda o la sessione guidata, non come default dell'esercizio.

**Migrazione**: tutti i campi nuovi sono opzionali con default `null`/`false`
— nessuna migrazione dati necessaria, le sessioni già registrate restano
valide (tecnica "normale" implicita). Richiede solo `dart run build_runner
build --delete-conflicting-outputs` per lo schema Isar.

---

## 5. Impatto sui calcoli esistenti

Tracciato nel codice attuale, non ipotizzato:

- **Volume** (`database_service.dart:1258-1261`,
  `workout_progress_service.dart:74`) — oggi `sum(reps * weightKg)` per serie.
  - *Rest-pause*: nessuna modifica. `reps` è già la somma dei cluster, la
    formula esistente resta corretta.
  - *Stripping*: **va aggiornata** — `reps * weightKg` conta solo il primo
    gradino, ignorando volume reale dei gradini successivi (peso diverso per
    gradino). Nuova formula quando `dropStages != null`:
    `reps*weightKg + sum(stage.reps * stage.weightKg per ogni stage)`.
  - *Forzate*: `forcedReps` va escluso dal volume "pulito" (non è carico
    realmente sollevato in autonomia) — non sommarlo a `reps` nella formula.

- **Stima 1RM/overload** (`workout_progress_service.dart:96`,
  `s.weightKg! * (1 + s.reps! / 30)`) — usa il peso più alto della serie con
  le sue reps.
  - *Stripping*: va usato il **primo gradino** (`reps`/`weightKg` a livello
    di `WorkoutSet`, il peso più alto), non i gradini successivi — già così
    con la formula attuale, nessuna modifica necessaria.
  - *Rest-pause*: usare `reps` (somma) sovrastimerebbe il carico realmente
    sostenuto in un singolo sforzo continuo — da valutare se escludere queste
    serie dal calcolo 1RM o usare solo il primo cluster. **Decisione aperta**,
    vedi sezione 8.

- **Stima kcal** (`CalorieEstimationService`) — già basata su numero di
  working set, non su reps/peso puntuali: nessuna modifica necessaria per
  nessuna delle tecniche.

- **PDF export / Storico** (`StoricoEsercizioScreen`) — vanno solo estesi per
  *mostrare* la tecnica (badge/testo), non ricalcolano nulla di proprio.

---

## 6. UX — creazione scheda

In `crea_scheda_screen.dart` / `target_esercizio_dialog.dart`, per ogni serie:

- Selettore "Tecnica" (chip orizzontali, default "Normale") — le opzioni
  strutturali (rest-pause, stripping) rivelano campi aggiuntivi inline
  (numero di cluster/gradini con reps/peso), le altre (forzate, super slow)
  bastano un toggle.
- **Piramidale**: non è una tecnica per singola serie, ma per l'intero
  esercizio — un pulsante separato "Genera piramide" che chiede peso/reps di
  partenza, numero di serie, direzione (crescente/decrescente) e incremento,
  poi compila le serie esistenti. Nessun nuovo stato persistito.
  **Come implementato (Fase 1)**: non in `target_esercizio_dialog.dart` —
  quel dialog produce un `WorkoutTemplateExercise` con un solo target
  (serie×reps@peso uniformi), non una lista di serie diverse, e la piramide
  non può sopravvivere a un salvataggio lì senza estendere lo schema Isar
  del template (fuori scope Fase 1). Vive invece come voce di menu
  "Genera piramide" sulla card esercizio in `allenamento_screen.dart`
  (`genera_piramide_dialog.dart`), che sovrascrive direttamente le
  `WorkoutSet` già materializzate dell'esercizio nel log del giorno — stesso
  punto dove oggi vive "Modifica" (`_modifica`). Decisione deliberata: la
  piramide è tipicamente decisa "per oggi" in base alla forma del momento,
  non un target fisso da salvare nella scheda riutilizzabile.
- **Superset veloce/lento**: quando si crea un superset (toggle già
  esistente), un secondo selettore per esercizio: "Esplosiva" / "Lenta".
  **Nota**: il riposo *tra* i membri di un gruppo superset è già zero per
  costruzione (`showRestTimerSheet` scatta solo dopo l'ultimo esercizio del
  giro, non tra un membro e l'altro — vedi `sessione_guidata_screen.dart`),
  quindi non serve nessun default speciale su `restSeconds` per questa
  variante: la riga sul punto era una sovra-ingegnerizzazione dell'analisi
  iniziale, rimossa in fase di implementazione (Fase 3).
  **A differenza della piramide**, `supersetRole` va anche su
  `WorkoutTemplateExercise` (non solo `WorkoutExercise`): l'abbinamento
  esplosiva/lenta è una scelta strutturale sulla coppia di esercizi, stabile
  tra una sessione e l'altra — stesso motivo per cui `supersetGroupId` è già
  a livello di template oggi, diversamente dalla piramide (numeri concreti,
  decisi il giorno stesso).

## 7. UX — sessione guidata

In `sessione_guidata_screen.dart` (`_ExerciseStepCard`):

- **Rest-pause/stripping**: la conferma di una serie diventa multi-stadio
  invece di un singolo tap — dopo il primo cluster/gradino, la card mostra
  "cluster 2 di 3" (o "gradino successivo: -Xkg") con un secondo pulsante di
  conferma, non un nuovo `showRestTimerSheet` tra i cluster (per definizione
  senza pausa lunga, o pausa brevissima non gestita dal timer esistente).
- **Forzate/super slow**: nessun cambio di flusso, solo un badge sulla card
  e il campo `forcedReps` accanto a `reps` quando il toggle è attivo.
- **Superset veloce/lento**: badge "esplosiva"/"lenta" sulla card, stesso
  meccanismo "a turni" già presente per il superset semplice
  (`GuidedSessionService.turnFor`, lucchetto + tooltip sulla card non di
  turno — riusabile senza modifiche).

---

## 8. Considerazioni aperte / rischi

- **1RM su rest-pause**: usare `reps` totale sovrastima lo sforzo — da
  decidere se escludere queste serie dal calcolo overload o usare solo il
  primo cluster. Non bloccante per iniziare l'implementazione (default:
  escluse, come le serie di riscaldamento oggi).
- **Scope MVP**: le sei tecniche non vanno implementate tutte insieme — la
  Fase 1 (piramidale) è a costo quasi zero e già dà valore; rest-pause e
  stripping (Fasi 3-5) sono il grosso del lavoro.
- **Isar schema**: `DropStage` è una nuova classe `@embedded` — verificare che
  liste di embedded dentro embedded (`WorkoutSet.dropStages` dentro
  `WorkoutExercise.sets`) siano supportate da Isar 3.1 prima di iniziare la
  Fase 2 (dovrebbero esserlo, ma da confermare con una build di prova).

---

## 9. Piano di implementazione

### Fase 1 — Piramidale ✅
- [x] Helper "Genera piramide" — voce di menu sulla card esercizio in
      `allenamento_screen.dart` (`_generaPiramide`), dialog dedicato
      `genera_piramide_dialog.dart` (peso/reps di partenza, N serie,
      direzione ascendente/discendente, incremento kg, decremento rip,
      anteprima live) → sovrascrive le `WorkoutSet` dell'esercizio nel log
      del giorno. Non disponibile per il cardio (menu condizionato a
      `!isCardio`, oltre a `source == null` come Modifica/Sostituisci)
- [x] Nessuna modifica al modello dati — solo nuove stringhe l10n
      (`allenamentoGeneraPiramide`, `piramideDialog*`)

### Fase 2 — Modello dati tecniche ✅
- [x] Nuovi campi su `WorkoutSet`: `forcedReps`, `isSuperSlow`,
      `restPauseClusters`, `dropStages` (+ classe `DropStage` embedded)
- [x] Nuovo campo `supersetRole` su `WorkoutExercise` (enum `SupersetRole`,
      stesso pattern `.name` già usato per `WorkoutSource`/`source`)
- [x] `dart run build_runner build --delete-conflicting-outputs` —
      **confermato**: Isar 3.1 gestisce correttamente liste di embedded
      annidate (`WorkoutSet.dropStages` dentro `WorkoutExercise.sets`),
      `readObjectList<DropStage>`/`DropStageSchema` generati senza problemi.
      `flutter analyze` pulito, 65 test esistenti su workout/database
      ancora verdi (nessuna migrazione necessaria, tutti i campi nuovi sono
      opzionali)

### Fase 3 — UI creazione scheda ✅
- [x] Campo `supersetRole` anche su `WorkoutTemplateExercise` (non solo
      `WorkoutExercise`, aggiunto in Fase 2) — copiato in `WorkoutExercise`
      da `startWorkoutFromTemplate`, e propagato anche da `duplicateTemplate`
      e dal caricamento dei preset (`_presetTemplateFromJson`), non solo da
      `startWorkoutFromTemplate` come previsto inizialmente — altrimenti
      duplicare una scheda con superset veloce/lento avrebbe perso il tag
- [x] Selettore ruolo esplosiva/lenta (`_RoleChip`) su `_EsercizioRow` in
      `crea_scheda_screen.dart`, visibile solo per righe in un gruppo
      superset (`supersetGroupId != null`); tap sullo stesso ruolo già
      selezionato lo azzera; azzerato anche quando l'esercizio esce dal
      gruppo (`_toggleSuperset`)
- [ ] **Riallocate a Fase 4** (non "creazione scheda"): selettore tecnica
      per serie e campi dinamici rest-pause/stripping — richiedono editing
      per-`WorkoutSet`, che esiste solo in sessione guidata, non nel target
      singolo di `WorkoutTemplateExercise` (stesso vincolo della piramide,
      Fase 1)

### Fase 4 — UI sessione guidata
- [ ] Selettore tecnica per serie (chip: normale/forzate/rest-pause/
      stripping/super slow) su `_ExerciseStepCard`, campi dinamici per
      rest-pause (N cluster) e stripping (N gradini)
- [ ] Conferma multi-stadio per rest-pause/stripping in
      `_ExerciseStepCard`
- [ ] Badge tecnica (forzate, super slow, esplosiva/lenta) sulle card

### Fase 5 — Calcoli
- [ ] Volume: includere i gradini di `dropStages` nella formula
      (`database_service.dart`, `workout_progress_service.dart`)
- [ ] Escludere `forcedReps` dal volume "pulito"
- [ ] Decisione + implementazione 1RM su rest-pause (vedi sezione 8)

### Fase 6 — Storico e PDF export
- [ ] Rappresentare la tecnica nel grafico storico esercizio
      (`StoricoEsercizioScreen`)
- [ ] Rappresentare la tecnica nell'export PDF del riepilogo allenamento
