import 'dart:math';
import '../models/enums.dart';

class PlicometryResult {
  final double bodyFatPercent;
  final double massaGrassaKg;
  final double massaMagraKg;
  final double sommaPlicheMm;
  final double? densitaCorporea;

  const PlicometryResult({
    required this.bodyFatPercent,
    required this.massaGrassaKg,
    required this.massaMagraKg,
    required this.sommaPlicheMm,
    this.densitaCorporea,
  });
}

class PlicometryCalculator {
  static double _log10(double x) => log(x) / log(10);

  static PlicometryResult _fromDensity({
    required double density,
    required double pesoKg,
    required double somma,
  }) {
    final bf = ((4.95 / density) - 4.50) * 100;
    final bfClamped = bf.clamp(1.0, 70.0);
    return PlicometryResult(
      bodyFatPercent: bfClamped,
      massaGrassaKg: pesoKg * bfClamped / 100,
      massaMagraKg: pesoKg * (1 - bfClamped / 100),
      sommaPlicheMm: somma,
      densitaCorporea: density,
    );
  }

  static PlicometryResult calculate({
    required MetodoPlicometria metodo,
    required Sesso sesso,
    required int eta,
    required double pesoKg,
    required Map<String, double> pliche,
    double altezzaCm = 0,
  }) {
    switch (metodo) {
      case MetodoPlicometria.durninWomersley:
        return _durninWomersley(sesso: sesso, eta: eta, pesoKg: pesoKg, pliche: pliche);
      case MetodoPlicometria.jacksonPollock3:
        return _jacksonPollock3(sesso: sesso, eta: eta, pesoKg: pesoKg, pliche: pliche);
      case MetodoPlicometria.jacksonPollock7:
        return _jacksonPollock7(sesso: sesso, eta: eta, pesoKg: pesoKg, pliche: pliche);
      case MetodoPlicometria.faulkner:
        return _faulkner(pesoKg: pesoKg, pliche: pliche);
      case MetodoPlicometria.usNavy:
        return _usNavy(sesso: sesso, pesoKg: pesoKg, altezzaCm: altezzaCm, misure: pliche);
    }
  }

  // ── Durnin & Womersley (1974) ─────────────────
  // Pliche: bicipite + tricipite + sottoscapolare + sovrailiaca
  static PlicometryResult _durninWomersley({
    required Sesso sesso,
    required int eta,
    required double pesoKg,
    required Map<String, double> pliche,
  }) {
    final sum = (pliche['bicipite'] ?? 0) +
        (pliche['tricipite'] ?? 0) +
        (pliche['sottoscapolare'] ?? 0) +
        (pliche['sovrailiaca'] ?? 0);

    double c, m;
    if (sesso == Sesso.maschio) {
      if (eta < 20)      { c = 1.1620; m = 0.0630; }
      else if (eta < 30) { c = 1.1631; m = 0.0632; }
      else if (eta < 40) { c = 1.1422; m = 0.0544; }
      else if (eta < 50) { c = 1.1620; m = 0.0700; }
      else               { c = 1.1715; m = 0.0779; }
    } else {
      if (eta < 20)      { c = 1.1549; m = 0.0678; }
      else if (eta < 30) { c = 1.1599; m = 0.0717; }
      else if (eta < 40) { c = 1.1423; m = 0.0632; }
      else if (eta < 50) { c = 1.1333; m = 0.0612; }
      else               { c = 1.1339; m = 0.0645; }
    }

    final density = c - m * _log10(sum);
    return _fromDensity(density: density, pesoKg: pesoKg, somma: sum);
  }

  // ── Jackson & Pollock 3 pliche ────────────────
  // Uomo: pettorale + addome + coscia
  // Donna: tricipite + sovrailiaca + coscia
  static PlicometryResult _jacksonPollock3({
    required Sesso sesso,
    required int eta,
    required double pesoKg,
    required Map<String, double> pliche,
  }) {
    double sum, density;
    if (sesso == Sesso.maschio) {
      sum = (pliche['pettorale'] ?? 0) +
            (pliche['addome'] ?? 0) +
            (pliche['coscia'] ?? 0);
      density = 1.10938 - (0.0008267 * sum) + (0.0000016 * sum * sum) - (0.0002574 * eta);
    } else {
      sum = (pliche['tricipite'] ?? 0) +
            (pliche['sovrailiaca'] ?? 0) +
            (pliche['coscia'] ?? 0);
      density = 1.0994921 - (0.0009929 * sum) + (0.0000023 * sum * sum) - (0.0001392 * eta);
    }
    return _fromDensity(density: density, pesoKg: pesoKg, somma: sum);
  }

