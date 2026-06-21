import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

/// Mostra il countdown di recupero tra le serie. Programma anche una notifica
/// locale a fine riposo (`NotificationService.scheduleRestTimer`), così l'utente
/// è avvisato anche se cambia schermata o l'app va in background — cancellata se
/// il riposo viene saltato o termina naturalmente mentre il sheet è ancora aperto.
Future<void> showRestTimerSheet(BuildContext context, {required int seconds}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _RestTimerSheet(initialSeconds: seconds),
  );
}

class _RestTimerSheet extends StatefulWidget {
  final int initialSeconds;
  const _RestTimerSheet({required this.initialSeconds});

  @override
  State<_RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<_RestTimerSheet> {
  late int _remaining;
  Timer? _ticker;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    NotificationService.instance.scheduleRestTimer(Duration(seconds: _remaining));
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _onDone();
        return;
      }
      setState(() => _remaining--);
    });
  }

  void _onDone() {
    _ticker?.cancel();
    setState(() {
      _remaining = 0;
      _done = true;
    });
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    NotificationService.instance.cancelRestTimer();
  }

  void _adjust(int deltaSeconds) {
    if (_done) return;
    setState(() => _remaining = (_remaining + deltaSeconds).clamp(0, 600));
    NotificationService.instance.scheduleRestTimer(Duration(seconds: _remaining));
    if (_remaining == 0) _onDone();
  }

  void _close() {
    _ticker?.cancel();
    NotificationService.instance.cancelRestTimer();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return GestureDetector(
      onTap: _done ? _close : null,
      child: SafeArea(
        top: false,
        child: Container(
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.restTimerTitle,
                style: TextStyle(color: p.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              _format(_remaining),
              style: TextStyle(
                color: _done ? p.accent : p.textPrimary,
                fontSize: 44,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            if (!_done)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundButton(label: '-15s', onTap: () => _adjust(-15), p: p),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _close,
                    child: Text(l10n.restTimerSalta, style: TextStyle(color: p.textMuted)),
                  ),
                  const SizedBox(width: 16),
                  _RoundButton(label: '+15s', onTap: () => _adjust(15), p: p),
                ],
              ),
          ],
        ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorPalette p;
  const _RoundButton({required this.label, required this.onTap, required this.p});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: p.cardBorder),
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
    );
  }
}
