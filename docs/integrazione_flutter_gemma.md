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
- **Qwen3 1.7B come modello di default**, **Qwen3 0.6B come fallback** su device con RAM
  limitata (più leggero ancora del default) — footprint di entrambi nell'ordine delle
  centinaia di MB, coerente con l'impostazione di sezione 5.1
- **Italiano**: Qwen3 dichiara supporto multilingue su 100+ lingue, italiano incluso
  esplicitamente nella lista ufficiale, anche sulle taglie piccole (0.6B/1.7B, tramite
  distillazione "strong-to-weak" dai modelli Qwen3 più grandi). Il supporto dichiarato
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
| Piano alimentare attivo | `getMealPlan()` | "Cosa devo mangiare oggi secondo il piano?" |
| Volume settimanale per gruppo muscolare | `getWeeklyVolumeByMuscleGroup(weekStart)` | "Sto allenando abbastanza le gambe questa settimana?" |
| Impostazioni/obiettivo TDEE | `getAppSettings()` | "Qual è il mio obiettivo calorico attuale?" |

> Nessun tool con effetti collaterali in v1 (niente `save*`/`add*`/`delete*`): coerente con
> la decisione "sola lettura" di questo documento.

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

- **Punto di ingresso**: le 5 tab esistenti (Home/Diario/Allenamento/Progressi/TDEE) sono
  già piene — niente nuovo tab, un FAB globale o un'icona in AppBar
- **Onboarding alla prima apertura**: cosa può e non può fare l'assistente, disclaimer "non
  sostituisce un professionista" (coerente col guardrail di sezione 3.4)
- **Indicatore di stato**: streaming della risposta + eventuale stato "sto consultando i
  tuoi dati" quando è in corso una function call, per non far percepire l'attesa come un
  blocco
- **Cronologia**: almeno la sessione corrente in memoria; persistenza multi-sessione tra
  riavvii è una rifinitura successiva, non bloccante per l'MVP

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
- [ ] Scaricare/testare Qwen3 1.7B (default) e Qwen3 0.6B (fallback) su device reale
- [ ] Verificare qualità delle risposte in italiano su domande di dominio reali (non solo
      fidarsi del supporto multilingue dichiarato, sezione 2)
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
