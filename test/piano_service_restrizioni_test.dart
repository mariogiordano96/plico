import 'package:flutter_test/flutter_test.dart';
import 'package:plico/services/piano_service.dart';

void main() {
  group('PianoService.excludedByRestrizioni', () {
    test('nessuna restrizione → nessuna categoria esclusa', () {
      expect(PianoService.excludedByRestrizioni([]), isEmpty);
    });

    test('vegetariano esclude carne e pesce ma non uova/latticini', () {
      final excluded = PianoService.excludedByRestrizioni(['vegetariano']);
      expect(excluded, containsAll(['Carni fresche', 'Prodotti della pesca']));
      expect(excluded, isNot(contains('Uova')));
      expect(excluded, isNot(contains('Latte e yogurt')));
    });

    test('vegano esclude anche uova e latticini oltre a carne/pesce', () {
      final excluded = PianoService.excludedByRestrizioni(['vegano']);
      expect(
        excluded,
        containsAll([
          'Carni fresche',
          'Prodotti della pesca',
          'Uova',
          'Latte e yogurt',
          'Formaggi e latticini',
        ]),
      );
    });

    test('no_lattosio esclude solo le categorie di latticini', () {
      final excluded = PianoService.excludedByRestrizioni(['no_lattosio']);
      expect(excluded, containsAll(['Latte e yogurt', 'Formaggi e latticini']));
      expect(excluded, isNot(contains('Carni fresche')));
    });

    test('no_glutine, no_pesce, no_fruttaSecca escludono ciascuna una sola categoria', () {
      expect(PianoService.excludedByRestrizioni(['no_glutine']), ['Cereali e derivati']);
      expect(PianoService.excludedByRestrizioni(['no_pesce']), ['Prodotti della pesca']);
      expect(
        PianoService.excludedByRestrizioni(['no_fruttaSecca']),
        ['Frutta secca a guscio e semi oleaginosi'],
      );
    });

    test('più restrizioni insieme si combinano senza duplicati', () {
      final excluded =
          PianoService.excludedByRestrizioni(['vegano', 'no_lattosio', 'no_glutine']);
      expect(excluded.toSet().length, excluded.length); // nessun duplicato (usa un Set interno)
      expect(
        excluded,
        containsAll(['Carni fresche', 'Uova', 'Latte e yogurt', 'Cereali e derivati']),
      );
    });
  });
}
