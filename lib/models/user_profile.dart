import 'package:isar/isar.dart';
import 'enums.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = 1; // single-user: always 1

  late String nome;
  late String cognome;
  late DateTime dataNascita;

  @enumerated
  late Sesso sesso;

  late double altezzaCm;

  double? bodyFatIniziale;

  late DateTime createdAt;

  int get etaCorrente {
    final oggi = DateTime.now();
    int eta = oggi.year - dataNascita.year;
    if (oggi.month < dataNascita.month ||
        (oggi.month == dataNascita.month && oggi.day < dataNascita.day)) {
      eta--;
    }
    return eta;
  }
}
