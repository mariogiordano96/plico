# Ricerca — Modello AI locale per consigli allenamento/nutrizione

> Ricerca preliminare (luglio 2026) per un eventuale assistente AI on-device, limitato
> ai domini allenamento e nutrizione. **Due punti superati da `integrazione_flutter_gemma.md`**
> (analisi funzionale completa, con piano di implementazione): l'integrazione avviene
> dentro il codebase di Plico, non in un progetto ad hoc separato come ipotizzato qui
> sotto; e il modello scelto è **Qwen3 1.7B/0.6B**, non Gemma (vedi "Raccomandazione"
> aggiornata più sotto). Il resto — RAG-first, avvertimento legale, confronto modelli —
> resta valido come contesto.

---

## Raccomandazione

> **Aggiornamento — decisione finale**: **Qwen3 1.7B (default) / Qwen3 0.6B (fallback
> leggero)**, non Gemma come raccomandato inizialmente qui sotto. Motivo: **licenza Apache
> 2.0** su tutta la famiglia Qwen3, contro la Gemma Terms of Use che vincola ancora Gemma
> 3n/Gemma 3 (Prohibited Use Policy, diritto di revoca unilaterale). Google ha rilasciato
> **Gemma 4 sotto Apache 2.0** nell'aprile 2026, risolvendo lo stesso problema di licenza,
> ma la sua taglia minima pubblicata (Gemma 4 E2B) resta nella classe di peso pesante
> (~2GB) — Qwen3 offre licenza pulita **e** taglie leggere insieme, per questo la scelta è
> caduta su Qwen3 anche a parità di problema di licenza risolto da entrambi. Dettagli
> completi (incluso supporto italiano verificato, function calling confermato su Qwen3,
> modalità "thinking/non-thinking") in `integrazione_flutter_gemma.md`, sezione 2.
>
> Il pacchetto Flutter resta comunque `flutter_gemma` (il nome non vincola al modello:
> supporta Gemma, Qwen3, Phi-4-mini e altri attraverso lo stesso pacchetto).

