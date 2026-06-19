import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_combo.dart';
import '../../models/meal_entry.dart';
import '../../models/meal_plan.dart';
import '../../services/achievement_service.dart';
import '../../services/database_service.dart';
import '../../services/open_food_facts_service.dart';
import '../../services/piano_service.dart';
import 'barcode_scanner_screen.dart';

class AggiuntaAlimentoScreen extends StatefulWidget {
  final int pastoTipo;
  final DateTime date;
  const AggiuntaAlimentoScreen({
    super.key,
    required this.pastoTipo,
    required this.date,
  });

  @override
  State<AggiuntaAlimentoScreen> createState() =>
      _AggiuntaAlimentoScreenState();
}

class _AggiuntaAlimentoScreenState extends State<AggiuntaAlimentoScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<OFFFood> _offResults = [];
  List<FoodItem> _localResults = [];
  List<PlanFood> _planFoods = [];
  List<MealCombo> _combos = [];
  bool _searching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadLocal('');
    _loadPlanFoods();
    _loadCombos();
  }

  Future<void> _loadPlanFoods() async {
    final plan = await DatabaseService.instance.getMealPlan();
    if (plan == null) return;
    PlanMeal? pasto;
    for (final p in plan.pasti) {
      if (p.tipo == widget.pastoTipo) {
        pasto = p;
        break;
      }
    }
    if (pasto == null || !mounted) return;
    final foods = pasto.slots
        .map((s) => s.principale)
        .whereType<PlanFood>()
        .toList();
    setState(() => _planFoods = foods);
  }

  Future<void> _loadCombos() async {
    final combos = await DatabaseService.instance.getMealCombos();
    combos.sort((a, b) {
      final aMatch = a.pastoTipo == widget.pastoTipo;
      final bMatch = b.pastoTipo == widget.pastoTipo;
      if (aMatch != bMatch) return aMatch ? -1 : 1;
      return a.nome.compareTo(b.nome);
    });
    if (!mounted) return;
    setState(() => _combos = combos);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _loadLocal(String q) async {
    final items = await DatabaseService.instance.searchFoodItems(q);
    if (!mounted) return;
    setState(() => _localResults = items);
  }

  Future<void> _search(String q) async {
    await _loadLocal(q);
    if (q.trim().isEmpty) {
      setState(() {
        _offResults = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await OpenFoodFactsService.search(q);
    if (!mounted) return;
    setState(() {
      _offResults = results;
      _searching = false;
      _hasSearched = true;
    });
  }

  void _selectOFF(OFFFood food) {
    _showQuantitySheet(
      nome: food.nome,
      brand: food.brand,
      kcalPer100g: food.kcalPer100g,
      proteinPer100g: food.proteinPer100g,
      fatPer100g: food.fatPer100g,
      carbsPer100g: food.carbsPer100g,
      offCode: food.offCode,
    );
  }

  void _selectLocal(FoodItem item) {
    _showQuantitySheet(
      nome: item.nome,
      brand: item.brand,
      kcalPer100g: item.kcalPer100g,
      proteinPer100g: item.proteinPer100g,
      fatPer100g: item.fatPer100g,
      carbsPer100g: item.carbsPer100g,
      foodItemId: item.id,
    );
  }

  void _selectPlanFood(PlanFood food) {
    final k = food.quantitaG > 0 ? 100 / food.quantitaG : 0.0;
    _showQuantitySheet(
      nome: food.nome,
      kcalPer100g: food.kcal * k,
      proteinPer100g: food.proteine * k,
      fatPer100g: food.grassi * k,
      carbsPer100g: food.carboidrati * k,
      initialQty: food.quantitaG,
      foodItemId: food.foodItemId != 0 ? food.foodItemId : null,
    );
  }

  Future<void> _applyCombo(MealCombo combo) async {
    for (final item in combo.items) {
      final entry = MealEntry()
        ..foodNome = item.foodNome
        ..foodBrand = item.foodBrand
        ..kcalPer100g = item.kcalPer100g
        ..proteinPer100g = item.proteinPer100g
        ..fatPer100g = item.fatPer100g
        ..carbsPer100g = item.carbsPer100g
        ..quantitaG = item.quantitaG
        ..pastoTipo = widget.pastoTipo
        ..orarioInserimento = DateTime.now();
      await DatabaseService.instance.addMealEntry(widget.date, entry);
    }
    AchievementService.instance.checkAll();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _openScanner() async {
    final food = await Navigator.push<OFFFood>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (food != null && mounted) {
      await _showQuantitySheet(
        nome: food.nome,
        brand: food.brand,
        kcalPer100g: food.kcalPer100g,
        proteinPer100g: food.proteinPer100g,
        fatPer100g: food.fatPer100g,
        carbsPer100g: food.carbsPer100g,
        offCode: food.offCode,
      );
    }
  }

  Future<void> _showQuantitySheet({
    required String nome,
    String? brand,
    required double kcalPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    String? offCode,
    double initialQty = 100,
    int? foodItemId,
  }) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuantitySheet(
        nome: nome,
        brand: brand,
        kcalPer100g: kcalPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        offCode: offCode,
        initialQty: initialQty,
        foodItemId: foodItemId,
        pastoTipo: widget.pastoTipo,
        date: widget.date,
        onAdded: () => Navigator.pop(context, true),
      ),
    );
    if (added == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _showCustomForm() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomFoodSheet(
        pastoTipo: widget.pastoTipo,
        date: widget.date,
        onAdded: () => Navigator.pop(context, true),
      ),
    );
    if (added == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(
          context.l10n.aggiuntiA(PianoService.pastoLabel(context.l10n, widget.pastoTipo).toUpperCase()),
          style: TextStyle(
            color: p.accent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _SearchBar(
                    controller: _searchCtrl,
                    onChanged: _onChanged,
                    p: p,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openScanner,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.cardBorder),
                    ),
                    child: Icon(Icons.qr_code_scanner_rounded,
                        color: p.accent, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searching
                ? Center(child: CircularProgressIndicator(color: p.accent))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      if (_searchCtrl.text.isEmpty && _combos.isNotEmpty) ...[
                        _SectionLabel(context.l10n.aggiuntiPastiPreferiti, p),
                        const SizedBox(height: 8),
                        _FoodListBox(
                          children: _combos.map((combo) {
                            final kcal = combo.items
                                .fold<double>(0, (s, e) => s + e.kcal);
                            return _FoodTile(
                              nome: combo.nome,
                              brand: combo.items
                                  .map((e) => e.foodNome)
                                  .join(', '),
                              kcal: kcal,
                              protein: combo.items
                                  .fold<double>(0, (s, e) => s + e.proteinG),
                              fat: combo.items
                                  .fold<double>(0, (s, e) => s + e.fatG),
                              carbs: combo.items
                                  .fold<double>(0, (s, e) => s + e.carbsG),
                              isLast: combo == _combos.last,
                              onTap: () => _applyCombo(combo),
                              p: p,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_searchCtrl.text.isEmpty &&
                          _planFoods.isNotEmpty) ...[
                        _SectionLabel(context.l10n.aggiuntiDalPiano, p),
                        const SizedBox(height: 8),
                        _FoodListBox(
                          children: _planFoods.map((food) {
                            final k = food.quantitaG > 0
                                ? 100 / food.quantitaG
                                : 0.0;
                            return _FoodTile(
                              nome: food.nome,
                              kcal: food.kcal * k,
                              protein: food.proteine * k,
                              fat: food.grassi * k,
                              carbs: food.carboidrati * k,
                              isLast: food == _planFoods.last,
                              onTap: () => _selectPlanFood(food),
                              p: p,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_localResults.isNotEmpty) ...[
                        _SectionLabel(
                          _searchCtrl.text.isEmpty
                              ? context.l10n.aggiuntiTuoiAlimenti
                              : context.l10n.aggiuntiAlimentiSalvati,
                          p,
                        ),
                        const SizedBox(height: 8),
                        _FoodListBox(
                          children: _localResults.map((item) {
                            return _FoodTile(
                              nome: item.nome,
                              brand: item.brand,
                              kcal: item.kcalPer100g,
                              protein: item.proteinPer100g,
                              fat: item.fatPer100g,
                              carbs: item.carbsPer100g,
                              isFavorite: item.isFavorite,
                              isLast: item == _localResults.last,
                              onTap: () => _selectLocal(item),
                              onFavorite: () async {
                                await DatabaseService.instance
                                    .toggleFavorite(item.id);
                                await _loadLocal(_searchCtrl.text);
                              },
                              p: p,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_hasSearched && _offResults.isNotEmpty) ...[
                        _SectionLabel(context.l10n.aggiuntiRisultatiOFF, p),
                        const SizedBox(height: 8),
                        _FoodListBox(
                          children: _offResults.map((food) {
                            return _FoodTile(
                              nome: food.nome,
                              brand: food.brand,
                              kcal: food.kcalPer100g,
                              protein: food.proteinPer100g,
                              fat: food.fatPer100g,
                              carbs: food.carbsPer100g,
                              isLast: food == _offResults.last,
                              onTap: () => _selectOFF(food),
                              p: p,
                            );
                          }).toList(),
                        ),
                      ],
                      if (_hasSearched &&
                          _offResults.isEmpty &&
                          _localResults.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              context.l10n.aggiuntiNessunRisultato,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: p.textMuted, fontSize: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextButton.icon(
            onPressed: _showCustomForm,
            icon: Icon(Icons.add_circle_outline, color: p.accent),
            label: Text(
              context.l10n.aggiuntiCreaManuale,
              style: TextStyle(
                  color: p.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quantity bottom sheet ──────────────────────────────────────

class _QuantitySheet extends StatefulWidget {
  final String nome;
  final String? brand;
  final double kcalPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final String? offCode;
  final double initialQty;
  final int? foodItemId;
  final int pastoTipo;
  final DateTime date;
  final VoidCallback onAdded;

  const _QuantitySheet({
    required this.nome,
    this.brand,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    this.offCode,
    this.initialQty = 100,
    this.foodItemId,
    required this.pastoTipo,
    required this.date,
    required this.onAdded,
  });

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late final TextEditingController _ctrl;
  late double _qty;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _qty = widget.initialQty;
    _ctrl = TextEditingController(text: _formatQty(_qty));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatQty(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toString();

  double get _kcal => widget.kcalPer100g * _qty / 100;
  double get _protein => widget.proteinPer100g * _qty / 100;
  double get _fat => widget.fatPer100g * _qty / 100;
  double get _carbs => widget.carbsPer100g * _qty / 100;

  Future<void> _add() async {
    if (_qty <= 0 || _saving) return;
    setState(() => _saving = true);

    if (widget.offCode != null) {
      final existing = await DatabaseService.instance
          .getFoodItemByOffCode(widget.offCode!);
      if (existing == null) {
        final item = FoodItem()
          ..nome = widget.nome
          ..brand = widget.brand
          ..kcalPer100g = widget.kcalPer100g
          ..proteinPer100g = widget.proteinPer100g
          ..fatPer100g = widget.fatPer100g
          ..carbsPer100g = widget.carbsPer100g
          ..offCode = widget.offCode
          ..lastUsedAt = DateTime.now();
        await DatabaseService.instance.saveFoodItem(item);
      } else {
        await DatabaseService.instance.markFoodUsed(existing.id);
      }
    } else if (widget.foodItemId != null) {
      await DatabaseService.instance.markFoodUsed(widget.foodItemId!);
    }

    final entry = MealEntry()
      ..foodNome = widget.nome
      ..foodBrand = widget.brand
      ..kcalPer100g = widget.kcalPer100g
      ..proteinPer100g = widget.proteinPer100g
      ..fatPer100g = widget.fatPer100g
      ..carbsPer100g = widget.carbsPer100g
      ..quantitaG = _qty
      ..pastoTipo = widget.pastoTipo
      ..orarioInserimento = DateTime.now();

    await DatabaseService.instance.addMealEntry(widget.date, entry);
    AchievementService.instance.checkAll();
    if (mounted) widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: p.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.nome,
                style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            if (widget.brand != null)
              Text(widget.brand!,
                  style: TextStyle(color: p.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: TextStyle(color: p.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: context.l10n.aggiuntiQuantitaG,
                      labelStyle: TextStyle(color: p.textMuted),
                      suffix: Text('g', style: TextStyle(color: p.textMuted)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: p.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: p.accent),
                      ),
                    ),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null && val > 0) {
                        setState(() => _qty = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroChip(
                      label: '${_kcal.round()} kcal',
                      color: const Color(0xFFFF6B35),
                      p: p),
                  _MacroChip(
                      label: 'P ${_protein.round()}g',
                      color: const Color(0xFF3B9FF2),
                      p: p),
                  _MacroChip(
                      label: 'G ${_fat.round()}g',
                      color: const Color(0xFFFFB800),
                      p: p),
                  _MacroChip(
                      label: 'C ${_carbs.round()}g',
                      color: const Color(0xFF4CAF8E),
                      p: p),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(context.l10n.aggiuntiAggiungi,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Custom food form ───────────────────────────────────────────

class _CustomFoodSheet extends StatefulWidget {
  final int pastoTipo;
  final DateTime date;
  final VoidCallback onAdded;
  const _CustomFoodSheet(
      {required this.pastoTipo, required this.date, required this.onAdded});

  @override
  State<_CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<_CustomFoodSheet> {
  final _nomeCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    final nome = _nomeCtrl.text.trim();
    final kcal = double.tryParse(_kcalCtrl.text) ?? 0;
    if (nome.isEmpty || kcal <= 0) return;
    setState(() => _saving = true);

    final item = FoodItem()
      ..nome = nome
      ..brand = _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim()
      ..kcalPer100g = kcal
      ..proteinPer100g = double.tryParse(_proteinCtrl.text) ?? 0
      ..fatPer100g = double.tryParse(_fatCtrl.text) ?? 0
      ..carbsPer100g = double.tryParse(_carbsCtrl.text) ?? 0
      ..isCustom = true
      ..lastUsedAt = DateTime.now();

    await DatabaseService.instance.saveFoodItem(item);

    final entry = MealEntry()
      ..foodNome = item.nome
      ..foodBrand = item.brand
      ..kcalPer100g = item.kcalPer100g
      ..proteinPer100g = item.proteinPer100g
      ..fatPer100g = item.fatPer100g
      ..carbsPer100g = item.carbsPer100g
      ..quantitaG = 100
      ..pastoTipo = widget.pastoTipo
      ..orarioInserimento = DateTime.now();

    await DatabaseService.instance.addMealEntry(widget.date, entry);
    AchievementService.instance.checkAll();
    if (mounted) widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SafeArea(
      top: false,
      child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: p.cardBorder,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.aggiuntiCreaAlimento,
                style: TextStyle(
                    color: p.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _Field(ctrl: _nomeCtrl, label: context.l10n.aggiuntiNome, p: p),
            const SizedBox(height: 10),
            _Field(ctrl: _brandCtrl, label: context.l10n.aggiuntiBrand, p: p),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Field(ctrl: _kcalCtrl, label: context.l10n.aggiuntiKcal100g, p: p, isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _proteinCtrl, label: context.l10n.aggiuntiProteine100g, p: p, isNumber: true)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Field(ctrl: _fatCtrl, label: context.l10n.aggiuntiGrassi100g, p: p, isNumber: true)),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _carbsCtrl, label: context.l10n.aggiuntiCarbo100g, p: p, isNumber: true)),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(context.l10n.aggiuntiSalvaAggiungi,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Widgets helpers ────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ColorPalette p;
  const _SearchBar(
      {required this.controller, required this.onChanged, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.cardBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: p.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: context.l10n.aggiuntiCercaHint,
          hintStyle: TextStyle(color: p.textMuted, fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorPalette p;
  const _SectionLabel(this.text, this.p);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600));
  }
}

class _FoodListBox extends StatelessWidget {
  final List<Widget> children;
  const _FoodListBox({required this.children});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final String nome;
  final String? brand;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final bool isLast;
  final bool? isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final ColorPalette p;

  const _FoodTile({
    required this.nome,
    this.brand,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.isLast,
    this.isFavorite,
    required this.onTap,
    this.onFavorite,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: p.cardBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (brand != null) brand,
                      '${kcal.round()} kcal/100g',
                      'P${protein.round()} G${fat.round()} C${carbs.round()}',
                    ].join(' · '),
                    style: TextStyle(color: p.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onFavorite != null)
              GestureDetector(
                onTap: onFavorite,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    isFavorite == true
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: isFavorite == true
                        ? const Color(0xFFFFB800)
                        : p.textMuted,
                    size: 20,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: p.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;
  final ColorPalette p;
  const _MacroChip(
      {required this.label, required this.color, required this.p});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w700));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final ColorPalette p;
  final bool isNumber;
  const _Field(
      {required this.ctrl,
      required this.label,
      required this.p,
      this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      style: TextStyle(color: p.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: p.textMuted, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: p.accent),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
