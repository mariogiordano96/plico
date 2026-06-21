import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';

/// Dialog per configurare il riposo di default tra le serie (usato in modalità
/// guidata quando un esercizio non ha un `restSeconds` specifico).
/// Vedi docs/evolutiva_esercizi.md, sezione "Modalità esecuzione guidata".
Future<void> showRestTimerSettingsDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RestTimerSettingsDialog(),
  );
}

class _RestTimerSettingsDialog extends StatefulWidget {
  const _RestTimerSettingsDialog();

  @override
  State<_RestTimerSettingsDialog> createState() => _RestTimerSettingsDialogState();
}

class _RestTimerSettingsDialogState extends State<_RestTimerSettingsDialog> {
  int _seconds = 90;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await DatabaseService.instance.getAppSettings();
    if (!mounted) return;
    setState(() {
      _seconds = s.restTimerDefaultSeconds;
      _loading = false;
    });
  }

  Future<void> _salva() async {
    final s = await DatabaseService.instance.getAppSettings();
    s.restTimerDefaultSeconds = _seconds;
    await DatabaseService.instance.saveAppSettings(s);
    if (mounted) Navigator.pop(context);
  }

  void _adjust(int delta) {
    setState(() => _seconds = (_seconds + delta).clamp(15, 600));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.restTimerSettingsTitle,
                    style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _adjust(-15),
                        icon: Icon(Icons.remove_circle_outline_rounded, color: p.accent),
                      ),
                      Text(
                        '${_seconds}s',
                        style: TextStyle(
                            color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () => _adjust(15),
                        icon: Icon(Icons.add_circle_outline_rounded, color: p.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _salva,
                          style: FilledButton.styleFrom(backgroundColor: p.accent),
                          child: Text(l10n.eserciziSalva,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
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
