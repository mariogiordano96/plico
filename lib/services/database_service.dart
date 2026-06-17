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

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late Isar _isar;

  static const _schemas = [
    UserProfileSchema, BodySnapshotSchema, PlicometrySessionSchema,
    AppSettingsSchema, MeasurementSnapshotSchema, FoodItemSchema,
    DailyLogSchema, UserFoodPreferencesSchema, MealPlanSchema,
    AchievementSchema,
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

  Future<DateTime?> getGoalSetDate() async {
    final settings = await _isar.appSettings.get(1);
    return settings?.goalSetDate;
  }

  Future<void> activateGoal({
    required int livello,
    required int metodo,
    required int obiettivo,
  }) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.appSettings.get(1) ?? AppSettings();
      settings.livelloAttivita = livello;
      settings.metodoTdee = metodo;
      settings.obiettivo = obiettivo;
      settings.goalSetDate = DateTime.now();
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
    if (query.trim().isEmpty) {
      return _isar.foodItems
          .filter()
          .isFavoriteEqualTo(true)
          .or()
          .isCustomEqualTo(true)
          .sortByNome()
          .findAll();
    }
    return _isar.foodItems
        .filter()
        .nomeContains(query, caseSensitive: false)
        .sortByNome()
        .findAll();
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
  // Utility
  // ──────────────────────────────────────────────

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
