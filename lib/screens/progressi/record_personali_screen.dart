import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/personal_record.dart';
import '../../services/database_service.dart';
import '../esercizi/muscle_group_labels.dart';
import '../allenamento/storico_esercizio_screen.dart';

/// "I tuoi record" (Fase 17): bacheca dei PR aggregati per esercizio, filtrabile
/// per gruppo muscolare. Vedi docs/evolutiva_esercizi.md, sezione
/// "Bacheca record personali".
class RecordPersonaliScreen extends StatefulWidget {
  const RecordPersonaliScreen({super.key});

  @override
  State<RecordPersonaliScreen> createState() => _RecordPersonaliScreenState();
}

class _RecordPersonaliScreenState extends State<RecordPersonaliScreen> {
  List<PersonalRecord> _records = [];
  bool _loading = true;
  String? _gruppoSelezionato;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await DatabaseService.instance.getAllPersonalRecords();
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final filtered = _gruppoSelezionato == null
        ? _records
        : _records.where((r) => r.muscleGroup == _gruppoSelezionato).toList();

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.recordPersonaliTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SafeArea(
        top: false,
        child: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [null, ...muscleGroups].map((g) {
                      final selected = g == _gruppoSelezionato;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(muscleGroupLabel(l10n, g)),
                          selected: selected,
                          onSelected: (_) => setState(() => _gruppoSelezionato = g),
                          selectedColor: p.accent.withValues(alpha: 0.2),
                          labelStyle: TextStyle(color: selected ? p.accent : p.textPrimary),
                          backgroundColor: p.surface,
                          side: BorderSide(color: p.cardBorder),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(l10n.recordPersonaliVuoto,
                              style: TextStyle(color: p.textMuted),
                              textAlign: TextAlign.center),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _RecordTile(record: filtered[i], p: p),
                        ),
                ),
              ],
            ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final PersonalRecord record;
  final ColorPalette p;
  const _RecordTile({required this.record, required this.p});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dataLabel = DateFormat('d MMM y', locale).format(record.achievedAt);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoricoEsercizioScreen(
            exerciseId: record.exerciseId,
            exerciseName: record.exerciseName,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.cardBorder),
        ),
        child: Row(
          children: [
            Text('🏆', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.exerciseName,
                      style: TextStyle(
                          color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(dataLabel, style: TextStyle(color: p.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Text(context.l10n.recordPersonaliKg(record.maxWeightKg.toStringAsFixed(1)),
                style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
