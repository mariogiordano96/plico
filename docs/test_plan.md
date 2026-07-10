# Piano di test automatici

Checklist di tutto ciò che vale la pena testare in `lib/services/`, organizzato a blocchi
per dipendenza (logica pura → Isar → bug noti → platform/rete). Si spunta una voce solo
quando il test è scritto **e passa**. Aggiornare questo file ad ogni blocco completato.

## Blocco 1 — Logica pura (nessuna dipendenza Isar/rete/platform)

- [x] `CalorieEstimationService` — `test/calorie_estimation_service_test.dart`
- [x] `GuidedSessionService` — `test/guided_session_service_test.dart`
- [x] `WorkoutProgressService` — `test/workout_progress_service_test.dart`
- [ ] `ExerciseAlternativesService.rank` — ranking sostituzione esercizio (stesso
      `muscleGroup`, punteggio per `mechanic`/`equipment` in comune)
- [ ] `PlicometryCalculator` — 5 metodi (Durnin-Womersley, Jackson-Pollock 3/7, Faulkner,
      US Navy) + `categoria()` per uomo/donna
- [ ] `PianoService.excludedByRestrizioni` — filtro alimenti per restrizioni (unica funzione
      pura non ancora coperta; `calcolaTdee`/macro math già testati in
      `piano_service_test.dart`)

## Blocco 2 — Servizi con dipendenza Isar (richiedono `DatabaseService.initForTest`,
stesso pattern di `piano_service_test.dart`)

- [ ] `DatabaseService` — metodi core allenamento: `startWorkoutFromTemplate`,
      `addWorkoutExercise`, `addSessionDuration` (cumulativo), `getWorkoutLabelsForRange`,
      `duplicateTemplate`/`duplicateProgram`, `deleteWorkoutLog`, `getNextDayForProgram`
- [ ] `TargetService.computeDailyTargets` — null se profilo/peso mancanti, calcolo
      kcal/macro altrimenti
- [ ] `MealTimingService.suggestedTime` — null sotto la soglia campioni, media orari
      altrimenti
- [ ] `TdeeCalibrationService.suggestion` — null nei vari casi di guardia (pochi snapshot,
      pochi giorni loggati, differenza sotto soglia), suggerimento altrimenti
- [ ] `InsightsService.generate` — overshoot insight (giorno della settimana ricorrente) e
      protein insight (proteine sotto target)
- [ ] `StreakService` — `currentStreak`/`currentWorkoutStreak` (giorni consecutivi da oggi
      o ieri a ritroso)
- [ ] `AchievementService` — `checkAll` e le singole soglie (`_checkFirstKgLost`,
      `_checkStreak7`, `_checkDays30Logged`, `_checkWeekOnTarget`, `_checkFirstWorkout`,
      `_checkWorkoutStreak7`, `_checkWorkoutSessions`) indirettamente tramite gli
      achievement sbloccati

## Blocco 3 — Bug pre-esistente scoperto durante il Blocco 1

- [ ] Investigare e correggere i 5 test falliti in `piano_service_test.dart`
      (`generaPiano integration`): kcal del piano molto lontane dal target
      (es. atteso ~2711, ottenuto 1228) — sospetta regressione dalla normalizzazione/
      localizzazione dei nomi alimenti (commit `e44e1d1`/`bfeed58`)

## Blocco 4 — Platform/IO (bassa priorità, valutare caso per caso)

Non pianificati ora: dipendono da platform channel o rete, il valore di un unit test è
basso senza mock robusti. Da rivalutare solo se emergono bug specifici.

- [ ] `NotificationService` — platform channel `flutter_local_notifications`
- [ ] `PdfExportService` — genera bytes PDF, platform channel `printing`
- [ ] `WidgetService` — platform channel `home_widget`
- [ ] `OpenFoodFactsService` — chiamata HTTP esterna (Open Food Facts API)
