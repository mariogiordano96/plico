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

class _RestTimerSheetState extends State<_RestTimerSheet> with WidgetsBindingObserver {
  late int _remaining;
  late DateTime _endTime;
  Timer? _ticker;
  Timer? _autoCloseTimer;
  bool _done = false;
  bool _closed = false;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Clamp difensivo: un initialSeconds corrotto o fuori range (es. dati
    // legacy) non deve mai tradursi in un countdown assurdo a schermo.
    _remaining = widget.initialSeconds.clamp(0, 600);
    _endTime = DateTime.now().add(Duration(seconds: _remaining));
    NotificationService.instance.scheduleRestTimer(Duration(seconds: _remaining));
    _startTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed) _resync();
  }

  // Ricalcola sempre il tempo residuo dall'orologio reale (_endTime), invece
  // di decrementare un contatore: evita drift quando l'app va in background
  // e i tick del Timer.periodic vengono sospesi dal sistema operativo.
  void _resync() {
    if (_done) return;
    final rem = _endTime.difference(DateTime.now()).inSeconds;
    if (rem <= 0) {
      // Se l'app è in background, il processo può restare vivo abbastanza
      // da far scattare comunque questo tick: non chiamare _onDone() qui,
      // altrimenti cancelRestTimer() cancella la notifica di sistema prima
      // che possa suonare, mentre aptica/suono di questo metodo non sono
      // udibili fuori dal foreground. Si aggiorna solo al resume.
      if (_lifecycle == AppLifecycleState.resumed) _onDone();
    } else {
      setState(() => _remaining = rem);
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _resync());
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
    // Chiusura automatica dopo un istante: lascia il tempo di percepire
    // vibrazione/suono prima di tornare all'esercizio, senza richiedere un tap.
    _autoCloseTimer = Timer(const Duration(seconds: 1), _close);
  }

  void _adjust(int deltaSeconds) {
    if (_done) return;
    final newRemaining = (_remaining + deltaSeconds).clamp(0, 600);
    setState(() {
      _remaining = newRemaining;
      _endTime = DateTime.now().add(Duration(seconds: newRemaining));
    });
    NotificationService.instance.scheduleRestTimer(Duration(seconds: newRemaining));
    if (newRemaining == 0) _onDone();
  }

  void _setAbsolute(int totalSeconds) {
    if (_done) return;
    setState(() {
      _remaining = totalSeconds;
      _endTime = DateTime.now().add(Duration(seconds: totalSeconds));
    });
    NotificationService.instance.scheduleRestTimer(Duration(seconds: totalSeconds));
  }

  void _close() {
    if (_closed) return;
    _closed = true;
    _ticker?.cancel();
    _autoCloseTimer?.cancel();
    NotificationService.instance.cancelRestTimer();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _autoCloseTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
            if (!_done) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PresetChip(label: '1 min', seconds: 60, remaining: _remaining, onTap: _setAbsolute, p: p),
                  const SizedBox(width: 10),
                  _PresetChip(label: '2 min', seconds: 120, remaining: _remaining, onTap: _setAbsolute, p: p),
                  const SizedBox(width: 10),
                  _PresetChip(label: '3 min', seconds: 180, remaining: _remaining, onTap: _setAbsolute, p: p),
                ],
              ),
            ],
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

class _PresetChip extends StatelessWidget {
  final String label;
  final int seconds;
  final int remaining;
  final void Function(int) onTap;
  final ColorPalette p;
  const _PresetChip({
    required this.label,
    required this.seconds,
    required this.remaining,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final selected = remaining == seconds;
    return GestureDetector(
      onTap: () => onTap(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? p.accent.withValues(alpha: 0.12) : p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? p.accent : p.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? p.accent : p.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
