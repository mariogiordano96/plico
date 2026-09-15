/// Guardrail deterministico lato app per il Coach (docs/integrazione_flutter_gemma.md,
/// Fase 8): un controllo locale, prima ancora di chiamare Gemini, per le richieste
/// palesemente fuori dal dominio allenamento/nutrizione/ricette. Non sostituisce il
/// system prompt (che resta la difesa principale, sfumata) — è un secondo livello
/// grezzo ma gratuito e istantaneo, per i casi più ovvi (niente rete, niente consumo
/// di quota).
///
/// Nessun pacchetto/lista pronta trovata per questo scopo (ricerca 2026-09): i
/// framework guardrail professionali (LLM Guard, NeMo Guardrails) usano modelli di
/// classificazione, non liste — troppo pesanti per un'app client-only senza backend.
/// Lista scritta e mantenuta a mano, come gli altri contenuti curati di Plico
/// (catalogo esercizi, knowledge base).
///
/// Deliberatamente permissivo: in caso di dubbio lascia passare al modello (system
/// prompt) invece di rifiutare — un falso positivo (bloccare una domanda legittima
/// formulata in modo insolito) è peggio di un falso negativo (lasciar passare
/// qualcosa di fuori tema, che il system prompt comunque rifiuterà). Per questo i
/// pattern richiedono frasi/combinazioni abbastanza specifiche, non singole parole
/// ambigue (es. "programma" da solo non basta: potrebbe essere "programma di
/// allenamento", in dominio).
class CoachGuardrail {
  static final List<RegExp> _offTopicPatterns = [
    // Programmazione / aiuto tecnico non legato all'app
    RegExp(
      r'\b(scrivi|scrivimi|aiutami con|debugga|correggi)\b.{0,20}\b(codice|funzione|script|programma in (python|java|javascript|dart|c\+\+))\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(write|help me (with|debug)|fix)\b.{0,20}\b(code|function|script|program in (python|java|javascript|dart|c\+\+))\b',
      caseSensitive: false,
    ),
    // Compiti scolastici di materie non pertinenti
    RegExp(
      r'\b(compiti?|tema|esercizio) di (matematica|storia|geografia|italiano|inglese|fisica|chimica|filosofia|latino)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bhomework (for|on|about) (math|history|geography|english|physics|chemistry|philosophy)\b',
      caseSensitive: false,
    ),
    // Politica / attualità
    RegExp(
      r'\b(chi è|chi era) il presidente\b|\belezioni (politiche|presidenziali)\b|\brisultati delle elezioni\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bwho is the president\b|\b(election results|presidential election)\b',
      caseSensitive: false,
    ),
    // Trivia generica / cultura generale
    RegExp(
      r'\bcapitale (di|dell|della|degli)\b|\bquanti abitanti ha\b|\bchi ha vinto (il|la) (mondiale|champions|oscar)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bcapital of\b|\bhow many people live in\b|\bwho won the (world cup|champions league|oscars)\b',
      caseSensitive: false,
    ),
    // Scrittura creativa generica (non ricette)
    RegExp(
      r'\bscrivi(mi)? (una poesia|una canzone|un racconto|una barzelletta|una storia)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bwrite (me )?(a poem|a song|a short story|a joke)\b',
      caseSensitive: false,
    ),
    // Meteo / cronaca varia, richieste spesso usate per "testare" un assistente
    RegExp(r'\bprevisioni del tempo\b|\bche tempo fa\b', caseSensitive: false),
    RegExp(r"\bweather forecast\b|\bwhat'?s the weather\b", caseSensitive: false),
    // Assistenza tecnica generica su altre app / dispositivi (non i wearable/app fitness)
    RegExp(
      r'\b(password|account) di (instagram|facebook|whatsapp|gmail|netflix|spotify|tiktok)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bil (wifi|wi-fi)\b.{0,20}\b(non si connette|non funziona)\b|\b(aggiornare|aggiorno) (android|ios|windows) (sul|del) (telefono|pc)\b|\bcancell(are|o) la cache\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(password|account) (for|on) (instagram|facebook|whatsapp|gmail|netflix|spotify|tiktok)\b',
      caseSensitive: false,
    ),
    RegExp(
      r"\b(wifi|wi-fi) (won'?t connect|is not working)\b|\bupdate (android|ios|windows) on my (phone|pc)\b|\bclear (the )?cache\b",
      caseSensitive: false,
    ),
    // Intrattenimento / gossip
    RegExp(
      r'\bchi è (il fidanzato|la fidanzata|il marito|la moglie) di\b|\b(trama|recensione) del film\b|\bultimo episodio di\b|\bconsigliami una serie tv\b|\bche film guardo stasera\b',
      caseSensitive: false,
    ),
    RegExp(
      r"\bwho is (dating|her boyfriend|his girlfriend)\b|\b(plot|review) of the movie\b|\blatest episode of\b|\bwhat (tv series|movie) should I watch\b|\bcelebrity gossip\b",
      caseSensitive: false,
    ),
    // Consigli legali / finanziari non di fitness
    RegExp(
      r'\bconviene investire in (bitcoin|azioni|criptovalute|borsa)\b|\b(dichiarazione dei redditi|730|modello unico)\b|\bcome (faccio|posso) a separarmi (da|dal|dalla) (mio marito|mia moglie)\b|\bconsulenza legale su\b|\bcome faccio causa a\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\bshould I invest in (bitcoin|stocks|crypto|the stock market)\b|\b(tax return|file my taxes)\b|\bhow do I (get a )?divorce\b|\blegal advice (on|about)\b|\bcan I sue\b',
      caseSensitive: false,
    ),
    // Richieste di traduzione generica (non contenuti del dominio come ricette/piani)
    RegExp(
      r'\btraduci(mi)? (questa frase|questo testo|la seguente frase|il seguente testo)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\btranslate (this sentence|this text|the following sentence|the following text)\b',
      caseSensitive: false,
    ),
  ];

  static bool isOffTopic(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    return _offTopicPatterns.any((p) => p.hasMatch(trimmed));
  }
}
