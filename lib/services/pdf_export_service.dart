import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../models/enums.dart';
import '../models/body_snapshot.dart';
import '../models/plicometry_session.dart';
import '../models/measurement_snapshot.dart';
import '../models/workout_template.dart';
import '../models/workout_template_exercise.dart';
import '../models/workout_program.dart';
import '../models/workout_exercise.dart';
import '../models/workout_set.dart';
import '../services/database_service.dart';
import '../services/workout_progress_service.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;

const _goalMult = [0.80, 1.0, 1.15];

/// Pre-resolved PDF strings. Build from AppLocalizations in the widget layer
/// and pass to PDF generation methods (which have no BuildContext).
class PdfStrings {
  final String diarioTitle;
  final String targetLabel;
  final String kcalGiornoUnit;
  final String nessunoRegistrato;
  final String pastoFallback;
  final List<String> pastoLabels;
  final String riepilogo;
  final String Function(int withData, int days) giorniConDati;
  final String Function(int onTarget, int total) giorniOnTarget;
  final String mediaLabel;
  final String targetPrefixLabel;
  final String pianoTitle;
  final String Function(String created) generato;
  final List<String> pianoSlotLabels;

  // Fase 19: export scheda/programma/storico esercizio
  final String schedaPdfTitle;
  final String programmaPdfTitle;
  final String storicoPdfTitle;
  final String Function(int n) nEsercizi;
  final String nessunaSessione;
  final String prBadge;
  final String Function(int min) durataMin;

  // Fase 6 di docs/tecniche_allenamento.md: etichette tecniche nello storico PDF
  final String tecnicaForzate;
  final String tecnicaRestPause;
  final String tecnicaStripping;
  final String tecnicaSuperSlow;

  // Superset in scheda/programma PDF (tabella esercizi): etichetta di
  // gruppo e ruolo esplosiva/lenta, stesse stringhe usate a schermo in
  // crea_scheda_screen.dart.
  final String supersetLabel;
  final String ruoloEsplosiva;
  final String ruoloLenta;

  // Export "Progressi" (peso/composizione/misurazioni/allenamenti)
  final String progressiPdfTitle;
  final String progressiSezPeso;
  final String progressiSezComposizione;
  final String progressiSezMisurazioni;
  final String progressiSezAllenamentiPdf;
  final String progressiMassaGrassa;
  final String progressiMassaMagra;
  final String progressiNessunDato;
  final String progressiCirconferenze;
  final String progressiPliche;

  // Intestazioni colonna per le tabelle del PDF Progressi
  final String pdfColData;
  final String pdfColPeso;
  final String pdfColBf;
  final String pdfColEsercizio;
  final String pdfColDettaglio;

  const PdfStrings({
    required this.diarioTitle,
    required this.targetLabel,
    required this.kcalGiornoUnit,
    required this.nessunoRegistrato,
    required this.pastoFallback,
    required this.pastoLabels,
    required this.riepilogo,
    required this.giorniConDati,
    required this.giorniOnTarget,
    required this.mediaLabel,
    required this.targetPrefixLabel,
    required this.pianoTitle,
    required this.generato,
    required this.pianoSlotLabels,
    required this.schedaPdfTitle,
    required this.programmaPdfTitle,
    required this.storicoPdfTitle,
    required this.nEsercizi,
    required this.nessunaSessione,
    required this.prBadge,
    required this.durataMin,
    this.tecnicaForzate = 'forz.',
    this.tecnicaRestPause = 'RP',
    this.tecnicaStripping = 'stripping',
    this.tecnicaSuperSlow = 'super slow',
    this.supersetLabel = 'Superset',
    this.ruoloEsplosiva = 'Esplosiva',
    this.ruoloLenta = 'Lenta',
    this.progressiPdfTitle = 'Progressi',
    this.progressiSezPeso = 'PESO',
    this.progressiSezComposizione = 'COMPOSIZIONE CORPOREA',
    this.progressiSezMisurazioni = 'MISURAZIONI',
    this.progressiSezAllenamentiPdf = 'ALLENAMENTI',
    this.progressiMassaGrassa = 'Massa Grassa',
    this.progressiMassaMagra = 'Massa Magra',
    this.progressiNessunDato = 'Nessun dato nel periodo selezionato',
    this.progressiCirconferenze = 'Circonferenze:',
    this.progressiPliche = 'Pliche:',
    this.pdfColData = 'Data',
    this.pdfColPeso = 'Peso',
    this.pdfColBf = 'BF%',
    this.pdfColEsercizio = 'Esercizio',
    this.pdfColDettaglio = 'Dettaglio',
  });
}

/// Argomenti per [PdfExportService._buildProgressiPdfBytes], eseguita in un
/// isolate separato via `compute()`. Solo dati semplici (niente closure: la
/// generazione di uno storico lungo richiede pw.MultiPage a spannare su
/// centinaia di pagine con un calcolo sincrono pesante, che sull'isolate
/// principale blocca la UI abbastanza a lungo da causare un ANR — vedi
/// `PdfExportService.generateProgressi`).
class _ProgressiPdfArgs {
  final String periodLabel;
  final String userName;
  final String? anagrafica;
  final List<BodySnapshot> bodySnapshots;
  final List<PlicometrySession> plicometrySessions;
  final List<MeasurementSnapshot> measurementSnapshots;
  final List<WorkoutExercise> workoutExercises;
  final Map<String, String> misuraLabels;
  final String locale;
  final ByteData fontRegularBytes;
  final ByteData fontBoldBytes;
  final String progressiPdfTitle;
  final String progressiSezPeso;
  final String progressiSezComposizione;
  final String progressiSezMisurazioni;
  final String progressiSezAllenamentiPdf;
  final String progressiMassaGrassa;
  final String progressiMassaMagra;
  final String progressiNessunDato;
  final String progressiCirconferenze;
  final String progressiPliche;
  final String nessunaSessione;
  final String minutiSuffix;
  final String pdfColData;
  final String pdfColPeso;
  final String pdfColBf;
  final String pdfColEsercizio;
  final String pdfColDettaglio;

