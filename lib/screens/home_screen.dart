import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../main.dart';
import 'pesate/pesate_screen.dart';
import 'storico/storico_misurazioni_screen.dart';
import 'debug/calibration_screen.dart';
import 'plicometry/method_selection_screen.dart';
import 'progressi/progressi_screen.dart';
import 'tdee/tdee_screen.dart';
import 'diario/diario_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text('PLICO', style: TextStyle(color: p.accent, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: p.accent),
                tooltip: isDark ? 'Modalità chiara' : 'Modalità scura',
                onPressed: () async {
                  final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                  themeNotifier.value = newMode;
                  await DatabaseService.instance.saveIsDarkMode(newMode == ThemeMode.dark);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.history_rounded, color: p.accent),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: p.accent.withValues(alpha: 0.5)),
            tooltip: 'Calibrazione (debug)',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalibrationScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScannerCard(),
            const SizedBox(height: 24),
            _SectionTitle('PLICOMETRIA'),
            const SizedBox(height: 12),
            const _LastResultCard(),
            const SizedBox(height: 16),
            const _TdeeCard(),
            const SizedBox(height: 16),
            const _DiarioCard(),
            const SizedBox(height: 16),
            const _PesateCard(),
            const SizedBox(height: 16),
            const _StoricoCard(),
            const SizedBox(height: 16),
            const _ProgressiCard(),
          ],
        ),
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.cardBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.surface, p.accent.withValues(alpha: 0.05)],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent.withValues(alpha: 0.06), border: Border.all(color: p.accent.withValues(alpha: 0.08)))),
              Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: p.accent.withValues(alpha: 0.08), border: Border.all(color: p.accent.withValues(alpha: 0.12)))),
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.background, border: Border.all(color: p.accent, width: 1.5)),
                child: Icon(Icons.person_outline_rounded, color: p.accent, size: 36),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('NUOVA MISURAZIONE', style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2.5)),
          const SizedBox(height: 6),
          Text('Calcola la tua\ncomposizione corporea', textAlign: TextAlign.center,
              style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MethodSelectionScreen()),
            ),
            child: const Text('INIZIA'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: context.palette.textMuted, fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.w600));
  }
}

class _LastResultCard extends StatelessWidget {
  const _LastResultCard();

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<List<PlicometrySession>>(
      stream: DatabaseService.instance.watchPlicometrySessions(),
      builder: (context, snapshot) {
        final session = (snapshot.data?.isNotEmpty == true) ? snapshot.data!.first : null;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.cardBorder)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(session == null ? 'Nessuna misurazione' : 'Ultima plicometria', style: TextStyle(color: p.textSecondary, fontSize: 14)),
                  Text(
                    session == null ? 'Inizia ora →' : _formatDate(session.data),
                    style: TextStyle(color: session == null ? p.accent : p.textMuted, fontSize: 13, fontWeight: session == null ? FontWeight.w600 : FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'BF%', value: session != null ? '${session.risultati.bodyFatPercent.toStringAsFixed(1)}%' : '--'),
                  Container(width: 1, height: 40, color: p.cardBorder),
                  _StatItem(label: 'Massa Grassa', value: session != null ? '${session.risultati.massaGrassaKg.toStringAsFixed(1)} kg' : '--'),
                  Container(width: 1, height: 40, color: p.cardBorder),
                  _StatItem(label: 'Massa Magra', value: session != null ? '${session.risultati.massaMagraKg.toStringAsFixed(1)} kg' : '--'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PesateCard extends StatelessWidget {
  const _PesateCard();

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

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
            final latest = snapshot.data?.isNotEmpty == true ? snapshot.data!.first : null;

            double? bmi;
            if (latest != null && profile != null && profile.altezzaCm > 0) {
              final hM = profile.altezzaCm / 100;
              bmi = latest.pesoKg / (hM * hM);
            }

            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PesateScreen())),
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
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.monitor_weight_outlined, color: p.accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PESATE', style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2)),
                          const SizedBox(height: 2),
                          Text(
                            latest != null
                                ? '${latest.pesoKg.toStringAsFixed(1)} kg — ${_formatDate(latest.data)}'
                                : 'Nessuna pesata registrata',
                            style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
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
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _bmiColor(bmi, p).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: _bmiColor(bmi, p).withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    _bmiLabel(bmi),
                                    style: TextStyle(
                                      color: _bmiColor(bmi, p),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
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

class _StoricoCard extends StatelessWidget {
  const _StoricoCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<List<dynamic>>(
      stream: DatabaseService.instance.watchMeasurementSnapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoricoMisurazioniScreen())),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.cardBorder)),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: p.accent.withValues(alpha: 0.3))),
                  child: Icon(Icons.straighten_rounded, color: p.accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MISURAZIONI', style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2)),
                      const SizedBox(height: 2),
                      Text(count == 0 ? 'Nessuna misurazione' : '$count giornate registrate',
                          style: TextStyle(color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(value, style: TextStyle(color: p.accent, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _ProgressiCard extends StatelessWidget {
  const _ProgressiCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProgressiScreen())),
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
                  border: Border.all(color: p.accent.withValues(alpha: 0.3))),
              child:
                  Icon(Icons.trending_up_rounded, color: p.accent, size: 20),
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
            Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TdeeCard extends StatefulWidget {
  const _TdeeCard();

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
    _settingsSub = DatabaseService.instance.watchAppSettings().listen((_) => _load());
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final session = await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
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
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TdeeScreen()));
        _load();
      },
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
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3))),
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
                        ? '${_tdee!.toString()} kcal/giorno'
                        : 'Calcola il tuo fabbisogno',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DiarioCard extends StatefulWidget {
  const _DiarioCard();

  @override
  State<_DiarioCard> createState() => _DiarioCardState();
}

class _DiarioCardState extends State<_DiarioCard> {
  double? _kcalLogged;
  int? _kcalTarget;
  StreamSubscription? _settingsSub;

  @override
  void initState() {
    super.initState();
    _load();
    _settingsSub = DatabaseService.instance.watchAppSettings().listen((_) => _load());
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final today = DateTime.now();
    final log = await DatabaseService.instance
        .getDailyLog(DateTime(today.year, today.month, today.day));
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    if (!mounted) return;
    int? target;
    if (profile != null && snapshot != null) {
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
      if (result != null) {
        target = (result.tdee * goalMult[obiettivo.clamp(0, 2)]).round();
      }
    }
    if (mounted) {
      setState(() {
        _kcalLogged = log?.kcalTotali ?? 0;
        _kcalTarget = target;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final logged = _kcalLogged ?? 0;
    final pct = (_kcalTarget != null && _kcalTarget! > 0)
        ? (logged / _kcalTarget!).clamp(0.0, 1.0)
        : 0.0;
    final over = _kcalTarget != null && logged > _kcalTarget!;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiarioScreen()),
        );
        _load();
      },
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
                border: Border.all(color: p.accent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.restaurant_menu_rounded,
                  color: p.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DIARIO ALIMENTARE',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(
                    _kcalTarget != null
                        ? '${logged.round()} / $_kcalTarget kcal'
                        : '${logged.round()} kcal oggi',
                    style: TextStyle(
                        color: over
                            ? const Color(0xFFE74C3C)
                            : p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  if (_kcalTarget != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: p.accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            over ? const Color(0xFFE74C3C) : p.accent),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
