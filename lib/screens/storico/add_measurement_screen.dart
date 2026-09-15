import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/enums.dart';
import '../../services/database_service.dart';
import '../../widgets/measurement_guide.dart';
import '../debug/calibration_screen.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _data = DateTime.now();
  bool _saving = false;
  Sesso _sesso = Sesso.maschio; // default, sovrascritto da initState

  // Pliche controllers
  final _tricipiteCtrl = TextEditingController();
  final _bicipiteCtrl = TextEditingController();
  final _pettoralCtrl = TextEditingController();
  final _ascellareCtrl = TextEditingController();
  final _sottoscapCtrl = TextEditingController();
  final _sovrailiacacCtrl = TextEditingController();
  final _addomeCtrl = TextEditingController();
  final _cosciaPlCtrl = TextEditingController();
  final _polpaccioPlCtrl = TextEditingController();

  // Circonferenze controllers
  final _colloCtrl = TextEditingController();
  final _vitaCtrl = TextEditingController();
  final _fianchiCtrl = TextEditingController();
  final _braccioCtrl = TextEditingController();
  final _cosciaCircCtrl = TextEditingController();
  final _polpaccioCircCtrl = TextEditingController();
  final _toraceCtrl = TextEditingController();
  final _spalleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSesso();
  }

  Future<void> _loadSesso() async {
    final profile = await DatabaseService.instance.getUserProfile();
    if (profile != null && mounted) {
      setState(() => _sesso = profile.sesso);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _tricipiteCtrl,
      _bicipiteCtrl,
      _pettoralCtrl,
      _ascellareCtrl,
      _sottoscapCtrl,
      _sovrailiacacCtrl,
      _addomeCtrl,
      _cosciaPlCtrl,
      _polpaccioPlCtrl,
      _colloCtrl,
      _vitaCtrl,
      _fianchiCtrl,
      _braccioCtrl,
      _cosciaCircCtrl,
      _polpaccioCircCtrl,
      _toraceCtrl,
      _spalleCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());

  bool get _hasAnyValue => [
    _tricipiteCtrl,
    _bicipiteCtrl,
    _pettoralCtrl,
    _ascellareCtrl,
    _sottoscapCtrl,
    _sovrailiacacCtrl,
    _addomeCtrl,
    _cosciaPlCtrl,
    _polpaccioPlCtrl,
    _colloCtrl,
    _vitaCtrl,
    _fianchiCtrl,
    _braccioCtrl,
    _cosciaCircCtrl,
    _polpaccioCircCtrl,
    _toraceCtrl,
    _spalleCtrl,
  ].any((c) => c.text.trim().isNotEmpty);

  Future<void> _pickDate() async {
    final p = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: p.accent,
            onPrimary: p.background,
            surface: p.surface,
            onSurface: p.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: p.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data = picked);
  }

  Future<void> _save() async {
    if (!_hasAnyValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.misurazioneInserisciValore),
          backgroundColor: context.palette.surface,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    await DatabaseService.instance.upsertMeasurementSnapshot(
      data: _data,
      fonte: 'manuale',
      colloCm: _parse(_colloCtrl),
      tricipiteMm: _parse(_tricipiteCtrl),
      bicipiteMm: _parse(_bicipiteCtrl),
      pettoraleMm: _parse(_pettoralCtrl),
      ascelllareMm: _parse(_ascellareCtrl),
      sottoscapolareMm: _parse(_sottoscapCtrl),
      sovrailiachMm: _parse(_sovrailiacacCtrl),
      addomineMm: _parse(_addomeCtrl),
      cosciaMm: _parse(_cosciaPlCtrl),
      polpaccioMm: _parse(_polpaccioPlCtrl),
      vitaCm: _parse(_vitaCtrl),
      fianchiCm: _parse(_fianchiCtrl),
      braccioCm: _parse(_braccioCtrl),
      cosciaCm: _parse(_cosciaCircCtrl),
      polpaccioCm: _parse(_polpaccioCircCtrl),
      toraceCm: _parse(_toraceCtrl),
      spalleCm: _parse(_spalleCtrl),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dataStr =
        '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.misurazioneNuova,
          style: TextStyle(
            color: p.accent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.tune_rounded, color: p.accent),
              tooltip: context.l10n.misurazioneCalibrazione,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalibrationScreen()),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Date picker
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: p.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: p.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      dataStr,
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.misurazioneModifica,
                      style: TextStyle(color: p.accent, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // TabBar (compatta)
          Container(
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: p.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: p.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: p.background,
              unselectedLabelColor: p.textMuted,
              labelPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
              tabs: [
                Tab(text: context.l10n.misurazioneTabPliche),
                Tab(text: context.l10n.misurazioneTabCirconferenze),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PlicheTab(
                  sesso: _sesso,
                  tricipite: _tricipiteCtrl,
                  bicipite: _bicipiteCtrl,
                  pettorale: _pettoralCtrl,
                  ascellare: _ascellareCtrl,
                  sottoscapolare: _sottoscapCtrl,
                  sovrailica: _sovrailiacacCtrl,
                  addome: _addomeCtrl,
                  coscia: _cosciaPlCtrl,
                  polpaccio: _polpaccioPlCtrl,
                ),
                _CirconferenzeTab(
                  sesso: _sesso,
                  collo: _colloCtrl,
                  vita: _vitaCtrl,
                  fianchi: _fianchiCtrl,
                  braccio: _braccioCtrl,
                  coscia: _cosciaCircCtrl,
                  polpaccio: _polpaccioCircCtrl,
                  torace: _toraceCtrl,
                  spalle: _spalleCtrl,
                ),
              ],
            ),
          ),

          // Save button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: p.background,
                      ),
                    )
                  : Text(context.l10n.misurazioneSalva),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Tab Pliche
