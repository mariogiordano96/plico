import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';

/// Vista mensile dei giorni in cui è stato registrato un allenamento,
/// etichettati con il nome della prima scheda/programma fatto quel giorno
/// (+N se ce ne sono altre). Tap su un giorno marcato → ritorna quella data
/// al chiamante (`allenamento_screen.dart` la usa per spostare il tab
/// Allenamento su quel giorno). Vedi docs/evolutiva_esercizi.md, Fase 31.
class CalendarioAllenamentiScreen extends StatefulWidget {
  const CalendarioAllenamentiScreen({super.key});

  @override
  State<CalendarioAllenamentiScreen> createState() => _CalendarioAllenamentiScreenState();
}

class _CalendarioAllenamentiScreenState extends State<CalendarioAllenamentiScreen> {
  late DateTime _month = _firstOfMonth(DateTime.now());
  Map<DateTime, List<String>> _labelsByDay = {};
  bool _loading = true;

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final from = _month;
    final to = DateTime(_month.year, _month.month + 1, 0);
    final labels = await DatabaseService.instance.getWorkoutLabelsForRange(from, to);
    if (!mounted) return;
    setState(() {
      _labelsByDay = labels;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final today = _dayOnly(DateTime.now());

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = _month.weekday - 1; // weekday: 1=lun..7=dom
    final totalCells = leadingBlanks + daysInMonth;
    final trailingBlanks = (7 - (totalCells % 7)) % 7;

    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var d = 1; d <= daysInMonth; d++) DateTime(_month.year, _month.month, d),
      for (var i = 0; i < trailingBlanks; i++) null,
    ];

    final weekdayLabels = List.generate(7, (i) {
      final ref = DateTime(2024, 1, 1 + i); // 1 gen 2024 è un lunedì
      return DateFormat.E(locale).format(ref).substring(0, 1).toUpperCase();
    });

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.calendarioTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: Icon(Icons.chevron_left_rounded, color: p.accent),
                  ),
                  Text(
                    DateFormat.yMMMM(locale).format(_month),
                    style: TextStyle(
                        color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: Icon(Icons.chevron_right_rounded, color: p.accent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final w in weekdayLabels)
                    Expanded(
                      child: Center(
                        child: Text(w,
                            style: TextStyle(
                                color: p.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: p.accent))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: cells.length,
                        itemBuilder: (context, i) {
                          final date = cells[i];
                          if (date == null) return const SizedBox.shrink();
                          final labels = _labelsByDay[date];
                          return _DayCell(
                            day: date.day,
                            labels: labels,
                            isToday: date == today,
                            emptyExerciseLabel: l10n.calendarioEsercizioLibero,
                            onTap: labels != null ? () => Navigator.pop(context, date) : null,
                            p: p,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final List<String>? labels;
  final bool isToday;
  final String emptyExerciseLabel;
  final VoidCallback? onTap;
  final ColorPalette p;

  const _DayCell({
    required this.day,
    required this.labels,
    required this.isToday,
    required this.emptyExerciseLabel,
    required this.onTap,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final hasWorkout = labels != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: hasWorkout ? p.accent.withValues(alpha: 0.12) : p.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isToday ? p.accent : p.cardBorder,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text('$day',
                    style: TextStyle(
                        color: p.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                if (hasWorkout && labels!.length > 1)
                  Positioned(
                    right: -8,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('+${labels!.length - 1}',
                          style: TextStyle(
                              color: p.background,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            if (hasWorkout) ...[
              const SizedBox(height: 2),
              Text(
                labels!.isNotEmpty ? labels!.first : emptyExerciseLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.accent, fontSize: 8, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
