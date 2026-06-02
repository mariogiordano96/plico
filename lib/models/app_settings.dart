import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1; // single record

  bool isDarkMode = false;
  int livelloAttivita = 2; // 0=sedentario 1=legg.attivo 2=mod.attivo 3=molto attivo 4=atleta
  int metodoTdee = 0;     // 0=auto 1=katch-mcArdle 2=mifflin-stJeor 3=harris-benedict
  int obiettivo = 1;      // 0=deficit 1=mantenimento 2=surplus
}
