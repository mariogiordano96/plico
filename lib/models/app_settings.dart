import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1; // single record

  bool isDarkMode = false;
  int livelloAttivita = 2; // 0=sedentario 1=legg.attivo 2=mod.attivo 3=molto attivo 4=atleta
  int metodoTdee = 0;     // 0=auto 1=katch-mcArdle 2=mifflin-stJeor 3=harris-benedict
  int obiettivo = 1;      // 0=deficit 1=mantenimento 2=surplus
  bool creaSeeded = false;
  bool exercisesSeeded = false;
  bool workoutPresetsSeeded = false;
  // Migrazione una-tantum: rinomina gli alimenti già in DB secondo i nomi
  // normalizzati correnti (matching per creaCode, stabile) — necessaria per
  // chi aveva installato l'app prima della normalizzazione dei nomi, altrimenti
  // il vecchio nome in Isar non fa più match con `PianoService.curatedNames`.
  bool foodNamesNormalizedV2 = false;
  DateTime? goalSetDate;
  double? pesoObiettivo;

  // Promemoria pasti
  bool notificheAttive = false;
  bool notColAttiva = true;
  bool notPranzoAttiva = true;
  bool notCenaAttiva = true;
  bool notSpuntinoAttiva = false;
  bool notPostWoAttiva = false;
  bool notSorAttiva = false;
  int notColMin = 450;      // 7:30
  int notPranzoMin = 750;   // 12:30
  int notCenaMin = 1170;    // 19:30
  int notSpuntinoMin = 630; // 10:30
  int notPostWoMin = 1020;  // 17:00
  int notSorMin = 1260;     // 21:00

  bool tourCompleted = false;

  // Allenamento — Fase 8
  int restTimerDefaultSeconds = 90;

  // Allenamento — Fase 10
  bool notWorkoutAttiva = false;
}
