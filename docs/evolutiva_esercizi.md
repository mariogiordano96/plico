# Evolutiva — Sezione Esercizi

## Idea

Integrare il tracking dell'attività fisica in Plico, complementando il monitoraggio
nutrizionale con la spesa calorica da allenamento. L'utente può cercare esercizi da un
catalogo precompilato (importato da `free-exercise-db`), aggiungerne di propri, e
registrare serie/ripetizioni o durata giorno per giorno. Le kcal stimate dall'allenamento
compaiono nel bilancio giornaliero in Home.

L'utente può inoltre censire **schede di allenamento** personali (liste di esercizi
riutilizzabili) e consultare lo **storico dei carichi/ripetizioni** per ogni esercizio,
per verificare il progressive overload nel tempo (più peso o più ripetizioni a parità
di esercizio).

---

## Fonte dati — `yuhonas/free-exercise-db`

**Repository:** https://github.com/yuhonas/free-exercise-db
**Licenza:** Public Domain — nessun vincolo di attribution o copyleft
**Volume:** ~800 esercizi, file singolo `dist/exercises.json`
**Lingua:** inglese (nessuna traduzione italiana disponibile nel dataset originale)

### Struttura JSON

```json
{
  "id": "Barbell_Bench_Press_-_Medium_Grip",
  "name": "Barbell Bench Press - Medium Grip",
  "force": "push",
  "level": "beginner",
  "mechanic": "compound",
  "equipment": "barbell",
  "primaryMuscles": ["chest"],
  "secondaryMuscles": ["shoulders", "triceps"],
  "instructions": ["Lie back on a flat bench...", "..."],
  "category": "strength",
  "images": ["Barbell_Bench_Press_-_Medium_Grip/0.jpg", "..."]
}
```

### Perché questa fonte

- JSON bundlabile offline → zero costi operativi, funziona senza connessione
- Dataset più grande con immagini (`exercises.json` di wrkout, 2.500+ esercizi) porta immagini
  da ~200 MB non adatte al bundle
- ExerciseDB (11k esercizi, GIF, AGPL) richiede server e ha vincoli di licenza
- 800 esercizi coprono ampiamente palestra + home workout

---

## Strategia di importazione — seed su Isar

Il dataset non è caricato in memoria: al primo avvio viene fatto un **bulk-insert su Isar**
(`exercises.json` dagli asset Flutter). Da quel momento le query sfruttano gli indici Isar
(filtro gruppo muscolare, ricerca per nome) senza codice custom.

Il seed avviene una sola volta, tramite un flag su `AppSettings` (stesso pattern già usato
da `creaSeeded`/`seedCreaFoods()` per il database alimenti CREA), non un count su Isar:

```dart
Future<void> seedExercises() async {
  final settings = await _isar.appSettings.get(1);
  if (settings?.exercisesSeeded == true) return;

  final raw = await rootBundle.loadString('assets/data/exercises_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  final exercises = list.map((e) => _exerciseFromJson(e)).toList();

  await _isar.writeTxn(() async {
    await _isar.exerciseDefinitions.putAll(exercises);
    final s = await _isar.appSettings.get(1) ?? AppSettings();
    s.exercisesSeeded = true;
    await _isar.appSettings.put(s);
  });
}
```

Il file `assets/data/exercises_seed.json` è generato da `tool/seed_exercises.dart` a partire
da `exercise_db_raw.json` (il download grezzo da `free-exercise-db`, committato in root sul
modello di `crea_food_composition_tables.csv`) — stesso schema già usato per il seed CREA:
uno script standalone in `tool/` che produce l'asset, non una trasformazione a runtime.

---

## Modello dati

### `ExerciseDefinition` — catalogo (Isar)

```dart
@collection
class ExerciseDefinition {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String externalId;     // id originale yuhonas (chiave di deduplicazione)

  late String name;           // nome originale inglese
  String? nameIt;             // override italiano (null → mostra name)

  @Index(type: IndexType.value)
  late String muscleGroup;    // chest | back | legs | arms | core | shoulders | cardio

  late String category;       // strength | cardio | stretching | plyometrics
  String? equipment;          // barbell | dumbbell | bodyweight | machine | ...
  String? level;              // beginner | intermediate | expert
  String? mechanic;           // compound | isolation (già nel JSON yuhonas, utile per
                               // ordinare le alternative nella sostituzione esercizio)

  List<String> instructions = [];

  bool isCustom = false;      // true per esercizi aggiunti dall'utente
  bool isDeleted = false;     // soft-delete per i pre-caricati (non cancellati fisicamente)
}
```

### Mapping `primaryMuscles` → `muscleGroup`

Il campo `muscleGroup` viene derivato da `primaryMuscles` al momento del seed:

| primaryMuscles (yuhonas) | muscleGroup |
|---|---|
| chest | chest |
| lats, middle back, lower back, traps | back |
| quadriceps, hamstrings, glutes, calves, adductors, abductors | legs |
| biceps, triceps, forearms | arms |
| abdominals | core |
| shoulders | shoulders |
| categoria `cardio` | cardio |

### `WorkoutLog` — allenamento giornaliero (Isar) ✅ implementato

```dart
@collection
class WorkoutLog {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime date;

  String? note;                // nota libera sulla sessione (es. "ginocchio doloreva")
}
```

> **Correzione rispetto al piano originale**: niente `IsarLinks<WorkoutExercise>` su
> `WorkoutLog`. Dato che `WorkoutExercise.date` è già denormalizzata, gli esercizi di un
> giorno si interrogano direttamente (`WorkoutExercise.filter().dateEqualTo(day)`) senza
> bisogno di un link esplicito — più semplice, nessun overhead di tabella di link.

### `WorkoutExercise` — esercizio eseguito (Isar) ✅ implementato

```dart
@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String exerciseId;      // ExerciseDefinition.externalId
  late String exerciseName;    // snapshot del nome al momento del log

  @Index(type: IndexType.value)
  late DateTime date;          // normalizzata a mezzanotte: query dirette per giorno
                                // e per storico, senza join

  int? supersetGroupId;        // esercizi con lo stesso valore eseguiti in sequenza
                                // senza riposo tra loro (null = esercizio singolo)
  int? restSeconds;            // riposo configurato dopo l'ultima serie/il completamento

  // Per cardio
  int? durationSeconds;
  int? met;                    // valore MET usato per la stima

  // Per strength — embedded, non IsarLinks (vedi nota sotto)
  List<WorkoutSet> sets = [];

  int? estimatedKcal;          // calcolato e persistito al salvataggio
}
```

### `WorkoutSet` — singola serie (Isar, embedded) ✅ implementato

```dart
@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
  int? rpe;                    // sforzo percepito 1-10 (opzionale)
  bool isWarmup = false;        // serie di riscaldamento: esclusa da PR/volume/storico overload
}
```

> **Correzione rispetto al piano originale**: `WorkoutSet` è `@embedded`, e Isar non
> permette `IsarLinks` su tipi embedded (i link richiedono `@collection` su entrambi i
> lati). `WorkoutExercise.sets` è quindi una `List<WorkoutSet>` embedded semplice, come
> già fa `DailyLog.entries` con `MealEntry` nel resto dell'app — coerente con la
> convenzione esistente, e WorkoutSet non ha comunque bisogno di query indipendenti.

---

## Esercizi personalizzati dall'utente

L'utente può aggiungere esercizi non presenti nel catalogo. Vengono salvati come
`ExerciseDefinition` con `isCustom = true` e `externalId` generato lato app (es. UUID).

Campi che l'utente compila:
- Nome (obbligatorio)
- Gruppo muscolare (picker: Petto / Dorso / Gambe / Braccia / Spalle / Core / Cardio)
- Tipo (Forza / Cardio)
- Attrezzatura (opzionale, testo libero o picker)

Gli esercizi custom appaiono nel catalogo mescolati con quelli precaricati, con un'icona
distintiva (es. stella o etichetta "Il mio"). L'utente può modificarli o eliminarli
(cancellazione fisica, non soft-delete).

Gli esercizi precaricati possono essere rinominati (`nameIt`) ma non eliminati fisicamente
(soft-delete con `isDeleted = true` per non ricomparire al prossimo seed).

---

## Localizzazione nomi esercizi

Il dataset è in inglese. Strategia:

1. **File separato** `assets/data/exercises_it.json` con solo gli override:
   `[{"id": "Barbell_Bench_Press_-_Medium_Grip", "nameIt": "Panca piana con bilanciere"}, ...]`
2. Al seed, il campo `nameIt` viene popolato se l'id è presente negli override
3. In UI si mostra `nameIt ?? name`
4. **Copertura iniziale**: ~150 esercizi più comuni (bilanciere, manubri, corpo libero, macchine)
   — coprono >90% degli utilizzi reali in palestra

---

## Stima calorie bruciate ✅ implementata (`CalorieEstimationService`)

### Cardio — formula MET

```
kcal = MET × peso_kg × durata_ore
```

MET per esercizio, mappato sui 14 esercizi cardio reali del dataset `free-exercise-db`
(non sulle etichette generiche del piano originale, che non corrispondevano 1:1 ai nomi
reali — vedi `lib/services/calorie_estimation_service.dart`):

| externalId | MET |
|---|---|
| Bicycling | 8.0 |
| Bicycling_Stationary | 6.8 |
| Elliptical_Trainer | 5.0 |
| Jogging_Treadmill | 8.0 |
| Prowler_Sprint | 8.0 |
| Recumbent_Bike | 5.0 |
| Rope_Jumping | 10.0 |
| Rowing_Stationary | 7.0 |
| Running_Treadmill | 9.5 |
| Skating | 7.0 |
| Stairmaster | 9.0 |
| Step_Mill | 9.0 |
| Trail_Running_Walking | 6.0 |
| Walking_Treadmill | 3.5 |

