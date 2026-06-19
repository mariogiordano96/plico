import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/body_snapshot.dart';
import '../../services/achievement_service.dart';
import '../../services/database_service.dart';

class AddPesataScreen extends StatefulWidget {
  const AddPesataScreen({super.key});

  @override
  State<AddPesataScreen> createState() => _AddPesataScreenState();
}

class _AddPesataScreenState extends State<AddPesataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _altezzaController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _data = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _pesoController.dispose();
    _altezzaController.dispose();
    _bodyFatController.dispose();
    _noteController.dispose();
    super.dispose();
  }

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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final snapshot = BodySnapshot()
      ..data = _data
      ..pesoKg = double.parse(_pesoController.text.trim())
      ..altezzaCm = _altezzaController.text.trim().isEmpty ? null : double.tryParse(_altezzaController.text.trim())
      ..bodyFatManuale = _bodyFatController.text.trim().isEmpty ? null : double.tryParse(_bodyFatController.text.trim())
      ..note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    await DatabaseService.instance.addBodySnapshot(snapshot);
    AchievementService.instance.checkAll();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dataStr = '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pesateNuova, style: TextStyle(color: p.accent, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.accent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label(context.l10n.pesateData, p),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: p.surfaceVariant, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.cardBorder)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: p.accent, size: 18),
                      const SizedBox(width: 12),
                      Text(dataStr, style: TextStyle(color: p.textPrimary, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _Label(context.l10n.pesatePeso, p),
              const SizedBox(height: 8),
              _Field(
                controller: _pesoController, hint: '75.5', suffix: 'kg', p: p,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return context.l10n.pesateCampoObb;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 20 || n > 300) return context.l10n.pesatePesoInvalido;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _Label(context.l10n.pesateAltezzaOpz, p),
              const SizedBox(height: 8),
              _Field(
                controller: _altezzaController, hint: context.l10n.pesateAltezzaHint, suffix: 'cm', p: p,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 100 || n > 250) return context.l10n.pesateAltezzaInvalida;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _Label(context.l10n.pesateBodyFatOpz, p),
              const SizedBox(height: 8),
              _Field(
                controller: _bodyFatController, hint: context.l10n.pesateBodyFatHint, suffix: '%', p: p,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 1 || n > 70) return context.l10n.pesateBodyFatInvalido;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _Label(context.l10n.pesateNoteOpz, p),
              const SizedBox(height: 8),
              _Field(controller: _noteController, hint: context.l10n.pesateNoteHint, p: p, maxLines: 3),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: p.background))
                    : Text(context.l10n.pesateSalva),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final ColorPalette p;
  const _Label(this.text, this.p);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: p.textMuted, fontSize: 11, letterSpacing: 2.5, fontWeight: FontWeight.w600));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final ColorPalette p;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.hint,
    required this.p,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: p.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textMuted, fontSize: 14),
        suffixText: suffix,
        suffixStyle: TextStyle(color: p.textMuted),
        filled: true,
        fillColor: p.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: p.accent, width: 1.5)),
      ),
    );
  }
}
