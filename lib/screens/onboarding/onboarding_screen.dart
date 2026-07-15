import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../models/body_snapshot.dart';
import '../../models/enums.dart';
import '../../services/database_service.dart';
import '../../utils/navigation_utils.dart';
import '../main_screen.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  Sesso? _sesso;
  DateTime? _dataNascita;

  final _altezzaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _formKey3 = GlobalKey<FormState>();

  ThemeMode _selectedTheme = ThemeMode.light;
  int _goal = 1;
  int _livello = 2;

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _cognomeController.dispose();
    _altezzaController.dispose();
    _pesoController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _nextPage() => _pageController.nextPage(
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  void _prevPage() => _pageController.previousPage(
      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);

  bool _validateStep1() => _formKey1.currentState?.validate() ?? false;

  bool _validateStep2() {
    if (_sesso == null || _dataNascita == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.onboardingSessoDataError),
        backgroundColor: context.palette.surface,
      ));
      return false;
    }
    return true;
  }

  bool _validateStep3() => _formKey3.currentState?.validate() ?? false;

  Future<void> _pickDate() async {
    final p = context.palette;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: p.accent, onPrimary: p.background,
            surface: p.surface, onSurface: p.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: p.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dataNascita = picked);
  }

  Future<void> _complete() async {
    final profile = UserProfile()
      ..nome = _nomeController.text.trim()
      ..cognome = _cognomeController.text.trim()
      ..dataNascita = _dataNascita!
      ..sesso = _sesso!
      ..altezzaCm = double.parse(_altezzaController.text.trim())
      ..bodyFatIniziale = _bodyFatController.text.trim().isEmpty
          ? null : double.tryParse(_bodyFatController.text.trim())
      ..createdAt = DateTime.now();

    await DatabaseService.instance.saveUserProfile(profile);

    final pesoTxt = _pesoController.text.trim();
    if (pesoTxt.isNotEmpty) {
      final snapshot = BodySnapshot()
        ..data = DateTime.now()
        ..pesoKg = double.parse(pesoTxt)
        ..bodyFatManuale = _bodyFatController.text.trim().isEmpty
            ? null : double.tryParse(_bodyFatController.text.trim())
        ..note = 'Peso iniziale';
      await DatabaseService.instance.addBodySnapshot(snapshot);
      await DatabaseService.instance.activateGoal(
        livello: _livello, metodo: 0, obiettivo: _goal);
    } else {
      await DatabaseService.instance.saveLivelloAttivita(_livello);
      await DatabaseService.instance.saveObiettivo(_goal);
    }

    final isDark = _selectedTheme == ThemeMode.dark;
    await DatabaseService.instance.saveIsDarkMode(isDark);
    themeNotifier.value = _selectedTheme;

    if (!mounted) return;
    replaceEntireStack(context, (_) => const MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _currentPage, total: 6),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _Step1(
                    formKey: _formKey1,
                    nomeController: _nomeController,
                    cognomeController: _cognomeController,
                    l10n: l10n,
                    onNext: () { if (_validateStep1()) _nextPage(); },
                  ),
                  _Step2(
                    sesso: _sesso,
                    dataNascita: _dataNascita,
                    l10n: l10n,
                    onSessoChanged: (s) => setState(() => _sesso = s),
                    onPickDate: _pickDate,
                    onNext: () { if (_validateStep2()) _nextPage(); },
                    onBack: _prevPage,
                  ),
                  _Step3(
                    formKey: _formKey3,
                    altezzaController: _altezzaController,
                    pesoController: _pesoController,
                    bodyFatController: _bodyFatController,
                    l10n: l10n,
                    onNext: () { if (_validateStep3()) _nextPage(); },
                    onBack: _prevPage,
                  ),
                  _StepObiettivo(
                    selected: _goal,
                    l10n: l10n,
                    onSelect: (v) => setState(() => _goal = v),
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  _StepAttivita(
                    selected: _livello,
                    l10n: l10n,
                    onSelect: (v) => setState(() => _livello = v),
                    onNext: _nextPage,
                    onBack: _prevPage,
                  ),
                  _Step4(
                    selectedTheme: _selectedTheme,
                    l10n: l10n,
                    onThemeChanged: (t) {
                      setState(() => _selectedTheme = t);
                      themeNotifier.value = t;
                    },
                    onComplete: _complete,
                    onBack: _prevPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Progress bar
// ──────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? p.accent : p.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 1 — Nome e Cognome
// ──────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeController;
  final TextEditingController cognomeController;
  final dynamic l10n;
  final VoidCallback onNext;

  const _Step1({
    required this.formKey,
    required this.nomeController,
    required this.cognomeController,
    required this.l10n,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('PLICO', style: TextStyle(color: p.accent, fontSize: 13, letterSpacing: 4, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(l10n.onboardingWelcomeTitle, style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 48),
            _OnboardingField(
              controller: nomeController,
              label: l10n.onboardingNomeLabel,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.onboardingNomeError : null,
            ),
            const SizedBox(height: 16),
            _OnboardingField(
              controller: cognomeController,
              label: l10n.onboardingCognomeLabel,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.onboardingCognomeError : null,
            ),
            const SizedBox(height: 48),
            ElevatedButton(onPressed: onNext, child: Text(l10n.onboardingContinua)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 2 — Sesso e Data di nascita
// ──────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final Sesso? sesso;
  final DateTime? dataNascita;
  final dynamic l10n;
  final ValueChanged<Sesso> onSessoChanged;
  final VoidCallback onPickDate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2({
    required this.sesso,
    required this.dataNascita,
    required this.l10n,
    required this.onSessoChanged,
    required this.onPickDate,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(l10n.onboardingChiSeiTitle, style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 48),
          Text(l10n.onboardingSessoLabel, style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              _SessoButton(label: l10n.onboardingUomo, icon: Icons.male_rounded, selected: sesso == Sesso.maschio, onTap: () => onSessoChanged(Sesso.maschio)),
              const SizedBox(width: 12),
              _SessoButton(label: l10n.onboardingDonna, icon: Icons.female_rounded, selected: sesso == Sesso.femmina, onTap: () => onSessoChanged(Sesso.femmina)),
            ],
          ),
          const SizedBox(height: 32),
          Text(l10n.onboardingDataNascitaLabel, style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2.5)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: p.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dataNascita != null ? p.accent : p.cardBorder, width: dataNascita != null ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: dataNascita != null ? p.accent : p.textMuted, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    dataNascita != null
                        ? '${dataNascita!.day.toString().padLeft(2, '0')}/${dataNascita!.month.toString().padLeft(2, '0')}/${dataNascita!.year}'
                        : l10n.onboardingSelezionaData,
                    style: TextStyle(color: dataNascita != null ? p.textPrimary : p.textMuted, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: onNext, child: Text(l10n.onboardingContinua)),
          const SizedBox(height: 12),
          TextButton(onPressed: onBack, child: Text(l10n.onboardingIndietro, style: TextStyle(color: p.textMuted))),
        ],
      ),
    );
  }
}

class _SessoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SessoButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected ? p.accent.withValues(alpha: 0.1) : p.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? p.accent : p.cardBorder, width: selected ? 1.5 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? p.accent : p.textMuted, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: selected ? p.accent : p.textMuted, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 3 — Altezza, Peso e BF iniziale
// ──────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController altezzaController;
  final TextEditingController pesoController;
  final TextEditingController bodyFatController;
  final dynamic l10n;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step3({
    required this.formKey,
    required this.altezzaController,
    required this.pesoController,
    required this.bodyFatController,
    required this.l10n,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(l10n.onboardingMisureTitle, style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 48),
            _OnboardingField(
              controller: altezzaController,
              label: l10n.onboardingAltezzaLabel,
              suffix: 'cm',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.onboardingAltezzaError;
                final n = double.tryParse(v.trim());
                if (n == null || n < 100 || n > 250) return l10n.onboardingAltezzaInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _OnboardingField(
              controller: pesoController,
              label: l10n.onboardingPesoLabel,
              suffix: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.trim());
                if (n == null || n < 20 || n > 300) return l10n.onboardingPesoInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            _OnboardingField(
              controller: bodyFatController,
              label: l10n.onboardingBodyFatLabel,
              suffix: '%',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = double.tryParse(v.trim());
                if (n == null || n < 1 || n > 70) return l10n.onboardingBodyFatInvalid;
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.onboardingMisureNote, style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.5)),
            const SizedBox(height: 48),
            ElevatedButton(onPressed: onNext, child: Text(l10n.onboardingContinua)),
            const SizedBox(height: 12),
            TextButton(onPressed: onBack, child: Text(l10n.onboardingIndietro, style: TextStyle(color: p.textMuted))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step 4 — Scelta tema
// ──────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  final ThemeMode selectedTheme;
  final dynamic l10n;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _Step4({
    required this.selectedTheme,
    required this.l10n,
    required this.onThemeChanged,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(l10n.onboardingTemaTitle, style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l10n.onboardingTemaSubtitle, style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: _ThemeCard(
                label: l10n.onboardingTemaChiaro, icon: Icons.light_mode_rounded,
                selected: selectedTheme == ThemeMode.light,
                bgColor: const Color(0xFFF2FAF5), surfaceColor: Colors.white,
                accentColor: const Color(0xFF00995A), textColor: const Color(0xFF0A1A0F),
                onTap: () => onThemeChanged(ThemeMode.light),
                selectedBorderColor: p.accent, unselectedBorderColor: p.cardBorder,
                labelBg: p.surface, labelSelectedBg: p.accent.withValues(alpha: 0.08),
                labelColor: p.textMuted, labelSelectedColor: p.accent,
              )),
              const SizedBox(width: 14),
              Expanded(child: _ThemeCard(
                label: l10n.onboardingTemaScuro, icon: Icons.dark_mode_rounded,
                selected: selectedTheme == ThemeMode.dark,
                bgColor: const Color(0xFF0B1622), surfaceColor: const Color(0xFF162035),
                accentColor: const Color(0xFF00FF88), textColor: const Color(0xFFE8F2FF),
                onTap: () => onThemeChanged(ThemeMode.dark),
                selectedBorderColor: p.accent, unselectedBorderColor: p.cardBorder,
                labelBg: p.surface, labelSelectedBg: p.accent.withValues(alpha: 0.08),
                labelColor: p.textMuted, labelSelectedColor: p.accent,
              )),
            ],
          ),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: onComplete, child: Text(l10n.onboardingInizia)),
          const SizedBox(height: 12),
          TextButton(onPressed: onBack, child: Text(l10n.onboardingIndietro, style: TextStyle(color: p.textMuted))),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color bgColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color textColor;
  final VoidCallback onTap;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final Color labelBg;
  final Color labelSelectedBg;
  final Color labelColor;
  final Color labelSelectedColor;

  const _ThemeCard({
    required this.label, required this.icon, required this.selected,
    required this.bgColor, required this.surfaceColor, required this.accentColor,
    required this.textColor, required this.onTap,
    required this.selectedBorderColor, required this.unselectedBorderColor,
    required this.labelBg, required this.labelSelectedBg,
    required this.labelColor, required this.labelSelectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? selectedBorderColor : unselectedBorderColor, width: selected ? 2 : 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              Container(
                height: 140, color: bgColor,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(color: bgColor, border: Border(bottom: BorderSide(color: accentColor.withValues(alpha: 0.2)))),
                      child: Center(child: Container(width: 30, height: 4, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)))),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 38,
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: accentColor.withValues(alpha: 0.3))),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentColor, width: 1.5))),
                          const SizedBox(width: 6),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(width: 40, height: 4, color: textColor.withValues(alpha: 0.7), margin: const EdgeInsets.only(bottom: 3)),
                            Container(width: 28, height: 3, color: accentColor.withValues(alpha: 0.5)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 28,
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (_) => Container(width: 18, height: 8, decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2)))),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: selected ? labelSelectedBg : labelBg,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: selected ? labelSelectedColor : labelColor, size: 16),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(color: selected ? labelSelectedColor : labelColor, fontWeight: selected ? FontWeight.w700 : FontWeight.normal, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step Obiettivo
// ──────────────────────────────────────────────

class _StepObiettivo extends StatelessWidget {
  final int selected;
  final dynamic l10n;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _StepObiettivo({
    required this.selected,
    required this.l10n,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  static const _icons = [
    Icons.trending_down_rounded,
    Icons.balance_rounded,
    Icons.trending_up_rounded,
  ];
  static const _colors = [
    Color(0xFF3B9FF2),
    Color(0xFF00C48C),
    Color(0xFFFF8C42),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = [
      (id: 0, label: l10n.onboardingObiettivo0Label, sub: l10n.onboardingObiettivo0Sub, desc: l10n.onboardingObiettivo0Desc),
      (id: 1, label: l10n.onboardingObiettivo1Label, sub: l10n.onboardingObiettivo1Sub, desc: l10n.onboardingObiettivo1Desc),
      (id: 2, label: l10n.onboardingObiettivo2Label, sub: l10n.onboardingObiettivo2Sub, desc: l10n.onboardingObiettivo2Desc),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(l10n.onboardingObiettivoTitle,
              style: TextStyle(color: p.textPrimary, fontSize: 28,
                  fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 40),
          ...items.map((item) {
            final sel = selected == item.id;
            final color = _colors[item.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: sel ? color.withValues(alpha: 0.08) : p.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? color : p.cardBorder, width: sel ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: sel ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_icons[item.id],
                            color: sel ? color : color.withValues(alpha: 0.6),
                            size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: TextStyle(
                                    color: sel ? color : p.textPrimary,
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(item.sub,
                                style: TextStyle(
                                    color: sel ? color.withValues(alpha: 0.8) : p.accent,
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(item.desc,
                                style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.4)),
                          ],
                        ),
                      ),
                      if (sel)
                        Icon(Icons.check_circle_rounded, color: color, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onNext, child: Text(l10n.onboardingContinua)),
          const SizedBox(height: 12),
          TextButton(onPressed: onBack,
              child: Text(l10n.onboardingIndietro, style: TextStyle(color: p.textMuted))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Step Livello di attività
// ──────────────────────────────────────────────

class _StepAttivita extends StatelessWidget {
  final int selected;
  final dynamic l10n;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _StepAttivita({
    required this.selected,
    required this.l10n,
    required this.onSelect,
    required this.onNext,
    required this.onBack,
  });

  static const _multipli = ['×1.2', '×1.375', '×1.55', '×1.725', '×1.9'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final labels = [
      l10n.onboardingAttivita0Label,
      l10n.onboardingAttivita1Label,
      l10n.onboardingAttivita2Label,
      l10n.onboardingAttivita3Label,
      l10n.onboardingAttivita4Label,
    ];
    final descs = [
      l10n.onboardingAttivita0Desc,
      l10n.onboardingAttivita1Desc,
      l10n.onboardingAttivita2Desc,
      l10n.onboardingAttivita3Desc,
      l10n.onboardingAttivita4Desc,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(l10n.onboardingAttivitaTitle,
              style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l10n.onboardingAttivitaSubtitle,
              style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.cardBorder),
            ),
            child: Column(
              children: List.generate(labels.length, (i) {
                final sel = selected == i;
                final isLast = i == labels.length - 1;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFFF6B35).withValues(alpha: 0.07)
                          : Colors.transparent,
                      border: isLast
                          ? null
                          : Border(bottom: BorderSide(color: p.cardBorder)),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: sel ? const Color(0xFFFF6B35) : p.cardBorder,
                                width: sel ? 5 : 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(labels[i],
                                  style: TextStyle(
                                      color: sel ? const Color(0xFFFF6B35) : p.textPrimary,
                                      fontSize: 14,
                                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                              Text(descs[i],
                                  style: TextStyle(color: p.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(_multipli[i],
                            style: TextStyle(
                                color: sel ? const Color(0xFFFF6B35) : p.textMuted,
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: onNext, child: Text(l10n.onboardingContinua)),
          const SizedBox(height: 12),
          TextButton(onPressed: onBack,
              child: Text(l10n.onboardingIndietro, style: TextStyle(color: p.textMuted))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Shared input field
// ──────────────────────────────────────────────

class _OnboardingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const _OnboardingField({
    required this.controller,
    required this.label,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(color: p.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: TextStyle(color: p.textMuted),
        labelStyle: TextStyle(color: p.textSecondary),
        filled: true,
        fillColor: p.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.accent, width: 1.5)),
      ),
    );
  }
}
