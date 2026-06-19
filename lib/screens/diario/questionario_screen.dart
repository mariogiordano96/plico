import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/food_item.dart';
import '../../models/user_food_preferences.dart';
import '../../services/database_service.dart';
import '../../services/piano_service.dart';

class QuestionarioScreen extends StatefulWidget {
  const QuestionarioScreen({super.key});

  @override
  State<QuestionarioScreen> createState() => _QuestionarioScreenState();
}

class _FoodGroup {
  final String label;
  final String emoji;
  final List<FoodItem> foods;
  _FoodGroup(this.label, this.emoji, this.foods);
}

class _QuestionarioScreenState extends State<QuestionarioScreen> {
  int _page = 0;
  bool _loading = true;
  bool _saving = false;

  final Set<String> _restrizioni = {};
  final Set<int> _likedIds = {};
  List<_FoodGroup> _foodGroups = [];
  int _numPasti = 3;
  bool _haSpuntinoPostWo = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await DatabaseService.instance.getUserFoodPreferences();
    if (prefs != null) {
      _restrizioni.addAll(prefs.restrizioni);
      _likedIds.addAll(prefs.foodLikedIds);
      _numPasti = prefs.numPasti;
      _haSpuntinoPostWo = prefs.haSpuntinoPostWo;
    }
    await _loadFoodGroups();
  }

  Future<void> _loadFoodGroups() async {
    final all = await DatabaseService.instance.getAllCreaFoods();
    final byName = {for (final f in all) f.nome: f};

    List<FoodItem> byNames(List<String> names) =>
        names.map((n) => byName[n]).whereType<FoodItem>().toList();

    final cn = PianoService.curatedNames;
    final groups = [
      _FoodGroup('Proteine animali', '🥩', byNames(cn['Proteine animali']!)),
      _FoodGroup('Proteine vegetali', '🫘', byNames(cn['Proteine vegetali']!)),
      _FoodGroup('Cereali', '🍚', byNames(cn['Cereali']!)),
      _FoodGroup('Verdure', '🥦', byNames(cn['Verdure']!)),
      _FoodGroup('Latticini', '🧀', byNames(cn['Latticini']!)),
      _FoodGroup('Grassi', '🫒', byNames(cn['Grassi']!)),
      _FoodGroup('Affettati', '🥩', byNames(PianoService.curatedProteineSalataColazione)),
      _FoodGroup('Frutta', '🍓', byNames(PianoService.curatedFruttaColazione)),
    ];

    if (!mounted) return;
    setState(() {
      _foodGroups = groups;
      _loading = false;
    });
  }

  Future<void> _salva() async {
    setState(() => _saving = true);
    final prefs = UserFoodPreferences()
      ..restrizioni = _restrizioni.toList()
      ..foodLikedIds = _likedIds.toList()
      ..numPasti = _numPasti
      ..haSpuntinoPostWo = _haSpuntinoPostWo
      ..questionarioCompletato = true;
    await DatabaseService.instance.saveUserFoodPreferences(prefs);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _toggleRestriz(String key) {
    setState(() {
      if (_restrizioni.contains(key)) {
        _restrizioni.remove(key);
      } else {
        _restrizioni.add(key);
        if (key == 'vegano') _restrizioni.add('vegetariano');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
        title: Text(
          context.l10n.questionarioTitolo,
          style: TextStyle(
            color: p.accent,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : Column(
              children: [
                _ProgressBar(current: _page, p: p),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: _buildPage(p),
                  ),
                ),
                _buildNavBar(p),
              ],
            ),
    );
  }

  Widget _buildNavBar(ColorPalette p) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            if (_page > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _page--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.textSecondary,
                  side: BorderSide(color: p.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: Text(context.l10n.questionarioIndietro, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : (_page < 2 ? () => setState(() => _page++) : _salva),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: const Color(0xFF0A1A0F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: _saving
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: p.background),
                      )
                    : Text(
                        _page < 2 ? context.l10n.questionarioAvanti : context.l10n.questionarioSalvaGenera,
                        style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(ColorPalette p) {
    switch (_page) {
      case 0:
        return _buildBlock1(p);
      case 1:
        return _buildBlock2(p);
      case 2:
        return _buildBlock3(p);
      default:
        return const SizedBox();
    }
  }

  // ── Block 1: Restrizioni ──────────────────────────────────────

  Widget _buildBlock1(ColorPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.questionarioRestrizioni,
            style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          context.l10n.questionarioRestrizioniSub,
          style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _RChip(value: 'vegetariano', label: context.l10n.questionarioVegetariano, icon: Icons.eco_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
            _RChip(value: 'vegano', label: context.l10n.questionarioVegano, icon: Icons.spa_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
            _RChip(value: 'no_lattosio', label: context.l10n.questionarioNoLattosio, icon: Icons.local_cafe_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
            _RChip(value: 'no_glutine', label: context.l10n.questionarioNoGlutine, icon: Icons.grain_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
            _RChip(value: 'no_pesce', label: context.l10n.questionarioNoPesce, icon: Icons.water_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
            _RChip(value: 'no_fruttaSecca', label: context.l10n.questionarioNoFruttaSecca, icon: Icons.nature_rounded, sel: _restrizioni, onTap: _toggleRestriz, p: p),
          ],
        ),
        const SizedBox(height: 20),
        if (_restrizioni.isEmpty)
          Text(context.l10n.questionarioNessunaRestrizione,
              style: TextStyle(color: p.textMuted, fontSize: 12)),
      ],
    );
  }

  // ── Block 2: Preferenze alimenti ─────────────────────────────

  Widget _buildBlock2(ColorPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.questionarioPreferenze,
            style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          context.l10n.questionarioPreferenzeSub,
          style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        ..._foodGroups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${group.emoji}  ${group.label}',
                    style: TextStyle(
                        color: p.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.foods.map((food) {
                      final liked = _likedIds.contains(food.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (liked) {
                            _likedIds.remove(food.id);
                          } else {
                            _likedIds.add(food.id);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: liked ? p.accent.withValues(alpha: 0.12) : p.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: liked ? p.accent : p.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (liked) ...[
                                Icon(Icons.check_rounded, size: 13, color: p.accent),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                _shortName(food.nome),
                                style: TextStyle(
                                  color: liked ? p.accent : p.textSecondary,
                                  fontSize: 12,
                                  fontWeight: liked ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Block 3: Struttura ────────────────────────────────────────

  Widget _buildBlock3(ColorPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.questionarioStruttura,
            style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(context.l10n.questionarioStrutturaSub,
            style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5)),
        const SizedBox(height: 28),
        Text(context.l10n.questionarioPastiGiorno,
            style: TextStyle(color: p.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [3, 4, 5].map((n) {
            final sel = _numPasti == n;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _numPasti = n),
                child: Container(
                  width: 64,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sel ? p.accent.withValues(alpha: 0.15) : p.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? p.accent : p.cardBorder,
                        width: sel ? 2 : 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$n',
                    style: TextStyle(
                      color: sel ? p.accent : p.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.questionarioSpuntinoPostWo,
                        style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(context.l10n.questionarioSpuntinoPostWoSub,
                        style: TextStyle(color: p.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: _haSpuntinoPostWo,
                onChanged: (v) => setState(() => _haSpuntinoPostWo = v),
                activeThumbColor: p.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _shortName(String nome) {
    if (nome.length <= 26) return nome;
    final comma = nome.indexOf(',');
    if (comma > 0 && comma <= 26) return nome.substring(0, comma);
    return '${nome.substring(0, 23)}…';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _RChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Set<String> sel;
  final void Function(String) onTap;
  final ColorPalette p;
  const _RChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.sel,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final selected = sel.contains(value);
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.15) : p.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? p.accent : p.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? p.accent : p.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? p.accent : p.textSecondary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final ColorPalette p;
  const _ProgressBar({required this.current, required this.p});

  @override
  Widget build(BuildContext context) {
    final titles = [
      context.l10n.questionarioRestrizioni,
      context.l10n.questionarioPreferenze,
      context.l10n.questionarioStruttura,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titles[current],
                  style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('${current + 1} / 3',
                  style: TextStyle(color: p.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / 3,
              backgroundColor: p.accent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
