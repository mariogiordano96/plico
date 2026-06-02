import 'package:isar/isar.dart';

part 'measurement_snapshot.g.dart';

@collection
class MeasurementSnapshot {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime data; // normalizzata a mezzanotte (un record per giorno)

  List<String> fonti = []; // es. ['manuale', 'jacksonPollock3']

  // ── Pliche (mm) ──────────────────────────────
  double? tricipiteMm;
  double? bicipiteMm;
  double? pettoraleMm;
  double? ascelllareMm;
  double? sottoscapolareMm;
  double? sovrailiachMm;
  double? addomineMm;
  double? cosciaMm;
  double? polpaccioMm;

  // ── Circonferenze (cm) ───────────────────────
  double? colloCm;
  double? vitaCm;
  double? fianchiCm;
  double? braccioCm;
  double? cosciaCm;
  double? polpaccioCm;
  double? toraceCm;
  double? spalleCm;

  // ── Helpers ──────────────────────────────────
  int get contPliche => [
        tricipiteMm, bicipiteMm, pettoraleMm, ascelllareMm,
        sottoscapolareMm, sovrailiachMm, addomineMm, cosciaMm, polpaccioMm,
      ].where((v) => v != null).length;

  int get contCirconferenze => [
        colloCm, vitaCm, fianchiCm, braccioCm, cosciaCm,
        polpaccioCm, toraceCm, spalleCm,
      ].where((v) => v != null).length;
}
