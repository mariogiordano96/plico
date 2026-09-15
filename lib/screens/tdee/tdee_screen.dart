import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../models/user_profile.dart';
import '../../models/body_snapshot.dart';
import '../../models/plicometry_session.dart';
import '../../services/database_service.dart';
import '../../services/tdee_calibration_service.dart';

// ── Costanti attività ──────────────────────────────────────────

const _attivitaMultipli = [1.2, 1.375, 1.55, 1.725, 1.9];

List<String> _getAttivitaLabels(BuildContext context) => [
  context.l10n.tdeeAttSedentario,
  context.l10n.tdeeAttLegg,
  context.l10n.tdeeAttMod,
  context.l10n.tdeeAttMolto,
  context.l10n.tdeeAttAtleta,
];

List<String> _getAttivitaDescrizioni(BuildContext context) => [
  context.l10n.tdeeAttSedentarioDesc,
  context.l10n.tdeeAttLeggDesc,
  context.l10n.tdeeAttModDesc,
  context.l10n.tdeeAttMoltoDesc,
  context.l10n.tdeeAttAtletaDesc,
];

// ── Metodi di calcolo ──────────────────────────────────────────

class _Metodo {
  final int id;
  final String nome;
  final String descrizione;
  final bool richiedeLbm;
  const _Metodo(this.id, this.nome, this.descrizione,
      {this.richiedeLbm = false});
}

const _metodi = [
  _Metodo(0, '', '', ),
  _Metodo(1, 'Katch-McArdle', '', richiedeLbm: true),
  _Metodo(2, 'Mifflin-St Jeor', ''),
  _Metodo(3, 'Harris-Benedict', ''),
];

String _metodoNome(int id, BuildContext context) => switch (id) {
  0 => context.l10n.tdeeMetodoAutomaticoNome,
  1 => 'Katch-McArdle',
  2 => 'Mifflin-St Jeor',
  _ => 'Harris-Benedict',
};

String _metodoDesc(int id, BuildContext context) => switch (id) {
  0 => context.l10n.tdeeMetodoAutomaticoDesc,
  1 => context.l10n.tdeeMetodoKatchDesc,
  2 => context.l10n.tdeeMetodoMifflinDesc,
  _ => context.l10n.tdeeMetodoHarrisDesc,
};

// ── Calcolo TDEE ────────────────────────────────────────────────

class TdeeResult {
  final int bmr;
  final int tdee;
  final String nomeFormula;

  const TdeeResult(
      {required this.bmr, required this.tdee, required this.nomeFormula});
}

TdeeResult? calcolaTdee({
  required Sesso sesso,
  required int eta,
  required double altezzaCm,
  required double pesoKg,
  required int livello,
  required int metodo,
  double? massaMagraKg,
}) {
  if (pesoKg <= 0 || altezzaCm <= 0 || eta <= 0) return null;

  final double bmr;
  final String formula;

  final int metodoEffettivo;
  if (metodo == 0) {
    metodoEffettivo =
        (massaMagraKg != null && massaMagraKg > 0) ? 1 : 2;
  } else {
    metodoEffettivo = metodo;
  }

  switch (metodoEffettivo) {
    case 1:
      if (massaMagraKg == null || massaMagraKg <= 0) return null;
      bmr = 370 + 21.6 * massaMagraKg;
      formula = 'Katch-McArdle';
    case 2:
      bmr = sesso == Sesso.maschio
          ? 10 * pesoKg + 6.25 * altezzaCm - 5 * eta + 5
          : 10 * pesoKg + 6.25 * altezzaCm - 5 * eta - 161;
      formula = 'Mifflin-St Jeor';
    case 3:
      bmr = sesso == Sesso.maschio
          ? 88.362 + 13.397 * pesoKg + 4.799 * altezzaCm - 5.677 * eta
          : 447.593 + 9.247 * pesoKg + 3.098 * altezzaCm - 4.330 * eta;
      formula = 'Harris-Benedict';
    default:
      return null;
  }

  final mult = _attivitaMultipli[livello.clamp(0, 4)];
  return TdeeResult(
    bmr: bmr.round(),
    tdee: (bmr * mult).round(),
    nomeFormula: formula,
  );
}

// ── Calcolo macro ───────────────────────────────────────────────

