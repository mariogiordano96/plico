import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/app_settings.dart';
import '../models/measurement_snapshot.dart';
import '../models/food_item.dart';
import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/enums.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late Isar _isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserProfileSchema, BodySnapshotSchema, PlicometrySessionSchema, AppSettingsSchema, MeasurementSnapshotSchema, FoodItemSchema, DailyLogSchema],
      directory: dir.path,
    );
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

  Stream<DailyLog?> watchDailyLog(DateTime date) {
    final day = _logDate(date);
    return _isar.dailyLogs
        .filter()
        .dataEqualTo(day)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
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
