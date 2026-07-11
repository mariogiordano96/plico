import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../impostazioni/backup_screen.dart';
import 'onboarding_screen.dart';

/// Primo schermo mostrato quando non esiste ancora un profilo utente
/// (`main.dart`, ramo "nessun profilo" del `FutureBuilder` iniziale).
/// Chiede se è la prima volta che si usa Plico (→ [OnboardingScreen],
/// invariato) o se si arriva da un altro dispositivo con un backup da
/// importare (→ stesso flusso di import usato da `BackupScreen`).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showImportStep = false;
  bool _importing = false;

  Future<void> _startImport() async {
    setState(() => _importing = true);
    await runImportBackupFlow(context);
    if (mounted) setState(() => _importing = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _showImportStep ? _buildImportStep(context, p) : _buildChoice(context, p),
        ),
      ),
    );
  }

  Widget _buildChoice(BuildContext context, ColorPalette p) {
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('PLICO',
            style: TextStyle(
                color: p.accent, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 2),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(l10n.welcomeTitolo,
            style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(l10n.welcomeSottotitolo,
            style: TextStyle(color: p.textMuted, fontSize: 14, height: 1.4),
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        _ChoiceCard(
          icon: Icons.rocket_launch_outlined,
          title: l10n.welcomeNuovoButton,
          subtitle: l10n.welcomeNuovoSub,
          p: p,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          ),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          icon: Icons.restore_outlined,
          title: l10n.welcomeImportaButton,
          subtitle: l10n.welcomeImportaSub,
          p: p,
          onTap: () => setState(() => _showImportStep = true),
        ),
      ],
    );
  }

  Widget _buildImportStep(BuildContext context, ColorPalette p) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: p.accent),
          tooltip: l10n.welcomeIndietro,
          onPressed: () => setState(() => _showImportStep = false),
        ),
        const Spacer(),
        Icon(Icons.restore_outlined, color: p.accent, size: 48),
        const SizedBox(height: 20),
        Text(l10n.welcomeImportaStepTitolo,
            style: TextStyle(color: p.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(l10n.welcomeImportaStepDesc,
            style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _importing ? null : _startImport,
          style: FilledButton.styleFrom(
              backgroundColor: p.accent, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _importing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: p.background),
                )
              : Text(l10n.welcomeImportaSelezionaButton,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorPalette p;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: Icon(icon, color: p.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: p.textMuted, fontSize: 12)),
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
