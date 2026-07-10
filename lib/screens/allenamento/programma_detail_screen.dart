import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../theme/app_theme.dart';
import '../../models/workout_program.dart';
import '../../models/workout_template.dart';
import '../../services/database_service.dart';
import '../../services/pdf_export_service.dart';
import 'crea_scheda_screen.dart';

class ProgrammaDetailScreen extends StatefulWidget {
  final WorkoutProgram program;
  const ProgrammaDetailScreen({super.key, required this.program});

  @override
  State<ProgrammaDetailScreen> createState() => _ProgrammaDetailScreenState();
}

class _ProgrammaDetailScreenState extends State<ProgrammaDetailScreen> {
  List<WorkoutTemplate> _giorni = [];
  WorkoutTemplate? _suggerito;

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
    final scelta = await _scegliOrigineGiorno();
    if (scelta == null || !mounted) return;
    if (scelta == _OrigineGiorno.nuova) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreaSchedaScreen(programId: widget.program.id, order: _giorni.length),
        ),
      );
    } else {
      await _scegliSchedaEsistente();
    }
    _load();
  }

  Future<_OrigineGiorno?> _scegliOrigineGiorno() async {
    final p = context.palette;
    final l10n = context.l10n;
    return showModalBottomSheet<_OrigineGiorno>(
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
              Text(l10n.programmaDetailAggiungiGiorno,
                  style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _OpzioneMenu(
                icon: Icons.add_rounded,
                label: l10n.creaSchedaTitleNuova,
                p: p,
                onTap: () => Navigator.pop(ctx, _OrigineGiorno.nuova),
              ),
              const SizedBox(height: 8),
              _OpzioneMenu(
                icon: Icons.content_copy_rounded,
                label: l10n.programmaDetailSchedaEsistente,
                p: p,
                onTap: () => Navigator.pop(ctx, _OrigineGiorno.esistente),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scegliSchedaEsistente() async {
    final l10n = context.l10n;
    final p = context.palette;
    final standalone = await DatabaseService.instance.getStandaloneTemplates();
    if (!mounted) return;
    if (standalone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.programmaDetailNessunaSchedaDisponibile)),
      );
      return;
    }
    final scelta = await showModalBottomSheet<WorkoutTemplate>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          decoration: BoxDecoration(
            color: p.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.programmaDetailSchedaEsistente,
                  style: TextStyle(color: p.accent, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: standalone.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = standalone[i];
                    return ListTile(
                      tileColor: p.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(t.name,
                          style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w600)),
                      subtitle: Text(l10n.schedeNEsercizi(t.exercises.length),
                          style: TextStyle(color: p.textMuted, fontSize: 12)),
                      onTap: () => Navigator.pop(ctx, t),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (scelta == null || !mounted) return;
    await DatabaseService.instance
        .duplicateTemplate(scelta, programId: widget.program.id, order: _giorni.length);
  }

  Future<void> _modificaGiorno(WorkoutTemplate giorno) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreaSchedaScreen(existing: giorno)),
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

  /// Popola solo il log di oggi con gli esercizi del giorno scelto e torna al
  /// tab Allenamento: l'avvio della modalità guidata è un'azione separata, dal
  /// pulsante "Avvia allenamento" nel log.
  Future<void> _inizia(WorkoutTemplate giorno) async {
    await DatabaseService.instance.startWorkoutFromTemplate(giorno, DateTime.now());
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
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
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
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
                  if (isCustom)
                    IconButton(
                      onPressed: () => _modificaGiorno(giorno),
                      icon: Icon(Icons.edit_outlined, color: p.textMuted, size: 20),
                      tooltip: l10n.schedeModifica,
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
      ),
    );
  }
}

enum _OrigineGiorno { nuova, esistente }

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
