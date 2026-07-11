import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../main_screen.dart';
import 'wifi_receive_screen.dart';
import 'wifi_send_screen.dart';

/// Seleziona un file di backup dal file system e lo importa (vedi
/// [confirmAndImportBackup]). Ritorna true solo se l'import è stato
/// completato.
Future<bool> runImportBackupFlow(BuildContext context) async {
  // L'estensione "isar" è registrata come tipo di file custom in
  // ios/Runner/Info.plist (UTExportedTypeDeclarations): senza quella
  // dichiarazione iOS non saprebbe risolverla a un tipo noto e file_picker
  // scarterebbe il filtro (vedi FileUtils.m, "dynamic UTI"), lasciando il
  // file non selezionabile.
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['isar'],
  );
  final path = picked?.files.single.path;
  if (path == null) return false;
  if (!context.mounted) return false;
  return confirmAndImportBackup(context, File(path));
}

/// Valida [file] come backup, chiede conferma esplicita (l'import
/// sovrascrive tutti i dati presenti) e lo importa. A successo ricostruisce
/// la navigazione da zero verso [MainScreen]: l'istanza Isar viene chiusa e
/// riaperta durante l'import, quindi qualunque `watch()` già sottoscritto
/// in schermate montate smetterebbe di aggiornarsi. Ritorna true solo se
/// l'import è stato completato. Punto condiviso da [runImportBackupFlow]
/// (file scelto dal file system) e dal trasferimento via Wi-Fi locale
/// (file scaricato da un altro device).
Future<bool> confirmAndImportBackup(BuildContext context, File file) async {
  final l10n = context.l10n;

  final valid = await DatabaseService.instance.validateBackupFile(file);
  if (!valid) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupImportaFileNonValido)),
    );
    return false;
  }

  if (!context.mounted) return false;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final p = ctx.palette;
      return AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.backupImportaConfermaTitolo,
            style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.backupImportaConfermaBody,
            style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.backupImportaConfermaConferma,
                style: TextStyle(color: p.error)),
          ),
        ],
      );
    },
  );
  if (confirmed != true) return false;

  try {
    await DatabaseService.instance.importBackup(file);
  } catch (e) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupImportaErrore(e.toString()))),
    );
    return false;
  }

  // Un backup può arrivare da una versione più vecchia dell'app: riallinea
  // i dati importati alle stesse correzioni idempotenti già applicate ad
  // ogni avvio (main.dart), es. categorie esercizi corrette nel frattempo.
  await DatabaseService.instance.seedCreaFoods();
  await DatabaseService.instance.migrateFoodNamesV2();
  await DatabaseService.instance.seedExercises();
  await DatabaseService.instance.seedWorkoutPresets();

  if (!context.mounted) return true;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainScreen()),
    (route) => false,
  );
  return true;
}

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final file = await DatabaseService.instance.exportBackup();
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.backupEsportaErrore(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    final ok = await runImportBackupFlow(context);
    if (mounted) setState(() => _importing = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.backupImportaSuccesso)),
      );
    }
  }

  Future<void> _sendViaWifi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WifiSendScreen()),
    );
  }

  Future<void> _receiveViaWifi() async {
    final file = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const WifiReceiveScreen()),
    );
    if (file == null || !mounted) return;
    final ok = await confirmAndImportBackup(context, file);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.backupImportaSuccesso)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.backupTitolo,
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
            _BackupSection(
              icon: Icons.ios_share_rounded,
              title: l10n.backupEsportaTitolo,
              description: l10n.backupEsportaDesc,
              buttonLabel: l10n.backupEsportaButton,
              loading: _exporting,
              onTap: _export,
              p: p,
            ),
            const SizedBox(height: 24),
            _BackupSection(
              icon: Icons.file_download_outlined,
              title: l10n.backupImportaTitolo,
              description: l10n.backupImportaDesc,
              buttonLabel: l10n.backupImportaButton,
              loading: _importing,
              onTap: _import,
              destructive: true,
              p: p,
            ),
            const SizedBox(height: 24),
            Text(l10n.backupWifiTitolo,
                style: TextStyle(
                    color: p.textMuted,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(l10n.backupWifiDesc,
                style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.4)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sendViaWifi,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.backupWifiInviaButton,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: p.accent, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _receiveViaWifi,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l10n.backupWifiRiceviButton,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: p.accent, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final bool loading;
  final bool destructive;
  final VoidCallback onTap;
  final ColorPalette p;

  const _BackupSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.loading,
    required this.onTap,
    required this.p,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Text(title,
                    style: TextStyle(
                        color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : onTap,
              style: FilledButton.styleFrom(
                backgroundColor: destructive ? p.error : p.accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: p.background),
                    )
                  : Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
