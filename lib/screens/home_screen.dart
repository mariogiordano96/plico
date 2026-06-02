import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/plicometry_session.dart';
import '../services/database_service.dart';
import '../main.dart';
import 'debug/calibration_screen.dart';
import 'plicometry/method_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
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
          IconButton(
            icon: Icon(Icons.tune_rounded,
                color: p.accent.withValues(alpha: 0.5)),
            tooltip: 'Calibrazione (debug)',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CalibrationScreen())),
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
              Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withValues(alpha: 0.06),
                      border: Border.all(
                          color: p.accent.withValues(alpha: 0.08)))),
              Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.accent.withValues(alpha: 0.08),
                      border: Border.all(
                          color: p.accent.withValues(alpha: 0.12)))),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.background,
                    border: Border.all(color: p.accent, width: 1.5)),
                child: Icon(Icons.person_outline_rounded,
                    color: p.accent, size: 36),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('NUOVA MISURAZIONE',
              style: TextStyle(
                  color: p.textMuted, fontSize: 11, letterSpacing: 2.5)),
          const SizedBox(height: 6),
          Text('Calcola la tua\ncomposizione corporea',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.3)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MethodSelectionScreen()),
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
    return Text(text,
        style: TextStyle(
            color: context.palette.textMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600));
  }
}

class _LastResultCard extends StatelessWidget {
  const _LastResultCard();

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return StreamBuilder<List<PlicometrySession>>(
      stream: DatabaseService.instance.watchPlicometrySessions(),
      builder: (context, snapshot) {
        final session =
            (snapshot.data?.isNotEmpty == true) ? snapshot.data!.first : null;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.cardBorder)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      session == null
                          ? 'Nessuna misurazione'
                          : 'Ultima plicometria',
                      style:
                          TextStyle(color: p.textSecondary, fontSize: 14)),
                  Text(
                    session == null ? 'Inizia ora →' : _formatDate(session.data),
                    style: TextStyle(
                        color: session == null ? p.accent : p.textMuted,
                        fontSize: 13,
                        fontWeight: session == null
                            ? FontWeight.w600
                            : FontWeight.normal),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                      label: 'BF%',
                      value: session != null
                          ? '${session.risultati.bodyFatPercent.toStringAsFixed(1)}%'
                          : '--'),
                  Container(width: 1, height: 40, color: p.cardBorder),
                  _StatItem(
                      label: 'Massa Grassa',
                      value: session != null
                          ? '${session.risultati.massaGrassaKg.toStringAsFixed(1)} kg'
                          : '--'),
                  Container(width: 1, height: 40, color: p.cardBorder),
                  _StatItem(
                      label: 'Massa Magra',
                      value: session != null
                          ? '${session.risultati.massaMagraKg.toStringAsFixed(1)} kg'
                          : '--'),
                ],
              ),
            ],
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
        Text(value,
            style: TextStyle(
                color: p.accent,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}
