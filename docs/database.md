# Plico — Documentazione Database

**Engine:** Isar (NoSQL embedded, Flutter-native)  
**Versione schema:** 2.0  
**Ultimo aggiornamento:** 2026-06-05  
**Service layer:** `lib/services/database_service.dart`  
**Tipo app:** Standalone, single-user, offline-first

---

## Principi di progettazione

- **Single-user**: nessun account o autenticazione. I record singoli usano id fisso = 1.
- **Storicizzazione**: peso, plicometria e misurazioni sono snapshot temporali, mai sovrascritti, per consentire l'analisi dell'evoluzione nel tempo.
- **Separazione dati anagrafici / misurazioni**: dati statici in `UserProfile`; dati temporali in `BodySnapshot` e `PlicometrySession`.
- **Embedded objects**: valori nested (pliche, risultati, slot piano, voci diario) sono embedded nella collezione padre per evitare join su dati sempre letti insieme.
- **Offline-first**: nessuna dipendenza da rete. Il DB vive interamente sul device.

---

## Collezioni

### 1. `UserProfile`

Dati anagrafici dell'utente. Record singolo (id = 1).

| Campo             | Tipo       | Obbligatorio | Note                                    |
|-------------------|------------|:------------:|-----------------------------------------|
| `id`              | `Id`       | ✓            | Sempre 1                                |
| `nome`            | `String`   | ✓            |                                         |
| `cognome`         | `String`   | ✓            |                                         |
| `dataNascita`     | `DateTime` | ✓            | Usata per calcolare l'età corrente      |
| `sesso`           | `Sesso`    | ✓            | Enum: `maschio` / `femmina`             |
| `altezzaCm`       | `double`   | ✓            | Altezza di riferimento per i calcoli    |
| `bodyFatIniziale` | `double?`  |              | BF% di partenza (pre-plicometria)       |
| `createdAt`       | `DateTime` | ✓            | Data prima configurazione               |

**Campo calcolato:** `etaCorrente` (getter, non persistito) — calcola l'età dall'anno corrente.

---

### 2. `AppSettings`

Impostazioni applicative e configurazione del piano nutrizionale. Record singolo (id = 1).

| Campo             | Tipo       | Default | Note                                          |
|-------------------|------------|:-------:|-----------------------------------------------|
| `id`              | `Id`       | 1       | Sempre 1                                      |
| `isDarkMode`      | `bool`     | false   | Tema dell'interfaccia                         |
| `livelloAttivita` | `int`      | 2       | 0=sedentario · 1=legg. attivo · 2=mod. attivo · 3=molto attivo · 4=atleta |
| `metodoTdee`      | `int`      | 0       | 0=auto · 1=Katch-McArdle · 2=Mifflin-St Jeor · 3=Harris-Benedict |
| `obiettivo`       | `int`      | 1       | 0=deficit (−20%) · 1=mantenimento · 2=surplus (+15%) |
| `creaSeeded`      | `bool`     | false   | Flag: DB alimenti CREA già popolato           |
| `goalSetDate`     | `DateTime?`|         | Data attivazione piano; `null` = piano non attivo |

**Nota:** `goalSetDate != null` indica che il piano è attivo. Dopo 30 giorni l'app suggerisce di ricalcolarlo.

---

### 3. `UserFoodPreferences`

Preferenze alimentari dell'utente, raccolte tramite il questionario. Record singolo (id = 1).

| Campo                   | Tipo          | Default | Note                                         |
|-------------------------|---------------|:-------:|----------------------------------------------|
| `id`                    | `Id`          | 1       | Sempre 1                                     |
| `restrizioni`           | `List<String>`| []      | Es. `"vegetariano"`, `"vegano"`, `"no_lattosio"`, `"no_glutine"`, `"no_pesce"`, `"no_fruttaSecca"` |
| `foodLikedIds`          | `List<int>`   | []      | Id Isar degli alimenti marcati come preferiti |
| `numPasti`              | `int`         | 3       | 3 / 4 / 5 pasti al giorno                   |
| `haSpuntinoPostWo`      | `bool`        | false   | Se true, il piano include uno spuntino post-allenamento |
| `questionarioCompletato`| `bool`        | false   | Flag UI: mostra il piano o il CTA questionario |

---

### 4. `FoodItem`

Alimento dal database nutrizionale CREA. Valori per 100g.