const _proteinMatrix = [
  [1.4, 1.8, 2.3, 2.6, 3.1],
  [0.8, 1.2, 1.4, 1.8, 2.0],
  [0.8, 1.2, 1.6, 1.8, 2.0],
];

class _MacroResult {
  final int proteinG;
  final int fatG;
  final int carbsG;
  final double proteinPct;
  final double fatPct;
  final double carbsPct;
  const _MacroResult({
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.proteinPct,
    required this.fatPct,
    required this.carbsPct,
  });
}

_MacroResult _calcolaMacro(int kcal, double pesoKg, int goal, int livello) {
  final proteinGPerKg = _proteinMatrix[goal.clamp(0, 2)][livello.clamp(0, 4)];
  final proteinG = (pesoKg * proteinGPerKg).round();
  final proteinKcal = proteinG * 4;

  final fatGFromPct = (kcal * 0.25 / 9).round();
  final fatGFromKg = (pesoKg * 0.8).round();
  final fatG = fatGFromPct > fatGFromKg ? fatGFromPct : fatGFromKg;
  final fatKcal = fatG * 9;

  final remaining = kcal - proteinKcal - fatKcal;
  final carbsG = remaining > 0 ? (remaining / 4).round() : 0;
  final carbsKcal = carbsG * 4;

  final total = (proteinKcal + fatKcal + carbsKcal).toDouble();
  return _MacroResult(
    proteinG: proteinG,
    fatG: fatG,
    carbsG: carbsG,
    proteinPct: total > 0 ? proteinKcal / total * 100 : 0,
    fatPct: total > 0 ? fatKcal / total * 100 : 0,
    carbsPct: total > 0 ? carbsKcal / total * 100 : 0,
  );
}

int _goalKcal(int tdee, int g) => switch (g) {
      0 => (tdee * 0.80).round(),
      2 => (tdee * 1.15).round(),
      _ => tdee,
    };

// ── Tab (incorporata nella tab TDEE dentro DiarioScreen) ─────────

class TdeeTab extends StatefulWidget {
  const TdeeTab({super.key});

  @override
  State<TdeeTab> createState() => _TdeeTabState();
}

class _TdeeTabState extends State<TdeeTab> {
  UserProfile? _profile;
  BodySnapshot? _snapshot;
  PlicometrySession? _session;

  // Stato locale del wizard (non salvato finché non si preme "Attiva Piano")
  int _livello = 2;
  int _metodo = 0;
  int _goal = 1;
  final _pesoObiettivoCtrl = TextEditingController();

