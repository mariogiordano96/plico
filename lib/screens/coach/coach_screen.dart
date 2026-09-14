import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_settings.dart';
import '../../services/database_service.dart';
import '../../services/gemini_quota.dart';
import '../../services/gemini_service.dart';
import '../../theme/app_theme.dart';

/// Tab "Coach" (dopo TDEE, docs/integrazione_flutter_gemma.md Fase 7): chat
/// AI su allenamento/nutrizione con Gemini, bring-your-own-key. Prima di
/// avere una chiave salvata mostra le istruzioni per generarne una gratuita
/// su Google AI Studio; con una chiave salvata mostra la chat.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

/// Messaggio localizzato per un [GeminiErrorType] — condiviso tra la view di
/// setup (validazione chiave) e la chat (errore durante l'invio).
String coachErrorMessage(BuildContext context, GeminiErrorType type) {
  final l10n = context.l10n;
  switch (type) {
    case GeminiErrorType.invalidApiKey:
      return l10n.coachErroreChiaveNonValida;
    case GeminiErrorType.quotaExceeded:
      return l10n.coachErroreQuotaEsaurita;
    case GeminiErrorType.dailyLimitReached:
      return l10n.coachErroreLimiteGiornaliero;
    case GeminiErrorType.rateLimited:
      return l10n.coachErroreLimiteMinuto;
    case GeminiErrorType.network:
      return l10n.coachErroreRete;
    case GeminiErrorType.serviceUnavailable:
      return l10n.coachErroreServizioNonDisponibile;
    case GeminiErrorType.unknown:
      return l10n.coachErroreGenerico;
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final bool isError;
  const _ChatMessage({required this.isUser, required this.text, this.isError = false});
}

class _CoachScreenState extends State<CoachScreen> {
  bool _loading = true;
  String? _apiKey;
  int _remainingToday = GeminiQuota.dailyLimit;

  final _messages = <_ChatMessage>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await DatabaseService.instance.getAppSettings();
    final remaining = await GeminiService.remainingToday();
    if (!mounted) return;
    setState(() {
      _apiKey = settings.geminiApiKey?.isNotEmpty == true ? settings.geminiApiKey : null;
      _remainingToday = remaining;
      _loading = false;
    });
    if (!settings.coachOnboardingSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboardingBanner(settings));
    }
  }

  /// Banner mostrato una sola volta, alla primissima apertura della tab —
  /// prima ancora delle istruzioni per la chiave (mostrate solo se non è
  /// ancora salvata): a differenza del resto di Plico, offline-first, qui i
  /// messaggi escono verso Google, e va detto subito, non solo nel
  /// disclaimer al salvataggio della chiave.
  Future<void> _showOnboardingBanner(AppSettings settings) async {
    final p = context.palette;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        icon: Icon(Icons.public_rounded, color: p.accent),
        title: Text(l10n.coachOnboardingTitolo, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.coachOnboardingBody, style: TextStyle(color: p.textSecondary)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: p.accent),
            child: Text(l10n.coachOnboardingOk,
                style: TextStyle(color: p.background, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    settings.coachOnboardingSeen = true;
    await DatabaseService.instance.saveAppSettings(settings);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _systemInstruction(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    if (isItalian) {
      return 'Sei il "Coach" dell\'app Plico, un assistente su allenamento e '
          'alimentazione. Rispondi in italiano, in modo conciso e pratico. Resta '
          'SOLO nel dominio allenamento/nutrizione: per qualunque altro argomento '
          'rifiuta gentilmente e riporta la conversazione al tuo scopo. Non fornire '
          'mai diagnosi mediche, non dare indicazioni su infortuni specifici, non '
          'trattare disturbi alimentari: per questi temi invita sempre a consultare '
          'un professionista (medico, fisioterapista, dietista) invece di rispondere '
          'nel merito.';
    }
    return 'You are "Coach", Plico\'s assistant for workout and nutrition '
        'questions. Answer in English, concisely and practically. Stay ONLY in '
        'the workout/nutrition domain: for anything else, politely decline and '
        'steer the conversation back. Never give medical diagnoses, specific '
        'injury guidance, or eating-disorder advice: for those topics always '
        'suggest consulting a professional (doctor, physiotherapist, '
        'dietitian) instead of answering directly.';
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending || _apiKey == null) return;
    _inputCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await GeminiService.sendMessage(
        apiKey: _apiKey!,
        systemInstruction: _systemInstruction(context),
        history: [
          for (final m in _messages) GeminiTurn(isUser: m.isUser, text: m.text),
        ],
      );
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(isUser: false, text: reply)));
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() => _messages
          .add(_ChatMessage(isUser: false, text: _errorMessage(e.type), isError: true)));
    } finally {
      final remaining = await GeminiService.remainingToday();
      if (mounted) {
        setState(() {
          _sending = false;
          _remainingToday = remaining;
        });
        _scrollToBottom();
      }
    }
  }

  String _errorMessage(GeminiErrorType type) => coachErrorMessage(context, type);

  Future<void> _cambiaChiave() async {
    final l10n = context.l10n;
    final p = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.coachRimuoviChiaveTitolo, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.coachRimuoviChiaveSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.coachModificaChiave, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final settings = await DatabaseService.instance.getAppSettings();
    settings.geminiApiKey = null;
    await DatabaseService.instance.saveAppSettings(settings);
    if (!mounted) return;
    setState(() {
      _apiKey = null;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        title: Text(l10n.coachTitolo,
            style: TextStyle(color: p.accent, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_apiKey != null)
            IconButton(
              onPressed: _cambiaChiave,
              icon: Icon(Icons.vpn_key_off_rounded, color: p.textMuted),
              tooltip: l10n.coachModificaChiave,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: p.accent))
          : _apiKey == null
              ? _ApiKeySetupView(onSaved: _load)
              : _ChatView(
                  messages: _messages,
                  inputCtrl: _inputCtrl,
                  scrollCtrl: _scrollCtrl,
                  sending: _sending,
                  remainingToday: _remainingToday,
                  onSend: _send,
                ),
    );
  }
}

