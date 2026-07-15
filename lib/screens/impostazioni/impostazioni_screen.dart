import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'backup_screen.dart';
import 'notifiche_screen.dart';
import 'smartwatch_screen.dart';

class ImpostazioniScreen extends StatelessWidget {
  const ImpostazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.impostazioniTitolo,
            style: TextStyle(
                color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _MenuTile(
              icon: Icons.notifications_outlined,
              title: l10n.impostazioniNotifiche,
              subtitle: l10n.impostazioniNotificheSub,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificheScreen()),
              ),
              p: p,
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.backup_outlined,
              title: l10n.impostazioniBackup,
              subtitle: l10n.impostazioniBackupSub,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              ),
              p: p,
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.watch_rounded,
              title: l10n.impostazioniSalute,
              subtitle: l10n.impostazioniSaluteSub,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmartwatchScreen()),
              ),
              p: p,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorPalette p;

  const _MenuTile({
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