| Campo         | Tipo     | Note                                              |
|---------------|----------|---------------------------------------------------|
| `id`          | `Id`     | Auto-increment                                    |
| `nome`        | `String` | Nome canonico italiano (es. "Petto di pollo")     |
| `kcalPer100g` | `double` |                                                   |
| `protPer100g` | `double` |                                                   |
| `fatPer100g`  | `double` |                                                   |
| `carbsPer100g`| `double` |                                                   |
| `fibraPer100g`| `double?`| Opzionale                                         |
| `fonte`       | `String` | `"crea"` per i dati ufficiali, `"custom"` per voci aggiuntive |

**Indici:** `nome` (ricerca testuale), `fonte`.  
**Seed:** il file `assets/data/crea_seed.json` popola questa collezione al primo avvio via `seedCreaFoods()`. Contiene ~80 voci CREA + 6 voci custom (CUSTOM001–006: skyr, gallette di riso, fiocchi di latte, tofu, tempeh, seitan).

---

### 5. `BodySnapshot`

Storico delle pesate. Ogni record è una misurazione in un dato momento.

| Campo            | Tipo      | Obbligatorio | Note                                              |
|------------------|-----------|:------------:|---------------------------------------------------|
| `id`             | `Id`      | ✓            | Auto-increment                                    |
| `data`           | `DateTime`| ✓            | Data e ora della rilevazione                      |
| `pesoKg`         | `double`  | ✓            |                                                   |
| `altezzaCm`      | `double?` |              | Solo se diversa dal profilo                       |
| `bodyFatManuale` | `double?` |              | BF% da bilancia impedenziometrica                 |
| `note`           | `String?` |              |                                                   |

**Indici:** `data` (desc).  
**Uso:** la pesata più recente è usata per calcolare TDEE e macro target. Il grafico peso in `ProgressiScreen` visualizza la serie storica.

---

### 6. `PlicometrySession`

Sessione di plicometria con misure, metodo e risultati calcolati.

| Campo       | Tipo                    | Obbligatorio | Note                                  |
|-------------|-------------------------|:------------:|---------------------------------------|
| `id`        | `Id`                    | ✓            | Auto-increment                        |
| `data`      | `DateTime`              | ✓            |                                       |
| `metodo`    | `MetodoPlicometria`     | ✓            | Enum (vedi sotto)                     |
| `etaAnni`   | `int`                   | ✓            | Età al momento della sessione         |
| `pesoKg`    | `double`                | ✓            | Copiato dalla pesata corrente         |
| `altezzaCm` | `double`                | ✓            | Copiato dal profilo                   |
| `pliche`    | `Pliche` (embedded)     | ✓            | Valori mm dei siti rilevati           |
| `risultati` | `RisultatiPlico` (emb.) | ✓            | BF%, MG, MM calcolati                 |
| `note`      | `String?`               |              |                                       |

**Indici:** `data`, `metodo`.

#### Embedded: `Pliche`
Valori mm per sito. Solo i campi richiesti dal metodo vengono compilati.

| Campo              | Metodi                                     |
|--------------------|--------------------------------------------|
| `tricipiteMm`      | D&W, J&P-3 (F), J&P-7, Faulkner           |
| `bicipiteMm`       | D&W                                        |
| `pettoraleMm`      | J&P-3 (M), J&P-7                           |
| `ascelllareMm`     | J&P-7                                      |
| `sottoscapolareMm` | D&W, J&P-7, Faulkner                       |
| `sovrailiachMm`    | D&W, J&P-3 (F), J&P-7, Faulkner           |
| `addomineMm`       | J&P-3 (M), J&P-7, Faulkner                |
| `cosciaMm`         | J&P-3, J&P-7                               |
| `polpaccioMm`      | US Navy (circonferenza)                    |

#### Embedded: `RisultatiPlico`

| Campo             | Tipo      | Descrizione                           |
|-------------------|-----------|---------------------------------------|
| `bodyFatPercent`  | `double`  | % massa grassa                        |
| `massaGrassaKg`   | `double`  | Massa grassa in kg                    |
| `massaMagraKg`    | `double`  | Massa magra (FFM) in kg               |
| `sommaPlicheMm`   | `double`  | Somma delle pliche usate              |
| `densitaCorporea` | `double?` | Densità corporea (se calcolata)       |

---

### 7. `MeasurementSnapshot`

Misurazioni corporee manuali (pliche aggregate + circonferenze). Un record per giorno.

| Sezione       | Campi                                                                    |
|---------------|--------------------------------------------------------------------------|
| **Pliche (mm)**| `tricipiteMm`, `bicipiteMm`, `pettoraleMm`, `ascelllareMm`, `sottoscapolareMm`, `sovrailiachMm`, `addomineMm`, `cosciaMm`, `polpaccioMm` |
| **Circonferenze (cm)** | `colloCm`, `vitaCm`, `fianchiCm`, `braccioCm`, `cosciaCm`, `polpaccioCm`, `toraceCm`, `spalleCm` |
| **Meta**      | `fonti: List<String>` — es. `["manuale", "jacksonPollock3"]`             |

