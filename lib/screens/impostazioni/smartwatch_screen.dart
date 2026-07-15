import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../services/smartwatch_service.dart';
import '../../theme/app_theme.dart';

/// Impostazioni → "Collega Salute" (docs/integrazione_smartwatch.md sezione 8).
class SmartwatchScreen extends StatefulWidget {
  const SmartwatchScreen({super.key});

  @override
  State<SmartwatchScreen> createState() => _SmartwatchScreenState();
}

class _SmartwatchScreenState extends State<SmartwatchScreen> {
  bool _loading = true;
  bool _connecting = false;
  bool _connected = false;
  bool _available = true; // Health Connect installato; sempre true su iOS

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await DatabaseService.instance.getAppSettings();
    final available = await SmartwatchService.instance.isAvailable();
    if (mounted) {
      setState(() {
        _connected = settings.smartwatchConnected;
        _available = available;
        _loading = false;
      });
    }
  }

  /// Disclaimer privacy esplicito prima della prima richiesta di
  /// autorizzazione (docs/integrazione_smartwatch.md sezione 8): un consenso
  /// deliberato di Plico, distinto dal prompt di sistema di HealthKit/Health
  /// Connect che segue subito dopo.
  Future<bool> _confirmDisclaimer() async {
    final p = context.palette;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.smartwatchTitolo, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.smartwatchDisclaimer, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.smartwatchConnettiButton, style: TextStyle(color: p.accent)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _connect() async {
    if (!await _confirmDisclaimer()) return;
    if (!mounted) return;
    setState(() => _connecting = true);
    final result = await SmartwatchService.instance.requestAuthorization();
    if (!mounted) return;
    switch (result) {
      case SmartwatchAuthorizationResult.granted:
        final settings = await DatabaseService.instance.getAppSettings();
        settings.smartwatchConnected = true;
        await DatabaseService.instance.saveAppSettings(settings);
        if (mounted) setState(() => _connected = true);
      case SmartwatchAuthorizationResult.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.smartwatchPermessoNegato)),
        );
      case SmartwatchAuthorizationResult.unavailable:
        if (mounted) setState(() => _available = false);
    }
    if (mounted) setState(() => _connecting = false);
  }

  Future<void> _disconnect() async {
    final settings = await DatabaseService.instance.getAppSettings();
    settings.smartwatchConnected = false;
    await DatabaseService.instance.saveAppSettings(settings);
    if (mounted) setState(() => _connected = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final hubName = Platform.isIOS ? l10n.smartwatchHubIOS : l10n.smartwatchHubAndroid;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.smartwatchTitolo,
            style: TextStyle(
                color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
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
                              child: Icon(Icons.watch_rounded, color: p.accent, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hubName,
                                      style: TextStyle(
                                          color: p.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    !_available
                                        ? l10n.smartwatchNonDisponibile
                                        : _connected
                                            ? l10n.smartwatchConnesso
                                            : l10n.smartwatchNonConnesso,
                                    style: TextStyle(
                                      color: !_available
                                          ? p.error
                                          : (_connected ? p.accent : p.textMuted),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(l10n.smartwatchDescrizione,
                            style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.4)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _connecting
                                ? null
                                : !_available
                                    ? () => SmartwatchService.instance.installHealthConnect()
                                    : _connected
                                        ? _disconnect
                                        : _connect,
                            style: FilledButton.styleFrom(
                              backgroundColor: _connected ? p.error : p.accent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _connecting
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2, color: p.background),
                                  )
                                : Text(
                                    !_available
                                        ? l10n.smartwatchInstallaHealthConnect
                                        : _connected
                                            ? l10n.smartwatchDisconnetti
                                            : l10n.smartwatchConnettiButton,
                                    style: TextStyle(
                                        color: p.background, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.smartwatchDisclaimer,
                      style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
