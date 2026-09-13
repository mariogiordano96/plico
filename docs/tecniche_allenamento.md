# Tecniche di Allenamento — Analisi Funzionale

> ✅ **COMPLETATA** — Fasi 1-6 implementate e pushate su `main`. Vedi "Stato
> finale" in fondo al documento. Fase 7 (pianificazione in creazione scheda)
> aggiunta successivamente, vedi in fondo al piano.

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

### Fase 4 — UI sessione guidata ✅
- [x] Selettore tecnica per serie (chip: normale/forzate/rest-pause/
      stripping/super slow) su `_SetRow` (ora `StatefulWidget`, riceve la
      `WorkoutSet` reale), campi dinamici per rest-pause (N cluster
      aggiuntivi oltre al primo, che resta il campo reps principale) e
      stripping (N gradini aggiuntivi con reps+peso propri, il primo resta
      reps/peso della serie). Solo per serie di lavoro, non riscaldamento
      (`showTechnique: false` lì)
- [x] **Deviazione dal piano iniziale**: non "conferma multi-stadio" (tap
      separati per cluster/gradino durante l'esecuzione) — in pratica
      l'utente non interagisce col telefono tra un cluster/gradino e l'altro
      di un rest-pause/drop-set reale (10-15s di recupero, o stripping senza
      pausa). La riga espone invece tutti i campi extra subito ed è
      confermata in un solo tap a fine serie, coerente con come l'app già
      funziona oggi (si logga dopo aver fatto la serie, non durante)
- [x] Badge tecnica sulle card dopo la conferma (`_confirmedBadge`: 💪
      forzate, 🐌 super slow, 🔥 cluster rest-pause, ⬇️ stripping) e badge
      esplosiva/lenta (🚀/🐌) sull'header della card esercizio quando
      `supersetRole != null`
- [x] `_confirmSerie` nel parent: `reps` finale = somma dei
      `restPauseClusters` quando presenti (scritti da `_SetRow` prima del
      confirm), altrimenti invariato — volume/overload restano corretti
      senza altre modifiche, come da sezione 5
- [x] **Limite noto**: i campi cluster/gradino aggiuntivi sono stato locale
      di `_SetRow`, non recuperati se l'app si riavvia a metà compilazione
      di una serie non ancora confermata — l'utente li reinserisce

### Fase 5 — Calcoli ✅
- [x] Nuovo `WorkoutProgressService.setVolume(WorkoutSet)`, unico punto che
      calcola il volume di una serie (reps×peso + gradini `dropStages`) —
      usato sia da `sessionVolume` sia da `database_service.dart`
      (`volumeByGroup`), che prima duplicavano la stessa formula inline
- [x] `forcedReps` già escluso dal volume senza bisogno di codice: `_SetRow`
      (Fase 4) non lo somma mai a `reps`, campo separato fin dalla scrittura
- [x] 1RM su rest-pause: **decisione presa** — escluse dal calcolo
      (`estimatedOneRepMax`), stesso trattamento delle serie di
      riscaldamento. `reps` è la somma dei cluster, non ripetizioni di uno
      sforzo continuo: la formula di Epley le sovrastimerebbe
      (es. 15 rip a 100kg → 150kg stimati, contro un 1RM reale molto più
      basso)
- [x] 5 nuovi test in `workout_progress_service_test.dart`: volume
      rest-pause (nessun aggiustamento), volume stripping (gradini
      sommati), volume forzate (forcedReps escluso), 1RM con rest-pause
      escluso, 1RM null se tutte le serie sono rest-pause
- [x] **Non risolto, fuori scope Fase 5**: `suggestNextSession` (target
      della sessione successiva) usa `sets.first.reps` come riferimento —
      se la prima serie di lavoro fosse una rest-pause, il confronto con le
      serie successive userebbe un numero non comparabile (somma cluster
      contro reps singole). Nella pratica il rest-pause si usa quasi sempre
      sull'ultima serie di un esercizio, non la prima: rischio basso, non
      un bug che si manifesta nell'uso tipico. Da rivedere se emerge come
      problema reale

### Fase 6 — Storico e PDF export ✅
- [x] `StoricoEsercizioScreen`: ogni serie nello storico mostra un indicatore
      tecnica inline (💪+N forzate, 🐌 super slow, 🔥8+4+3 rest-pause,
      ⬇️ stripping) tramite `_setLabel`, un solo indicatore per serie (le
      tecniche sono mutualmente esclusive per costruzione)
- [x] Export PDF storico esercizio (`generateStoricoEsercizio`): stesso
      indicatore ma testuale, non emoji — il font PDF (NotoSans) non ne
      garantisce il rendering a differenza dello schermo. 4 nuove stringhe
      opzionali su `PdfStrings` (`tecnicaForzate`/`RestPause`/`Stripping`/
      `SuperSlow`, default italiano hardcoded, stesso pattern già usato per
      le stringhe "Progressi") — così i 4 chiamanti di `PdfStrings` che non
      c'entrano con lo storico esercizio non hanno bisogno di modifiche
- [x] **Fuori scope, gap pre-esistente non toccato**: l'export PDF di
      scheda/programma (`generateScheda`/`generateProgramma`,
      `_buildSchedaEsercizi`) non rappresenta i superset (nessun indicatore
      di gruppo) da prima di questo piano — aggiungere solo il badge
      esplosiva/lenta lì sarebbe incoerente senza prima risolvere quel gap
      più ampio, non specifico alle tecniche di allenamento

---

## Stato finale

Piano completato: tutte le 6 fasi implementate, testate (`flutter analyze`
pulito, 182 test verdi) e pushate su `main`. Le 6 tecniche (piramidale,
forzate, rest-pause, stripping, super slow, superset veloce/lento) sono
editabili nei punti giusti del flusso (menu esercizio per la piramide,
creazione scheda per il ruolo superset, sessione guidata per le altre
quattro) e visibili in storico/PDF. Limiti noti lasciati aperti, non
bloccanti: 1RM su `suggestNextSession` non technique-aware se la prima
serie è rest-pause (sezione Fase 5); campi cluster/gradino non recuperati
da un riavvio app a metà compilazione di una serie (sezione Fase 4); export
PDF scheda/programma senza indicatore superset (sezione Fase 6).

---

## Fase 7 — Pianificazione tecniche in creazione scheda ✅

**Motivazione**: le Fasi 3/4 (sopra) avevano deliberatamente escluso
piramide/rest-pause/stripping/forzate/super slow dalla creazione scheda,
perché richiedevano editing per-serie che il modello dati del target
(`WorkoutTemplateExercise`, un solo target uniforme) non poteva
rappresentare. Feedback dell'utente: se so già che farò un piramidale (o un
rest-pause) su un esercizio, voglio poterlo salvare nella scheda una volta
sola, non ridecidere ogni volta il giorno stesso in sessione guidata.

