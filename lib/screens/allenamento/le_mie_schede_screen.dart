import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_program.dart';
import '../../models/workout_template.dart';
import '../../services/database_service.dart';
import '../../services/pdf_export_service.dart';
import '../esercizi/aggiungi_esercizio_personalizzato_screen.dart';
import 'crea_scheda_screen.dart';
import 'programma_detail_screen.dart';

class LeMieSchedeScreen extends StatefulWidget {
  /// Giorno su cui popolare il log quando si preme "Inizia" — il giorno
  /// selezionato nel tab Allenamento al momento dell'apertura, non
  /// necessariamente oggi (si può navigare qui da un giorno passato).
  final DateTime targetDate;

  const LeMieSchedeScreen({super.key, required this.targetDate});

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

  Future<void> _modificaScheda(WorkoutTemplate t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreaSchedaScreen(existing: t)),
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
      MaterialPageRoute(
          builder: (_) =>
              ProgrammaDetailScreen(program: program, targetDate: widget.targetDate)),
    );
    _load();
  }

  Future<void> _apriMenuCreazione() async {
    final p = context.palette;
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OpzioneMenu(
                icon: Icons.list_alt_rounded,
                label: l10n.schedeNuovaScheda,
                p: p,
                onTap: () {
                  Navigator.pop(ctx);
                  _nuovaScheda();
                },
              ),
              const SizedBox(height: 8),
              _OpzioneMenu(
                icon: Icons.calendar_view_week_rounded,
                label: l10n.creaProgrammaTitle,
                p: p,
                onTap: () {
                  Navigator.pop(ctx);
                  _nuovoProgramma();
                },
              ),
              const SizedBox(height: 8),
              _OpzioneMenu(
                icon: Icons.fitness_center_rounded,
                label: l10n.eserciziNuovoTitle,
                p: p,
                onTap: () {
                  Navigator.pop(ctx);
                  _nuovoEsercizioPersonalizzato();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _nuovoEsercizioPersonalizzato() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AggiungiEsercizioPersonalizzatoScreen()),
    );
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

  /// Popola solo il log del giorno selezionato (Allenamento tab: non
  /// necessariamente oggi) con gli esercizi della scheda (target/serie da
  /// compilare) e torna al tab Allenamento: l'avvio della modalità guidata è
  /// un'azione separata, dal pulsante "Avvia allenamento" nel log.
  Future<void> _inizia(WorkoutTemplate t) async {
    await DatabaseService.instance.startWorkoutFromTemplate(t, widget.targetDate);
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  PdfStrings _pdfStrings(AppLocalizations l10n) {
    return PdfStrings(
      diarioTitle: l10n.pdfDiarioTitle,
      targetLabel: l10n.pdfTargetLabel,
      kcalGiornoUnit: l10n.tdeeKcalGiornoUnit,
      nessunoRegistrato: l10n.pdfNessunDato,
      pastoFallback: l10n.pdfPastoFallback,
      pastoLabels: [
        l10n.pastoColazione, l10n.pastoPranzo, l10n.pastoCena,
        l10n.pastoSpuntino, l10n.pastoPostWo, l10n.pastoSpuntinoSerale,
      ],
      riepilogo: l10n.pdfRiepilogo,
      giorniConDati: l10n.pdfGiorniConDati,
      giorniOnTarget: l10n.pdfGiorniOnTarget,
      mediaLabel: l10n.pdfMediaLabel,
      targetPrefixLabel: l10n.pdfTargetPrefix,
      pianoTitle: l10n.pdfPianoTitle,
      generato: l10n.pdfGenerato,
      pianoSlotLabels: [
        l10n.slotProteina, l10n.slotCarboidrati, l10n.slotVerdura,
        l10n.slotGrassi, l10n.slotExtra, l10n.slotFrutta,
      ],
      schedaPdfTitle: l10n.pdfSchedaTitle,
      programmaPdfTitle: l10n.pdfProgrammaTitle,
      storicoPdfTitle: l10n.pdfStoricoTitle,
      nEsercizi: l10n.schedeNEsercizi,
      nessunaSessione: l10n.storicoNessunaSessione,
      prBadge: l10n.storicoPrBadge,
      durataMin: l10n.allenamentoDurataMin,
      tecnicaForzate: l10n.pdfTecnicaForzate,
      tecnicaRestPause: l10n.pdfTecnicaRestPause,
      tecnicaStripping: l10n.pdfTecnicaStripping,
      tecnicaSuperSlow: l10n.pdfTecnicaSuperSlow,
      pdfColEsercizio: l10n.pdfColEsercizio,
      pdfColDettaglio: l10n.pdfColDettaglio,
      supersetLabel: l10n.creaSchedaSupersetUnito,
      ruoloEsplosiva: l10n.creaSchedaRuoloEsplosiva,
      ruoloLenta: l10n.creaSchedaRuoloLenta,
    );
  }

  Future<void> _exportTemplate(WorkoutTemplate t) async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    try {
      final bytes = await PdfExportService.generateScheda(
        t,
        strings: _pdfStrings(l10n),
        locale: locale,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'plico_scheda.pdf');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pianoErrorePdf)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    final presetTemplates = _templates.where((t) => t.isPreset).toList();
    final myTemplates = _templates.where((t) => !t.isPreset).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final presetPrograms = _programs.where((pr) => pr.isPreset).toList();
    final myPrograms = _programs.where((pr) => !pr.isPreset).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
            onPressed: _apriMenuCreazione,
            icon: Icon(Icons.add_rounded, color: p.accent),
            tooltip: l10n.schedeCreaTooltip,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (myTemplates.isNotEmpty || myPrograms.isNotEmpty) ...[
            _SectionLabel(l10n.schedeSezioneMie, p),
            const SizedBox(height: 8),
            for (final t in myTemplates)
              _TemplateCard(
                template: t,
                p: p,
                l10n: l10n,
                onTap: () => _inizia(t),
                onExportPdf: () => _exportTemplate(t),
                onEdit: () => _modificaScheda(t),
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
            const SizedBox(height: 20),
          ],
          if (presetTemplates.isNotEmpty || presetPrograms.isNotEmpty) ...[
            _SectionLabel(l10n.schedeSezionePreimpostate, p),
            const SizedBox(height: 8),
            for (final t in presetTemplates)
              _TemplateCard(
                template: t,
                p: p,
                l10n: l10n,
                onTap: () => _inizia(t),
                onExportPdf: () => _exportTemplate(t),
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
          ],
        ],
        ),
      ),
    );
  }

  Future<void> _openProgram(WorkoutProgram p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ProgrammaDetailScreen(program: p, targetDate: widget.targetDate)),
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
  final VoidCallback? onExportPdf;
  final VoidCallback? onEdit;
  final Widget? trailing;

  const _TemplateCard({
    required this.template,
    required this.p,
    required this.l10n,
    required this.onTap,
    this.onExportPdf,
    this.onEdit,
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
            if (onExportPdf != null)
              IconButton(
                onPressed: onExportPdf,
                icon: Icon(Icons.picture_as_pdf_outlined, color: p.textMuted, size: 20),
                tooltip: l10n.pianoEsportaPdf,
              ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: p.textMuted, size: 20),
                tooltip: l10n.schedeModifica,
              ),
            if (trailing != null) trailing!,
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.play_circle_fill_rounded, color: p.accent, size: 28),
              tooltip: l10n.schedeInizia,
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

class _OpzioneMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorPalette p;
  final VoidCallback onTap;

  const _OpzioneMenu({
    required this.icon,
    required this.label,
    required this.p,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: p.accent, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      color: p.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
