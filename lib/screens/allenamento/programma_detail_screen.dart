import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_program.dart';
import '../../models/workout_template.dart';
import '../../services/database_service.dart';
import '../../services/pdf_export_service.dart';
import 'crea_scheda_screen.dart';
import 'sessione_guidata_screen.dart';

class ProgrammaDetailScreen extends StatefulWidget {
  final WorkoutProgram program;
  const ProgrammaDetailScreen({super.key, required this.program});

  @override
  State<ProgrammaDetailScreen> createState() => _ProgrammaDetailScreenState();
}

class _ProgrammaDetailScreenState extends State<ProgrammaDetailScreen> {
  List<WorkoutTemplate> _giorni = [];
  WorkoutTemplate? _suggerito;
  bool _avviato = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseService.instance;
    final giorni = await db.getProgramDays(widget.program.id);
    final suggerito = await db.getNextDayForProgram(widget.program.id);
    if (mounted) {
      setState(() {
        _giorni = giorni;
        _suggerito = suggerito;
      });
    }
  }

  Future<void> _aggiungiGiorno() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreaSchedaScreen(programId: widget.program.id, order: _giorni.length),
      ),
    );
    _load();
  }

  Future<void> _eliminaGiorno(WorkoutTemplate giorno) async {
    final l10n = context.l10n;
    final ok = await DatabaseService.instance.deleteWorkoutTemplate(giorno.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.schedeUltimoGiornoErrore)),
      );
      return;
    }
    _load();
  }

  Future<void> _exportPdf() async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    try {
      final bytes = await PdfExportService.generateProgramma(
        widget.program,
        _giorni,
        strings: PdfStrings(
          diarioTitle: l10n.pdfDiarioTitle,
          targetLabel: l10n.pdfTargetLabel,
          kcalGiornoUnit: l10n.tdeeKcalGiornoUnit,
          footerPage: l10n.pdfPagina,
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
        ),
        locale: locale,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'plico_programma.pdf');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pianoErrorePdf)),
      );
    }
  }

  Future<void> _inizia(WorkoutTemplate giorno) async {
    final esercizi =
        await DatabaseService.instance.startWorkoutFromTemplate(giorno, DateTime.now());
    if (!mounted) return;
    setState(() => _avviato = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessioneGuidataScreen(template: giorno, exercises: esercizi),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final isCustom = !widget.program.isPreset;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(widget.program.name,
            style: TextStyle(color: p.accent, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.accent),
        actions: [
          if (_giorni.isNotEmpty)
            IconButton(
              onPressed: _exportPdf,
              icon: Icon(Icons.picture_as_pdf_outlined, color: p.accent),
              tooltip: l10n.pianoEsportaPdf,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (_avviato)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('✓', style: TextStyle(color: p.accent)),
            ),
          if (_giorni.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(l10n.programmaDetailNessunGiorno,
                    style: TextStyle(color: p.textMuted)),
              ),
            ),
          for (final giorno in _giorni)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: giorno.id == _suggerito?.id ? p.accent : p.cardBorder,
                  width: giorno.id == _suggerito?.id ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(giorno.name,
                            style: TextStyle(
                                color: p.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(l10n.schedeNEsercizi(giorno.exercises.length),
                            style: TextStyle(color: p.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isCustom && _giorni.length > 1)
                    IconButton(
                      onPressed: () => _eliminaGiorno(giorno),
                      icon: Icon(Icons.delete_outline_rounded, color: p.textMuted, size: 20),
                    ),
                  TextButton(
                    onPressed: () => _inizia(giorno),
                    child: Text(l10n.schedeInizia, style: TextStyle(color: p.accent)),
                  ),
                ],
              ),
            ),
          if (isCustom)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: _aggiungiGiorno,
                icon: Icon(Icons.add_rounded, color: p.accent),
                label: Text(l10n.programmaDetailAggiungiGiorno,
                    style: TextStyle(color: p.accent)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: p.cardBorder)),
              ),
            ),
        ],
      ),
    );
  }
}
