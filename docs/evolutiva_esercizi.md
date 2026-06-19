# Evolutiva — Sezione Esercizi

## Idea

Integrare il tracking dell'attività fisica in Plico, complementando il monitoraggio
nutrizionale con la spesa calorica da allenamento. L'utente può cercare esercizi da un
catalogo precompilato (importato da `free-exercise-db`), aggiungerne di propri, e
registrare serie/ripetizioni o durata giorno per giorno. Le kcal stimate dall'allenamento
compaiono nel bilancio giornaliero in Home.

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

Il seed avviene una sola volta:

```dart
Future<void> seedExercisesIfNeeded() async {
  final count = await _isar.exerciseDefinitions.count();
  if (count > 0) return;
  final json = await rootBundle.loadString('assets/data/exercises.json');
  final list = jsonDecode(json) as List;
  await _isar.writeTxn(() async {
    for (final e in list) {
      await _isar.exerciseDefinitions.put(ExerciseDefinition.fromJson(e));
    }
  });
}
```

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

### `WorkoutLog` — allenamento giornaliero (Isar)

```dart
@collection
class WorkoutLog {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime date;

  final exercises = IsarLinks<WorkoutExercise>();
}
```

### `WorkoutExercise` — esercizio eseguito (Isar)

```dart
@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  late String exerciseId;      // ExerciseDefinition.externalId
  late String exerciseName;    // snapshot del nome al momento del log

  // Per cardio
  int? durationSeconds;
  int? met;                    // valore MET usato per la stima

  // Per strength
  final sets = IsarLinks<WorkoutSet>();

  int? estimatedKcal;          // calcolato e persistito al salvataggio
}
```

### `WorkoutSet` — singola serie (Isar, embedded)

```dart
@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
}
```

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

## Stima calorie bruciate

### Cardio — formula MET

```
kcal = MET × peso_kg × durata_ore
```

Ogni esercizio cardio ha un MET predefinito (hardcodato per categoria o per singolo
esercizio):

| Esercizio | MET |
|---|---|
| Corsa 8 km/h | 8.0 |
| Ciclismo moderato | 6.0 |
| Camminata veloce | 4.5 |
| Nuoto | 7.0 |
| Salto con la corda | 10.0 |
| HIIT | 8.5 |

### Strength — euristica volume

```
kcal ≈ (serie × rip × peso_kg) × 0.0008
```

Alternativa più semplice: MET fisso 4.0 × peso_kg × durata_stimata_ora
(durata stimata = `numero_serie × 2.5 min`).

> La stima è puramente indicativa. Un disclaimer in UI chiarisce che non è un dato medico.

### Integrazione in Home

Il totale kcal allenamento appare nella card giornaliera:

```
Kcal ingerite    2.100
Attività          –420
──────────────────────
Bilancio netto   1.680
```

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

**Opzione A — 5° tab dedicato** (consigliata):

```
Home | Diario | Allenamento | Progressi | TDEE
```

Pro: la feature è ben visibile e separata dal diario alimentare.
Contro: il nav bar diventa affollato (5 tab).

**Opzione B — terzo tab in Diario**:
Il tab "Diario" diventa "Diario / Piano / Allenamento" (tre tab interni).
Pro: nav bar rimane a 4 voci.
Contro: meno discoverable.

---

## Piano di implementazione

### Fase 1 — Catalogo offline
- [ ] Scaricare `dist/exercises.json` da `yuhonas/free-exercise-db`
- [ ] Aggiungere a `assets/data/exercises.json` e dichiarare in `pubspec.yaml`
- [ ] Creare `ExerciseDefinition` con tutti i campi + codegen Isar (`build_runner`)
- [ ] Implementare `seedExercisesIfNeeded()` in `DatabaseService`
- [ ] Mapping `primaryMuscles → muscleGroup`

### Fase 2 — Traduzione iniziale
- [ ] Creare `assets/data/exercises_it.json` con ~150 esercizi comuni
- [ ] Popolare `nameIt` al seed

### Fase 3 — UI catalogo
- [ ] Bottom sheet con chip filtro gruppo muscolare + barra di ricerca
- [ ] Lista esercizi con nome IT, gruppo, equipment
- [ ] Schermata aggiunta esercizio custom

### Fase 4 — Log allenamento
- [ ] Modelli Isar `WorkoutLog`, `WorkoutExercise`, `WorkoutSet` + codegen
- [ ] `WorkoutService` con CRUD
- [ ] Tab Allenamento con lista esercizi del giorno
- [ ] Dialog log serie (forza) e dialog durata (cardio)

### Fase 5 — Stima kcal + integrazione Home
- [ ] `CalorieEstimationService` con MET per cardio + euristica strength
- [ ] `DatabaseService.getWorkoutKcalForDay(date)`
- [ ] Card "Attività" nella Home con bilancio netto

### Fase 6 — Rifinitura
- [ ] Cronologia allenamenti in Progressi (ultimi 7 giorni)
- [ ] Aggiornare tour guidato con il nuovo tab
- [ ] Disclaimer stima kcal in UI

**Stima totale: ~7–9 giorni di sviluppo**

---

## Considerazioni aperte

- **Peso utente per MET** — la formula MET richiede il peso dell'utente. Se non inserito,
  usare un valore di default (75 kg) con nota in UI.
- **Conflitto seed / aggiornamento dataset** — se in futuro si aggiorna `exercises.json`,
  il seed deve fare upsert su `externalId` (non re-insert), per non perdere le personalizzazioni
  (`nameIt`, `isDeleted`).
- **Import da Apple Health / Google Fit** — fuori scope v1, ma il modello dati è compatibile:
  un `WorkoutLog` importato avrebbe `estimatedKcal` già valorizzato dalla fonte esterna.
