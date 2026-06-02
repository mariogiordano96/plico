import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../models/user_profile.dart';
import '../../models/body_snapshot.dart';
import '../../models/plicometry_session.dart';
import '../../services/database_service.dart';

// ── Costanti attività ──────────────────────────────────────────

const _attivitaLabels = [
  'Sedentario',
  'Legg. attivo',
  'Mod. attivo',
  'Molto attivo',
  'Atleta',
];
const _attivitaDescrizioni = [
  'Lavoro sedentario, poco o nessun esercizio',
  'Esercizio leggero 1–3 giorni/settimana',
  'Esercizio moderato 3–5 giorni/settimana',
  'Esercizio intenso 6–7 giorni/settimana',
  'Lavoro fisico intenso o doppio allenamento',
];
const _attivitaMultipli = [1.2, 1.375, 1.55, 1.725, 1.9];

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
  _Metodo(0, 'Automatico',
      'Usa la formula più precisa disponibile: Katch-McArdle se hai una plicometria, altrimenti Mifflin-St Jeor.'),
  _Metodo(1, 'Katch-McArdle',
      'BMR = 370 + 21,6 × massa magra. La più precisa: considera solo la massa metabolicamente attiva.',
      richiedeLbm: true),
  _Metodo(2, 'Mifflin-St Jeor',
      'Formula raccomandata dall\'American Dietetic Association. Accurata per la maggior parte delle persone.'),
  _Metodo(3, 'Harris-Benedict',
      'Formula classica revisionata (Roza & Shizgal, 1984). Tende a sovrastimare leggermente.'),
];

