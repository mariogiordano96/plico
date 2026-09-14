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
  ];

  static bool isOffTopic(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    return _offTopicPatterns.any((p) => p.hasMatch(trimmed));
  }
}
