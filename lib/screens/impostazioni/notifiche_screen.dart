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
    await NotificationService.instance.refreshEveningRecap();
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

  // Apre il time picker e restituisce i minuti scelti, o null se annullato.
  Future<int?> _pickTime(int currentMin) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentMin ~/ 60, minute: currentMin % 60),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    ).then((t) => t == null ? null : t.hour * 60 + t.minute);
  }

  // Toggle pasto: abilita/disabilita e, se abilitazione, apre subito il picker.
  Future<void> _toggleMeal({
    required bool newVal,
    required bool Function() getActive,
    required void Function(bool) setActive,
    required int Function() getMin,
    required void Function(int) setMin,
  }) async {
    if (newVal) {
      final picked = await _pickTime(getMin());
      if (!mounted) return;
      setState(() {
        setActive(true);
        if (picked != null) setMin(picked);
      });
    } else {
      setState(() => setActive(false));
    }
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
                  Text('PASTI',
                      style: TextStyle(
                          color: p.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                  const SizedBox(height: 10),
                  _mealCard(p),
                  const SizedBox(height: 12),
                  Text(
                    'Tocca l\'orario per modificarlo.',
                    style: TextStyle(color: p.textMuted, fontSize: 12),
                  ),
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
            child:
                Icon(Icons.notifications_rounded, color: p.accent, size: 20),
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

  Widget _mealCard(ColorPalette p) {
    final tiles = <_MealTileData>[
      _MealTileData(
        icon: Icons.free_breakfast_rounded,
        label: 'Colazione',
        active: _s!.notColAttiva,
        minVal: _s!.notColMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notColAttiva,
          setActive: (x) => _s!.notColAttiva = x,
          getMin: () => _s!.notColMin,
          setMin: (x) => _s!.notColMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notColMin);
          if (picked != null && mounted) {
            setState(() => _s!.notColMin = picked);
            await _save();
          }
        },
      ),
      _MealTileData(
        icon: Icons.lunch_dining_rounded,
        label: 'Pranzo',
        active: _s!.notPranzoAttiva,
        minVal: _s!.notPranzoMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notPranzoAttiva,
          setActive: (x) => _s!.notPranzoAttiva = x,
          getMin: () => _s!.notPranzoMin,
          setMin: (x) => _s!.notPranzoMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notPranzoMin);
          if (picked != null && mounted) {
            setState(() => _s!.notPranzoMin = picked);
            await _save();
          }
        },
      ),
      _MealTileData(
        icon: Icons.dinner_dining_rounded,
        label: 'Cena',
        active: _s!.notCenaAttiva,
        minVal: _s!.notCenaMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notCenaAttiva,
          setActive: (x) => _s!.notCenaAttiva = x,
          getMin: () => _s!.notCenaMin,
          setMin: (x) => _s!.notCenaMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notCenaMin);
          if (picked != null && mounted) {
            setState(() => _s!.notCenaMin = picked);
            await _save();
          }
        },
      ),
      _MealTileData(
        icon: Icons.apple_rounded,
        label: 'Spuntino',
        active: _s!.notSpuntinoAttiva,
        minVal: _s!.notSpuntinoMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notSpuntinoAttiva,
          setActive: (x) => _s!.notSpuntinoAttiva = x,
          getMin: () => _s!.notSpuntinoMin,
          setMin: (x) => _s!.notSpuntinoMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notSpuntinoMin);
          if (picked != null && mounted) {
            setState(() => _s!.notSpuntinoMin = picked);
            await _save();
          }
        },
      ),
      _MealTileData(
        icon: Icons.fitness_center_rounded,
        label: 'Post-WO',
        active: _s!.notPostWoAttiva,
        minVal: _s!.notPostWoMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notPostWoAttiva,
          setActive: (x) => _s!.notPostWoAttiva = x,
          getMin: () => _s!.notPostWoMin,
          setMin: (x) => _s!.notPostWoMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notPostWoMin);
          if (picked != null && mounted) {
            setState(() => _s!.notPostWoMin = picked);
            await _save();
          }
        },
      ),
      _MealTileData(
        icon: Icons.nights_stay_rounded,
        label: 'Spuntino serale',
        active: _s!.notSorAttiva,
        minVal: _s!.notSorMin,
        onToggle: (v) => _toggleMeal(
          newVal: v,
          getActive: () => _s!.notSorAttiva,
          setActive: (x) => _s!.notSorAttiva = x,
          getMin: () => _s!.notSorMin,
          setMin: (x) => _s!.notSorMin = x,
        ),
        onTimeTap: () async {
          final picked = await _pickTime(_s!.notSorMin);
          if (picked != null && mounted) {
            setState(() => _s!.notSorMin = picked);
            await _save();
          }
        },
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
          for (int i = 0; i < tiles.length; i++) ...[
            _buildTile(tiles[i], p),
            if (i < tiles.length - 1)
              Divider(height: 1, indent: 60, color: p.cardBorder),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(_MealTileData d, ColorPalette p) {
    final timeLabel = _formatMin(d.minVal);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(d.icon,
              color: d.active ? p.accent : p.textMuted, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(d.label,
                style: TextStyle(
                    color: d.active ? p.textPrimary : p.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: d.active ? d.onTimeTap : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: d.active
                    ? p.accent.withValues(alpha: 0.1)
                    : p.cardBorder.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: d.active
                        ? p.accent.withValues(alpha: 0.35)
                        : Colors.transparent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(timeLabel,
                      style: TextStyle(
                          color: d.active ? p.accent : p.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  if (d.active) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded,
                        size: 11,
                        color: p.accent.withValues(alpha: 0.7)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: d.active,
            onChanged: d.onToggle,
            activeThumbColor: p.accent,
            activeTrackColor: p.accent.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  String _formatMin(int m) {
    final h = m ~/ 60;
    final min = m % 60;
    return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }
}

class _MealTileData {
  final IconData icon;
  final String label;
  final bool active;
  final int minVal;
  final void Function(bool) onToggle;
  final VoidCallback onTimeTap;

  const _MealTileData({
    required this.icon,
    required this.label,
    required this.active,
    required this.minVal,
    required this.onToggle,
    required this.onTimeTap,
  });
}
