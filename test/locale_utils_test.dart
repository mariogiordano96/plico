import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plico/utils/locale_utils.dart';

void main() {
  const supported = [Locale('en'), Locale('it')];

  group('resolveInitialLocale', () {
    test('sceglie la prima lingua di sistema supportata', () {
      expect(
        resolveInitialLocale([const Locale('it', 'IT')], supported),
        const Locale('it'),
      );
    });

    test('rispetta l\'ordine di preferenza di sistema', () {
      expect(
        resolveInitialLocale([const Locale('fr'), const Locale('it'), const Locale('en')], supported),
        const Locale('it'),
      );
    });

    test('nessuna lingua di sistema supportata: fallback alla prima supportata', () {
      expect(
        resolveInitialLocale([const Locale('fr'), const Locale('de')], supported),
        const Locale('en'),
      );
    });

    test('lista di sistema vuota: fallback alla prima supportata', () {
      expect(resolveInitialLocale([], supported), const Locale('en'));
    });
  });
}