- [x] **Modello dati**: nuovo `WorkoutTemplateExercise.plannedSets`
      (`List<WorkoutTemplateSet>?`, embedded) — quando valorizzato sostituisce
      il target uniforme. `WorkoutTemplateSet` ha gli stessi campi tecnica di
      `WorkoutSet` (`forcedReps`, `isSuperSlow`, `restPauseClusters`,
      `dropStages`) ma non `rpe`/`isWarmup`/`confirmed` (concetti solo
      dell'esecuzione reale). Campo opzionale, nessuna migrazione.
- [x] `WorkoutTemplateExercise.materializeSets()` consolida in un solo posto
      la generazione delle `WorkoutSet` del giorno (prima duplicata identica
      in `startWorkoutFromTemplate`, `_aggiungiEsercizio`, `_modifica`):
      copia `plannedSets` 1:1 se presente, altrimenti torna al
      `List.generate` uniforme di prima.
- [x] `duplicateTemplate` propaga `plannedSets` (con deep copy via
      `WorkoutTemplateSet.copy()`) — stesso bug di categoria già risolto per
      `supersetRole` in Fase 3 (dimenticarlo avrebbe fatto perdere la
      pianificazione duplicando una scheda). **Non esteso** a
      `_presetTemplateFromJson`: nessun preset JSON usa oggi `plannedSets`,
      stesso principio "nessun codice per dati che non esistono ancora".
- [x] **UI** in `target_esercizio_dialog.dart` (condiviso da creazione
      scheda e dal log libero/`_modifica` in `allenamento_screen.dart`):
      toggle "Serie personalizzate" che sostituisce i 3 campi uniformi
      (Serie/Rip/Kg) con una lista di righe per-serie, ciascuna con reps/peso
      e lo stesso selettore tecnica (chip + campi extra rest-pause/
      stripping/forzate) già usato in sessione guidata. Pulsante "Genera
      piramide" riusa `showGeneraPiramideSheet` esistente (Fase 1) per
      precompilare la lista con una progressione, poi ogni riga resta
      modificabile (es. aggiungere rest-pause solo sull'ultima serie della
      piramide).
- [x] Estratti in `widgets/technique_widgets.dart` i due widget presentazionali
      (`TechniqueChip`, `NumberField`) prima privati e duplicati in
      `sessione_guidata_screen.dart` — riusati identici nella nuova UI,
      nessuna duplicazione di ~150 righe di logica stateful cluster/gradino
      (quella resta specifica per contesto: sessione guidata conferma una
      serie alla volta, qui si pianificano N serie in anticipo).
- [x] `crea_scheda_screen.dart` (`_EsercizioRow`): il riepilogo mostra
      `12×40kg · 8×50kg` per-serie quando `plannedSets` è presente, invece
      del riepilogo uniforme `3×10 · 40kg`.
- [x] **Riconoscimento "era personalizzata" in modifica**: `_modifica`
      (`allenamento_screen.dart`) passa un `WorkoutExercise` già
      materializzato, non il `WorkoutTemplateExercise` originale (che non
      esiste più a quel punto, o non è mai esistito per il log libero) —
      `_looksCustom` deduce l'euristica dalle `WorkoutSet` stesse (reps/peso
      non uniformi, o almeno una tecnica non normale).
