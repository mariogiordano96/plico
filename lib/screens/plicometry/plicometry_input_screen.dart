import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../models/plicometry_session.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../services/plicometry_calculator.dart';
import '../../widgets/measurement_guide.dart';
import 'plicometry_result_screen.dart';

// ──────────────────────────────────────────────
// Field metadata
// ──────────────────────────────────────────────

class _FieldSpec {
  final String label;
  final String unit;
  final String? guideKey;
  const _FieldSpec(this.label, this.unit, [this.guideKey]);
}

const _plicaSpecs = <String, _FieldSpec>{
  'bicipite':       _FieldSpec('Bicipite', 'mm', 'bicipite'),
  'tricipite':      _FieldSpec('Tricipite', 'mm', 'tricipite'),
  'pettorale':      _FieldSpec('Pettorale', 'mm', 'pettorale'),
  'ascellare':      _FieldSpec('Ascellare', 'mm', 'ascellare'),
  'sottoscapolare': _FieldSpec('Sottoscapolare', 'mm', 'sottoscapolare'),
  'sovrailiaca':    _FieldSpec('Sovrailiaca', 'mm', 'sovrailiaca'),
  'addome':         _FieldSpec('Addome', 'mm', 'addome'),
  'coscia':         _FieldSpec('Coscia', 'mm', 'coscia_plica'),
};

const _circSpecs = <String, _FieldSpec>{
  'collo':   _FieldSpec('Collo', 'cm', 'collo'),
  'vita':    _FieldSpec('Vita', 'cm', 'vita'),
  'fianchi': _FieldSpec('Fianchi', 'cm', 'fianchi'),
};

bool _isCircumference(MetodoPlicometria m) => m == MetodoPlicometria.usNavy;

List<String> _plicaKeys(MetodoPlicometria metodo, Sesso sesso) {
  switch (metodo) {
    case MetodoPlicometria.durninWomersley:
      return ['bicipite', 'tricipite', 'sottoscapolare', 'sovrailiaca'];
    case MetodoPlicometria.jacksonPollock3:
      return sesso == Sesso.maschio
          ? ['pettorale', 'addome', 'coscia']
          : ['tricipite', 'sovrailiaca', 'coscia'];
    case MetodoPlicometria.jacksonPollock7:
      return ['pettorale', 'tricipite', 'sottoscapolare', 'ascellare', 'sovrailiaca', 'addome', 'coscia'];
    case MetodoPlicometria.faulkner:
      return ['tricipite', 'sottoscapolare', 'sovrailiaca', 'addome'];
    case MetodoPlicometria.usNavy:
      return [];
  }
}

List<String> _circumKeys(MetodoPlicometria metodo, Sesso sesso) {
  switch (metodo) {
    case MetodoPlicometria.usNavy:
      return sesso == Sesso.maschio ? ['collo', 'vita'] : ['collo', 'vita', 'fianchi'];
    default:
      return [];
  }
}

String _methodTitle(MetodoPlicometria m) {
  switch (m) {
    case MetodoPlicometria.durninWomersley: return 'Durnin & Womersley';
    case MetodoPlicometria.jacksonPollock3: return 'Jackson & Pollock · 3';
    case MetodoPlicometria.jacksonPollock7: return 'Jackson & Pollock · 7';
    case MetodoPlicometria.faulkner:        return 'Faulkner';
    case MetodoPlicometria.usNavy:          return 'US Navy';
  }
}

// ──────────────────────────────────────────────
// Screen
// ──────────────────────────────────────────────

class PlicometryInputScreen extends StatefulWidget {
  final MetodoPlicometria metodo;
  const PlicometryInputScreen({super.key, required this.metodo});

  @override
  State<PlicometryInputScreen> createState() => _PlicometryInputScreenState();
}

class _PlicometryInputScreenState extends State<PlicometryInputScreen> {
  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;

  final _pesoCtrl = TextEditingController();
  final Map<String, TextEditingController> _ctrls = {};

  @override
  void initState() {
    super.initState();
    _pesoCtrl.addListener(_onFieldChanged);
    _loadData();
  }

