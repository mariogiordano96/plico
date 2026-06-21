import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_program.dart';
import '../../models/workout_template.dart';
import '../../services/database_service.dart';
import 'crea_scheda_screen.dart';
import 'programma_detail_screen.dart';

class LeMieSchedeScreen extends StatefulWidget {
  const LeMieSchedeScreen({super.key});

  @override
  State<LeMieSchedeScreen> createState() => _LeMieSchedeScreenState();
}

class _LeMieSchedeScreenState extends State<LeMieSchedeScreen> {
  List<WorkoutTemplate> _templates = [];
  List<WorkoutProgram> _programs = [];
  final Map<int, WorkoutTemplate?> _nextDayByProgram = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseService.instance;
    final templates = await db.getStandaloneTemplates();
    final programs = await db.getAllPrograms();
    final nextDays = <int, WorkoutTemplate?>{};
    for (final program in programs) {
      nextDays[program.id] = await db.getNextDayForProgram(program.id);
    }
    if (mounted) {
      setState(() {
        _templates = templates;
        _programs = programs;
        _nextDayByProgram
          ..clear()
          ..addAll(nextDays);
      });
    }
  }

  Future<void> _nuovaScheda() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreaSchedaScreen()),
    );
    _load();
  }

  Future<void> _nuovoProgramma() async {
    final l10n = context.l10n;
    final p = context.palette;
    final ctrl = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.creaProgrammaTitle, style: TextStyle(color: p.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.creaProgrammaNomeHint,
            hintStyle: TextStyle(color: p.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.eserciziSalva, style: TextStyle(color: p.accent)),
          ),
        ],
      ),
    );
    if (nome == null || nome.isEmpty || !mounted) return;

    final program = WorkoutProgram()
      ..name = nome
      ..createdAt = DateTime.now();
    final id = await DatabaseService.instance.saveWorkoutProgram(program);
    program.id = id;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProgrammaDetailScreen(program: program)),
    );
    _load();
  }

  Future<void> _duplicaTemplate(WorkoutTemplate t) async {
    await DatabaseService.instance.duplicateTemplate(t);
    _load();
  }

  Future<void> _duplicaProgramma(WorkoutProgram p) async {
    await DatabaseService.instance.duplicateProgram(p);
    _load();
  }

  Future<void> _eliminaTemplate(WorkoutTemplate t) async {
    final l10n = context.l10n;
    final p = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.schedeEliminaTitle, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.schedeEliminaSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.appElimina, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteWorkoutTemplate(t.id);
      _load();
    }
  }

  Future<void> _inizia(WorkoutTemplate t) async {
    await DatabaseService.instance.startWorkoutFromTemplate(t, DateTime.now());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    final presetTemplates = _templates.where((t) => t.isPreset).toList();
    final myTemplates = _templates.where((t) => !t.isPreset).toList();
    final presetPrograms = _programs.where((pr) => pr.isPreset).toList();
    final myPrograms = _programs.where((pr) => !pr.isPreset).toList();

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.schedeTitle,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
        actions: [
          IconButton(
            onPressed: _nuovaScheda,
            icon: Icon(Icons.add_rounded, color: p.accent),
            tooltip: l10n.schedeNuovaScheda,
          ),
          IconButton(
            onPressed: _nuovoProgramma,
            icon: Icon(Icons.calendar_view_week_rounded, color: p.accent),
            tooltip: l10n.schedeNuovoProgramma,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (presetTemplates.isNotEmpty || presetPrograms.isNotEmpty) ...[
            _SectionLabel(l10n.schedeSezionePreimpostate, p),
            const SizedBox(height: 8),
            for (final t in presetTemplates)
              _TemplateCard(
                template: t,
                p: p,
                l10n: l10n,
                onTap: () => _inizia(t),
                trailing: IconButton(
                  onPressed: () => _duplicaTemplate(t),
                  icon: Icon(Icons.copy_rounded, color: p.textMuted, size: 20),
                  tooltip: l10n.schedeDuplica,
                ),
              ),
            for (final pr in presetPrograms)
              _ProgramCard(
                program: pr,
                nextDay: _nextDayByProgram[pr.id],
                p: p,
                l10n: l10n,
                onTap: () => _openProgram(pr),
                trailing: IconButton(
                  onPressed: () => _duplicaProgramma(pr),
                  icon: Icon(Icons.copy_rounded, color: p.textMuted, size: 20),
                  tooltip: l10n.schedeDuplica,
                ),
              ),
            const SizedBox(height: 20),
          ],
          _SectionLabel(l10n.schedeSezioneMie, p),
          const SizedBox(height: 8),
          for (final t in myTemplates)
            _TemplateCard(
              template: t,
              p: p,
              l10n: l10n,
              onTap: () => _inizia(t),
              trailing: IconButton(
                onPressed: () => _eliminaTemplate(t),
                icon: Icon(Icons.delete_outline_rounded, color: p.textMuted, size: 20),
              ),
            ),
          for (final pr in myPrograms)
            _ProgramCard(
              program: pr,
              nextDay: _nextDayByProgram[pr.id],
              p: p,
              l10n: l10n,
              onTap: () => _openProgram(pr),
            ),
        ],
      ),
    );
  }

  Future<void> _openProgram(WorkoutProgram p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProgrammaDetailScreen(program: p)),
    );
    _load();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorPalette p;
  const _SectionLabel(this.text, this.p);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: p.textMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600));
  }
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final ColorPalette p;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final Widget? trailing;

  const _TemplateCard({
    required this.template,
    required this.p,
    required this.l10n,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: ListTile(
        title: Text(template.name,
            style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(l10n.schedeNEsercizi(template.exercises.length),
            style: TextStyle(color: p.textMuted, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) trailing!,
            TextButton(
              onPressed: onTap,
              child: Text(l10n.schedeInizia, style: TextStyle(color: p.accent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  final WorkoutTemplate? nextDay;
  final ColorPalette p;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProgramCard({
    required this.program,
    required this.nextDay,
    required this.p,
    required this.l10n,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.calendar_view_week_rounded, color: p.accent),
        title: Text(program.name,
            style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: nextDay != null
            ? Text(l10n.schedeProssimo(nextDay!.name),
                style: TextStyle(color: p.textMuted, fontSize: 12))
            : null,
        trailing: trailing,
      ),
    );
  }
}