**Indici:** `data` (normalizzata a mezzanotte, un record per giorno).  
**Uso:** i dati aggregati sono visualizzati in `ProgressiScreen` → sezione "Misurazioni".

---

### 8. `DailyLog`

Diario alimentare giornaliero. Un record per giorno (normalizzato a mezzanotte).

| Campo     | Tipo              | Note                                        |
|-----------|-------------------|---------------------------------------------|
| `id`      | `Id`              | Auto-increment                              |
| `data`    | `DateTime`        | Normalizzata a mezzanotte; indice univoco   |
| `entries` | `List<MealEntry>` | Voci alimentari della giornata (embedded)   |

**Getter calcolati:** `kcalTotali`, `proteinTotali`, `fatTotali`, `carbsTotali`.

#### Embedded: `MealEntry`

| Campo           | Tipo     | Note                                          |
|-----------------|----------|-----------------------------------------------|
| `foodNome`      | `String` | Nome alimento                                 |
| `foodBrand`     | `String?`| Brand (da Open Food Facts, se presente)       |
| `kcalPer100g`   | `double` |                                               |
| `proteinPer100g`| `double` |                                               |
| `fatPer100g`    | `double` |                                               |
| `carbsPer100g`  | `double` |                                               |
| `quantitaG`     | `double` | Quantità in grammi                            |
| `pastoTipo`     | `int`    | Indice `PastoTipo` (vedi enum sotto)          |

**Getter calcolati:** `kcal`, `proteinG`, `fatG`, `carbsG` (quantitaG × valore/100).

---

### 9. `MealPlan`

Piano alimentare giornaliero generato. Record singolo (id = 1), sovrascritto ad ogni rigenerazione.

| Campo                    | Tipo             | Note                                         |
|--------------------------|------------------|----------------------------------------------|
| `id`                     | `Id`             | Sempre 1                                     |
| `dataCreazione`          | `DateTime`       |                                              |
| `pasti`                  | `List<PlanMeal>` | Pasti del piano (embedded)                   |
| `kcalTotali`             | `double`         | Totale piano                                 |
| `proteineTotali`         | `double`         |                                              |
| `grassiTotali`           | `double`         |                                              |
| `carbsTotali`            | `double`         |                                              |
| `obsoleto`               | `bool`           | True se peso/obiettivo cambiati dopo la generazione |
| `livelloAtGenerazione`   | `int`            | Snapshot livello attività al momento della generazione |
| `obiettivoAtGenerazione` | `int`            | Snapshot obiettivo al momento della generazione |

#### Embedded: `PlanMeal`

| Campo            | Tipo            | Note                                              |
|------------------|-----------------|---------------------------------------------------|
| `tipo`           | `int`           | Indice `PastoTipo` (0–5)                          |
| `slots`          | `List<PlanSlot>`| Slot alimentari del pasto (principale)            |
| `slotsAlternativa`| `List<PlanSlot>`| Slot per la versione alternativa del pasto (es. colazione salata vs dolce) |

#### Embedded: `PlanSlot`

