# Test E2E — Piano di Automazione con Patrol

> Obiettivo: automatizzare i flussi utente end-to-end (avvio app reale su
> device/emulatore, interazione con la UI, verifica del risultato) per i percorsi
> critici, a complemento della copertura unitaria già pianificata in
> `docs/test_plan.md` (che copre `lib/services/` in isolamento, senza UI). Scope di
> questa prima fase: **solo locale** (nessun job CI per ora) e **due flussi**:
> Onboarding e Diario (aggiunta alimento, incluso scan barcode).

---

## 1. Stato attuale

- Nessuna infrastruttura E2E: non esiste una cartella `integration_test/`, nessuna
  dipendenza `patrol`/`integration_test` in `pubspec.yaml`.
- `test/` contiene solo unit test (VM, `flutter_test`), coperti in
  `docs/test_plan.md`. `test/widget_test.dart` è un placeholder (`expect(true,
  isTrue)`), nessun precedente di "pump dell'app reale" da riusare.
- I due workflow CI (`release-android.yml`, `release-ios.yml`) fanno solo
  build/release, nessuno step di test.
- **Nessun widget interattivo ha una `Key`** nei flussi Onboarding
  (`welcome_screen.dart`, `onboarding_screen.dart`) e Diario/aggiunta-alimento
  (`aggiunta_alimento_screen.dart`, `barcode_scanner_screen.dart`), a parte un
  `ValueKey` dinamico in `diario_screen.dart:698` pensato per l'identità di lista,
  non riusabile come finder di test.

## 2. Scelte fatte

- **Patrol** invece del solo `integration_test`: l'app richiede il permesso
  fotocamera a runtime per lo scanner barcode
  (`barcode_scanner_screen.dart:27-32`, via `permission_handler`) — un dialog di
  sistema nativo che `integration_test` puro non sa gestire, mentre il
  `NativeAutomator` di Patrol sì. Le notifiche non richiedono questa gestione nei
  due flussi in scope (la richiesta esplicita vive solo in
  `impostazioni/notifiche_screen.dart`, fuori scope).
- **Scope iniziale**: Onboarding (primo avvio → profilo creato) e Diario → aggiunta
  alimento (ricerca locale + scan barcode). Sono i due percorsi che ogni utente
  attraversa sempre, e i più stabili dopo lo snellimento UI recente.
- **Solo locale per ora**: niente job GitHub Actions con emulatore in questa fase.
  Da valutare in un secondo momento, quando i flussi locali sono stabili — coerente
  con la spinta verso più automazione CI/CD già in corso sul progetto, ma senza
  aggiungere un altro fronte instabile mentre l'infrastruttura E2E è ancora nuova.

## 3. Nodi tecnici da risolvere prima di scrivere i test

### 3.1 Avviare l'app con un DB pulito

`main.dart` (righe 34-75) chiama `DatabaseService.instance.init()`, che apre Isar
nella vera documents directory del device (`database_service.dart:56`), poi — solo
in `kDebugMode` — esegue `seedTestUserProfileIfMissing()` e
`seedTestTemplateTecniche()`. Se un test Patrol gira in debug (il default), questo
seed crea un profilo utente fittizio: `PlicoApp` (righe 150-195) controlla
`hasUserProfile()` per decidere se mostrare `WelcomeScreen` o `MainScreen`, quindi
il test dell'Onboarding **salterebbe direttamente alla Home**.

