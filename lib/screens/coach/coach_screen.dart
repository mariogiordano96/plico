import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/app_settings.dart';
import '../../models/coach_message.dart';
import '../../services/coach_context.dart';
import '../../services/coach_guardrail.dart';
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
  // Sottoinsieme di isError: rifiuto locale del guardrail, non un errore
  // Gemini — mai un bottone "Riprova", né in sessione né al reload.
  final bool isGuardrail;
  // Solo sui messaggi di errore (non guardrail): il testo dell'utente che ha
  // causato l'errore, per poter riprovare senza doverlo ridigitare.
  final String? retryText;
  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.isError = false,
    this.isGuardrail = false,
    this.retryText,
  });
}

class _CoachScreenState extends State<CoachScreen> {
  bool _loading = true;
  String? _apiKey;
  int _remainingToday = GeminiQuota.dailyLimit;

  final _messages = <_ChatMessage>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;
  bool _shareData = false;
  String? _retryHint;

  // Limite ai turni inviati a Gemini come history: la conversazione persiste
  // per sempre (nessun reset per giorno/sessione), ma il payload di ogni
  // richiesta deve restare limitato — la UI mostra comunque tutta la
  // cronologia salvata, solo il contesto mandato al modello è troncato.
  static const _maxHistoryTurns = 30;

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
    final persisted = await DatabaseService.instance.getCoachMessages();
    if (!mounted) return;
    setState(() {
      _apiKey = settings.geminiApiKey?.isNotEmpty == true ? settings.geminiApiKey : null;
      _remainingToday = remaining;
      _shareData = settings.coachShareData;
      _messages
        ..clear()
        ..addAll(_fromPersisted(persisted));
      _loading = false;
    });
    _scrollToBottom();
    if (!settings.coachOnboardingSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOnboardingBanner(settings));
    }
  }

  /// Ricostruisce `retryText` per i messaggi di errore Gemini (non i rifiuti
  /// del guardrail, che non l'hanno mai avuto) ricaricati da disco: risale
  /// oltre eventuali errori consecutivi (retry falliti più volte di fila)
  /// fino al messaggio utente che li ha originati — stesso testo che
  /// avremmo mandato di nuovo.
  List<_ChatMessage> _fromPersisted(List<CoachMessage> messages) {
    final result = <_ChatMessage>[];
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      String? retryText;
      if (m.isError && !m.isGuardrail) {
        var j = i - 1;
        while (j >= 0 && messages[j].isError) {
          j--;
        }
        if (j >= 0 && messages[j].isUser) retryText = messages[j].text;
      }
      result.add(_ChatMessage(
        isUser: m.isUser,
        text: m.text,
        isError: m.isError,
        isGuardrail: m.isGuardrail,
        retryText: retryText,
      ));
    }
    return result;
  }

  /// Aggiunge il messaggio in UI e lo persiste; se la scrittura su disco
  /// fallisce annulla l'aggiunta in UI invece di lasciare un bubble che
  /// sparirebbe silenziosamente al prossimo riavvio. Il chiamante deve
  /// controllare l'esito prima di proseguire (es. non chiamare Gemini se il
  /// turno utente non è stato salvato).
  Future<bool> _addMessage(_ChatMessage message) async {
    setState(() => _messages.add(message));
    try {
      await DatabaseService.instance.addCoachMessage(
        CoachMessage()
          ..createdAt = DateTime.now()
          ..isUser = message.isUser
          ..text = message.text
          ..isError = message.isError
          ..isGuardrail = message.isGuardrail,
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() => _messages.remove(message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.coachErroreGenerico)),
      );
      return false;
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

  Future<String> _systemInstruction(BuildContext context) async {
    final base = _baseInstruction(context);
    if (!_shareData) return base;
    try {
      final isItalian = Localizations.localeOf(context).languageCode == 'it';
      final data = CoachContext.build(await CoachContext.load(), isItalian: isItalian);
      return data.isEmpty ? base : '$base\n\n$data';
    } catch (_) {
      // Il contesto è un di più: se la lettura fallisce il Coach risponde
      // comunque, come prima della Fase 8.
      return base;
    }
  }

  Future<void> _toggleShareData() async {
    final settings = await DatabaseService.instance.getAppSettings();
    settings.coachShareData = !settings.coachShareData;
    await DatabaseService.instance.saveAppSettings(settings);
    if (!mounted) return;
    setState(() => _shareData = settings.coachShareData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(settings.coachShareData
            ? context.l10n.coachCondividiDatiOn
            : context.l10n.coachCondividiDatiOff)));
  }

  String _baseInstruction(BuildContext context) {
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
    // Se il turno utente non viene persistito (bubble già rimosso da
    // _addMessage) non ha senso interpellare Gemini per un messaggio che la
    // UI ha appena ritirato: niente spesa di quota per una richiesta che non
    // resterà in conversazione.
    final persisted = await _addMessage(_ChatMessage(isUser: true, text: text));
    if (!persisted) return;
    await _sendText(text);
  }

  /// Bottone "Riprova" su un messaggio di errore: rimanda lo stesso testo
  /// senza doverlo ridigitare — il turno utente originale è già in
  /// `_messages`, non va aggiunto di nuovo.
  Future<void> _retry(String text) => _sendText(text);

  Future<void> _sendText(String text) async {
    if (_sending || _apiKey == null) return;
    // Guardrail deterministico (docs/integrazione_flutter_gemma.md, Fase 8):
    // per le richieste palesemente fuori tema risponde subito in locale,
    // senza toccare la rete né consumare quota — il system prompt resta la
    // difesa principale per tutto il resto, più sfumato di una lista fissa.
    if (CoachGuardrail.isOffTopic(text)) {
      // isError: true anche se non è un errore Gemini — vedi il commento su
      // CoachMessage.isError: qui serve solo a escludere il rifiuto dalla
      // history rimandata a Gemini (e dal rendering Markdown). isGuardrail
      // distingue questo caso da un vero errore Gemini per _fromPersisted.
      await _addMessage(_ChatMessage(
          isUser: false, text: context.l10n.coachFuoriTema, isError: true, isGuardrail: true));
      _scrollToBottom();
      return;
    }
    setState(() => _sending = true);
    _scrollToBottom();

    try {
      final reply = await GeminiService.sendMessage(
        apiKey: _apiKey!,
        systemInstruction: await _systemInstruction(context),
        // Esclude i bubble di errore dalla storia mandata a Gemini: sono
        // messaggi nostri (localizzati, per l'utente), non turni reali del
        // modello — includerli inquinerebbe la conversazione. Tronca poi ai
        // turni più recenti: la conversazione persiste senza limiti, ma il
        // payload per richiesta deve restare limitato.
        history: [
          for (final m in _boundedHistory(_messages.where((m) => !m.isError).toList()))
            GeminiTurn(isUser: m.isUser, text: m.text),
        ],
        onRetrying: (attempt) {
          if (!mounted) return;
          setState(() => _retryHint = context.l10n.coachRiprovo(attempt));
        },
      );
      if (!mounted) return;
      await _addMessage(_ChatMessage(isUser: false, text: reply));
    } on GeminiException catch (e) {
      if (!mounted) return;
      await _addMessage(_ChatMessage(
          isUser: false, text: _errorMessage(e.type), isError: true, retryText: text));
    } finally {
      final remaining = await GeminiService.remainingToday();
      if (mounted) {
        setState(() {
          _sending = false;
          _retryHint = null;
          _remainingToday = remaining;
        });
        _scrollToBottom();
      }
    }
  }

  /// Tronca ai turni più recenti, ma solo a partire dal primo turno utente:
  /// l'API Gemini richiede che `contents` cominci con role "user", e un
  /// taglio a indice fisso potrebbe altrimenti atterrare su un turno modello
  /// (la history filtrata non è garantita alternata, vedi i commenti sopra
  /// su guardrail ed errori esclusi).
  List<_ChatMessage> _boundedHistory(List<_ChatMessage> messages) {
    if (messages.length <= _maxHistoryTurns) return messages;
    var start = messages.length - _maxHistoryTurns;
    while (start < messages.length && !messages[start].isUser) {
      start++;
    }
    return messages.sublist(start);
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
    // Coerente col testo del dialog sopra ("la chat attuale non verrà
    // salvata"): ora che la cronologia è persistita, azzerarla solo in
    // memoria non basterebbe più a mantenere quella promessa.
    await DatabaseService.instance.clearCoachMessages();
    if (!mounted) return;
    setState(() {
      _apiKey = null;
      _messages.clear();
    });
  }

  Future<void> _nuovaConversazione() async {
    final l10n = context.l10n;
    final p = context.palette;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: Text(l10n.coachNuovaConversazioneTitolo, style: TextStyle(color: p.textPrimary)),
        content: Text(l10n.coachNuovaConversazioneSub, style: TextStyle(color: p.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.diarioAnnulla, style: TextStyle(color: p.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.coachNuovaConversazioneConferma, style: TextStyle(color: p.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await DatabaseService.instance.clearCoachMessages();
    if (!mounted) return;
    setState(() => _messages.clear());
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
              onPressed: _toggleShareData,
              icon: Icon(_shareData ? Icons.person_rounded : Icons.person_off_outlined,
                  color: _shareData ? p.accent : p.textMuted),
              tooltip: l10n.coachCondividiDatiTooltip,
            ),
          if (_apiKey != null && _messages.isNotEmpty)
            IconButton(
              onPressed: _nuovaConversazione,
              icon: Icon(Icons.delete_sweep_outlined, color: p.textMuted),
              tooltip: l10n.coachNuovaConversazioneTitolo,
            ),
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
                  retryHint: _retryHint,
                  remainingToday: _remainingToday,
                  onSend: _send,
                  onRetry: _retry,
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
  final String? retryHint;
  final int remainingToday;
  final VoidCallback onSend;
  final ValueChanged<String> onRetry;

  const _ChatView({
    required this.messages,
    required this.inputCtrl,
    required this.scrollCtrl,
    required this.sending,
    required this.retryHint,
    required this.remainingToday,
    required this.onSend,
    required this.onRetry,
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
              for (final m in messages)
                _MessageBubble(message: m, p: p, sending: sending, onRetry: onRetry),
              if (sending)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
                        ),
                        if (retryHint != null) ...[
                          const SizedBox(width: 10),
                          Text(retryHint!, style: TextStyle(color: p.textMuted, fontSize: 12)),
                        ],
                      ],
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

/// Stile Markdown allineato alla palette tema-aware dell'app invece del
/// default (che userebbe i colori del `Theme` Material, non i nostri).
MarkdownStyleSheet _markdownStyle(BuildContext context, ColorPalette p) {
  final base = TextStyle(color: p.textPrimary, fontSize: 14, height: 1.35);
  return MarkdownStyleSheet(
    p: base,
    strong: base.copyWith(fontWeight: FontWeight.w700),
    em: base.copyWith(fontStyle: FontStyle.italic),
    h1: base.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    h2: base.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    h3: base.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
    listBullet: base,
    blockquote: base.copyWith(color: p.textMuted),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: p.cardBorder, width: 3)),
    ),
    code: base.copyWith(
      color: p.accent,
      fontFamily: 'monospace',
      backgroundColor: p.background,
    ),
    codeblockDecoration: BoxDecoration(
      color: p.background,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: p.cardBorder),
    ),
    a: base.copyWith(color: p.accent, decoration: TextDecoration.underline),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: p.cardBorder)),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final ColorPalette p;
  final bool sending;
  final ValueChanged<String> onRetry;
  const _MessageBubble({
    required this.message,
    required this.p,
    required this.sending,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Solo le risposte del modello sono Markdown reale (grassetto,
            // elenchi, titoli...) da renderizzare — i messaggi dell'utente
            // sono testo digitato (un "*" va mostrato letterale, non
            // interpretato), gli errori sono stringhe nostre già semplici.
            if (!isUser && !message.isError)
              MarkdownBody(
                data: message.text,
                styleSheet: _markdownStyle(context, p),
                onTapLink: (_, href, _) async {
                  if (href == null) return;
                  try {
                    await launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                  } catch (_) {
                    // Nessun browser disponibile: il testo del link resta comunque leggibile.
                  }
                },
              )
            else
              Text(
                message.text,
                style: TextStyle(
                  color: message.isError ? p.error : p.textPrimary,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            if (message.isError && message.retryText != null) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: sending ? null : () => onRetry(message.retryText!),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 15, color: sending ? p.textMuted : p.error),
                      const SizedBox(width: 4),
                      Text(l10n.coachRiprova,
                          style: TextStyle(
                              color: sending ? p.textMuted : p.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