class _ApiKeySetupView extends StatefulWidget {
  final VoidCallback onSaved;
  const _ApiKeySetupView({required this.onSaved});

  @override
  State<_ApiKeySetupView> createState() => _ApiKeySetupViewState();
}

class _ApiKeySetupViewState extends State<_ApiKeySetupView> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _openAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/apikey');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Nessun browser disponibile: l'utente può comunque copiare l'URL a
      // mano, non blocchiamo il resto del flusso per questo.
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error = l10n.coachApiKeyObbligatoria);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await GeminiService.validateApiKey(key);
      final settings = await DatabaseService.instance.getAppSettings();
      settings.geminiApiKey = key;
      await DatabaseService.instance.saveAppSettings(settings);
      if (!mounted) return;
      widget.onSaved();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() => _error = coachErrorMessage(context, e.type));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: p.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: p.accent.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.smart_toy_rounded, color: p.accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(l10n.coachTitolo,
                          style: TextStyle(
                              color: p.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l10n.coachSetupIntro,
                    style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.coachSetupStep1,
              style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAiStudio,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: p.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: Icon(Icons.open_in_new_rounded, color: p.accent, size: 18),
              label: Text(l10n.coachSetupApriAiStudio,
                  style: TextStyle(color: p.accent, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.coachSetupStep2,
              style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _keyCtrl,
            obscureText: _obscure,
            style: TextStyle(color: p.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.coachApiKeyHint,
              hintStyle: TextStyle(color: p.textMuted),
              filled: true,
              fillColor: p.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: p.cardBorder),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: p.textMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: p.error, fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: p.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: p.background),
                        ),
                        const SizedBox(width: 10),
                        Text(l10n.coachVerificaChiave,
                            style: TextStyle(color: p.background, fontWeight: FontWeight.w700)),
                      ],
                    )
                  : Text(l10n.coachSalvaChiave,
                      style: TextStyle(color: p.background, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.coachDisclaimer,
              style: TextStyle(color: p.textMuted, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

class _ChatView extends StatelessWidget {
  final List<_ChatMessage> messages;
  final TextEditingController inputCtrl;
  final ScrollController scrollCtrl;
  final bool sending;
  final int remainingToday;
  final VoidCallback onSend;

  const _ChatView({
    required this.messages,
    required this.inputCtrl,
    required this.scrollCtrl,
    required this.sending,
    required this.remainingToday,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(l10n.coachRichiesteRimaste(remainingToday),
                style: TextStyle(color: p.textMuted, fontSize: 11)),
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (messages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.coachBenvenuto,
                      style: TextStyle(color: p.textMuted, fontSize: 13, height: 1.4)),
                ),
              for (final m in messages) _MessageBubble(message: m, p: p),
              if (sending)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    enabled: !sending && remainingToday > 0,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: TextStyle(color: p.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.coachScriviMessaggio,
                      hintStyle: TextStyle(color: p.textMuted),
                      isDense: true,
                      filled: true,
                      fillColor: p.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: p.cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sending || remainingToday <= 0 ? null : onSend,
                  icon: Icon(Icons.send_rounded,
                      color: sending || remainingToday <= 0 ? p.textMuted : p.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final ColorPalette p;
  const _MessageBubble({required this.message, required this.p});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? p.accent.withValues(alpha: 0.15)
              : message.isError
                  ? p.error.withValues(alpha: 0.1)
                  : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isUser ? p.accent.withValues(alpha: 0.4) : p.cardBorder),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isError ? p.error : p.textPrimary,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
