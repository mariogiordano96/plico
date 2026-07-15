# Integrazione Smartwatch — Analisi Funzionale

> Obiettivo: far arrivare in Plico i dati di attività fisica registrati da uno smartwatch
> (sessioni di allenamento, frequenza cardiaca, kcal attive), per ridurre l'inserimento
> manuale e rendere più precisa la stima calorica già implementata per la sezione
> Esercizi/Allenamento (vedi `esercizi.md`, `evolutiva_esercizi.md`).

---

## 1. Scope

1. **Import sessioni di allenamento** rilevate dal watch (cardio e pesi) → creano
   `WorkoutExercise` senza inserimento manuale, affiancando (non sostituendo) il log manuale
   delle serie quando si tratta di pesi
2. **Kcal attive reali** riportate dal watch → sostituiscono la stima interna (MET fisso,
   vedi `CalorieEstimationService`) quando disponibili, non si limitano ad affiancarla
3. **Frequenza cardiaca** → mostrata a livello di sessione; usata come fallback per stimare
   le kcal solo se il watch non riporta calorie attive dirette

Fuori scope: loggare un allenamento offline direttamente dal polso, senza telefono — le
alternative valutate e scartate per arrivarci sono in sezione 3. Fuori scope anche il TDEE
dinamico basato su passi/attività quotidiana (idea originariamente in `miglioramenti.md`):
nessun nutrizionista aggiusta il TDEE a questo livello di granularità giorno per giorno,
non aggiunge valore reale all'utente.

---

## 2. Come Plico può "vedere" uno smartwatch

Nessun produttore espone un'API pensata per essere integrata direttamente, uno per uno,
da un'app terza come Plico. Il canale standard è invece l'**hub di sistema** del telefono:
ogni app companion di uno smartwatch (Apple Watch, Wear OS, Galaxy Watch, Garmin Connect,
Fitbit, Polar Flow, Whoop, Coros...) scrive i propri dati — se l'utente lo autorizza — in:

- **iOS → Apple HealthKit** ("Salute")
- **Android → Health Connect** (sostituisce Google Fit; le API di Google Fit vengono
  dismesse a fine 2026, qualunque nuova integrazione va fatta su Health Connect)

Quindi "integrare gli smartwatch" significa, in pratica, integrare questi due hub — non i
singoli dispositivi.

---

## 3. Opzioni valutate

| Opzione | Copertura device | Sforzo | Manutenzione | Note |
|---|---|---|---|---|
| **Health Connect + Apple Health** (hub di sistema) | Praticamente tutti i watch rilevanti (Apple Watch, Wear OS/Galaxy Watch, Garmin, Fitbit, Polar, Coros, Whoop, Xiaomi...), a patto che l'utente abbia l'app companion collegata | Medio — un solo package Flutter, permessi piattaforma, mapping dati | Bassa — Google/Apple mantengono l'hub, Plico legge solo | **Raccomandato** |
| Companion app nativa Wear OS (Kotlin/Compose) | Solo Wear OS 4+ | Alto — codebase nativa separata, Data Layer API, listing Play Store dedicato | Alta — un secondo prodotto da mantenere in parallelo a Flutter | Permetterebbe logging offline dal polso, ma è fuori scope qui |
| Companion app nativa watchOS (SwiftUI) | Solo Apple Watch | Alto — stesso discorso, terza codebase | Alta | idem |
| SDK diretti per singolo vendor (Garmin Connect IQ, Fitbit Web API, Polar AccessLink, Whoop API) | Solo quel device | Alto, si moltiplica per ogni vendor supportato | Alta — N integrazioni, N OAuth, N rate limit diversi | Ridondante: questi stessi dati passano già da HealthKit/Health Connect se l'utente collega l'app companion |

---

## 4. Raccomandazione

**Health Connect (Android) + Apple Health (iOS)** è la scelta corretta, non solo la più
semplice: è l'unica opzione che copre l'intero mercato smartwatch con un solo layer di
integrazione, senza dover scegliere quali vendor supportare esplicitamente. Ogni smartwatch
rilevante scrive già, tramite la propria app companion, in uno dei due hub.