  DateTime? _goalSetDate;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pesoObiettivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final session = await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    final goal = await DatabaseService.instance.getObiettivo();
    final goalSetDate = await DatabaseService.instance.getGoalSetDate();
    final settings = await DatabaseService.instance.getAppSettings();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _snapshot = snapshot;
      _session = session;
      _livello = livello;
      _metodo = metodo;
      _goal = goal;
      _goalSetDate = goalSetDate;
      _loading = false;
      if (settings.pesoObiettivo != null) {
        _pesoObiettivoCtrl.text = settings.pesoObiettivo!.toStringAsFixed(1);
      }
    });
  }

  TdeeResult? get _result {
    if (_profile == null || _snapshot == null) return null;
    return calcolaTdee(
      sesso: _profile!.sesso,
      eta: _profile!.etaCorrente,
      altezzaCm: _profile!.altezzaCm,
      pesoKg: _snapshot!.pesoKg,
      livello: _livello,
      metodo: _metodo,
      massaMagraKg: _session?.risultati.massaMagraKg,
    );
  }

  bool get _hasLbm =>
      _session != null && (_session!.risultati.massaMagraKg) > 0;

  bool get _pianAttivo => _goalSetDate != null;

  int get _giorniDallaAttivazione {
    if (_goalSetDate == null) return 0;
    return DateTime.now().difference(_goalSetDate!).inDays;
  }

  Future<void> _attivaePiano() async {
    if (_saving) return;
    setState(() => _saving = true);
    await DatabaseService.instance.activateGoal(
      livello: _livello,
      metodo: _metodo,
      obiettivo: _goal,
      pesoObiettivo: _goal == 1
          ? null
          : double.tryParse(_pesoObiettivoCtrl.text.replaceAll(',', '.')),
    );
    await _load();
    setState(() => _saving = false);
  }

  Future<void> _ricalcola() async {
    final giorni = _giorniDallaAttivazione;
    if (giorni < 30) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final p = ctx.palette;
          return AlertDialog(
            backgroundColor: p.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(ctx.l10n.tdeeRicalcolaObiettivo,
                style: TextStyle(color: p.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            content: Text(
              ctx.l10n.tdeeRicalcolaBody(giorni),
              style: TextStyle(color: p.textSecondary, fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(ctx.l10n.diarioAnnulla,
                    style: TextStyle(color: p.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ctx.l10n.tdeeRicalcolaBtn,
                    style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      );
      if (confirm != true) return;
    }
    await DatabaseService.instance.resetGoal();
    await _load();
  }

  String _formatDate(DateTime d) =>
      DateFormat('d MMM y', Localizations.localeOf(context).toString()).format(d);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return _loading
        ? Center(child: CircularProgressIndicator(color: p.accent))
        : _pianAttivo
            ? _buildPianoAttivo(p)
            : _buildWizard(p);
  }

  // ── Stato A: wizard ────────────────────────────────────────────

  Widget _buildWizard(ColorPalette p) {
    final result = _result;
    final kcal = result != null ? _goalKcal(result.tdee, _goal) : null;
    final macro =
        (kcal != null && _snapshot != null)
            ? _calcolaMacro(kcal, _snapshot!.pesoKg, _goal, _livello)
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: p.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.tdeeIntroTesto,
                    style: TextStyle(color: p.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel(context.l10n.tdeeSezObiettivo, p),
          const SizedBox(height: 12),
          _ObiettivoSelector(
            selected: _goal,
            tdee: result?.tdee,
            onSelect: (v) => setState(() => _goal = v),
            p: p,
          ),
          if (_goal != 1) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _pesoObiettivoCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: p.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                labelText: context.l10n.tdeePesoObiettivo,
                labelStyle: TextStyle(color: p.textMuted, fontSize: 13),
                filled: true,
                fillColor: p.surface,
                suffixText: 'kg',
                suffixStyle: TextStyle(color: p.textMuted, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: p.accent),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          _SectionLabel(context.l10n.tdeeSezAttivita, p),
          const SizedBox(height: 12),
          _AttivitaSelector(
            selected: _livello,
            onSelect: (v) => setState(() => _livello = v),
            p: p,
          ),
          const SizedBox(height: 20),

          _SectionLabel(context.l10n.tdeeSezMetodo, p),
          const SizedBox(height: 12),
          _MetodoSelector(
            selected: _metodo,
            hasLbm: _hasLbm,
            onSelect: (v) => setState(() => _metodo = v),
            p: p,
          ),
          const SizedBox(height: 20),

          // Anteprima risultato
          if (result != null && macro != null) ...[
            _SectionLabel(context.l10n.tdeeSezAnteprima, p),
            const SizedBox(height: 12),
            _PreviewCard(
              result: result,
              kcal: kcal!,
              macro: macro,
              goal: _goal,
              livello: _livello,
              p: p,
            ),
            const SizedBox(height: 24),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: p.textMuted, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.tdeeNessunaPesata,
                      style: TextStyle(color: p.textMuted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (result == null || _saving) ? null : _attivaePiano,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.accent,
                disabledBackgroundColor: p.cardBorder,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : Text(context.l10n.tdeeAttivaPiano,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stato B: piano attivo ──────────────────────────────────────

  Widget _buildPianoAttivo(ColorPalette p) {
    final result = _result;
    final kcal = result != null ? _goalKcal(result.tdee, _goal) : null;
    final macro =
        (kcal != null && _snapshot != null)
            ? _calcolaMacro(kcal, _snapshot!.pesoKg, _goal, _livello)
            : null;
    final giorni = _giorniDallaAttivazione;
    final scaduto = giorni >= 30;

    final obiettivoLabel = [
      context.l10n.tdeeObjDeficitBadge,
      context.l10n.tdeeObjMantenimento,
      context.l10n.tdeeObjSurplusBadge,
    ][_goal.clamp(0, 2)];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner 30 giorni
          if (scaduto) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: p.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(context.l10n.tdeeSonoPassati(giorni),
                          style: TextStyle(
                              color: p.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.tdeeBannerSub,
                    style: TextStyle(
                        color: p.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _ricalcola,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(context.l10n.tdeeAggiornaPiano,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Calibrazione TDEE dinamica (solo suggerimento informativo)
          if (result != null)
            FutureBuilder<TdeeCalibrationResult?>(
              future:
                  TdeeCalibrationService.instance.suggestion(result.tdee),
              builder: (context, snap) {
                final cal = snap.data;
                if (cal == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.insights_rounded,
                            color: p.accent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n.tdeeCalibrazione(
                              '${cal.days}',
                              '${cal.suggestedTdee}',
                              '${cal.currentTdee}',
                            ),
                            style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Card piano attivo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.cardBorder),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.surface,
                  const Color(0xFFFF6B35).withValues(alpha: 0.05)
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C48C).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C48C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(context.l10n.tdeePianoAttivoLabel,
                              style: const TextStyle(
                                  color: Color(0xFF00C48C),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.tdeeAttivatoDal(_formatDate(_goalSetDate!)),
                      style: TextStyle(color: p.textMuted, fontSize: 12),
                    ),
                    if (!scaduto) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: context.l10n.tdeeRicalcolaObiettivo,
                        child: InkWell(
                          onTap: _ricalcola,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.refresh_rounded,
                                color: p.textMuted, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                if (result == null || kcal == null)
                  Text(context.l10n.tdeeDatiInsufficienti,
                      style: TextStyle(color: p.textMuted, fontSize: 14))
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: const Color(0xFFFF6B35), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '$kcal',
                        style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5, left: 4),
                        child: Text(context.l10n.tdeeKcalGiornoUnit,
                            style:
                                TextStyle(color: p.textMuted, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$obiettivoLabel  ·  ${_getAttivitaLabels(context)[_livello.clamp(0, 4)]}',
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],

                const SizedBox(height: 16),
                Divider(height: 1, color: p.cardBorder),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoPill(label: 'BMR', value: '${result?.bmr ?? '--'} kcal', p: p),
                    Container(width: 1, height: 32, color: p.cardBorder),
                    _InfoPill(label: 'Formula', value: result?.nomeFormula ?? '--', p: p),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Macro breakdown
          if (macro != null) ...[
            _SectionLabel(context.l10n.tdeeSezRipartizione, p),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.cardBorder),
              ),
              child: Column(
                children: [
                  _MacroRow(
                    label: context.l10n.progressiProteine,
                    grams: macro.proteinG,
                    pct: macro.proteinPct,
                    color: const Color(0xFF3B9FF2),
                    note:
                        '${_proteinMatrix[_goal.clamp(0, 2)][_livello.clamp(0, 4)]}g/kg · ISSN/ACSM',
                    p: p,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: p.cardBorder),
                  ),
                  _MacroRow(
                    label: context.l10n.progressiGrassi,
                    grams: macro.fatG,
                    pct: macro.fatPct,
                    color: const Color(0xFFFFB800),
                    note: 'min(25% kcal, 0.8g/kg)',
                    p: p,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: p.cardBorder),
                  ),
                  _MacroRow(
                    label: context.l10n.progressiCarboidrati,
                    grams: macro.carbsG,
                    pct: macro.carbsPct,
                    color: const Color(0xFF4CAF8E),
                    note: context.l10n.tdeeCarbsNote,
                    p: p,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ],
      ),
    );
  }
}

// ── Obiettivo selector (wizard) ────────────────────────────────

class _ObiettivoSelector extends StatelessWidget {
  final int selected;
  final int? tdee;
  final ValueChanged<int> onSelect;
  final ColorPalette p;
  const _ObiettivoSelector({
    required this.selected,
    required this.tdee,
    required this.onSelect,
    required this.p,
  });

  int _kcal(int tdee, int id) => switch (id) {
        0 => (tdee * 0.80).round(),
        2 => (tdee * 1.15).round(),
        _ => tdee,
      };

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: context.l10n.tdeeObjDeficit, sub: '−20%', color: const Color(0xFF3B9FF2), id: 0),
      (label: context.l10n.tdeeObjMantenimento, sub: 'TDEE', color: const Color(0xFF00C48C), id: 1),
      (label: context.l10n.tdeeObjSurplus, sub: '+15%', color: const Color(0xFFFF8C42), id: 2),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = selected == item.id;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                    left: item.id == 0 ? 0 : 6,
                    right: item.id == 2 ? 0 : 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: item.color.withValues(alpha: 0.4))
                      : null,
                ),
                child: Column(
                  children: [
                    Text(item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isSelected ? item.color : p.textMuted,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500)),
                    const SizedBox(height: 4),
                    if (tdee != null)
                      Text('${_kcal(tdee!, item.id)} kcal',
                          style: TextStyle(
                              color: isSelected ? item.color : p.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800))
                    else
                      Text(item.sub,
                          style: TextStyle(
                              color: isSelected ? item.color : p.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Preview card (wizard) ──────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final TdeeResult result;
  final int kcal;
  final _MacroResult macro;
  final int goal;
  final int livello;
  final ColorPalette p;
  const _PreviewCard({
    required this.result,
    required this.kcal,
    required this.macro,
    required this.goal,
    required this.livello,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6B35), size: 22),
              const SizedBox(width: 6),
              Text('$kcal',
                  style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(context.l10n.tdeeKcalGiornoUnit,
                    style: TextStyle(color: p.textMuted, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(
                  label: 'P',
                  grams: macro.proteinG,
                  color: const Color(0xFF3B9FF2)),
              _MacroChip(
                  label: 'G',
                  grams: macro.fatG,
                  color: const Color(0xFFFFB800)),
              _MacroChip(
                  label: 'C',
                  grams: macro.carbsG,
                  color: const Color(0xFF4CAF8E)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.tdeePreviewFormula(result.nomeFormula, '${result.tdee}'),
            style: TextStyle(color: p.textMuted, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int grams;
  final Color color;
  const _MacroChip(
      {required this.label, required this.grams, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${grams}g',
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }
}

// ── Metodo selector ────────────────────────────────────────────

class _MetodoSelector extends StatelessWidget {
  final int selected;
  final bool hasLbm;
  final ValueChanged<int> onSelect;
  final ColorPalette p;
  const _MetodoSelector(
      {required this.selected,
      required this.hasLbm,
      required this.onSelect,
      required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: List.generate(_metodi.length, (i) {
          final m = _metodi[i];
          final isSelected = selected == m.id;
          final disabled = m.richiedeLbm && !hasLbm;
          final isLast = i == _metodi.length - 1;

          return GestureDetector(
            onTap: disabled ? null : () => onSelect(m.id),
            child: Opacity(
              opacity: disabled ? 0.4 : 1.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.08)
                      : Colors.transparent,
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: p.cardBorder)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF6B35)
                                  : p.cardBorder,
                              width: isSelected ? 5 : 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_metodoNome(m.id, context),
                                  style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFF6B35)
                                          : p.textPrimary,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500)),
                              if (m.richiedeLbm && !hasLbm) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.cardBorder,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(context.l10n.tdeeRichiedePlic,
                                      style: TextStyle(
                                          color: p.textMuted, fontSize: 10)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(_metodoDesc(m.id, context),
                              style:
                                  TextStyle(color: p.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Attività selector ──────────────────────────────────────────

class _AttivitaSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final ColorPalette p;
  const _AttivitaSelector(
      {required this.selected, required this.onSelect, required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: List.generate(5, (i) {
          final labels = _getAttivitaLabels(context);
          final descrizioni = _getAttivitaDescrizioni(context);
          final isSelected = selected == i;
          final isLast = i == 4;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35).withValues(alpha: 0.08)
                    : Colors.transparent,
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: p.cardBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF6B35)
                              : p.cardBorder,
                          width: isSelected ? 5 : 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels[i],
                            style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF6B35)
                                    : p.textPrimary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                        Text(descrizioni[i],
                            style:
                                TextStyle(color: p.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    '×${_attivitaMultipli[i]}',
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFFF6B35)
                            : p.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

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

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final ColorPalette p;
  const _InfoPill(
      {required this.label, required this.value, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: p.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: p.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final int grams;
  final double pct;
  final Color color;
  final String note;
  final ColorPalette p;
  const _MacroRow({
    required this.label,
    required this.grams,
    required this.pct,
    required this.color,
    required this.note,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(note,
                    style: TextStyle(color: p.textMuted, fontSize: 11)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${grams}g',
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Text('${pct.round()}%',
                    style: TextStyle(color: p.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
