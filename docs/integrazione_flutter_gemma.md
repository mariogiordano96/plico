# Integrazione Flutter Gemma — Analisi Funzionale

> Obiettivo: un assistente AI on-device dentro Plico, accessibile via chat, che risponde
> solo a domande di nutrizione e allenamento e può consultare (in sola lettura) i dati
> dell'utente per rispondere in modo contestuale — non un chatbot generico, e non un'AI
> che modifica dati per conto dell'utente.
>
> Questo documento **supera** un punto della ricerca preliminare in
> `ricerca_modello_ai_locale.md`, che ipotizzava un "progetto ad hoc separato da Plico":
> qui l'integrazione è dentro il codebase di Plico, per poter accedere ai dati locali
> dell'utente (Isar) tramite function calling. Il resto di quella ricerca (modello,
> RAG-first, avvertimento legale) resta valido e non viene riscritto qui.

---

## 1. Scope

1. **Chat conversazionale** con dominio ristretto a nutrizione e allenamento — rifiuto
   esplicito di tutto il resto, non solo "meglio se non risponde"
2. **Function calling in sola lettura** sui dati locali dell'utente (Isar, tramite
   `DatabaseService` esistente) per risposte contestuali reali: "quante kcal ho mangiato
   oggi", "quando ho fatto squat l'ultima volta", non solo consigli generici
3. **Rifiuto esplicito e redirect** per aree sensibili: diagnosi mediche, gestione
   infortuni, disturbi alimentari (vedi avvertimento in `ricerca_modello_ai_locale.md`)

Fuori scope v1 (decisione esplicita, non solo rimandata):
- **Azioni in scrittura** — loggare un pasto, avviare un allenamento, modificare dati su
  richiesta della chat. L'assistente consulta, non agisce. Vedi Fase 6 in sezione 6 per
  come si estenderebbe in futuro, se servirà.
- **Fine-tuning** — si parte da RAG + system prompt, come da raccomandazione della ricerca
  preliminare.

---

## 2. Modello e libreria

Recap minimo, il confronto completo dei modelli resta in `ricerca_modello_ai_locale.md`;
questa sezione la aggiorna sul punto licenza/modello dopo verifica puntuale.

- **Modello scelto: Qwen3** (non Gemma), tramite `flutter_gemma` — il pacchetto resta lo
  stesso nonostante il nome, supporta nativamente più famiglie di modelli oltre a Gemma
  (Qwen3, Phi-4-mini, DeepSeek R1 distillati, SmolLM...)
- **Perché Qwen3 e non Gemma**: **licenza Apache 2.0 su tutta la famiglia** (0.6B, 1.7B,
  4B...) — nessuna Prohibited Use Policy, nessun diritto di revoca unilaterale, a
  differenza della Gemma Terms of Use che vincola ancora Gemma 3n/Gemma 3. **Nota**: Google
  ha rilasciato Gemma 4 (aprile 2026) sotto Apache 2.0, risolvendo lo stesso problema di
  licenza — ma la taglia più piccola pubblicata (Gemma 4 E2B) resta nella classe di peso
  pesante (~2GB), mentre Qwen3 offre licenza pulita **e** taglie leggere insieme. Per
  questo si è scelto Qwen3 anche a parità di problema di licenza risolto da entrambi.
- **Aggiornamento 2026-09 — verifica puntuale su pub.dev**: `flutter_gemma` v1.8.2 (pubblicata
  di recente) elenca esplicitamente come modello Qwen3 supportato **solo "Qwen3 0.6B"** —
  **nessun Qwen3 1.7B** nell'elenco ufficiale dei modelli curati dal pacchetto (verificato sia
  su `pub.dev/packages/flutter_gemma` sia su `fluttergemma.dev/docs/models`, stessa fonte,
  stesso autore). La scelta "1.7B di default" sotto va quindi trattata come **da riverificare
  prima dell'implementazione**, non confermata: il modello Qwen3-1.7B esiste ed è Apache 2.0
  (Hugging Face), ma non risulta tra quelli che il pacchetto scarica/esegue "out of the box" —
  andrebbe capito se è comunque caricabile (formato `.task`/`.litertlm` convertito a mano) o
  se in pratica l'unica opzione Qwen3 disponibile senza lavoro extra è la 0.6B.
  **Alternativa già pronta nello stesso pacchetto, se la 0.6B risultasse troppo debole**:
  **Qwen 2.5 1.5B (1.6GB)** — anch'esso Apache 2.0 (confermato: tutti i modelli Qwen2.5 tranne
  3B e 72B sono Apache 2.0), function calling supportato, esplicitamente nell'elenco ufficiale
  del pacchetto. Non è Qwen3 (niente "thinking mode"), ma è più pesante/capace della 0.6B e
  resta gratuito e già supportato senza lavoro di conversione.
  **Non ancora disponibile**: la nuova famiglia **Qwen 3.5 Small (0.8B/2B/4B/9B, Apache 2.0,
  rilasciata marzo 2026)** non risulta nell'elenco modelli di `flutter_gemma` al momento di
  questa verifica — potenziale upgrade futuro se/quando il pacchetto la supporterà, non
  un'opzione utilizzabile oggi.