**Package Flutter raccomandato:** [`health`](https://pub.dev/packages/health) — wrapper
unico per HealthKit + Health Connect, attivamente mantenuto, ampiamente usato. Alternative
emerse in fase di ricerca (`health_connector`, `health_forge`) sono più recenti/di nicchia:
restare su `health` salvo problemi concreti in fase di implementazione.

---

## 5. Dati da leggere (mapping)

Lista completa, organizzata per priorità in base a cosa userebbe davvero l'app oggi.

### 5.1 Allenamento — priorità alta (Fasi 2-3 del piano)

Ogni sessione del watch (cardio o pesi) importa come un `WorkoutExercise` a sé, usando il
tipo già esposto dall'hub (`workoutActivityType` in HealthKit, `exerciseType` in Health
Connect) per distinguere i due casi — nessuna euristica lato app:

- **Cardio** (corsa, camminata, ciclismo, nuoto, ellittica...): l'entry è popolata con
  durata, distanza, kcal e frequenza cardiaca reali — stesso schema già usato per un log
  cardio manuale (`durationSeconds` + kcal)
- **Pesi** (`Traditional/Functional Strength Training`, `Weightlifting`...): il watch non
  misura serie/ripetizioni/peso (nessun sensore rileva il carico su un bilanciere), quindi
  l'entry importata ha `sets` vuoto — porta solo durata, kcal reali e frequenza cardiaca
  media. Le serie restano affidate esclusivamente al log manuale (vedi sezione 6 per come
  le due cose convivono senza sommarsi)

| Dato | HealthKit (iOS) | Health Connect (Android) | Uso in Plico |
|---|---|---|---|
| Sessione di allenamento | `HKWorkoutType` (`workoutActivityType`) | `ExerciseSessionRecord` (`exerciseType`) | Crea `WorkoutExercise`; il tipo determina se popolare `sets` (cardio, mai) o lasciarlo vuoto (pesi) |
| Frequenza cardiaca | `HKQuantityTypeIdentifierHeartRate` | `HeartRateRecord` | Nuovo campo `avgHeartRate` su `WorkoutExercise`, per entrambi i tipi |
| Calorie attive | `HKQuantityTypeIdentifierActiveEnergyBurned` | `ActiveCaloriesBurnedRecord` | `estimatedKcal` reale, sostituisce la stima MET quando presente (sezione 6) |
| Distanza | `HKQuantityTypeIdentifierDistanceWalkingRunning`/`DistanceCycling` | `DistanceRecord` | Dettaglio sessioni cardio (corsa, bici) |

### 5.2 Corpo/Progressi — priorità alta, auto-popolano `BodySnapshot`

| Dato | HealthKit (iOS) | Health Connect (Android) | Uso in Plico |
|---|---|---|---|
| Peso corporeo | `HKQuantityTypeIdentifierBodyMass` | `WeightRecord` | `BodySnapshot.pesoKg` — da bilancia smart (Withings, Xiaomi, Renpho...) che sincronizza sull'hub; elimina la pesata manuale |
| Massa grassa % | `HKQuantityTypeIdentifierBodyFatPercentage` | `BodyFatRecord` | Oggi esiste solo `bodyFatManuale` — richiede un nuovo campo `bodyFatSource` su `BodySnapshot` per distinguere manuale da importato, stesso pattern del `source` su `WorkoutExercise` (sezione 6) |
| Altezza | `HKQuantityTypeIdentifierHeight` | `HeightRecord` | `BodySnapshot.altezzaCm` — cambia raramente, ma evita di richiederla a mano |

> Il peso è probabilmente il dato a più alto valore/sforzo di tutta la lista: chi possiede
> una bilancia smart eliminerebbe del tutto la pesata manuale in Progressi.

### 5.3 Wellness — dashboard centralizzata di sola lettura

