import 'database_service.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;

const _goalMult = [0.80, 1.0, 1.15];
const _protMatrix = [
  [1.4, 1.8, 2.3, 2.6, 3.1],
  [0.8, 1.2, 1.4, 1.8, 2.0],
  [1.6, 1.8, 2.0, 2.2, 2.4],
];

/// Ritorna (kcalTarget, proteinTarget, fatTarget, carbsTarget) per oggi,
/// o (null, null, null, null) se profilo/peso non sono ancora configurati.
Future<(int?, int?, int?, int?)> computeDailyTargets() async {
  final profile = await DatabaseService.instance.getUserProfile();
  final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
  if (profile == null || snapshot == null) return (null, null, null, null);
  final session = await DatabaseService.instance.getLatestPlicometrySession();
  final livello = await DatabaseService.instance.getLivelloAttivita();
  final metodo = await DatabaseService.instance.getMetodoTdee();
  final obiettivo = await DatabaseService.instance.getObiettivo();
  final result = calcolaTdee(
    sesso: profile.sesso,
    eta: profile.etaCorrente,
    altezzaCm: profile.altezzaCm,
    pesoKg: snapshot.pesoKg,
    livello: livello,
    metodo: metodo,
    massaMagraKg: session?.risultati.massaMagraKg,
  );
  if (result == null) return (null, null, null, null);
  final kcalTarget = (result.tdee * _goalMult[obiettivo.clamp(0, 2)]).round();
  final protTarget =
      (snapshot.pesoKg * _protMatrix[obiettivo.clamp(0, 2)][livello.clamp(0, 4)]).round();
  // Fat: 25% delle kcal totali; Carbs: kcal rimanenti dopo prot e grassi
  final fatTarget = (kcalTarget * 0.25 / 9).round();
  final carbsTarget = ((kcalTarget - protTarget * 4 - fatTarget * 9) / 4).round().clamp(0, 9999);
  return (kcalTarget, protTarget, fatTarget, carbsTarget);
}