  // ── Jackson & Pollock 7 pliche ────────────────
  // Uomo e Donna: pettorale + tricipite + sottoscapolare + ascellare + sovrailiaca + addome + coscia
  static PlicometryResult _jacksonPollock7({
    required Sesso sesso,
    required int eta,
    required double pesoKg,
    required Map<String, double> pliche,
  }) {
    final sum = (pliche['pettorale'] ?? 0) +
        (pliche['tricipite'] ?? 0) +
        (pliche['sottoscapolare'] ?? 0) +
        (pliche['ascellare'] ?? 0) +
        (pliche['sovrailiaca'] ?? 0) +
        (pliche['addome'] ?? 0) +
        (pliche['coscia'] ?? 0);

    double density;
    if (sesso == Sesso.maschio) {
      density = 1.112 - (0.00043499 * sum) + (0.00000055 * sum * sum) - (0.00028826 * eta);
    } else {
      density = 1.097 - (0.00046971 * sum) + (0.00000056 * sum * sum) - (0.00012828 * eta);
    }
    return _fromDensity(density: density, pesoKg: pesoKg, somma: sum);
  }

  // ── Faulkner (1968) ───────────────────────────
  // Pliche: tricipite + sottoscapolare + sovrailiaca + addome
  static PlicometryResult _faulkner({
    required double pesoKg,
    required Map<String, double> pliche,
  }) {
    final sum = (pliche['tricipite'] ?? 0) +
        (pliche['sottoscapolare'] ?? 0) +
        (pliche['sovrailiaca'] ?? 0) +
        (pliche['addome'] ?? 0);

    final bf = (sum * 0.153) + 5.783;
    final bfClamped = bf.clamp(1.0, 70.0);
    return PlicometryResult(
      bodyFatPercent: bfClamped,
      massaGrassaKg: pesoKg * bfClamped / 100,
      massaMagraKg: pesoKg * (1 - bfClamped / 100),
      sommaPlicheMm: sum,
    );
  }

  // ── US Navy (Hodgdon & Beckett, 1984) ────────
  // Uomo: collo, vita, altezza
  // Donna: collo, vita, fianchi, altezza
  static PlicometryResult _usNavy({
    required Sesso sesso,
    required double pesoKg,
    required double altezzaCm,
    required Map<String, double> misure,
  }) {
    double bf;
    if (sesso == Sesso.maschio) {
      final collo = misure['collo'] ?? 0;
      final vita  = misure['vita']  ?? 0;
      bf = 495 / (1.0324 - 0.19077 * _log10(vita - collo) + 0.15456 * _log10(altezzaCm)) - 450;
    } else {
      final collo  = misure['collo']  ?? 0;
      final vita   = misure['vita']   ?? 0;
      final fianchi = misure['fianchi'] ?? 0;
      bf = 495 / (1.29579 - 0.35004 * _log10(vita + fianchi - collo) + 0.22100 * _log10(altezzaCm)) - 450;
    }
    final bfClamped = bf.clamp(1.0, 70.0);
    return PlicometryResult(
      bodyFatPercent: bfClamped,
      massaGrassaKg: pesoKg * bfClamped / 100,
      massaMagraKg: pesoKg * (1 - bfClamped / 100),
      sommaPlicheMm: 0,
    );
  }

  // ── Categoria BF% ─────────────────────────────
  static BfCategory categoria(double bf, Sesso sesso) {
    if (sesso == Sesso.maschio) {
      if (bf < 6)  return BfCategory.grassoEssenziale;
      if (bf < 14) return BfCategory.atleta;
      if (bf < 18) return BfCategory.fitness;
      if (bf < 25) return BfCategory.accettabile;
      return BfCategory.obeso;
    } else {
      if (bf < 14) return BfCategory.grassoEssenziale;
      if (bf < 21) return BfCategory.atleta;
      if (bf < 25) return BfCategory.fitness;
      if (bf < 32) return BfCategory.accettabile;
      return BfCategory.obeso;
    }
  }
}

enum BfCategory {
  grassoEssenziale,
  atleta,
  fitness,
  accettabile,
  obeso;

  String get label {
    switch (this) {
      case grassoEssenziale: return 'Grasso Essenziale';
      case atleta:           return 'Atleta';
      case fitness:          return 'Fitness';
      case accettabile:      return 'Accettabile';
      case obeso:            return 'Sovrappeso';
    }
  }
}
