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
      'come resetto la password di instagram',
      'how do I reset my password on facebook',
      'il wifi di casa non si connette, che faccio?',
      'my wifi won\'t connect, help',
      'come aggiorno android sul telefono',
      'how do I update ios on my phone',
      'chi è il fidanzato di quella cantante famosa?',
      'who is dating that famous actor',
      'qual è la trama del film uscito ieri?',
      'what is the plot of the movie everyone is talking about',
      'consigliami una serie tv da guardare',
      'what tv series should I watch this weekend',
      'conviene investire in bitcoin adesso?',
      'should I invest in bitcoin right now',
      'come si fa la dichiarazione dei redditi',
      'how do I file my taxes this year',
      'come faccio a separarmi da mio marito',
      'how do I get a divorce',
      'traducimi questa frase in inglese',
      'translate this sentence into french',
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
      'il mio garmin non si sincronizza con l\'app, cosa faccio?',
      'my fitness tracker won\'t sync with the app, help',
      'mi motiva guardare video di allenamento su youtube, hai consigli?',
      'come si dice squat in inglese?',
      'conviene investire di più tempo in cardio o pesi questa settimana?',
      'quanto devo spendere per un buon integratore proteico?',
      'traduci la lista degli ingredienti di questa ricetta in inglese',
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