| Campo         | Tipo            | Note                                              |
|---------------|-----------------|---------------------------------------------------|
| `tipo`        | `int`           | 0=proteina · 1=carboidrato · 2=verdura · 3=grasso · 4=extra · 5=frutta |
| `principale`  | `PlanFood?`     | Alimento principale per lo slot                   |
| `alternative` | `List<PlanFood>`| Alternative equivalenti (prima i preferiti dall'utente, poi max 3 non-preferiti) |

#### Embedded: `PlanFood`

| Campo         | Tipo     | Note                                |
|---------------|----------|-------------------------------------|
| `nome`        | `String` |                                     |
| `foodItemId`  | `int`    | Id del `FoodItem` sorgente          |
| `quantitaG`   | `double` | Arrotondata a multipli di 5g        |
| `kcal`        | `double` |                                     |
| `proteine`    | `double` |                                     |
| `grassi`      | `double` |                                     |
| `carboidrati` | `double` |                                     |

---

## Enumerazioni

### `Sesso`
```
maschio · femmina
```

### `PastoTipo`
```
0 = colazione
1 = pranzo
2 = cena
3 = spuntino
4 = postWo          ← aggiunto; mostrato solo se haSpuntinoPostWo = true
5 = spuntinoSerale  ← aggiunto; mostrato solo se numPasti = 5
```

### `MetodoPlicometria`
```
durninWomersley  → 4 pliche, uomo e donna
jacksonPollock3  → 3 pliche, dipende dal sesso
jacksonPollock7  → 7 pliche, alta precisione
faulkner         → 4 pliche, pensato per atleti
usNavy           → circonferenze (collo, vita, fianchi)
```

---

## Diagramma ER (logico)

```
┌─────────────────┐   ┌──────────────────┐   ┌──────────────────────┐
│   UserProfile   │   │   AppSettings    │   │ UserFoodPreferences  │
│  (id = 1)       │   │  (id = 1)        │   │  (id = 1)            │
│─────────────────│   │──────────────────│   │──────────────────────│
│ nome, cognome   │   │ isDarkMode       │   │ restrizioni[]        │
│ dataNascita     │   │ livelloAttivita  │   │ foodLikedIds[]       │
│ sesso           │   │ metodoTdee       │   │ numPasti             │
│ altezzaCm       │   │ obiettivo        │   │ haSpuntinoPostWo     │
│ bodyFatIniziale?│   │ creaSeeded       │   │ questionarioCompletato│
│ createdAt       │   │ goalSetDate?     │   └──────────────────────┘
└─────────────────┘   └──────────────────┘

┌─────────────────┐   ┌──────────────────────────────────────────────┐
│  BodySnapshot   │   │              PlicometrySession               │
│  (N record)     │   │              (N record)                      │
│─────────────────│   │──────────────────────────────────────────────│
│ data            │   │ data, metodo, etaAnni, pesoKg, altezzaCm    │
│ pesoKg          │   │ ┌──────────────┐  ┌───────────────────────┐ │
│ altezzaCm?      │   │ │    Pliche    │  │   RisultatiPlico      │ │
│ bodyFatManuale? │   │ │  (mm × sito) │  │ bodyFat%, MG, MM      │ │
│ note?           │   │ └──────────────┘  └───────────────────────┘ │
└─────────────────┘   └──────────────────────────────────────────────┘

┌────────────────────────┐   ┌────────────────────────────────────────┐
│  MeasurementSnapshot   │   │              DailyLog                  │
│  (N record, 1/giorno)  │   │         (N record, 1/giorno)           │
│────────────────────────│   │────────────────────────────────────────│
│ data                   │   │ data                                   │
│ fonti[]                │   │ entries[]:                             │
│ pliche (mm) × 9        │   │   MealEntry {                         │
│ circonferenze (cm) × 8 │   │     foodNome, quantitaG               │
└────────────────────────┘   │     pastoTipo (0–5)                   │
                             │     macro per 100g                    │
                             │   }                                   │
                             └────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                           MealPlan                                 │
│                          (id = 1)                                  │
│────────────────────────────────────────────────────────────────────│
│ dataCreazione, kcalTotali, macro totali, obsoleto                  │
│ livelloAtGenerazione, obiettivoAtGenerazione                       │
│                                                                    │
│ pasti[]: PlanMeal {                                                │
│   tipo (PastoTipo 0–5)                                             │
│   slots[]: PlanSlot {                                              │
│     tipo (0=prot · 1=carbo · 2=verd · 3=grasso · 4=extra · 5=frut)│
│     principale: PlanFood { nome, quantitaG, macro }               │
│     alternative[]: PlanFood[]                                      │
│   }                                                                │
│   slotsAlternativa[]: PlanSlot[]  (es. colazione salata)          │
│ }                                                                  │
└────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│               FoodItem                  │
│           (~80 voci CREA)               │
│─────────────────────────────────────────│
│ nome                                    │
│ kcal / prot / fat / carbs per 100g      │
│ fibra? (opzionale)                      │
│ fonte ("crea" | "custom")               │
└─────────────────────────────────────────┘
```

---

## Architettura navigazione

```
main.dart
  └── hasUserProfile?
        ├── NO  → OnboardingScreen (6 step)
        │           └── completamento → MainScreen
        └── SÌ  → MainScreen
                    ├── Tab 0: HomeScreen
                    ├── Tab 1: DiarioScreen (DIARIO | PIANO tabs)
                    ├── Tab 2: ProgressiScreen
                    └── Tab 3: TdeeScreen
```

`MainScreen` usa `IndexedStack` + `BottomNavigationBar`. Le schermate secondarie (PesateScreen, MethodSelectionScreen, StoricoMisurazioniScreen, ecc.) sono pushate via `Navigator.push` sopra il MainScreen.

---

## Service Layer — `DatabaseService`

Singleton accessibile via `DatabaseService.instance`.  
Inizializzato in `main()` prima di `runApp()`.

### UserProfile
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `hasUserProfile()` | `Future<bool>` | Routing onboarding/home |
| `getUserProfile()` | `Future<UserProfile?>` | Legge il profilo |
| `saveUserProfile(p)` | `Future<void>` | Crea o aggiorna |
| `watchUserProfile()` | `Stream<UserProfile?>` | Reattivo per la UI |

### AppSettings
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `getIsDarkMode()` / `saveIsDarkMode(bool)` | — | Tema |
| `getLivelloAttivita()` / `saveLivelloAttivita(int)` | — | Livello attività |
| `getMetodoTdee()` / `saveMetodoTdee(int)` | — | Metodo calcolo TDEE |
| `getObiettivo()` / `saveObiettivo(int)` | — | Obiettivo calorico |
| `getGoalSetDate()` | `Future<DateTime?>` | Data attivazione piano |
| `activateGoal(livello, metodo, obiettivo)` | `Future<void>` | Attiva il piano (imposta goalSetDate) |
| `resetGoal()` | `Future<void>` | Deattiva il piano |
| `watchAppSettings()` | `Stream<AppSettings?>` | Reattivo per TDEE/Diario |

### UserFoodPreferences
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `getUserFoodPreferences()` | `Future<UserFoodPreferences?>` | Legge le preferenze |
| `saveUserFoodPreferences(p)` | `Future<void>` | Salva questionario |

### FoodItem
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `seedCreaFoods()` | `Future<void>` | Popola il DB al primo avvio |
| `getAllCreaFoods()` | `Future<List<FoodItem>>` | Tutti gli alimenti |
| `searchFoods(query)` | `Future<List<FoodItem>>` | Ricerca testuale |

### BodySnapshot
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `addBodySnapshot(s)` | `Future<void>` | Aggiunge pesata |
| `deleteBodySnapshot(id)` | `Future<void>` | Elimina pesata |
| `getLatestBodySnapshot()` | `Future<BodySnapshot?>` | Ultima pesata |
| `watchBodySnapshots()` | `Stream<List<BodySnapshot>>` | Reattivo per grafici e HomeScreen |

### PlicometrySession
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `addPlicometrySession(s)` | `Future<void>` | Salva sessione |
| `deletePlicometrySession(id)` | `Future<void>` | Elimina |
| `getLatestPlicometrySession()` | `Future<PlicometrySession?>` | Ultima sessione |
| `watchPlicometrySessions()` | `Stream<List<...>>` | Reattivo per HomeScreen/Progressi |

### DailyLog
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `getDailyLog(date)` | `Future<DailyLog?>` | Log di un giorno |
| `watchDailyLog(date)` | `Stream<DailyLog?>` | Reattivo per DiarioScreen/HomeScreen |
| `addMealEntry(date, entry)` | `Future<void>` | Aggiunge voce al diario |
| `removeMealEntry(date, index)` | `Future<void>` | Rimuove voce |

### MealPlan
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `getMealPlan()` | `Future<MealPlan?>` | Piano corrente |
| `saveMealPlan(plan)` | `Future<void>` | Salva/sovrascrive piano |
| `watchMealPlan()` | `Stream<MealPlan?>` | Reattivo per PianoTab |

### MeasurementSnapshot
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `addMeasurementSnapshot(s)` | `Future<void>` | Aggiunge misurazione |
| `deleteMeasurementSnapshot(id)` | `Future<void>` | Elimina |
| `watchMeasurementSnapshots()` | `Stream<List<...>>` | Reattivo per Progressi/Storico |

---

## Decisioni di progettazione

| Decisione | Motivazione |
|-----------|-------------|
| `BodySnapshot` separato da `PlicometrySession` | Il peso può essere registrato senza plicometria |
| `etaAnni`/`pesoKg`/`altezzaCm` copiati nella sessione | I calcoli storici devono restare corretti anche se il profilo cambia |
| `MealPlan` record singolo (id=1) | Il piano è sempre uno solo; la rigenerazione sovrascrive |
| `PlanFood.quantitaG` arrotondata a multipli di 5g | Usabilità pratica: grammature realistiche da pesare |
| `PastoTipo` come `int` in `MealEntry` | Flessibilità: aggiungere nuovi tipi senza migrazioni Isar |
| `slotsAlternativa` in `PlanMeal` | Permette la versione alternativa del pasto (es. colazione salata) senza duplicare il record |
| `goalSetDate` in `AppSettings` | Unica fonte di verità per lo stato del piano; usata da TdeeScreen, DiarioScreen e HomeScreen |