Esiste già un pattern di DB isolato,
`DatabaseService.instance.initForTest(directory)` (`database_service.dart:60-62`),
usato in 8 unit test file (es. `test/piano_service_test.dart:269-280`), ma è
pensato per la VM Dart (`Isar.initializeIsarCore(download: true)` scarica la
libreria nativa per l'host) — su device/emulatore reale la libreria nativa è già
inclusa via `isar_flutter_libs`, quindi non va scaricata, ma il concetto di
"directory dedicata e pulita ad ogni run" resta valido e va riadattato.

**Proposta**: un flag `--dart-define=PLICO_E2E=true`, letto in `main.dart`, che:

1. apre Isar in una directory temporanea dedicata (`path_provider`'s
   `getTemporaryDirectory()` + sottocartella univoca, es. col timestamp) invece
   della documents directory reale, così ogni run parte da zero;
2. salta `seedTestUserProfileIfMissing()`/`seedTestTemplateTecniche()` anche in
   debug, mantenendo invece i seed di catalogo idempotenti (alimenti, esercizi)
   necessari per una ricerca realistica nel test del Diario.

### 3.2 Key mancanti sui widget

Nessun bottone, campo o riga selezionabile ha una `Key` nei due flussi in scope.
I finder di Patrol andrebbero appoggiati a `find.text(...)` (fragile: dipende
dalla lingua attiva) o `find.byType(...).at(n)` (fragile: dipende dall'ordine).
**Vanno aggiunte `Key` esplicite e stabili** ai widget effettivamente toccati dai
test — solo quelli nei due flussi in scope, non un audit di tutta l'app in una
volta.

### 3.3 Permesso fotocamera nello scan barcode

`barcode_scanner_screen.dart:27-32` controlla `Permission.camera.status` e, se
negato, chiama `.request()`: il punto esatto in cui compare il dialog di sistema.
Il test che copre lo scan deve gestirlo esplicitamente con il `NativeAutomator` di
Patrol (concessione permesso Android/iOS).

## 4. Pacchetti da aggiungere

| Pacchetto | Uso | Note |
|---|---|---|
| `patrol` | Framework E2E, estende `integration_test` | Introduce dipendenza da `patrol_cli` per lanciare i test (`dart pub global activate patrol_cli`) |
| `integration_test` (SDK) | Base su cui Patrol si appoggia | Già incluso in Flutter SDK, va solo dichiarato in `dev_dependencies` |

Nessun altro pacchetto necessario per lo scope attuale (niente mock HTTP: la
ricerca locale/piano non richiede rete, e il test dello scan si ferma alla
concessione del permesso — vedi §6).

## 5. Piano a fasi

- [ ] **Fase 1 — Setup infrastruttura**: aggiungere `patrol`/`integration_test` a
      `pubspec.yaml`, creare `patrol.yaml` e la cartella `integration_test/`,
      implementare il flag `PLICO_E2E` in `main.dart` (DB temporaneo + skip seed
      profilo di test). Verifica di uscita: `patrol test` lancia l'app su
      emulatore/device e mostra `WelcomeScreen` (non la Home).
- [ ] **Fase 2 — Key su Onboarding**: aggiungere `Key` a `_ChoiceCard` in
      `welcome_screen.dart` e ai campi/bottoni di `_Step1`..`_Step4`,
      `_StepObiettivo`, `_StepAttivita` in `onboarding_screen.dart`.
- [ ] **Fase 3 — Test E2E Onboarding**: happy path completo — "Nuovo" → nome/cognome
      → sesso + data di nascita → altezza/peso/body fat → obiettivo → livello
      attività → tema → "Inizia" — verifica di atterrare su `MainScreen`/Home con
      profilo salvato (query diretta a `DatabaseService` a fine test).
- [ ] **Fase 4 — Key su Diario/aggiunta alimento**: campo ricerca, righe risultato
      (locale/piano/combo/OFF), bottone scan, campo quantità, bottoni
      salva/aggiungi in `aggiunta_alimento_screen.dart` e
      `barcode_scanner_screen.dart`.
- [ ] **Fase 5 — Test E2E Diario (ricerca locale)**: apri Diario → aggiungi pasto →
      cerca un alimento seedato → seleziona → imposta quantità → salva → verifica
      che l'entry compaia nella lista del giorno e nei totali kcal/macro.
- [ ] **Fase 6 — Test E2E Diario (permesso scan)**: apri lo scanner → gestisci il
      dialog di sistema con `NativeAutomator` (concessione) → verifica che la
      camera si attivi. Il detection di un barcode reale resta fuori da questa
      fase (vedi §6).
- [ ] **Fase 7 (futura, fuori scope ora) — CI**: job GitHub Actions con
      `android-emulator-runner` per eseguire le Fasi 1-6 in automatico ad ogni PR;
      da avviare solo dopo che i flussi locali sono stabili, per non aggiungere
      un altro fronte instabile mentre l'infrastruttura E2E è nuova.

## 6. Limiti noti

- **Scan barcode reale**: iniettare un'immagine/feed video con un barcode valido
  davanti alla fotocamera di un emulatore non è supportato nativamente né da
  Patrol né da `mobile_scanner`. La Fase 6 copre solo l'apertura dello scanner e
  la gestione del permesso; il detection e il salvataggio dati OFF restano
  verificati manualmente, salvo introdurre in futuro un mock del livello
  `OpenFoodFactsService`/`MobileScannerController` per simulare una detection.
- **iOS**: Patrol supporta iOS, ma richiede un simulatore configurato. Il piano
  parte da Android; l'estensione a iOS è una fase successiva separata, da valutare
  solo se i test Android si dimostrano stabili e utili nel tempo.

---

Ogni fase è indipendente e va in commit + push separato a fase completata, come da
convenzione già in uso per i piani a fasi di questo progetto.
