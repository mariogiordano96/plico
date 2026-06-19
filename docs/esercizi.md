# Sezione Esercizi — Analisi Funzionale

> Obiettivo: integrare il tracking dell'attività fisica in Plico, complementando il
> monitoraggio nutrizionale con la spesa calorica da allenamento.

---

## 1. Scope

La sezione esercizi copre tre funzionalità core:

1. **Catalogo esercizi** — database precompilato con schede descrittive, muscoli coinvolti, istruzioni
2. **Scheda allenamento** — l'utente registra serie/ripetizioni/peso (o durata per cardio) per giorno
3. **Impatto calorico** — stima kcal bruciate integrata nel bilancio giornaliero in Home

Fuori scope per v1: routine precalcolate, progressione automatica dei carichi, integrazione HealthKit/Google Fit.

---

## 2. Fonte dati esercizi

### Opzioni valutate

| Fonte | Esercizi | Licenza | Offline | Immagini | Note |
|---|---|---|---|---|---|
| **free-exercise-db** (yuhonas) | ~800 | Public Domain | ✅ JSON bundlabile | ✅ incluse | Struttura pulita, categorie e muscoli già mappati |
| **exercises.json** (wrkout) | ~2.500 | Public Domain | ✅ JSON bundlabile | ✅ 10k+ img | Più grande ma immagini pesanti per bundle |
| **ExerciseDB API** | 11.000+ | AGPL v3 | ❌ richiede server | ✅ GIF/video | Ottimo ma troppo per un'app offline gratuita |
| **wger** | ~200 | AGPL 3+ | ❌ REST API | Limitata | Troppo pochi esercizi |

### Raccomandazione: `free-exercise-db` (yuhonas/free-exercise-db)

**Motivi:**
- Licenza Public Domain → nessun obbligo di attribution o copyleft
- JSON bundlabile offline → nessuna dipendenza da API esterne, zero costi operativi
- Struttura già pronta: `category`, `primaryMuscles`, `secondaryMuscles`, `equipment`, `level`, `instructions`
- ~800 esercizi coprono ampiamente il target (palestra + casa)

**Repository:** https://github.com/yuhonas/free-exercise-db
**File singolo compilato:** `dist/exercises.json`

### Struttura JSON (esempio)

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

### Mapping categorie → italiano

| Valore originale | Label IT | Icona |
|---|---|---|
| `chest` | Petto | 💪 |
| `back` | Dorso | 🔙 |
| `legs` | Gambe | 🦵 |
| `shoulders` | Spalle | 🏋️ |
| `arms` (biceps/triceps) | Braccia | 💪 |
| `core` / `abdominals` | Core/Addome | 🎯 |
| `cardio` | Cardio | ❤️ |

> In `free-exercise-db` la categoria è nel campo `category` (strength/cardio/stretching/plyometrics)
> e i muscoli primari distinguono dorso/petto/gambe/braccia. Il mapping muscolo→gruppo è da fare
> lato app (es. `["chest"] → Petto`, `["lats","middle back","lower back"] → Dorso`).

---

## 3. Architettura dati

### 3.1 Bundle offline

Il file `exercises.json` (~1.5 MB compresso) viene incluso in `assets/data/exercises.json`
e caricato una volta all'avvio in memoria (lista di `ExerciseDefinition`).

Non serve Isar per il catalogo: è read-only e si carica da asset. Isar è usato solo per
i log degli allenamenti.

```
assets/
  data/
    exercises.json        ← 800+ esercizi, caricato in memoria
    exercises_it.json     ← (opzionale) override nomi/istruzioni in italiano
```

### 3.2 Modelli Isar

```dart
// Log di un allenamento (giornata)
@collection
class WorkoutLog {
  Id id = Isar.autoIncrement;
  late DateTime date;
  final exercises = IsarLinks<WorkoutExercise>();
}

// Singolo esercizio eseguito
@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;
  late String exerciseId;      // referenza a ExerciseDefinition.id
  late String exerciseName;    // snapshot del nome (no join necessario)
  int? durationSeconds;        // per cardio
  final sets = IsarLinks<WorkoutSet>();
  int? estimatedKcal;
}

// Singola serie (per strength)
@embedded
class WorkoutSet {
  int? reps;
  double? weightKg;
}
```

### 3.3 Modello in memoria (non persistito)

```dart
class ExerciseDefinition {
  final String id;
  final String name;
  final String nameIt;          // traduzione
  final String category;        // strength | cardio | stretching
  final String muscleGroup;     // mapped: chest | back | legs | arms | core | shoulders
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String? equipment;
  final String level;           // beginner | intermediate | expert
  final List<String> instructions;
  final List<String> images;
}
```

---

## 4. Struttura UI

### 4.1 Nuovo tab "Allenamento"

Aggiungere un 5° tab al `BottomNavigationBar` tra Progressi e TDEE:

```
Home  |  Diario  |  Allenamento  |  Progressi  |  TDEE
 0          1           2              3             4
```

> Alternativa meno invasiva: integrare il log allenamento nella schermata Diario
> (come terzo tab accanto a Piano/Diario). Da decidere in base all'importanza data alla feature.

### 4.2 Schermata Allenamento (tab principale)

```
┌─────────────────────────────┐
│  Allenamento di oggi         │
│  [+ Aggiungi esercizio]      │
├─────────────────────────────┤
│  Squat con bilanciere        │
│  3 × 80 kg  →  3 serie      │
│  [Modifica] [Elimina]        │
├─────────────────────────────┤
│  Corsa                       │
│  30 min  ≈ 280 kcal          │
├─────────────────────────────┤
│  Totale stimato: 420 kcal   │
└─────────────────────────────┘
```