  const _ProgressiPdfArgs({
    required this.periodLabel,
    required this.userName,
    required this.anagrafica,
    required this.bodySnapshots,
    required this.plicometrySessions,
    required this.measurementSnapshots,
    required this.workoutExercises,
    required this.misuraLabels,
    required this.locale,
    required this.fontRegularBytes,
    required this.fontBoldBytes,
    required this.progressiPdfTitle,
    required this.progressiSezPeso,
    required this.progressiSezComposizione,
    required this.progressiSezMisurazioni,
    required this.progressiSezAllenamentiPdf,
    required this.progressiMassaGrassa,
    required this.progressiMassaMagra,
    required this.progressiNessunDato,
    required this.progressiCirconferenze,
    required this.progressiPliche,
    required this.nessunaSessione,
    required this.minutiSuffix,
    required this.pdfColData,
    required this.pdfColPeso,
    required this.pdfColBf,
    required this.pdfColEsercizio,
    required this.pdfColDettaglio,
  });
}

class PdfExportService {
  PdfExportService._();

  static Future<Uint8List> generateDiario({
    required DateTime from,
    required DateTime to,
    required PdfStrings strings,
    required String locale,
  }) async {
    final db = DatabaseService.instance;

    final profile = await db.getUserProfile();
    final snapshot = await db.getLatestBodySnapshot();
    final session = await db.getLatestPlicometrySession();
    final livello = await db.getLivelloAttivita();
    final metodo = await db.getMetodoTdee();
    final obiettivo = await db.getObiettivo();
    final logs = await db.getDailyLogsRange(from, to);

    int? kcalTarget, protTarget, fatTarget;
    if (profile != null && snapshot != null) {
      final r = calcolaTdee(
        sesso: profile.sesso,
        eta: profile.etaCorrente,
        altezzaCm: profile.altezzaCm,
        pesoKg: snapshot.pesoKg,
        livello: livello,
        metodo: metodo,
        massaMagraKg: session?.risultati.massaMagraKg,
      );
      if (r != null) {
        kcalTarget = (r.tdee * _goalMult[obiettivo.clamp(0, 2)]).round();
        const protMatrix = [
          [1.4, 1.8, 2.3, 2.6, 3.1],
          [0.8, 1.2, 1.4, 1.8, 2.0],
          [1.6, 1.8, 2.0, 2.2, 2.4],
        ];
        protTarget = (snapshot.pesoKg *
                protMatrix[obiettivo.clamp(0, 2)][livello.clamp(0, 4)])
            .round();
        fatTarget = (kcalTarget * 0.25 / 9).round();
      }
    }

    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    return _buildPdf(
      from: from,
      to: to,
      logs: logs,
      profile: profile,
      snapshot: snapshot,
      kcalTarget: kcalTarget,
      protTarget: protTarget,
      fatTarget: fatTarget,
      font: font,
      bold: bold,
      strings: strings,
      locale: locale,
    );
  }

