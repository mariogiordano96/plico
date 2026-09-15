import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/app_settings.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/meal_plan.dart';
import '../models/achievement.dart';
import '../models/workout_exercise.dart';
import '../services/calorie_estimation_service.dart';
import '../services/database_service.dart';
import '../services/streak_service.dart';
import '../services/insights_service.dart';
import '../main.dart';
import 'impostazioni/impostazioni_screen.dart';
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
        leading: IconButton(
          icon: Icon(Icons.emoji_events_rounded, color: p.accent),
          tooltip: context.l10n.homeStreakTitle,
          onPressed: () => _showStreakSheet(context),
        ),
        actions: [
          if (kDebugMode)
            ValueListenableBuilder<Locale?>(
              valueListenable: localeNotifier,
              builder: (context, locale, _) {
                final isEnglish = locale?.languageCode == 'en';
                return IconButton(
                  tooltip: isEnglish ? 'Switch to Italian' : 'Passa a inglese',
                  icon: Text(isEnglish ? '🇬🇧' : '🇮🇹',
                      style: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    localeNotifier.value =
                        isEnglish ? const Locale('it') : const Locale('en');
                  },
                );
              },
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: p.accent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImpostazioniScreen()),
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
            _AttivitaCard(onSwitchTab: onSwitchTab),
            const _WeeklyRecapCard(),
            const SizedBox(height: 16),
            _AderenzaCard(onSwitchTab: onSwitchTab),
            const SizedBox(height: 16),
            const _InsightsCard(),
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

  String _saluto(BuildContext context) {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return context.l10n.homeSalutoBuongiorno;
    if (h >= 12 && h < 18) return context.l10n.homeSalutoBuonPomeriggio;
    return context.l10n.homeSalutoBuonasera;
  }

  String _formatDate(DateTime d, BuildContext context) =>
      DateFormat('EEEE d MMM', Localizations.localeOf(context).toString()).format(d);

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
                Text(_saluto(context),
                    style: TextStyle(color: p.textMuted, fontSize: 13)),
                Text(
                  nome.isNotEmpty ? nome : context.l10n.homeFallbackNome,
                  style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(_formatDate(DateTime.now(), context),
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
                Text(context.l10n.homeDiarioDiOggi,
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

// ── Attività (allenamento) ───────────────────────────────────────

class _AttivitaCard extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const _AttivitaCard({this.onSwitchTab});

  @override
  State<_AttivitaCard> createState() => _AttivitaCardState();
}

class _AttivitaCardState extends State<_AttivitaCard> {
  DailyLog? _log;
  List<WorkoutExercise> _esercizi = [];
  StreamSubscription? _logSub;
  StreamSubscription? _workoutSub;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _logSub = DatabaseService.instance.watchDailyLog(_today).listen((log) {
      if (mounted) setState(() => _log = log);
    });
    _workoutSub =
        DatabaseService.instance.watchWorkoutExercisesForDay(_today).listen((list) {
      if (mounted) setState(() => _esercizi = list);
    });
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _workoutSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_esercizi.isEmpty) return const SizedBox.shrink();

    final p = context.palette;
    final l10n = context.l10n;
    final kcalIngerite = (_log?.kcalTotali ?? 0).round();
    final kcalAttivita = CalorieEstimationService.dailyKcal(_esercizi);
    final bilancioNetto = kcalIngerite - kcalAttivita;

    return GestureDetector(
      onTap: () => widget.onSwitchTab?.call(2),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
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
              children: [
                Icon(Icons.fitness_center_rounded, color: p.accent, size: 16),
                const SizedBox(width: 6),
                Text(l10n.homeAttivitaTitle,
                    style: TextStyle(
                        color: p.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            _RigaBilancio(label: l10n.homeAttivitaKcalIngerite, value: kcalIngerite, p: p),
            const SizedBox(height: 4),
            _RigaBilancio(label: l10n.homeAttivitaKcalBruciate, value: -kcalAttivita, p: p),
            Divider(color: p.cardBorder, height: 16),
            _RigaBilancio(
              label: l10n.homeAttivitaBilancioNetto,
              value: bilancioNetto,
              p: p,
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeAttivitaKcalDisclaimer,
              style: TextStyle(color: p.textMuted, fontSize: 11, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _RigaBilancio extends StatelessWidget {
  final String label;
  final int value;
  final ColorPalette p;
  final bool bold;
  const _RigaBilancio({required this.label, required this.value, required this.p, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? p.textPrimary : p.textMuted,
      fontSize: bold ? 14 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('$value kcal', style: style),
      ],
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

// ── Pesate ────────────────────────────────────────────────────────

class _PesateCard extends StatelessWidget {
  const _PesateCard();

  String _formatDate(DateTime d, BuildContext context) =>
      DateFormat.yMd(Localizations.localeOf(context).toString()).format(d);

  String _bmiLabel(double bmi, BuildContext context) {
    final l10n = context.l10n;
    if (bmi < 18.5) return l10n.homeBmiSottopeso;
    if (bmi < 25.0) return l10n.homeBmiNormopeso;
    if (bmi < 30.0) return l10n.homeBmiSovrappeso;
    if (bmi < 35.0) return l10n.homeBmiObesitaI;
    return l10n.homeBmiObesitaII;
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
    final nf1 = NumberFormat.decimalPatternDigits(
        locale: Localizations.localeOf(context).toString(), decimalDigits: 1);
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
            return StreamBuilder<AppSettings?>(
              stream: DatabaseService.instance.watchAppSettings(),
              builder: (context, settingsSnap) {
                final pesoObiettivo = settingsSnap.data?.pesoObiettivo;
                final goalDelta = (latest != null && pesoObiettivo != null)
                    ? latest.pesoKg - pesoObiettivo
                    : null;
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
                          Text(context.l10n.homePesoLabel,
                              style: TextStyle(
                                  color: p.textMuted,
                                  fontSize: 11,
                                  letterSpacing: 2)),
                          const SizedBox(height: 2),
                          Text(
                            latest != null
                                ? '${nf1.format(latest.pesoKg)} kg — ${_formatDate(latest.data, context)}'
                                : context.l10n.homeNessunaPesata,
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
                                  'BMI ${nf1.format(bmi)}',
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
                                    _bmiLabel(bmi, context),
                                    style: TextStyle(
                                        color: _bmiColor(bmi, p),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (goalDelta != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              goalDelta.abs() < 0.5
                                  ? context.l10n.homePesoObiettivoRaggiunto
                                  : context.l10n.homePesoAlObiettivo(nf1.format(goalDelta.abs())),
                              style: TextStyle(
                                  color: goalDelta.abs() < 0.5
                                      ? const Color(0xFF4CAF8E)
                                      : p.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
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
      },
    );
  }
}

// ── Plicometria (risultato + CTA) ─────────────────────────────────

class _PlicometriaCard extends StatelessWidget {
  const _PlicometriaCard();

  String _formatDate(DateTime d, BuildContext context) =>
      DateFormat.yMd(Localizations.localeOf(context).toString()).format(d);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final nf1 = NumberFormat.decimalPatternDigits(
        locale: Localizations.localeOf(context).toString(), decimalDigits: 1);
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
                  Text(context.l10n.homePlicoLabel,
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600)),
                  if (session != null)
                    Text(_formatDate(session.data, context),
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
                            '${nf1.format(session.risultati.bodyFatPercent)}%'),
                    Container(
                        width: 1, height: 36, color: p.cardBorder),
                    _StatItem(
                        label: context.l10n.homePlicoMassaGrassa,
                        value:
                            '${nf1.format(session.risultati.massaGrassaKg)} kg'),
                    Container(
                        width: 1, height: 36, color: p.cardBorder),
                    _StatItem(
                        label: context.l10n.homePlicoMassaMagra,
                        value:
                            '${nf1.format(session.risultati.massaMagraKg)} kg'),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: p.cardBorder),
                const SizedBox(height: 14),
              ] else ...[
                Text(context.l10n.homeNessunaSessionePlico,
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
                  label: Text(context.l10n.homePlicoNuovaMisurazione,
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
                  Text(context.l10n.homeProgressiLabel,
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 2),
                  Text(context.l10n.homeProgressiSubtitle,
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

// ── Riepilogo settimanale (solo lunedì) ────────────────────────────

class _WeeklyRecapCard extends StatefulWidget {
  const _WeeklyRecapCard();

  @override
  State<_WeeklyRecapCard> createState() => _WeeklyRecapCardState();
}

class _WeeklyRecapWeek {
  final double? avgKcal;
  final double? adherence;
  final DateTime start;
  final DateTime end;
  const _WeeklyRecapWeek({
    required this.avgKcal,
    required this.adherence,
    required this.start,
    required this.end,
  });
}

class _WeeklyRecapCardState extends State<_WeeklyRecapCard> {
  bool _loading = true;
  _WeeklyRecapWeek? _current;
  _WeeklyRecapWeek? _previous;
  double? _weightChangeCurrent;
  double? _weightChangePrevious;

  bool get _isMonday => DateTime.now().weekday == DateTime.monday;

  @override
  void initState() {
    super.initState();
    if (_isMonday) _load();
  }

  Future<_WeeklyRecapWeek> _week(
      DateTime start, DateTime end, MealPlan? plan) async {
    final logs = await DatabaseService.instance.getDailyLogsRange(start, end);
    final loggedDays = logs.where((l) => l.entries.isNotEmpty).toList();
    final avgKcal = loggedDays.isEmpty
        ? null
        : loggedDays.fold<double>(0, (s, l) => s + l.kcalTotali) /
            loggedDays.length;

    double? adherence;
    if (plan != null && plan.pasti.isNotEmpty) {
      final planned = plan.pasti.map((m) => m.tipo).toSet();
      final days = List.generate(7, (i) => start.add(Duration(days: i)));
      final values = days.map((day) {
        final log = logs.firstWhere(
          (l) => l.data == day,
          orElse: () => DailyLog()..data = day,
        );
        return _adherenceFor(log, planned);
      });
      adherence = values.fold<double>(0, (s, v) => s + v) / values.length;
    }

    return _WeeklyRecapWeek(
        avgKcal: avgKcal, adherence: adherence, start: start, end: end);
  }

  double? _weightChangeFor(List<BodySnapshot> snapshots, DateTime end) {
    BodySnapshot? before(DateTime limit) {
      for (final s in snapshots) {
        if (!s.data.isAfter(limit)) return s;
      }
      return null;
    }

    final atEnd = before(end);
    if (atEnd == null) return null;
    final atStart = before(end.subtract(const Duration(days: 7)));
    if (atStart == null) return null;
    return atEnd.pesoKg - atStart.pesoKg;
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekEnd = today.subtract(const Duration(days: 1));
    final currentWeekStart = currentWeekEnd.subtract(const Duration(days: 6));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(days: 1));
    final previousWeekStart =
        previousWeekEnd.subtract(const Duration(days: 6));

    final plan = await DatabaseService.instance.getMealPlan();
    final snapshots = await DatabaseService.instance.getBodySnapshots();

    final current = await _week(currentWeekStart, currentWeekEnd, plan);
    final previous = await _week(previousWeekStart, previousWeekEnd, plan);

    if (!mounted) return;
    setState(() {
      _current = current;
      _previous = previous;
      _weightChangeCurrent = _weightChangeFor(snapshots, currentWeekEnd);
      _weightChangePrevious = _weightChangeFor(snapshots, previousWeekEnd);
      _loading = false;
    });
  }

  Widget _row(ColorPalette p, String label, String currentVal, double? delta,
      {bool higherIsBetter = true}) {
    Widget? trend;
    if (delta != null && delta.abs() >= 0.05) {
      final improved = higherIsBetter ? delta > 0 : delta < 0;
      trend = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              delta > 0
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 13,
              color: improved
                  ? const Color(0xFF4CAF8E)
                  : const Color(0xFFFF8C42)),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: p.textMuted, fontSize: 12)),
          Row(
            children: [
              Text(currentVal,
                  style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              if (trend != null) ...[const SizedBox(width: 4), trend],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMonday || _loading) return const SizedBox.shrink();
    final current = _current;
    if (current == null) return const SizedBox.shrink();
    final p = context.palette;

    final l10n = context.l10n;
    final nf1 = NumberFormat.decimalPatternDigits(
        locale: Localizations.localeOf(context).toString(), decimalDigits: 1);
    final kcalLabel = current.avgKcal == null
        ? l10n.homeNessunDato
        : l10n.homeWeeklyAvgKcal('${current.avgKcal!.round()}');
    final kcalDelta = (current.avgKcal != null && _previous?.avgKcal != null)
        ? current.avgKcal! - _previous!.avgKcal!
        : null;

    final pesoLabel = _weightChangeCurrent == null
        ? l10n.homeNessunDato
        : '${_weightChangeCurrent! >= 0 ? '+' : ''}${nf1.format(_weightChangeCurrent!)} kg';
    final pesoDelta =
        (_weightChangeCurrent != null && _weightChangePrevious != null)
            ? _weightChangeCurrent! - _weightChangePrevious!
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
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
                children: [
                  Icon(Icons.calendar_view_week_rounded,
                      color: p.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.homeRiepilogoSettimanale,
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              _row(p, l10n.homeMediaKcal, kcalLabel, kcalDelta,
                  higherIsBetter: false),
              _row(p, l10n.homeVariazionePeso, pesoLabel, pesoDelta,
                  higherIsBetter: false),
              if (current.adherence != null)
                _row(p, l10n.homeAderenzaAlPiano,
                    '${(current.adherence! * 100).round()}%',
                    (_previous?.adherence != null)
                        ? current.adherence! - _previous!.adherence!
                        : null),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Aderenza al piano ─────────────────────────────────────────────

double _adherenceFor(DailyLog? log, Set<int> planned) {
  if (planned.isEmpty) return 0.0;
  final logged = log?.entries.map((e) => e.pastoTipo).toSet() ?? {};
  return logged.intersection(planned).length / planned.length;
}

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
                Text(context.l10n.homeAderenzaHeader,
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
                    context.l10n.homePastiOggi,
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
                Text(context.l10n.homeUltimiSetteGiorni,
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

List<(AchievementType, IconData, String)> _buildBadgeInfo(BuildContext context) => [
  (AchievementType.firstKgLost, Icons.scale_rounded, context.l10n.homeBadge1KgPerso),
  (AchievementType.streak7, Icons.local_fire_department_rounded, context.l10n.homeBadgeStreak7),
  (AchievementType.days30Logged, Icons.calendar_month_rounded, context.l10n.homeBadge30Giorni),
  (AchievementType.weekOnTarget, Icons.flag_rounded, context.l10n.homeBadgeSettimanaTarget),
  (AchievementType.firstWorkout, Icons.fitness_center_rounded, context.l10n.homeBadgePrimaScheda),
  (AchievementType.workoutStreak7, Icons.bolt_rounded, context.l10n.homeBadgeStreak7Allenamento),
  (AchievementType.newWorkoutPr, Icons.emoji_events_rounded, context.l10n.homeBadgeNuovoPr),
  (AchievementType.workoutSessions10, Icons.looks_one_rounded, context.l10n.homeBadge10Sessioni),
  (AchievementType.workoutSessions50, Icons.military_tech_rounded, context.l10n.homeBadge50Sessioni),
];

void _showStreakSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _StreakSheet(),
  );
}

class _StreakSheet extends StatelessWidget {
  const _StreakSheet();

  static const _flame = Color(0xFFFF6B35);

  static const _bolt = Color(0xFF4C8DFF);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<int>(
      stream: StreakService.instance.watchCurrentStreak(),
      builder: (context, streakSnap) {
        final streak = streakSnap.data ?? 0;
        final active = streak > 0;
        return StreamBuilder<int>(
          stream: StreakService.instance.watchCurrentWorkoutStreak(),
          builder: (context, workoutStreakSnap) {
            final workoutStreak = workoutStreakSnap.data ?? 0;
            final workoutActive = workoutStreak > 0;
            return StreamBuilder<Set<AchievementType>>(
              stream: DatabaseService.instance.watchUnlockedTypes(),
              builder: (context, badgeSnap) {
                final unlocked = badgeSnap.data ?? const <AchievementType>{};
                return SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    decoration: BoxDecoration(
                      color: p.background,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: p.cardBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.emoji_events_rounded,
                                color: p.accent, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.homeStreakTitle,
                              style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _StreakRow(
                          icon: Icons.local_fire_department_rounded,
                          color: _flame,
                          label: context.l10n.homeStreakAlimentazione,
                          value: active
                              ? context.l10n.homeStreakGiorni('$streak')
                              : context.l10n.homeStreakNonAttiva,
                          active: active,
                          p: p,
                        ),
                        const SizedBox(height: 10),
                        _StreakRow(
                          icon: Icons.fitness_center_rounded,
                          color: _bolt,
                          label: context.l10n.homeStreakAllenamentoLabel,
                          value: workoutActive
                              ? context.l10n
                                  .homeStreakAllenamentoGiorni('$workoutStreak')
                              : context.l10n.homeStreakNonAttiva,
                          active: workoutActive,
                          p: p,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _buildBadgeInfo(context).map((entry) {
                            final (type, icon, label) = entry;
                            return _BadgeIcon(
                              icon: icon,
                              label: label,
                              unlocked: unlocked.contains(type),
                              p: p,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StreakRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool active;
  final ColorPalette p;

  const _StreakRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.active,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: active ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: active ? 0.35 : 0.15)),
          ),
          child: Icon(icon, color: active ? color : p.textMuted, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: p.textMuted, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Insights automatici ───────────────────────────────────────────

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FutureBuilder<List<String>>(
      future: InsightsService.instance.generate(),
      builder: (context, snap) {
        final insights = snap.data ?? const <String>[];
        if (insights.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < insights.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: p.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            insights[i],
                            style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
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
    return SizedBox(
      width: 70,
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