- **Piano rivisto in attesa di riverifica**: **Qwen3 0.6B come modello di default** (unico
  Qwen3 confermato supportato), **Qwen 2.5 1.5B come opzione più capace** se la qualità della
  0.6B non basta (in particolare per la generazione ricette, sezione 3.2/6 — task più
  esigente delle semplici risposte fattuali già previste) — footprint di entrambi comunque
  nell'ordine delle centinaia di MB/pochi GB, coerente con l'impostazione di sezione 5.1
- **Italiano**: Qwen3/Qwen2.5 dichiarano supporto multilingue su 100+ lingue, italiano incluso
  esplicitamente nella lista ufficiale, anche sulle taglie piccole. Il supporto dichiarato
  **non equivale a qualità verificata sul dominio nutrizione/allenamento in italiano** —
  da validare concretamente in Fase 1 con domande reali, non assunto solo perché l'italiano
  è nell'elenco delle lingue supportate
- **Doppia modalità "thinking"/"non-thinking"**: Qwen3 supporta un modo di ragionamento
  esteso (visibile step-by-step) e uno rapido. Per una chat interattiva su dispositivo, la
  modalità "non-thinking" è probabilmente da preferire per la latenza — da configurare e
  verificare in Fase 1, non lasciare il default della libreria senza controllo
- Il pacchetto ha un'architettura modulare: un core che non registra alcun motore da solo,
  più package opzionali per l'inference engine e per il RAG (`flutter_gemma_rag_qdrant` su
  mobile, basato su `qdrant-edge` — vero vector store con embedding, non un semplice
  keyword-match) — da aggiungere esplicitamente in `FlutterGemma.initialize(...)`
- **Function calling confermato supportato su Qwen3** in `flutter_gemma` — punto critico
  per l'architettura di sezione 3.2, verificato prima di scegliere questo modello
- Perso rispetto a Gemma: **`FunctionGemma 270M`**, il modello dedicato al routing delle
  function call, è specifico Gemma — nessun equivalente Qwen. Era già segnato "non
  necessario per l'MVP" nella versione precedente di questa sezione, impatto basso

---

## 3. Architettura

### 3.1 Componenti

- **`ChatScreen`** (nuova UI) — lista messaggi + input, streaming della risposta token per
  token (l'inferenza on-device, anche sul modello di default più leggero, richiede
  comunque qualche secondo)
- **`GemmaService`** — wrapper attorno a `flutter_gemma`: caricamento modello, gestione
  conversazione/contesto, esecuzione in isolato separato (inferenza pesante, non deve
  bloccare la UI thread)
- **Tool registry** — le funzioni Dart che il modello può invocare, ognuna una query in
  sola lettura su `DatabaseService` esistente, con ritorno di un oggetto piccolo e tipato
  (non righe grezze del DB) — importante per un modello con context window ridotta
- **RAG store** (`flutter_gemma_rag_qdrant`) — knowledge base locale di contenuti
  nutrizione/allenamento, curata a mano, bundlata come asset (stesso principio già usato
  per `exercises_seed.json`: contenuto preparato offline, non generato a runtime)
- **System prompt** — vincola dominio, tono, formato, e i rifiuti su temi sensibili

### 3.2 Function calling — tool esposti (sola lettura)

Quasi tutti i metodi necessari esistono già in `DatabaseService`: il lavoro è avvolgerli in
tool con uno schema chiaro per il modello, non scrivere nuove query.

| Tool | Metodo esistente | Esempio domanda utente |
|---|---|---|
| Kcal/macro di un giorno | `getDailyLog(date)` | "Quante kcal ho mangiato oggi?" |
| Storico peso | `getBodySnapshots()` / `getLatestBodySnapshot()` | "Come sta andando il mio peso questo mese?" |
| Storico di un esercizio | `getHistoryForExercise(exerciseId)` | "Quando ho fatto squat l'ultima volta?" |
| Record personali | `getAllPersonalRecords()` | "Qual è il mio massimale in panca?" |
| Kcal bruciate in allenamento (giorno) | `getWorkoutKcalForDay(date)` | "Quante kcal ho bruciato oggi in palestra?" |
| Piano alimentare attivo | `getMealPlan()` | "Cosa devo mangiare oggi secondo il piano?" / "Dammi una ricetta per pranzo con queste grammature" |
| Volume settimanale per gruppo muscolare | `getWeeklyVolumeByMuscleGroup(weekStart)` | "Sto allenando abbastanza le gambe questa settimana?" |
| Impostazioni/obiettivo TDEE | `getAppSettings()` | "Qual è il mio obiettivo calorico attuale?" |

> Nessun tool con effetti collaterali in v1 (niente `save*`/`add*`/`delete*`): coerente con
> la decisione "sola lettura" di questo documento.

**Nota su "dammi una ricetta"**: a differenza degli altri esempi in tabella (risposte brevi e
fattuali su dati già noti), generare una ricetta è un output lungo e strutturato
(ingredienti + procedimento) — un task generativo più esigente, non solo un lookup. Due
conseguenze da tenere esplicite:
- Va validato in Fase 1 con lo stesso rigore riservato alla qualità in italiano (vedi
  sezione 2): non basta che il modello "sappia l'italiano", deve produrre una ricetta
  coerente e seguibile, specialmente sul modello più leggero (0.6B).