  static Future<Uint8List> _buildPdf({
    required DateTime from,
    required DateTime to,
    required List<DailyLog> logs,
    required UserProfile? profile,
    required BodySnapshot? snapshot,
    required int? kcalTarget,
    required int? protTarget,
    required int? fatTarget,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
    required String locale,
  }) async {
    final doc = pw.Document(compress: true);
    final logMap = {for (final l in logs) _dayOnly(l.data): l};

    final days = <DateTime>[];
    var cur = _dayOnly(from);
    final end = _dayOnly(to);
    while (!cur.isAfter(end)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }

    final userName = profile != null
        ? '${profile.nome} ${profile.cognome}'.trim()
        : '';
    final pesoStr = snapshot != null
        ? '${snapshot.pesoKg.toStringAsFixed(1)} kg'
        : '';
    final targetStr = kcalTarget != null
        ? '$kcalTarget ${strings.kcalGiornoUnit}'
        : '';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        header: (_) => _buildHeader(
          from: from,
          to: to,
          userName: userName,
          pesoStr: pesoStr,
          targetStr: targetStr,
          font: font,
          bold: bold,
          strings: strings,
          locale: locale,
        ),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          ...days.map((d) => _buildDaySection(
                date: d,
                log: logMap[d],
                kcalTarget: kcalTarget,
                font: font,
                bold: bold,
                strings: strings,
                locale: locale,
              )),
          pw.SizedBox(height: 8),
          _buildSummary(
            logs: logs,
            days: days.length,
            kcalTarget: kcalTarget,
            protTarget: protTarget,
            fatTarget: fatTarget,
            font: font,
            bold: bold,
            strings: strings,
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Header pagina ──────────────────────────────────────────────

  static pw.Widget _buildHeader({
    required DateTime from,
    required DateTime to,
    required String userName,
    required String pesoStr,
    required String targetStr,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
    required String locale,
  }) {
    final monthFmt = DateFormat.MMMM(locale);
    final dateFmt = DateFormat.yMd(locale);
    final period = from.month == to.month && from.year == to.year
        ? '${from.day}–${to.day} ${monthFmt.format(from)} ${from.year}'
        : '${dateFmt.format(from)} – ${dateFmt.format(to)}';

    final subtitles = [
      if (userName.isNotEmpty) userName,
      if (pesoStr.isNotEmpty) pesoStr,
      if (targetStr.isNotEmpty) '${strings.targetLabel} $targetStr',
    ].join('  ·  ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('PLICO',
                style: pw.TextStyle(
                    font: bold, fontSize: 16, color: PdfColors.black)),
            pw.Text(strings.diarioTitle,
                style: pw.TextStyle(
                    font: font, fontSize: 11, color: PdfColors.grey600)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(period,
            style: pw.TextStyle(
                font: bold, fontSize: 11, color: PdfColors.grey800)),
        if (subtitles.isNotEmpty)
          pw.Text(subtitles,
              style: pw.TextStyle(
                  font: font, fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  // ── Sezione giorno ─────────────────────────────────────────────

  static pw.Widget _buildDaySection({
    required DateTime date,
    required DailyLog? log,
    required int? kcalTarget,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
    required String locale,
  }) {
    final dayLabel =
        '${DateFormat.EEEE(locale).format(date).toUpperCase()}  ${DateFormat.yMd(locale).format(date)}';

    final hasEntries = log != null && log.entries.isNotEmpty;
    final totalKcal = log?.kcalTotali ?? 0.0;
    final totalProt = log?.proteinTotali ?? 0.0;
    final totalFat = log?.fatTotali ?? 0.0;
    final totalCarbs = log?.carbsTotali ?? 0.0;
    final pct = (kcalTarget != null && kcalTarget > 0)
        ? (totalKcal / kcalTarget * 100).round()
        : null;

    final byMeal = <int, List<MealEntry>>{};
    for (final e in log?.entries ?? <MealEntry>[]) {
      byMeal.putIfAbsent(e.pastoTipo, () => []).add(e);
    }
    final mealOrder = byMeal.keys.toList()..sort();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(dayLabel,
                  style: pw.TextStyle(
                      font: bold, fontSize: 9, color: PdfColors.grey900)),
              if (hasEntries)
                pw.Text(
                  '${totalKcal.round()} kcal'
                  '${pct != null ? '  ($pct%)' : ''}',
                  style: pw.TextStyle(
                      font: font, fontSize: 9, color: PdfColors.grey700),
                ),
            ],
          ),
        ),
        if (!hasEntries)
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 4, 0, 6),
            child: pw.Text(strings.nessunoRegistrato,
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500)),
          )
        else ...[
          pw.SizedBox(height: 4),
          ...mealOrder.map((tipo) {
            final label = tipo < strings.pastoLabels.length
                ? strings.pastoLabels[tipo]
                : strings.pastoFallback;
            final entries = byMeal[tipo]!;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(6, 2, 0, 1),
                  child: pw.Text(label,
                      style: pw.TextStyle(
                          font: bold,
                          fontSize: 8.5,
                          color: PdfColors.grey800)),
                ),
                ...entries.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(14, 1, 6, 1),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              e.foodNome,
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                  color: PdfColors.grey900),
                              maxLines: 1,
                              overflow: pw.TextOverflow.clip,
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.SizedBox(
                            width: 36,
                            child: pw.Text(
                              '${e.quantitaG.round()}g',
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                  color: PdfColors.grey600),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.SizedBox(
                            width: 52,
                            child: pw.Text(
                              '${e.kcal.round()} kcal',
                              style: pw.TextStyle(
                                  font: font,
                                  fontSize: 8,
                                  color: PdfColors.grey700),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            'P${e.proteinG.round()}  G${e.fatG.round()}  C${e.carbsG.round()}',
                            style: pw.TextStyle(
                                font: font,
                                fontSize: 7.5,
                                color: PdfColors.grey500),
                          ),
                        ],
                      ),
                    )),
              ],
            );
          }),
          pw.SizedBox(height: 3),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: pw.Divider(thickness: 0.3, color: PdfColors.grey300),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 1, 6, 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'P ${totalProt.round()}g  ·  G ${totalFat.round()}g  ·  C ${totalCarbs.round()}g',
                  style: pw.TextStyle(
                      font: font, fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  '${totalKcal.round()} kcal${pct != null ? '  ($pct%)' : ''}',
                  style: pw.TextStyle(
                      font: bold, fontSize: 8, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Riepilogo finale ───────────────────────────────────────────

  static pw.Widget _buildSummary({
    required List<DailyLog> logs,
    required int days,
    required int? kcalTarget,
    required int? protTarget,
    required int? fatTarget,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
  }) {
    final withData = logs.where((l) => l.entries.isNotEmpty).toList();
    if (withData.isEmpty) return pw.SizedBox();

    final avgKcal =
        withData.fold(0.0, (s, l) => s + l.kcalTotali) / withData.length;
    final avgProt =
        withData.fold(0.0, (s, l) => s + l.proteinTotali) / withData.length;
    final avgFat =
        withData.fold(0.0, (s, l) => s + l.fatTotali) / withData.length;
    final avgCarbs =
        withData.fold(0.0, (s, l) => s + l.carbsTotali) / withData.length;

    int onTarget = 0;
    if (kcalTarget != null) {
      for (final l in withData) {
        final pct = l.kcalTotali / kcalTarget;
        if (pct >= 0.9 && pct <= 1.05) onTarget++;
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.SizedBox(height: 6),
        pw.Text(strings.riepilogo,
            style: pw.TextStyle(
                font: bold, fontSize: 10, color: PdfColors.grey900)),
        pw.SizedBox(height: 5),
        pw.Text(
          strings.giorniConDati(withData.length, days),
          style:
              pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
        ),
        if (kcalTarget != null)
          pw.Text(
            strings.giorniOnTarget(onTarget, withData.length),
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColors.grey700),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${strings.mediaLabel} ${avgKcal.round()} kcal  ·  P ${avgProt.round()}g  ·  G ${avgFat.round()}g  ·  C ${avgCarbs.round()}g',
          style:
              pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
        ),
        if (kcalTarget != null || protTarget != null || fatTarget != null)
          pw.Text(
            '${strings.targetPrefixLabel} '
            '${kcalTarget != null ? '$kcalTarget kcal  ·  ' : ''}'
            '${protTarget != null ? 'P ${protTarget}g  ·  ' : ''}'
            '${fatTarget != null ? 'G ${fatTarget}g' : ''}',
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColors.grey500),
          ),
      ],
    );
  }

  // ── Piano alimentare PDF ───────────────────────────────────────

  static Future<Uint8List> generatePiano(
    MealPlan plan, {
    required PdfStrings strings,
    required String locale,
  }) async {
    final db = DatabaseService.instance;
    final profile = await db.getUserProfile();
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    final userName = profile != null
        ? '${profile.nome} ${profile.cognome}'.trim()
        : '';
    final created = DateFormat.yMd(locale).format(plan.dataCreazione);

    final doc = pw.Document(compress: true);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        header: (_) => _buildPianoHeader(
          userName: userName,
          created: created,
          plan: plan,
          font: font,
          bold: bold,
          strings: strings,
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          ...plan.pasti.map((meal) => _buildPianoMeal(meal, font, bold, strings)),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _buildPianoHeader({
    required String userName,
    required String created,
    required MealPlan plan,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
  }) {
    final macro = '${plan.kcalTotali.round()} kcal  ·  '
        'P ${plan.proteineTotali.round()}g  ·  '
        'G ${plan.grassiTotali.round()}g  ·  '
        'C ${plan.carbsTotali.round()}g';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('PLICO',
                style: pw.TextStyle(
                    font: bold, fontSize: 16, color: PdfColors.black)),
            pw.Text(strings.pianoTitle,
                style: pw.TextStyle(
                    font: font, fontSize: 11, color: PdfColors.grey600)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '${strings.generato(created)}${userName.isNotEmpty ? '  ·  $userName' : ''}',
          style: pw.TextStyle(
              font: bold, fontSize: 11, color: PdfColors.grey800)),
        pw.Text(macro,
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildPianoMeal(
      PlanMeal meal, pw.Font font, pw.Font bold, PdfStrings strings) {
    final label = meal.tipo < strings.pastoLabels.length
        ? strings.pastoLabels[meal.tipo]
        : strings.pastoFallback;
    final validSlots = meal.slots.where((s) => s.principale != null).toList();
    if (validSlots.isEmpty) return pw.SizedBox();

    final mealKcal =
        validSlots.fold(0.0, (s, slot) => s + (slot.principale?.kcal ?? 0));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label.toUpperCase(),
                  style: pw.TextStyle(
                      font: bold, fontSize: 9, color: PdfColors.grey900)),
              pw.Text('${mealKcal.round()} kcal',
                  style: pw.TextStyle(
                      font: font, fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        ...validSlots.map((slot) {
          final slotLabel = slot.tipo < strings.pianoSlotLabels.length
              ? strings.pianoSlotLabels[slot.tipo]
              : '';
          final f = slot.principale!;
          final alts =
              slot.alternative.where((a) => a.nome.isNotEmpty).toList();
          return pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 2, 6, 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 64,
                      child: pw.Text(slotLabel,
                          style: pw.TextStyle(
                              font: bold,
                              fontSize: 8,
                              color: PdfColors.grey500)),
                    ),
                    pw.Expanded(
                      child: pw.Text(f.nome,
                          style: pw.TextStyle(
                              font: bold,
                              fontSize: 9,
                              color: PdfColors.grey900),
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('${f.quantitaG.round()}g',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 8,
                            color: PdfColors.grey600)),
                    pw.SizedBox(width: 6),
                    pw.Text('${f.kcal.round()} kcal',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 8,
                            color: PdfColors.grey700)),
                    pw.SizedBox(width: 6),
                    pw.Text(
                        'P${f.proteine.round()} G${f.grassi.round()} C${f.carboidrati.round()}',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 7.5,
                            color: PdfColors.grey500)),
                  ],
                ),
                if (alts.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 64, top: 1),
                    child: pw.Text(
                      'Alt: ${alts.map((a) => '${a.nome} (${a.quantitaG.round()}g)').join(', ')}',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 7.5,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey500),
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 6),
      ],
    );
  }

  // ── Scheda allenamento PDF ──────────────────────────────────────

  static Future<Uint8List> generateScheda(
    WorkoutTemplate template, {
    required PdfStrings strings,
    required String locale,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    final doc = pw.Document(compress: true);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        header: (_) => _buildDocHeader(
          docTitle: strings.schedaPdfTitle,
          subtitle: template.name,
          detail: strings.nEsercizi(template.exercises.length),
          font: font,
          bold: bold,
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          _buildSchedaEsercizi(template.exercises, font, bold, strings),
        ],
      ),
    );
    return doc.save();
  }

  // ── Programma (più giorni/scheda) PDF ───────────────────────────

  static Future<Uint8List> generateProgramma(
    WorkoutProgram program,
    List<WorkoutTemplate> giorni, {
    required PdfStrings strings,
    required String locale,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    final doc = pw.Document(compress: true);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        header: (_) => _buildDocHeader(
          docTitle: strings.programmaPdfTitle,
          subtitle: program.name,
          detail: null,
          font: font,
          bold: bold,
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          for (final giorno in giorni) ...[
            pw.Container(
              color: PdfColors.grey100,
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(giorno.name,
                      style: pw.TextStyle(
                          font: bold, fontSize: 9, color: PdfColors.grey900)),
                  pw.Text(strings.nEsercizi(giorno.exercises.length),
                      style: pw.TextStyle(
                          font: font, fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 4),
            _buildSchedaEsercizi(giorno.exercises, font, bold, strings),
            pw.SizedBox(height: 10),
          ],
        ],
      ),
    );
    return doc.save();
  }

  // Etichetta di una serie pianificata in scheda, tecnica inclusa — stessa
  // idea di `_setLabelPdf` (storico, serie già eseguite) ma su
  // `WorkoutTemplateSet` e con anche il dettaglio numerico dello stripping
  // (i pesi di scarico), utile qui perché è quello che si porta in
  // palestra, a differenza dello storico dove serve solo confermare che la
  // tecnica è stata usata.
  static String _plannedSetLabelPdf(WorkoutTemplateSet s, PdfStrings strings) {
    final base = '${s.reps ?? '-'}×${s.weightKg ?? '-'}kg';
    return switch (s.technique) {
      SetTechnique.forzate => '$base (+${s.forcedReps} ${strings.tecnicaForzate})',
      SetTechnique.superSlow => '$base (${strings.tecnicaSuperSlow})',
      SetTechnique.restPause =>
        '$base (${strings.tecnicaRestPause} ${s.restPauseClusters!.join("+")})',
      SetTechnique.stripping => '$base (${strings.tecnicaStripping} '
          '${s.dropStages!.map((d) => '${d.reps ?? '-'}×${d.weightKg ?? '-'}kg').join(' → ')})',
      SetTechnique.normale => base,
    };
  }

  // Un esercizio per riga: quando ci sono più serie pianificate o una
  // tecnica (cluster rest-pause, gradini di stripping...) il dettaglio va
  // nella stessa riga, impilato su più righe di testo nella cella — la riga
  // della tabella si allarga di conseguenza (vedi nota su `pw.Table` in
  // `_buildProgressiTable`), niente riga separata per esercizio/tecnica.
  static List<pw.Widget> _schedaEsercizioCells(
    WorkoutTemplateExercise e,
    pw.Font font,
    pw.Font bold,
    PdfStrings strings,
  ) {
    final nomeLines = <pw.Widget>[
      pw.Text(e.exerciseName,
          style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.grey900)),
    ];
    if (e.supersetGroupId != null) {
      final ruolo = switch (e.supersetRole) {
        'esplosiva' => strings.ruoloEsplosiva,
        'lenta' => strings.ruoloLenta,
        _ => null,
      };
      nomeLines.add(pw.Text(
        ruolo != null ? '${strings.supersetLabel} · $ruolo' : strings.supersetLabel,
        style: pw.TextStyle(
            font: font, fontSize: 7.5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500),
      ));
    }

    final planned = e.plannedSets;
    final pw.Widget dettaglio;
    if (e.isCardio) {
      dettaglio = pw.Text(strings.durataMin(e.targetDurationSeconds! ~/ 60),
          style: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.grey900));
    } else if (planned != null && planned.isNotEmpty) {
      // Le tecniche (Fase 7 di docs/tecniche_allenamento.md) sostituiscono il
      // target uniforme con `plannedSets`: senza questo branch il target
      // restava sempre "-×-" (targetSets/targetReps sono null per quegli
      // esercizi) e la tecnica non compariva affatto.
      dettaglio = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: planned
            .map((s) => pw.Text(_plannedSetLabelPdf(s, strings),
                style: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.grey900)))
            .toList(),
      );
    } else {
      final target = '${e.targetSets ?? '-'}×${e.targetReps ?? '-'}'
          '${e.targetWeightKg != null ? ' · ${e.targetWeightKg}kg' : ''}';
      dettaglio = pw.Text(target,
          style: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.grey900));
    }

    return [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: nomeLines),
      dettaglio,
    ];
  }

  static pw.Widget _buildSchedaEsercizi(
    List<WorkoutTemplateExercise> esercizi,
    pw.Font font,
    pw.Font bold,
    PdfStrings strings,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: [strings.pdfColEsercizio, strings.pdfColDettaglio],
      data: esercizi.map((e) => _schedaEsercizioCells(e, font, bold, strings)).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      headerStyle: pw.TextStyle(font: bold, fontSize: 8.5, color: PdfColors.white),
      headerAlignment: pw.Alignment.centerLeft,
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      cellAlignment: pw.Alignment.topLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: const {0: pw.FlexColumnWidth(1.2), 1: pw.FlexColumnWidth(1.5)},
      defaultColumnWidth: const pw.FlexColumnWidth(),
    );
  }

  // ── Storico esercizio PDF ───────────────────────────────────────

  static Future<Uint8List> generateStoricoEsercizio({
    required String exerciseName,
    required List<WorkoutExercise> history,
    required PdfStrings strings,
    required String locale,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final dateFmt = DateFormat.yMd(locale);

    final doc = pw.Document(compress: true);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        header: (_) => _buildDocHeader(
          docTitle: strings.storicoPdfTitle,
          subtitle: exerciseName,
          detail: null,
          font: font,
          bold: bold,
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          if (history.isEmpty)
            pw.Text(strings.nessunaSessione,
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500))
          else
            for (var i = 0; i < history.length; i++)
              _buildStoricoRow(
                session: history[i],
                isPr: WorkoutProgressService.isNewPersonalRecord(
                    history[i], history.sublist(i + 1)),
                dateFmt: dateFmt,
                font: font,
                bold: bold,
                strings: strings,
              ),
        ],
      ),
    );
    return doc.save();
  }

  /// Etichetta di una serie per lo storico PDF, tecnica inclusa
  /// (docs/tecniche_allenamento.md, Fase 6) — niente emoji: il font PDF
  /// (NotoSans) non ne garantisce il rendering, diversamente dalla stessa
  /// etichetta a schermo (`storico_esercizio_screen.dart`).
  static String _setLabelPdf(WorkoutSet s, PdfStrings strings) {
    final base = '${s.reps ?? '-'}×${s.weightKg ?? '-'}kg';
    return switch (s.technique) {
      SetTechnique.forzate => '$base (+${s.forcedReps} ${strings.tecnicaForzate})',
      SetTechnique.superSlow => '$base (${strings.tecnicaSuperSlow})',
      SetTechnique.restPause =>
        '$base (${strings.tecnicaRestPause} ${s.restPauseClusters!.join("+")})',
      SetTechnique.stripping => '$base (${strings.tecnicaStripping})',
      SetTechnique.normale => base,
    };
  }

  static pw.Widget _buildStoricoRow({
    required WorkoutExercise session,
    required bool isPr,
    required DateFormat dateFmt,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
  }) {
    final isCardio = session.isCardio;
    final detail = isCardio
        ? (session.durationSeconds != null
            ? strings.durataMin(session.durationSeconds! ~/ 60)
            : '-')
        : session.sets.map((s) => _setLabelPdf(s, strings)).join(', ');

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 64,
            child: pw.Text(dateFmt.format(session.date),
                style: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.grey600)),
          ),
          pw.Expanded(
            child: pw.Text(detail,
                style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey900)),
          ),
          if (isPr && !isCardio)
            pw.Text(strings.prBadge,
                style: pw.TextStyle(font: bold, fontSize: 8.5, color: PdfColors.grey800)),
        ],
      ),
    );
  }

  // ── Export "Progressi" (peso/composizione/misurazioni/allenamenti) ────

  /// Esporta i dati delle sezioni mostrate in [ProgressiScreen] per il
  /// periodo già filtrato a schermo: peso, composizione corporea,
  /// misurazioni e il log degli allenamenti registrati. Le liste vanno già
  /// filtrate/ordinate dal chiamante (stesso range della UI).
  static Future<Uint8List> generateProgressi({
    required String periodLabel,
    required UserProfile? profile,
    required List<BodySnapshot> bodySnapshots,
    required List<PlicometrySession> plicometrySessions,
    required List<MeasurementSnapshot> measurementSnapshots,
    required List<WorkoutExercise> workoutExercises,
    required Map<String, String> misuraLabels,
    required PdfStrings strings,
    required String locale,
  }) async {
    // Font caricati qui (I/O di rete/disco, va bene sull'isolate principale):
    // dentro l'isolate di calcolo passiamo solo i byte grezzi, ricostruendo
    // il pw.Font li' — un'istanza pw.Font gia' costruita non attraverserebbe
    // il confine dell'isolate.
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final fontRegularBytes = (regularFont as pw.TtfFont).data;
    final fontBoldBytes = (boldFont as pw.TtfFont).data;

    final userName =
        profile != null ? '${profile.nome} ${profile.cognome}'.trim() : '';
    final anagrafica = profile == null
        ? null
        : '${profile.sesso == Sesso.maschio ? 'Uomo' : 'Donna'} · '
            '${profile.etaCorrente} anni · ${profile.altezzaCm.round()} cm';

    // Costruire e impaginare centinaia di pagine (uno storico di un anno) e'
    // un calcolo sincrono pesante: farlo sull'isolate principale blocca la UI
    // abbastanza a lungo da far scattare un ANR di Android ("Input
    // dispatching timed out"), verificato con adb logcat. Lo eseguiamo quindi
    // su un isolate separato con compute() — per questo `PdfStrings` (che
    // contiene closure legate all'istanza AppLocalizations, non
    // trasferibili tra isolate) non attraversa il confine: estraiamo solo le
    // stringhe semplici effettivamente usate in questo export.
    return compute(
      _buildProgressiPdfBytes,
      _ProgressiPdfArgs(
        periodLabel: periodLabel,
        userName: userName,
        anagrafica: anagrafica,
        bodySnapshots: bodySnapshots,
        plicometrySessions: plicometrySessions,
        measurementSnapshots: measurementSnapshots,
        workoutExercises: workoutExercises,
        misuraLabels: misuraLabels,
        locale: locale,
        fontRegularBytes: fontRegularBytes,
        fontBoldBytes: fontBoldBytes,
        progressiPdfTitle: strings.progressiPdfTitle,
        progressiSezPeso: strings.progressiSezPeso,
        progressiSezComposizione: strings.progressiSezComposizione,
        progressiSezMisurazioni: strings.progressiSezMisurazioni,
        progressiSezAllenamentiPdf: strings.progressiSezAllenamentiPdf,
        progressiMassaGrassa: strings.progressiMassaGrassa,
        progressiMassaMagra: strings.progressiMassaMagra,
        progressiNessunDato: strings.progressiNessunDato,
        progressiCirconferenze: strings.progressiCirconferenze,
        progressiPliche: strings.progressiPliche,
        nessunaSessione: strings.nessunaSessione,
        // Entrambe le lingue supportate oggi formattano la durata cardio
        // come "{min} min" (vedi app_it.arb/app_en.arb, allenamentoDurataMin):
        // evitiamo di passare la closure `strings.durataMin` (non
        // trasferibile) dato che il risultato e' identico.
        minutiSuffix: 'min',
        pdfColData: strings.pdfColData,
        pdfColPeso: strings.pdfColPeso,
        pdfColBf: strings.pdfColBf,
        pdfColEsercizio: strings.pdfColEsercizio,
        pdfColDettaglio: strings.pdfColDettaglio,
      ),
    );
  }

  static Future<Uint8List> _buildProgressiPdfBytes(_ProgressiPdfArgs args) async {
    await initializeDateFormatting(args.locale);
    final font = pw.TtfFont(args.fontRegularBytes);
    final bold = pw.TtfFont(args.fontBoldBytes);
    final dateFmt = DateFormat.yMd(args.locale);

    final peso = [...args.bodySnapshots]..sort((a, b) => a.data.compareTo(b.data));
    final composizione = [...args.plicometrySessions]
      ..sort((a, b) => a.data.compareTo(b.data));
    final misurazioni = [...args.measurementSnapshots]
      ..sort((a, b) => a.data.compareTo(b.data));

    final byDay = <DateTime, List<WorkoutExercise>>{};
    for (final e in args.workoutExercises) {
      byDay.putIfAbsent(e.date, () => []).add(e);
    }
    final workoutDays = byDay.keys.toList()..sort();

    final doc = pw.Document(compress: true);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        // Con uno storico di più anni il documento intero può legittimamente
        // superare le 20 pagine (default della libreria, pensato per
        // intercettare widget bloccati, non documenti genuinamente lunghi)
        // — alzato per non far scattare `TooManyPagesException` su un export
        // corretto ma voluminoso (vedi `_buildProgressiTable`).
        maxPages: 1000,
        header: (_) => _buildDocHeader(
          docTitle: args.progressiPdfTitle,
          subtitle: args.periodLabel,
          detail: args.anagrafica,
          name: args.userName,
          font: font,
          bold: bold,
        ),
        build: (_) => [
          pw.SizedBox(height: 12),
          ..._buildProgressiTable(
            title: args.progressiSezPeso,
            headers: [args.pdfColData, args.pdfColPeso],
            rows: peso.isEmpty
                ? null
                : peso
                    .map((s) => [dateFmt.format(s.data), '${s.pesoKg.toStringAsFixed(1)} kg'])
                    .toList(),
            emptyLabel: args.progressiNessunDato,
            font: font,
            bold: bold,
            columnWidths: const {0: pw.FixedColumnWidth(70)},
          ),
          ..._buildProgressiTable(
            title: args.progressiSezComposizione,
            headers: [args.pdfColData, args.pdfColBf, args.progressiMassaGrassa, args.progressiMassaMagra],
            rows: composizione.isEmpty
                ? null
                : composizione
                    .map((s) => [
                          dateFmt.format(s.data),
                          s.risultati.bodyFatPercent.toStringAsFixed(1),
                          '${s.risultati.massaGrassaKg.toStringAsFixed(1)} kg',
                          '${s.risultati.massaMagraKg.toStringAsFixed(1)} kg',
                        ])
                    .toList(),
            emptyLabel: args.progressiNessunDato,
            font: font,
            bold: bold,
            columnWidths: const {0: pw.FixedColumnWidth(70)},
          ),
          ..._buildProgressiTable(
            title: args.progressiSezMisurazioni,
            headers: [args.pdfColData, args.progressiCirconferenze, args.progressiPliche],
            rows: misurazioni.isEmpty
                ? null
                : misurazioni
                    .map((s) => _misurazioneRowCells(dateFmt.format(s.data), s, args.misuraLabels))
                    .toList(),
            emptyLabel: args.progressiNessunDato,
            font: font,
            bold: bold,
            columnWidths: const {0: pw.FixedColumnWidth(60)},
          ),
          ..._buildProgressiTable(
            title: args.progressiSezAllenamentiPdf,
            headers: [args.pdfColData, args.pdfColEsercizio, args.pdfColDettaglio],
            rows: workoutDays.isEmpty
                ? null
                : [
                    for (final d in workoutDays)
                      for (final e in byDay[d]!)
                        [dateFmt.format(d), e.exerciseName, _workoutExerciseDetail(e, args.minutiSuffix)]
                  ],
            emptyLabel: args.nessunaSessione,
            font: font,
            bold: bold,
            columnWidths: const {0: pw.FixedColumnWidth(58), 1: pw.FlexColumnWidth(1.3), 2: pw.FlexColumnWidth(2)},
          ),
        ],
      ),
    );
    return doc.save(enableEventLoopBalancing: true);
  }

  // Ogni sezione va spread (`...`) direttamente nei figli di primo livello di
  // `pw.MultiPage.build`, MAI avvolta in un `pw.Padding`: `pw.Table` (come
  // ogni `SpanningWidget`) si spezza tra più pagine se non ci sta in una
  // sola, ma `pw.Padding` no.
  //
  // A differenza di `pw.Column`/`Flex` (che nel package `pdf` 3.x prova a far
  // stare TUTTI i figli in un colpo solo e, se non ci riescono, rimane
  // "bloccata" a riprovare sulla pagina successiva — da cui il vecchio
  // workaround di spezzare le righe in Column-chunk da 10), `pw.Table`
  // spezza le righe una alla volta internamente (vedi `Table.layout` nel
  // package `pdf`): può quindi ricevere l'intera lista di righe di una
  // sezione in un solo widget, senza bisogno di chunking manuale.
  static List<pw.Widget> _buildProgressiTable({
    required String title,
    required List<String> headers,
    required List<List<String>>? rows,
    required String emptyLabel,
    required pw.Font font,
    required pw.Font bold,
    Map<int, pw.TableColumnWidth>? columnWidths,
  }) {
    final widgets = <pw.Widget>[
      pw.Text(title,
          style: pw.TextStyle(
              font: bold, fontSize: 10, color: PdfColors.grey700, letterSpacing: 1.2)),
      pw.SizedBox(height: 6),
    ];

    if (rows == null || rows.isEmpty) {
      widgets.add(pw.Text(emptyLabel,
          style: pw.TextStyle(
              font: font,
              fontSize: 9,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey500)));
    } else {
      widgets.add(pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
        headerStyle: pw.TextStyle(font: bold, fontSize: 8.5, color: PdfColors.white),
        headerAlignment: pw.Alignment.centerLeft,
        headerPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        cellStyle: pw.TextStyle(font: font, fontSize: 8.5, color: PdfColors.grey900),
        cellAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        columnWidths: columnWidths,
        defaultColumnWidth: const pw.FlexColumnWidth(),
      ));
    }

    widgets.add(pw.SizedBox(height: 14));
    return widgets;
  }

  // Circonferenze (cm) e pliche (mm) sono grandezze diverse — mai nella
  // stessa cella: senza questa separazione una "Coscia" a 58cm (circonferenza)
  // e una "Coscia" a 10mm (plica) finivano nella stessa stringa concatenata,
  // distinguibili solo dall'unità di misura in coda.
  static List<String> _misurazioneRowCells(
    String date,
    MeasurementSnapshot s,
    Map<String, String> labels,
  ) {
    final circonferenze = <String>[];
    final pliche = <String>[];
    for (final entry in labels.entries) {
      final v = _misurazioneValue(s, entry.key);
      if (v == null) continue;
      final isMm = entry.key.endsWith('Mm');
      final text = '${entry.value} ${v.toStringAsFixed(1)}${isMm ? 'mm' : 'cm'}';
      (isMm ? pliche : circonferenze).add(text);
    }
    return [
      date,
      circonferenze.isEmpty ? '-' : circonferenze.join(' · '),
      pliche.isEmpty ? '-' : pliche.join(' · '),
    ];
  }

  static double? _misurazioneValue(MeasurementSnapshot s, String key) {
    switch (key) {
      case 'vitaCm':           return s.vitaCm;
      case 'fianchiCm':        return s.fianchiCm;
      case 'braccioCm':        return s.braccioCm;
      case 'colloCm':          return s.colloCm;
      case 'cosciaCm':         return s.cosciaCm;
      case 'polpaccioCm':      return s.polpaccioCm;
      case 'toraceCm':         return s.toraceCm;
      case 'spalleCm':         return s.spalleCm;
      case 'tricipiteMm':      return s.tricipiteMm;
      case 'bicipiteMm':       return s.bicipiteMm;
      case 'sottoscapolareMm': return s.sottoscapolareMm;
      case 'sovrailiachMm':    return s.sovrailiachMm;
      case 'addomineMm':       return s.addomineMm;
      case 'cosciaMm':         return s.cosciaMm;
      default:                 return null;
    }
  }

  static String _workoutExerciseDetail(WorkoutExercise e, String minutiSuffix) {
    if (e.isCardio) {
      return e.durationSeconds != null
          ? '${e.durationSeconds! ~/ 60} $minutiSuffix'
          : '-';
    }
    return e.sets.map((s) => '${s.reps ?? '-'}×${s.weightKg ?? '-'}kg').join(', ');
  }

  // ── Header generico documento (scheda/programma/storico) ───────

  static pw.Widget _buildDocHeader({
    required String docTitle,
    required String subtitle,
    required String? detail,
    required pw.Font font,
    required pw.Font bold,
    String? name,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('PLICO',
                style: pw.TextStyle(font: bold, fontSize: 16, color: PdfColors.black)),
            pw.Text(docTitle,
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey600)),
          ],
        ),
        if (name != null && name.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(name,
              style: pw.TextStyle(font: bold, fontSize: 13, color: PdfColors.black)),
        ],
        pw.SizedBox(height: 2),
        pw.Text(subtitle,
            style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.grey800)),
        if (detail != null)
          pw.Text(detail,
              style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
