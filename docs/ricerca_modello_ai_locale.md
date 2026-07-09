# Ricerca — Modello AI locale per consigli allenamento/nutrizione

> Ricerca preliminare (luglio 2026) per un eventuale assistente AI on-device, limitato
> ai domini allenamento e nutrizione, da integrare in un progetto ad hoc separato da
> Plico. Nessuna implementazione ancora avviata — questo documento è solo il punto di
> partenza per quando quel progetto verrà creato.

---

## Raccomandazione

**Gemma 3n E2B (o, più leggero, Gemma 3 1B) tramite il pacchetto Flutter `flutter_gemma`**,
con **RAG on-device come meccanismo primario di restrizione al dominio** (non il
fine-tuning, che va aggiunto solo in un secondo momento se necessario).

## Confronto modelli compatti (mobile-ready)

| Modello | Parametri | RAM richiesta | Licenza | Quando ha senso |
|---|---|---|---|---|
| **Gemma 3n E2B** | ~5B "grezzi", footprint effettivo ~2B (architettura MatFormer) | ~2GB | Gemma ToU (uso commerciale permesso, revocabile, non usabile per addestrare modelli concorrenti) | Consigliato: assistente conversazionale, gira su quasi tutti gli smartphone recenti |
| **Gemma 3 1B** | 1B | ~4GB | Gemma ToU | Alternativa più leggera/prevedibile, meno "intelligente" |
| **Gemma 3 270M** | 270M | poche centinaia di MB | Gemma ToU | Solo per task ristretti e templati (classificazione, estrazione, routing) — progettato da Google esplicitamente per essere fine-tunato su un compito stretto, non per fare da chatbot generalista |
| **Qwen3 1.7B / 0.6B** | 0.6-1.7B | simile ai Gemma equivalenti | **Apache 2.0** (nessuna clausola di revoca, nessun limite) | Se si vuole la licenza più pulita possibile per un'app commerciale |
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
