# Migrazione dati tra dispositivi

## Idea

Tutti i dati di Plico vivono esclusivamente in un unico file Isar locale, sul
dispositivo. Non c'è alcun account, alcun backend, alcun sync cloud. Questo è
oggi un punto di forza (app privacy-first, funziona offline, zero costi
operativi) ma diventa un problema quando l'utente cambia telefono — sia
restando sulla stessa piattaforma (Android→Android, iOS→iOS), sia passando da
una piattaforma all'altra (Android↔iOS): senza un meccanismo esplicito, tutto
il diario alimentare, gli allenamenti, le pesate, la plicometria e le
misurazioni accumulati nel tempo vanno persi.

Questo documento analizza lo stato attuale e le opzioni per risolverlo,
**prima di implementare nulla**.

---

## Stato attuale (analisi)

- **16 collection Isar** in `lib/services/database_service.dart` (elenco in
  `_schemas`): dati anagrafici/impostazioni (`UserProfile`, `AppSettings`),
  nutrizione (`FoodItem`, `DailyLog`, `UserFoodPreferences`, `MealPlan`,
  `MealCombo`), corpo (`BodySnapshot`, `PlicometrySession`,
  `MeasurementSnapshot`), allenamento (`ExerciseDefinition`, `WorkoutLog`,
  `WorkoutExercise`, `WorkoutTemplate`, `WorkoutProgram`), gamification
  (`Achievement`). Tutto in un solo file `.isar` in
  `getApplicationDocumentsDirectory()`.
- **Nessun export/import/backup esistente**: gli export PDF (piano, scheda,
  storico, progressi) sono solo per stampa/condivisione, non ripristinabili.
  Nessuna dipendenza `share_plus`/`file_picker` in `pubspec.yaml`.
- **Nessun account/cloud**: nessuna dipendenza Firebase/Supabase/backend
  proprio. `http` è usato solo verso Open Food Facts.
- **Backup di sistema non configurato esplicitamente** e comunque
  insufficiente per il caso d'uso:
  - Android: `android:allowBackup` non impostato → vale il default `true`
    (Auto Backup su Google Drive), ma è **inaffidabile**: richiede stesso
    package/firma, account Google con backup attivo, dispositivo carico e in
    idle da un po', quota 25MB/app di default, e molti OEM lo disattivano o
    lo ritardano. **Funziona solo Android→Android**, mai verso iOS.
  - iOS: `Documents/` (dove risiede il file Isar) è incluso di default nel
    backup iCloud/Finder — ma questo aiuta solo se l'utente configura il
    nuovo iPhone **ripristinandolo da un backup completo del vecchio**, non
    con un'installazione pulita da App Store. **Funziona solo iOS→iOS**, e
    solo in quel flusso specifico.
  - **Nessuna delle due copre il caso esplicitamente richiesto (Android↔iOS)**,
    che è strutturalmente impossibile da risolvere con i soli backup di
    sistema, dato che sono ecosistemi separati.

---

## Opzioni valutate

### A. Backup/restore su file locale, senza cloud né account — CONSIGLIATA

L'utente esporta un file di backup dall'app vecchia (tramite il foglio di
condivisione nativo: lo salva su Google Drive/iCloud Drive, se lo manda per
email, lo trasferisce via AirDrop/Nearby Share, USB, ecc. — **la scelta del
canale resta interamente sua**, l'app non deve saperne nulla), poi lo importa
nell'app nuova con un file picker.

**Due varianti tecniche:**

- **A1 — Copia del file `.isar` grezzo.** Isar usa lo stesso formato di
  storage su tutte le piattaforme supportate (è un obiettivo di design del
  progetto), quindi il file dovrebbe aprirsi identico su Android e iOS.
  Export = chiudere/copiare il file e condividerlo; import = sostituire il
  file locale e riaprire Isar. **Pro**: implementazione minima, cattura tutto
  esattamente com'è (incluse le relazioni tra collection via id auto-increment,
  es. `WorkoutExercise.sourceTemplateId`), zero rischio di bug di
  serializzazione custom. **Contro**: file binario opaco (non ispezionabile),
  include anche dati rigenerabili (catalogo esercizi/alimenti CREA, che pesano
  la maggior parte del file), operazione tutto-o-niente (sostituisce
  interamente il device di destinazione — accettabile per il caso d'uso
  "cambio telefono", che è sempre una sostituzione, mai un merge).

- **A2 — Export JSON strutturato per collection**, con schema/versione
  esplicita nel file. **Pro**: leggibile/debuggabile, permette di escludere i
  dati rigenerabili dal seed (file più piccolo), più resiliente a futuri
  cambi di formato interno di Isar, apre la strada a un eventuale merge
  selettivo in futuro. **Contro**: va scritto e mantenuto codice di
  serializzazione per ~10 collection "vere" (esclusi cataloghi), e soprattutto
  vanno **rimappati gli id auto-increment** nelle relazioni tra collection
  (es. `WorkoutTemplateExercise`→`WorkoutTemplate`, `PlanFood.foodItemId`→
  `FoodItem`, `WorkoutExercise.sourceProgramId`→`WorkoutProgram`) perché su un
  Isar vuoto gli id ripartono da 1 e non coincidono più con quelli del
  backup — lavoro via via più delicato quanto più le relazioni sono
  interconnesse.

**Dipendenze da aggiungere**: `share_plus` (condivisione file) e
`file_picker` (selezione file in import). Nessun permesso runtime speciale
richiesto su Android/iOS moderni (SAF / document picker sandboxato).

### B. Sync cloud con account (Firebase/Supabase/backend proprio)

