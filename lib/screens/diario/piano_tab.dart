import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/meal_plan.dart';
import '../../models/meal_entry.dart';
import '../../models/user_food_preferences.dart';
import '../../services/database_service.dart';
import '../../services/piano_service.dart';
import 'questionario_screen.dart';

const _diaryPastoNomi = ['Colazione', 'Pranzo', 'Cena', 'Spuntino'];
const _diaryPastoIcons = [
  Icons.free_breakfast_rounded,
  Icons.lunch_dining_rounded,
  Icons.dinner_dining_rounded,
  Icons.apple_rounded,
];

class PianoTab extends StatefulWidget {
  final DateTime currentDate;
  const PianoTab({super.key, required this.currentDate});

  @override
  State<PianoTab> createState() => _PianoTabState();
}

class _PianoTabState extends State<PianoTab> {
  UserFoodPreferences? _prefs;
  MealPlan? _plan;
  bool _loading = true;
  bool _generating = false;
  final Set<String> _expandedSlots = {};
  StreamSubscription? _settingsSub;

  @override
  void initState() {
    super.initState();
    _load();
    _settingsSub = DatabaseService.instance.watchAppSettings().listen((_) => _checkObsoleto());
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await DatabaseService.instance.getUserFoodPreferences();
    final plan = await DatabaseService.instance.getMealPlan();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _plan = plan;
      _loading = false;
    });
  }

  Future<void> _checkObsoleto() async {
    if (_plan == null || _plan!.obsoleto) return;
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final obiettivo = await DatabaseService.instance.getObiettivo();
    if (livello != _plan!.livelloAtGenerazione || obiettivo != _plan!.obiettivoAtGenerazione) {
      await DatabaseService.instance.markPlanObsoleto(true);
      final updated = await DatabaseService.instance.getMealPlan();
      if (!mounted) return;
      setState(() => _plan = updated);
    }
  }

  Future<void> _generaPiano() async {
    setState(() => _generating = true);
    final plan = await PianoService.generaPiano();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _generating = false;
    });
  }

  Future<void> _rigenera() async {
    await DatabaseService.instance.markPlanObsoleto(false);
    await _generaPiano();
  }

  Future<void> _openQuestionario() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const QuestionarioScreen()),
    );
    if (result == true) {
      await _load();
      await _generaPiano();
    }
  }

  void _addToDiary(PlanFood food, int mealTipo) {
    // Mappa tipo pasto piano → tipo pasto diario (0=col 1=pranzo 2=cena 3=spuntino)
    final suggestedPasto = mealTipo.clamp(0, 3);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PastoPicker(
        food: food,
        currentDate: widget.currentDate,
        suggestedPasto: suggestedPasto,
        onAdded: (pastoNome) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aggiunto a $pastoNome'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_loading) return Center(child: CircularProgressIndicator(color: p.accent));

    if (_prefs == null || !_prefs!.questionarioCompletato) return _buildEmptyState(p);

    if (_generating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: p.accent),
            const SizedBox(height: 16),
            Text('Generazione piano in corso…',
                style: TextStyle(color: p.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    if (_plan == null || _plan!.pasti.isEmpty) return _buildNoPlanState(p);

    return _buildPlanView(p);
  }

  // ── Stato A: nessun questionario ──────────────────────────────

  Widget _buildEmptyState(ColorPalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.restaurant_menu_rounded, size: 48, color: p.accent),
            ),
            const SizedBox(height: 24),
            Text('Piano Alimentare',
                style: TextStyle(color: p.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              'Dicci le tue preferenze alimentari e generiamo un piano personalizzato sui tuoi macro target.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _AccentButton(label: 'INIZIA QUESTIONARIO', onTap: _openQuestionario, p: p),
          ],
        ),
      ),
    );
  }

  // ── Stato B: questionario fatto, nessun piano ─────────────────

  Widget _buildNoPlanState(ColorPalette p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: p.accent),
            const SizedBox(height: 16),
            Text('Preferenze salvate',
                style: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Pronto per generare il tuo piano alimentare.',
                style: TextStyle(color: p.textMuted, fontSize: 13)),
            const SizedBox(height: 32),
            _AccentButton(label: 'GENERA PIANO', onTap: _generaPiano, p: p),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _openQuestionario,
              child: Text('Modifica preferenze', style: TextStyle(color: p.textMuted, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stato C/D: piano attivo (o obsoleto) ──────────────────────

  Widget _buildPlanView(ColorPalette p) {
    final plan = _plan!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.obsoleto) ...[
            _ObsoletoBanner(onRigenera: _rigenera, p: p),
            const SizedBox(height: 12),
          ],
          _PlanHeaderCard(plan: plan, p: p),
          const SizedBox(height: 20),

          // Pasti
          ...plan.pasti.asMap().entries.expand((mealEntry) {
            final mealIdx = mealEntry.key;
            final meal = mealEntry.value;
            final validSlots = meal.slots.where((s) => s.principale != null).toList();
            if (validSlots.isEmpty) return <Widget>[];

            return [
              _MealHeader(tipo: meal.tipo, p: p),
              const SizedBox(height: 8),
              ...validSlots.asMap().entries.map((slotEntry) {
                final slotIdx = slotEntry.key;
                final slot = slotEntry.value;
                final key = '$mealIdx-$slotIdx';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SlotCard(
                    slot: slot,
                    expanded: _expandedSlots.contains(key),
                    onToggleExpand: () => setState(() {
                      if (_expandedSlots.contains(key)) {
                        _expandedSlots.remove(key);
                      } else {
                        _expandedSlots.add(key);
                      }
                    }),
                    onAddToDiary: (food) => _addToDiary(food, meal.tipo),
                    dimmed: plan.obsoleto,
                    p: p,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ];
          }),

          Center(
            child: TextButton.icon(
              onPressed: _openQuestionario,
              icon: Icon(Icons.tune_rounded, color: p.textMuted, size: 16),
              label: Text('Modifica preferenze',
                  style: TextStyle(color: p.textMuted, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────

class _AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorPalette p;
  const _AccentButton({required this.label, required this.onTap, required this.p});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: p.accent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF0A1A0F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2)),
          ),
        ),
      ),
    );
  }
}

class _ObsoletoBanner extends StatelessWidget {
  final VoidCallback onRigenera;
  final ColorPalette p;
  const _ObsoletoBanner({required this.onRigenera, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'I tuoi obiettivi sono cambiati. Rigenera il piano per aggiornare le grammature.',
              style: TextStyle(color: p.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRigenera,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: const Color(0xFFFFB800).withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('RIGENERA',
                style: TextStyle(
                    color: Color(0xFFFFB800), fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _PlanHeaderCard extends StatelessWidget {
  final MealPlan plan;
  final ColorPalette p;
  const _PlanHeaderCard({required this.plan, required this.p});

  String _formatDate(DateTime d) {
    const months = ['gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${plan.kcalTotali.round()} kcal/giorno',
                        style: TextStyle(
                            color: p.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Generato il ${_formatDate(plan.dataCreazione)}',
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (!plan.obsoleto)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ATTIVO',
                      style: TextStyle(
                          color: p.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniMacro(label: 'P', value: plan.proteineTotali.round(), color: const Color(0xFF3B9FF2), p: p),
              const SizedBox(width: 20),
              _MiniMacro(label: 'G', value: plan.grassiTotali.round(), color: const Color(0xFFFFB800), p: p),
              const SizedBox(width: 20),
              _MiniMacro(label: 'C', value: plan.carbsTotali.round(), color: const Color(0xFF4CAF8E), p: p),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ColorPalette p;
  const _MiniMacro({required this.label, required this.value, required this.color, required this.p});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text('$label  ${value}g', style: TextStyle(color: p.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _MealHeader extends StatelessWidget {
  final int tipo;
  final ColorPalette p;
  const _MealHeader({required this.tipo, required this.p});

  @override
  Widget build(BuildContext context) {
    final label = PianoService.pastoLabels[tipo.clamp(0, 4)];
    final emoji = PianoService.pastoEmoji[tipo.clamp(0, 4)];
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: p.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  final PlanSlot slot;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final void Function(PlanFood) onAddToDiary;
  final bool dimmed;
  final ColorPalette p;

  const _SlotCard({
    required this.slot,
    required this.expanded,
    required this.onToggleExpand,
    required this.onAddToDiary,
    required this.dimmed,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final food = slot.principale!;
    final slotLabel = PianoService.slotLabels[slot.tipo.clamp(0, 4)];
    final slotEmoji = PianoService.slotEmoji[slot.tipo.clamp(0, 4)];

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$slotEmoji ', style: const TextStyle(fontSize: 13)),
                      Text(
                        slotLabel.toUpperCase(),
                        style: TextStyle(
                            color: p.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.nome,
                                style: TextStyle(
                                    color: p.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(
                              '${food.quantitaG.round()}g  ·  ${food.kcal.round()} kcal',
                              style: TextStyle(color: p.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'P ${food.proteine.toStringAsFixed(1)}  G ${food.grassi.toStringAsFixed(1)}  C ${food.carboidrati.toStringAsFixed(1)}',
                              style: TextStyle(color: p.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => onAddToDiary(food),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add_rounded, color: p.accent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (slot.alternative.isNotEmpty) ...[
              Container(height: 1, color: p.cardBorder),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleExpand,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          expanded
                              ? 'Nascondi alternative'
                              : '${slot.alternative.length} alternativ${slot.alternative.length == 1 ? "a" : "e"}',
                          style: TextStyle(
                              color: p.accent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: p.accent,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (expanded)
                ...slot.alternative.map((alt) => Container(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(
                        color: p.surfaceVariant,
                        border: Border(top: BorderSide(color: p.cardBorder)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alt.nome,
                                    style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  '${alt.quantitaG.round()}g  ·  ${alt.kcal.round()} kcal  ·  P ${alt.proteine.toStringAsFixed(1)}  G ${alt.grassi.toStringAsFixed(1)}  C ${alt.carboidrati.toStringAsFixed(1)}',
                                  style: TextStyle(color: p.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => onAddToDiary(alt),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: p.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add_rounded, color: p.accent, size: 16),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}

class _PastoPicker extends StatelessWidget {
  final PlanFood food;
  final DateTime currentDate;
  final int suggestedPasto;
  final void Function(String pastoNome) onAdded;

  const _PastoPicker({
    required this.food,
    required this.currentDate,
    required this.suggestedPasto,
    required this.onAdded,
  });

  MealEntry _toMealEntry(int pastoTipo) {
    final k = food.quantitaG > 0 ? 100 / food.quantitaG : 0.0;
    return MealEntry()
      ..foodNome = food.nome
      ..kcalPer100g = food.kcal * k
      ..proteinPer100g = food.proteine * k
      ..fatPer100g = food.grassi * k
      ..carbsPer100g = food.carboidrati * k
      ..quantitaG = food.quantitaG
      ..pastoTipo = pastoTipo;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aggiungi al diario',
                style: TextStyle(
                    color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${food.nome}  ·  ${food.quantitaG.round()}g  ·  ${food.kcal.round()} kcal',
              style: TextStyle(color: p.textMuted, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (i) {
              final isSuggested = i == suggestedPasto;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                decoration: isSuggested
                    ? BoxDecoration(
                        color: p.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.accent.withValues(alpha: 0.25)),
                      )
                    : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: Icon(_diaryPastoIcons[i],
                      color: isSuggested ? p.accent : p.textMuted),
                  title: Text(_diaryPastoNomi[i],
                      style: TextStyle(
                          color: isSuggested ? p.accent : p.textPrimary,
                          fontSize: 14,
                          fontWeight: isSuggested ? FontWeight.w600 : FontWeight.normal)),
                  trailing: isSuggested
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Suggerito',
                              style: TextStyle(
                                  color: p.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                        )
                      : null,
                  onTap: () async {
                    final entry = _toMealEntry(i);
                    await DatabaseService.instance.addMealEntry(currentDate, entry);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onAdded(_diaryPastoNomi[i]);
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
