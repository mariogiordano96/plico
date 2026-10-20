import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/app_settings.dart';
import '../models/measurement_snapshot.dart';
import '../models/food_item.dart';
import '../models/nutrizione_completa.dart';
import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/enums.dart';
import '../models/user_food_preferences.dart';
import '../models/meal_plan.dart';
import '../models/achievement.dart';
import '../models/meal_combo.dart';
import '../models/exercise_definition.dart';
import '../models/workout_log.dart';
import '../models/workout_exercise.dart';
import '../models/workout_set.dart';
import '../models/workout_template.dart';
import '../models/workout_template_exercise.dart';
import '../models/workout_program.dart';
import '../models/personal_record.dart';
import '../models/coach_message.dart';
import 'calorie_estimation_service.dart';
import 'plicometry_calculator.dart';
import 'exercise_alternatives_service.dart';
import 'workout_progress_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late Isar _isar;

  static const _coachMessageLimit = 500;

  static const _schemas = [
    UserProfileSchema, BodySnapshotSchema, PlicometrySessionSchema,
    AppSettingsSchema, MeasurementSnapshotSchema, FoodItemSchema,
    DailyLogSchema, UserFoodPreferencesSchema, MealPlanSchema,
    AchievementSchema, MealComboSchema, ExerciseDefinitionSchema,
    WorkoutLogSchema, WorkoutExerciseSchema,
    WorkoutTemplateSchema, WorkoutProgramSchema,
    CoachMessageSchema,
  ];

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(_schemas, directory: dir.path);
  }

  @visibleForTesting
  Future<void> initForTest(String directory) async {
    _isar = await Isar.open(_schemas, directory: directory, name: 'test');
  }

  @visibleForTesting
  Future<void> close() async {
    await _isar.close();
  }

  // ──────────────────────────────────────────────
  // UserProfile
  // ──────────────────────────────────────────────

  Future<bool> hasUserProfile() async {
    return await _isar.userProfiles.get(1) != null;
  }

  Future<UserProfile?> getUserProfile() async {
    return _isar.userProfiles.get(1);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _isar.writeTxn(() async {
      await _isar.userProfiles.put(profile);
    });
  }

  /// Solo per test manuali in debug: crea un profilo utente/onboarding
  /// completo se assente, per non dover rifare l'onboarding a mano a ogni
  /// build di test. **Non tocca mai un profilo già esistente** — a
  /// differenza di `seedTestTemplateTecniche` (una scheda in più è
  /// innocua), qui sovrascrivere significherebbe cancellare dati reali se
  /// questo stesso device viene anche usato per l'uso quotidiano vero
  /// dell'app. Chiamata solo da `main.dart` sotto `kDebugMode`.
  Future<void> seedTestUserProfileIfMissing() async {
    if (await hasUserProfile()) return;
    final profile = UserProfile()
      ..nome = 'Test'
      ..cognome = 'Plico'
      ..dataNascita = DateTime(1996, 1, 1)
      ..sesso = Sesso.maschio
      ..altezzaCm = 178
      ..bodyFatIniziale = 15
      ..createdAt = DateTime.now();
    await saveUserProfile(profile);
    await addBodySnapshot(BodySnapshot()
      ..data = DateTime.now()
      ..pesoKg = 78
      ..bodyFatManuale = 15
      ..note = 'Peso iniziale (test)');
    await activateGoal(livello: 2, metodo: 0, obiettivo: 1);
  }

  Stream<UserProfile?> watchUserProfile() {
    return _isar.userProfiles.watchObject(1, fireImmediately: true);
  }

  // ──────────────────────────────────────────────
  // BodySnapshot
  // ──────────────────────────────────────────────

  Future<void> addBodySnapshot(BodySnapshot snapshot) async {
    await _isar.writeTxn(() async {
      await _isar.bodySnapshots.put(snapshot);
    });
  }

  Future<void> deleteBodySnapshot(int id) async {
    await _isar.writeTxn(() async {
      await _isar.bodySnapshots.delete(id);
    });
  }

  Future<List<BodySnapshot>> getBodySnapshots() async {
    return _isar.bodySnapshots
        .where()
        .sortByDataDesc()
        .findAll();
  }

  Future<BodySnapshot?> getLatestBodySnapshot() async {
    return _isar.bodySnapshots
        .where()
        .sortByDataDesc()
        .findFirst();
  }

  Stream<List<BodySnapshot>> watchBodySnapshots() {
    return _isar.bodySnapshots
        .where()
        .sortByDataDesc()
        .watch(fireImmediately: true);
  }

  // ──────────────────────────────────────────────
  // PlicometrySession
  // ──────────────────────────────────────────────

  Future<void> addPlicometrySession(PlicometrySession session) async {
    await _isar.writeTxn(() async {
      await _isar.plicometrySessions.put(session);
    });
  }

  Future<void> deletePlicometrySession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.plicometrySessions.delete(id);
    });
  }

  Future<List<PlicometrySession>> getPlicometrySessions() async {
    return _isar.plicometrySessions
        .where()
        .sortByDataDesc()
        .findAll();
  }

  Future<PlicometrySession?> getLatestPlicometrySession() async {
    return _isar.plicometrySessions
        .where()
        .sortByDataDesc()
        .findFirst();
  }

  Future<List<PlicometrySession>> getSessionsByMethod(
      MetodoPlicometria metodo) async {
    return _isar.plicometrySessions
        .filter()
        .metodoEqualTo(metodo)
        .sortByDataDesc()
        .findAll();
  }

  Stream<List<PlicometrySession>> watchPlicometrySessions() {
    return _isar.plicometrySessions
        .where()
        .sortByDataDesc()
        .watch(fireImmediately: true);
  }

  // ──────────────────────────────────────────────
  // MeasurementSnapshot
  // ──────────────────────────────────────────────

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> upsertMeasurementSnapshot({
    required DateTime data,
    required String fonte,
    double? tricipiteMm,
    double? bicipiteMm,
    double? pettoraleMm,
    double? ascelllareMm,
    double? sottoscapolareMm,
    double? sovrailiachMm,
    double? addomineMm,
    double? cosciaMm,
    double? polpaccioMm,
    double? colloCm,
    double? vitaCm,
    double? fianchiCm,
    double? braccioCm,
    double? cosciaCm,
    double? polpaccioCm,
    double? toraceCm,
    double? spalleCm,
  }) async {
    final day = _dayStart(data);
    await _isar.writeTxn(() async {
      var record = await _isar.measurementSnapshots
          .filter()
          .dataEqualTo(day)
          .findFirst();

      record ??= MeasurementSnapshot()..data = day;

      if (!record.fonti.contains(fonte)) {
        record.fonti = [...record.fonti, fonte];
      }

      // Merge: sovrascrive solo i campi non-null della nuova rilevazione
      if (colloCm != null) record.colloCm = colloCm;
      if (tricipiteMm != null) record.tricipiteMm = tricipiteMm;
      if (bicipiteMm != null) record.bicipiteMm = bicipiteMm;
      if (pettoraleMm != null) record.pettoraleMm = pettoraleMm;
      if (ascelllareMm != null) record.ascelllareMm = ascelllareMm;
      if (sottoscapolareMm != null) record.sottoscapolareMm = sottoscapolareMm;
      if (sovrailiachMm != null) record.sovrailiachMm = sovrailiachMm;
      if (addomineMm != null) record.addomineMm = addomineMm;
      if (cosciaMm != null) record.cosciaMm = cosciaMm;
      if (polpaccioMm != null) record.polpaccioMm = polpaccioMm;
      if (vitaCm != null) record.vitaCm = vitaCm;
      if (fianchiCm != null) record.fianchiCm = fianchiCm;
      if (braccioCm != null) record.braccioCm = braccioCm;
      if (cosciaCm != null) record.cosciaCm = cosciaCm;
      if (polpaccioCm != null) record.polpaccioCm = polpaccioCm;
      if (toraceCm != null) record.toraceCm = toraceCm;
      if (spalleCm != null) record.spalleCm = spalleCm;

      await _isar.measurementSnapshots.put(record);
    });
  }

  Future<void> deleteMeasurementSnapshot(int id) async {
    await _isar.writeTxn(() async {
      await _isar.measurementSnapshots.delete(id);
    });
  }

  Future<List<MeasurementSnapshot>> getMeasurementSnapshots() async {
    return _isar.measurementSnapshots.where().sortByDataDesc().findAll();
  }

  Stream<List<MeasurementSnapshot>> watchMeasurementSnapshots() {
    return _isar.measurementSnapshots
        .where()
        .sortByDataDesc()
        .watch(fireImmediately: true);
  }

  // ──────────────────────────────────────────────
  // AppSettings
  // ──────────────────────────────────────────────

  Stream<AppSettings?> watchAppSettings() {
    return _isar.appSettings.watchObject(1);
  }

  Future<bool> getIsDarkMode() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.isDarkMode ?? false;
  }

  Future<void> saveIsDarkMode(bool isDark) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.isDarkMode = isDark;
      await _isar.appSettings.put(settings);
    });
  }

  Future<int> getMetodoTdee() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.metodoTdee ?? 0;
  }

  Future<void> saveMetodoTdee(int metodo) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.metodoTdee = metodo;
      await _isar.appSettings.put(settings);
    });
  }

  Future<int> getLivelloAttivita() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.livelloAttivita ?? 2;
  }

  Future<void> saveLivelloAttivita(int livello) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.livelloAttivita = livello;
      await _isar.appSettings.put(settings);
    });
  }

  Future<int> getObiettivo() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.obiettivo ?? 1;
  }

  Future<void> saveObiettivo(int obiettivo) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.obiettivo = obiettivo;
      await _isar.appSettings.put(settings);
    });
  }

  Future<bool> getTourCompleted() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.tourCompleted ?? false;
  }

  Future<void> setTourCompleted() async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.tourCompleted = true;
      await _isar.appSettings.put(settings);
    });
  }

  Future<DateTime?> getGoalSetDate() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.goalSetDate;
  }

  Future<void> activateGoal({
    required int livello,
    required int metodo,
    required int obiettivo,
    double? pesoObiettivo,
  }) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.livelloAttivita = livello;
      settings.metodoTdee = metodo;
      settings.obiettivo = obiettivo;
      settings.goalSetDate = DateTime.now();
      settings.pesoObiettivo = pesoObiettivo;
      await _isar.appSettings.put(settings);
    });
  }

  Future<void> resetGoal() async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.goalSetDate = null;
      await _isar.appSettings.put(settings);
    });
  }

  // ──────────────────────────────────────────────
  // FoodItem
  // ──────────────────────────────────────────────

  Future<List<FoodItem>> searchFoodItems(String query, {String languageCode = 'it'}) async {
    final List<FoodItem> items;
    if (query.trim().isEmpty) {
      items = await _isar.foodItems
          .filter()
          .isFavoriteEqualTo(true)
          .or()
          .isCustomEqualTo(true)
          .or()
          .lastUsedAtIsNotNull()
          .findAll();
    } else if (languageCode == 'en') {
      // In inglese cerca anche su nomeInglese, non solo sul nome italiano:
      // altrimenti un termine come "chicken" non troverebbe mai "Pollo,
      // petto" (nomeInglese: "Chicken, breast") perché nomeContains lo
      // ignora — vedi FoodItem.localizedName per lo stesso fallback in
      // visualizzazione.
      items = await _isar.foodItems
          .filter()
          .nomeContains(query, caseSensitive: false)
          .or()
          .nomeIngleseContains(query, caseSensitive: false)
          .findAll();
    } else {
      items = await _isar.foodItems
          .filter()
          .nomeContains(query, caseSensitive: false)
          .findAll();
    }
    items.sort(_byRecencyThenFavoriteThenNome);
    return items;
  }

  int _byRecencyThenFavoriteThenNome(FoodItem a, FoodItem b) {
    final aUsed = a.lastUsedAt;
    final bUsed = b.lastUsedAt;
    if (aUsed != null || bUsed != null) {
      if (aUsed == null) return 1;
      if (bUsed == null) return -1;
      final cmp = bUsed.compareTo(aUsed);
      if (cmp != 0) return cmp;
    }
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    return a.nome.compareTo(b.nome);
  }

  Future<FoodItem?> getFoodItemById(Id id) => _isar.foodItems.get(id);

  Future<void> markFoodUsed(Id foodId) async {
    await _isar.writeTxn(() async {
      final item = await _isar.foodItems.get(foodId);
      if (item == null) return;
      item.lastUsedAt = DateTime.now();
      await _isar.foodItems.put(item);
    });
  }

  Future<FoodItem?> getFoodItemByOffCode(String offCode) async {
    return _isar.foodItems
        .filter()
        .offCodeEqualTo(offCode)
        .findFirst();
  }

  Future<Id> saveFoodItem(FoodItem item) async {
    late Id id;
    await _isar.writeTxn(() async {
      id = await _isar.foodItems.put(item);
    });
    return id;
  }

  Future<void> toggleFavorite(Id foodId) async {
    await _isar.writeTxn(() async {
      final item = await _isar.foodItems.get(foodId);
      if (item == null) return;
      item.isFavorite = !item.isFavorite;
      await _isar.foodItems.put(item);
    });
  }

  Future<void> deleteFoodItem(Id foodId) async {
    await _isar.writeTxn(() async {
      await _isar.foodItems.delete(foodId);
    });
  }

  // ──────────────────────────────────────────────
  // MealCombo (pasti preferiti)
  // ──────────────────────────────────────────────

  Future<List<MealCombo>> getMealCombos() async {
    return _isar.mealCombos.where().sortByNome().findAll();
  }

  Future<Id> saveMealCombo(MealCombo combo) async {
    late Id id;
    await _isar.writeTxn(() async {
      id = await _isar.mealCombos.put(combo);
    });
    return id;
  }

  Future<void> deleteMealCombo(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.mealCombos.delete(id);
    });
  }

  @visibleForTesting
  Future<void> saveFoodItemsBatch(List<FoodItem> items) async {
    await _isar.writeTxn(() async {
      await _isar.foodItems.putAll(items);
    });
  }

  Future<void> seedCreaFoods() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.creaSeeded == true) return;

    final raw = await rootBundle.loadString('assets/data/crea_seed.json');
    final list = jsonDecode(raw) as List<dynamic>;

    final items = list.map((e) => _foodFromJson(e as Map<String, dynamic>)).toList();

    await _isar.writeTxn(() async {
      await _isar.foodItems.putAll(items);
      final s = await _isar.appSettings.get(1) ?? AppSettings();
      s.creaSeeded = true;
      await _isar.appSettings.put(s);
    });
  }

  /// Migrazione una-tantum: rinomina i `FoodItem` già persistiti secondo il
  /// nome normalizzato corrente in `crea_seed.json`, matchando per `creaCode`
  /// (stabile, a differenza del nome). Necessaria per chi aveva installato
  /// l'app prima della normalizzazione dei nomi (docs/normalizzazione_nomi_alimenti.md):
  /// senza questa migrazione il vecchio nome salvato in Isar non fa più match
  /// con `PianoService.curatedNames`/`byName`, e l'alimento sparisce
  /// silenziosamente dalle preferenze e dal piano pur restando in DB.
  Future<void> migrateFoodNamesV2() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.foodNamesNormalizedV2 == true) return;

    final raw = await rootBundle.loadString('assets/data/crea_seed.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final nameByCode = <String, String>{
      for (final e in list.cast<Map<String, dynamic>>())
        if (e['creaCode'] != null) e['creaCode'] as String: e['nome'] as String,
    };

    await _isar.writeTxn(() async {
      final existing = await _isar.foodItems.filter().creaCodeIsNotNull().findAll();
      for (final food in existing) {
        final newName = nameByCode[food.creaCode];
        if (newName != null && newName != food.nome) {
          food.nome = newName;
          await _isar.foodItems.put(food);
        }
      }
      final s = await _isar.appSettings.get(1) ?? AppSettings();
      s.foodNamesNormalizedV2 = true;
      await _isar.appSettings.put(s);
    });
  }

  /// Migrazione una-tantum: risincronizza `nomeInglese` sui `FoodItem` già
  /// persistiti, matchando per `creaCode` — la normalizzazione di
  /// `crea_seed.json` (docs/normalizzazione_nomi_alimenti.md) ha
  /// aggiunto/spostato molte traduzioni senza che `migrateFoodNamesV2`
  /// (che tocca solo `nome`) le risincronizzasse, lasciando `nomeInglese`
  /// null o disallineato per chi aveva già seedato il catalogo: la ricerca
  /// in inglese mostrava quindi i nomi italiani come fallback.
  Future<void> syncFoodNomeInglese() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.foodNomeIngleseSyncedV1 == true) return;

    final raw = await rootBundle.loadString('assets/data/crea_seed.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final nomeIngleseByCode = <String, String?>{
      for (final e in list.cast<Map<String, dynamic>>())
        if (e['creaCode'] != null) e['creaCode'] as String: e['nomeInglese'] as String?,
    };

    await _isar.writeTxn(() async {
      final existing = await _isar.foodItems.filter().creaCodeIsNotNull().findAll();
      for (final food in existing) {
        final newNomeInglese = nomeIngleseByCode[food.creaCode];
        if (newNomeInglese != food.nomeInglese) {
          food.nomeInglese = newNomeInglese;
          await _isar.foodItems.put(food);
        }
      }
      final s = await _isar.appSettings.get(1) ?? AppSettings();
      s.foodNomeIngleseSyncedV1 = true;
      await _isar.appSettings.put(s);
    });
  }

  FoodItem _foodFromJson(Map<String, dynamic> j) {
    final item = FoodItem()
      ..nome = j['nome'] as String
      ..creaCode = j['creaCode'] as String?
      ..categoria = j['categoria'] as String?
      ..nomeInglese = j['nomeInglese'] as String?
      ..imageUrl = (j['imageUrl'] as String?)?.isNotEmpty == true ? j['imageUrl'] as String : null
      ..porzione = (j['porzione'] as num?)?.toDouble()
      ..parteCommestibile = (j['parteCommestibile'] as num?)?.toDouble()
      ..kcalPer100g = (j['kcalPer100g'] as num?)?.toDouble() ?? 0
      ..proteinPer100g = (j['proteinPer100g'] as num?)?.toDouble() ?? 0
      ..fatPer100g = (j['fatPer100g'] as num?)?.toDouble() ?? 0
      ..carbsPer100g = (j['carbsPer100g'] as num?)?.toDouble() ?? 0;

    item.nutrizione = NutrizioneCompleta()
      ..acqua = (j['acqua'] as num?)?.toDouble()
      ..energiaKj = (j['energiaKj'] as num?)?.toDouble()
      ..colesterolo = (j['colesterolo'] as num?)?.toDouble()
      ..amido = (j['amido'] as num?)?.toDouble()
      ..zuccheriSolubili = (j['zuccheriSolubili'] as num?)?.toDouble()
      ..alcol = (j['alcol'] as num?)?.toDouble()
      ..fibreTotali = (j['fibreTotali'] as num?)?.toDouble()
      ..fibreSolubili = (j['fibreSolubili'] as num?)?.toDouble()
      ..fibreInsolubili = (j['fibreInsolubili'] as num?)?.toDouble()
      ..saccarosio = (j['saccarosio'] as num?)?.toDouble()
      ..glucosio = (j['glucosio'] as num?)?.toDouble()
      ..fruttosio = (j['fruttosio'] as num?)?.toDouble()
      ..lattosio = (j['lattosio'] as num?)?.toDouble()
      ..galattosio = (j['galattosio'] as num?)?.toDouble()
      ..maltosio = (j['maltosio'] as num?)?.toDouble()
      ..maltotriosio = (j['maltotriosio'] as num?)?.toDouble()
      ..raffinosio = (j['raffinosio'] as num?)?.toDouble()
      ..fluoro = (j['fluoro'] as num?)?.toDouble()
      ..sodio = (j['sodio'] as num?)?.toDouble()
      ..magnesio = (j['magnesio'] as num?)?.toDouble()
      ..fosforo = (j['fosforo'] as num?)?.toDouble()
      ..cloro = (j['cloro'] as num?)?.toDouble()
      ..potassio = (j['potassio'] as num?)?.toDouble()
      ..calcio = (j['calcio'] as num?)?.toDouble()
      ..cromo = (j['cromo'] as num?)?.toDouble()
      ..manganese = (j['manganese'] as num?)?.toDouble()
      ..ferro = (j['ferro'] as num?)?.toDouble()
      ..nichel = (j['nichel'] as num?)?.toDouble()
      ..rame = (j['rame'] as num?)?.toDouble()
      ..zinco = (j['zinco'] as num?)?.toDouble()
      ..selenio = (j['selenio'] as num?)?.toDouble()
      ..iodio = (j['iodio'] as num?)?.toDouble()
      ..carotenoidiTotali = (j['carotenoidiTotali'] as num?)?.toDouble()
      ..alfaCarotene = (j['alfaCarotene'] as num?)?.toDouble()
      ..betaCarotene = (j['betaCarotene'] as num?)?.toDouble()
      ..criptoxantina = (j['criptoxantina'] as num?)?.toDouble()
      ..licopene = (j['licopene'] as num?)?.toDouble()
      ..luteina = (j['luteina'] as num?)?.toDouble()
      ..retinolo = (j['retinolo'] as num?)?.toDouble()
      ..zeaxantina = (j['zeaxantina'] as num?)?.toDouble()
      ..vitaminaA = (j['vitaminaA'] as num?)?.toDouble()
      ..tiamina = (j['tiamina'] as num?)?.toDouble()
      ..riboflavina = (j['riboflavina'] as num?)?.toDouble()
      ..niacina = (j['niacina'] as num?)?.toDouble()
      ..acidoPantotenico = (j['acidoPantotenico'] as num?)?.toDouble()
      ..vitaminaB6 = (j['vitaminaB6'] as num?)?.toDouble()
      ..biotina = (j['biotina'] as num?)?.toDouble()
      ..folati = (j['folati'] as num?)?.toDouble()
      ..vitaminaB12 = (j['vitaminaB12'] as num?)?.toDouble()
      ..vitaminaC = (j['vitaminaC'] as num?)?.toDouble()
      ..vitaminaD = (j['vitaminaD'] as num?)?.toDouble()
      ..vitaminaE = (j['vitaminaE'] as num?)?.toDouble()
      ..alfaTocoferolo = (j['alfaTocoferolo'] as num?)?.toDouble()
      ..betaTocoferolo = (j['betaTocoferolo'] as num?)?.toDouble()
      ..gammaTocoferolo = (j['gammaTocoferolo'] as num?)?.toDouble()
      ..deltaTocoferolo = (j['deltaTocoferolo'] as num?)?.toDouble()
      ..vitaminaK = (j['vitaminaK'] as num?)?.toDouble()
      ..acidiGrassiSaturi = (j['acidiGrassiSaturi'] as num?)?.toDouble()
      ..acidiGrassiMonoinsaturi = (j['acidiGrassiMonoinsaturi'] as num?)?.toDouble()
      ..acidiGrassiPolinsaturi = (j['acidiGrassiPolinsaturi'] as num?)?.toDouble()
      ..rapportoPolinsaturiSaturi = (j['rapportoPolinsaturiSaturi'] as num?)?.toDouble()
      ..acidiGrassiC4C10 = (j['acidiGrassiC4C10'] as num?)?.toDouble()
      ..acidoButirrico = (j['acidoButirrico'] as num?)?.toDouble()
      ..acidoCapronico = (j['acidoCapronico'] as num?)?.toDouble()
      ..acidoEnanterico = (j['acidoEnanterico'] as num?)?.toDouble()
      ..acidoCaprilico = (j['acidoCaprilico'] as num?)?.toDouble()
      ..acidoCaprinico = (j['acidoCaprinico'] as num?)?.toDouble()
      ..acidoLaurico = (j['acidoLaurico'] as num?)?.toDouble()
      ..acidoTridecanoico = (j['acidoTridecanoico'] as num?)?.toDouble()
      ..acidoMiristico = (j['acidoMiristico'] as num?)?.toDouble()
      ..acidoPentadecanoico = (j['acidoPentadecanoico'] as num?)?.toDouble()
      ..acidoPalmitico = (j['acidoPalmitico'] as num?)?.toDouble()
      ..acidoEptadecanoico = (j['acidoEptadecanoico'] as num?)?.toDouble()
      ..acidoStearico = (j['acidoStearico'] as num?)?.toDouble()
      ..acidoArachidico = (j['acidoArachidico'] as num?)?.toDouble()
      ..acidoBenico = (j['acidoBenico'] as num?)?.toDouble()
      ..acidoLignocerico = (j['acidoLignocerico'] as num?)?.toDouble()
      ..acidoCaproleico = (j['acidoCaproleico'] as num?)?.toDouble()
      ..acidoLauroleico = (j['acidoLauroleico'] as num?)?.toDouble()
      ..acidoTridecenoico = (j['acidoTridecenoico'] as num?)?.toDouble()
      ..acidoMiristoleico = (j['acidoMiristoleico'] as num?)?.toDouble()
      ..acidoPentadecenoico = (j['acidoPentadecenoico'] as num?)?.toDouble()
      ..acidoPalmitoleico = (j['acidoPalmitoleico'] as num?)?.toDouble()
      ..acidoEptadecenoicoMono = (j['acidoEptadecenoicoMono'] as num?)?.toDouble()
      ..acidoOleico = (j['acidoOleico'] as num?)?.toDouble()
      ..acidoEicosenoico = (j['acidoEicosenoico'] as num?)?.toDouble()
      ..acidoErucico = (j['acidoErucico'] as num?)?.toDouble()
      ..acidoLinoleico = (j['acidoLinoleico'] as num?)?.toDouble()
      ..acidoLinolenico = (j['acidoLinolenico'] as num?)?.toDouble()
      ..acidoArachidonico = (j['acidoArachidonico'] as num?)?.toDouble()
      ..epa = (j['epa'] as num?)?.toDouble()
      ..dha = (j['dha'] as num?)?.toDouble()
      ..alanina = (j['alanina'] as num?)?.toDouble()
      ..cisteina = (j['cisteina'] as num?)?.toDouble()
      ..acidoAspartico = (j['acidoAspartico'] as num?)?.toDouble()
      ..acidoGlutammico = (j['acidoGlutammico'] as num?)?.toDouble()
      ..fenilalanina = (j['fenilalanina'] as num?)?.toDouble()
      ..glicina = (j['glicina'] as num?)?.toDouble()
      ..istidina = (j['istidina'] as num?)?.toDouble()
      ..isoleucina = (j['isoleucina'] as num?)?.toDouble()
      ..lisina = (j['lisina'] as num?)?.toDouble()
      ..leucina = (j['leucina'] as num?)?.toDouble()
      ..metionina = (j['metionina'] as num?)?.toDouble()
      ..prolina = (j['prolina'] as num?)?.toDouble()
      ..arginina = (j['arginina'] as num?)?.toDouble()
      ..serina = (j['serina'] as num?)?.toDouble()
      ..treonina = (j['treonina'] as num?)?.toDouble()
      ..valina = (j['valina'] as num?)?.toDouble()
      ..triptofano = (j['triptofano'] as num?)?.toDouble()
      ..tirosina = (j['tirosina'] as num?)?.toDouble()
      ..indiceChimico = (j['indiceChimico'] as num?)?.toDouble()
      ..aminoacidoLimitante = j['aminoacidoLimitante'] as String?
      ..acidoCaffeico = (j['acidoCaffeico'] as num?)?.toDouble()
      ..acidoCitrico = (j['acidoCitrico'] as num?)?.toDouble()
      ..acidoFitico = (j['acidoFitico'] as num?)?.toDouble()
      ..acidoMalico = (j['acidoMalico'] as num?)?.toDouble()
      ..apigenina = (j['apigenina'] as num?)?.toDouble()
      ..attivitaAntiossidante = (j['attivitaAntiossidante'] as num?)?.toDouble()
      ..campferolo = (j['campferolo'] as num?)?.toDouble()
      ..fitosteroli = (j['fitosteroli'] as num?)?.toDouble()
      ..fruttooligosaccaridi = (j['fruttooligosaccaridi'] as num?)?.toDouble()
      ..miricetina = (j['miricetina'] as num?)?.toDouble()
      ..polifenoli = (j['polifenoli'] as num?)?.toDouble()
      ..quercetina = (j['quercetina'] as num?)?.toDouble()
      ..violaxantina = (j['violaxantina'] as num?)?.toDouble();

    return item;
  }

  // ──────────────────────────────────────────────
  // UserFoodPreferences
  // ──────────────────────────────────────────────

  Future<UserFoodPreferences?> getUserFoodPreferences() async {
    return _isar.userFoodPreferences.get(1);
  }

  Future<void> saveUserFoodPreferences(UserFoodPreferences prefs) async {
    await _isar.writeTxn(() async {
      await _isar.userFoodPreferences.put(prefs);
    });
  }

  // ──────────────────────────────────────────────
  // MealPlan
  // ──────────────────────────────────────────────

  Future<MealPlan?> getMealPlan() async {
    return _isar.mealPlans.get(1);
  }

  Future<void> saveMealPlan(MealPlan plan) async {
    await _isar.writeTxn(() async {
      await _isar.mealPlans.put(plan);
    });
  }

  Stream<MealPlan?> watchMealPlan() {
    return _isar.mealPlans.watchObject(1);
  }

  Future<void> markPlanObsoleto(bool obsoleto) async {
    await _isar.writeTxn(() async {
      final plan = await _isar.mealPlans.get(1);
      if (plan == null) return;
      plan.obsoleto = obsoleto;
      await _isar.mealPlans.put(plan);
    });
  }

  Future<List<FoodItem>> getAllCreaFoods() async {
    return _isar.foodItems.filter().creaCodeIsNotNull().findAll();
  }

  // ──────────────────────────────────────────────
  // DailyLog
  // ──────────────────────────────────────────────

  static DateTime _logDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<DailyLog?> getDailyLog(DateTime date) async {
    final day = _logDate(date);
    return _isar.dailyLogs.filter().dataEqualTo(day).findFirst();
  }

  Future<void> addMealEntry(DateTime date, MealEntry entry) async {
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      var log = await _isar.dailyLogs.filter().dataEqualTo(day).findFirst();
      log ??= DailyLog()..data = day;
      log.entries = [...log.entries, entry];
      await _isar.dailyLogs.put(log);
    });
  }

  Future<void> removeMealEntry(DateTime date, int entryIndex) async {
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      final log = await _isar.dailyLogs.filter().dataEqualTo(day).findFirst();
      if (log == null) return;
      final updated = [...log.entries];
      updated.removeAt(entryIndex);
      log.entries = updated;
      await _isar.dailyLogs.put(log);
    });
  }

  Future<List<DailyLog>> getDailyLogsRange(DateTime from, DateTime to) async {
    final f = _logDate(from);
    final t = _logDate(to);
    return _isar.dailyLogs.filter().dataBetween(f, t).sortByData().findAll();
  }

  Stream<List<DailyLog>> watchDailyLogs() {
    return _isar.dailyLogs
        .where()
        .sortByData()
        .watch(fireImmediately: true);
  }

  Stream<DailyLog?> watchDailyLog(DateTime date) {
    final day = _logDate(date);
    return _isar.dailyLogs
        .filter()
        .dataEqualTo(day)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }

  // ──────────────────────────────────────────────
  // Achievement
  // ──────────────────────────────────────────────

  Future<void> unlockAchievement(AchievementType type) async {
    await _isar.writeTxn(() async {
      final existing =
          await _isar.achievements.filter().typeEqualTo(type.name).findFirst();
      if (existing != null) return;
      await _isar.achievements.put(Achievement()
        ..type = type.name
        ..unlockedAt = DateTime.now());
    });
  }

  static AchievementType? _typeFromName(String name) {
    for (final t in AchievementType.values) {
      if (t.name == name) return t;
    }
    return null;
  }

  Future<Set<AchievementType>> getUnlockedTypes() async {
    final all = await _isar.achievements.where().findAll();
    return all.map((a) => _typeFromName(a.type)).whereType<AchievementType>().toSet();
  }

  Stream<Set<AchievementType>> watchUnlockedTypes() {
    return _isar.achievements.where().watch(fireImmediately: true).map((all) =>
        all.map((a) => _typeFromName(a.type)).whereType<AchievementType>().toSet());
  }

  // ──────────────────────────────────────────────
  // Notification settings
  // ──────────────────────────────────────────────

  Future<AppSettings> getAppSettings() async {
    final s = await _isar.appSettings.get(1) ?? AppSettings();
    // Isar reads garbage bytes from old records when new int fields are added.
    // Any value outside 0..1439 (valid minutes in a day) means corrupt/missing data.
    bool invalidMin(int v) => v < 0 || v > 1439;
    bool needsSave = false;
    if (invalidMin(s.notColMin) || invalidMin(s.notPranzoMin) || invalidMin(s.notCenaMin)) {
      s.notColMin = 450;
      s.notPranzoMin = 750;
      s.notCenaMin = 1170;
      s.notSpuntinoMin = 630;
      s.notPostWoMin = 1020;
      s.notSorMin = 1260;
      // notColAttiva/notPranzoAttiva/notCenaAttiva sono arrivati nello stesso
      // commit dei _Min sopra: se quelli risultano corrotti, il record è
      // precedente all'intera feature promemoria pasti, quindi anche questi
      // tre flag erano assenti (letti come `false`, sentinel Isar per un
      // bool mancante, non il default dichiarato `true`) — sicuro forzarli.
      s.notColAttiva = true;
      s.notPranzoAttiva = true;
      s.notCenaAttiva = true;
      needsSave = true;
    }
    if (s.restTimerDefaultSeconds < 15 || s.restTimerDefaultSeconds > 600) {
      s.restTimerDefaultSeconds = 90;
      needsSave = true;
    }
    // livelloAttivita/metodoTdee/obiettivo: stesso problema dei _Min sopra,
    // ma per record ancora più vecchi (introdotti prima dei promemoria
    // pasti) — senza questo controllo, un metodoTdee corrotto fa sparire
    // silenziosamente il calcolo del target kcal/macro (calcolaTdee cade nel
    // default: return null).
    if (s.livelloAttivita < 0 || s.livelloAttivita > 4) {
      s.livelloAttivita = 2;
      needsSave = true;
    }
    if (s.metodoTdee < 0 || s.metodoTdee > 3) {
      s.metodoTdee = 0;
      needsSave = true;
    }
    if (s.obiettivo < 0 || s.obiettivo > 2) {
      s.obiettivo = 1;
      needsSave = true;
    }
    if (needsSave) {
      await _isar.writeTxn(() async => _isar.appSettings.put(s));
    }
    return s;
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  // ──────────────────────────────────────────────
  // ExerciseDefinition
  // ──────────────────────────────────────────────

  Future<void> seedExercises() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.exercisesSeeded != true) {
      final raw = await rootBundle.loadString('assets/data/exercises_seed.json');
      final list = jsonDecode(raw) as List<dynamic>;

      final exercises = list.map((e) => _exerciseFromJson(e as Map<String, dynamic>)).toList();

      await _isar.writeTxn(() async {
        await _isar.exerciseDefinitions.putAll(exercises);
        final s = await _isar.appSettings.get(1) ?? AppSettings();
        s.exercisesSeeded = true;
        await _isar.appSettings.put(s);
      });
    }
    await _fixMiscategorizedExercises();
  }

  /// Migrazione una-tantum: risincronizza `nameIt` sugli ExerciseDefinition
  /// già persistiti, matchando per `externalId` — il catalogo è stato
  /// tradotto in italiano dopo il primo rilascio, e `seedExercises` seeda
  /// una sola volta, quindi la traduzione da sola non arriva a chi aveva
  /// già installato l'app. Non tocca gli esercizi personalizzati dell'utente.
  Future<void> syncExerciseNamesIt() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.exerciseNamesItSyncedV1 == true) return;

    final raw = await rootBundle.loadString('assets/data/exercises_seed.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final nameItByExternalId = <String, String?>{
      for (final e in list.cast<Map<String, dynamic>>())
        e['externalId'] as String: e['nameIt'] as String?,
    };

    await _isar.writeTxn(() async {
      final existing = await _isar.exerciseDefinitions.filter().isCustomEqualTo(false).findAll();
      final changed = <ExerciseDefinition>[];
      for (final exercise in existing) {
        // containsKey, non solo il valore: un externalId assente dal seed
        // corrente (voce rimossa/rinominata a monte) non deve azzerare una
        // nameIt già persistita, a differenza di una nameIt tornata a null
        // esplicitamente nel JSON.
        if (!nameItByExternalId.containsKey(exercise.externalId)) continue;
        final newNameIt = nameItByExternalId[exercise.externalId];
        if (newNameIt != exercise.nameIt) {
          exercise.nameIt = newNameIt;
          changed.add(exercise);
        }
      }
      if (changed.isNotEmpty) {
        await _isar.exerciseDefinitions.putAll(changed);
      }
      final s = await _isar.appSettings.get(1) ?? AppSettings();
      s.exerciseNamesItSyncedV1 = true;
      await _isar.appSettings.put(s);
    });
  }

  /// Corregge in-place la categoria di voci del catalogo preinstallato già
  /// seedate su installazioni esistenti (`seedExercises` seeda una sola
  /// volta, quindi una correzione nel JSON da sola non arriva a chi ha già
  /// installato l'app). Idempotente e a costo trascurabile: dopo il primo
  /// fix diventa una sola lettura indicizzata a ogni avvio. Non tocca gli
  /// esercizi personalizzati dell'utente.
  Future<void> _fixMiscategorizedExercises() async {
    final burpee =
        await _isar.exerciseDefinitions.filter().externalIdEqualTo('Burpee').findFirst();
    if (burpee != null && !burpee.isCustom && burpee.category == 'cardio') {
      burpee
        ..muscleGroup = 'core'
        ..category = 'plyometrics';
      await _isar.writeTxn(() => _isar.exerciseDefinitions.put(burpee));
    }
  }

  ExerciseDefinition _exerciseFromJson(Map<String, dynamic> j) {
    return ExerciseDefinition()
      ..externalId = j['externalId'] as String
      ..name = j['name'] as String
      ..nameIt = j['nameIt'] as String?
      ..muscleGroup = j['muscleGroup'] as String
      ..category = j['category'] as String
      ..equipment = j['equipment'] as String?
      ..level = j['level'] as String?
      ..mechanic = j['mechanic'] as String?
      ..instructions = (j['instructions'] as List<dynamic>?)?.cast<String>() ?? [];
  }

  Future<List<ExerciseDefinition>> getAllExercises() async {
    return _isar.exerciseDefinitions.filter().isDeletedEqualTo(false).findAll();
  }

  Future<List<ExerciseDefinition>> searchExercises(String query, {String? muscleGroup}) async {
    final all = await getAllExercises();
    final tokens = query.trim().toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    return all.where((e) {
      if (muscleGroup != null && e.muscleGroup != muscleGroup) return false;
      if (tokens.isEmpty) return true;
      final name = e.name.toLowerCase();
      final nameIt = e.nameIt?.toLowerCase() ?? '';
      final words = [...name.split(RegExp(r'\s+')), ...nameIt.split(RegExp(r'\s+'))];
      return tokens.every((t) =>
          name.contains(t) || nameIt.contains(t) || words.any((w) => _isFuzzyMatch(t, w)));
    }).toList();
  }

  /// Tollera piccoli refusi di battitura: confronta [token] con una parola
  /// del nome esercizio tramite distanza di Levenshtein, con soglia crescente
  /// in base alla lunghezza della parola per non generare troppi falsi positivi.
  bool _isFuzzyMatch(String token, String word) {
    if (token.length < 3 || word.length < 3) return false;
    final maxDistance = token.length > 7 ? 2 : 1;
    if ((token.length - word.length).abs() > maxDistance) return false;
    return _levenshtein(token, word) <= maxDistance;
  }

  int _levenshtein(String a, String b) {
    final la = a.length, lb = b.length;
    var prev = List<int>.generate(lb + 1, (j) => j);
    for (var i = 1; i <= la; i++) {
      final curr = List<int>.filled(lb + 1, 0);
      curr[0] = i;
      for (var j = 1; j <= lb; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((v, e) => v < e ? v : e);
      }
      prev = curr;
    }
    return prev[lb];
  }

  Future<void> addCustomExercise(ExerciseDefinition exercise) async {
    await _isar.writeTxn(() async {
      await _isar.exerciseDefinitions.put(exercise);
    });
  }

  /// Alternative per la sostituzione esercizio al volo (Fase 13), ordinate
  /// per somiglianza a [exerciseId] (stesso muscleGroup, poi mechanic/equipment).
  Future<List<ExerciseDefinition>> getAlternatives(String exerciseId) async {
    final all = await getAllExercises();
    ExerciseDefinition? source;
    for (final e in all) {
      if (e.externalId == exerciseId) {
        source = e;
        break;
      }
    }
    if (source == null) return [];
    return ExerciseAlternativesService.rank(source, all);
  }

  // ──────────────────────────────────────────────
  // WorkoutLog / WorkoutExercise
  // ──────────────────────────────────────────────

  Future<WorkoutLog?> getWorkoutLog(DateTime date) async {
    final day = _logDate(date);
    return _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
  }

  Future<void> setWorkoutNote(DateTime date, String? note) async {
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      var log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
      log ??= WorkoutLog()..date = day;
      log.note = note;
      await _isar.workoutLogs.put(log);
    });
  }

  /// Somma [seconds] alla durata totale già accumulata quel giorno (Fase 30):
  /// più sessioni guidate nello stesso giorno si sommano invece di
  /// sovrascriversi.
  Future<void> addSessionDuration(DateTime date, int seconds) async {
    if (seconds <= 0) return;
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      var log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
      log ??= WorkoutLog()..date = day;
      log.totalDurationSeconds = (log.totalDurationSeconds ?? 0) + seconds;
      // La sessione è chiusa: il checkpoint intermedio non serve più, altrimenti
      // verrebbe riletto come base al prossimo "Avvia allenamento" dello stesso
      // giorno e il tempo finirebbe conteggiato due volte.
      log.pendingSessionSeconds = null;
      await _isar.workoutLogs.put(log);
    });
  }

  /// Legge il checkpoint di una sessione guidata interrotta a metà (app
  /// chiusa senza passare da "Termina sessione"), per farla ripartire dal
  /// tempo trascorso invece che da zero.
  Future<int> getPendingSessionSeconds(DateTime date) async {
    final day = _logDate(date);
    final log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
    return log?.pendingSessionSeconds ?? 0;
  }

  /// Salva periodicamente il tempo trascorso nella sessione guidata ancora in
  /// corso, per poterlo recuperare se l'app viene chiusa prima di "Termina
  /// sessione" (vedi [getPendingSessionSeconds]).
  Future<void> saveSessionCheckpoint(DateTime date, int seconds) async {
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      var log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
      log ??= WorkoutLog()..date = day;
      log.pendingSessionSeconds = seconds;
      await _isar.workoutLogs.put(log);
    });
  }

  Future<List<WorkoutExercise>> getWorkoutExercisesForDay(DateTime date) async {
    final day = _logDate(date);
    return _isar.workoutExercises.filter().dateEqualTo(day).findAll();
  }

  Stream<List<WorkoutExercise>> watchWorkoutExercisesForDay(DateTime date) {
    final day = _logDate(date);
    return _isar.workoutExercises
        .filter()
        .dateEqualTo(day)
        .watch(fireImmediately: true);
  }

  Future<void> addWorkoutExercise(DateTime date, WorkoutExercise exercise) async {
    final day = _logDate(date);
    exercise.date = day;
    await _isar.writeTxn(() async {
      var log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
      log ??= WorkoutLog()..date = day;
      await _isar.workoutLogs.put(log);
      await _isar.workoutExercises.put(exercise);
    });
  }

  Future<void> updateWorkoutExercise(WorkoutExercise exercise) async {
    await _isar.writeTxn(() async {
      await _isar.workoutExercises.put(exercise);
    });
  }

  Future<void> deleteWorkoutExercise(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.workoutExercises.delete(id);
    });
  }

  Future<List<WorkoutExercise>> getHistoryForExercise(String exerciseId) async {
    return _isar.workoutExercises
        .filter()
        .exerciseIdEqualTo(exerciseId)
        .sortByDateDesc()
        .findAll();
  }

  /// Record personali (peso massimo storico, escluse le serie di riscaldamento)
  /// per ogni esercizio di forza mai loggato — uno per `exerciseId` distinto,
  /// ordinati dal più recente. Esclude esercizi senza serie a peso (es. cardio).
  Future<List<PersonalRecord>> getAllPersonalRecords() async {
    final all = await _isar.workoutExercises.where().findAll();
    final byExercise = <String, List<WorkoutExercise>>{};
    for (final e in all) {
      byExercise.putIfAbsent(e.exerciseId, () => []).add(e);
    }

    final muscleGroupById = {
      for (final ex in await getAllExercises()) ex.externalId: ex.muscleGroup,
    };

    final records = <PersonalRecord>[];
    for (final entry in byExercise.entries) {
      double? bestWeight;
      DateTime? bestDate;
      String? bestName;
      for (final session in entry.value) {
        final maxW = WorkoutProgressService.sessionMaxWeight(session);
        if (maxW == null) continue;
        if (bestWeight == null || maxW > bestWeight) {
          bestWeight = maxW;
          bestDate = session.date;
          bestName = session.exerciseName;
        }
      }
      if (bestWeight == null || bestDate == null || bestName == null) continue;
      records.add(PersonalRecord(
        exerciseId: entry.key,
        exerciseName: bestName,
        muscleGroup: muscleGroupById[entry.key],
        maxWeightKg: bestWeight,
        achievedAt: bestDate,
      ));
    }
    records.sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
    return records;
  }

  Future<DateTime?> getLastWorkoutDate() async {
    final log = await _isar.workoutLogs.where().sortByDateDesc().findFirst();
    return log?.date;
  }

  /// Giorni (normalizzati a mezzanotte) in cui è stato registrato almeno un
  /// [WorkoutExercise], nel range indicato. Usato per la streak allenamento.
  Future<Set<DateTime>> getWorkoutDaysRange(DateTime from, DateTime to) async {
    final f = _logDate(from);
    final t = _logDate(to);
    final exercises = await _isar.workoutExercises.filter().dateBetween(f, t).findAll();
    return exercises.map((e) => e.date).toSet();
  }

  /// Per ogni giorno del range con almeno un [WorkoutExercise], i nomi
  /// distinti delle schede fatte quel giorno (`sourceTemplateName`, ordine di
  /// prima comparsa) — lista vuota se il giorno ha solo esercizi liberi.
  /// Usato dal calendario allenamenti (Fase 31).
  Future<Map<DateTime, List<String>>> getWorkoutLabelsForRange(DateTime from, DateTime to) async {
    final f = _logDate(from);
    final t = _logDate(to);
    final exercises = await _isar.workoutExercises.filter().dateBetween(f, t).findAll();
    final byDay = <DateTime, List<String>>{};
    for (final e in exercises) {
      final labels = byDay.putIfAbsent(e.date, () => []);
      final name = e.sourceTemplateName;
      if (name != null && !labels.contains(name)) labels.add(name);
    }
    return byDay;
  }

  /// Come [getWorkoutDaysRange], ma osservabile: emette ogni volta che cambia
  /// un [WorkoutExercise] qualsiasi.
  Stream<Set<DateTime>> watchWorkoutDays() {
    return _isar.workoutExercises
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.date).toSet());
  }

  /// Tutti i [WorkoutExercise] registrati nel range [from]-[to] (inclusi),
  /// osservabile. Usato dalla cronologia allenamenti recenti in Progressi.
  Stream<List<WorkoutExercise>> watchWorkoutExercisesRange(DateTime from, DateTime to) {
    final f = _logDate(from);
    final t = _logDate(to);
    return _isar.workoutExercises
        .filter()
        .dateBetween(f, t)
        .watch(fireImmediately: true);
  }

  /// Come [watchWorkoutExercisesRange], one-shot. Usato dall'export PDF di
  /// Progressi.
  Future<List<WorkoutExercise>> getWorkoutExercisesRange(DateTime from, DateTime to) async {
    final f = _logDate(from);
    final t = _logDate(to);
    return _isar.workoutExercises.filter().dateBetween(f, t).findAll();
  }

  /// Tutti i [WorkoutExercise] mai registrati. Usato dall'export PDF di
  /// Progressi quando il range selezionato è "tutto" (nessun filtro data).
  Future<List<WorkoutExercise>> getAllWorkoutExercises() async {
    return _isar.workoutExercises.where().findAll();
  }

  /// Numero totale di sessioni allenamento mai registrate, dove una sessione
  /// è un giorno con almeno un [WorkoutExercise].
  Future<int> getTotalWorkoutSessionsCount() async {
    final all = await _isar.workoutExercises.where().findAll();
    return all.map((e) => e.date).toSet().length;
  }

  Future<int> getWorkoutKcalForDay(DateTime date) async {
    final esercizi = await getWorkoutExercisesForDay(date);
    return CalorieEstimationService.dailyKcal(esercizi);
  }

  /// Giorni con almeno un allenamento nella settimana corrente (lunedì-oggi,
  /// stessa convenzione locale-aware di `WorkoutProgressService._weekKey`).

  /// Volume totale (Σ rip × peso, escluse le serie di riscaldamento) della
  /// settimana che inizia in [weekStart], aggregato per
  /// `ExerciseDefinition.muscleGroup`. Usato dal grafico "Volume settimanale"
  /// in Progressi (Fase 18).
  Future<Map<String, double>> getWeeklyVolumeByMuscleGroup(DateTime weekStart) async {
    final start = _logDate(weekStart);
    final end = _logDate(start.add(const Duration(days: 6)));
    final exercises = await _isar.workoutExercises.filter().dateBetween(start, end).findAll();
    final muscleGroupById = {
      for (final ex in await getAllExercises()) ex.externalId: ex.muscleGroup,
    };

    final volumeByGroup = <String, double>{};
    for (final e in exercises) {
      final group = muscleGroupById[e.exerciseId];
      if (group == null) continue;
      final volume = e.sets
          .where((s) => !s.isWarmup)
          .fold(0.0, (sum, s) => sum + WorkoutProgressService.setVolume(s));
      volumeByGroup[group] = (volumeByGroup[group] ?? 0) + volume;
    }
    return volumeByGroup;
  }

  Future<void> deleteWorkoutLog(DateTime date) async {
    final day = _logDate(date);
    await _isar.writeTxn(() async {
      final exercises = await _isar.workoutExercises.filter().dateEqualTo(day).findAll();
      await _isar.workoutExercises.deleteAll(exercises.map((e) => e.id).toList());
      final log = await _isar.workoutLogs.filter().dateEqualTo(day).findFirst();
      if (log != null) await _isar.workoutLogs.delete(log.id);
    });
  }

  // ──────────────────────────────────────────────
  // WorkoutTemplate / WorkoutProgram
  // ──────────────────────────────────────────────

  Future<void> seedWorkoutPresets() async {
    final settings = await _isar.appSettings.get(1);
    if (settings?.workoutPresetsSeeded == true) return;

    final raw = await rootBundle.loadString('assets/data/workout_presets.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;

    await _isar.writeTxn(() async {
      for (final t in (json['templates'] as List).cast<Map<String, dynamic>>()) {
        await _isar.workoutTemplates.put(_presetTemplateFromJson(t));
      }
      for (final p in (json['programs'] as List).cast<Map<String, dynamic>>()) {
        final program = WorkoutProgram()
          ..name = p['name'] as String
          ..createdAt = DateTime.now()
          ..isPreset = true;
        final programId = await _isar.workoutPrograms.put(program);

        final days = (p['days'] as List).cast<Map<String, dynamic>>();
        for (var i = 0; i < days.length; i++) {
          final day = _presetTemplateFromJson(days[i])
            ..programId = programId
            ..order = i;
          await _isar.workoutTemplates.put(day);
        }
      }
      final s = await _isar.appSettings.get(1) ?? AppSettings();
      s.workoutPresetsSeeded = true;
      await _isar.appSettings.put(s);
    });
  }

  /// Solo per test manuali in debug (docs/tecniche_allenamento.md, Fase 7):
  /// crea/ricrea una scheda fissa con un esercizio per ogni tecnica, così non
  /// serve ricomporla a mano a ogni build durante lo sviluppo. Cancella e
  /// ricrea ogni volta (idempotente sul nome), non solo se assente, così
  /// riflette sempre l'ultima versione di questo metodo dopo un reinstall.
  /// Chiamata solo da `main.dart` sotto `kDebugMode`, mai in release.
  Future<void> seedTestTemplateTecniche() async {
    final existing =
        (await getStandaloneTemplates()).where((t) => t.name == 'TEST — Tecniche').toList();
    for (final t in existing) {
      await deleteWorkoutTemplate(t.id);
    }

    final template = WorkoutTemplate()
      ..name = 'TEST — Tecniche'
      ..createdAt = DateTime.now()
      ..exercises = [
        // Normale, target uniforme — baseline di regressione (comportamento pre-Fase 7).
        WorkoutTemplateExercise()
          ..exerciseId = 'Barbell_Bench_Press_-_Medium_Grip'
          ..exerciseName = 'Barbell Bench Press - Medium Grip'
          ..targetSets = 3
          ..targetReps = 10
          ..targetWeightKg = 60,
        // Piramide pianificata — reps/peso diversi per serie, nessuna tecnica particolare.
        WorkoutTemplateExercise()
          ..exerciseId = 'Barbell_Incline_Bench_Press_-_Medium_Grip'
          ..exerciseName = 'Barbell Incline Bench Press - Medium Grip'
          ..plannedSets = [
            WorkoutTemplateSet()
              ..reps = 12
              ..weightKg = 40,
            WorkoutTemplateSet()
              ..reps = 10
              ..weightKg = 45,
            WorkoutTemplateSet()
              ..reps = 8
              ..weightKg = 50,
            WorkoutTemplateSet()
              ..reps = 6
              ..weightKg = 55,
          ],
        // Rest-pause pianificato sull'ultima serie.
        WorkoutTemplateExercise()
          ..exerciseId = 'Dumbbell_Bench_Press'
          ..exerciseName = 'Dumbbell Bench Press'
          ..plannedSets = [
            WorkoutTemplateSet()
              ..reps = 12
              ..weightKg = 24,
            WorkoutTemplateSet()
              ..reps = 10
              ..weightKg = 24
              ..restPauseClusters = [10, 5, 3],
          ],
        // Stripping (drop set) pianificato.
        WorkoutTemplateExercise()
          ..exerciseId = 'Wide-Grip_Lat_Pulldown'
          ..exerciseName = 'Wide-Grip Lat Pulldown'
          ..plannedSets = [
            WorkoutTemplateSet()
              ..reps = 10
              ..weightKg = 50
              ..dropStages = [
                DropStage()
                  ..reps = 8
                  ..weightKg = 40,
                DropStage()
                  ..reps = 6
                  ..weightKg = 30,
              ],
          ],
        // Forzate pianificate.
        WorkoutTemplateExercise()
          ..exerciseId = 'Barbell_Squat'
          ..exerciseName = 'Barbell Squat'
          ..plannedSets = [
            WorkoutTemplateSet()
              ..reps = 6
              ..weightKg = 100
              ..forcedReps = 2,
          ],
        // Super slow pianificato.
        WorkoutTemplateExercise()
          ..exerciseId = 'Leg_Press'
          ..exerciseName = 'Leg Press'
          ..plannedSets = [
            WorkoutTemplateSet()
              ..reps = 8
              ..weightKg = 120
              ..isSuperSlow = true,
          ],
        // Superset esplosiva/lenta.
        WorkoutTemplateExercise()
          ..exerciseId = 'Seated_Cable_Rows'
          ..exerciseName = 'Seated Cable Rows'
          ..targetSets = 3
          ..targetReps = 10
          ..targetWeightKg = 40
          ..supersetGroupId = 1
          ..supersetRole = SupersetRole.esplosiva.name,
        WorkoutTemplateExercise()
          ..exerciseId = 'Pullups'
          ..exerciseName = 'Pullups'
          ..targetSets = 3
          ..targetReps = 8
          ..supersetGroupId = 1
          ..supersetRole = SupersetRole.lenta.name,
        // Cardio — baseline di regressione.
        WorkoutTemplateExercise()
          ..exerciseId = 'Running_Treadmill'
          ..exerciseName = 'Running Treadmill'
          ..targetDurationSeconds = 1200,
      ];
    await saveWorkoutTemplate(template);
  }

  double _seedPesoKgAt(DateTime date, DateTime start, DateTime end) {
    final totalDays = end.difference(start).inDays.clamp(1, 1 << 30);
    final elapsed = date.difference(start).inDays.clamp(0, totalDays);
    return 84.0 - 8.0 * (elapsed / totalDays);
  }

  double _seedScaled(double base, double progress) =>
      double.parse((base * progress).toStringAsFixed(1));

  DateTime _seedNextWeekday(DateTime from, int weekday) {
    var d = DateTime(from.year, from.month, from.day);
    while (d.weekday != weekday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  /// Solo per test manuali in debug (richiesta esplicita per verificare
  /// grafici/PDF con dati realistici): popola un anno di storico per il
  /// profilo corrente — pesate, plicometrie e misurazioni mensili con un
  /// trend di ricomposizione corporea coerente tra loro, più il log
  /// allenamenti della scheda "TEST — Tecniche" (creata da
  /// [seedTestTemplateTecniche]) due volte a settimana con progressione di
  /// carico dal 75% al 100% dei pesi target del template. Non tocca dati
  /// esistenti in altri giorni (usa gli stessi metodi di scrittura del resto
  /// dell'app, idempotenti per data). Chiamata solo da un bottone in
  /// `kDebugMode`, mai in release.
  Future<String> seedTestYearlyHistory() async {
    final profile = await getUserProfile();
    if (profile == null) {
      return 'Nessun profilo utente: completa prima l\'onboarding.';
    }

    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);

    // Pulizia di eventuali pesate/plicometrie da un run precedente di questo
    // seed: a differenza di `upsertMeasurementSnapshot` (dedup per giorno),
    // `addBodySnapshot`/`addPlicometrySession` inseriscono sempre un nuovo
    // record, quindi senza questa pulizia ogni tap del bottone duplicherebbe
    // i 12 punti mensili invece di sostituirli.
    final oldSnapshots =
        await _isar.bodySnapshots.filter().noteEqualTo('Seed test').findAll();
    final oldSessions = await _isar.plicometrySessions
        .filter()
        .noteEqualTo('Seed test')
        .findAll();
    await _isar.writeTxn(() async {
      for (final s in oldSnapshots) {
        await _isar.bodySnapshots.delete(s.id);
      }
      for (final s in oldSessions) {
        await _isar.plicometrySessions.delete(s.id);
      }
    });

    // ── Pesate / Plicometrie / Misurazioni, un punto al mese ──
    var pesateCount = 0, plicoCount = 0, misureCount = 0;
    for (var i = 0; i < 12; i++) {
      final monthsAgo = 11 - i;
      final date = DateTime(now.year, now.month - monthsAgo, 5);
      final t = i / 11; // 0.0 (11 mesi fa) → 1.0 (oggi)

      final pesoKg = _seedScaled(84.0 - 8.0 * t, 1);
      await addBodySnapshot(BodySnapshot()
        ..data = date
        ..pesoKg = pesoKg
        ..note = 'Seed test');
      pesateCount++;

      final pliche = {
        'pettorale': _seedScaled(18.0 - 8.0 * t, 1),
        'addome': _seedScaled(24.0 - 12.0 * t, 1),
        'coscia': _seedScaled(17.0 - 7.0 * t, 1),
      };
      final result = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.jacksonPollock3,
        sesso: profile.sesso,
        eta: profile.etaCorrente,
        pesoKg: pesoKg,
        pliche: pliche,
      );
      await addPlicometrySession(PlicometrySession()
        ..data = date
        ..metodo = MetodoPlicometria.jacksonPollock3
        ..etaAnni = profile.etaCorrente
        ..pesoKg = pesoKg
        ..altezzaCm = profile.altezzaCm
        ..pliche = (Pliche()
          ..pettoralleMm = pliche['pettorale']
          ..addomineMm = pliche['addome']
          ..cosciaMm = pliche['coscia'])
        ..risultati = (RisultatiPlico()
          ..bodyFatPercent = result.bodyFatPercent
          ..massaGrassaKg = result.massaGrassaKg
          ..massaMagraKg = result.massaMagraKg
          ..sommaPlicheMm = result.sommaPlicheMm
          ..densitaCorporea = result.densitaCorporea)
        ..note = 'Seed test');
      plicoCount++;

      await upsertMeasurementSnapshot(
        data: date,
        fonte: 'seed_test',
        colloCm: 40.0,
        vitaCm: _seedScaled(92.0 - 8.0 * t, 1),
        fianchiCm: _seedScaled(104.0 - 4.0 * t, 1),
        braccioCm: _seedScaled(34.0 + 2.0 * t, 1),
        cosciaCm: _seedScaled(58.0 - 2.0 * t, 1),
        polpaccioCm: _seedScaled(38.0 + 1.0 * t, 1),
        toraceCm: _seedScaled(100.0 + 4.0 * t, 1),
        // Pliche: le stesse pettorale/addome/coscia usate per la
        // plicometria sopra, più le altre 4 non coinvolte nel calcolo
        // Jackson-Pollock 3 ma comunque selezionabili nel grafico
        // "Misurazioni" (chip in mm).
        pettoraleMm: pliche['pettorale'],
        addomineMm: pliche['addome'],
        cosciaMm: pliche['coscia'],
        tricipiteMm: _seedScaled(14.0 - 6.0 * t, 1),
        bicipiteMm: _seedScaled(8.0 - 3.0 * t, 1),
        sottoscapolareMm: _seedScaled(16.0 - 7.0 * t, 1),
        sovrailiachMm: _seedScaled(15.0 - 6.0 * t, 1),
      );
      misureCount++;
    }

    // ── Log allenamenti: scheda "TEST — Tecniche", lun+gio per un anno ──
    final templates = await getStandaloneTemplates();
    var template = WorkoutTemplate();
    var hasTemplate = false;
    for (final tmpl in templates) {
      if (tmpl.name == 'TEST — Tecniche') {
        template = tmpl;
        hasTemplate = true;
        break;
      }
    }

    var sessionCount = 0;
    if (hasTemplate) {
      final sessionDays = <DateTime>[];
      var cursor = _seedNextWeekday(start, DateTime.monday);
      var nextIsThursday = true;
      while (!cursor.isAfter(now)) {
        sessionDays.add(cursor);
        cursor = _seedNextWeekday(
          cursor.add(const Duration(days: 1)),
          nextIsThursday ? DateTime.thursday : DateTime.monday,
        );
        nextIsThursday = !nextIsThursday;
      }

      for (var i = 0; i < sessionDays.length; i++) {
        final date = sessionDays[i];

        // Idempotenza: `startWorkoutFromTemplate` restituisce gli esercizi
        // già loggati se presenti, senza ricrearli — se lo facessimo anche
        // qui, ogni tap successivo del bottone scalerebbe di nuovo i pesi
        // già scalati da un run precedente, componendo la progressione.
        final alreadyLogged = await getWorkoutExercisesForDay(date);
        if (alreadyLogged.any((e) => e.sourceTemplateId == template.id)) {
          sessionCount++;
          continue;
        }

        final progress = sessionDays.length <= 1
            ? 1.0
            : 0.75 + 0.25 * (i / (sessionDays.length - 1));
        final bodyWeight = _seedPesoKgAt(date, start, now);

        final created = await startWorkoutFromTemplate(template, date);
        for (final we in created) {
          if (we.isCardio) {
            we.cardioConfirmed = true;
            we.estimatedKcal = CalorieEstimationService.estimateCardioKcal(
              exerciseId: we.exerciseId,
              durationSeconds: we.durationSeconds ?? 0,
              bodyWeightKg: bodyWeight,
            );
          } else {
            for (final s in we.sets) {
              if (s.weightKg != null) {
                s.weightKg = _seedScaled(s.weightKg!, progress);
              }
              s.confirmed = true;
              final drops = s.dropStages;
              if (drops != null) {
                for (final d in drops) {
                  if (d.weightKg != null) {
                    d.weightKg = _seedScaled(d.weightKg!, progress);
                  }
                }
              }
            }
            we.estimatedKcal = CalorieEstimationService.estimateStrengthKcal(
              workingSetCount: we.sets.where((s) => !s.isWarmup).length,
              bodyWeightKg: bodyWeight,
            );
          }
          await updateWorkoutExercise(we);
        }
        await addSessionDuration(date, 2700 + (i % 6) * 180);
        sessionCount++;
      }
    }

    return '$pesateCount pesate, $plicoCount plicometrie, $misureCount misurazioni'
        '${hasTemplate ? ', $sessionCount sessioni allenamento' : ' — scheda "TEST — Tecniche" non trovata, nessuna sessione creata'}.';
  }

  WorkoutTemplate _presetTemplateFromJson(Map<String, dynamic> j) {
    return WorkoutTemplate()
      ..name = j['name'] as String
      ..createdAt = DateTime.now()
      ..isPreset = true
      ..exercises = (j['exercises'] as List)
          .cast<Map<String, dynamic>>()
          .map((e) => WorkoutTemplateExercise()
            ..exerciseId = e['exerciseId'] as String
            ..exerciseName = e['exerciseName'] as String
            ..targetSets = e['targetSets'] as int?
            ..targetReps = e['targetReps'] as int?
            ..targetWeightKg = (e['targetWeightKg'] as num?)?.toDouble()
            ..targetDurationSeconds = e['targetDurationSeconds'] as int?
            ..supersetGroupId = e['supersetGroupId'] as int?
            ..restSeconds = e['restSeconds'] as int?
            ..supersetRole = e['supersetRole'] as String?)
          .toList();
  }

  Future<List<WorkoutTemplate>> getStandaloneTemplates() async {
    return _isar.workoutTemplates.filter().programIdIsNull().findAll();
  }

  Future<List<WorkoutProgram>> getAllPrograms() async {
    return _isar.workoutPrograms.where().findAll();
  }

  Future<List<WorkoutTemplate>> getProgramDays(int programId) async {
    return _isar.workoutTemplates
        .filter()
        .programIdEqualTo(programId)
        .sortByOrder()
        .findAll();
  }

  /// Sceglie il giorno con `lastUsedAt` meno recente (o mai eseguito), così la
  /// rotazione si auto-corregge anche se l'utente salta o ripete un giorno fuori
  /// sequenza. Tie-break sull'`order` per il primo utilizzo (tutti `lastUsedAt` null).
  Future<WorkoutTemplate?> getNextDayForProgram(int programId) async {
    final days = await getProgramDays(programId);
    if (days.isEmpty) return null;
    days.sort((a, b) {
      if (a.lastUsedAt == null && b.lastUsedAt == null) {
        return a.order.compareTo(b.order);
      }
      if (a.lastUsedAt == null) return -1;
      if (b.lastUsedAt == null) return 1;
      return a.lastUsedAt!.compareTo(b.lastUsedAt!);
    });
    return days.first;
  }

  Future<Id> saveWorkoutTemplate(WorkoutTemplate template) async {
    late Id id;
    await _isar.writeTxn(() async {
      id = await _isar.workoutTemplates.put(template);
    });
    return id;
  }

  Future<Id> saveWorkoutProgram(WorkoutProgram program) async {
    late Id id;
    await _isar.writeTxn(() async {
      id = await _isar.workoutPrograms.put(program);
    });
    return id;
  }

  /// Impedisce di eliminare l'ultimo giorno rimasto di un programma (lo lascerebbe
  /// vuoto). Ritorna `false` senza eliminare in quel caso.
  Future<bool> deleteWorkoutTemplate(Id id) async {
    final template = await _isar.workoutTemplates.get(id);
    if (template == null) return true;
    if (template.programId != null) {
      final days = await getProgramDays(template.programId!);
      if (days.length <= 1) return false;
    }
    await _isar.writeTxn(() async {
      await _isar.workoutTemplates.delete(id);
    });
    return true;
  }

  Future<void> deleteWorkoutProgram(Id id) async {
    await _isar.writeTxn(() async {
      final days = await _isar.workoutTemplates.filter().programIdEqualTo(id).findAll();
      await _isar.workoutTemplates.deleteAll(days.map((d) => d.id).toList());
      await _isar.workoutPrograms.delete(id);
    });
  }

  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate original,
      {int? programId, int? order}) async {
    final copy = WorkoutTemplate()
      ..name = original.name
      ..createdAt = DateTime.now()
      ..isPreset = false
      ..programId = programId
      ..order = order ?? original.order
      ..exercises = original.exercises
          .map((e) => WorkoutTemplateExercise()
            ..exerciseId = e.exerciseId
            ..exerciseName = e.exerciseName
            ..targetSets = e.targetSets
            ..targetReps = e.targetReps
            ..targetWeightKg = e.targetWeightKg
            ..targetDurationSeconds = e.targetDurationSeconds
            ..supersetGroupId = e.supersetGroupId
            ..restSeconds = e.restSeconds
            ..supersetRole = e.supersetRole
            ..plannedSets = e.plannedSets?.map((s) => s.copy()).toList())
          .toList();
    copy.id = await saveWorkoutTemplate(copy);
    return copy;
  }

  Future<WorkoutProgram> duplicateProgram(WorkoutProgram original) async {
    final copy = WorkoutProgram()
      ..name = original.name
      ..createdAt = DateTime.now()
      ..isPreset = false;
    copy.id = await saveWorkoutProgram(copy);

    final days = await getProgramDays(original.id);
    for (final day in days) {
      await duplicateTemplate(day, programId: copy.id);
    }
    return copy;
  }

  /// Genera il log del giorno a partire dai target della scheda (la pre-compilazione
  /// con il suggerimento di progressive overload è Fase 7/8). Aggiorna `lastUsedAt`.
  ///
  /// Se la scheda è già stata avviata quel giorno (stesso `sourceTemplateId`
  /// già presente nel log), riprende quegli esercizi invece di ricrearli da
  /// zero: altrimenti premere di nuovo "Inizia" (es. dopo che l'app è stata
  /// riaperta da background/kill del processo) duplica l'intera scheda con
  /// tutto non confermato, e la sessione guidata — che lavora su tutti gli
  /// esercizi del giorno — non risulta mai completabile.
  Future<List<WorkoutExercise>> startWorkoutFromTemplate(
      WorkoutTemplate template, DateTime date) async {
    final day = _logDate(date);
    final existing = await _isar.workoutExercises
        .filter()
        .dateEqualTo(day)
        .sourceTemplateIdEqualTo(template.id)
        .findAll();
    if (existing.isNotEmpty) return existing;

    final program =
        template.programId != null ? await _isar.workoutPrograms.get(template.programId!) : null;
    final created = <WorkoutExercise>[];
    for (final te in template.exercises) {
      final isCardio = te.isCardio;
      final we = WorkoutExercise()
        ..exerciseId = te.exerciseId
        ..exerciseName = te.exerciseName
        ..date = day
        ..supersetGroupId = te.supersetGroupId
        ..restSeconds = te.restSeconds
        ..supersetRole = te.supersetRole
        ..durationSeconds = te.targetDurationSeconds
        ..sourceTemplateId = template.id
        ..sourceTemplateName = template.name
        ..sourceProgramId = program?.id
        ..sourceProgramName = program?.name
        ..sets = isCardio ? [] : te.materializeSets();
      await addWorkoutExercise(day, we);
      created.add(we);
    }
    template.lastUsedAt = day;
    await saveWorkoutTemplate(template);
    return created;
  }

  // ──────────────────────────────────────────────
  // Backup / migrazione dati
  // ──────────────────────────────────────────────

  /// Copia compattata e coerente del database corrente, pronta da
  /// condividere. Isar raccomanda `copyToFile` per i backup (vedi doc del
  /// metodo nel package).
  Future<File> exportBackup() async {
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().microsecondsSinceEpoch;
    final target = File('${tempDir.path}/plico_backup_$ts.isar');
    // mdbx_env_copy (usato da copyToFile) fallisce con FileExists se il
    // target è già presente: su iOS NSTemporaryDirectory() può conservare
    // file di export precedenti tra un tentativo e l'altro.
    if (await target.exists()) {
      await target.delete();
    }
    await _isar.copyToFile(target.path);
    return target;
  }

  /// Verifica che [file] sia un backup Isar valido con lo schema atteso,
  /// senza toccare il database reale: lo apre in un'istanza temporanea
  /// isolata (nome e percorso diversi da quello reale) e la richiude
  /// subito dopo.
  Future<bool> validateBackupFile(File file) async {
    final tempDir = await getTemporaryDirectory();
    final probeDir = Directory(
        '${tempDir.path}/backup_probe_${DateTime.now().microsecondsSinceEpoch}');
    await probeDir.create(recursive: true);
    try {
      final probeFile = File('${probeDir.path}/probe.isar');
      await file.copy(probeFile.path);
      final probe = await Isar.open(
        _schemas,
        directory: probeDir.path,
        name: 'probe_${DateTime.now().microsecondsSinceEpoch}',
      );
      await probe.close();
      return true;
    } catch (_) {
      return false;
    } finally {
      if (await probeDir.exists()) await probeDir.delete(recursive: true);
    }
  }

  /// Sostituisce il database reale con [file], che va validato PRIMA con
  /// [validateBackupFile]. Chiude l'istanza corrente, tiene una copia di
  /// sicurezza del file attuale finché la sostituzione non è confermata,
  /// poi riapre. Dopo un import riuscito il chiamante deve ricostruire la
  /// navigazione da zero: qualunque `watch()` già sottoscritto punta
  /// all'istanza appena chiusa e non si aggiornerà più.
  Future<void> importBackup(File file) async {
    final dirPath = (await getApplicationDocumentsDirectory()).path;
    final realFile = File('$dirPath/default.isar');
    final safetyCopy = File('$dirPath/default.isar.bak');

    await _isar.close();
    if (await realFile.exists()) {
      await realFile.copy(safetyCopy.path);
    }
    try {
      await file.copy(realFile.path);
      _isar = await Isar.open(_schemas, directory: dirPath);
      if (await safetyCopy.exists()) await safetyCopy.delete();
    } catch (_) {
      if (await safetyCopy.exists()) {
        await safetyCopy.copy(realFile.path);
      }
      _isar = await Isar.open(_schemas, directory: dirPath);
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Coach (chat Gemini — docs/integrazione_flutter_gemma.md, Fase 7)
  // ──────────────────────────────────────────────

  /// Un'unica conversazione continua (non una per sessione/giorno): ordinata
  /// per data di creazione, così sopravvive a un riavvio dell'app. Limitata
  /// ai più recenti [_coachMessageLimit] per non far crescere senza limiti
  /// né la query né la history tenuta in memoria dalla UI — un uso normale
  /// non arriva mai a toccare il limite, entra in gioco solo su una
  /// conversazione mai azzerata per mesi.
  Future<List<CoachMessage>> getCoachMessages() async {
    final recent = await _isar.coachMessages
        .where()
        .sortByCreatedAtDesc()
        .limit(_coachMessageLimit)
        .findAll();
    return recent.reversed.toList();
  }

  Future<void> addCoachMessage(CoachMessage message) async {
    await _isar.writeTxn(() async {
      await _isar.coachMessages.put(message);
    });
  }

  /// "Nuova conversazione": azzera la cronologia persistita.
  Future<void> clearCoachMessages() async {
    await _isar.writeTxn(() async {
      await _isar.coachMessages.clear();
    });
  }

  // ──────────────────────────────────────────────
  // Utility
  // ──────────────────────────────────────────────

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