- [x] Nuovi test in `database_service_workout_test.dart`:
      `plannedSets` materializzato correttamente da `startWorkoutFromTemplate`
      (tecnica inclusa, target uniforme ignorato quando presente), e
      `duplicateTemplate` non condivide le liste embedded con l'originale.
- [x] `flutter analyze` pulito, 184 test verdi (182 + 2 nuovi).
- [ ] **Non affrontato, fuori scope**: nessun flusso di modifica per un
      esercizio già aggiunto a una scheda in `crea_scheda_screen.dart` —
      limite preesistente anche per il target uniforme (si rimuove e si
      riaggiunge), non introdotto da questa fase.

### Fase 7c — Fix: tecnica pianificata in sessione guidata ✅

**Bug segnalato dall'utente dopo il primo test reale**: una serie
rest-pause/stripping pianificata in scheda arrivava in sessione guidata con
la tecnica già selezionata (chip evidenziata), ma `_SetRowState.initState`
non recuperava i cluster/gradini aggiuntivi da `WorkoutSet.restPauseClusters`
/`dropStages` — confermare la serie senza toccare nulla li azzerava
silenziosamente (`_handleConfirm` li ricalcola dai campi extra, vuoti se mai
popolati). Il fix di Fase 4 al riavvio app era lo stesso limite, ma raro; con
la pianificazione in scheda diventa il percorso comune.

