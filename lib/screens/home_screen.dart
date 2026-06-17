import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/meal_plan.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';
import '../services/streak_service.dart';
import '../main.dart';
import 'impostazioni/notifiche_screen.dart';
import 'pesate/pesate_screen.dart';
import 'plicometry/method_selection_screen.dart';
import 'tdee/tdee_screen.dart' show calcolaTdee;

class HomeScreen extends StatelessWidget {
  final void Function(int)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text('PLICO',
            style: TextStyle(
                color: p.accent,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: p.accent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificheScreen()),
            ),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: p.accent),
                onPressed: () async {
                  final newMode =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                  themeNotifier.value = newMode;
                  await DatabaseService.instance
                      .saveIsDarkMode(newMode == ThemeMode.dark);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GreetingHeader(),
            const SizedBox(height: 20),
            _DiarioHeroCard(onSwitchTab: onSwitchTab),
            const SizedBox(height: 16),
            _AderenzaCard(onSwitchTab: onSwitchTab),
            const SizedBox(height: 16),
            const _StreakCard(),
            const SizedBox(height: 16),
            _PianoCard(onSwitchTab: onSwitchTab),
            const SizedBox(height: 16),
            _TdeeCard(onSwitchTab: onSwitchTab),
            const SizedBox(height: 16),
            const _PesateCard(),
            const SizedBox(height: 16),
            const _PlicometriaCard(),
            const SizedBox(height: 16),
            _ProgressiCard(onSwitchTab: onSwitchTab),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String _saluto() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buongiorno';
    if (h >= 12 && h < 18) return 'Buon pomeriggio';
    return 'Buonasera';
  }

  String _formatDate(DateTime d) {
    const days = [
      'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
      'Venerdì', 'Sabato', 'Domenica'
    ];
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic'
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<UserProfile?>(
      stream: DatabaseService.instance.watchUserProfile(),
      builder: (context, snap) {
        final nome = snap.data?.nome ?? '';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_saluto(),
                    style: TextStyle(color: p.textMuted, fontSize: 13)),
                Text(
                  nome.isNotEmpty ? nome : 'Benvenuto',
                  style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(_formatDate(DateTime.now()),
                style: TextStyle(color: p.textMuted, fontSize: 13)),
          ],
        );
      },
    );
  }
}

// ── Diario hero card ──────────────────────────────────────────────

class _DiarioHeroCard extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const _DiarioHeroCard({this.onSwitchTab});

  @override
  State<_DiarioHeroCard> createState() => _DiarioHeroCardState();
}

