# Piano di test automatici

Checklist di tutto ciò che vale la pena testare in `lib/services/`, organizzato a blocchi
per dipendenza (logica pura → Isar → bug noti → platform/rete). Si spunta una voce solo
quando il test è scritto **e passa**. Aggiornare questo file ad ogni blocco completato.

## Blocco 1 — Logica pura (nessuna dipendenza Isar/rete/platform)

- [x] `CalorieEstimationService` — `test/calorie_estimation_service_test.dart`
- [x] `GuidedSessionService` — `test/guided_session_service_test.dart`
- [x] `WorkoutProgressService` — `test/workout_progress_service_test.dart`
- [x] `ExerciseAlternativesService.rank` — `test/exercise_alternatives_service_test.dart`
- [x] `PlicometryCalculator` — `test/plicometry_calculator_test.dart`
- [x] `PianoService.excludedByRestrizioni` — `test/piano_service_restrizioni_test.dart`

## Blocco 2 — Servizi con dipendenza Isar (richiedono `DatabaseService.initForTest`,
stesso pattern di `piano_service_test.dart`)

- [x] `DatabaseService` — `test/database_service_workout_test.dart` (`startWorkoutFromTemplate`,
      `addWorkoutExercise`, `addSessionDuration` cumulativo, `getWorkoutLabelsForRange`,
      `duplicateTemplate`/`duplicateProgram`, `deleteWorkoutLog`, `getNextDayForProgram`)
- [x] `TargetService.computeDailyTargets` — `test/target_service_test.dart`
- [x] `MealTimingService.suggestedTime` — `test/meal_timing_service_test.dart`
- [x] `TdeeCalibrationService.suggestion` — `test/tdee_calibration_service_test.dart`
- [x] `InsightsService.generate` — `test/insights_service_test.dart`
- [x] `StreakService` — `test/streak_service_test.dart`
- [x] `AchievementService` — `test/achievement_service_test.dart` (`checkAll` e le singole
      soglie, indirettamente tramite gli achievement sbloccati)

## Blocco 3 — Bug pre-esistente scoperto durante il Blocco 1

- [x] Investigato e corretto: **non era un bug dell'app**, ma un fixture di test
      obsoleto. `PianoService.curatedNames` (e le altre liste curate) erano già stati
      aggiornati ai nomi normalizzati (`docs/normalizzazione_nomi_alimenti.md`, es.
      "Petto di pollo" al posto di "Pollo, petto, crudo"), ma `_testFoods` in
      `piano_service_test.dart` usava ancora i vecchi nomi CREA verbosi — quasi nessun
      alimento del test combaciava più con le liste curate (specialmente proteine
      animali e grassi, pool quasi vuoti), da cui il crollo di kcal/proteine/grassi nel
      piano generato. Aggiornati i nomi in `_testFoods` per allinearli a
      `curatedNames`/`curated*Colazione`; tutti e 5 i test ora passano.

## Blocco 4 — Platform/IO (bassa priorità, valutare caso per caso)

Non pianificati ora: dipendono da platform channel o rete, il valore di un unit test è
basso senza mock robusti. Da rivalutare solo se emergono bug specifici.

- [ ] `NotificationService` — platform channel `flutter_local_notifications`
- [ ] `PdfExportService` — genera bytes PDF, platform channel `printing`
- [ ] `WidgetService` — platform channel `home_widget`
- [ ] `OpenFoodFactsService` — chiamata HTTP esterna (Open Food Facts API)
