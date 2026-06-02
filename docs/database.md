# Plico — Documentazione Database

**Engine:** Isar (NoSQL embedded, Flutter-native)  
**Versione schema:** 1.0  
**Ultimo aggiornamento:** 2026-06-02  
**Service layer:** `lib/services/database_service.dart`  
**Tipo app:** Standalone, single-user, offline-first

---

## Principi di progettazione

- **Single-user**: non esiste un concetto di account o autenticazione. Il profilo utente è sempre e solo uno (id = 1).
- **Storicizzazione**: peso, altezza e body fat vengono registrati come snapshot temporali, non sovrascritti, per consentire l'analisi dell'evoluzione nel tempo.
- **Separazione tra dati anagrafici e misurazioni**: i dati statici (nome, sesso, data di nascita) vivono in `UserProfile`; i dati che cambiano nel tempo vivono in `BodySnapshot` e `PlicometrySession`.
- **Embedded objects**: i valori delle pliche e i risultati calcolati sono embedded direttamente nella sessione, evitando join inutili su dati che non vengono mai letti separatamente.

---

## Collezioni

### 1. `UserProfile`

Dati anagrafici e baseline dell'utente. Record singolo (id fisso = 1).

| Campo          | Tipo       | Obbligatorio | Note                                      |
|----------------|------------|:------------:|-------------------------------------------|
| `id`           | `Id`       | ✓            | Sempre 1 (single-user)                    |
| `nome`         | `String`   | ✓            |                                           |
| `cognome`      | `String`   | ✓            |                                           |
| `dataNascita`  | `DateTime` | ✓            | Usata per calcolare l'età nelle formule   |
| `sesso`        | `Sesso`    | ✓            | Enum: `maschio` / `femmina`               |
| `altezzaCm`    | `double`   | ✓            | Altezza di riferimento in cm              |
| `bodyFatIniziale` | `double?` |            | BF% noto a priori (opzionale)            |
| `createdAt`    | `DateTime` | ✓            | Data di prima configurazione              |

**Note:** `altezzaCm` è il valore di default usato nei calcoli. Se l'altezza cambia nel tempo può essere aggiornata qui oppure indicata puntualmente nel `BodySnapshot`.

---

### 2. `BodySnapshot`

Storico delle misurazioni antropometriche manuali (peso, altezza, BF noto).  
Ogni record rappresenta una rilevazione in un dato momento.

| Campo             | Tipo       | Obbligatorio | Note                                            |
|-------------------|------------|:------------:|-------------------------------------------------|
| `id`              | `Id`       | ✓            | Auto-increment                                  |
| `data`            | `DateTime` | ✓            | Data e ora della rilevazione                    |
| `pesoKg`          | `double`   | ✓            | Peso in kg                                      |
| `altezzaCm`       | `double?`  |              | Compilare solo se diversa dal profilo           |
| `bodyFatManuale`  | `double?`  |              | BF% inserito manualmente (es. bilancia impedenziometrica) |
| `note`            | `String?`  |              | Annotazioni libere                              |

**Indici:** `data` (ordinamento cronologico).

---

### 3. `PlicometrySession`

Sessione completa di plicometria: contiene il metodo usato, i valori delle pliche rilevate e i risultati calcolati.

| Campo        | Tipo                    | Obbligatorio | Note                                        |
|--------------|-------------------------|:------------:|---------------------------------------------|
| `id`         | `Id`                    | ✓            | Auto-increment                              |
| `data`       | `DateTime`              | ✓            | Data e ora della sessione                   |
| `metodo`     | `MetodoPlicometria`     | ✓            | Enum (vedi sotto)                           |
| `etaAnni`    | `int`                   | ✓            | Età calcolata al momento della sessione     |
| `pesoKg`     | `double`                | ✓            | Peso usato per i calcoli                    |
| `altezzaCm`  | `double`                | ✓            | Altezza usata per i calcoli                 |
| `pliche`     | `Pliche` (embedded)     | ✓            | Valori in mm dei siti rilevati              |
| `risultati`  | `RisultatiPlico` (embedded) | ✓        | Output calcolati della sessione             |
| `note`       | `String?`               |              | Annotazioni libere                          |

**Indici:** `data`, `metodo`.

---

### Embedded: `Pliche`

Valori in millimetri dei siti di rilevazione. Solo i campi richiesti dal metodo scelto vengono compilati.

| Campo            | Tipo      | Metodi che lo usano                              |
|------------------|-----------|--------------------------------------------------|
| `tricipiteMm`    | `double?` | D&W, J&P-3 (F), J&P-7, Faulkner                 |
| `bicipiteMm`     | `double?` | D&W                                              |
| `pettoralleMm`   | `double?` | J&P-3 (M), J&P-7                                |
| `ascelllareMm`   | `double?` | J&P-7                                            |
| `sottoscapolareMm` | `double?` | D&W, J&P-7, Faulkner                          |
| `sovrailiachMm`  | `double?` | D&W, J&P-3 (F), J&P-7, Faulkner                 |
| `addomineMm`     | `double?` | J&P-3 (M), J&P-7, Faulkner                      |
| `cosciaMm`       | `double?` | J&P-3, J&P-7                                     |
| `polpacciomm`    | `double?` | Metodi opzionali futuri                          |

---

### Embedded: `RisultatiPlico`

Risultati calcolati a partire dai valori delle pliche e dai dati antropometrici.

