import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../models/body_snapshot.dart';
import '../models/workout_template.dart';
import '../models/workout_template_exercise.dart';
import '../models/workout_program.dart';
import '../models/workout_exercise.dart';
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
  final String Function(int page, int total) footerPage;
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

  const PdfStrings({
    required this.diarioTitle,
    required this.targetLabel,
    required this.kcalGiornoUnit,
    required this.footerPage,
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
          [0.8, 1.2, 1.6, 1.8, 2.0],
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
        footer: (ctx) => _buildFooter(ctx, font, strings),
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

  // ── Footer pagina ──────────────────────────────────────────────

  static pw.Widget _buildFooter(
      pw.Context ctx, pw.Font font, PdfStrings strings) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        strings.footerPage(ctx.pageNumber, ctx.pagesCount),
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
      ),
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
        footer: (ctx) => _buildFooter(ctx, font, strings),
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
        footer: (ctx) => _buildFooter(ctx, font, strings),
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
        footer: (ctx) => _buildFooter(ctx, font, strings),
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

  static pw.Widget _buildSchedaEsercizi(
    List<WorkoutTemplateExercise> esercizi,
    pw.Font font,
    pw.Font bold,
    PdfStrings strings,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: esercizi.map((e) {
        final target = e.targetDurationSeconds != null
            ? strings.durataMin(e.targetDurationSeconds! ~/ 60)
            : '${e.targetSets ?? '-'}×${e.targetReps ?? '-'}'
                '${e.targetWeightKg != null ? ' · ${e.targetWeightKg}kg' : ''}';
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(e.exerciseName,
                    style: pw.TextStyle(
                        font: font, fontSize: 9.5, color: PdfColors.grey900)),
              ),
              pw.Text(target,
                  style: pw.TextStyle(
                      font: bold, fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        );
      }).toList(),
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
        footer: (ctx) => _buildFooter(ctx, font, strings),
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

  static pw.Widget _buildStoricoRow({
    required WorkoutExercise session,
    required bool isPr,
    required DateFormat dateFmt,
    required pw.Font font,
    required pw.Font bold,
    required PdfStrings strings,
  }) {
    final isCardio = session.durationSeconds != null;
    final detail = isCardio
        ? strings.durataMin(session.durationSeconds! ~/ 60)
        : session.sets.map((s) => '${s.reps ?? '-'}×${s.weightKg ?? '-'}kg').join(', ');

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

  // ── Header generico documento (scheda/programma/storico) ───────

  static pw.Widget _buildDocHeader({
    required String docTitle,
    required String subtitle,
    required String? detail,
    required pw.Font font,
    required pw.Font bold,
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
