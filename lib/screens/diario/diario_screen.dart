import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/daily_log.dart';
import '../../models/meal_combo.dart';
import '../../models/meal_entry.dart';
import '../../services/achievement_service.dart';
import '../../services/database_service.dart';
import '../../services/target_service.dart';
import '../../services/widget_service.dart';
import '../../services/piano_service.dart';
import 'aggiunta_alimento_screen.dart';
import 'piano_tab.dart';
const _pastoIcons = [
  Icons.free_breakfast_rounded,
  Icons.lunch_dining_rounded,
  Icons.dinner_dining_rounded,
  Icons.apple_rounded,
  Icons.fitness_center_rounded,
  Icons.nights_stay_rounded,
];

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  DateTime _date = _dayStart(DateTime.now());
  DailyLog? _log;
  DailyLog? _yesterdayLog;
  int? _kcalTarget;
  int? _proteinTarget;
  int? _fatTarget;
  int? _carbsTarget;
  bool _loading = true;
  StreamSubscription? _settingsSub;
  bool _haPostWo = false;
  int _numPasti = 3;

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _load();
    _settingsSub = DatabaseService.instance
        .watchAppSettings()
        .listen((_) => _reloadTargets());
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final log = await DatabaseService.instance.getDailyLog(_date);
    final yesterdayLog = await DatabaseService.instance
        .getDailyLog(_date.subtract(const Duration(days: 1)));
    final target = await computeDailyTargets();
    final prefs = await DatabaseService.instance.getUserFoodPreferences();
    if (!mounted) return;
    setState(() {
      _log = log;
      _yesterdayLog = yesterdayLog;
      _kcalTarget = target.$1;
      _proteinTarget = target.$2;
      _fatTarget = target.$3;
      _carbsTarget = target.$4;
      _haPostWo = prefs?.haSpuntinoPostWo ?? false;
      _numPasti = prefs?.numPasti ?? 3;
      _loading = false;
    });
    WidgetService.refresh();
  }

  Future<void> _repeatYesterday(int pastoTipo) async {
    final entries =
        _yesterdayLog?.entries.where((e) => e.pastoTipo == pastoTipo) ??
            const <MealEntry>[];
    for (final e in entries) {
      final copy = MealEntry()
        ..foodNome = e.foodNome
        ..foodBrand = e.foodBrand
        ..kcalPer100g = e.kcalPer100g
        ..proteinPer100g = e.proteinPer100g
        ..fatPer100g = e.fatPer100g
        ..carbsPer100g = e.carbsPer100g
        ..quantitaG = e.quantitaG
        ..pastoTipo = pastoTipo
        ..orarioInserimento = DateTime.now();
      await DatabaseService.instance.addMealEntry(_date, copy);
    }
    AchievementService.instance.checkAll();
    await _load();
  }

  Future<String?> _askComboName() {
    final ctrl = TextEditingController();
    final p = context.palette;
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.diarioSalvaComePref,
            style: TextStyle(color: p.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.diarioSalvaHint,
            hintStyle: TextStyle(color: p.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.diarioAnnulla),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(l10n.diarioBtnSalva),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAsCombo(int pastoTipo, List<MealEntry> entries) async {
    if (entries.isEmpty) return;
    final nome = await _askComboName();
    if (nome == null || nome.trim().isEmpty) return;
    final combo = MealCombo()
      ..nome = nome.trim()
      ..pastoTipo = pastoTipo
      ..items = entries
          .map((e) => MealEntry()
            ..foodNome = e.foodNome
            ..foodBrand = e.foodBrand
            ..kcalPer100g = e.kcalPer100g
            ..proteinPer100g = e.proteinPer100g
            ..fatPer100g = e.fatPer100g
            ..carbsPer100g = e.carbsPer100g
            ..quantitaG = e.quantitaG
            ..pastoTipo = e.pastoTipo)
          .toList();
    await DatabaseService.instance.saveMealCombo(combo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.diarioSalvatoComePref(combo.nome))),
    );
  }

  Future<void> _reloadTargets() async {
    final target = await computeDailyTargets();
    if (!mounted) return;
    setState(() {
      _kcalTarget = target.$1;
      _proteinTarget = target.$2;
      _fatTarget = target.$3;
      _carbsTarget = target.$4;
    });
    WidgetService.refresh();
  }

  List<int> _visiblePasti() {
    final indices = [0, 1, 3, 2]; // colazione, pranzo, spuntino, cena
    if (_haPostWo) indices.add(4);      // postWo
    if (_numPasti >= 5) indices.add(5); // spuntinoSerale
    return indices;
  }

  Future<void> _removeEntry(int index) async {
    await DatabaseService.instance.removeMealEntry(_date, index);
    await _load();
  }

  Future<void> _openAdd(int pastoTipo) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AggiuntaAlimentoScreen(
          pastoTipo: pastoTipo,
          date: _date,
        ),
      ),
    );
    if (added == true) await _load();
  }

  String _formatDate(DateTime d) {
    final l10n = context.l10n;
    final today = _dayStart(DateTime.now());
    if (d == today) return l10n.diarioOggi;
    if (d == today.subtract(const Duration(days: 1))) return l10n.diarioIeri;
    return DateFormat('EEE d MMM', Localizations.localeOf(context).toString()).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          title: Text(context.l10n.diarioTitolo,
              style: TextStyle(
                  color: p.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5)),
          backgroundColor: p.background,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: p.accent),
          bottom: TabBar(
            indicatorColor: p.accent,
            labelColor: p.accent,
            unselectedLabelColor: p.textMuted,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: context.l10n.diarioTabPiano),
              Tab(text: context.l10n.diarioTabDiario),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PianoTab(currentDate: _date, onEntryAdded: _load),
            _buildDiarioTab(p),
          ],
        ),
      ),
    );
  }

  Widget _buildDiarioTab(ColorPalette p) {
    final log = _log;
    final kcalLogged = log?.kcalTotali ?? 0;
    final protLogged = log?.proteinTotali ?? 0;
    final fatLogged = log?.fatTotali ?? 0;
    final carbsLogged = log?.carbsTotali ?? 0;

    if (_loading) return Center(child: CircularProgressIndicator(color: p.accent));

    return Column(
      children: [
        _DateNav(
          date: _date,
          label: _formatDate(_date),
          onPrev: () {
            setState(() => _date = _date.subtract(const Duration(days: 1)));
            _load();
          },
          onNext: _date == _dayStart(DateTime.now())
              ? null
              : () {
                  setState(() => _date = _date.add(const Duration(days: 1)));
                  _load();
                },
          p: p,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              children: [
                _RiepilogoCard(
                  kcalLogged: kcalLogged,
                  kcalTarget: _kcalTarget,
                  protLogged: protLogged,
                  protTarget: _proteinTarget,
                  fatLogged: fatLogged,
                  fatTarget: _fatTarget,
                  carbsLogged: carbsLogged,
                  carbsTarget: _carbsTarget,
                  p: p,
                ),
                const SizedBox(height: 20),
                ..._visiblePasti().map((i) {
                  final entries = (log?.entries ?? [])
                      .where((e) => e.pastoTipo == i)
                      .toList();
                  final globalIndices = <int>[];
                  if (log != null) {
                    for (int j = 0; j < log.entries.length; j++) {
                      if (log.entries[j].pastoTipo == i) {
                        globalIndices.add(j);
                      }
                    }
                  }
                  final yesterdayHasEntries = _yesterdayLog?.entries
                          .any((e) => e.pastoTipo == i) ??
                      false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PastoSection(
                      label: PianoService.pastoLabel(context.l10n, i).toUpperCase(),
                      icon: _pastoIcons[i],
                      entries: entries,
                      globalIndices: globalIndices,
                      onAdd: () => _openAdd(i),
                      onRemove: _removeEntry,
                      canRepeatYesterday:
                          entries.isEmpty && yesterdayHasEntries,
                      onRepeatYesterday: () => _repeatYesterday(i),
                      onSaveCombo: entries.isEmpty
                          ? null
                          : () => _saveAsCombo(i, entries),
                      p: p,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Date nav ───────────────────────────────────────────────────

class _DateNav extends StatelessWidget {
  final DateTime date;
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final ColorPalette p;
  const _DateNav(
      {required this.date,
      required this.label,
      required this.onPrev,
      required this.onNext,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: p.accent),
            onPressed: onPrev,
          ),
          Text(label,
              style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded,
                color: onNext != null ? p.accent : p.textMuted),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Riepilogo card ─────────────────────────────────────────────

class _RiepilogoCard extends StatelessWidget {
  final double kcalLogged;
  final int? kcalTarget;
  final double protLogged;
  final int? protTarget;
  final double fatLogged;
  final int? fatTarget;
  final double carbsLogged;
  final int? carbsTarget;
  final ColorPalette p;
  const _RiepilogoCard({
    required this.kcalLogged,
    required this.kcalTarget,
    required this.protLogged,
    required this.protTarget,
    required this.fatLogged,
    required this.fatTarget,
    required this.carbsLogged,
    required this.carbsTarget,
    required this.p,
  });

  static const _green = Color(0xFF4CAF8E);

  @override
  Widget build(BuildContext context) {
    final pct =
        kcalTarget != null && kcalTarget! > 0 ? kcalLogged / kcalTarget! : 0.0;
    final over = pct > 1.05;
    final onTarget = kcalTarget != null && pct >= 0.9 && !over;
    final barColor = over
        ? const Color(0xFFE74C3C)
        : onTarget
            ? _green
            : p.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: onTarget ? _green.withValues(alpha: 0.35) : p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${kcalLogged.round()} kcal',
                      style: TextStyle(
                          color: over
                              ? const Color(0xFFE74C3C)
                              : onTarget
                                  ? _green
                                  : p.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  Text(
                    kcalTarget != null
                        ? context.l10n.diarioKcalObiettivo('$kcalTarget')
                        : context.l10n.diarioNessunObiettivo,
                    style: TextStyle(color: p.textMuted, fontSize: 12),
                  ),
                ],
              ),
              if (kcalTarget != null)
                Text(
                  over
                      ? '+${(kcalLogged - kcalTarget!).round()} kcal'
                      : onTarget
                          ? context.l10n.diarioObiettivoRaggiunto
                          : context.l10n.diarioKcalRimanenti('${(kcalTarget! - kcalLogged).round()}'),
                  style: TextStyle(
                      color: over
                          ? const Color(0xFFE74C3C)
                          : onTarget
                              ? _green
                              : p.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
            ],
          ),
          if (kcalTarget != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: barColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 8,
              ),
            ),
          ],
          if (onTarget) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: _green, size: 15),
                const SizedBox(width: 6),
                Text(context.l10n.diarioOttimoLavoro,
                    style: TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _MacroStat(
                label: context.l10n.diarioMacroProteine,
                logged: protLogged,
                target: protTarget?.toDouble(),
                color: const Color(0xFF3B9FF2),
                p: p,
              ),
              const SizedBox(width: 12),
              _MacroStat(
                label: context.l10n.diarioMacroGrassi,
                logged: fatLogged,
                target: fatTarget?.toDouble(),
                color: const Color(0xFFFFB800),
                p: p,
              ),
              const SizedBox(width: 12),
              _MacroStat(
                label: context.l10n.diarioMacroCarbo,
                logged: carbsLogged,
                target: carbsTarget?.toDouble(),
                color: const Color(0xFF4CAF8E),
                p: p,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final double logged;
  final double? target;
  final Color color;
  final ColorPalette p;
  const _MacroStat(
      {required this.label,
      required this.logged,
      this.target,
      required this.color,
      required this.p});

  @override
  Widget build(BuildContext context) {
    final pct = target != null && target! > 0 ? logged / target! : null;
    final onTarget = pct != null && pct >= 0.9 && pct <= 1.05;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${logged.round()}g',
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              if (target != null)
                Text(' / ${target!.round()}g',
                    style: TextStyle(color: p.textMuted, fontSize: 11)),
              if (onTarget) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle_rounded, color: color, size: 12),
              ],
            ],
          ),
          Text(label,
              style: TextStyle(
                  color: onTarget ? color : p.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Pasto section ──────────────────────────────────────────────

class _PastoSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<dynamic> entries; // MealEntry filtered
  final List<int> globalIndices;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool canRepeatYesterday;
  final VoidCallback? onRepeatYesterday;
  final VoidCallback? onSaveCombo;
  final ColorPalette p;

  const _PastoSection({
    required this.label,
    required this.icon,
    required this.entries,
    required this.globalIndices,
    required this.onAdd,
    required this.onRemove,
    this.canRepeatYesterday = false,
    this.onRepeatYesterday,
    this.onSaveCombo,
    required this.p,
  });

  double get _kcalTotali =>
      entries.fold(0.0, (s, e) => s + (e.kcal as double));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Icon(icon, color: p.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ),
                if (entries.isNotEmpty)
                  Text('${_kcalTotali.round()} kcal',
                      style:
                          TextStyle(color: p.textMuted, fontSize: 12)),
                if (onSaveCombo != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Icon(Icons.bookmark_add_outlined,
                        color: p.accent, size: 19),
                    onPressed: onSaveCombo,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: context.l10n.diarioSalvaComePref,
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.add_rounded, color: p.accent, size: 20),
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (entries.isNotEmpty)
            Container(height: 1, color: p.cardBorder),
          ...List.generate(entries.length, (i) {
            final entry = entries[i];
            final globalIdx = globalIndices[i];
            return Dismissible(
              key: ValueKey('$globalIdx-${entry.foodNome}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFE74C3C)),
              ),
              onDismissed: (_) => onRemove(globalIdx),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: i < entries.length - 1
                              ? p.cardBorder
                              : Colors.transparent)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.foodNome,
                              style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (entry.foodBrand != null)
                                entry.foodBrand!,
                              '${entry.quantitaG.round()}g',
                            ].join(' · '),
                            style: TextStyle(
                                color: p.textMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'P ${entry.proteinG.toStringAsFixed(1)}g'
                            '  G ${entry.fatG.toStringAsFixed(1)}g'
                            '  C ${entry.carbsG.toStringAsFixed(1)}g',
                            style: TextStyle(
                                color: p.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.kcal.round()} kcal',
                      style: TextStyle(
                          color: p.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(context.l10n.diarioNessunAlimento,
                        style:
                            TextStyle(color: p.textMuted, fontSize: 12)),
                  ),
                  if (canRepeatYesterday && onRepeatYesterday != null)
                    TextButton.icon(
                      onPressed: onRepeatYesterday,
                      icon: Icon(Icons.replay_rounded,
                          color: p.accent, size: 15),
                      label: Text(context.l10n.diarioRipetiIeri,
                          style: TextStyle(
                              color: p.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
