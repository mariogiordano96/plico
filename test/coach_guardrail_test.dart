import 'package:flutter_test/flutter_test.dart';
import 'package:plico/services/coach_guardrail.dart';

void main() {
  group('CoachGuardrail.isOffTopic — bloccate', () {
    final cases = [
      'scrivimi il codice per una funzione python',
      'help me debug this script',
      'ho i compiti di matematica per domani',
      'homework on history please',
      'chi è il presidente degli stati uniti?',
      'who is the president of france',
      'qual è la capitale della Francia?',
      'what is the capital of Italy',
      'scrivimi una poesia sull\'autunno',
      'write me a short story about a dragon',
      'che tempo fa domani a Milano?',
      'what\'s the weather like tomorrow',
    ];
    for (final text in cases) {
      test('"$text" è fuori tema', () {
        expect(CoachGuardrail.isOffTopic(text), isTrue);
      });
    }
  });

  group('CoachGuardrail.isOffTopic — permesse (dominio o ambigue)', () {
    final cases = [
      'quante proteine devo mangiare al giorno?',
      'dammi un programma di allenamento per le gambe',
      'come faccio a fare più serie di squat?',
      'raccontami come strutturare la dieta della settimana',
      'quanti carboidrati ha il riso?',
      'ho dolore al ginocchio dopo la corsa, cosa faccio?',
      'dammi una ricetta veloce con pollo e riso',
      'what should I eat before a workout?',
      'how many sets of bench press should I do?',
      '',
      '   ',
    ];
    for (final text in cases) {
      test('"$text" NON è fuori tema', () {
        expect(CoachGuardrail.isOffTopic(text), isFalse);
      });
    }
  });
}
