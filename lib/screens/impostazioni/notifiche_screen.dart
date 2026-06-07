import 'package:flutter/material.dart';

import '../../models/app_settings.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class NotificheScreen extends StatefulWidget {
  const NotificheScreen({super.key});

  @override
  State<NotificheScreen> createState() => _NotificheScreenState();
}

class _NotificheScreenState extends State<NotificheScreen> {
  AppSettings? _s;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await DatabaseService.instance.getAppSettings();
    if (mounted) setState(() => _s = s);
  }

  Future<void> _save() async {
    if (_s == null) return;
    await DatabaseService.instance.saveAppSettings(_s!);
    await NotificationService.instance.scheduleAll(_s!);
  }

  Future<void> _toggleMaster(bool val) async {
    if (_s == null) return;
    if (val) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permesso notifiche non concesso'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }
    setState(() => _s!.notificheAttive = val);
    await _save();
  }

  Future<void> _pickTime(
      int currentMin, ValueChanged<int> onPicked) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentMin ~/ 60, minute: currentMin % 60),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null || !mounted) return;
    onPicked(t.hour * 60 + t.minute);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text('Promemoria pasti',
            style: TextStyle(
                color: p.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: _s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _masterToggleCard(p),
                if (_s!.notificheAttive) ...[
                  const SizedBox(height: 24),
                  _sectionLabel('PASTI', p),
                  const SizedBox(height: 10),
                  _mealCard(p),
                ],
              ],
            ),
    );
  }

  Widget _masterToggleCard(ColorPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
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
            child: Icon(Icons.notifications_rounded, color: p.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attiva promemoria',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Ricevi una notifica per ogni pasto',
                    style: TextStyle(color: p.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _s!.notificheAttive,
            onChanged: _toggleMaster,
            activeThumbColor: p.accent,
            activeTrackColor: p.accent.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, ColorPalette p) {
    return Text(label,
        style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2));
  }

  Widget _mealCard(ColorPalette p) {
    final rows = [
      _MealRow(
        icon: Icons.free_breakfast_rounded,
        label: 'Colazione',
        active: _s!.notColAttiva,
        minVal: _s!.notColMin,
        onToggle: (v) {
          setState(() => _s!.notColAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notColMin, (v) {
          setState(() => _s!.notColMin = v);
        }),
      ),
      _MealRow(
        icon: Icons.lunch_dining_rounded,
        label: 'Pranzo',
        active: _s!.notPranzoAttiva,
        minVal: _s!.notPranzoMin,
        onToggle: (v) {
          setState(() => _s!.notPranzoAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notPranzoMin, (v) {
          setState(() => _s!.notPranzoMin = v);
        }),
      ),
      _MealRow(
        icon: Icons.dinner_dining_rounded,
        label: 'Cena',
        active: _s!.notCenaAttiva,
        minVal: _s!.notCenaMin,
        onToggle: (v) {
          setState(() => _s!.notCenaAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notCenaMin, (v) {
          setState(() => _s!.notCenaMin = v);
        }),
      ),
      _MealRow(
        icon: Icons.apple_rounded,
        label: 'Spuntino',
        active: _s!.notSpuntinoAttiva,
        minVal: _s!.notSpuntinoMin,
        onToggle: (v) {
          setState(() => _s!.notSpuntinoAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notSpuntinoMin, (v) {
          setState(() => _s!.notSpuntinoMin = v);
        }),
      ),
      _MealRow(
        icon: Icons.fitness_center_rounded,
        label: 'Post-WO',
        active: _s!.notPostWoAttiva,
        minVal: _s!.notPostWoMin,
        onToggle: (v) {
          setState(() => _s!.notPostWoAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notPostWoMin, (v) {
          setState(() => _s!.notPostWoMin = v);
        }),
      ),
      _MealRow(
        icon: Icons.nights_stay_rounded,
        label: 'Spuntino serale',
        active: _s!.notSorAttiva,
        minVal: _s!.notSorMin,
        onToggle: (v) {
          setState(() => _s!.notSorAttiva = v);
          _save();
        },
        onTimeTap: () => _pickTime(_s!.notSorMin, (v) {
          setState(() => _s!.notSorMin = v);
        }),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _buildMealTile(rows[i], p),
            if (i < rows.length - 1)
              Divider(height: 1, indent: 60, color: p.cardBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTile(_MealRow row, ColorPalette p) {
    final timeLabel = _formatMinutes(row.minVal);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(row.icon, color: p.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(row.label,
                style: TextStyle(
                    color: row.active ? p.textPrimary : p.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: row.active ? row.onTimeTap : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: row.active
                    ? p.accent.withValues(alpha: 0.1)
                    : p.cardBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: row.active
                        ? p.accent.withValues(alpha: 0.3)
                        : Colors.transparent),
              ),
              child: Text(timeLabel,
                  style: TextStyle(
                      color: row.active ? p.accent : p.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: row.active,
            onChanged: row.onToggle,
            activeThumbColor: p.accent,
            activeTrackColor: p.accent.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minVal) {
    final h = minVal ~/ 60;
    final m = minVal % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class _MealRow {
  final IconData icon;
  final String label;
  final bool active;
  final int minVal;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  const _MealRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.minVal,
    required this.onToggle,
    required this.onTimeTap,
  });
}
