import 'package:flutter_test/flutter_test.dart';
import 'package:plico/utils/food_label.dart';

void main() {
  group('shortFoodLabel', () {
    test('non tronca i nomi già corti', () {
      expect(shortFoodLabel('Tofu'), 'Tofu');
      expect(shortFoodLabel('Chickpeas, dried, raw'), 'Chickpeas, dried, raw');
    });

    test('nomi italiani corti restano invariati (nessun troncamento necessario)', () {
      expect(shortFoodLabel('Fagioli borlotti, secchi'), 'Fagioli borlotti, secchi');
      expect(shortFoodLabel('Fagioli cannellini, secchi'), 'Fagioli cannellini, secchi');
    });

    test('nomi italiani lunghi: la virgola arriva dopo la variante,'
        ' comportamento di troncamento invariato', () {
      expect(shortFoodLabel('Prosciutto di Parma DOP, magro'), 'Prosciutto di Parma DOP');
    });

    test('bug: nomi inglesi CREA non collassano più sullo stesso'
        ' prefisso generico prima della variante', () {
      final borlotti = shortFoodLabel('Beans, Borlotti, dried, raw');
      final cannellini = shortFoodLabel('Beans, Cannellini, dried, raw');
      expect(borlotti, isNot(equals(cannellini)));
      expect(borlotti, 'Beans, Borlotti');
      expect(cannellini, 'Beans, Cannellini');
    });

    test('bug: Pasta / Pasta integrale restano distinguibili in inglese', () {
      final pasta = shortFoodLabel('Pasta, durum wheat flour, raw');
      final integrale = shortFoodLabel('Pasta, wholemeal durum wheat, raw');
      expect(pasta, isNot(equals(integrale)));
    });

    test('senza nessuna virgola, ricade sull\'ellissi per lunghezza', () {
      final result = shortFoodLabel('Supercalifragilisticexpialidocious ingredient');
      expect(result.length, lessThanOrEqualTo(24));
      expect(result, endsWith('…'));
    });
  });
}