// ──────────────────────────────────────────────

class _PlicheTab extends StatelessWidget {
  final Sesso sesso;
  final TextEditingController tricipite, bicipite, pettorale, ascellare;
  final TextEditingController sottoscapolare,
      sovrailica,
      addome,
      coscia,
      polpaccio;

  const _PlicheTab({
    required this.sesso,
    required this.tricipite,
    required this.bicipite,
    required this.pettorale,
    required this.ascellare,
    required this.sottoscapolare,
    required this.sovrailica,
    required this.addome,
    required this.coscia,
    required this.polpaccio,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      children: [
        _MeasureField(
          label: context.l10n.misuraTricipite,
          unit: 'mm',
          controller: tricipite,
          siteKey: 'tricipite',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraBicipite,
          unit: 'mm',
          controller: bicipite,
          siteKey: 'bicipite',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraPettorale,
          unit: 'mm',
          controller: pettorale,
          siteKey: 'pettorale',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraAscellare,
          unit: 'mm',
          controller: ascellare,
          siteKey: 'ascellare',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraSottoscapolare,
          unit: 'mm',
          controller: sottoscapolare,
          siteKey: 'sottoscapolare',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraSovrailiaca,
          unit: 'mm',
          controller: sovrailica,
          siteKey: 'sovrailiaca',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraAddome,
          unit: 'mm',
          controller: addome,
          siteKey: 'addome',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraCosciaPlica,
          unit: 'mm',
          controller: coscia,
          siteKey: 'coscia_plica',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraPolpaccio,
          unit: 'mm',
          controller: polpaccio,
          siteKey: 'polpaccio_plica',
          sesso: sesso,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Tab Circonferenze
// ──────────────────────────────────────────────

class _CirconferenzeTab extends StatelessWidget {
  final Sesso sesso;
  final TextEditingController collo,
      vita,
      fianchi,
      braccio,
      coscia,
      polpaccio,
      torace,
      spalle;

  const _CirconferenzeTab({
    required this.sesso,
    required this.collo,
    required this.vita,
    required this.fianchi,
    required this.braccio,
    required this.coscia,
    required this.polpaccio,
    required this.torace,
    required this.spalle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      children: [
        _MeasureField(
          label: context.l10n.misuraCollo,
          unit: 'cm',
          controller: collo,
          siteKey: 'collo',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraVita,
          unit: 'cm',
          controller: vita,
          siteKey: 'vita',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraFianchi,
          unit: 'cm',
          controller: fianchi,
          siteKey: 'fianchi',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraBraccio,
          unit: 'cm',
          controller: braccio,
          siteKey: 'braccio',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraCoscia,
          unit: 'cm',
          controller: coscia,
          siteKey: 'coscia_circ',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraPolpaccio,
          unit: 'cm',
          controller: polpaccio,
          siteKey: 'polpaccio_circ',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraTorace,
          unit: 'cm',
          controller: torace,
          siteKey: 'torace',
          sesso: sesso,
        ),
        _MeasureField(
          label: context.l10n.misuraSpalle,
          unit: 'cm',
          controller: spalle,
          siteKey: 'spalle',
          sesso: sesso,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Shared field
// ──────────────────────────────────────────────

class _MeasureField extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;
  final String siteKey;
  final Sesso sesso;

  const _MeasureField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.siteKey,
    required this.sesso,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Label + bottone info
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: p.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () =>
                      showMeasurementGuide(context, siteKey, sesso: sesso),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: p.accent.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Input
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.right,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '—',
                hintStyle: TextStyle(color: p.textMuted),
                suffixText: unit,
                suffixStyle: TextStyle(color: p.textMuted, fontSize: 13),
                filled: true,
                fillColor: p.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: p.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: p.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: p.accent, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