- Ricerca esterna (2026) su generazione di ricette con LLM segnala che anche modelli
  fine-tunati ad hoc faticano a rispettare con precisione le quantità di ingredienti fornite
  in input — per Plico questo significa che la validazione non deve limitarsi a "la ricetta
  suona bene", ma controllare esplicitamente che le grammature citate nella ricetta generata
  siano vicine a quelle del piano passato come contesto (`getMealPlan()`), non reinventate dal
  modello. Se lo scostamento è sistematico, va gestito lato prompt (istruzione esplicita di
  rispettare le grammature date) prima di considerare la feature pronta.

### 3.3 RAG — contenuti di dominio

- Knowledge base scritta a mano: principi di nutrizione base (macro, deficit/surplus
  calorico, timing pasti) e di allenamento (progressive overload, volume, recupero) — non
  generata dal modello stesso, per poterla correggere senza riaddestrare nulla (stesso
  vantaggio già indicato in `ricerca_modello_ai_locale.md`)
- Volume contenuto (poche decine di documenti brevi): l'indicizzazione con
  `flutter_gemma_rag_qdrant` è comunque sufficiente e già supportata nativamente dal
  pacchetto, nessun servizio esterno
- Manutenzione: la knowledge base va scritta e aggiornata a mano, come i preset di
  allenamento in `evolutiva_esercizi.md` — non è "gratis", va budgetato come lavoro
  editoriale oltre che tecnico

### 3.4 System prompt e guardrail

- Vincola le risposte al dominio nutrizione/allenamento; tutto il resto → rifiuto esplicito
  con messaggio chiaro, non un tentativo di rispondere comunque
- Rifiuto esplicito, non delegato al solo prompt, per: diagnosi mediche, gestione infortuni,
  disturbi alimentari → redirect a un professionista. **Guardrail a doppio livello**: un
  controllo lato app su parole chiave/pattern sensibili *prima* di interpellare il modello
  (rifiuto immediato, deterministico) oltre alle istruzioni nel system prompt — non
  affidarsi al solo prompt per un'area a rischio di responsabilità legale
- Lingua coerente con quella dell'app (IT/EN, stesso meccanismo di `l10n`)

---

## 4. UX

> **Aggiornamento 2026-09 — decisione presa, supera questo punto**: implementata una 6ª
> tab dedicata "Coach" (dopo TDEE), non un FAB/icona AppBar come ipotizzato sotto — scelta
> esplicita dell'utente. La tab unifica setup chiave e chat nella stessa schermata
> (`CoachScreen`): senza chiave salvata mostra le istruzioni, con chiave salvata mostra la
> chat — vedi Fase 7 più sotto per il resto dell'implementazione.

- **Punto di ingresso**: le 5 tab esistenti (Home/Diario/Allenamento/Progressi/TDEE) sono
  già piene — niente nuovo tab, un FAB globale o un'icona in AppBar
- **Onboarding alla prima apertura**: cosa può e non può fare l'assistente, disclaimer "non
  sostituisce un professionista" (coerente col guardrail di sezione 3.4)
- **Indicatore di stato**: streaming della risposta + eventuale stato "sto consultando i
  tuoi dati" quando è in corso una function call, per non far percepire l'attesa come un
  blocco
- **Cronologia**: **implementata 2026-09** — persistita su Isar (`CoachMessage`,
  `lib/models/coach_message.dart`), una conversazione continua che sopravvive a un
  riavvio dell'app, non più solo in memoria della sessione corrente. Azzerabile
  esplicitamente dall'utente ("Nuova conversazione" in AppBar, o implicitamente
  cambiando la chiave API — coerente col disclaimer "la chat attuale non verrà
  salvata" mostrato in quel caso).

---

## 5. Considerazioni tecniche / rischi

### 5.1 Impatto sullo spazio

Il modello scelto (sezione 2) determina anche la risposta a "quanto pesa l'app": **Qwen3
1.7B come default**, footprint quantizzato nell'ordine delle **centinaia di MB**, un salto
molto più sostenibile per un'app il cui footprint dati attuale (catalogo esercizi +
database alimenti CREA) è sotto i 2 MB in totale.

- **Dimensione app da store**: cresce poco. La libreria nativa di inferenza di
  `flutter_gemma` (via native-assets/`dart:ffi`, nessun JVM/gRPC/server separato) si
  aggiunge al bundle in fase di build, ma è ordini di grandezza più piccola del modello
  stesso — il modello **non va mai bundlato** in APK/IPA (best practice consolidata: un
  modello da 600MB+ nel bundle "distrugge il tasso di conversione all'installazione")
