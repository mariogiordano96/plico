import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../services/database_service.dart';
import '../../services/sync_transfer_service.dart';
import '../../theme/app_theme.dart';

enum _SendState { preparing, waiting, transferred, timeout, error }

class WifiSendScreen extends StatefulWidget {
  const WifiSendScreen({super.key});

  @override
  State<WifiSendScreen> createState() => _WifiSendScreenState();
}

class _WifiSendScreenState extends State<WifiSendScreen> {
  final _server = BackupSendServer();
  _SendState _state = _SendState.preparing;
  SyncPairing? _pairing;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _state = _SendState.preparing;
      _pairing = null;
    });
    final File file;
    try {
      file = await DatabaseService.instance.exportBackup();
    } catch (_) {
      if (mounted) setState(() => _state = _SendState.error);
      return;
    }

    final pairing = await _server.start(
      file: file,
      onTransferred: () {
        if (mounted) setState(() => _state = _SendState.transferred);
      },
      onTimeout: () {
        if (mounted) setState(() => _state = _SendState.timeout);
      },
    );
    if (!mounted) return;
    if (pairing == null) {
      setState(() => _state = _SendState.error);
      return;
    }
    setState(() {
      _pairing = pairing;
      _state = _SendState.waiting;
    });
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.wifiSendTitolo,
            style: TextStyle(
                color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(p, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorPalette p, AppLocalizations l10n) {
    switch (_state) {
      case _SendState.preparing:
        return CircularProgressIndicator(color: p.accent);
      case _SendState.waiting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.cardBorder),
              ),
              child: QrImageView(data: _pairing!.toJson(), size: 220),
            ),
            const SizedBox(height: 24),
            Text(l10n.wifiSendDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
                ),
                const SizedBox(width: 10),
                Text(l10n.wifiSendInAttesa,
                    style: TextStyle(color: p.textMuted, fontSize: 13)),
              ],
            ),
          ],
        );
      case _SendState.transferred:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: p.accent, size: 56),
            const SizedBox(height: 16),
            Text(l10n.wifiSendTrasferito,
                style: TextStyle(
                    color: p.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(backgroundColor: p.accent),
              child: Text(l10n.wifiSendChiudi,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      case _SendState.timeout:
      case _SendState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: p.error, size: 48),
            const SizedBox(height: 16),
            Text(
              _state == _SendState.timeout ? l10n.wifiSendTimeout : l10n.wifiSendErroreRete,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _start,
              style: FilledButton.styleFrom(backgroundColor: p.accent),
              child:
                  Text(l10n.wifiSendRiprova, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
    }
  }
}
