import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';

/// Bottom sheet per configurare l'obiettivo settimanale di allenamenti
/// (Fase 16): toggle on/off + numero di giorni target. `null` in
/// `AppSettings.workoutTargetSettimanale` significa "usa il default
/// suggerito" ([defaultTarget], i giorni del programma attivo).
/// Vedi docs/evolutiva_esercizi.md, sezione "Obiettivo settimanale di allenamenti".
Future<void> showObiettivoSettimanaleSettingsDialog(
  BuildContext context, {
  required int defaultTarget,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ObiettivoSettimanaleSettingsDialog(defaultTarget: defaultTarget),
  );
}

class _ObiettivoSettimanaleSettingsDialog extends StatefulWidget {
  final int defaultTarget;
  const _ObiettivoSettimanaleSettingsDialog({required this.defaultTarget});

  @override
  State<_ObiettivoSettimanaleSettingsDialog> createState() =>
      _ObiettivoSettimanaleSettingsDialogState();
}

class _ObiettivoSettimanaleSettingsDialogState
    extends State<_ObiettivoSettimanaleSettingsDialog> {
  bool _attivo = true;
  late int _target = widget.defaultTarget;
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
      _attivo = s.workoutTargetAttivo;
      _target = s.workoutTargetSettimanale ?? widget.defaultTarget;
      _loading = false;
    });
  }

  Future<void> _salva() async {
    final s = await DatabaseService.instance.getAppSettings();
    s.workoutTargetAttivo = _attivo;
    s.workoutTargetSettimanale = _target;
    await DatabaseService.instance.saveAppSettings(s);
    if (mounted) Navigator.pop(context);
  }

  void _adjust(int delta) {
    setState(() => _target = (_target + delta).clamp(1, 7));
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.obiettivoSettimanaleTitle,
                          style: TextStyle(
                              color: p.accent, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Switch(
                        value: _attivo,
                        onChanged: (v) => setState(() => _attivo = v),
                        activeThumbColor: p.accent,
                        activeTrackColor: p.accent.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  if (_attivo) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _adjust(-1),
                          icon: Icon(Icons.remove_circle_outline_rounded, color: p.accent),
                        ),
                        Text(
                          l10n.obiettivoSettimanaleGiorni(_target),
                          style: TextStyle(
                              color: p.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          onPressed: () => _adjust(1),
                          icon: Icon(Icons.add_circle_outline_rounded, color: p.accent),
                        ),
                      ],
                    ),
                  ],
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