Fallback MET 6.0 per esercizi cardio custom o non mappati (es. aggiunti dall'utente).

### Strength — MET fisso (non euristica volume)

```
kcal = 4.0 (MET fisso) × peso_kg × durata_stimata_ora
durata_stimata_ora = (numero_serie_di_lavoro × 2.5 min) / 60
```

> **Correzione rispetto al piano originale**: la prima euristica proposta
> (`volume_kg × 0.0008`) aveva un coefficiente sbagliato di circa 40× — per uno squat
> 3×8×80kg (volume 1920) dava ~1.5 kcal, un ordine di grandezza assurdo (un MET-check
> indipendente stima ~60-90 kcal per lo stesso esercizio). Anziché ricalibrare un
> coefficiente arbitrario, si usa direttamente la "alternativa più semplice" già descritta
> nel piano originale (MET fisso × peso corporeo), che è anche più robusta: funziona
> identica per esercizi a corpo libero (dove `weightKg` è spesso `null` e il volume
> sarebbe comunque inaffidabile).

Il peso corporeo usato è l'ultimo `BodySnapshot.pesoKg` registrato; se assente, default
75 kg (`CalorieEstimationService.defaultBodyWeightKg`).

> La stima resta puramente indicativa, su entrambe le formule. Disclaimer in UI: Fase 20
> (Rifinitura) — non ancora mostrato.

### Integrazione in Home ✅ implementata

`_AttivitaCard` in `home_screen.dart`, visibile solo nei giorni con almeno un esercizio
registrato (per non mostrare una riga "Attività: 0 kcal" nei giorni di riposo):

```
Kcal ingerite    2.100
Kcal bruciate     –420
──────────────────────
Bilancio netto   1.680
```

Tap sulla card → passa al tab Allenamento (indice 2).

---

## UI — schermate principali

### Tab Allenamento (schermata principale)

```
┌─────────────────────────────┐
│  Allenamento  —  19 giu     │
│                             │
│  [+ Aggiungi esercizio]     │
├─────────────────────────────┤
│  Squat con bilanciere        │
│  3 × 80 kg                  │
│  ≈ 96 kcal                  │
├─────────────────────────────┤
│  Corsa                       │
│  30 min  ≈ 280 kcal         │
├─────────────────────────────┤
│  Totale: ≈ 376 kcal         │
└─────────────────────────────┘
```

### Catalogo esercizi (bottom sheet)

```
┌─────────────────────────────┐
│  [🔍 Cerca esercizio...]    │
│                             │
│  Petto · Dorso · Gambe      │
│  Braccia · Spalle · Core    │
│  Cardio · Il mio (+)        │
├─────────────────────────────┤
│  Panca piana                 │
│  Petto · Bilanciere         │
│                  [+Aggiungi] │
├─────────────────────────────┤
│  Squat                       │
│  Gambe · Bilanciere         │
│                  [+Aggiungi] │
└─────────────────────────────┘
```

### Dialog log — Forza

```
┌─────────────────────────────┐
│  Squat con bilanciere        │
│                             │
│  Serie 1  [8] rip  [80] kg  │
│  Serie 2  [8] rip  [80] kg  │
│  [+ Aggiungi serie]         │
│                             │
│       [Annulla]  [Salva]    │
└─────────────────────────────┘
```

### Dialog log — Cardio

```
┌─────────────────────────────┐
│  Corsa                       │
│                             │
│  Durata   [30] min          │
│  Stima:   ≈ 280 kcal        │
│                             │
│       [Annulla]  [Salva]    │
└─────────────────────────────┘
```

---

## Posizione nell'app

**Decisione: 5° tab dedicato**

```
Home | Diario | Allenamento | Progressi | TDEE
```

La feature è ben visibile e separata dal diario alimentare.

---

## Schede di allenamento (routine)

L'utente può censire schede di allenamento riutilizzabili (es. "Push Day", "Full Body A"),
ciascuna con una lista ordinata di esercizi e parametri target (serie/rip/peso o durata).
Avviare un allenamento da una scheda pre-compila il log del giorno, suggerendo i carichi
dell'ultima sessione per quell'esercizio (vedi sezione successiva).

Una scheda (`WorkoutTemplate`) rappresenta **una singola sessione** (es. "Push Day").
Quando un programma alterna più sessioni diverse (es. Upper/Lower, PPL), le sessioni sono
raggruppate in un `WorkoutProgram` — vedi sezione "Programmi multi-giorno" più sotto.

### Modello dati ✅ implementato

```dart
@collection
class WorkoutTemplate {
  Id id = Isar.autoIncrement;
  late String name;                 // es. "Push Day", o "Upper 1" se è un giorno di un programma
  late DateTime createdAt;
  DateTime? lastUsedAt;
  bool isPreset = false;             // true per le schede precaricate dall'app (read-only)

  int? programId;                    // WorkoutProgram.id, null se la scheda è autonoma
  int order = 0;                     // posizione nella rotazione/visualizzazione del programma

  List<WorkoutTemplateExercise> exercises = [];  // embedded, ordine = posizione in lista
}

@embedded
class WorkoutTemplateExercise {
  String exerciseId = '';           // ExerciseDefinition.externalId
  String exerciseName = '';         // snapshot
  int? targetSets;
  int? targetReps;
  double? targetWeightKg;
  int? targetDurationSeconds;       // per cardio
  int? supersetGroupId;             // raggruppa esercizi eseguiti senza riposo tra loro
  int? restSeconds;                 // riposo target dopo l'ultima serie/il completamento
}
```

> **Correzione rispetto al piano originale**: niente `IsarLinks`/`@Backlink`. Stessa
> logica già applicata in Fase 4 (`WorkoutExercise.sets`): `WorkoutTemplateExercise` è
> `@embedded` (Isar non permette `IsarLinks` su tipi embedded), quindi `exercises` è una
> `List` semplice che preserva l'ordine di inserimento — il campo `order` separato non
> serve più. Il legame con il programma è una FK denormalizzata (`programId`, come
> `WorkoutExercise.date` per il log), non un `IsarLink`: più semplice da interrogare
> (`filter().programIdEqualTo(x)`) e coerente col resto dell'app, che non usa IsarLinks
> da nessuna parte.

### Programmi multi-giorno (`WorkoutProgram`) ✅ implementato

```dart
@collection
class WorkoutProgram {
  Id id = Isar.autoIncrement;
  late String name;                 // es. "Upper/Lower", "Push Pull Legs"
  late DateTime createdAt;
  bool isPreset = false;
}
```

`WorkoutTemplate` resta `@collection` (non embeddable in `WorkoutProgram`): serve poter
interrogare/elencare/aggiornare (`lastUsedAt`) ogni giorno individualmente, sia che
appartenga a un programma sia che sia una scheda autonoma — stessa collection per
entrambi i casi, distinti solo da `programId` null o non null.

### Rotazione: "qual è il prossimo giorno?" ✅ implementato

Si determina il prossimo giorno da proporre scegliendo quello con `lastUsedAt` meno
recente (o mai eseguito), così la rotazione si auto-corregge anche se l'utente salta o
ripete un giorno fuori sequenza:

```dart
Future<WorkoutTemplate?> getNextDayForProgram(int programId) async {
  final days = await getProgramDays(programId); // filter().programIdEqualTo(programId)
  if (days.isEmpty) return null;
  days.sort((a, b) {
    if (a.lastUsedAt == null && b.lastUsedAt == null) return a.order.compareTo(b.order);
    if (a.lastUsedAt == null) return -1;
    if (b.lastUsedAt == null) return 1;
    return a.lastUsedAt!.compareTo(b.lastUsedAt!);
  });
  return days.first;
}
```

L'utente può sempre ignorare il suggerimento e scegliere manualmente un altro giorno del
programma (es. vuole rifare "Upper" anche se toccherebbe "Lower").

### Flusso "Inizia allenamento da scheda"

1. L'utente seleziona una scheda (o un programma, vedi sotto) dalla lista "Le mie schede"
2. Se è un programma, l'app propone il giorno suggerito da `getNextDay()`, modificabile
3. Per ogni `WorkoutTemplateExercise` del giorno scelto, l'app crea un `WorkoutExercise`
   nel `WorkoutLog` di oggi
4. I valori vengono pre-compilati con l'**ultima performance registrata** per quell'esercizio
   (non con il target statico della scheda), per riflettere il progresso reale — vedi
   l'algoritmo di suggerimento nella sezione "Storico progressi"
5. Se non esiste ancora uno storico per l'esercizio, si usano i target salvati nella scheda
6. A fine sessione si aggiorna `lastUsedAt` sul `WorkoutTemplate` (giorno) eseguito, così la
   rotazione del programma avanza

### UI

```
┌─────────────────────────────┐
│  Le mie schede                │
│  [+ Nuova scheda] [+ Programma]│
├─────────────────────────────┤
│  📋 Upper/Lower (programma)   │
│  Prossimo: Lower 2     ▶ Inizia│
│  4 giorni · ultimo 18 giu      │
├─────────────────────────────┤
│  Push Day                     │
│                        ▶ Inizia│
│  4 esercizi · ultimo 15 giu   │
└─────────────────────────────┘
```

Espandendo "Upper/Lower" si vedono i 4 giorni interni, con quello suggerito evidenziato e
gli altri selezionabili manualmente:

```
┌─────────────────────────────┐
│  Upper/Lower                 │
├─────────────────────────────┤
│  Upper 1         ultimo 12 giu│
│  Lower 1         ultimo 14 giu│
│  Upper 2         ultimo 16 giu│
│▶ Lower 2  (suggerito) ▶ Inizia│
└─────────────────────────────┘
```

```
┌─────────────────────────────┐
│  Nuova scheda                │
│  Nome: [Push Day_______]     │
├─────────────────────────────┤
│  1. Panca piana    4×8  80kg│
│  2. Military press  3×10 40kg│
│  [+ Aggiungi esercizio]       │
│                               │
│         [Annulla]   [Salva]   │
└─────────────────────────────┘
```

---

## Modalità esecuzione guidata (sessione attiva)

Sì: una scheda è eseguibile passo per passo. Quando l'utente la avvia, l'app entra in una
modalità a schermo singolo che guida l'esecuzione esercizio per esercizio, invece della
sola vista a lista piatta:

1. Si parte dal primo esercizio della scheda (rispettando l'ordine e i gruppi superset)
2. Per ogni serie target, l'utente inserisce rip/peso — pre-compilati col **suggerimento
   progressive overload** (vedi sezione successiva) — e conferma
3. Dopo l'ultima serie di un esercizio (o dell'ultimo esercizio del superset), parte
   automaticamente il **timer di recupero**
4. Al termine del riposo, l'app passa all'esercizio successivo; l'utente può anche navigare
   avanti/indietro manualmente (swipe o freccia), senza essere bloccato nell'ordine
5. Indicatore di avanzamento ("Esercizio 2 di 4")
6. A fine scheda, riepilogo della sessione (kcal stimate, eventuali PR raggiunti)

```
┌─────────────────────────────┐
│  Push Day  ·  Esercizio 2/4  │
│                              │
│  Panca piana                 │
│  Suggerito: 4×8×82.5kg  📈   │
│                              │
│  Serie 1  [8] rip [82.5] kg ✓│
│  Serie 2  [_] rip  [___] kg  │
│                              │
│  [< Precedente]  [Successivo >]│
└─────────────────────────────┘
```

Questa modalità è opzionale: resta disponibile anche la vista classica "lista del giorno"
(già descritta in "UI — schermate principali") per chi preferisce loggare in modo più
libero, ad esempio un allenamento non da scheda o la modifica di un log passato.

### Ripresa di una sessione interrotta — fuori scope

Se l'utente chiude l'app a metà di una sessione guidata, **non viene gestita** una ripresa
esatta (stesso esercizio, stesso timer). Nessuna perdita di dati però: ogni serie è
persistita su `WorkoutExercise`/`WorkoutSet` non appena confermata, quindi alla riapertura
l'utente vede già loggato ciò che aveva fatto nella vista "lista del giorno" e può
rientrare in modalità guidata dall'esercizio che preferisce (riparte semplicemente dal
primo della lista, non necessariamente da dove si era fermato).

