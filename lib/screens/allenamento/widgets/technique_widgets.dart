import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Chip di selezione tecnica (normale/forzate/rest-pause/stripping/super
/// slow), condiviso tra sessione guidata (`sessione_guidata_screen.dart`) e
/// pianificazione tecniche in creazione scheda (`target_esercizio_dialog.dart`,
/// Fase 7 di docs/tecniche_allenamento.md).
class TechniqueChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ColorPalette p;
  final VoidCallback onTap;
  const TechniqueChip(
      {super.key, required this.label, required this.selected, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.15) : p.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? p.accent : p.cardBorder),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: selected ? p.accent : p.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

/// Campo numerico compatto senza label (reps/peso/cluster/gradino), condiviso
/// tra sessione guidata e pianificazione tecniche in creazione scheda.
class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ColorPalette p;
  const NumberField({super.key, required this.controller, required this.hint, required this.p});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: p.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textMuted),
        isDense: true,
        filled: true,
        fillColor: p.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.cardBorder),
        ),
      ),
    );
  }
}
