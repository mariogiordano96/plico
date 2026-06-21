import 'dart:convert';

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
import '../models/workout_template.dart';
import '../models/workout_template_exercise.dart';
import '../models/workout_program.dart';
import '../models/workout_set.dart';
import '../models/personal_record.dart';
import 'exercise_alternatives_service.dart';
import 'workout_progress_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late Isar _isar;

  static const _schemas = [
    UserProfileSchema, BodySnapshotSchema, PlicometrySessionSchema,
    AppSettingsSchema, MeasurementSnapshotSchema, FoodItemSchema,
    DailyLogSchema, UserFoodPreferencesSchema, MealPlanSchema,
    AchievementSchema, MealComboSchema, ExerciseDefinitionSchema,
    WorkoutLogSchema, WorkoutExerciseSchema,
    WorkoutTemplateSchema, WorkoutProgramSchema,
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

  Future<List<FoodItem>> searchFoodItems(String query) async {
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
    if (invalidMin(s.notColMin) || invalidMin(s.notPranzoMin) || invalidMin(s.notCenaMin)) {
      s.notColMin = 450;
      s.notPranzoMin = 750;
      s.notCenaMin = 1170;
      s.notSpuntinoMin = 630;
      s.notPostWoMin = 1020;
      s.notSorMin = 1260;
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
    if (settings?.exercisesSeeded == true) return;

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
    final q = query.trim().toLowerCase();
    return all.where((e) {
      if (muscleGroup != null && e.muscleGroup != muscleGroup) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q) ||
          (e.nameIt?.toLowerCase().contains(q) ?? false);
    }).toList();
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

  /// Come [getWorkoutDaysRange], ma osservabile: emette ogni volta che cambia
  /// un [WorkoutExercise] qualsiasi.
  Stream<Set<DateTime>> watchWorkoutDays() {
    return _isar.workoutExercises
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.date).toSet());
  }

  /// Numero totale di sessioni allenamento mai registrate, dove una sessione
  /// è un giorno con almeno un [WorkoutExercise].
  Future<int> getTotalWorkoutSessionsCount() async {
    final all = await _isar.workoutExercises.where().findAll();
    return all.map((e) => e.date).toSet().length;
  }

  Future<int> getWorkoutKcalForDay(DateTime date) async {
    final esercizi = await getWorkoutExercisesForDay(date);
    return esercizi.fold<int>(0, (sum, e) => sum + (e.estimatedKcal ?? 0));
  }

  /// Giorni con almeno un allenamento nella settimana corrente (lunedì-oggi,
  /// stessa convenzione locale-aware di `WorkoutProgressService._weekKey`).
  Future<int> getWorkoutsThisWeek() async {
    final now = DateTime.now();
    final monday = _logDate(now.subtract(Duration(days: now.weekday - 1)));
    final days = await getWorkoutDaysRange(monday, now);
    return days.length;
  }

  /// Come [getWorkoutsThisWeek], ma osservabile.
  Stream<int> watchWorkoutsThisWeek() {
    return watchWorkoutDays().map((allDays) {
      final now = DateTime.now();
      final monday = _logDate(now.subtract(Duration(days: now.weekday - 1)));
      return allDays.where((d) => !d.isBefore(monday)).length;
    });
  }

  /// Numero di giorni del "programma attivo": il programma a cui appartiene
  /// la scheda con `lastUsedAt` più recente (quello che l'utente sta
  /// effettivamente seguendo). Null se nessuna scheda di un programma è mai
  /// stata eseguita.
  Future<int?> getActiveProgramDaysCount() async {
    final mostRecent = await _isar.workoutTemplates
        .filter()
        .programIdIsNotNull()
        .lastUsedAtIsNotNull()
        .sortByLastUsedAtDesc()
        .findFirst();
    if (mostRecent?.programId == null) return null;
    final days = await getProgramDays(mostRecent!.programId!);
    return days.isEmpty ? null : days.length;
  }

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
          .fold(0.0, (sum, s) => sum + (s.reps ?? 0) * (s.weightKg ?? 0));
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
            ..restSeconds = e['restSeconds'] as int?)
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

  Future<WorkoutTemplate> duplicateTemplate(WorkoutTemplate original, {int? programId}) async {
    final copy = WorkoutTemplate()
      ..name = original.name
      ..createdAt = DateTime.now()
      ..isPreset = false
      ..programId = programId
      ..order = original.order
      ..exercises = original.exercises
          .map((e) => WorkoutTemplateExercise()
            ..exerciseId = e.exerciseId
            ..exerciseName = e.exerciseName
            ..targetSets = e.targetSets
            ..targetReps = e.targetReps
            ..targetWeightKg = e.targetWeightKg
            ..targetDurationSeconds = e.targetDurationSeconds
            ..supersetGroupId = e.supersetGroupId
            ..restSeconds = e.restSeconds)
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
  Future<List<WorkoutExercise>> startWorkoutFromTemplate(
      WorkoutTemplate template, DateTime date) async {
    final day = _logDate(date);
    final created = <WorkoutExercise>[];
    for (final te in template.exercises) {
      final isCardio = te.targetDurationSeconds != null;
      final we = WorkoutExercise()
        ..exerciseId = te.exerciseId
        ..exerciseName = te.exerciseName
        ..date = day
        ..supersetGroupId = te.supersetGroupId
        ..restSeconds = te.restSeconds
        ..durationSeconds = te.targetDurationSeconds
        ..sets = isCardio
            ? []
            : List.generate(
                te.targetSets ?? 1,
                (_) => WorkoutSet()
                  ..reps = te.targetReps
                  ..weightKg = te.targetWeightKg,
              );
      await addWorkoutExercise(day, we);
      created.add(we);
    }
    template.lastUsedAt = day;
    await saveWorkoutTemplate(template);
    return created;
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