---

## Schede preimpostate (preset)

Per dare un punto di partenza a chi non sa come strutturare l'allenamento, l'app include
**10 schede preimpostate**, seedate una sola volta (come il catalogo esercizi) e marcate
`isPreset = true` — non modificabili direttamente, ma duplicabili come scheda personale
editabile.

> Nomi e schemi sono generici (split/serie/ripetizioni), non riprendono programmi
> commerciali brandizzati né le loro prescrizioni esatte (es. niente percentuali stile
> "5/3/1" o branding "StrongLifts").

8 dei 10 preset alternano giorni diversi e vengono quindi seedati come `WorkoutProgram`
(con i relativi `WorkoutTemplate` figli, incluso Cardio Misto: 3 giorni con attività
diverse); i restanti 2 (Calisthenics Full Body, Circuito Cardio/HIIT) ripetono lo stesso allenamento ogni
volta e restano `WorkoutTemplate` singole.

### Forza / Palestra

#### 1. Full Body Principianti — 3 gg/sett (A-B-A) · **Programma, 2 giorni**

| Giorno A | Serie×Rip | Giorno B | Serie×Rip |
|---|---|---|---|
| Squat con bilanciere | 3×8 | Stacco da terra (o rumeno) | 3×8 |
| Panca piana | 3×8 | Military press | 3×8 |
| Rematore con bilanciere | 3×8 | Lat machine (o trazioni) | 3×8 |
| Plank | 3×30s | Crunch | 3×15 |

Settimane successive alternano A-B-A / B-A-B.

#### 2. Full Body 5×5 — 3 gg/sett (A/B alternati) · **Programma, 2 giorni**

| Giorno A | Serie×Rip | Giorno B | Serie×Rip |
|---|---|---|---|
| Squat con bilanciere | 5×5 | Squat con bilanciere | 5×5 |
| Panca piana | 5×5 | Military press | 5×5 |
| Rematore con bilanciere | 5×5 | Stacco da terra | 1×5 |

Volume più basso sullo stacco (1 serie), come da prassi comune per questo schema.

#### 3. Upper/Lower — 4 gg/sett (generico) · **Programma, 4 giorni**

| Giorno | Esercizi | Serie×Rip |
|---|---|---|
| Upper 1 | Panca piana, Rematore bilanciere, Military press, Curl bicipiti | 3×10, 3×10, 3×10, 3×12 |
| Lower 1 | Squat, Leg press, Leg curl, Polpacci | 3×10, 3×10, 3×12, 3×15 |
| Upper 2 | Panca inclinata manubri, Lat machine, Alzate laterali, Push down tricipiti | 3×10, 3×10, 3×12, 3×12 |
| Lower 2 | Stacco rumeno, Affondi, Hip thrust, Plank | 3×10, 3×10, 3×12, 3×40s |

#### 4. Power + Ipertrofia — 4 gg/sett (split forza/ipertrofia) · **Programma, 4 giorni**

| Giorno | Esercizi | Serie×Rip |
|---|---|---|
| Upper Power | Panca piana, Rematore bilanciere, Military press, Curl bicipiti | 4×6, 4×6, 3×8, 3×8 |
| Lower Power | Squat, Stacco rumeno, Leg press, Polpacci | 4×6, 3×8, 3×8, 3×10 |
| Upper Ipertrofia | Panca inclinata manubri, Lat machine, Alzate laterali, Push down tricipiti | 3×10-12, 3×10-12, 3×12-15, 3×12-15 |
| Lower Ipertrofia | Affondi, Leg curl, Hip thrust, Plank | 3×10-12, 3×12-15, 3×12-15, 3×45s |

2 giorni a basso volume/alto carico + 2 giorni ad alto volume/carico moderato.

#### 5. Push/Pull/Legs — 3 gg/sett · **Programma, 3 giorni**

| Giorno | Esercizi | Serie×Rip |
|---|---|---|
| Push | Panca piana, Military press, Dip alle parallele, Alzate laterali, Push down tricipiti | 4×8, 3×10, 3×10, 3×12, 3×12 |
| Pull | Stacco da terra, Lat machine (o trazioni), Rematore bilanciere, Curl bicipiti, Face pull | 4×6, 4×8, 3×10, 3×12, 3×15 |
| Legs | Squat, Leg press, Leg curl, Affondi, Polpacci in piedi | 4×8, 3×10, 3×12, 3×10, 4×15 |

#### 6. Push/Pull/Legs — 6 gg/sett (doppio giro) · **Programma, 6 giorni**

Stessa struttura del PPL 3gg ripetuta due volte a settimana, con varianti tra il primo
e il secondo giro per evitare monotonia ed equilibrare forza/ipertrofia:

| Giorno | Esercizi | Serie×Rip |
|---|---|---|
| Push (forza) | Panca piana, Military press, Dip alle parallele | 4×6, 3×8, 3×10 |
| Pull (forza) | Stacco da terra, Rematore bilanciere, Lat machine | 4×6, 4×8, 3×10 |
| Legs (forza) | Squat, Leg press, Leg curl | 4×6, 3×10, 3×12 |
| Push (ipertrofia) | Panca inclinata manubri, Alzate laterali, Push down tricipiti | 3×10, 3×12, 3×12 |
| Pull (ipertrofia) | Lat machine, Curl bicipiti, Face pull | 3×10, 3×12, 3×15 |
| Legs (ipertrofia) | Affondi, Leg curl, Polpacci | 3×12, 3×12, 4×15 |

#### 7. Bro Split — 5 gg/sett (un gruppo al giorno) · **Programma, 5 giorni**

| Giorno | Esercizi | Serie×Rip |
|---|---|---|
| Petto | Panca piana, Panca inclinata manubri, Croci ai cavi, Dip alle parallele | 4×8, 3×10, 3×12, 3×10 |
| Dorso | Stacco da terra, Lat machine, Rematore bilanciere, Pulley basso | 4×6, 4×10, 3×10, 3×12 |
| Gambe | Squat, Leg press, Leg curl, Polpacci | 4×8, 3×10, 3×12, 4×15 |
| Spalle | Military press, Alzate laterali, Alzate posteriori, Shrug | 4×8, 3×12, 3×12, 3×15 |
| Braccia | Curl bicipiti, Push down tricipiti, Curl a martello, French press | 3×10, 3×10, 3×12, 3×12 |

### Corpo libero (no attrezzi)

#### 8. Calisthenics Full Body — 3 gg/sett · **Scheda singola**

| Esercizio | Serie×Rip |
|---|---|
| Piegamenti (push-up) | 3×12 |
| Squat a corpo libero | 3×15 |
| Trazioni alla sbarra | 3×8 |
| Plank | 3×40s |
| Affondi a corpo libero | 3×12 per gamba |
| Hip thrust a corpo libero | 3×15 |

#### 9. Circuito Cardio/HIIT — 3 gg/sett · **Scheda singola**

Circuito a tempo, 4 round, 20s di recupero tra esercizi e 2 min tra round:

| Esercizio | Durata |
|---|---|
| Jumping jack | 40s |
| Squat a corpo libero | 40s |
| Mountain climber | 40s |
| Plank | 40s |
| Burpees | 40s |

### Cardio

#### 10. Cardio Misto — 2-3 gg/sett · **Programma, 3 giorni**

| Giorno | Attività | Durata |
|---|---|---|
| 1 | Corsa (ritmo moderato) | 30 min |
| 2 | Bici (ritmo costante) | 40 min |
| 3 | Camminata veloce o nuoto | 30-45 min |

### Seed e mapping al catalogo

Come per gli esercizi, i preset vengono dichiarati in un asset JSON e seedati una sola
volta al primo avvio (idempotente, controllo su `isPreset` esistente):

```
assets/
  data/
    workout_presets.json   ← 8 programmi (multi-giorno) + 2 schede singole,
                              esercizi referenziati per externalId
```

Ogni voce del JSON referenzia l'`externalId` di `free-exercise-db` (lo stesso usato da
`ExerciseDefinition`); va quindi fatta una mappatura manuale una tantum tra i nomi generici
sopra e gli id reali del dataset (es. "Squat con bilanciere" → `Barbell_Squat`), così come
già previsto per `exercises_it.json`. Le voci cardio/circuito usano `targetDurationSeconds`
invece di `targetSets`/`targetReps`. Per gli 8 programmi, il seed crea un `WorkoutProgram`
con `isPreset = true` e i suoi `WorkoutTemplate` figli con `order` crescente.

### Flusso di utilizzo