### 4.3 Catalogo esercizi (bottom sheet / schermata separata)

```
┌─────────────────────────────┐
│  [🔍 Cerca esercizio...]    │
├── Filtra per gruppo ─────── │
│  Petto · Dorso · Gambe      │
│  Braccia · Spalle · Core    │
├─────────────────────────────┤
│  Panca piana                 │
│  Petto · Bilanciere · Base  │
│                    [+Aggiungi] │
├─────────────────────────────┤
│  Squat                       │
│  Gambe · Bilanciere · Base  │
│                    [+Aggiungi] │
└─────────────────────────────┘
```

### 4.4 Dialog log serie (dopo aver scelto l'esercizio)

```
┌─────────────────────────────┐
│  Squat con bilanciere        │
│                              │
│  Serie 1: [3] rip × [80] kg │
│  [+ Aggiungi serie]          │
│                              │
│          [Annulla] [Salva]   │
└─────────────────────────────┘
```

---

## 5. Stima calorie

### Cardio

Usare la formula MET (Metabolic Equivalent of Task):

```
kcal = MET × peso_kg × durata_ore
```

Ogni esercizio cardio ha un MET predefinito nel dataset (o mappato manualmente):
- Corsa 8 km/h → MET 8.0
- Ciclismo → MET 6.0
- Camminata → MET 3.5
- Nuoto → MET 7.0

### Strength

Stima approssimativa basata su volume (serie × rip × peso):

```
kcal ≈ volume_kg × 0.0008  (euristica comune, non scientifica)
```

Oppure usare MET fisso per il sollevamento pesi (MET 3.5–6.0 a seconda dell'intensità).

> La stima è informativa, non medica. Va comunicato chiaramente in UI.

### Integrazione con Home

Il totale kcal allenamento appare nella home come "Attività":

```
Kcal ingerite   2.100
Kcal bruciate    –420  (attività)
─────────────────────
Bilancio netto  1.680
```

---

## 6. Piano di implementazione

### Fase 1 — Catalogo offline (1–2 gg)
- [ ] Scaricare `dist/exercises.json` da `yuhonas/free-exercise-db`
- [ ] Tradurre in italiano i nomi dei ~100 esercizi più comuni (manualmente o con LLM una tantum)
- [ ] Creare `ExerciseDefinition` + `ExerciseService` con caricamento da asset
- [ ] Implementare mapping `primaryMuscles → muscleGroup` (chest/back/legs/arms/core/shoulders)

### Fase 2 — UI catalogo (1–2 gg)
- [ ] Bottom sheet con lista filtrata per gruppo muscolare + ricerca testuale
- [ ] Card esercizio con nome IT, gruppo, equipment, livello
- [ ] Schermata dettaglio con istruzioni + immagine

### Fase 3 — Log allenamento (2–3 gg)
- [ ] Modelli Isar `WorkoutLog`, `WorkoutExercise`, `WorkoutSet`
- [ ] Run `build_runner` per generare codice Isar
- [ ] `WorkoutService` con CRUD operazioni
- [ ] Schermata tab Allenamento con lista esercizi del giorno
- [ ] Dialog log serie per strength / dialog durata per cardio

### Fase 4 — Stima kcal + integrazione Home (1 gg)
- [ ] `CalorieEstimationService` con MET per cardio + euristica per strength
- [ ] `DatabaseService.getWorkoutKcalForDay(date)` 
- [ ] Aggiornare Home screen per mostrare bilancio netto

### Fase 5 — Rifinitura (1 gg)
- [ ] Traduzione nomi esercizi rimanenti
- [ ] Cronologia allenamenti (lista ultimi 7 giorni in Progressi)
- [ ] Aggiornare tour guidato con il nuovo tab

**Stima totale: ~7–9 giorni di sviluppo**

---

## 7. Localizzazione esercizi

Il dataset `free-exercise-db` è in inglese. Strategia:

1. **Lista curata manuale**: tradurre i ~150 esercizi più comuni (quelli con equipment
   comune: bilanciere, manubri, corpo libero, macchine) — copertura >90% degli utenti
2. **Fallback inglese**: gli esercizi non tradotti mostrano il nome originale
3. **File separato** `exercises_it.json` con solo gli override: `{"id": "...", "nameIt": "..."}`

Questo evita di forkarsi il dataset originale e permette aggiornamenti futuri.

---

## 8. Note tecniche

- **Nessuna API esterna** → zero costi operativi, funziona offline
- **Isar** per i log è già nel progetto, aggiungere solo le nuove collection
- **Assets** con `exercises.json` da dichiarare in `pubspec.yaml` sotto `flutter.assets`
- Le immagini del dataset (~200 MB) sono **escluse** dal bundle: troppo pesanti.
  Usare solo testo + icone vettoriali per i muscoli nella v1.

---

## Riferimenti

- [free-exercise-db (yuhonas)](https://github.com/yuhonas/free-exercise-db) — dataset raccomandato
- [exercises.json (wrkout)](https://github.com/wrkout/exercises.json) — alternativa con più esercizi
- [ExerciseDB API](https://github.com/ExerciseDB/exercisedb-api) — per una futura versione con GIF
- [Compendium of Physical Activities (MET)](https://sites.google.com/site/compendiumofphysicalactivities/) — fonte per valori MET