Raccomandazione originale (luglio 2026, superata sul modello ma non sull'approccio):
**Gemma 3n E2B (o, più leggero, Gemma 3 1B) tramite il pacchetto Flutter `flutter_gemma`**,
con **RAG on-device come meccanismo primario di restrizione al dominio** (non il
fine-tuning, che va aggiunto solo in un secondo momento se necessario) — quest'ultimo
punto (RAG-first) resta valido indipendentemente dal modello scelto.

## Confronto modelli compatti (mobile-ready)

| Modello | Parametri | RAM richiesta | Licenza | Quando ha senso |
|---|---|---|---|---|
| **Qwen3 1.7B / 0.6B** | 0.6-1.7B | simile ai Gemma equivalenti | **Apache 2.0** (nessuna clausola di revoca, nessun limite) | **✅ Scelto per Plico** — licenza pulita e footprint leggero insieme, italiano confermato nella lista lingue supportate |
| **Gemma 3n E2B** | ~5B "grezzi", footprint effettivo ~2B (architettura MatFormer) | ~2GB | Gemma ToU (uso commerciale permesso, revocabile, non usabile per addestrare modelli concorrenti) | Scartato per Plico (licenza revocabile); resta valido come assistente conversazionale se la licenza non è un problema |
| **Gemma 4 E2B** | ~2B (architettura MatFormer, generazione successiva) | non verificato per questo caso d'uso | **Apache 2.0** (da aprile 2026) | Licenza pulita come Qwen3, ma taglia minima pubblicata resta in classe ~2GB — scartato per Plico solo per il peso, non per la licenza |
| **Gemma 3 1B** | 1B | ~4GB | Gemma ToU | Alternativa più leggera/prevedibile, meno "intelligente" — scartata per la licenza |
| **Gemma 3 270M** | 270M | poche centinaia di MB | Gemma ToU | Solo per task ristretti e templati (classificazione, estrazione, routing) — progettato da Google esplicitamente per essere fine-tunato su un compito stretto, non per fare da chatbot generalista |
| **Phi-4-mini** | 3.8B | ~3GB | Microsoft, permissiva | Miglior ragionamento nella fascia piccola, ma più pesante — rischioso su device Android di fascia bassa |

Dato chiave: **`flutter_gemma` supporta tutti questi modelli** (Gemma, Qwen3, Phi-4-mini,
DeepSeek R1 distillati, SmolLM) attraverso lo stesso pacchetto, formati `.task`/
`.litertlm`, con supporto nativo per **RAG on-device, function calling e GPU
acceleration**. La scelta del modello base non blocca in uno stack diverso — si può
partire con Gemma e cambiare modello dopo senza riscrivere l'integrazione.

## Come restringerlo al dominio — l'ordine conta

1. **RAG + system prompt (farlo per primo, è quasi gratis)**: dare in pasto al modello,
   come contesto recuperato, dati di dominio strutturati (contenuti su allenamento,
   regole di progressione/overload, database alimenti). Il system prompt vincola tono,
   formato e — soprattutto — cosa **rifiutare** (diagnosi infortuni, patologie, disturbi
   alimentari → redirect a un professionista). Vantaggio: se un consiglio è sbagliato si
   corregge il documento RAG all'istante, senza riaddestrare nulla.
2. **LoRA fine-tuning (solo se il punto 1 non basta)**: utile per consistenza di
   stile/formato e per rinforzare i rifiuti su domande fuori scope in modo più affidabile
   del solo prompt. Economico su un modello piccolo (Gemma 3 270M o 1B si fine-tunano in
   minuti/ore su una GPU consumer), ma aggiunge un impegno di manutenzione (dataset,
   retraining a ogni versione) — non partire da qui.

La combinazione dei due (RAG + fine-tuning leggero) batte l'uno o l'altro da solo, ma
per un MVP il solo RAG copre gran parte del bisogno con una frazione dello sforzo.

## Avvertimento non tecnico

Dare consigli su allenamento/nutrizione è un'area sensibile lato responsabilità legale
— indipendentemente dal modello scelto, vale la pena hard-codare (nel system prompt e
possibilmente con un guardrail separato) il rifiuto esplicito di diagnosi mediche,
gestione infortuni e argomenti da disturbo alimentare, con redirect a un professionista.
È una decisione di prodotto più che tecnica, ma incide su quanto "aperto" lasciare il
modello.

## Fonti

- [Best Open-Source LLMs: July 2026 Leaderboard — TECHSY](https://techsy.io/en/blog/best-open-source-llms-2026)
- [The Best Open-Source Small Language Models (SLMs) in 2026 — BentoML](https://www.bentoml.com/blog/the-best-open-source-small-language-models)
- [flutter_gemma — On-device LLMs for Flutter](https://fluttergemma.dev/)
- [flutter_gemma — Flutter package](https://pub.dev/packages/flutter_gemma)
- [Flutter + On-Device AI: Running Small LLMs Without a Cloud Backend (2026 Edition)](https://thejenildgohel.medium.com/flutter-on-device-ai-running-small-llms-without-a-cloud-backend-2026-edition-4fbd568b585f)
- [Introducing Gemma 3 270M: The compact model for hyper-efficient AI — Google Developers Blog](https://developers.googleblog.com/en/introducing-gemma-3-270m/)
- [Own your AI: fine-tune Gemma 3 270M and run it on-device — Google Developers Blog](https://developers.googleblog.com/own-your-ai-fine-tune-gemma-3-270m-for-on-device/)
- [Open Source LLM Comparison Table (2026) — ComputingForGeeks](https://computingforgeeks.com/open-source-llm-comparison/)
- [LLM Customization Cheat Sheet: Fine-Tuning vs. LoRA vs. RAG Explained](https://medium.com/@ramyaravi19/llm-customization-cheat-sheet-fine-tuning-vs-lora-vs-rag-explained-bc43aa713b34)
- [google/gemma-3n-E2B-it — device requirements discussion, Hugging Face](https://huggingface.co/google/gemma-3n-E2B-it/discussions/6)

Fonti aggiunte con la decisione finale (Qwen3, verificate al momento della scelta):

- [Qwen3 (GitHub, QwenLM)](https://github.com/qwenLM/qwen3) — licenza Apache 2.0 su tutta la famiglia, incluse 0.6B/1.7B, supporto multilingue 100+ lingue incluso italiano
- [Gemma Terms of Use](https://ai.google.dev/gemma/terms) — Prohibited Use Policy e diritto di revoca, ancora validi per Gemma 3n/Gemma 3
- [Gemma 4: Expanding the Gemmaverse with Apache 2.0 — Google Open Source Blog](https://opensource.googleblog.com/2026/03/gemma-4-expanding-the-gemmaverse-with-apache-20.html) — rilascio aprile 2026, Apache 2.0, taglia minima E2B
