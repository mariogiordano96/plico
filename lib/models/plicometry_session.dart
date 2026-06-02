import 'package:isar/isar.dart';
import 'enums.dart';

part 'plicometry_session.g.dart';

@collection
class PlicometrySession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime data;

  @enumerated
  late MetodoPlicometria metodo;

  late int etaAnni;
  late double pesoKg;
  late double altezzaCm;

  late Pliche pliche;
  late RisultatiPlico risultati;

  String? note;
}

@embedded
class Pliche {
  double? tricipiteMm;
  double? bicipiteMm;
  double? pettoralleMm;
  double? ascelllareMm;
  double? sottoscapolareMm;
  double? sovrailiachMm;
  double? addomineMm;
  double? cosciaMm;
  double? polpaccioMm;

  double get somma {
    return [
      tricipiteMm,
      bicipiteMm,
      pettoralleMm,
      ascelllareMm,
      sottoscapolareMm,
      sovrailiachMm,
      addomineMm,
      cosciaMm,
      polpaccioMm,
    ].whereType<double>().fold(0.0, (a, b) => a + b);
  }
}

@embedded
class RisultatiPlico {
  late double bodyFatPercent;
  late double massaGrassaKg;
  late double massaMagraKg;
  late double sommaPlicheMm;
  double? densitaCorporea;
}