Il valore di "centralizzare" questi dati non sta nel farli entrare nei calcoli dell'app
(TDEE, kcal, target — quelli restano scartati per i motivi in sezione 1), ma nel dare
all'utente **un unico posto dove vedere ciò che il watch già registra**, senza dover aprire
Garmin Connect/Fitbit/app del sonno separatamente. Per Plico si traduce in una nuova
sezione di sola lettura (es. "Salute" in Progressi, sotto il grafico peso) — nessuna nuova
logica di business, nessun impatto sui calcoli esistenti.

| Dato | HealthKit (iOS) | Health Connect (Android) | Cosa mostrerebbe Plico |
|---|---|---|---|
| Sonno | `HKCategoryTypeIdentifierSleepAnalysis` | `SleepSessionRecord` | Ore di sonno per notte, trend ultimi 7/30gg — stesso pattern grafico già usato per il peso (`fl_chart`) |
| Frequenza cardiaca a riposo | `HKQuantityTypeIdentifierRestingHeartRate` | `RestingHeartRateRecord` | Trend nel tempo, indicatore generale di forma cardiovascolare |
| HRV | `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` | `HeartRateVariabilityRmssdRecord` | Valore/trend giornaliero, indicatore di recupero |
| VO2max | `HKQuantityTypeIdentifierVO2Max` | `Vo2MaxRecord` | Stima della forma aerobica, aggiornata periodicamente dal watch stesso |
| Passi | `HKQuantityTypeIdentifierStepCount` | `StepsRecord` | Contatore giornaliero — puro display, **non** rientra nel calcolo TDEE (scartato, sezione 1) |
| Kcal totali giornaliere | `BasalEnergyBurned` + `ActiveEnergyBurned` | `TotalCaloriesBurnedRecord` | Confronto informativo con le kcal ingerite del diario, separato dal target nutrizionale dell'app |
| Minuti di attività settimanali | aggregato da `HKWorkoutType` | aggregato da `ExerciseSessionRecord` | Es. "120/150 min questa settimana" (linea guida OMS) — puro display |
| Idratazione | `DietaryWater` | `HydrationRecord` | Caso particolare, vedi nota sotto |

**Idratazione — perché non è come gli altri**: a differenza di sonno/HRV/passi (rilevati
passivamente dal sensore), l'acqua bevuta viene comunque inserita a mano dall'utente, sul
watch o su un'altra app. Importarla da Health avrebbe senso solo se Plico costruisce prima
un proprio tracker acqua che **scrive** verso l'hub (vedi sezione 5.4) — altrimenti si
sposta solo il problema da un'app all'altra, non lo si risolve.

**Confine netto col resto del documento**: questi dati restano puramente informativi, non
alimentano il TDEE né la stima kcal delle sezioni 5.1/5.2 — coerente con la decisione di
scartare il TDEE dinamico (sezione 1). L'obiettivo è dare visibilità a dati che il watch
già raccoglie, non far decidere all'app cosa farne.

### 5.4 Verso opposto — scrittura, non lettura (nota, fuori scope di questo piano)

Plico ha già dati nutrizionali dettagliati (kcal/macro per pasto) che potrebbe **scrivere**
verso HealthKit/Health Connect (`DietaryEnergyConsumed`, `DietaryProtein`, `DietaryCarbohydrates`,
`DietaryFatTotal` / equivalenti Health Connect) invece di limitarsi a leggere — diventando
fonte per l'ecosistema Salute oltre che consumatore. È l'opposto del flusso descritto in
questo documento (sezione 6, "solo import in v1"): eventuale estensione futura separata,
non necessaria per gli obiettivi delle sezioni 5.1-5.2.

---

## 6. Architettura d'integrazione con i modelli esistenti

- **Solo import, non sync bidirezionale in v1**: Plico legge da HealthKit/Health Connect,
  non scrive mai verso l'hub in questa fase.
- **Un solo percorso di import per cardio e pesi**: ogni sessione watch diventa un
  `WorkoutExercise` a sé (stesso modello, non un oggetto "overlay" separato), con tre nuovi
  campi:
  - `source` (`manual | healthKit | healthConnect`)
  - `sourceStartTime`/`sourceEndTime` — valorizzati solo per le entry importate, servono a
    individuare sovrapposizioni orarie con log manuali esistenti nello stesso giorno (utile
    quando la giornata ha più sessioni, es. cardio al mattino e pesi al pomeriggio: restano
    due entry indipendenti, ognuna con la propria finestra oraria, mai fuse tra loro)
  - `avgHeartRate` — per entrambi i tipi