| Campo             | Tipo     | Descrizione                                    |
|-------------------|----------|------------------------------------------------|
| `bodyFatPercent`  | `double` | % di massa grassa                              |
| `massaGrassaKg`   | `double` | Massa grassa in kg                             |
| `massaMapraKg`    | `double` | Massa magra (FFM) in kg                        |
| `sommaPlicheMm`   | `double` | Somma totale delle pliche usate (mm)           |
| `densitaCorporea` | `double?`| Densità corporea (se calcolata dalla formula)  |

---

## Enumerazioni

### `Sesso`
```
maschio
femmina
```

### `MetodoPlicometria`
```
durninWomersley    → 4 pliche, uomo e donna
jacksonPollock3    → 3 pliche, dipende dal sesso
jacksonPollock7    → 7 pliche, alta precisione
faulkner           → 4 pliche, pensato per atleti
```

---

## Diagramma ER (logico)

```
┌─────────────────────┐
│     UserProfile     │  ← record singolo (id = 1)
│─────────────────────│
│ id                  │
│ nome                │
│ cognome             │
│ dataNascita         │
│ sesso               │
│ altezzaCm           │
│ bodyFatIniziale?    │
│ createdAt           │
└─────────────────────┘

┌─────────────────────┐
│    BodySnapshot     │  ← N record nel tempo
│─────────────────────│
│ id (auto)           │
│ data                │
│ pesoKg              │
│ altezzaCm?          │
│ bodyFatManuale?     │
│ note?               │
└─────────────────────┘

┌──────────────────────────────────────────┐
│           PlicometrySession              │  ← N record nel tempo
│──────────────────────────────────────────│
│ id (auto)                                │
│ data                                     │
│ metodo                                   │
│ etaAnni                                  │
│ pesoKg                                   │
│ altezzaCm                                │
│ note?                                    │
│                                          │
│  ┌─────────────────┐  ┌───────────────┐  │
│  │     Pliche      │  │  Risultati    │  │
│  │─────────────────│  │───────────────│  │
│  │ tricipiteMm?    │  │ bodyFat%      │  │
│  │ bicipiteMm?     │  │ massaGrassaKg │  │
│  │ pettoralleMm?   │  │ massaMagraKg  │  │
│  │ ascelllareMm?   │  │ sommaPliche   │  │
│  │ sottoscapolareMm│  │ densita?      │  │
│  │ sovrailiachMm?  │  └───────────────┘  │
│  │ addomineMm?     │                     │
│  │ cosciaMm?       │                     │
│  │ polpaccioMm?    │                     │
│  └─────────────────┘                     │
└──────────────────────────────────────────┘
```

---

## Decisioni di progettazione

| Decisione | Motivazione |
|-----------|-------------|
| `BodySnapshot` separato da `PlicometrySession` | Il peso può essere registrato anche senza fare una sessione di plicometria (es. pesata mattutina) |
| `etaAnni` e `pesoKg` copiati nella sessione | I calcoli dipendono dai valori al momento della misurazione; se in futuro il profilo cambia, i risultati storici restano corretti |
| `altezzaCm` duplicata nella sessione | Stessa motivazione del punto sopra |
| Nessuna relazione esplicita tra collezioni | Isar non supporta foreign key; il collegamento implicito è sempre con l'unico `UserProfile` (id=1) |
| `bodyFatIniziale` opzionale nel profilo | Permette di avere un punto di partenza anche prima della prima sessione di plicometria |

---

## Service Layer — `DatabaseService`

Singleton accessibile ovunque via `DatabaseService.instance`.  
Inizializzato in `main()` prima di `runApp()`.

### API pubblica

#### UserProfile
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `hasUserProfile()` | `Future<bool>` | Usato per decidere se mostrare l'onboarding |
| `getUserProfile()` | `Future<UserProfile?>` | Legge il profilo utente |
| `saveUserProfile(profile)` | `Future<void>` | Crea o aggiorna il profilo |
| `watchUserProfile()` | `Stream<UserProfile?>` | Stream reattivo per la UI |

#### BodySnapshot
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `addBodySnapshot(snapshot)` | `Future<void>` | Aggiunge una nuova pesata |
| `deleteBodySnapshot(id)` | `Future<void>` | Elimina una pesata |
| `getBodySnapshots()` | `Future<List<...>>` | Tutte le pesate, ordinate per data desc |
| `getLatestBodySnapshot()` | `Future<BodySnapshot?>` | L'ultima pesata registrata |
| `watchBodySnapshots()` | `Stream<List<...>>` | Stream reattivo per grafici |

#### PlicometrySession
| Metodo | Ritorna | Descrizione |
|--------|---------|-------------|
| `addPlicometrySession(session)` | `Future<void>` | Salva una sessione di plicometria |
| `deletePlicometrySession(id)` | `Future<void>` | Elimina una sessione |
| `getPlicometrySessions()` | `Future<List<...>>` | Tutte le sessioni, ordinate per data desc |
| `getLatestPlicometrySession()` | `Future<PlicometrySession?>` | L'ultima sessione |
| `getSessionsByMethod(metodo)` | `Future<List<...>>` | Filtra per metodo di calcolo |
| `watchPlicometrySessions()` | `Stream<List<...>>` | Stream reattivo per grafici/storico |

#### Utility
| Metodo | Descrizione |
|--------|-------------|
| `clearAll()` | Cancella tutti i dati (usato per reset/debug) |