  void _onFieldChanged() => setState(() {});

  Future<void> _loadData() async {
    final profile = await DatabaseService.instance.getUserProfile();
    final latest  = await DatabaseService.instance.getLatestBodySnapshot();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      if (latest != null) _pesoCtrl.text = latest.pesoKg.toStringAsFixed(1);
      _loading = false;
    });
    if (profile != null) {
      final keys = _isCircumference(widget.metodo)
          ? _circumKeys(widget.metodo, profile.sesso)
          : _plicaKeys(widget.metodo, profile.sesso);
      for (final k in keys) {
        final ctrl = TextEditingController()..addListener(_onFieldChanged);
        _ctrls[k] = ctrl;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    for (final c in _ctrls.values) { c.dispose(); }
    super.dispose();
  }

  double? _parse(String text) =>
      text.trim().isEmpty ? null : double.tryParse(text.trim());

  bool get _canCalculate {
    if (_profile == null || _loading) return false;
    if ((_parse(_pesoCtrl.text) ?? 0) <= 0) return false;
    final keys = _isCircumference(widget.metodo)
        ? _circumKeys(widget.metodo, _profile!.sesso)
        : _plicaKeys(widget.metodo, _profile!.sesso);
    return keys.every((k) => (_parse(_ctrls[k]?.text ?? '') ?? 0) > 0);
  }

  Future<void> _calculate() async {
    if (_profile == null) return;

    final peso = _parse(_pesoCtrl.text);
    if (peso == null || peso <= 0) {
      _snack('Inserisci il peso corporeo');
      return;
    }

    final isCm = _isCircumference(widget.metodo);
    final keys = isCm
        ? _circumKeys(widget.metodo, _profile!.sesso)
        : _plicaKeys(widget.metodo, _profile!.sesso);

    if (keys.any((k) => (_parse(_ctrls[k]?.text ?? '') ?? 0) <= 0)) {
      _snack(isCm ? 'Inserisci tutte le circonferenze' : 'Inserisci tutte le pliche richieste');
      return;
    }

    if (widget.metodo == MetodoPlicometria.usNavy) {
      final collo = _parse(_ctrls['collo']!.text)!;
      final vita = _parse(_ctrls['vita']!.text)!;
      final fianchi = _profile!.sesso == Sesso.maschio ? 0.0 : _parse(_ctrls['fianchi']!.text)!;
      // La formula US Navy fa log10(vita - collo) (uomo) o
      // log10(vita + fianchi - collo) (donna): un valore non positivo
      // produce NaN/-infinito e, dopo il clamp, un falso 70% invece di un
      // errore visibile — vedi PlicometryCalculator._usNavy.
      if (vita + fianchi - collo <= 0) {
        _snack('Vita (+ fianchi) deve essere maggiore del collo');
        return;
      }
    }

    setState(() => _saving = true);

    final inputMap = <String, double>{
      for (final k in keys) k: _parse(_ctrls[k]!.text)!,
    };

    final result = PlicometryCalculator.calculate(
      metodo: widget.metodo,
      sesso: _profile!.sesso,
      eta: _profile!.etaCorrente,
      pesoKg: peso,
      pliche: inputMap,
      altezzaCm: _profile!.altezzaCm,
    );

    final session = PlicometrySession()
      ..data = DateTime.now()
      ..metodo = widget.metodo
      ..etaAnni = _profile!.etaCorrente
      ..pesoKg = peso
      ..altezzaCm = _profile!.altezzaCm
      ..pliche = isCm
          ? Pliche()
          : (Pliche()
            ..bicipiteMm       = inputMap['bicipite']
            ..tricipiteMm      = inputMap['tricipite']
            ..pettoralleMm     = inputMap['pettorale']
            ..ascelllareMm     = inputMap['ascellare']
            ..sottoscapolareMm = inputMap['sottoscapolare']
            ..sovrailiachMm    = inputMap['sovrailiaca']
            ..addomineMm       = inputMap['addome']
            ..cosciaMm         = inputMap['coscia'])
      ..risultati = (RisultatiPlico()
        ..bodyFatPercent  = result.bodyFatPercent
        ..massaGrassaKg   = result.massaGrassaKg
        ..massaMagraKg    = result.massaMagraKg
        ..sommaPlicheMm   = result.sommaPlicheMm
        ..densitaCorporea = result.densitaCorporea);

    await DatabaseService.instance.addPlicometrySession(session);

    if (isCm) {
      await DatabaseService.instance.upsertMeasurementSnapshot(
        data: session.data,
        fonte: 'circonferenze_bf',
        colloCm:   inputMap['collo'],
        vitaCm:    inputMap['vita'],
        fianchiCm: inputMap['fianchi'],
      );
    } else {
      await DatabaseService.instance.upsertMeasurementSnapshot(
        data: session.data,
        fonte: 'plicometria',
        tricipiteMm:      inputMap['tricipite'],
        bicipiteMm:       inputMap['bicipite'],
        pettoraleMm:      inputMap['pettorale'],
        ascelllareMm:     inputMap['ascellare'],
        sottoscapolareMm: inputMap['sottoscapolare'],
        sovrailiachMm:    inputMap['sovrailiaca'],
        addomineMm:       inputMap['addome'],
        cosciaMm:         inputMap['coscia'],
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlicometryResultScreen(
          session: session,
          result: result,
          sesso: _profile!.sesso,
        ),
      ),
    );
    setState(() => _saving = false);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.palette.surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isCm = _isCircumference(widget.metodo);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _methodTitle(widget.metodo).toUpperCase(),
          style: TextStyle(
              color: p.accent, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1.5),
        ),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    children: [
                      // ── Peso ──────────────────────────────
                      Text('PESO',
                          style: TextStyle(
                              color: p.textMuted,
                              fontSize: 11,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _FieldRow(
                        label: 'Peso corporeo',
                        unit: 'kg',
                        ctrl: _pesoCtrl,
                        guideKey: null,
                        sesso: _profile!.sesso,
                        p: p,
                      ),
                      const SizedBox(height: 24),

                      // ── Pliche o Circonferenze ─────────────
                      Text(isCm ? 'CIRCONFERENZE' : 'PLICHE',
                          style: TextStyle(
                              color: p.textMuted,
                              fontSize: 11,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),

                      if (_profile != null && isCm)
                        ..._circumKeys(widget.metodo, _profile!.sesso).map((k) {
                          final spec = _circSpecs[k]!;
                          return _FieldRow(
                            label: spec.label,
                            unit: spec.unit,
                            ctrl: _ctrls[k]!,
                            guideKey: spec.guideKey,
                            sesso: _profile!.sesso,
                            p: p,
                          );
                        }),

                      if (_profile != null && !isCm)
                        ..._plicaKeys(widget.metodo, _profile!.sesso).map((k) {
                          final spec = _plicaSpecs[k]!;
                          return _FieldRow(
                            label: spec.label,
                            unit: spec.unit,
                            ctrl: _ctrls[k]!,
                            guideKey: spec.guideKey,
                            sesso: _profile!.sesso,
                            p: p,
                          );
                        }),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
                  child: ElevatedButton(
                    onPressed: (_saving || !_canCalculate) ? null : _calculate,
                    child: _saving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: p.background))
                        : const Text('CALCOLA'),
                  ),
                ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Shared field row
// ──────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController ctrl;
  final String? guideKey;
  final Sesso sesso;
  final ColorPalette p;

  const _FieldRow({
    required this.label,
    required this.unit,
    required this.ctrl,
    required this.guideKey,
    required this.sesso,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                          color: p.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                if (guideKey != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => showMeasurementGuide(context, guideKey!, sesso: sesso),
                    child: Icon(Icons.info_outline_rounded,
                        color: p.accent.withValues(alpha: 0.7), size: 18),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '—',
                hintStyle: TextStyle(color: p.textMuted),
                suffixText: unit,
                suffixStyle: TextStyle(color: p.textMuted, fontSize: 13),
                filled: true,
                fillColor: p.surfaceVariant,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: p.cardBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: p.cardBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: p.accent, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