- **Cardio**: l'entry importata popola `durationSeconds`/kcal con valori reali, come un log
  manuale. Deduplica contro eventuali log manuali della stessa sessione (match su
  `sourceStartTime`/`sourceEndTime` con tolleranza) per non contare due volte la stessa corsa.
- **Pesi**: l'entry importata ha `sets` vuoto. La stima MET sulle serie manuali di quel
  giorno resta calcolata e salvata come oggi, ma **non entra più nel totale kcal di Home**
  quando esiste una sessione watch pesi sovrapposta in orario — il dato reale vince sempre
  sulla stima, senza somma né media. Coerentemente, la card del singolo esercizio (es.
  "Squat 3×80kg") **nasconde la kcal stimata** in quel caso, mostrando solo serie/rip/peso;
  la kcal reale compare una sola volta, a livello di sessione. Per gli utenti senza
  smartwatch, kcal per esercizio e totale restano invariati.
- Le sessioni importate compaiono nella lista Allenamento con badge sorgente, non editabili
  nei singoli set (a differenza di un log manuale) ma eliminabili se l'utente non le vuole
  conteggiare.

---

## 7. Permessi piattaforma

### iOS
- Capability **HealthKit** abilitata in Xcode (`Runner.xcodeproj`)
- `NSHealthShareUsageDescription` in `Info.plist` (lettura)
- `NSHealthUpdateUsageDescription` solo se in futuro si scrive verso HealthKit (non in v1)
- Richiede un Apple Developer account con l'entitlement HealthKit abilitato — **non
  testabile su simulatore con dati reali**, serve device fisico con Apple Watch abbinato

### Android
- Dichiarare i permessi Health Connect nel manifest: `android.permission.health.READ_EXERCISE`,
  `READ_HEART_RATE`, `READ_ACTIVE_CALORIES_BURNED` (+ `READ_STEPS` se si affronta la fase futura)
- **minSdk**: il progetto usa `flutter.minSdkVersion` di default; Health Connect richiede
  minSdk 26 — da verificare/alzare, stesso tipo di gotcha già incontrato per iOS (bump del
  Podfile a `16.0`, vedi memoria "iOS Build Config")
- Su Android 9–13 Health Connect è un'app separata da Play Store: gestire il caso "non
  installata" con link allo store; su Android 14+ è integrata nel sistema, nessun setup
- Dichiarare `<queries>` per l'intent di Health Connect (package visibility richiesta da
  Android 11+)

---

## 8. UX

- Nuova voce in **Impostazioni**: "Collega Salute" — su iOS mostra "Apple Salute", su
  Android "Health Connect" (l'hub è trasparente, non si chiede all'utente quale smartwatch usa)
- Import manuale (pull-to-refresh) nella card Attività/tab Allenamento in v1; import
  automatico in background come rifinitura successiva, con attenzione al consumo batteria
- Disclaimer privacy esplicito al primo collegamento (vedi sezione rischi)

---

## 9. Considerazioni aperte / rischi

- **Google Fit dismesso**: le API REST di Google Fit terminano a fine 2026 — qualunque
  integrazione Android va fatta su Health Connect, non Google Fit (coerente con quanto
  ipotizzato in partenza)
- **Doppio conteggio kcal**: risolto architetturalmente in sezione 6 (dedup per cardio,
  "il watch vince sempre sulla stima" per i pesi), ma resta la parte più delicata da testare
  bene — in particolare i casi con più sessioni nello stesso giorno (es. cardio al mattino,
  pesi al pomeriggio) o sessioni molto ravvicinate nel tempo
- **Dato sanitario sensibile**: richiede consenso esplicito separato dagli altri permessi
  app; nessun invio a server esterni, coerente con l'impostazione offline-first del resto
  dell'app (Isar locale)