class _DiarioHeroCardState extends State<_DiarioHeroCard> {
  DailyLog? _log;
  int? _kcalTarget;
  int? _proteinTarget;
  int? _fatTarget;
  int? _carbsTarget;
  StreamSubscription? _logSub;
  StreamSubscription? _settingsSub;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _load();
    _logSub = DatabaseService.instance
        .watchDailyLog(_today)
        .listen((log) { if (mounted) setState(() => _log = log); });
    _settingsSub = DatabaseService.instance
        .watchAppSettings()
        .listen((_) => _loadTargets());
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final log = await DatabaseService.instance.getDailyLog(_today);
    if (mounted) setState(() => _log = log);
    await _loadTargets();
  }

  Future<void> _loadTargets() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    if (!mounted || profile == null || snapshot == null) return;
    final session =
        await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    final obiettivo = await DatabaseService.instance.getObiettivo();
    const goalMult = [0.80, 1.0, 1.15];
    final result = calcolaTdee(
      sesso: profile.sesso,
      eta: profile.etaCorrente,
      altezzaCm: profile.altezzaCm,
      pesoKg: snapshot.pesoKg,
      livello: livello,
      metodo: metodo,
      massaMagraKg: session?.risultati.massaMagraKg,
    );
    if (result == null || !mounted) return;
    final kcal =
        (result.tdee * goalMult[obiettivo.clamp(0, 2)]).round();
    final peso = snapshot.pesoKg;
    const protMatrix = [
      [1.4, 1.8, 2.3, 2.6, 3.1],
      [0.8, 1.2, 1.4, 1.8, 2.0],
      [0.8, 1.2, 1.6, 1.8, 2.0],
    ];
    final protG =
        (peso * protMatrix[obiettivo.clamp(0, 2)][livello.clamp(0, 4)])
            .round();
    final fatGPct = (kcal * 0.25 / 9).round();
    final fatGKg = (peso * 0.8).round();
    final fatG = fatGPct > fatGKg ? fatGPct : fatGKg;
    final carbsG = ((kcal - protG * 4 - fatG * 9) / 4)
        .clamp(0, double.infinity)
        .round();
    setState(() {
      _kcalTarget = kcal;
      _proteinTarget = protG;
      _fatTarget = fatG;
      _carbsTarget = carbsG;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final logged = _log?.kcalTotali ?? 0;
    final prot = _log?.proteinTotali ?? 0;
    final fat = _log?.fatTotali ?? 0;
    final carbs = _log?.carbsTotali ?? 0;
    final rawPct = _kcalTarget != null && _kcalTarget! > 0
        ? logged / _kcalTarget!
        : 0.0;
    final pct = rawPct.clamp(0.0, 1.0);
    final over = _kcalTarget != null && rawPct > 1.05;
    final onTarget = _kcalTarget != null && rawPct >= 0.9 && !over;
    const green = Color(0xFF4CAF8E);
    final barColor = over
        ? const Color(0xFFE74C3C)
        : onTarget
            ? green
            : p.accent;

    return GestureDetector(
      onTap: () => widget.onSwitchTab?.call(1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: onTarget
                  ? green.withValues(alpha: 0.35)
                  : p.cardBorder),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              p.surface,
              onTarget
                  ? green.withValues(alpha: 0.04)
                  : p.accent.withValues(alpha: 0.04)
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DIARIO DI OGGI',
                    style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600)),
                if (onTarget)
                  const Icon(Icons.check_circle_rounded,
                      color: green, size: 18)
                else
                  Icon(Icons.chevron_right_rounded,
                      color: p.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  logged.round().toString(),
                  style: TextStyle(
                      color: over
                          ? const Color(0xFFE74C3C)
                          : onTarget
                              ? green
                              : p.textPrimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 5),
                  child: Text(
                    _kcalTarget != null
                        ? '/ $_kcalTarget kcal'
                        : 'kcal',
                    style:
                        TextStyle(color: p.textMuted, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: p.accent.withValues(alpha: 0.12),
                valueColor:
                    AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroChip(
                    label: 'P',
                    logged: prot.round(),
                    target: _proteinTarget,
                    color: const Color(0xFF3B9FF2)),
                const SizedBox(width: 10),
                _MacroChip(
                    label: 'G',
                    logged: fat.round(),
                    target: _fatTarget,
                    color: const Color(0xFFFFB800)),
                const SizedBox(width: 10),
                _MacroChip(
                    label: 'C',
                    logged: carbs.round(),
                    target: _carbsTarget,
                    color: const Color(0xFF4CAF8E)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int logged;
  final int? target;
  final Color color;
  const _MacroChip(
      {required this.label,
      required this.logged,
      required this.target,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 2),
            Text('${logged}g',
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            if (target != null)
              Text('/ ${target}g',
                  style:
                      TextStyle(color: p.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Piano alimentare ──────────────────────────────────────────────

class _PianoCard extends StatelessWidget {
  final void Function(int)? onSwitchTab;
  const _PianoCard({this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => onSwitchTab?.call(1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: p.accent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.today_rounded, color: p.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PIANO ALIMENTARE',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Text('Visualizza e genera il piano',
                      style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── TDEE ──────────────────────────────────────────────────────────

class _TdeeCard extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const _TdeeCard({this.onSwitchTab});

  @override
  State<_TdeeCard> createState() => _TdeeCardState();
}

class _TdeeCardState extends State<_TdeeCard> {
  int? _tdee;
  StreamSubscription? _settingsSub;

  @override
  void initState() {
    super.initState();
    _load();
    _settingsSub = DatabaseService.instance
        .watchAppSettings()
        .listen((_) => _load());
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot =
        await DatabaseService.instance.getLatestBodySnapshot();
    final session =
        await DatabaseService.instance.getLatestPlicometrySession();
    final livello =
        await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    if (!mounted || profile == null || snapshot == null) return;
    final result = calcolaTdee(
      sesso: profile.sesso,
      eta: profile.etaCorrente,
      altezzaCm: profile.altezzaCm,
      pesoKg: snapshot.pesoKg,
      livello: livello,
      metodo: metodo,
      massaMagraKg: session?.risultati.massaMagraKg,
    );
    if (mounted) setState(() => _tdee = result?.tdee);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => widget.onSwitchTab?.call(3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.cardBorder)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color:
                      const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFFF6B35)
                          .withValues(alpha: 0.3))),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFFF6B35), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TDEE',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Text(
                    _tdee != null
                        ? '${_tdee!} kcal/giorno'
                        : 'Calcola il tuo fabbisogno',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Pesate ────────────────────────────────────────────────────────

class _PesateCard extends StatelessWidget {
  const _PesateCard();

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Sottopeso';
    if (bmi < 25.0) return 'Normopeso';
    if (bmi < 30.0) return 'Sovrappeso';
    if (bmi < 35.0) return 'Obesità I';
    return 'Obesità II+';
  }

  Color _bmiColor(double bmi, ColorPalette p) {
    if (bmi < 18.5) return const Color(0xFF3B9FF2);
    if (bmi < 25.0) return p.accent;
    if (bmi < 30.0) return const Color(0xFFFF8C42);
    return p.error;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<UserProfile?>(
      stream: DatabaseService.instance.watchUserProfile(),
      builder: (context, profileSnap) {
        final profile = profileSnap.data;
        return StreamBuilder<List<BodySnapshot>>(
          stream: DatabaseService.instance.watchBodySnapshots(),
          builder: (context, snapshot) {
            final latest = snapshot.data?.isNotEmpty == true
                ? snapshot.data!.first
                : null;
            double? bmi;
            if (latest != null &&
                profile != null &&
                profile.altezzaCm > 0) {
              final hM = profile.altezzaCm / 100;
              bmi = latest.pesoKg / (hM * hM);
            }
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const PesateScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: p.accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.monitor_weight_outlined,
                          color: p.accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PESO',
                              style: TextStyle(
                                  color: p.textMuted,
                                  fontSize: 11,
                                  letterSpacing: 2)),
                          const SizedBox(height: 2),
                          Text(
                            latest != null
                                ? '${latest.pesoKg.toStringAsFixed(1)} kg — ${_formatDate(latest.data)}'
                                : 'Nessuna pesata registrata',
                            style: TextStyle(
                                color: p.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          if (bmi != null) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'BMI ${bmi.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      color: _bmiColor(bmi, p),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _bmiColor(bmi, p)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    border: Border.all(
                                        color: _bmiColor(bmi, p)
                                            .withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    _bmiLabel(bmi),
                                    style: TextStyle(
                                        color: _bmiColor(bmi, p),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: p.textMuted, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Plicometria (risultato + CTA) ─────────────────────────────────

class _PlicometriaCard extends StatelessWidget {
  const _PlicometriaCard();

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<List<PlicometrySession>>(
      stream: DatabaseService.instance.watchPlicometrySessions(),
      builder: (context, snapshot) {
        final session = snapshot.data?.isNotEmpty == true
            ? snapshot.data!.first
            : null;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PLICOMETRIA',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600)),
                  if (session != null)
                    Text(_formatDate(session.data),
                        style:
                            TextStyle(color: p.textMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),
              if (session != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                        label: 'BF%',
                        value:
                            '${session.risultati.bodyFatPercent.toStringAsFixed(1)}%'),
                    Container(
                        width: 1, height: 36, color: p.cardBorder),
                    _StatItem(
                        label: 'Massa Grassa',
                        value:
                            '${session.risultati.massaGrassaKg.toStringAsFixed(1)} kg'),
                    Container(
                        width: 1, height: 36, color: p.cardBorder),
                    _StatItem(
                        label: 'Massa Magra',
                        value:
                            '${session.risultati.massaMagraKg.toStringAsFixed(1)} kg'),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: p.cardBorder),
                const SizedBox(height: 14),
              ] else ...[
                Text('Nessuna sessione registrata',
                    style:
                        TextStyle(color: p.textMuted, fontSize: 13)),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const MethodSelectionScreen())),
                  icon: Icon(Icons.add_rounded,
                      size: 16, color: p.accent),
                  label: Text('Nuova misurazione',
                      style: TextStyle(
                          color: p.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: p.accent.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Progressi ─────────────────────────────────────────────────────

class _ProgressiCard extends StatelessWidget {
  final void Function(int)? onSwitchTab;
  const _ProgressiCard({this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => onSwitchTab?.call(2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.cardBorder)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: p.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: p.accent.withValues(alpha: 0.3))),
              child: Icon(Icons.trending_up_rounded,
                  color: p.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROGRESSI',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Text('Composizione e misurazioni nel tempo',
                      style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Aderenza al piano ─────────────────────────────────────────────

class _AderenzaCard extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const _AderenzaCard({this.onSwitchTab});

  @override
  State<_AderenzaCard> createState() => _AderenzaCardState();
}

class _AderenzaCardState extends State<_AderenzaCard> {
  MealPlan? _plan;
  DailyLog? _todayLog;
  List<DailyLog> _weekLogs = [];
  StreamSubscription? _planSub;
  StreamSubscription? _logSub;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _load();
    _planSub = DatabaseService.instance
        .watchMealPlan()
        .listen((p) { if (mounted) setState(() => _plan = p); });
    _logSub = DatabaseService.instance
        .watchDailyLog(_today)
        .listen((l) { if (mounted) setState(() => _todayLog = l); });
  }

  @override
  void dispose() {
    _planSub?.cancel();
    _logSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await DatabaseService.instance.getMealPlan();
    final log = await DatabaseService.instance.getDailyLog(_today);
    final from = _today.subtract(const Duration(days: 6));
    final week = await DatabaseService.instance.getDailyLogsRange(from, _today);
    if (!mounted) return;
    setState(() { _plan = plan; _todayLog = log; _weekLogs = week; });
  }

  double _adherenceFor(DailyLog? log, Set<int> planned) {
    if (planned.isEmpty) return 0.0;
    final logged = log?.entries.map((e) => e.pastoTipo).toSet() ?? {};
    return logged.intersection(planned).length / planned.length;
  }

  DailyLog? _logForDay(DateTime day) {
    for (final l in _weekLogs) {
      if (l.data == day) return l;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_plan == null || _plan!.pasti.isEmpty) return const SizedBox.shrink();

    final p = context.palette;
    final planned = _plan!.pasti.map((m) => m.tipo).toSet();
    final loggedToday =
        (_todayLog?.entries.map((e) => e.pastoTipo).toSet() ?? {})
            .intersection(planned);
    final pct = _adherenceFor(_todayLog, planned);
    final color = pct >= 0.8
        ? const Color(0xFF4CAF8E)
        : pct >= 0.4
            ? const Color(0xFFFF8C42)
            : pct > 0
                ? const Color(0xFFFF8C42)
                : p.textMuted;

    final now = DateTime.now();
    final dots = List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      final log = i == 6 ? _todayLog : _logForDay(day);
      // future days or no log
      if (day.isAfter(DateTime(now.year, now.month, now.day))) return -1.0;
      return _adherenceFor(log, planned);
    });

    return GestureDetector(
      onTap: () => widget.onSwitchTab?.call(1),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ADERENZA AL PIANO',
                    style: TextStyle(
                        color: p.textMuted,
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600)),
                Icon(Icons.chevron_right_rounded,
                    color: p.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${loggedToday.length}/${planned.length}',
                  style: TextStyle(
                      color: pct > 0 ? color : p.textMuted,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 6),
                  child: Text(
                    'pasti oggi',
                    style: TextStyle(color: p.textMuted, fontSize: 13),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(pct * 100).round()}%',
                  style: TextStyle(
                      color: pct > 0 ? color : p.textMuted,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: p.cardBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                    pct > 0 ? color : p.cardBorder),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ultimi 7 giorni',
                    style:
                        TextStyle(color: p.textMuted, fontSize: 11)),
                Row(
                  children: List.generate(7, (i) {
                    final v = dots[i];
                    final isToday = i == 6;
                    Color dotColor;
                    if (v < 0) {
                      dotColor = p.cardBorder;
                    } else if (v >= 0.8) {
                      dotColor = const Color(0xFF4CAF8E);
                    } else if (v >= 0.4) {
                      dotColor = const Color(0xFFFF8C42);
                    } else if (v > 0) {
                      dotColor = const Color(0xFFFF8C42).withValues(alpha: 0.5);
                    } else {
                      dotColor = p.cardBorder;
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 5),
                      width: isToday ? 10 : 8,
                      height: isToday ? 10 : 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                                color: p.accent.withValues(alpha: 0.5),
                                width: 1.5)
                            : null,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak + badge traguardi ────────────────────────────────────────

const _badgeInfo = {
  AchievementType.firstKgLost: (Icons.scale_rounded, '1° kg perso'),
  AchievementType.streak7: (Icons.local_fire_department_rounded, 'Streak 7gg'),
  AchievementType.days30Logged: (Icons.calendar_month_rounded, '30 giorni'),
  AchievementType.weekOnTarget: (Icons.flag_rounded, 'Settimana in target'),
};

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  static const _flame = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<int>(
      stream: StreakService.instance.watchCurrentStreak(),
      builder: (context, streakSnap) {
        final streak = streakSnap.data ?? 0;
        final active = streak > 0;
        return StreamBuilder<Set<AchievementType>>(
          stream: DatabaseService.instance.watchUnlockedTypes(),
          builder: (context, badgeSnap) {
            final unlocked = badgeSnap.data ?? const <AchievementType>{};
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color:
                        active ? _flame.withValues(alpha: 0.35) : p.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _flame.withValues(alpha: active ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _flame.withValues(
                                  alpha: active ? 0.35 : 0.15)),
                        ),
                        child: Icon(Icons.local_fire_department_rounded,
                            color: active ? _flame : p.textMuted, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STREAK',
                                style: TextStyle(
                                    color: p.textMuted,
                                    fontSize: 11,
                                    letterSpacing: 2)),
                            const SizedBox(height: 2),
                            Text(
                              active
                                  ? '$streak giorni di fila'
                                  : 'Inizia oggi la tua streak',
                              style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _badgeInfo.entries.map((e) {
                      final isUnlocked = unlocked.contains(e.key);
                      final (icon, label) = e.value;
                      return _BadgeIcon(
                        icon: icon,
                        label: label,
                        unlocked: isUnlocked,
                        p: p,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;
  final ColorPalette p;
  const _BadgeIcon(
      {required this.icon,
      required this.label,
      required this.unlocked,
      required this.p});

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? const Color(0xFFFFB800) : p.textMuted;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: unlocked ? 0.15 : 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: unlocked ? 0.4 : 0.15)),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: unlocked ? p.textSecondary : p.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: p.accent,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}