Feedback aggiuntivo, più di UX: se la scheda ha già deciso la tecnica, i
pulsanti normale/forzate/rest-pause/stripping/super slow in sessione guidata
non devono richiedere nessuna interazione — si segue con le spunte, non si
"risetta" niente.

- [x] `_SetRowState.initState` ora idrata `_clusterCtrls`/`_stageCtrls` da
      `w.restPauseClusters`/`w.dropStages` quando presenti — confermare senza
      modifiche preserva esattamente il piano.
- [x] Nuovo stato `_editingTechnique`: `false` di default quando la tecnica
      arriva già decisa (`w.technique != normale` all'apertura, quindi non
      scelta ora dall'utente) — al posto del picker si vede solo un'etichetta
      (`_plannedBadge`, stesso formato di `_confirmedBadge` ma pre-conferma)
      con un tocco "Modifica" per riaprirlo se si vuole cambiare per oggi.
      Per una serie senza tecnica pianificata (`normale` all'apertura) il
      picker resta visibile come prima — scelta spontanea di una tecnica a
      metà sessione resta un caso d'uso valido, non solo la pianificazione.
- [x] `flutter analyze` pulito, 184 test verdi (nessun nuovo test: fix
      puramente di widget state, non c'è un test harness per
      `sessione_guidata_screen.dart` in questo repo — verificato manualmente
      dall'utente sul device).

### Fase 7d — Fix: nessuna modifica tecnica in sessione guidata ✅

**Feedback dell'utente dopo aver provato la Fase 7c**: il tocco "Modifica"
introdotto lì non ha senso — la sessione guidata deve solo eseguire la
scheda (spunte), non permettere di cambiare la tecnica di un esercizio.
Deciderla è un'azione di creazione scheda, non di esecuzione.

- [x] Rimossi del tutto `_editingTechnique` e il picker a chip
      (normale/forzate/rest-pause/stripping/super slow) da
      `sessione_guidata_screen.dart` — la tecnica è fissata una volta per
      tutte in `initState` da `WorkoutSet.technique` e non è più
      modificabile in sessione guidata, né per una serie pianificata né per
      una libera (prima si poteva scegliere spontaneamente a metà sessione;
      tolto su richiesta esplicita, non solo il caso pianificato).
- [x] Restano editabili solo i **numeri** della tecnica già fissata — reps
      forzate, valori dei cluster rest-pause, reps/peso dei gradini
      stripping — stessa logica di "reps/kg restano editabili" già valida
      per ogni altra serie: non è la categoria di tecnica a cambiare, solo
      cosa si è realmente fatto quel giorno.
- [x] Rimossa la stringa l10n `sessioneGuidataModificaTecnica` (mai arrivata
      in produzione, introdotta e tolta nella stessa iterazione).
- [x] `flutter analyze` pulito, 184 test verdi.

### Fase 7e — Scheda di test fissa per QA manuale ✅

**Richiesta dell'utente**: ricreare a mano una scheda con tutte le tecniche
a ogni build da testare è lento. `DatabaseService.seedTestTemplateTecniche()`
crea/ricrea (cancella prima eventuali omonime, così riflette sempre
l'ultima versione del metodo) una scheda standalone "TEST — Tecniche" con
un esercizio per ciascun caso: normale uniforme, piramide pianificata,
rest-pause pianificato, stripping pianificato, forzate pianificate, super
slow pianificato, superset esplosiva/lenta, cardio.

- [x] Chiamata da `main.dart` solo sotto `kDebugMode` (mai in release: un
      `flutter install` senza `--debug` non la esegue) — stesso pattern già
      usato per il toggle lingua debug in `home_screen.dart`. Per vederla,
      installare con `flutter install --debug` invece del comando release.
- [x] `flutter analyze` pulito, 184 test verdi (nessun nuovo test: è un
      helper di QA manuale, non logica di prodotto).
- [x] **Seguito**: `DatabaseService.seedTestUserProfileIfMissing()` crea
      anche un profilo utente/onboarding completo (nome, sesso, altezza,
      peso, obiettivo) se assente, per non dover rifare l'onboarding a mano
      a ogni build di test — chiamata insieme alla scheda, sempre sotto
      `kDebugMode`. **A differenza della scheda, non sovrascrive mai un
      profilo già esistente**: se lo stesso device viene usato anche per
      l'uso quotidiano vero dell'app, sovrascrivere il profilo reale
      cancellerebbe dati reali.
      **Nota per l'utente**: se il device richiede comunque l'onboarding
      dopo `flutter install --debug`, è probabile che Android abbia dovuto
      disinstallare l'app prima di reinstallarla (firma debug diversa da
      quella usata per le build precedenti installate su questo device),
      il che azzera tutto il database locale, non solo il profilo — non
      un bug di questa fase, comportamento standard di Android su firme
      incompatibili.

### Fase 7f — Fix: foglio "Genera piramide" sotto la status bar (Samsung) ✅

`showModalBottomSheet` con `isScrollControlled: true` e nessun `constraints`
esplicito lascia crescere il foglio oltre l'altezza schermo quando il
contenuto è alto (anteprima piramide su molte serie) — segnalato
dall'utente su Samsung, il foglio finiva sotto la status bar/notch invece
di scorrere internamente.

- [x] `constraints: BoxConstraints(maxHeight: 90% schermo)` su
      `genera_piramide_dialog.dart` e `target_esercizio_dialog.dart`
      (stesso rischio con molte "serie personalizzate"), con
      `SingleChildScrollView` sul contenuto interno così l'eccesso scorre
      invece di sforare.
- [x] `flutter analyze` pulito, 184 test verdi.

### Fase 7g — Fix: picker tecnica nascosto di default per-serie in creazione ✅

**Feedback dell'utente**: dopo "Genera piramide" ogni riga mostrava comunque
tutti i chip tecnica (Normale/Forzate/Rest-pause/Stripping/Super slow) —
ridondante, avendo già dichiarato che è un piramidale generandolo. Stesso
principio già applicato in sessione guidata (Fase 7c/7d), qui adattato alla
creazione: la tecnica resta scelta esplicita, non sparisce del tutto (a
differenza della sessione guidata, in creazione ha senso poterne aggiungere
una a una riga specifica, es. rest-pause solo sull'ultima serie della
piramide), ma non è più sempre visibile.

- [x] `_PlannedSetState.showPicker` (nuovo campo): `false` di default per
      una riga senza tecnica (nuova riga, o generata da "Genera piramide"),
      `true` se la riga arriva già con una tecnica (modifica di un
      esercizio esistente via `_looksCustom`/`fromWorkoutSets`).
- [x] `_PlannedSetRow` mostra un link discreto "+ Tecnica" al posto dei
      chip quando `showPicker` è `false`; un tocco lo apre per quella riga.
- [x] `flutter analyze` pulito, 184 test verdi.

### Fase 7h — Redesign: tecnica a livello di esercizio, non per-serie ✅

**Feedback dell'utente, dopo tre iterazioni sul punto (Fase 7c/7d/7g)**: la
tecnica (forzate/rest-pause/stripping/super slow) non è un concetto
per-serie — nell'uso reale si decide "questo esercizio lo faccio a
rest-pause", non riga per riga. Il picker per-serie (anche nascosto di
default, Fase 7g) restava concettualmente sbagliato. Richiesta esplicita:
un selettore "Tecnica" in alto, sopra l'elenco serie, con una descrizione
di cosa fa la tecnica scelta.

- [x] **Rimossa la tecnica da `_PlannedSetState`** (`target_esercizio_dialog.dart`):
      la riga di una serie pianificata torna a contenere solo reps/peso —
      niente più `technique`/`showPicker`/`forcedCtrl`/cluster/gradini per
      riga. `_PlannedSetRow` è tornata una riga semplicissima.
- [x] Nuova sezione "Tecnica" in `_TargetEsercizioDialogState`, sopra
      l'elenco serie (sia in modalità uniforme sia "Serie personalizzate"):
      chip Normale/Forzate/Rest-pause/Stripping/Super slow, con una
      descrizione testuale sotto quando non è "Normale"
      (`targetDialogTecnicaDescrizione*`) e i campi extra (reps forzate,
      cluster, gradini) una sola volta, condivisi.
- [x] `_applyTecnica` applica la tecnica scelta **identica a ogni serie**
      generata (sia dal target uniforme sia dalle serie personalizzate) al
      salvataggio — non più letta/scritta riga per riga.
- [x] `plannedSets` ora si popola anche quando l'unica personalizzazione è
      la tecnica (prima serviva "Serie personalizzate" attivo): il target
      resta invece uniforme (`targetSets`/`targetReps`/`targetWeightKg`,
      nessun `plannedSets`) solo quando tecnica è "Normale" e le serie non
      sono personalizzate — percorso più semplice invariato per chi non usa
      nessuna delle due funzionalità.
- [x] `_detectTechnique`/`_looksCustomSets` separano di nuovo le due
      dimensioni in modifica: la tecnica si rileva dalla prima serie
      (uniforme per costruzione, essendo scritta identica su tutte), le
      serie personalizzate dal confronto reps/peso tra le serie.
- [x] `crea_scheda_screen.dart` (`_EsercizioRow`): il riepilogo mostra ora
      anche l'etichetta della tecnica (es. "Rest-pause") sotto le
      reps/peso, quando presente.
- [x] `flutter analyze` pulito, 184 test verdi (nessun nuovo test: modifica
      di UI/dialog, la logica di materializzazione già coperta dai test di
      Fase 7a non cambia).

### Fase 7i — Redesign: "Piramidale"/"Piramidale inverso" al posto di "Serie personalizzate" ✅

**Feedback dell'utente**: con la tecnica ormai a livello di esercizio (Fase
7h), "Serie personalizzate" (toggle + lista manuale + pulsante "Genera
piramide" separato) restava solo per il caso piramide — troppi click e
sezioni per un risultato che è sempre una progressione aritmetica.
Richiesta: sostituirla con una sezione "Piramidale"/"Piramidale inverso"
che genera la progressione in automatico dagli stessi campi Serie/Rip/Kg,
senza aprire un foglio a parte.

- [x] **Rimossi del tutto** `_custom`, `_rows`, `_PlannedSetState`,
      `_PlannedSetRow`, `_toggleCustom`/`_addRow`/`_removeRow`,
      `_generaPiramide` (chiamata a `showGeneraPiramideSheet`) da
      `target_esercizio_dialog.dart` — nessuna lista di serie modificabile
      a mano, i campi Serie/Rip/Kg sono sempre gli unici 3 campi visibili.
- [x] Nuovo enum `_Progressione { normale, piramidale, piramidaleInverso }`
      con una sezione "Progressione" (stesso stile chip di "Tecnica", con
      descrizione) sotto Serie/Rip/Kg: se non "Normale", due campi in più
      (incremento kg, decremento rip, stessi nomi/default di
      `genera_piramide_dialog.dart`) e la progressione si genera al
      salvataggio con la stessa formula (`_generaSerieBase`) — non c'è più
      un foglio separato da aprire per questo, tutto inline.
      **"Piramidale"** = ascendente (peso su, reps giù), **"Piramidale
      inverso"** = discendente (peso giù, reps su) — stessa distinzione
      ascendente/discendente di prima, nomi diversi.
- [x] `genera_piramide_dialog.dart`/`showGeneraPiramideSheet` **non
      rimossi**: restano l'unico modo di rigenerare una piramide per il log
      del **giorno** (menu esercizio in `allenamento_screen.dart`, Fase 1),
      un caso d'uso distinto e ancora valido ("decido la piramide di oggi
      in base alla forma", indipendente dalla scheda salvata).
- [x] `_detectProgressione`: in modifica di un esercizio esistente, se le
      prime due serie hanno reps/peso diversi si deduce direzione e
      incremento/decremento dalla differenza — non c'è più uno stato
      "custom" salvato a parte da rileggere, si ricostruisce dai dati.
- [x] `flutter analyze` pulito, 184 test verdi (nessun nuovo test: la
      formula piramide è la stessa già in `genera_piramide_dialog.dart`,
      non testata prima nemmeno lì).

### Fase 7j — Fix: esplosiva/lenta solo tra due card dello stesso esercizio ✅

**Feedback dell'utente**: il ruolo esplosiva/lenta compariva per qualunque
coppia in superset, ma ha senso solo tra due card dello **stesso**
esercizio (carico alto esplosivo/carico più basso lento sullo stesso
movimento) — con due esercizi diversi collegati è un superset standard, il
ruolo non si applica.

- [x] `_isSameExerciseSuperset(i)` in `crea_scheda_screen.dart`: vero solo
      se il gruppo ha esattamente 2 membri con lo stesso `exerciseId`.
      `_EsercizioRow` mostra i chip esplosiva/lenta solo quando
      `showRoles` è vero, altrimenti la card resta un superset standard
      (icona/bordo di gruppo, nessun ruolo).
- [x] `_clearRolesIfNotSamePair`: azzera `supersetRole` sui membri di un
      gruppo che non è più una coppia dello stesso esercizio (rimozione di
      un membro, unione con un terzo esercizio diverso) — evita un ruolo
      "appeso" che non sarebbe più visibile in UI ma resterebbe salvato e
      propagato (badge esplosiva/lenta in sessione guidata) senza che
      l'utente lo veda più nel punto dove lo ha impostato.
- [x] `flutter analyze` pulito, 184 test verdi.

### Fase 7k — Fix: peso obbligatorio nella piramide non comunicato, salvataggio silenzioso ✅

**Feedback dell'utente**: con "Piramidale"/"Piramidale inverso" selezionato,
salvare senza Kg non faceva procedere — ma il campo restava etichettato
"Kg (opzionale)" come nel caso normale, e il tap su "Salva" falliva senza
nessun messaggio (stesso comportamento silenzioso, in realtà preesistente
anche per "Serie" invalido nel caso normale, solo più visibile ora che il
Kg diventa obbligatorio con la piramide).

- [x] Label del campo Kg dinamica: "Kg (opzionale)" con progressione
      normale, "Kg (richiesto per la piramide)" con piramide/piramide
      inverso selezionato.
- [x] `_salva` non fallisce più in silenzio: nuovo stato `_errore`,
      mostrato come testo rosso sotto i campi, con messaggi specifici
      (serie non valido, durata non valida, ripetizioni/peso mancanti per
      la piramide, incremento/decremento non validi) invece di un
      `return` senza feedback.
- [x] `flutter analyze` pulito, 184 test verdi.

### Fase 7l — Fix: peso obbligatorio (≥0) per confermare una serie in sessione guidata ✅

**Feedback dell'utente**: in sessione guidata si poteva confermare una serie
(tap sulla spunta) senza aver scritto nulla nel campo peso, o con un valore
negativo — il peso deve essere obbligatorio, `0` è un valore valido (a
corpo libero o su macchine assistite che sottraggono peso).

- [x] `_SetRowState._handleConfirm` valida il campo peso prima di
      procedere: se vuoto o negativo, mostra uno `SnackBar` con messaggio
      (`sessioneGuidataErrorePeso`) e non conferma la serie. `0` passa la
      validazione. Vale sia per le serie di riscaldamento sia per quelle
      di lavoro (stesso punto di conferma per entrambe).
- [x] `flutter analyze` pulito, 184 test verdi.