- **Test solo su device fisico**: HealthKit non è testabile su simulatore con dati reali,
  serve un iPhone con Apple Watch abbinato (o, su Android, un device con Health Connect e
  un wearable collegato) — build/run va comunque dato come comando da eseguire manualmente
- **minSdk bump**: da verificare l'impatto sui dispositivi Android più vecchi esclusi,
  decisione da validare con l'utente prima di procedere all'implementazione

---

## 10. Piano di implementazione

### Fase 1 — Setup piattaforma ✅
- [x] Aggiungere dipendenza `health` a `pubspec.yaml` (13.3.1)
- [x] iOS: abilitare capability HealthKit in Xcode, aggiungere `NSHealthShareUsageDescription`
- [x] Android: verificare/alzare `minSdk` a 26, dichiarare permessi Health Connect e `<queries>`
- [x] Verificare che il progetto compili su entrambe le piattaforme (nessuna feature ancora) —
      Android verificato con `flutter build apk --debug` (build riuscita); iOS non verificabile
      su questa macchina Linux, richiede `pod install` + build su Mac (vedi nota sotto)

### Fase 2 — Lettura dati (senza persistenza)
- [x] Flusso di richiesta permessi (`requestAuthorization`) con gestione del rifiuto —
      `SmartwatchService.requestAuthorization()` distingue anche il caso "Health Connect
      non installato" (`SmartwatchAuthorizationResult.unavailable`)
- [x] `SmartwatchService`: legge sessioni allenamento + frequenza cardiaca + kcal attive per
      un intervallo di date (`lib/services/smartwatch_service.dart`)
- [ ] Verifica manuale su device reale con watch abbinato (nessuna UI ancora) — in attesa
      dell'utente, vedi istruzioni fornite in chat

### Fase 3 — Import e deduplica
- [ ] Nuovi campi su `WorkoutExercise`: `source` (`manual | healthKit | healthConnect`),
      `sourceStartTime`/`sourceEndTime`, `avgHeartRate`
- [ ] Mapping sessione importata → `WorkoutExercise` (+ `WorkoutLog` del giorno se assente);
      `sets` vuoto per le sessioni pesi
- [ ] Deduplica cardio contro log manuali esistenti (match su orario sessione)
- [ ] Regola "watch vince sulla stima MET" per il totale kcal pesi + card esercizio senza
      kcal quando esiste una sessione watch sovrapposta in orario

### Fase 4 — UI
- [ ] Voce Impostazioni "Collega Salute" con toggle e stato permessi
- [ ] Badge sorgente nella lista Allenamento per le sessioni importate
- [ ] Import manuale (pull-to-refresh) nella card Attività/tab Allenamento

### Fase 5 — Rifinitura
- [ ] Import automatico in background, valutando impatto batteria
- [ ] Fallback: se una sessione watch riporta solo frequenza cardiaca senza kcal attive,
      derivarle con `CalorieEstimationService` invece di scartare la sessione
- [ ] Disclaimer privacy in UI al primo collegamento

### Fase 6 — *(estensione successiva)* Dashboard Wellness
- [ ] Nuova sezione "Salute" di sola lettura (es. in Progressi, sotto il grafico peso)
- [ ] Lettura sonno, FC a riposo, HRV, VO2max, passi, kcal totali, minuti attività
      settimanali (sezione 5.3) — nessun nuovo calcolo, solo display con trend (`fl_chart`)
- [ ] Idratazione esclusa da questa fase: richiede prima un tracker in-app dedicato con
      scrittura verso l'hub (sezione 5.4), non solo lettura

---

## Riferimenti

- [health (pub.dev)](https://pub.dev/packages/health) — package raccomandato
- [Health Connect — Android Developers](https://developer.android.com/health-and-fitness/health-connect)
- [Apple HealthKit — Apple Developer](https://developer.apple.com/documentation/healthkit)
- `evolutiva_esercizi.md` — nota "Import da Apple Health / Google Fit fuori scope v1, modello dati compatibile"