1. La schermata "Le mie schede" mostra due sezioni: **Preimpostate** (i 10, badge "Preset",
   filtrabili per categoria Forza/Corpo libero/Cardio — gli 8 programmi espandibili nei
   relativi giorni) e **Le mie schede** (custom dell'utente)
2. Da una preset l'utente può: **Inizia** (usarla/il giorno suggerito direttamente) o
   **Duplica e personalizza** → crea una copia editabile con `isPreset = false` (un
   `WorkoutProgram` duplicato copia anche tutti i `WorkoutTemplate` figli)
3. Le preset non sono mai modificabili/eliminabili in-place, per restare un riferimento stabile

---

## Storico progressi e progressive overload

Per ogni esercizio del catalogo (o custom), l'utente deve poter consultare l'andamento
nel tempo di carico e ripetizioni, per verificare il progressive overload — inteso in
senso ampio: più ripetizioni a parità di carico, oppure più carico a parità di ripetizioni.

### Query storico

Grazie all'indice su `WorkoutExercise.exerciseId` e al campo `date` denormalizzato, lo
storico di un esercizio si ottiene con una query diretta, senza join su `WorkoutLog`:

```dart
Future<List<WorkoutExercise>> getHistoryForExercise(String exerciseId) {
  return isar.workoutExercises
    .filter()
    .exerciseIdEqualTo(exerciseId)
    .sortByDateDesc()
    .findAll();
}
```

### Metriche derivate (calcolate a runtime, non persistite) ✅ implementate

- **Volume per sessione**: `Σ (serie.reps × serie.weightKg)`, escluse le serie `isWarmup`
- **Carico massimo per sessione**: `max(serie.weightKg)`, escluse le serie `isWarmup`
- **Stima 1RM (formula di Epley)**: `peso × (1 + rip / 30)`, sulla serie migliore
- **Record personale (PR)**: peso massimo mai sollevato per quell'esercizio (confrontato
  solo con le sessioni precedenti a quella in esame, non con l'intero storico incluso il
  futuro) — evidenziato con badge "🏆 Nuovo record" quando una sessione lo supera

### Suggerimento progressive overload ✅ implementato

All'avvio di un esercizio (da scheda o da catalogo) si recupera l'ultima sessione
registrata e si propone un incremento, **senza applicarlo automaticamente**:

```
Ultima volta: 3 × 8 × 80 kg
Suggerimento: 3 × 8 × 82.5 kg   (oppure)   3 × 9 × 80 kg
```

Il suggerimento va anche **a scendere**, non solo in incremento, in base a quanto l'utente
si è avvicinato o no al target nella sessione precedente:

| Esito ultima sessione | Suggerimento prossima volta |
|---|---|
| Tutte le serie completate al target (RPE basso, se inserito) | ⬆️ +2.5 kg sul peso, stessi rip |
| Target raggiunto ma con fatica (RPE alto, se inserito) | ➡️ stesso peso e rip (consolidare) |
| Una serie sotto il target di ripetizioni | ➡️ stesso peso, riprova le stesse rip |
| Più serie sotto il target, o fallimento marcato | ⬇️ -5/-10% sul peso, stessi rip target |

L'utente conferma il suggerimento (⬆️/➡️/⬇️) con un tap o inserisce valori propri: non viene
mai applicato automaticamente senza una sua azione.

> **Nota implementativa**: la "prima serie" dell'ultima sessione è usata come riferimento
> del target (baseline reps), dato che i preset prescrivono rip uniformi tra le serie
> (es. "3×8"). Il suggerimento pre-compila solo la **prima** serie del nuovo log; le serie
> successive restano da inserire manualmente (l'utente le copia o le modifica).

### Settimana di scarico (deload) suggerita ✅ implementata

Estensione dell'algoritmo di suggerimento: se per un esercizio si rilevano **N settimane
consecutive** (default 4, configurabile) di sessioni con carico in aumento o stabile senza
mai una riduzione, l'app propone una settimana di scarico prima di continuare a progredire.

```dart
bool needsDeload(List<WorkoutExercise> history, {int weeks = 4}) {
  final recent = groupByWeek(history).take(weeks);
  return recent.length == weeks &&
      recent.every((week) => week.maxWeight >= previousWeek.maxWeight);
}
```

Se rilevato, il suggerimento successivo per quell'esercizio diventa una riduzione (es. -40%
su carico o volume) invece del consueto incremento, con un banner informativo:

```
┌─────────────────────────────┐
│ 💡 Stai progredendo da 4     │
│ settimane su questo esercizio│
│ Valuta una settimana più     │
│ leggera (scarico)            │
│         [Ignora] [Applica]   │
└─────────────────────────────┘
```

Anche qui nessuna applicazione automatica: è solo un suggerimento, calcolato a runtime
sullo storico esistente (nessun nuovo campo persistito).

### UI — Storico esercizio ✅ implementata (`StoricoEsercizioScreen`)

```
┌─────────────────────────────┐
│  Storico — Panca piana       │
│                              │
│  📈 [grafico carico/tempo]  │
│                              │
│  19 giu  4×8×82.5kg  🏆PR   │
│  15 giu  4×8×80kg            │
│  10 giu  3×8×80kg            │
│  05 giu  3×8×77.5kg           │
└─────────────────────────────┘
```