Permetterebbe sync continuo multi-dispositivo, non solo migrazione una
tantum. Ma è un investimento enormemente più grande: account/login, hosting,
logica di sync con risoluzione conflitti, e soprattutto **un cambio di
postura sulla privacy** — oggi i dati (alimentazione, peso, misure corporee)
non lasciano mai il dispositivo; con un backend smetterebbero di essere
strettamente locali, con implicazioni su normativa (GDPR/dati sanitari) da
valutare seriamente. Sproporzionato rispetto al problema posto ("cambiare
telefono ogni tanto").

### C. Rafforzare solo il backup di sistema (Android/iOS)

Costo quasi nullo (dichiarare esplicitamente `allowBackup`/regole di backup
su Android, nessuna esclusione da fare su iOS dato che è già incluso di
default). Utile come rete di sicurezza aggiuntiva e gratuita, ma **non
risolve il problema posto**: resta inaffidabile su Android, funziona su iOS
solo nel flusso di ripristino completo del device, e non copre mai il
cambio di piattaforma. Non sostituisce A, al massimo la completa.

---

## Raccomandazione

**Opzione A, variante A1 (copia del file Isar)** come prima versione:
risolve esattamente il caso d'uso descritto (qualunque combinazione di
piattaforme, nessuna dipendenza da cloud/account, coerente con la filosofia
"tutto locale" già scelta per il resto dell'app), con il minor rischio
tecnico e il minor sforzo di implementazione. A2 (export JSON selettivo)
resta un'evoluzione sensata più avanti, se emergesse il bisogno di file più
piccoli o di un import "parziale/merge" invece che sostitutivo.

---

## Domande aperte (da chiarire prima di implementare)

1. Il file di backup deve essere **cifrato** (es. con una passphrase scelta
   dall'utente) dato che contiene dati sanitari/corporei? O è accettabile un
   file in chiaro, dato che comunque il canale di trasferimento lo sceglie
   l'utente stesso (Drive/iCloud privati, AirDrop diretto, ecc.)?
2. Va **esclusa dal backup** l'anagrafica rigenerabile (`ExerciseDefinition`
   non custom, `FoodItem` non custom del dataset CREA) per tenere il file più
   piccolo, o si preferisce la semplicità di A1 (tutto il file così com'è)?
3. Il flusso di import deve essere raggiungibile **solo su un'app "vuota"**
   (primo avvio, nessun dato reale ancora presente) o deve essere permesso
   anche su un'app già in uso, con un avviso chiaro che sovrascrive tutto
   l'esistente?
4. Serve un **promemoria periodico** ("non fai un backup da X mesi") o basta
   un'azione manuale raggiungibile dalle Impostazioni?

## Fasi

### Fase 1 — Export/import backup locale ✅ completata
- [x] Dipendenze `share_plus`/`file_picker` (con `dependency_overrides: win32`
      per risolvere un conflitto di versione tra i due, irrilevante dato che
      il progetto non include il target Windows)
- [x] `DatabaseService.exportBackup()` — `Isar.copyToFile()` verso una copia
      compattata in `getTemporaryDirectory()`, nome `plico_backup_<data>.isar`
- [x] `DatabaseService.validateBackupFile()` — apre il file scelto in
      un'istanza Isar temporanea isolata prima di toccare quella reale
- [x] `DatabaseService.importBackup()` — chiude l'istanza reale, tiene una
      copia di sicurezza (`default.isar.bak`) del file attuale, sostituisce e
      riapre; ripristina il `.bak` se la riapertura fallisce
- [x] `lib/screens/impostazioni/backup_screen.dart`: sezione Esporta (foglio
      di condivisione nativo) e sezione Importa (file picker, dialog di
      conferma esplicito e distruttivo, `runImportBackupFlow` riusabile)
- [x] Dopo un import riuscito: rieseguite le funzioni di seed/migrazione
      idempotenti già esistenti (`seedCreaFoods`, `migrateFoodNamesV2`,
      `seedExercises`, `seedWorkoutPresets`) per allineare un backup di una
      versione più vecchia dell'app, poi restart della navigazione verso
      `MainScreen` (le `watch()` già sottoscritte punterebbero all'istanza
      Isar appena chiusa)

### Fase 2 — Punti di ingresso ✅ completata
- [x] Nuovo hub `lib/screens/impostazioni/impostazioni_screen.dart`
      (Notifiche + Backup dati); l'icona in `home_screen.dart` passa da
      "notifiche dirette" a "impostazioni" per aprirlo
- [x] `lib/screens/onboarding/welcome_screen.dart`: primo schermo al posto
      di `OnboardingScreen` diretto, con scelta "Inizia da zero" (→
      `OnboardingScreen`, invariato) o "Ho già usato Plico" (step che spiega
      la procedura, poi stesso `runImportBackupFlow` di `BackupScreen`)
- [x] `main.dart` aggiornato di conseguenza (`WelcomeScreen` al posto di
      `OnboardingScreen` nel `FutureBuilder` iniziale)

### Fase 3 — Verifica
- [x] `flutter analyze` pulito, `flutter test` (148 test) verde
- [ ] Test manuale end-to-end su device reali (export da un device, import
      su un secondo device — idealmente di piattaforma diversa): da fare
      dall'utente, non eseguibile in questo ambiente
- [ ] Marker di versione/compatibilità esplicito nel file di backup (oggi la
      compatibilità è garantita solo dalla riesecuzione delle migrazioni
      idempotenti post-import, non da un controllo di versione dichiarato)
- [ ] Aggiornare `docs/database.md`/`docs/retention.md` con la nuova
      funzionalità
