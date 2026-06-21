import '../../l10n/app_localizations.dart';

const muscleGroups = ['chest', 'back', 'legs', 'arms', 'shoulders', 'core', 'cardio'];

String muscleGroupLabel(AppLocalizations l10n, String? group) {
  switch (group) {
    case 'chest':
      return l10n.muscleGroupChest;
    case 'back':
      return l10n.muscleGroupBack;
    case 'legs':
      return l10n.muscleGroupLegs;
    case 'arms':
      return l10n.muscleGroupArms;
    case 'shoulders':
      return l10n.muscleGroupShoulders;
    case 'core':
      return l10n.muscleGroupCore;
    case 'cardio':
      return l10n.muscleGroupCardio;
    default:
      return l10n.muscleGroupAll;
  }
}
