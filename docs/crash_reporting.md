# Crash Reporting (Firebase Crashlytics) — Piano a fasi

> Obiettivo: vedere i crash e gli errori non gestiti delle app in produzione su iOS e
> Android, con stack trace leggibili, senza compromettere la postura privacy-first di Plico.
> Motivazione: i crash visti finora erano tutti **release-only** (R8/WorkManager, ML Kit
> camera — vedi memoria progetto), invisibili in debug. Le console degli store mostrano
> solo crash/ANR di base, senza contesto.

Stato: **PIANIFICATO** — nessuna fase iniziata.

---

## 1. Scelta del servizio

| Opzione | Costo | Pro | Contro |
|---|---|---|---|
| **Firebase Crashlytics** | Gratuito, senza limiti sui crash | Standard per Flutter, crash nativi + Dart, mappatura R8 e dSYM, filtri per versione | Dati verso Google; serve progetto Firebase e file di config |
| Sentry | Piano gratuito con quota eventi | Scrubbing dati sensibile prima dell'invio, self-hosting possibile | Quota limitata; altro account da gestire |
| Solo console store | Incluso | Nessuna integrazione | Solo crash/ANR di base, niente contesto né errori Dart |

**Scelta: Crashlytics.** Prezzi e quote da riverificare al momento dell'attivazione.

## 2. Decisione privacy (da prendere PRIMA della Fase 1)

Oggi Plico non invia nulla fuori dal dispositivo. Crashlytics invia a Google dati tecnici
(modello device, OS, stack trace, identificativo di installazione).

- **Opzione A — opt-in esplicito** (consigliata): toggle in Impostazioni, **disattivato di
  default**, con spiegazione. Coerente con "privacy-first". Contro: meno copertura (solo chi
  accetta).
- **Opzione B — sempre attivo**: massima copertura, ma richiede dichiarazione più pesante e
  cambia la promessa dell'app.

In entrambi i casi: **mai** dati di salute, alimentari o misure nei log, nei messaggi di
eccezione o nelle custom key.

Scelta: _da confermare_ (default proposto: A).

---

## 3. Fasi

### Fase 1 — Progetto Firebase e config piattaforma (manuale, fuori dal codice)
- [ ] Creare progetto Firebase; registrare app Android (`com.maxio96.plico`) e iOS
      (`com.maxio96.plico`)
- [ ] Scaricare `google-services.json` e `GoogleService-Info.plist`
- [ ] Verificare che il widget iOS (`PlicoWidgetExtension`) **non** riceva Crashlytics:
      solo il target Runner
- [ ] Decidere A/B della sezione 2

### Fase 2 — Integrazione Android
- [ ] Aggiungere `firebase_core` e `firebase_crashlytics` a `pubspec.yaml`
- [ ] Plugin Gradle `com.google.gms.google-services` e `com.google.firebase.crashlytics`
      in `android/settings.gradle.kts` / `android/app/build.gradle.kts`
- [ ] Posizionare `google-services.json` in `android/app/`
- [ ] **Rischio noto**: AGP 9.0.1 / builtInKotlin può rompere la build con plugin che hanno
      sorgenti Kotlin (vedi memoria gotcha AGP9). Se la build rompe, provare prima versioni
      alternative dei plugin Firebase, non toccare i flag Gradle
- [ ] Verificare che il mapping R8 venga caricato (task Crashlytics in release) e non
      confligga con `proguard-rules.pro`
- [ ] Build release locale + crash di test su device fisico

### Fase 3 — Integrazione iOS
- [ ] Posizionare `GoogleService-Info.plist` nel target Runner
- [ ] `pod install` con il deployment target 16.0 già richiesto dal Podfile
- [ ] Aggiungere la Run Script phase per l'upload dei dSYM (`DEBUG_INFORMATION_FORMAT =
      dwarf-with-dsym` è già impostato nelle configurazioni Release/Profile)
- [ ] Verificare l'archivio con `flutter build ipa` e che i dSYM arrivino a Crashlytics
- [ ] Crash di test su device fisico, controllo simbolicazione

### Fase 4 — Codice Dart e consenso
- [ ] Inizializzazione in `lib/main.dart`: `Firebase.initializeApp()`,
      `FlutterError.onError` → `recordFlutterFatalError`,
      `PlatformDispatcher.instance.onError` → `recordError(fatal: true)`
- [ ] `setCrashlyticsCollectionEnabled(false)` di default; abilitare solo con il consenso
      (se Opzione A) — flag persistito in `app_settings.dart` (+ rigenerare `.g.dart`)
- [ ] Toggle in Impostazioni con testo esplicativo (l10n it/en, vedi
      `internazionalizzazione.md`)
- [ ] Disabilitare la raccolta in debug (`kDebugMode`)
- [ ] Review: nessun dato personale in eccezioni, `debugPrint`, custom key

### Fase 5 — CI/CD
- [ ] Secret di repo per i due file di config (base64), come per le altre credenziali
- [ ] `release-android.yml`: scrivere `google-services.json` prima della build
- [ ] `release-ios.yml`: scrivere `GoogleService-Info.plist`; verificare che l'upload dei
      dSYM giri anche nella build `flutter build ipa` del runner
- [ ] I file di config **non** vanno nel repo (aggiungere a `.gitignore`)
- [ ] Rilascio di prova su internal/TestFlight

### Fase 6 — Dichiarazioni store e privacy policy
- [ ] **Play Console → Sicurezza dei dati**: dichiarare crash log e diagnostica, identificativi
      del dispositivo (finalità: analisi/stabilità app)
- [ ] **App Store Connect → Privacy dell'app**: dati di diagnostica (Crash Data, Performance
      Data), non collegati all'identità, non usati per tracking
- [ ] Aggiornare `docs/privacy-policy/index.html` e il repo `plico_privacy`
- [ ] Se Opzione A: descrivere il toggle e che è disattivato di default

### Fase 7 — Verifica in produzione
- [ ] Crash forzato in build release su entrambe le piattaforme e verifica nella dashboard
      (stack trace leggibili: R8 su Android, dSYM su iOS)
- [ ] Impostare avvisi su nuovi crash/regressioni
- [ ] Documentare in questo file i risultati e i limiti emersi

---

## 4. Rischi e note

- **Compatibilità AGP 9 / Kotlin**: fase 2 è quella più a rischio (vedi sopra).
- **Simboli iOS**: senza dSYM gli stack trace sono illeggibili; fase 3 e 7 lo verificano.
- **Ordine consigliato**: fare questo lavoro **dopo** che le release 1.0.5 sono pubblicate e
  stabili, non nello stesso ciclo, per non sovrapporre errori di firma/dichiarazioni store
  e errori di integrazione.
- **Costo**: nessuno atteso al volume attuale (13 tester); rivalutare in produzione.
