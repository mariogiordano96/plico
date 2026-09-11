import 'package:flutter/material.dart';
import '../models/exercise_definition.dart';
import '../theme/app_theme.dart';

/// Miniatura quadrata per un esercizio del catalogo. Mostra l'icona di
/// fallback per gli esercizi custom o per quelli senza foto nel dataset
/// sorgente (`ExerciseDefinition.imageAssetPath` torna null, o l'asset
/// manca — gestito con errorBuilder invece di controllare l'esistenza del
/// file, più semplice e senza I/O extra).
class ExerciseThumbnail extends StatelessWidget {
  final ExerciseDefinition exercise;
  final double size;

  const ExerciseThumbnail({super.key, required this.exercise, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final path = exercise.imageAssetPath;

    Widget fallback = Icon(Icons.fitness_center_rounded, color: p.textMuted, size: size * 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: p.surfaceVariant,
        child: path == null
            ? fallback
            : Image.asset(
                path,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
