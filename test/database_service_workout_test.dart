import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:plico/models/workout_exercise.dart';
import 'package:plico/models/workout_program.dart';
import 'package:plico/models/workout_set.dart';
import 'package:plico/models/workout_template.dart';
import 'package:plico/models/workout_template_exercise.dart';
import 'package:plico/services/database_service.dart';

/// Simula il flusso "esercizio libero" (`AllenamentoScreen._aggiungiEsercizio`):
/// un WorkoutExercise creato a mano, senza scheda di provenienza.
Future<WorkoutExercise> _addFreeExercise(DateTime day) async {
  final we = WorkoutExercise()
    ..exerciseId = 'free'
    ..exerciseName = 'Esercizio libero'
    ..sets = [WorkoutSet()];
  await DatabaseService.instance.addWorkoutExercise(day, we);
  return we;
}

WorkoutTemplateExercise _templateExercise({
  required String id,
  int? targetSets,
  int? targetReps,
  double? targetWeightKg,
}) {
  return WorkoutTemplateExercise()
    ..exerciseId = id
    ..exerciseName = id
    ..targetSets = targetSets
    ..targetReps = targetReps
    ..targetWeightKg = targetWeightKg;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('plico_workout_test_');
    await DatabaseService.instance.initForTest(tempDir.path);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    tempDir.deleteSync(recursive: true);
  });

  group('startWorkoutFromTemplate', () {
    test('crea un WorkoutExercise per esercizio, con serie pre-compilate dai target', () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..exercises = [
          _templateExercise(id: 'bench', targetSets: 3, targetReps: 8, targetWeightKg: 80),
        ];
      final id = await db.saveWorkoutTemplate(template);
      template.id = id;

      final day = DateTime(2026, 1, 10);
      final created = await db.startWorkoutFromTemplate(template, day);

      expect(created, hasLength(1));
      final we = created.first;
      expect(we.exerciseId, 'bench');
      expect(we.date, DateTime(2026, 1, 10));
      expect(we.sets, hasLength(3));
      expect(we.sets.every((s) => s.reps == 8 && s.weightKg == 80), isTrue);
      expect(we.sets.every((s) => !s.confirmed), isTrue);
      expect(we.sourceTemplateId, id);
      expect(we.sourceTemplateName, 'Push Day');
      expect(we.sourceProgramId, isNull);
    });

    test('valorizza sourceProgramId/Name quando la scheda appartiene a un programma', () async {
      final db = DatabaseService.instance;
      final program = WorkoutProgram()..name = 'Upper/Lower'..createdAt = DateTime.now();
      final programId = await db.saveWorkoutProgram(program);

      final template = WorkoutTemplate()
        ..name = 'Upper 1'
        ..createdAt = DateTime.now()
        ..programId = programId
        ..exercises = [_templateExercise(id: 'row', targetSets: 3, targetReps: 10)];
      final templateId = await db.saveWorkoutTemplate(template);
      template.id = templateId;

      final created = await db.startWorkoutFromTemplate(template, DateTime(2026, 1, 10));

      expect(created.first.sourceProgramId, programId);
      expect(created.first.sourceProgramName, 'Upper/Lower');
    });

    test('aggiorna lastUsedAt della scheda alla data del log', () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..exercises = [_templateExercise(id: 'bench', targetSets: 1, targetReps: 5)];
      final id = await db.saveWorkoutTemplate(template);
      template.id = id;

      final day = DateTime(2026, 2, 1);
      await db.startWorkoutFromTemplate(template, day);

      final standalone = await db.getStandaloneTemplates();
      final reloaded = standalone.firstWhere((t) => t.id == id);
      expect(reloaded.lastUsedAt, day);
    });

    test('Fase 7: plannedSets riproduce reps/peso/tecnica per-serie invece del target uniforme',
        () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..exercises = [
          WorkoutTemplateExercise()
            ..exerciseId = 'bench'
            ..exerciseName = 'bench'
            // Target uniforme presente ma ignorato: plannedSets ha priorità.
            ..targetSets = 1
            ..targetReps = 99
            ..plannedSets = [
              WorkoutTemplateSet()
                ..reps = 12
                ..weightKg = 40,
              WorkoutTemplateSet()
                ..reps = 8
                ..weightKg = 50
                ..restPauseClusters = [8, 4, 3],
            ],
        ];
      final id = await db.saveWorkoutTemplate(template);
      template.id = id;

      final created = await db.startWorkoutFromTemplate(template, DateTime(2026, 1, 10));

      final sets = created.first.sets;
      expect(sets, hasLength(2));
      expect(sets[0].reps, 12);
      expect(sets[0].weightKg, 40);
      expect(sets[0].technique, SetTechnique.normale);
      expect(sets[1].restPauseClusters, [8, 4, 3]);
      expect(sets[1].technique, SetTechnique.restPause);
    });

    test('esercizio cardio (targetDurationSeconds) non genera serie', () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Cardio'
        ..createdAt = DateTime.now()
        ..exercises = [
          WorkoutTemplateExercise()
            ..exerciseId = 'run'
            ..exerciseName = 'Corsa'
            ..targetDurationSeconds = 1800,
        ];
      await db.saveWorkoutTemplate(template);
      final created = await db.startWorkoutFromTemplate(template, DateTime(2026, 1, 1));
      expect(created.first.sets, isEmpty);
      expect(created.first.durationSeconds, 1800);
    });

    test(
        'seconda chiamata lo stesso giorno riprende gli esercizi già creati invece di duplicarli',
        () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Giorno1'
        ..createdAt = DateTime.now()
        ..exercises = [
          _templateExercise(id: 'bench', targetSets: 3, targetReps: 8, targetWeightKg: 80),
        ];
      await db.saveWorkoutTemplate(template);
      final day = DateTime(2026, 1, 10);

      final first = await db.startWorkoutFromTemplate(template, day);
      // Conferma tutte le serie, come farebbe la sessione guidata prima di
      // "Termina sessione".
      for (final s in first.first.sets) {
        s.confirmed = true;
      }
      await db.updateWorkoutExercise(first.first);

      // Premere di nuovo "Inizia" sulla stessa scheda lo stesso giorno (es.
      // dopo che l'app è stata riaperta da background) non deve creare un
      // secondo giro di esercizi azzerati.
      final second = await db.startWorkoutFromTemplate(template, day);

      final logged = await db.getWorkoutExercisesForDay(day);
      expect(logged, hasLength(1));
      expect(second, hasLength(1));
      expect(second.first.id, first.first.id);
      expect(second.first.sets.every((s) => s.confirmed), isTrue);
    });
  });

  group('addWorkoutExercise / getWorkoutExercisesForDay', () {
    test('crea il WorkoutLog del giorno se assente e persiste l\'esercizio', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 3, 1);
      expect(await db.getWorkoutLog(day), isNull);

      final we = await _addFreeExercise(day);
      final exercises = await db.getWorkoutExercisesForDay(day);
      expect(exercises, hasLength(1));
      expect(exercises.first.exerciseId, we.exerciseId);
      expect(await db.getWorkoutLog(day), isNotNull);
    });
  });

  group('addSessionDuration', () {
    test('più chiamate lo stesso giorno si sommano invece di sovrascriversi', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 4, 1);
      await db.addSessionDuration(day, 120);
      await db.addSessionDuration(day, 30);
      final log = await db.getWorkoutLog(day);
      expect(log!.totalDurationSeconds, 150);
    });

    test('secondi zero o negativi non vengono sommati', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 4, 2);
      await db.addSessionDuration(day, 0);
      expect(await db.getWorkoutLog(day), isNull);
    });

    test('azzera il checkpoint pendente quando la sessione viene chiusa', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 4, 3);
      await db.saveSessionCheckpoint(day, 90);
      expect(await db.getPendingSessionSeconds(day), 90);

      await db.addSessionDuration(day, 90);
      expect(await db.getPendingSessionSeconds(day), 0);
      final log = await db.getWorkoutLog(day);
      expect(log!.totalDurationSeconds, 90);
    });
  });

  group('saveSessionCheckpoint / getPendingSessionSeconds', () {
    test('il checkpoint più recente sovrascrive quello precedente (non si somma)', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 4, 4);
      await db.saveSessionCheckpoint(day, 30);
      await db.saveSessionCheckpoint(day, 45);
      expect(await db.getPendingSessionSeconds(day), 45);
    });

    test('nessun checkpoint salvato restituisce zero', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 4, 5);
      expect(await db.getPendingSessionSeconds(day), 0);
    });
  });

  group('getWorkoutLabelsForRange', () {
    test('etichetta i giorni con il nome della scheda, vuota per i giorni liberi', () async {
      final db = DatabaseService.instance;
      final template = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..exercises = [_templateExercise(id: 'bench', targetSets: 1, targetReps: 5)];
      await db.saveWorkoutTemplate(template);

      final schedaDay = DateTime(2026, 5, 1);
      final liberoDay = DateTime(2026, 5, 2);
      await db.startWorkoutFromTemplate(template, schedaDay);
      await _addFreeExercise(liberoDay);

      final labels =
          await db.getWorkoutLabelsForRange(DateTime(2026, 5, 1), DateTime(2026, 5, 3));

      expect(labels[schedaDay], ['Push Day']);
      expect(labels[liberoDay], isEmpty);
      expect(labels.containsKey(DateTime(2026, 5, 3)), isFalse);
    });
  });

  group('duplicateTemplate / duplicateProgram', () {
    test('duplicateTemplate copia gli esercizi e rispetta l\'order esplicito', () async {
      final db = DatabaseService.instance;
      final original = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..order = 0
        ..exercises = [_templateExercise(id: 'bench', targetSets: 3, targetReps: 8)];
      await db.saveWorkoutTemplate(original);

      final copy = await db.duplicateTemplate(original, programId: 42, order: 5);

      expect(copy.id, isNot(original.id));
      expect(copy.programId, 42);
      expect(copy.order, 5);
      expect(copy.exercises, hasLength(1));
      expect(copy.exercises.first.exerciseId, 'bench');
      expect(copy.isPreset, isFalse);
    });

    test('duplicateTemplate copia plannedSets senza condividere le liste embedded con l\'originale',
        () async {
      final db = DatabaseService.instance;
      final original = WorkoutTemplate()
        ..name = 'Push Day'
        ..createdAt = DateTime.now()
        ..exercises = [
          WorkoutTemplateExercise()
            ..exerciseId = 'bench'
            ..exerciseName = 'bench'
            ..plannedSets = [
              WorkoutTemplateSet()
                ..reps = 12
                ..weightKg = 40
                ..restPauseClusters = [12, 5],
            ],
        ];
      await db.saveWorkoutTemplate(original);

      final copy = await db.duplicateTemplate(original);

      final copiedPlanned = copy.exercises.first.plannedSets!;
      expect(copiedPlanned, hasLength(1));
      expect(copiedPlanned.first.restPauseClusters, [12, 5]);

      // Mutare la copia non deve riflettersi sull'originale in memoria.
      copiedPlanned.first.restPauseClusters!.add(99);
      expect(original.exercises.first.plannedSets!.first.restPauseClusters, [12, 5]);
    });

    test('duplicateProgram copia il programma e tutti i suoi giorni', () async {
      final db = DatabaseService.instance;
      final program = WorkoutProgram()..name = 'Upper/Lower'..createdAt = DateTime.now();
      final programId = await db.saveWorkoutProgram(program);
      program.id = programId;

      final day1 = WorkoutTemplate()
        ..name = 'Upper'
        ..createdAt = DateTime.now()
        ..programId = programId
        ..order = 0
        ..exercises = [_templateExercise(id: 'bench', targetSets: 3, targetReps: 8)];
      final day2 = WorkoutTemplate()
        ..name = 'Lower'
        ..createdAt = DateTime.now()
        ..programId = programId
        ..order = 1
        ..exercises = [_templateExercise(id: 'squat', targetSets: 3, targetReps: 5)];
      await db.saveWorkoutTemplate(day1);
      await db.saveWorkoutTemplate(day2);

      final copy = await db.duplicateProgram(program);
      final copiedDays = await db.getProgramDays(copy.id);

      expect(copy.id, isNot(programId));
      expect(copiedDays, hasLength(2));
      expect(copiedDays.map((d) => d.name), containsAll(['Upper', 'Lower']));
    });
  });

  group('deleteWorkoutLog', () {
    test('rimuove sia gli esercizi sia il log del giorno', () async {
      final db = DatabaseService.instance;
      final day = DateTime(2026, 6, 1);
      await _addFreeExercise(day);
      expect(await db.getWorkoutExercisesForDay(day), isNotEmpty);

      await db.deleteWorkoutLog(day);

      expect(await db.getWorkoutExercisesForDay(day), isEmpty);
      expect(await db.getWorkoutLog(day), isNull);
    });
  });

  group('getNextDayForProgram', () {
    test('sceglie il giorno mai eseguito o con lastUsedAt meno recente', () async {
      final db = DatabaseService.instance;
      final program = WorkoutProgram()..name = 'PPL'..createdAt = DateTime.now();
      final programId = await db.saveWorkoutProgram(program);

      final day1 = WorkoutTemplate()
        ..name = 'Push'
        ..createdAt = DateTime.now()
        ..programId = programId
        ..order = 0
        ..lastUsedAt = DateTime(2026, 1, 10)
        ..exercises = [];
      final day2 = WorkoutTemplate()
        ..name = 'Pull'
        ..createdAt = DateTime.now()
        ..programId = programId
        ..order = 1
        ..exercises = []; // mai eseguito
      await db.saveWorkoutTemplate(day1);
      await db.saveWorkoutTemplate(day2);

      final next = await db.getNextDayForProgram(programId);
      expect(next!.name, 'Pull'); // mai eseguito ha priorità
    });

    test('null se il programma non ha giorni', () async {
      final db = DatabaseService.instance;
      final program = WorkoutProgram()..name = 'Vuoto'..createdAt = DateTime.now();
      final programId = await db.saveWorkoutProgram(program);
      expect(await db.getNextDayForProgram(programId), isNull);
    });
  });
}