Accessibile tappando il nome dell'esercizio nella card di `AllenamentoScreen`.
**Non ancora** accessibile dal catalogo esercizi né da una voce dedicata in Progressi —
questi due entry point aggiuntivi sono deferiti, non bloccanti per l'uso della feature
(la Bacheca record personali di Fase 17 è il punto naturale per l'integrazione in Progressi).

### Libreria grafico — ✅ riusato `fl_chart` (già dipendenza del progetto)

Verificare se `fl_chart` è già una dipendenza del progetto (usata altrove in
Progressi/TDEE) e riusarla per coerenza visiva; altrimenti introdurla come nuova
dipendenza solo per questa sezione.

---

## Bacheca record personali (PR aggregati)

Estensione naturale del PR già calcolato nello storico per singolo esercizio: una vista
"I tuoi record" che li raccoglie tutti, invece di doverli scoprire esercizio per esercizio.

### Query

Per ogni `exerciseId` distinto mai loggato (serie non di riscaldamento), si prende il
peso massimo storico — stesso filtro/ordinamento già usato per `getHistoryForExercise`,
applicato a tutti gli esercizi invece che a uno solo:

```dart
Future<List<PersonalRecord>> getAllPersonalRecords() async {
  final exerciseIds = await isar.workoutExercises
      .where()
      .distinctByExerciseId()
      .findAll();

  return [
    for (final ex in exerciseIds)
      PersonalRecord(
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        maxWeightKg: await getMaxWeightForExercise(ex.exerciseId), // esclude isWarmup
        achievedAt: await getMaxWeightDateForExercise(ex.exerciseId),
      ),
  ];
}
```

`PersonalRecord` è un oggetto in memoria (non persistito), calcolato a runtime come le
altre metriche derivate.

### UI

```
┌─────────────────────────────┐
│  I tuoi record               │
│  Filtra: Tutti · Petto · ... │
├─────────────────────────────┤
│  🏆 Panca piana    82.5 kg   │
│     19 giu 2026               │
├─────────────────────────────┤
│  🏆 Squat           100 kg   │
│     15 giu 2026               │
└─────────────────────────────┘
```

Accessibile da una nuova voce in Progressi, vicino al grafico storico per esercizio.

---

## Volume settimanale per gruppo muscolare

Grafico che mostra il volume totale (Σ rip × peso, escluse le serie di riscaldamento)
della settimana corrente per ciascun gruppo muscolare — utile per capire se un programma
(es. Bro Split) sta trascurando un gruppo.

### Query

Aggrega `WorkoutExercise` (e i relativi `WorkoutSet` non-warmup) della settimana per
`ExerciseDefinition.muscleGroup`:

```dart
Future<Map<String, double>> getWeeklyVolumeByMuscleGroup(DateTime weekStart) async {
  final exercises = await isar.workoutExercises
      .filter()
      .dateGreaterThan(weekStart)
      .findAll();

  final volumeByGroup = <String, double>{};
  for (final ex in exercises) {
    final group = await getMuscleGroupFor(ex.exerciseId);
    final volume = ex.sets
        .where((s) => !s.isWarmup)
        .fold(0.0, (sum, s) => sum + (s.reps ?? 0) * (s.weightKg ?? 0));
    volumeByGroup[group] = (volumeByGroup[group] ?? 0) + volume;
  }
  return volumeByGroup;
}
```

### UI

```
┌─────────────────────────────┐
│  Volume settimanale          │
│  Petto    ▓▓▓▓▓▓░░  1200 kg  │
│  Dorso    ▓▓▓▓▓▓▓▓  1800 kg  │
│  Gambe    ▓▓▓░░░░░   600 kg  │
│  Spalle   ▓▓▓▓░░░░   900 kg  │
│  Braccia  ▓▓░░░░░░   400 kg  │
│  Core     ░░░░░░░░     0 kg  │
│                              │
│  ⚠️ Core trascurato questa   │
│     settimana                │
└─────────────────────────────┘
```

Banner di avviso opzionale se un gruppo ha volume nullo o molto sotto la media degli
altri — utile soprattutto con programmi a split (Bro Split, PPL). Accessibile da Progressi,
vicino al grafico storico per esercizio e alla bacheca record.

---

## Riscaldamento (warm-up set suggeriti)

Prima delle serie "di lavoro" di un esercizio di forza, l'app suggerisce 1-2 serie di
riscaldamento a carico progressivamente crescente, calcolate sul carico target (target
della scheda o suggerimento overload). Sotto una soglia configurabile il riscaldamento
non viene proposto (poco utile con carichi leggeri o corpo libero):

```dart
List<WorkoutSet> suggestWarmupSets(double targetWeightKg, {double thresholdKg = 40}) {
  if (targetWeightKg < thresholdKg) return [];
  return [
    WorkoutSet(reps: 8, weightKg: roundToNearest2_5(targetWeightKg * 0.5), isWarmup: true),
    WorkoutSet(reps: 5, weightKg: roundToNearest2_5(targetWeightKg * 0.7), isWarmup: true),
  ];
}
```

Le serie di riscaldamento sono salvate (campo `WorkoutSet.isWarmup`) ma **escluse** dal
calcolo di volume, PR, 1RM e dal suggerimento di progressive overload — contano solo le
serie di lavoro.

### UI — modalità guidata

```
┌─────────────────────────────┐
│  Panca piana — Riscaldamento │
│                              │
│  Riscaldamento 1  8 rip 40kg │
│  Riscaldamento 2  5 rip 56kg │
│  [Salta riscaldamento]        │
│                              │
│            [Avanti]          │
└─────────────────────────────┘
```

Mostrato come step preliminare prima delle serie principali nella modalità esecuzione
guidata; saltabile con un tap. Non disponibile per esercizi cardio o di stretching.

---

## Obiettivo settimanale di allenamenti

Diverso dalla streak (continuità giorno per giorno): qui l'utente fissa un traguardo
settimanale flessibile (es. "3 allenamenti questa settimana"), più indulgente se salta un
giorno — basta recuperare entro la settimana.

### Modello

Non serve una collection Isar dedicata: il target si salva come preferenza utente
(stesso pattern di `target_service.dart` già usato per gli obiettivi giornalieri di
calorie/macro), il conteggio si deriva a runtime dai `WorkoutLog` della settimana corrente:

```dart
Future<int> getWorkoutsThisWeek() {
  final start = startOfWeek(DateTime.now());  // locale-aware, stessa utility dell'i18n Fase 9
  return isar.workoutLogs.filter().dateGreaterThan(start).distinctByDate().count();
}
```

### Relazione con i programmi multi-giorno

L'obiettivo è volutamente **disaccoppiato** da un singolo `WorkoutProgram`: conta tutte le
sessioni registrate nella settimana, indipendentemente dalla scheda/giorno usato — utile
per chi alterna programmi o si allena anche fuori scheda. Per chi segue un programma, il
target di default proposto in fase di setup è il numero di giorni del programma attivo
(es. 4 per Upper/Lower), ma resta modificabile liberamente.

### UI

```
┌─────────────────────────────┐
│  Allenamento                 │
│  🎯 Questa settimana: 2/3    │
│  ▓▓▓▓▓▓▓░░░░                 │
├─────────────────────────────┤
│  ...lista esercizi...        │
└─────────────────────────────┘
```

Impostabile/disattivabile dalle impostazioni della sezione Allenamento; se disattivato non
mostra alcun indicatore (nessun obbligo di usarlo).

---

## Timer di recupero tra le serie

Dopo aver loggato una serie (o un esercizio in un superset), l'app mostra un countdown
basato su `restSeconds` (impostato nella scheda o di default), con avviso sonoro/vibrazione
al termine. Funzionalità puramente UI, nessuna nuova collection Isar oltre ai campi
`restSeconds` già aggiunti a `WorkoutTemplateExercise`/`WorkoutExercise`.

```
┌─────────────────────────────┐
│  Riposo                      │
│        01:23                 │
│   [-15s]  [Salta]  [+15s]    │
└─────────────────────────────┘
```

- Default riposo configurabile nelle impostazioni (es. 90s strength, 30s circuito)
- Il timer continua a girare in background per la durata della sessione (overlay/notifica
  locale se l'utente cambia schermata, analogo a un timer di cottura)
- A fine countdown: vibrazione + suono breve, dismissibile con un tap

---

## RPE (sforzo percepito) per serie

Accanto a ripetizioni e peso, l'utente può opzionalmente indicare l'RPE (Rate of Perceived
Exertion, scala 1-10) di ogni serie — più informativo del solo carico per capire se il
progressive overload è sostenibile o l'utente è già al limite.

```
┌─────────────────────────────┐
│  Squat con bilanciere        │
│                              │
│  Serie 1  [8] rip [80] kg    │
│  RPE: 😌 1 2 3 4 5 6 7 8 9 🥵10│
│                              │
│       [Annulla]  [Salva]     │
└─────────────────────────────┘
```

Nello storico esercizio, l'RPE medio di sessione affianca volume/carico massimo: un
carico stabile con RPE in calo è un segnale di progresso più affidabile del solo peso.
Campo opzionale: chi non vuole usarlo lo ignora senza impatti sul resto del flusso.

---

## Note per sessione

Riuso del pattern già presente in `body_snapshot` (pesate) e nel diario alimentare: un
campo `note` libero su `WorkoutLog` (già aggiunto al modello), editabile dalla schermata
Allenamento del giorno.

```
┌─────────────────────────────┐
│  Allenamento — 19 giu        │
│  📝 "Ginocchio doloreva su   │
│      squat, ridotto carico"  │
├─────────────────────────────┤
│  ...esercizi...              │
└─────────────────────────────┘
```

Nessun nuovo servizio: stesso `TextField` già usato altrove nell'app, stesso pattern di
salvataggio.

---

## Reminder allenamento

Riuso di `notification_service` (già usato per gli altri reminder dell'app) per notificare
l'utente se non registra un `WorkoutLog` da N giorni (default configurabile, es. 3).

- Nuova voce in `notifiche_screen.dart`: "Promemoria allenamento" con toggle on/off e
  selettore giorni di inattività
- Check eseguito al lancio dell'app o tramite lo scheduler già usato dalle altre notifiche
  (stessa infrastruttura, nessun nuovo sistema di background task)
- Testo esempio: "Non ti alleni da 3 giorni — vuoi riprendere oggi?"

---

## Streak e achievement allenamento

Riuso di `streak_service` e `achievement_service` (già usati per il diario alimentare) per
gamificare la costanza negli allenamenti, senza costruire un sistema parallelo.

- **Streak**: giorni con almeno un `WorkoutLog` registrato, stessa logica di
  `_streakFromLoggedDays` applicata alla collection allenamenti invece che al diario
- **Achievement nuovi** (estendendo `achievement.dart`):
  - "Prima scheda completata"
  - "7 allenamenti di fila"
  - "Nuovo PR su un esercizio" (si aggancia alla rilevazione PR già prevista nello storico)
  - "10 sessioni totali", "50 sessioni totali"
- Gli achievement collegati ai PR richiedono un hook nel salvataggio di `WorkoutExercise`
  che confronta con `getHistoryForExercise` e notifica l'achievement service in caso di record

---

## Superset / circuiti

Per allenamenti come il preset Circuito Cardio/HIIT, più esercizi vengono eseguiti in
sequenza senza riposo tra loro (riposo solo dopo l'ultimo del gruppo). Il campo
`supersetGroupId` (già aggiunto a `WorkoutTemplateExercise`/`WorkoutExercise`) raggruppa
gli esercizi: stesso valore = stesso blocco.

### UI — creazione scheda

```
┌─────────────────────────────┐
│  Nuova scheda                │
│  ┌─ Superset A ────────────┐│
│  │ 1. Jumping jack    40s  ││
│  │ 2. Squat           40s  ││
│  │ 3. Mountain climber 40s ││
│  └─────────────────────────┘│
│  [+ Aggiungi al superset]    │
│  [+ Nuovo esercizio singolo]  │
└─────────────────────────────┘
```

### UI — durante il log

Gli esercizi dello stesso `supersetGroupId` vengono mostrati come un blocco unico, il
timer di recupero scatta solo dopo il completamento dell'ultimo esercizio del gruppo
(invece che dopo ogni singolo esercizio).

---

## Sostituzione esercizio al volo

Durante l'esecuzione (modalità guidata o lista del giorno), l'utente può sostituire
l'esercizio corrente con un'alternativa — utile quando un attrezzo è occupato o non
disponibile. La sostituzione vale **solo per la sessione corrente**: non modifica la
scheda/programma salvato, solo il `WorkoutExercise` del giorno.

### Algoritmo di proposta alternative

L'app propone alternative filtrando per `muscleGroup` uguale, escludendo l'esercizio
stesso e quelli già presenti nella sessione, ordinate per somiglianza (stesso `mechanic`
prima, poi `equipment` diverso da quello mancante o `bodyweight` come fallback):

```dart
List<ExerciseDefinition> getAlternatives(ExerciseDefinition original, {int limit = 5}) {
  final candidates = isar.exerciseDefinitions
    .filter()
    .muscleGroupEqualTo(original.muscleGroup)
    .isDeletedEqualTo(false)
    .findAllSync()
    .where((e) => e.externalId != original.externalId)
    .toList();

  candidates.sort((a, b) {
    final mechanicScore = (b.mechanic == original.mechanic ? 1 : 0)
        - (a.mechanic == original.mechanic ? 1 : 0);
    if (mechanicScore != 0) return mechanicScore;
    return (b.equipment == original.equipment ? 1 : 0)
        - (a.equipment == original.equipment ? 1 : 0);
  });

  return candidates.take(limit).toList();
}
```

### UI

```
┌─────────────────────────────┐
│  Sostituisci: Panca piana    │
│                              │
│  Panca inclinata manubri     │
│  Petto · Manubri · Compound │
│                     [Scegli] │
├─────────────────────────────┤
│  Croci ai cavi                │
│  Petto · Cavi · Isolamento   │
│                     [Scegli] │
├─────────────────────────────┤
│  Piegamenti (push-up)        │
│  Petto · Corpo libero        │
│                     [Scegli] │
└─────────────────────────────┘
```

Se l'esercizio scelto come sostituto non ha storico proprio, si ricade sui target della
scheda (stesso comportamento già previsto per un esercizio mai eseguito prima).

---

## Modifica e cancellazione di un log passato

Accessibile dalla cronologia allenamenti (in Progressi, o da un selettore data nel tab
Allenamento): selezionando un giorno passato si entra nella stessa vista "lista del
giorno" usata per oggi, in modalità modifica.

Operazioni permesse:
- Modificare le serie (rip/peso/RPE) di un `WorkoutExercise` già salvato
- Aggiungere o rimuovere un `WorkoutExercise` dal `WorkoutLog` di quel giorno
- Eliminare l'intero `WorkoutLog` del giorno (azione distruttiva, richiede conferma)

```
┌─────────────────────────────┐
│  Allenamento — 15 giu        │
│  [<]      [Oggi]       [>]   │
├─────────────────────────────┤
│  Squat con bilanciere        │
│  3 × 80 kg           [Modifica]│
│                      [Elimina]│
├─────────────────────────────┤
│         [🗑 Elimina giornata] │
└─────────────────────────────┘
```

### Effetti collaterali

- Volume, PR, 1RM e suggerimenti di overload/deload sono **sempre calcolati a runtime**
  dallo storico aggiornato: nessuna ricalcolazione manuale, si "auto-correggono" alla
  query successiva
- **Gli achievement già sbloccati non vengono revocati**, anche se una modifica fa
  "perdere" un PR storico (es. cancellando la sessione che lo aveva generato) — comportamento
  standard per la gamification, evita di togliere qualcosa già ottenuto all'utente
- **Streak**: se si elimina il log di un giorno che faceva parte di una streak attiva, la
  streak si ricalcola alla query successiva sui giorni effettivamente loggati (stessa
  logica già usata per il diario alimentare)
- Modificare un log passato non aggiorna retroattivamente `lastUsedAt` di un
  `WorkoutTemplate`/giorno di programma: resta il valore scritto al momento dell'avvio
  originale della sessione

---

## Export PDF (scheda e storico)

Riuso di `pdf_export_service.dart`, già usato in Progressi e nel Piano alimentare — nessun
nuovo motore PDF, solo nuovi "template" di documento per questa sezione.

Due varianti:

1. **Export di una scheda/programma** — lista esercizi con target serie/rip/peso (o
   durata), leggibile e stampabile, utile da portare in palestra o condividere con un
   personal trainer
2. **Export storico di un esercizio** — tabella delle sessioni (data, serie×rip×peso, PR)
   più, se possibile riusare lo stesso renderer del grafico già usato in Progressi, il
   grafico carico/tempo

### UI

Bottone "Esporta PDF" nella schermata scheda e nella schermata "Storico esercizio", stesso
posizionamento/stile già visto in Progressi.

---

## Piano di implementazione

> **Localizzazione trasversale**: l'app è interamente localizzata (i18n completata nelle
> fasi precedenti del progetto). Ogni stringa introdotta da queste fasi — nomi preset,
> achievement, banner di suggerimento overload/deload, testo dei reminder, etichette RPE/
> superset — va nei file `.arb` esistenti, nessuna stringa hardcoded. Vale per tutte le
> fasi seguenti, non solo dove richiamato esplicitamente.
>
> **Nota sulla stima**: i giorni indicati per fase sono in stile "giorni-persona" da
> pianificazione tradizionale, non calibrati sull'assistenza AI. Le fasi a forte
> contenuto di boilerplate (modelli Isar/codegen, CRUD, query, scaffolding UI) si
> comprimono molto con l'AI; i collo di bottiglia che non si comprimono sono: traduzione
> dei ~150 nomi esercizi (Fase 2), mapping manuale dei 10 preset sugli `externalId` reali
> (Fase 6), e il test manuale su device reale (timer, vibrazione, notifiche, UX) per
> ciascuna fase.

### Fase 1 — Catalogo offline ✅ completata
- [x] Scaricare `dist/exercises.json` da `yuhonas/free-exercise-db` (873 esercizi, salvato
      come `exercise_db_raw.json` in root, sul modello di `crea_food_composition_tables.csv`)
- [x] Trasformato in `assets/data/exercises_seed.json` tramite `tool/seed_exercises.dart`
      (sul modello di `tool/seed_crea.dart`); `assets/data/` già dichiarato in `pubspec.yaml`
- [x] Creato `ExerciseDefinition` (`lib/models/exercise_definition.dart`) + codegen Isar
- [x] Implementato `seedExercises()` in `DatabaseService` (flag `AppSettings.exercisesSeeded`,
      stesso pattern di `seedCreaFoods()`/`creaSeeded`), richiamato in `main.dart`
- [x] Mapping `primaryMuscles → muscleGroup` in `tool/seed_exercises.dart` (incluso `neck →
      shoulders`, non documentato in origine ma necessario: 8 esercizi nel dataset reale)
- [x] Verificato con test temporaneo: 873 esercizi seedati, mapping corretto, idempotente

### Fase 2 — Traduzione iniziale ✅ completata
- [x] Creato `tool/exercises_it_overrides.json` con 141 esercizi comuni tradotti (curati a
      mano, non tramite API di traduzione — terminologia da palestra spesso non coincide
      con la traduzione letterale, vedi nota sotto). File in `tool/`, non in `assets/`,
      perché consumato solo a generazione (build-time), non a runtime
- [x] `tool/seed_exercises.dart` applica gli override durante la generazione di
      `exercises_seed.json` (non più un merge a runtime in `seedExercises()`): più semplice,
      un solo asset da seedare, nessuna logica di merge nel service
- [x] Verificato: 141/873 esercizi con `nameIt` popolato, fallback a `name` per gli altri

> **Nota di design**: rispetto al piano originale (file `exercises_it.json` separato,
> mergiato a runtime), si è scelto di mergere gli override **a generazione** dell'asset
> (nel tool Dart), perché `exercises_seed.json` è già una trasformazione del dataset
> originale (non il file upstream letterale) — il motivo per cui il piano originale
> separava i due file (evitare di forkare il dataset) non si applica più.
>
> **Esercizi noti per nome comune ma assenti/diversi nel dataset reale** (utile per la
> Fase 6, mapping preset): "Jumping Jack", "Burpee", "Wall Sit", "Seated Row" (generico) e
> "French Press" (nome non usato dal dataset, mappato su `EZ-Bar_Skullcrusher`) non esistono
> con questo nome esatto in `free-exercise-db` — andranno gestiti con esercizi custom o
> il più vicino equivalente reale in fase di mapping preset.

### Fase 3 — UI catalogo ✅ completata
- [x] `showCatalogoEserciziSheet()` (`lib/screens/esercizi/catalogo_esercizi_screen.dart`):
      bottom sheet con chip filtro gruppo muscolare + barra di ricerca (debounce 350ms)
- [x] Lista esercizi con nome IT (fallback EN), gruppo, equipment; badge "Il mio" per i
      personalizzati; tap su un esercizio ritorna l'`ExerciseDefinition` selezionato
      (consumato dalla Fase 4, non ancora wired a nessuna schermata "log del giorno")
- [x] `AggiungiEsercizioPersonalizzatoScreen`: form nome/gruppo/tipo/attrezzatura,
      salva con `isCustom = true` e `externalId` generato (`custom_<timestamp>`)
- [x] `DatabaseService.searchExercises()`/`addCustomExercise()` aggiunti
- [x] Nuove chiavi `.arb` (it/en) per le due schermate; `flutter gen-l10n` rieseguito
      (ha anche risolto 67 errori pre-esistenti di chiavi `.arb` non sincronizzate)
- [x] Verificato: `flutter analyze` pulito; test di servizio (`searchExercises`,
      `addCustomExercise`, filtro per gruppo) passano in modo affidabile

> **Nota tecnica**: `Isar.open()` va in deadlock se invocato dentro la zona `FakeAsync` di
> `flutter_test` (va isolato con `tester.runAsync`); le query Isar triggerate da
> interazioni utente (tap/debounce) durante `pump()` non si risolvono in modo affidabile
> nello stesso ambiente — limite noto del binding nativo, non un bug applicativo. La
> logica è verificata a livello di servizio (test diretti su `DatabaseService`); la
> verifica interattiva della UI va fatta manualmente su device/emulatore.

### Fase 4 — Log allenamento ✅ completata
- [x] Modelli Isar `WorkoutLog` (con `note`), `WorkoutExercise` (con `exerciseId`/`date`
      indicizzati, `supersetGroupId`, `restSeconds`), `WorkoutSet` (con `rpe`, `isWarmup`)
      + codegen — vedi correzioni `@embedded`/`IsarLinks` sopra
- [x] CRUD direttamente in `DatabaseService` (no `WorkoutService` dedicato: il progetto
      non ha service per-collection, tutto il CRUD vive in `DatabaseService`, stesso
      pattern di `DailyLog`/`BodySnapshot`/ecc.)
- [x] 5° tab "Allenamento" in `MainScreen` (tra Diario e Progressi) + `AllenamentoScreen`
      con lista esercizi del giorno (StreamBuilder su `watchWorkoutExercisesForDay`)
- [x] `showLogSerieDialog` (forza, serie dinamiche rip/kg) e `showLogCardioDialog`
      (durata in minuti) — RPE non incluso nel dialog: è Fase 9
- [x] **Fix collaterale**: `app_tour.dart` aveva indici di tab e calcolo larghezza
      cablati su 4 tab; inserendo il 5° a metà si rompeva lo spotlight. Shiftati gli
      indici (Progressi/TDEE ora 3/4) e il calcolo `itemW` su 5 tab totali — senza
      aggiungere un nuovo step per "Allenamento" (contenuto del tour: Fase 20/Rifinitura)
- [x] Verificato: `flutter analyze` pulito; test di servizio sul CRUD completo
      (creazione/lettura/nota/eliminazione esercizio/eliminazione intero log) passa

### Fase 5 — Stima kcal + integrazione Home ✅ completata
- [x] `CalorieEstimationService` con MET per cardio (14 esercizi reali + fallback) e MET
      fisso per la forza (corretto il coefficiente errato dell'euristica volume — vedi nota)
- [x] `DatabaseService.getWorkoutKcalForDay(date)` (somma `estimatedKcal` già persistiti)
- [x] Stima calcolata e persistita al salvataggio in `AllenamentoScreen._aggiungiEsercizio`
      (peso corporeo da `getLatestBodySnapshot()`, fallback 75kg)
- [x] kcal stimate mostrate per esercizio in `_ExerciseCard`
- [x] `_AttivitaCard` nella Home (kcal ingerite / bruciate / bilancio netto), visibile
      solo nei giorni con allenamento registrato; tap → tab Allenamento
- [x] Verificato: `flutter analyze` pulito; test su ordine di grandezza delle stime
      (squat 3×8×80kg ≈ 20-150 kcal, corsa 30min ≈ 300-600 kcal) e su aggregazione giornaliera

### Fase 6 — Schede di allenamento e programmi multi-giorno ✅ completata
- [x] Modelli Isar `WorkoutTemplate` (con `isPreset`, `programId`/`order`),
      `WorkoutTemplateExercise` (`@embedded`: niente `IsarLinks`, vedi correzione sopra),
      `WorkoutProgram` + codegen
- [x] CRUD in `DatabaseService` (no service dedicati, stessa scelta della Fase 4):
      `getStandaloneTemplates`, `getAllPrograms`, `getProgramDays`, `getNextDayForProgram`
      (rotazione su `lastUsedAt`), `save/deleteWorkoutTemplate` (con guardia ultimo giorno),
      `save/deleteWorkoutProgram`, `duplicateTemplate`/`duplicateProgram`,
      `startWorkoutFromTemplate`
- [x] `LeMieSchedeScreen`: sezioni Preimpostate / Le mie schede, programmi con giorno
      suggerito mostrato in anteprima; `ProgrammaDetailScreen` per i giorni espansi
      (suggerito evidenziato, aggiungi/elimina giorno se non preset)
- [x] `CreaSchedaScreen` (nome + esercizi con target via catalogo + `TargetEsercizioDialog`)
      per creare/modificare schede singole o giorni di un programma
- [x] Flusso "Inizia" → `startWorkoutFromTemplate` genera il log del giorno dai target
      della scheda (pre-compilazione con suggerimento overload: Fase 7/8) e aggiorna
      `lastUsedAt`
- [x] Mappati i 10 preset (8 come `WorkoutProgram`, 2 come `WorkoutTemplate` singole) sugli
      `externalId` reali del catalogo — script Python di validazione + `assets/data/workout_presets.json`
      scritto direttamente (non generato da un tool Dart: è contenuto originale curato, non
      una trasformazione di un dataset esterno come per gli esercizi)
- [x] `seedWorkoutPresets()` (idempotente, flag `AppSettings.workoutPresetsSeeded`)
- [x] Flusso "Duplica e personalizza" da preset a scheda/programma proprio
      (`duplicateTemplate`/`duplicateProgram`)
- [x] Aggiunti 2 esercizi sintetici (Jumping_Jack, Burpee) assenti dal dataset upstream,
      necessari per il preset Circuito Cardio/HIIT — vedi Considerazioni aperte
- [x] Verificato: `flutter analyze` pulito; test di servizio su CRUD, rotazione, guardia
      ultimo giorno, duplicazione, seed preset (8 programmi + 2 schede, idempotente) e
      flusso end-to-end "Inizia" → log del giorno popolato correttamente

### Fase 7 — Storico progressi e progressive overload ✅ completata
- [x] `DatabaseService.getHistoryForExercise(exerciseId)` (query indicizzata, no service
      dedicato — stessa scelta delle fasi precedenti)
- [x] `WorkoutProgressService` (puro, no DB): `sessionVolume`, `sessionMaxWeight`,
      `estimatedOneRepMax` (Epley), `isNewPersonalRecord`
- [x] `suggestNextSession()`: confronta le serie dell'ultima sessione con la prima serie
      come riferimento del target (baseline reps), copre le 4 casistiche della tabella
      (aumenta/mantieni per fatica RPE/mantieni per rip sotto target/riduci)
- [x] `needsDeload()` (4 settimane consecutive senza riduzione del carico massimo
      settimanale) + `deloadSuggestion()` (-40%, sostituisce il suggerimento normale)
- [x] `StoricoEsercizioScreen`: grafico `fl_chart` del carico massimo nel tempo (solo
      forza), lista sessioni con badge 🏆PR, vista semplificata per esercizi cardio
      (nessun grafico/PR: l'algoritmo di overload è specifico della forza). Accessibile
      tappando il nome esercizio in `AllenamentoScreen` — non ancora integrato in
      Progressi (previsto solo nella Fase 17, Bacheca record personali)
- [x] Integrazione nel dialog log serie: `AllenamentoScreen` calcola storico+suggerimento
      (o deload se rilevato) prima di apre `showLogSerieDialog`, che mostra il banner
      "Ultima volta: ..." + suggerimento (⬆️/➡️/⬇️/💡 scarico) e pre-compila la prima serie
- [x] Verificato: `flutter analyze` pulito; 11 test sulle metriche/overload/deload/PR/
      esclusione riscaldamento; test di integrazione storico→suggerimento→nuovo PR

### Fase 8 — Modalità esecuzione guidata + timer di recupero ✅ completata
- [x] Campo `restSeconds` già su `WorkoutTemplateExercise`/`WorkoutExercise` (da Fase 4/6)
- [x] Schermata sessione attiva (`SessioneGuidataScreen`): navigazione esercizio per
      esercizio (avanti/indietro liberi, non bloccati dalla conferma delle serie), gli
      step rispettano `supersetGroupId` (`GuidedSessionService.groupSteps`, esercizi
      consecutivi con lo stesso gruppo formano un solo step/superset), indicatore di
      avanzamento "Esercizio N/M" in AppBar
- [x] Pre-compilazione serie con suggerimento progressive overload (⬆️/➡️/⬇️/💡 scarico,
      da Fase 7), stessa logica `WorkoutProgressService` usata nel log manuale
- [x] `RestTimerSheet` (bottom sheet non dismissibile): countdown, vibrazione
      (`HapticFeedback.heavyImpact`) + suono di sistema (`SystemSound.play`) a fine
      riposo — nessuna nuova dipendenza, riusate le API native di Flutter — avvio
      automatico dopo ogni serie confermata (`_confirmSerie`/`_confirmCardio`)
- [x] Default riposo configurabile: `AppSettings.restTimerDefaultSeconds`, dialog
      dedicato (`RestTimerSettingsDialog`) apribile dall'icona ⏱️ in `AllenamentoScreen`
- [x] Persistenza del timer in background: `NotificationService.scheduleRestTimer`
      programma una notifica locale one-shot a fine riposo (riusa
      `flutter_local_notifications`, già usato per i promemoria pasti), cancellata se il
      riposo viene saltato/modificato o termina mentre il sheet è ancora aperto
- [x] `SessioneRiepilogoScreen` a fine sessione: kcal totali stimate
      (`GuidedSessionService.totalEstimatedKcal`) e nuovi record personali
      (`GuidedSessionService.newPersonalRecords`, esclude i cardio)
- [x] Verificato: `flutter analyze` pulito; 7 test temporanei su `GuidedSessionService`
      (raggruppamento step/superset, somma kcal, individuazione PR escludendo i cardio),
      rimossi dopo la verifica per restare coerenti con le fasi precedenti

> **Correzione rispetto al piano originale**: il timer di recupero parte dopo OGNI
> serie confermata (non solo a fine esercizio/blocco), in linea con la sezione
> "Timer di recupero tra le serie" del piano ("Dopo aver loggato una serie...").
> Il blocco superset (timer solo a fine blocco, navigazione bloccata sul gruppo) resta
> previsto per la Fase 12; qui i superset sono raggruppati solo come step visivi.
>
> **Correzione rispetto al piano originale**: `startWorkoutFromTemplate` (Fase 6)
> persiste già il `WorkoutExercise` della sessione in corso prima che la modalità
> guidata si apra, quindi `getHistoryForExercise` includerebbe la sessione corrente
> stessa nello storico usato per il suggerimento di overload. `SessioneGuidataScreen`
> esclude esplicitamente l'id della sessione corrente dallo storico recuperato
> (`_priorHistoryByExerciseId`), che viene anche passato al riepilogo per il calcolo dei
> PR (altrimenti ogni sessione risulterebbe banalmente un "nuovo record" rispetto a se
> stessa).

### Fase 9 — Note di sessione e RPE ✅ completata
- [x] Campo `note` su `WorkoutLog` (da Fase 4): icona dedicata nell'AppBar di
      `AllenamentoScreen` (`_editNota`) apre un bottom sheet con `TextField`
      multilinea, stesso pattern di `add_pesata_screen.dart`; la nota del
      giorno, se presente, è mostrata anche come banner sopra la lista
      esercizi (`DatabaseService.getWorkoutLog`/`setWorkoutNote`, già da Fase 4)
- [x] Campo `rpe` su `WorkoutSet` (da Fase 4): selettore 1-10 a chip
      orizzontali scorrevoli (`_RpeSelector`) sotto ogni riga serie nel
      dialog log serie (`log_serie_dialog.dart`)
- [x] RPE medio di sessione nella schermata Storico esercizio:
      `WorkoutProgressService.averageRpe` (nuovo metodo, esclude le serie di
      riscaldamento) mostrato come sottotitolo in `_SessionRow`
      (`storico_esercizio_screen.dart`)
- [x] Verificato: `flutter analyze` pulito (21 issue pre-esistenti, 0 nuove);
      3 test temporanei su `WorkoutProgressService.averageRpe` rimossi dopo
      la verifica per restare coerenti con le fasi precedenti

> **Correzione rispetto al piano originale**: il selettore RPE è stato aggiunto
> solo nel dialog log serie (`log_serie_dialog.dart`), come indicato dal piano,
> e non anche nella modalità esecuzione guidata (Fase 8) per mantenere lo
> scope di questa fase circoscritto a quanto descritto in checklist.

### Fase 10 — Reminder allenamento ✅ completata
- [x] Nuova voce "Promemoria allenamento" in `notifiche_screen.dart`
      (`_workoutReminderCard`, toggle `AppSettings.notWorkoutAttiva`),
      coerente con lo stile esistente della schermata (stringhe hardcoded
      in italiano, non tradotta — come il resto del file)
- [x] Check giorni di inattività riusando `notification_service`:
      `NotificationService.refreshWorkoutReminder`/`scheduleWorkoutReminder`,
      stesso pattern di `refreshWeighInReminder` (soglia 3 giorni, basata su
      `DatabaseService.getLastWorkoutDate`, nuovo metodo che legge l'ultima
      `WorkoutLog.date`); richiamato all'avvio (`main.dart`) e al resume
      dell'app, oltre che al toggle dalla UI
- [x] Testo notifica localizzato: nuove chiavi `notifChannelWorkout`,
      `notifChannelWorkoutDesc`, `notifWorkoutBody` in `app_it.arb`/`app_en.arb`
- [x] Verificato: `flutter analyze` pulito (21 issue pre-esistenti, 0 nuove);
      nessun nuovo test temporaneo (la logica di soglia giorni è analoga a
      quella già non testata di `refreshWeighInReminder`, accoppiata a Isar
      e al plugin di notifiche)

### Fase 11 — Streak e achievement allenamento ✅ completata
- [x] Streak allenamento in `streak_service.dart`: `currentWorkoutStreak`/
      `watchCurrentWorkoutStreak`, riusano la stessa `_streakFromLoggedDays`
      della streak diario ma sui "giorni allenati" (nuovi metodi
      `DatabaseService.getWorkoutDaysRange`/`watchWorkoutDays`, basati su
      `WorkoutExercise.date` e non su `WorkoutLog`, perché un `WorkoutLog` può
      esistere con sola nota e senza esercizi — vedi correzione sotto)
- [x] 5 nuovi `AchievementType` in `achievement.dart`: `firstWorkout`,
      `workoutStreak7`, `newWorkoutPr`, `workoutSessions10`,
      `workoutSessions50` (lo storage è una stringa via `.name`, quindi
      nessuna migrazione necessaria); nuovo
      `DatabaseService.getTotalWorkoutSessionsCount` (giorni distinti con
      almeno un `WorkoutExercise`) per i check "prima scheda"/"10/50 sessioni"
      in `achievement_service.dart`
- [x] Hook "nuovo PR" → `AchievementService.checkAll(hasNewWorkoutPr: ...)`
      (nuovo parametro opzionale): da `allenamento_screen.dart` dopo
      `addWorkoutExercise` (confronto con lo storico già recuperato per il
      suggerimento di sovraccarico) e da `sessione_guidata_screen.dart`
      `_termina()`, riusando `GuidedSessionService.newPersonalRecords` già
      calcolato per il riepilogo di sessione — un solo check a fine sessione
      guidata, non ad ogni serie confermata
- [x] UI: card streak in `home_screen.dart` (`_StreakCard`) estesa con una
      seconda riga "ALLENAMENTO" (icona `fitness_center`) accanto alla streak
      diario esistente; riga badge passata da `Row(spaceBetween)` a `Wrap`
      per ospitare i 9 traguardi totali senza overflow (`_BadgeIcon` da
      `Expanded` a `SizedBox(width: 60)`)
- [x] Verificato: `flutter analyze` pulito (21 issue pre-esistenti, 0 nuove);
      nessun nuovo test temporaneo — la logica nuova è interamente
      orchestrazione DB (`StreakService`/`AchievementService`), la logica pura
      riusata (`_streakFromLoggedDays`, `WorkoutProgressService.isNewPersonalRecord`)
      non è cambiata

> **Correzione rispetto al piano originale**: la streak allenamento è basata
> sui giorni con almeno un `WorkoutExercise` registrato, non sulla semplice
> esistenza di un `WorkoutLog` come indicato letteralmente dal piano —
> `WorkoutLog` può esistere anche con sola nota (Fase 9) senza alcun esercizio
> loggato, il che renderebbe la streak falsabile senza allenarsi davvero.

### Fase 12 — Superset / circuiti
- [ ] Campo `supersetGroupId` già su `WorkoutTemplateExercise`/`WorkoutExercise` (da Fase 4/6)
- [ ] UI raggruppamento esercizi in creazione scheda
- [ ] UI blocco superset durante il log + timer di recupero solo a fine blocco
- [ ] Aggiornare il preset Circuito Cardio/HIIT per usare un singolo superset

### Fase 13 — Sostituzione esercizio al volo
- [ ] Campo `mechanic` su `ExerciseDefinition` (da Fase 1, già nel JSON sorgente)
- [ ] `getAlternatives(exerciseId)` con ranking per `muscleGroup`/`mechanic`/`equipment`
- [ ] UI "Sostituisci esercizio" da modalità guidata e da lista del giorno
- [ ] Sostituzione limitata al `WorkoutExercise` della sessione (scheda salvata invariata)

### Fase 14 — Modifica e cancellazione log passato
- [ ] Cronologia/selettore data per navigare ai `WorkoutLog` passati
- [ ] UI modifica serie/esercizi e cancellazione esercizio singolo
- [ ] Cancellazione intero `WorkoutLog` con conferma
- [ ] Verifica che storico/PR/streak/achievement si ricalcolino correttamente a runtime
      dopo una modifica (nessuno stato derivato persistito da invalidare manualmente)

### Fase 15 — Riscaldamento
- [ ] Campo `isWarmup` su `WorkoutSet` (da Fase 4)
- [ ] `suggestWarmupSets(targetWeightKg)` con soglia configurabile
- [ ] Step preliminare nella modalità guidata, saltabile
- [ ] Esclusione delle serie di riscaldamento da volume/PR/1RM/overload (Fase 7)

### Fase 16 — Obiettivo settimanale di allenamenti
- [ ] Preferenza utente per il target settimanale (pattern `target_service.dart`)
- [ ] `getWorkoutsThisWeek()` (conteggio `WorkoutLog` distinti per data, settimana locale-aware)
- [ ] Default suggerito = numero giorni del programma attivo, modificabile
- [ ] Indicatore di progresso nel tab Allenamento ("2/3 questa settimana")
- [ ] Toggle per disattivarlo nelle impostazioni

### Fase 17 — Bacheca record personali
- [ ] `getAllPersonalRecords()` (PR per ogni `exerciseId` distinto, esclude `isWarmup`)
- [ ] Modello in memoria `PersonalRecord` (non persistito, calcolato a runtime)
- [ ] Schermata "I tuoi record" con filtro per gruppo muscolare, in Progressi

### Fase 18 — Volume settimanale per gruppo muscolare
- [ ] `getWeeklyVolumeByMuscleGroup(weekStart)` (aggrega `WorkoutExercise`/`WorkoutSet`
      non-warmup tramite `ExerciseDefinition.muscleGroup`)
- [ ] Grafico a barre per gruppo muscolare, in Progressi (valutare `fl_chart`, da Fase 7)
- [ ] Banner di avviso se un gruppo ha volume nullo/molto sotto la media

### Fase 19 — Export PDF scheda/storico
- [ ] Template PDF scheda/programma (riuso `pdf_export_service.dart`)
- [ ] Template PDF storico esercizio (tabella sessioni + grafico se riusabile)
- [ ] Bottone "Esporta PDF" nelle schermate scheda e storico esercizio

### Fase 20 — Rifinitura
- [ ] Cronologia allenamenti in Progressi (ultimi 7 giorni)
- [ ] Aggiornare tour guidato con il nuovo tab, le schede e le nuove feature
- [ ] Disclaimer stima kcal in UI

**Stima totale: ~30–37 giorni-persona stile tradizionale (con assistenza AI sulle fasi di
codice, l'elapsed-time reale è dominato dai compiti non comprimibili: traduzioni, mapping
preset, test manuale su device — vedi nota a inizio sezione)**

---

## Considerazioni aperte

- **Peso utente per MET** — la formula MET richiede il peso dell'utente. Se non inserito,
  usare un valore di default (75 kg) con nota in UI.
- **Conflitto seed / aggiornamento dataset** — se in futuro si aggiorna `exercises.json`,
  il seed deve fare upsert su `externalId` (non re-insert), per non perdere le personalizzazioni
  (`nameIt`, `isDeleted`).
- **Import da Apple Health / Google Fit** — fuori scope v1, ma il modello dati è compatibile:
  un `WorkoutLog` importato avrebbe `estimatedKcal` già valorizzato dalla fonte esterna.
- **Scheda che referenzia un esercizio eliminato/rinominato** — `WorkoutTemplateExercise`
  salva uno snapshot di `exerciseName`, quindi la scheda resta leggibile anche se
  l'`ExerciseDefinition` originale viene soft-deleted; va però gestito il caso "avvia
  allenamento" quando l'esercizio non è più disponibile nel catalogo attivo (mostrare
  comunque la riga, permettere di sostituirla).
- **Progressive overload con esercizi mai eseguiti prima** — se non esiste storico,
  il suggerimento ricade sui target della scheda (o resta vuoto per un esercizio dal
  catalogo, l'utente inserisce i valori manualmente la prima volta).
- **Programma con un solo giorno rimasto** — se l'utente elimina giorni da un
  `WorkoutProgram` fino a lasciarne uno solo, `getNextDay()` resta valida (ritorna sempre
  l'unico giorno) ma il programma si comporta di fatto come una scheda singola; non serve
  gestione speciale, ma va evitato di permettere l'eliminazione dell'ultimo giorno rimasto
  (altrimenti il programma resterebbe vuoto). ✅ Implementato come guardia in
  `deleteWorkoutTemplate()`: ritorna `false` senza eliminare se è l'ultimo giorno.
- **Esercizi isometrici nei preset (Plank ecc.)** — il modello non ha un campo dedicato
  per "N serie da M secondi" (solo `targetReps` per la forza o `targetDurationSeconds`
  per un singolo blocco continuo, usato per cardio/circuiti). Convenzione adottata nei
  preset: per le voci isometriche usate come accessorio in una scheda di forza (es.
  "Plank 3×30s"), `targetReps` esprime i **secondi di hold**, non le ripetizioni
  (`targetSets=3, targetReps=30`) — crea comunque 3 `WorkoutSet` reali nel log, consistente
  col resto del flusso forza. Per le voci di un circuito a tempo (es. Circuito Cardio/HIIT),
  si usa invece `targetDurationSeconds` per blocco, senza serie. Da rivedere se si vuole
  un campo dedicato (es. `targetHoldSeconds` su `WorkoutSet`) in una fase futura.
- **Due esercizi sintetici aggiunti al catalogo** — `Jumping_Jack` e `Burpee` non esistono
  nel dataset `free-exercise-db` (verificato in Fase 2) ma sono usati nel preset Circuito
  Cardio/HIIT. Aggiunti come voci extra in `tool/seed_exercises.dart` (categoria cardio),
  seedate insieme al resto del catalogo — non sono esercizi "custom" dell'utente, sono
  parte del seed standard dell'app.
