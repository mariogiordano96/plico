import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/daily_log.dart';
import '../models/meal_entry.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../models/body_snapshot.dart';
import '../services/database_service.dart';
import '../screens/tdee/tdee_screen.dart' show calcolaTdee;

const _weekdays = [
  'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
  'Venerdì', 'Sabato', 'Domenica'
];
const _months = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre'
];
const _pastoLabels = [
  'Colazione', 'Pranzo', 'Cena', 'Spuntino', 'Post-WO', 'Spuntino serale'
];
const _goalMult = [0.80, 1.0, 1.15];

class PdfExportService {
  PdfExportService._();

  /// Genera il PDF del diario dal [from] al [to] e restituisce i byte.
  static Future<Uint8List> generateDiario({
    required DateTime from,
    required DateTime to,
  }) async {
    final db = DatabaseService.instance;

    // ── Dati utente ──────────────────────────────────────────────
    final profile = await db.getUserProfile();
    final snapshot = await db.getLatestBodySnapshot();
    final session = await db.getLatestPlicometrySession();
    final livello = await db.getLivelloAttivita();
    final metodo = await db.getMetodoTdee();
    final obiettivo = await db.getObiettivo();
    final logs = await db.getDailyLogsRange(from, to);

    // ── Target ───────────────────────────────────────────────────
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

    // ── Font ─────────────────────────────────────────────────────
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
    final targetStr = kcalTarget != null ? '$kcalTarget kcal/giorno' : '';

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
        ),
        footer: (ctx) => _buildFooter(ctx, font),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          ...days.map((d) => _buildDaySection(
                date: d,
                log: logMap[d],
                kcalTarget: kcalTarget,
                font: font,
                bold: bold,
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
  }) {
    final period = from.month == to.month && from.year == to.year
        ? '${from.day}–${to.day} ${_months[from.month - 1]} ${from.year}'
        : '${_fmtDate(from)} – ${_fmtDate(to)}';

    final subtitles = [
      if (userName.isNotEmpty) userName,
      if (pesoStr.isNotEmpty) pesoStr,
      if (targetStr.isNotEmpty) 'target $targetStr',
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
            pw.Text('Diario Alimentare',
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

  static pw.Widget _buildFooter(pw.Context ctx, pw.Font font) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'pagina ${ctx.pageNumber} di ${ctx.pagesCount}',
        style:
            pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey500),
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
  }) {
    final dayLabel =
        '${_weekdays[date.weekday - 1].toUpperCase()}  ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    final hasEntries = log != null && log.entries.isNotEmpty;
    final totalKcal = log?.kcalTotali ?? 0.0;
    final totalProt = log?.proteinTotali ?? 0.0;
    final totalFat = log?.fatTotali ?? 0.0;
    final totalCarbs = log?.carbsTotali ?? 0.0;
    final pct = (kcalTarget != null && kcalTarget > 0)
        ? (totalKcal / kcalTarget * 100).round()
        : null;

    // Raggruppa per tipo pasto
    final byMeal = <int, List<MealEntry>>{};
    for (final e in log?.entries ?? <MealEntry>[]) {
      byMeal.putIfAbsent(e.pastoTipo, () => []).add(e);
    }
    final mealOrder = byMeal.keys.toList()..sort();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Day header ─────────────────────────────────
        pw.Container(
          color: PdfColors.grey100,
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
        // ── Contenuto ─────────────────────────────────
        if (!hasEntries)
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(6, 4, 0, 6),
            child: pw.Text('Nessun dato registrato',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500)),
          )
        else ...[
          pw.SizedBox(height: 4),
          ...mealOrder.map((tipo) {
            final label = tipo < _pastoLabels.length
                ? _pastoLabels[tipo]
                : 'Pasto';
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
                      padding:
                          const pw.EdgeInsets.fromLTRB(14, 1, 6, 1),
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
        pw.Text('RIEPILOGO',
            style: pw.TextStyle(
                font: bold, fontSize: 10, color: PdfColors.grey900)),
        pw.SizedBox(height: 5),
        pw.Text(
          'Giorni con dati: ${withData.length}/$days',
          style:
              pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
        ),
        if (kcalTarget != null)
          pw.Text(
            'Giorni on-target (90–105%): $onTarget/${withData.length}',
            style: pw.TextStyle(
                font: font, fontSize: 9, color: PdfColors.grey700),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Media giornaliera: ${avgKcal.round()} kcal  ·  P ${avgProt.round()}g  ·  G ${avgFat.round()}g  ·  C ${avgCarbs.round()}g',
          style:
              pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
        ),
        if (kcalTarget != null || protTarget != null || fatTarget != null)
          pw.Text(
            'Target: '
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

  static const _pianoMealLabels = [
    'Colazione', 'Pranzo', 'Cena', 'Spuntino', 'Post-WO', 'Spuntino serale'
  ];
  static const _pianoSlotLabels = [
    'Proteina', 'Carboidrati', 'Verdura', 'Grassi', 'Extra', 'Frutta'
  ];

  static Future<Uint8List> generatePiano(MealPlan plan) async {
    final db = DatabaseService.instance;
    final profile = await db.getUserProfile();
    final font = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    final userName = profile != null
        ? '${profile.nome} ${profile.cognome}'.trim()
        : '';
    final created =
        '${plan.dataCreazione.day.toString().padLeft(2, '0')}/'
        '${plan.dataCreazione.month.toString().padLeft(2, '0')}/'
        '${plan.dataCreazione.year}';

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
        ),
        footer: (ctx) => _buildFooter(ctx, font),
        build: (_) => [
          pw.SizedBox(height: 12),
          ...plan.pasti.map((meal) => _buildPianoMeal(meal, font, bold)),
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
  }) {
    final macro =
        '${plan.kcalTotali.round()} kcal  ·  '
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
                style: pw.TextStyle(font: bold, fontSize: 16, color: PdfColors.black)),
            pw.Text('Piano Alimentare',
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey600)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text('Generato il $created${userName.isNotEmpty ? '  ·  $userName' : ''}',
            style: pw.TextStyle(font: bold, fontSize: 11, color: PdfColors.grey800)),
        pw.Text(macro,
            style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
      ],
    );
  }

  static pw.Widget _buildPianoMeal(PlanMeal meal, pw.Font font, pw.Font bold) {
    final label = meal.tipo < _pianoMealLabels.length
        ? _pianoMealLabels[meal.tipo]
        : 'Pasto';
    final validSlots = meal.slots.where((s) => s.principale != null).toList();
    if (validSlots.isEmpty) return pw.SizedBox();

    final mealKcal = validSlots.fold(
        0.0, (s, slot) => s + (slot.principale?.kcal ?? 0));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Meal header
        pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label.toUpperCase(),
                  style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.grey900)),
              pw.Text('${mealKcal.round()} kcal',
                  style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        // Slots
        ...validSlots.map((slot) {
          final slotLabel = slot.tipo < _pianoSlotLabels.length
              ? _pianoSlotLabels[slot.tipo]
              : '';
          final f = slot.principale!;
          final alts = slot.alternative
              .where((a) => a.nome.isNotEmpty)
              .toList();
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
                              font: bold, fontSize: 8, color: PdfColors.grey500)),
                    ),
                    pw.Expanded(
                      child: pw.Text(f.nome,
                          style: pw.TextStyle(
                              font: bold, fontSize: 9, color: PdfColors.grey900),
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('${f.quantitaG.round()}g',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
                    pw.SizedBox(width: 6),
                    pw.Text('${f.kcal.round()} kcal',
                        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700)),
                    pw.SizedBox(width: 6),
                    pw.Text(
                        'P${f.proteine.round()} G${f.grassi.round()} C${f.carboidrati.round()}',
                        style: pw.TextStyle(font: font, fontSize: 7.5, color: PdfColors.grey500)),
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

  // ── Helpers ────────────────────────────────────────────────────

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _fmtDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}