// ── Calcolo ─────────────────────────────────────────────────────

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

  // Risolvi "auto"
  final int metodoEffettivo;
  if (metodo == 0) {
    metodoEffettivo =
        (massaMagraKg != null && massaMagraKg > 0) ? 1 : 2;
  } else {
    metodoEffettivo = metodo;
  }

  switch (metodoEffettivo) {
    case 1: // Katch-McArdle
      if (massaMagraKg == null || massaMagraKg <= 0) return null;
      bmr = 370 + 21.6 * massaMagraKg;
      formula = 'Katch-McArdle';
    case 2: // Mifflin-St Jeor
      bmr = sesso == Sesso.maschio
          ? 10 * pesoKg + 6.25 * altezzaCm - 5 * eta + 5
          : 10 * pesoKg + 6.25 * altezzaCm - 5 * eta - 161;
      formula = 'Mifflin-St Jeor';
    case 3: // Harris-Benedict (Roza & Shizgal 1984)
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

// ── Screen ──────────────────────────────────────────────────────

class TdeeScreen extends StatefulWidget {
  const TdeeScreen({super.key});

  @override
  State<TdeeScreen> createState() => _TdeeScreenState();
}

class _TdeeScreenState extends State<TdeeScreen> {
  UserProfile? _profile;
  BodySnapshot? _snapshot;
  PlicometrySession? _session;
  int _livello = 2;
  int _metodo = 0;
  int _goal = 1; // 0=deficit 1=mantenimento 2=surplus
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final snapshot = await DatabaseService.instance.getLatestBodySnapshot();
    final session =
        await DatabaseService.instance.getLatestPlicometrySession();
    final livello = await DatabaseService.instance.getLivelloAttivita();
    final metodo = await DatabaseService.instance.getMetodoTdee();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _snapshot = snapshot;
      _session = session;
      _livello = livello;
      _metodo = metodo;
      _loading = false;
    });
  }

  Future<void> _setLivello(int v) async {
    setState(() => _livello = v);
    await DatabaseService.instance.saveLivelloAttivita(v);
  }

  Future<void> _setMetodo(int v) async {
    setState(() => _metodo = v);
    await DatabaseService.instance.saveMetodoTdee(v);
  }

  TdeeResult? get _result {
    if (_loading || _profile == null || _snapshot == null) return null;
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

  int _goalKcal(int tdee, int g) => switch (g) {
        0 => (tdee * 0.80).round(),
        2 => (tdee * 1.15).round(),
        _ => tdee,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: Text('TDEE',
            style: TextStyle(
                color: p.accent,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      backgroundColor: p.background,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MainCard(result: result, livello: _livello, p: p),
                  const SizedBox(height: 20),

                  _SectionLabel('METODO DI CALCOLO', p),
                  const SizedBox(height: 12),
                  _MetodoSelector(
                    selected: _metodo,
                    hasLbm: _hasLbm,
                    onSelect: _setMetodo,
                    p: p,
                  ),
                  const SizedBox(height: 20),

                  _SectionLabel('LIVELLO DI ATTIVITÀ', p),
                  const SizedBox(height: 12),
                  _AttivitaSelector(
                      selected: _livello,
                      onSelect: _setLivello,
                      p: p),
                  const SizedBox(height: 20),

                  if (result != null) ...[
                    _SectionLabel('OBIETTIVI CALORICI', p),
                    const SizedBox(height: 12),
                    _ObiettiviCard(
                      tdee: result.tdee,
                      selectedGoal: _goal,
                      onSelectGoal: (g) => setState(() => _goal = g),
                      p: p,
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('RIPARTIZIONE MACRO', p),
                    const SizedBox(height: 12),
                    _MacroCard(
                      kcal: _goalKcal(result.tdee, _goal),
                      pesoKg: _snapshot!.pesoKg,
                      goal: _goal,
                      livello: _livello,
                      p: p,
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
    );
  }
}

// ── Main card ──────────────────────────────────────────────────

class _MainCard extends StatelessWidget {
  final TdeeResult? result;
  final int livello;
  final ColorPalette p;
  const _MainCard(
      {required this.result, required this.livello, required this.p});

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.surface, const Color(0xFFFF6B35).withValues(alpha: 0.05)],
        ),
      ),
      child: result == null
          ? Column(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: p.textMuted, size: 40),
                const SizedBox(height: 12),
                Text('Dati insufficienti',
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    'Registra una pesata per calcolare il TDEE.\n'
                    'Per Katch-McArdle è necessaria anche una plicometria.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: p.textMuted, fontSize: 13)),
              ],
            )
          : Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Color(0xFFFF6B35), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      _fmt(result!.tdee),
                      style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                      child: Text('kcal/giorno',
                          style:
                              TextStyle(color: p.textMuted, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_attivitaLabels[livello.clamp(0, 4)],
                    style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Container(height: 1, color: p.cardBorder),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoPill(
                        label: 'BMR',
                        value: '${_fmt(result!.bmr)} kcal',
                        p: p),
                    Container(width: 1, height: 32, color: p.cardBorder),
                    _InfoPill(
                        label: 'Formula',
                        value: result!.nomeFormula,
                        p: p),
                  ],
                ),
              ],
            ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.08)
                      : Colors.transparent,
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(color: p.cardBorder)),
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
                              Text(m.nome,
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
                                  child: Text('richiede plicometria',
                                      style: TextStyle(
                                          color: p.textMuted,
                                          fontSize: 10)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(m.descrizione,
                              style: TextStyle(
                                  color: p.textMuted, fontSize: 12)),
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
      {required this.selected,
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
        children: List.generate(_attivitaLabels.length, (i) {
          final isSelected = selected == i;
          final isLast = i == _attivitaLabels.length - 1;
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
                    : Border(
                        bottom: BorderSide(color: p.cardBorder)),
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
                        Text(_attivitaLabels[i],
                            style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFF6B35)
                                    : p.textPrimary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                        Text(_attivitaDescrizioni[i],
                            style: TextStyle(
                                color: p.textMuted, fontSize: 12)),
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

// ── Obiettivi calorici ─────────────────────────────────────────

class _ObiettiviCard extends StatelessWidget {
  final int tdee;
  final int selectedGoal;
  final ValueChanged<int> onSelectGoal;
  final ColorPalette p;
  const _ObiettiviCard({
    required this.tdee,
    required this.selectedGoal,
    required this.onSelectGoal,
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectGoal(0),
              child: _ObiettivoCol(
                label: 'Deficit',
                sub: '−20%',
                kcal: (tdee * 0.80).round(),
                color: const Color(0xFF3B9FF2),
                isSelected: selectedGoal == 0,
                p: p,
              ),
            ),
          ),
          Container(width: 1, height: 52, color: p.cardBorder),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectGoal(1),
              child: _ObiettivoCol(
                label: 'Mantenimento',
                sub: 'TDEE',
                kcal: tdee,
                color: p.accent,
                isSelected: selectedGoal == 1,
                p: p,
              ),
            ),
          ),
          Container(width: 1, height: 52, color: p.cardBorder),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelectGoal(2),
              child: _ObiettivoCol(
                label: 'Surplus',
                sub: '+15%',
                kcal: (tdee * 1.15).round(),
                color: const Color(0xFFFF8C42),
                isSelected: selectedGoal == 2,
                p: p,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObiettivoCol extends StatelessWidget {
  final String label;
  final String sub;
  final int kcal;
  final Color color;
  final bool isSelected;
  final ColorPalette p;
  const _ObiettivoCol({
    required this.label,
    required this.sub,
    required this.kcal,
    required this.color,
    required this.isSelected,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: isSelected ? color : p.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('$kcal',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(sub, style: TextStyle(color: p.textMuted, fontSize: 11)),
        ],
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

// ── Macro ──────────────────────────────────────────────────────

// Fonte: ISSN 2017 + ACSM/AND/DC — g/kg per [goal][livello]
// goal: 0=deficit 1=mantenimento 2=surplus | livello: 0=sed. … 4=atleta
const _proteinMatrix = [
  [1.4, 1.8, 2.3, 2.6, 3.1], // deficit
  [0.8, 1.2, 1.4, 1.8, 2.0], // mantenimento
  [0.8, 1.2, 1.6, 1.8, 2.0], // surplus
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

  // Grassi: floor massimo tra 25% delle kcal target e 0.8g/kg
  final fatGFromPct = (kcal * 0.25 / 9).round();
  final fatGFromKg = (pesoKg * 0.8).round();
  final fatG = fatGFromPct > fatGFromKg ? fatGFromPct : fatGFromKg;
  final fatKcal = fatG * 9;

  // Carboidrati: calorie rimanenti
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

class _MacroCard extends StatelessWidget {
  final int kcal;
  final double pesoKg;
  final int goal;
  final int livello;
  final ColorPalette p;
  const _MacroCard({
    required this.kcal,
    required this.pesoKg,
    required this.goal,
    required this.livello,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final gPerKg = _proteinMatrix[goal.clamp(0, 2)][livello.clamp(0, 4)];
    final m = _calcolaMacro(kcal, pesoKg, goal, livello);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        children: [
          _MacroRow(
            label: 'Proteine',
            grams: m.proteinG,
            pct: m.proteinPct,
            color: const Color(0xFF3B9FF2),
            note: '${gPerKg}g/kg · ISSN/ACSM',
            p: p,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: p.cardBorder),
          ),
          _MacroRow(
            label: 'Grassi',
            grams: m.fatG,
            pct: m.fatPct,
            color: const Color(0xFFFFB800),
            note: 'min(25% kcal, 0.8g/kg)',
            p: p,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: p.cardBorder),
          ),
          _MacroRow(
            label: 'Carboidrati',
            grams: m.carbsG,
            pct: m.carbsPct,
            color: const Color(0xFF4CAF8E),
            note: 'calorie rimanenti',
            p: p,
          ),
        ],
      ),
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
