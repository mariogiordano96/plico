import 'package:flutter_test/flutter_test.dart';
import 'package:plico/models/enums.dart';
import 'package:plico/services/plicometry_calculator.dart';

void main() {
  group('PlicometryCalculator.calculate — Durnin-Womersley', () {
    test('uomo, 25 anni: bf% e masse coerenti con peso e somma pliche', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.durninWomersley,
        sesso: Sesso.maschio,
        eta: 25,
        pesoKg: 80,
        pliche: {
          'bicipite': 8,
          'tricipite': 12,
          'sottoscapolare': 15,
          'sovrailiaca': 18,
        },
      );
      expect(r.sommaPlicheMm, 53);
      expect(r.densitaCorporea, isNotNull);
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
      expect(r.massaGrassaKg + r.massaMagraKg, closeTo(80, 0.01));
    });

    test('donna, età diversa usa coefficienti diversi dall\'uomo', () {
      final pliche = {
        'bicipite': 8.0,
        'tricipite': 12.0,
        'sottoscapolare': 15.0,
        'sovrailiaca': 18.0,
      };
      final uomo = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.durninWomersley,
        sesso: Sesso.maschio,
        eta: 25,
        pesoKg: 80,
        pliche: pliche,
      );
      final donna = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.durninWomersley,
        sesso: Sesso.femmina,
        eta: 25,
        pesoKg: 80,
        pliche: pliche,
      );
      expect(uomo.bodyFatPercent, isNot(equals(donna.bodyFatPercent)));
    });
  });

  group('PlicometryCalculator.calculate — Jackson-Pollock 3 pliche', () {
    test('uomo usa pettorale+addome+coscia', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.jacksonPollock3,
        sesso: Sesso.maschio,
        eta: 30,
        pesoKg: 75,
        pliche: {'pettorale': 10, 'addome': 15, 'coscia': 12},
      );
      expect(r.sommaPlicheMm, 37);
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
    });

    test('donna usa tricipite+sovrailiaca+coscia', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.jacksonPollock3,
        sesso: Sesso.femmina,
        eta: 30,
        pesoKg: 60,
        pliche: {'tricipite': 14, 'sovrailiaca': 16, 'coscia': 20},
      );
      expect(r.sommaPlicheMm, 50);
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
    });
  });

  group('PlicometryCalculator.calculate — Jackson-Pollock 7 pliche', () {
    test('somma le 7 pliche indicate', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.jacksonPollock7,
        sesso: Sesso.maschio,
        eta: 28,
        pesoKg: 82,
        pliche: {
          'pettorale': 8,
          'tricipite': 10,
          'sottoscapolare': 12,
          'ascellare': 9,
          'sovrailiaca': 14,
          'addome': 16,
          'coscia': 13,
        },
      );
      expect(r.sommaPlicheMm, 82);
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
    });
  });

  group('PlicometryCalculator.calculate — Faulkner', () {
    test('formula lineare su tricipite+sottoscapolare+sovrailiaca+addome', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.faulkner,
        sesso: Sesso.maschio,
        eta: 30,
        pesoKg: 70,
        pliche: {
          'tricipite': 10,
          'sottoscapolare': 10,
          'sovrailiaca': 10,
          'addome': 10,
        },
      );
      // somma = 40 -> bf = 40*0.153 + 5.783 = 11.903
      expect(r.sommaPlicheMm, 40);
      expect(r.bodyFatPercent, closeTo(11.903, 0.01));
    });
  });

  group('PlicometryCalculator.calculate — US Navy', () {
    test('uomo usa collo/vita/altezza', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.usNavy,
        sesso: Sesso.maschio,
        eta: 30,
        pesoKg: 80,
        altezzaCm: 178,
        pliche: {'collo': 38, 'vita': 85},
      );
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
    });

    test('donna richiede anche i fianchi', () {
      final r = PlicometryCalculator.calculate(
        metodo: MetodoPlicometria.usNavy,
        sesso: Sesso.femmina,
        eta: 28,
        pesoKg: 62,
        altezzaCm: 165,
        pliche: {'collo': 32, 'vita': 70, 'fianchi': 95},
      );
      expect(r.bodyFatPercent, inInclusiveRange(1.0, 70.0));
    });
  });

  group('PlicometryCalculator.categoria', () {
    test('soglie uomo', () {
      expect(PlicometryCalculator.categoria(5, Sesso.maschio), BfCategory.grassoEssenziale);
      expect(PlicometryCalculator.categoria(10, Sesso.maschio), BfCategory.atleta);
      expect(PlicometryCalculator.categoria(16, Sesso.maschio), BfCategory.fitness);
      expect(PlicometryCalculator.categoria(20, Sesso.maschio), BfCategory.accettabile);
      expect(PlicometryCalculator.categoria(30, Sesso.maschio), BfCategory.obeso);
    });

    test('soglie donna (diverse dall\'uomo)', () {
      expect(PlicometryCalculator.categoria(12, Sesso.femmina), BfCategory.grassoEssenziale);
      expect(PlicometryCalculator.categoria(18, Sesso.femmina), BfCategory.atleta);
      expect(PlicometryCalculator.categoria(23, Sesso.femmina), BfCategory.fitness);
      expect(PlicometryCalculator.categoria(28, Sesso.femmina), BfCategory.accettabile);
      expect(PlicometryCalculator.categoria(35, Sesso.femmina), BfCategory.obeso);
    });
  });
}