- **Spazio su device dopo il download**: Qwen3 1.7B quantizzato, scaricato on-demand alla
  prima apertura della chat (non al primo avvio dell'app) — centinaia di MB, con UI di
  progresso e gestione di connessione assente/lenta (sezione 4, Fase 5)
- **Qwen3 0.6B come fallback più leggero**: per device con RAM limitata, non come upgrade
  ma come opzione più contenuta — a differenza dello schema precedente (dove il modello più
  pesante era l'upgrade qualità), qui non c'è ancora un'opzione "più capace" individuata:
  Qwen3 4B esiste ma non è stato valutato per il footprint su questo caso d'uso, da
  considerare solo se 1.7B risultasse insufficiente in Fase 1
- Nessuna cifra qui è verificata con precisione per la libreria nativa bundlata né per la
  dimensione esatta dei file quantizzati Qwen3 in formato `flutter_gemma`: da misurare
  concretamente in Fase 1 (build di prova, download reale del modello) prima di comunicare
  un numero definitivo

### 5.2 Altri rischi

- **Device di fascia bassa**: serve un fallback esplicito ("Assistente non disponibile su
  questo dispositivo") sotto una soglia minima di RAM, invece di un'esperienza
  inutilizzabilmente lenta o un crash
- **Batteria/CPU**: l'inferenza locale è pesante — isolato dedicato, timeout, cancellazione
  se l'utente esce dalla chat a metà risposta
- **Context window limitata**: i tool devono restituire dati minimi/aggregati (sezione 3.2),
  mai intere liste o oggetti grezzi del DB
- **Guardrail non delegabile al solo modello**: per i temi sensibili (infortuni, disturbi
  alimentari) un controllo deterministico lato app resta necessario, un modello piccolo
  può comunque sbagliare il rifiuto
- **Nessun invio dati a server esterni**: tutto on-device, coerente con l'impostazione
  offline-first di Plico (Isar locale) — a differenza di un chatbot cloud-based, non c'è
  nulla da configurare lato privacy/consenso oltre al download del modello stesso
- **Pacchetto in rapida evoluzione**: `flutter_gemma` ha cambiato l'architettura RAG di
  recente (rimosso il vecchio store sqlite+hnsw a favore di `qdrant-edge`) — verificare la
  versione corrente e la stabilità delle API di function calling al momento
  dell'implementazione, non fidarsi ciecamente di questo documento

---

## 6. Piano di implementazione

### Fase 1 — Setup
- [ ] Aggiungere `flutter_gemma` (+ package RAG `flutter_gemma_rag_qdrant`)
- [ ] Scaricare/testare Qwen3 0.6B (unico Qwen3 confermato supportato, vedi sezione 2) e,
      se la qualità non basta, Qwen 2.5 1.5B come alternativa più capace — su device reale
- [ ] Verificare qualità delle risposte in italiano su domande di dominio reali (non solo
      fidarsi del supporto multilingue dichiarato, sezione 2)
- [x] **Test negativo, 2026-09** — generazione ricette con `qwen3.5:2b` via Ollama
      (`--think=false`), stesso prompt di test di questo doc (sezione 3.2): risultato
      inutilizzabile. Il modello ha inventato un ingrediente non presente nel piano ("lardo
      crudo" al posto del pollo), ha prodotto un procedimento incoerente e contraddittorio
      (impanatura, un impasto steso a mano, frittura, congelamento, bollitura in acqua per
      un piatto pollo/riso/zucchine) ed è entrato in un loop di elaborazione senza arrivare
      a una conclusione sensata, richiedendo interruzione manuale. Non risolto disattivando
      il thinking mode — non è (solo) un problema di ragionamento visibile, ma di coerenza
      generativa di base a questa taglia. **Non testata la Fase 2 di verifica prevista**
      (prompt più vincolante, o `qwen3.5:4b` laptop-class) — decisione presa di non investire
      altro tempo su questo prima di avere il fallback cloud pronto, vedi Fase 7
- [ ] *(eventuale, se si vuole dare un'altra possibilità al modello locale prima di
      considerarlo chiuso)* Ripetere il test con un prompt più vincolante (limite di
      passaggi, divieto esplicito di ingredienti/tecniche fuori lista) e/o con `qwen3.5:4b`
      — non prioritario, la strada decisa per ora è il fallback Gemini opt-in (Fase 7)
- [ ] Configurare e verificare la modalità "non-thinking" per la latenza in chat
- [ ] Confermare il supporto function calling su Qwen3 con un test end-to-end minimo
- [ ] Misurare concretamente l'impatto sulla dimensione dell'app da store (libreria nativa,
      senza il modello) e la dimensione reale dei modelli scaricati (sezione 5.1)

### Fase 2 — Chat base (nessuna restrizione di dominio, nessun tool)
- [ ] `ChatScreen` minimale, `GemmaService`, inferenza locale funzionante in isolato
- [ ] Streaming della risposta in UI

### Fase 3 — Dominio e guardrail
- [ ] System prompt con restrizione al dominio nutrizione/allenamento
- [ ] Knowledge base RAG (contenuti curati a mano, sezione 3.3)
- [ ] Guardrail lato app per temi sensibili, **prima** di interpellare il modello

### Fase 4 — Function calling sui dati utente
- [ ] Tool registry (tabella sezione 3.2), wrapping dei metodi `DatabaseService` esistenti
- [ ] Nessun tool con effetti collaterali (solo lettura)
- [ ] Test con domande reali sui propri dati, verifica che il contesto passato al modello
      resti minimo

### Fase 5 — UX/rifinitura
- [ ] Entry point (FAB), onboarding/disclaimer alla prima apertura
- [ ] Download modello on-demand con progress UI e gestione errori di rete
- [ ] Fallback esplicito per device sotto soglia RAM

### Fase 6 — *(futura, fuori da questo piano)* Azioni in scrittura
Loggare pasti/allenamenti su richiesta della chat. Deciso esplicitamente fuori scope in
questa fase: richiederebbe conferme utente più stringenti prima di ogni azione e un'analisi
separata dei guardrail (un'AI che scrive dati per errore è un rischio diverso da una che
risponde male a una domanda).

### Fase 7 — Modello cloud bring-your-own-key (implementata, 2026-09)

> **Scope allargato rispetto al piano originale**: la motivazione sotto parla solo di
> ricette, ma l'implementazione 2026-09 è una chat "Coach" generale (allenamento +
> nutrizione), non ristretta alle ricette — il modello locale (Fasi 1-6) non è mai stato
> costruito, quindi Gemini è oggi l'unico motore, non un fallback per un caso specifico.
> **Non ancora implementato in questa fase**: function calling/lettura dati utente
> (`getMealPlan()`, TDEE, storico) — il Coach oggi risponde senza contesto sui dati
> dell'utente, una naturale Fase 8 se serve renderlo più utile ("cosa mangio oggi secondo
> il mio piano?").
>
> **Guardrail deterministico lato app — aggiunto 2026-09** (`lib/services/coach_guardrail.dart`,
> `CoachGuardrail.isOffTopic`, testato in `test/coach_guardrail_test.dart`): un controllo
> locale a pattern regex, eseguito PRIMA di chiamare Gemini, per le richieste palesemente
> fuori dal dominio allenamento/nutrizione/ricette (aiuto di programmazione, compiti
> scolastici di altre materie, politica/attualità, trivia generica, scrittura creativa
> generica, meteo) — rifiuta in locale senza toccare la rete né consumare quota.
> **Categorie aggiunte 2026-09**: assistenza tecnica generica su altre app/dispositivi
> (password/account di app terze, wifi, aggiornamento OS, cache — non i wearable/app
> fitness, che restano in dominio), intrattenimento/gossip (celebrità, trama/recensioni
> di film e serie tv), consigli legali/finanziari non di fitness (investimenti, fisco,
> separazioni/divorzio, consulenza legale) e richieste di traduzione generica (frasi/testi
> generici, non contenuti del dominio come ricette o piani). Stesso criterio delle
> categorie originali: pattern su frasi specifiche in entrambe le lingue dell'app, mai
> parole singole che potrebbero comparire in una domanda di fitness/nutrizione (es. "il
> mio garmin non si sincronizza" resta in dominio, non collide col pattern wifi/app).
> Deliberatamente permissivo: in caso di dubbio lascia passare al system prompt (sezione
> 3.4, resta la difesa principale) invece di rifiutare — pattern su frasi/combinazioni
> specifiche, non singole parole ambigue che collidono col dominio (es. "programma" da
> solo non basta, potrebbe essere "programma di allenamento"). Nessuna lista/pacchetto
> pronto trovato per questo (ricerca web 2026-09): i guardrail professionali (LLM Guard,
> NeMo Guardrails) usano modelli di classificazione zero-shot, non liste — troppo pesanti
> per un client-only senza backend; lista scritta e mantenuta a mano, come gli altri
> contenuti curati di Plico. **Limite noto**: non copre i temi sensibili (diagnosi
> mediche, infortuni, disturbi alimentari) — quelli restano delegati al solo system
> prompt, che li gestisce con un redirect esplicito, non un rifiuto secco.

**Motivazione — non più solo un'ipotesi, confermata da un test reale**: il test negativo di
Fase 1 (2026-09, `qwen3.5:2b`) ha mostrato che il modello locale nella classe di taglia
adatta a mobile non è affidabile per generare ricette — ingredienti inventati, procedimento
incoerente, nessun miglioramento disattivando il thinking mode. **Decisione presa**: per la
generazione ricette specificamente, non si insiste sul modello locale — si offre da subito
l'iscrizione (enrollment) al fallback **Gemini Flash** via API se l'utente lo desidera,
invece di investire altro tempo di validazione su modelli locali più grandi o prompt più
elaborati. Il modello locale resta comunque il default per il resto della chat (domande
fattuali sui propri dati, sezione 3.2, dove il test *non* ha mostrato problemi) — la scelta
riguarda solo la generazione ricette, non tutto l'assistente. Senza rompere il principio
offline-first per chi non attiva l'opzione: resta opt-in, mai automatico.

**Meccanismo — bring-your-own-key, non una chiave Plico condivisa**:
- L'utente genera **la propria** API key gratuita su [Google AI Studio](https://aistudio.google.com)
  (nessuna carta richiesta) e la incolla in un campo nelle Impostazioni di Plico — non è un
  "Accedi con Google" via OAuth dentro l'app (richiederebbe la registrazione/verifica
  dell'app presso Google, più complesso), solo un campo testo per la chiave
- **Perché non una chiave unica incorporata in Plico**: il free tier di Gemini Flash è
  limitato **per progetto** (10 richieste/minuto, 1.500/giorno — verificato su
  `ai.google.dev/gemini-api/docs/rate-limits`, 2026-09), non per utente finale. Una chiave
  condivisa da tutti gli utenti Plico esaurirebbe quel limite quasi subito con più di
  qualche utente contemporaneo, oltre al rischio di estrazione della chiave dall'APK. Con
  bring-your-own-key ogni utente ha la propria quota separata, e un eventuale sforamento a
  pagamento resterebbe a suo carico, non di Plico
- Nessun backend, nessuna chiave di Plico da proteggere — le chiamate partono direttamente
  dal client verso l'API Google usando la chiave incollata dall'utente

**Implementazione — REST diretta, non `firebase_ai`**:
- L'SDK ufficiale Dart `google_generative_ai` è **deprecato**; il sostituto raccomandato da
  Google è `firebase_ai`. **Da evitare per questo caso d'uso**: `firebase_ai` richiede un
  progetto Firebase collegato all'app (file di configurazione, inizializzazione Firebase) —
  e quel progetto sarebbe **di Plico**, non dell'utente. L'uso dell'API passerebbe quindi
  per la quota/fatturazione del progetto di Plico, non per quella personale dell'utente,
  vanificando l'intero motivo per cui si è scelto bring-your-own-key
- **Scelta**: chiamata HTTP diretta alla REST API di Gemini (package `http`, nessuna
  dipendenza nuova pesante, nessun progetto Firebase/Google Cloud lato Plico):
  ```
  POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=<chiave_utente>
  Body: { "contents": [{ "parts": [{ "text": "<prompt costruito>" }] }] }
  ```
  > **Aggiornamento 2026-09**: modello fisso, non l'alias `gemini-flash-latest`
  > inizialmente usato — quell'alias punta oggi a Gemini 3.8 Flash, un modello appena
  > uscito e molto richiesto, che nella pratica ha dato ripetuti `503 UNAVAILABLE`
  > ("modello sovraccarico") durante i primi test reali. Primo tentativo di fix,
  > `gemini-2.5-flash` (più datato, atteso più stabile in disponibilità): risultato
  > `404 NOT_FOUND` dal vivo — *"This model models/gemini-2.5-flash is no longer
  > available to new users. Please update your code to use models/gemini-3.6-flash"*,
  > testo del messaggio d'errore di Google stessa. Modello finale: `gemini-3.6-flash`,
  > raccomandazione diretta di Google nello stesso errore — più recente di 2.5 (quindi
  > ancora disponibile a nuove chiavi) ma non l'ultimissimo 3.8 (quindi meno esposto ai
  > picchi di domanda del giorno del lancio). Ricerca e fonti in sezione "Riferimenti".
  Per lo streaming in UI (token per token, come già previsto per il modello locale in
  sezione 4) c'è l'endpoint equivalente `:streamGenerateContent`
- **Nessun function calling verso Gemini necessario per le ricette**: a differenza del
  modello locale (sezione 3.2, tool registry su `DatabaseService`), qui il piano alimentare
  lo si legge già in locale con `getMealPlan()` **prima** di costruire la richiesta, e si
  scrive direttamente nel prompt come testo/dati — più semplice che far scoprire al modello
  cloud i dati tramite una tool call
- La UI di chat/streaming già pianificata per il modello locale (sezione 4) può essere
  riusata cambiando solo il "motore" dietro le quinte — non serve una schermata separata

**Privacy — punto distinto dal costo, da comunicare esplicitamente**:
- Google dichiara che le richieste sul free tier **possono essere usate per migliorare i
  modelli** — a differenza del modello locale, i dati inviati (piano alimentare, e
  indirettamente peso/obiettivi se passati come contesto) lasciano il device e potrebbero
  finire nei dati di addestramento di Google
- Serve un disclaimer esplicito **prima** di attivare l'opzione, stesso pattern già usato
  per il consenso dati smartwatch (`integrazione_smartwatch.md`, Fase 5) — non un'attivazione
  silenziosa o un fallback automatico quando il modello locale è "abbastanza buono"

- [x] **2026-09**: UI campo "API key Gemini" — non nelle Impostazioni come scritto sopra,
      ma nella nuova tab "Coach" stessa (`lib/screens/coach/coach_screen.dart`,
      `_ApiKeySetupView`): link diretto a Google AI Studio (`aistudio.google.com/apikey`)
      e spiegazione bring-your-own-key prima del campo. La chiave viene anche validata con
      una chiamata di test (`GeminiService.validateApiKey`) prima di salvarla, non solo
      accettata a occhio.
- [x] **2026-09**: Disclaimer esplicito pre-salvataggio (dati a Google, possibile uso per
      training sul free tier, costi di eventuale sforamento a carico dell'utente) —
      `coachDisclaimer` in `app_it.arb`/`app_en.arb`, mostrato sotto il campo chiave.
- [ ] Selettore modello locale/cloud in chat, o fallback automatico **solo su errore/timeout
      del modello locale**, mai come sostituzione silenziosa per "qualità percepita bassa"
      (quella resta una scelta esplicita dell'utente, non euristica automatica) — **N/A per
      ora**: il modello locale (Fasi 1-6) non è mai stato implementato, Coach oggi è
      solo-cloud, non un fallback di qualcosa che esiste
- [x] **2026-09**: Gestione errori specifici dell'API cloud — chiave non valida (400/403),
      quota esaurita (429), nessuna connessione: `GeminiErrorType` in `gemini_service.dart`,
      messaggi distinti localizzati (`coachErrore*` in arb). **In più, non solo previsto dal
      piano originale**: due guardrail locali *preventivi*, prima ancora di chiamare l'API,
      per non fare affidamento solo sul 429 di Google — vedi punto quota sotto.
- [ ] Verificare se serve gestire il caso "utente ha una chiave con billing attivo oltre il
      free tier" in modo diverso (nessuna azione lato Plico prevista oggi, ma da tenere
      presente se emergono segnalazioni)

**Aggiunta 2026-09, non nel piano originale — protezione quota locale**: dato che la chiave
è dell'utente, uno sforamento lo pagherebbe lui, non Plico. `GeminiQuota`
(`lib/services/gemini_quota.dart`, logica pura testata in `test/gemini_quota_test.dart`)
blocca nuove richieste *prima* di interpellare l'API se si supererebbe il free tier (10
richieste/minuto, finestra in memoria; 1.500/giorno, contatore persistito su
`AppSettings.geminiRequestsToday`/`geminiRequestsResetDate`, azzerato al cambio di giorno). La
UI mostra "N richieste rimaste oggi" e disabilita l'invio a quota locale esaurita. **Limite
noto**: il contatore giornaliero è locale a questo device — un utente con Plico installato su
più device supererebbe comunque il free tier di Google senza che Plico se ne accorga (nessun
sync della quota tra device), da tenere presente se emergono segnalazioni.


### Fase 8 — Contesto sui dati utente nel Coach (implementata, 2026-10)

Il Coach ora può rispondere su dati reali ("cosa mangio a pranzo secondo il mio piano?",
"sto allenando abbastanza le gambe?"). **Scelta: contesto nel system prompt, non function
calling** — ogni tool call verso Gemini sarebbe una richiesta in più sulla quota free tier
della chiave dell'utente (vedi `GeminiQuota`), mentre i dati si leggono in locale prima
della richiesta, come già indicato nella Fase 7 per il piano alimentare.

- [x] `CoachContext` (`lib/services/coach_context.dart`): `load()` legge da
      `DatabaseService` (obiettivo, target giornalieri, ultimi 5 pesi, pasti di oggi, kcal
      allenamento, piano attivo con grammature, volume settimanale per gruppo, 8 PR) e
      `build()` (pura, IT/EN) lo trasforma in testo compatto accodato al system prompt.
- [x] **Opt-in esplicito**: `AppSettings.coachShareData`, default `false`, toggle in AppBar
      della tab Coach (icona persona) con snackbar che dice che i dati vanno a Google. Il
      disclaimer della Fase 7 copriva le "richieste", non dati personali.
- [x] Fallimento della lettura contesto → il Coach risponde come prima, senza contesto.
- [x] Test: `test/coach_context_test.dart`.
- [ ] Verifica su device con chiave reale (le grammature citate nelle ricette coincidono
      con quelle del piano? vedi nota sezione 3.2).
- [ ] Eventuale tool per storico di un singolo esercizio (`getHistoryForExercise`): non
      incluso, il contesto resta piccolo; da valutare se emergono domande che lo richiedono.

#### Revisione 2026-10 — azioni a bottone con contesto deterministico (da implementare)

Decisione presa con l'utente: la **chat libera non fa mai function calling** e usa solo il
contesto leggero già implementato (obiettivo, target, oggi, piano). Lo storico lungo passa
solo da **bottoni fissi in chat**, ognuno con un costruttore di contesto dalla finestra e dal
formato fissi: è l'app a decidere quali dati escono, non il modello. Una richiesta Gemini per
azione (nessun costo extra di quota). **Nessuna scrittura nel database**: il Coach risponde in
chat in Markdown con la nuova scheda/alimentazione/ricette e l'utente le aggiunge a mano.

- Il tocco del bottone è il consenso per quell'azione, con anteprima di cosa viene inviato.
- Soglia minima di dati per abilitare il bottone; sotto soglia il bottone è disabilitato e
  spiega cosa manca, proponendo di descrivere a mano a Gemini livello e obiettivo in chat.
- Aggregazione a tabelle compatte (CSV con legenda), medie solo sui giorni con diario
  registrato e numero di giorni registrati dichiarato nel testo.
- Nella scheda si passano i nomi degli esercizi realmente usati, con l'istruzione di restare
  su quelli, così l'utente li ritrova nel catalogo.

- [x] **2026-10** 8a: `CoachHistory` (`lib/services/coach_history.dart`, test in
      `test/coach_history_test.dart`): finestra 90 giorni, funzioni pure `gate*`/`build*` +
      `load*`/`*Gate` da DB. Soglie: scheda ≥ 6 giorni con lavoro *confermato* (non
      conta le sessioni create e mai svolte); alimentazione = profilo + peso +
      `questionarioCompletato` (il diario non blocca: se ≥ 14 giorni registrati si
      aggiungono aderenza e peso, altrimenti il testo dice che è scarso e di non usarlo);
      ricette = piano con almeno un pasto. Restrizioni alimentari scritte come DIVIETI
      ASSOLUTI, target kcal/macro come valori FISSI. Medie solo sui giorni registrati, con il
      numero di giorni dichiarato. La UI riceve `CoachGateReason` (codici), i testi
      localizzati arrivano con i bottoni (8b-8d). Avviso fisso sotto le risposte: verificare
      gli ingredienti rispetto alle proprie allergie.
- [x] **2026-10** 8b: bottone "Ricette dal piano" (`CoachAction.recipes`,
      `lib/services/coach_actions.dart`; chip sopra il campo di testo in `coach_screen.dart`).
      Flusso: gate (dialog con cosa manca) → anteprima del testo esatto che parte verso
      Google → messaggio utente in chat → richiesta con istruzioni+contesto accodati al
      system prompt (sostituiscono lo snapshot generico, non dipendono dal toggle) → risposta
      con avviso fisso sulle allergie. Il guardrail off-topic non si applica (testo scritto
      dall'app); niente "Riprova" sugli errori delle azioni (si tocca di nuovo il bottone).
      Il contesto non è persistito: le domande di follow-up vedono solo la risposta nella
      cronologia. **Da provare su device con chiave reale**: le grammature delle ricette
      coincidono col piano?
- [ ] 8c: bottone "Genera nuova alimentazione" (variante del piano esistente, kcal/macro
      calcolati dall'app, `piano_service`)
- [ ] 8d: bottone "Genera nuova scheda" (storico 3 mesi, livello, obiettivo)
- [ ] Rivedere il ruolo del toggle `coachShareData`: resta solo per la chat libera

---

## Riferimenti

- `ricerca_modello_ai_locale.md` — confronto modelli, raccomandazione RAG-first, avvertimento legale
- [flutter_gemma (pub.dev)](https://pub.dev/packages/flutter_gemma)
- [flutter_gemma — On-device LLMs for Flutter](https://fluttergemma.dev/)
- [flutter_gemma_rag_qdrant — RAG su mobile](https://github.com/DenisovAV/flutter_gemma/blob/main/web/rag/README.md)
- [Qwen3 (GitHub, QwenLM)](https://github.com/qwenLM/qwen3) — licenza Apache 2.0 su tutta la famiglia, incluse 0.6B/1.7B
- [Gemma Terms of Use](https://ai.google.dev/gemma/terms) — Prohibited Use Policy e diritto di revoca, ancora validi per Gemma 3n/Gemma 3
- [Gemma 4: Expanding the Gemmaverse with Apache 2.0 — Google Open Source Blog](https://opensource.googleblog.com/2026/03/gemma-4-expanding-the-gemmaverse-with-apache-20.html) — rilascio aprile 2026, Apache 2.0, ma taglia minima E2B resta in classe ~2GB
- `evolutiva_esercizi.md` — pattern seed/contenuto curato a mano già in uso in Plico (preset allenamento)
- [Gemini API — Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) — quote free tier per progetto, Fase 7. **Aggiornamento 2026-09**: questa pagina non pubblica più una tabella fissa RPM/RPD per modello, rimanda alla dashboard personale su AI Studio (`aistudio.google.com/rate-limit`) — il numero "1.500/giorno" usato in `GeminiQuota.dailyLimit` (`lib/services/gemini_quota.dart`) **non è più riverificabile con certezza** con una fonte ufficiale unica: fonti terze concordano su un taglio del free tier nel tempo ma divergono sul numero esatto (250/giorno per Gemini 2.5 Flash secondo alcune, tagli fino a ~20/giorno riportati per altri modelli) — vedi fonti sotto. Il vero backstop resta comunque il 429 reale di Google (`GeminiErrorType.quotaExceeded`, gestito), il contatore locale è solo un avviso preventivo, non l'unica protezione.
- [Google AI Studio](https://aistudio.google.com) — dove l'utente genera la propria API key gratuita per Fase 7
- [Gemini API — generateContent REST reference](https://ai.google.dev/api/generate-content) — endpoint usato in Fase 7, chiamata diretta senza SDK
- [Firebase AI Logic — pricing/billing](https://firebase.google.com/docs/ai-logic/pricing) — motivo per cui `firebase_ai` non va usato in Fase 7 (quota sul progetto Firebase di Plico, non dell'utente)
- [Gemini 503 "The model is overloaded" — retries that work and when to stop, Kunavo](https://kunavo.com/guides/gemini-api-model-overloaded) — un 503 è capacità server condivisa tra tutti gli utenti (free e a pagamento), diverso dal 429 (quota per-progetto): non si risolve passando a pagamento, solo con retry/backoff o un modello meno congestionato
- [5 Methods to Resolve Gemini API Error High Demand 503, Apiyi.com](https://help.apiyi.com/en/gemini-api-high-demand-503-error-solution-guide-en.html) — un modello appena rilasciato e molto richiesto satura più spesso di uno consolidato
- [What's new in Gemini 3.8 Flash — Google AI for Developers](https://ai.google.dev/gemini-api/docs/latest-model) — conferma che l'alias `gemini-flash-latest` punta oggi (2026-09) a Gemini 3.8 Flash, motivo del cambio a un modello fisso sopra (`gemini-2.5-flash`, poi `gemini-3.6-flash` dopo il 404 — vedi nota inline sulla REST call)
- [Models — Gemini API, Google AI for Developers](https://ai.google.dev/gemini-api/docs/models) — conferma che Gemini 2.5 Flash è ancora un modello disponibile/stabile
- [Gemini API Rate Limits 2026 — AI Prompt Generator Hub](https://aipromptshub.co/limits/gemini-rate-limits-2026) — fonte terza (non ufficiale) sui numeri free tier attuali, divergente da altre fonti — vedi nota sopra
