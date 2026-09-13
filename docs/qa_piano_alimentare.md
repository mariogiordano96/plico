# QA Piano Alimentare — test di fattibilità real-world

## Idea

`PianoService.generaPiano` è già ben testato **sui numeri**: `test/piano_service_test.dart`
verifica che kcal/macro del piano generato cadano entro tolleranza (±15/20%) su un pugno di
combinazioni fisse obiettivo×livello, che i pesi diminuiscano/aumentino nella direzione
giusta, e che le restrizioni dietetiche escludano le categorie giuste
(`piano_service_restrizioni_test.dart`).

Quello che non è mai stato verificato è se il piano generato **abbia senso per una persona
reale che deve comprarlo e cucinarlo**: grammature assurde o non cucinabili, alimenti
ripetuti nello stesso pasto, comportamento su combinazioni di preferenze estreme (pool quasi
vuoti), piano sempre identico a ogni rigenerazione. Questo doc pianifica una suite di test
più ampia — generazione a matrice di scenari + batteria di assert di fattibilità — per
scoprire questa classe di problemi, distinta da quella (già coperta) di accuratezza
calorica.

---

## Cosa sappiamo già del comportamento attuale (da lettura di `piano_service.dart`)

- **`generaPiano` è completamente deterministico**: nessun uso di `Random`/`dart:math` nel
  file. Stesso profilo + stesse preferenze → stesso identico piano, sempre. Rilevante per la
  Fase 5 sotto: non è un'ipotesi da verificare, è già un fatto.
- Le grammature sono arrotondate a multipli di 5g (`_round5`), uguale per ogni alimento —
  non distingue un alimento "a pezzo" (es. uova) da uno sfuso (riso, pollo).
- `FoodItem` ha già un campo `porzione` (porzione standard CREA, in grammi) — dato
  potenzialmente utile per un arrotondamento più realistico (es. multipli della porzione
  invece di multipli fissi di 5g), non ancora usato in `_buildSlot`/`_round5`.
- Ogni slot ha già `minGrams`/`maxGrams` (clamp), quindi un limite di fattibilità esiste in
  parte — da verificare se i valori attuali sono stretti a sufficienza o solo un clamp
  largo che lascia passare comunque porzioni poco realistiche.

---

## Cosa NON copre il test attuale (il gap da chiudere)

1. **Grammature cucinabili** — quantità troppo piccole (es. 10g di un ingrediente) o troppo
   grandi per una porzione singola, o non arrotondate a un'unità sensata per alimenti "a
   pezzo".
2. **Coerenza compositiva del pasto** — non solo "i macro tornano", ma "ha senso mangiare
   questa combinazione insieme?" (es. lo stesso alimento che appare due volte nello stesso
   pasto tra slot diversi).
3. **Robustezza su preferenze estreme** — utente che segna "non mi piace" quasi tutto,
   vegano + intolleranze multiple + pochi alimenti graditi: oggi non sappiamo se il piano si
   degrada in modo controllato (slot saltato, messaggio esplicito) o produce qualcosa di
   silenziosamente sbagliato (piano vuoto, kcal molto sotto target senza segnalazione).
4. **Varietà tra rigenerazioni** — l'utente ha un solo piano attivo con "Genera piano" a
   richiesta (non un piano diverso ogni giorno, per design — vedi `evolutiva_piano_alimentare.md`).
   Dato che la generazione è deterministica, rigenerare con le stesse preferenze restituisce
   sempre lo stesso piano: è una scelta accettabile o un problema quando l'utente rigenera
   sperando in qualcosa di diverso?
5. **Alternative equivalenti sensate** — le alternative di uno slot (stesso contributo
   macro, grammatura ricalcolata) non sono mai state verificate per assenza di duplicati o
   sovrapposizione con l'alimento principale.

---

## Approccio: generazione a matrice + batteria di assert di fattibilità

Non un test per scenario fisso, ma una funzione che genera N profili sintetici variando
sesso, età, peso, altezza, livello attività, obiettivo, numero pasti, preferenze food e
restrizioni — incluse combinazioni estreme — con un `Random(seed)` fisso per riproducibilità
(stesso seed → stesso eventuale fallimento, non flaky). Si fa girare `generaPiano` su
ciascun profilo e si applica la stessa batteria di assert di fattibilità a tutti.

## Fasi

### Fase 1 — Infrastruttura del generatore di scenari (pianificata)
- [ ] `_randomProfile(Random rng)`: produce combinazioni valide di profilo/preferenze/
      restrizioni, incluse le combinazioni estreme di preferenze (quasi tutto "non mi
      piace", vegano + intollerante lattosio + intollerante glutine, obiettivo aggressivo
      con peso corporeo basso)
- [ ] Loop su un numero fisso di seed (es. 200) che raccoglie i piani generati per ciascuno
- [ ] Primo giro senza assert stringenti: solo verificare stabilità di base — `generaPiano`
      non lancia eccezioni e non restituisce `null` quando i dati minimi ci sono per
      nessuno dei 200 scenari

### Fase 2 — Assert di fattibilità delle grammature (pianificata)
- [ ] Nessuna quantità sotto una soglia minima "cucinabile" per lo slot (valore da
      concordare, non tecnico — vedi "Domande aperte")
- [ ] Nessuna quantità sopra una soglia massima realistica per porzione singola
- [ ] Valutare se usare `FoodItem.porzione` per arrotondare a un multiplo della porzione
      standard invece del fisso 5g attuale, almeno per gli alimenti dove ha senso (es. uova)
      — verificare prima quali alimenti del dataset CREA hanno `porzione` popolata e quanto
      è affidabile come proxy di "unità naturale"

### Fase 3 — Assert di coerenza compositiva (pianificata, ridimensionata)
**Nota**: il piano è dichiaratamente una lista di **fonti** di proteine/carboidrati/grassi
per slot, non una ricetta — "ha senso mangiare questa combinazione insieme?" non è un
criterio applicabile qui (lo sarà per le ricette generate a valle, fuori scope di questo
doc). Restano validi solo i controlli di igiene del dato, non di senso culinario:
- [ ] Nessun `FoodItem` ripetuto due volte nello stesso pasto tra slot diversi
- [ ] Le alternative equivalenti di uno slot non includono l'alimento principale né
      duplicati tra loro
- [ ] Comportamento su slot vuoto (nessun alimento disponibile dopo preferenze+restrizioni)
      verificato esplicitamente: oggi non è chiaro se lo slot viene saltato, il piano
      generato è parziale, o `generaPiano` fallisce — va prima capito cosa succede
      realmente leggendo `_buildSlot`, poi deciso se è il comportamento voluto

### Fase 4 — Assert di rispetto restrizioni su fuzz, non solo casi fissi (pianificata)
- [ ] Su tutti gli N profili generati, nessun alimento di categoria esclusa
      (`excludedByRestrizioni`) appare nel piano finale, incluse le alternative — oggi
      `piano_service_restrizioni_test.dart` lo verifica solo su 1-2 casi fissi, non su una
      matrice ampia di combinazioni di restrizioni

### Fase 5 — Varietà: risolta a livello di chat, non di generazione del piano (decisione presa)
- [x] **Decisione presa**: il piano resta deliberatamente stabile/deterministico — è
      l'ancora dei target macro, non va reso casuale. La varietà "giorno per giorno" che
      mancava non si risolve modificando `generaPiano`, ma con la feature ricette-AI
      pianificata in `integrazione_flutter_gemma.md` (sezione 3.2): l'utente chiede in chat
      "dammi una ricetta con queste grammature" partendo dallo stesso piano stabile, e può
      ottenere proposte diverse a ogni richiesta senza che il piano sottostante cambi.
- [x] Resta comunque vero, e verificato da codice, che `generaPiano` è completamente
      deterministico (nessun `Random`) — nessuna azione da prendere su questo punto,
      documentato qui solo come contesto della decisione sopra.
- [ ] Conseguenza per la Fase 2 di questo doc: le grammature del piano diventano input
      diretto della feature ricette-AI, quindi "grammature cucinabili" non è più solo una
      questione di UX del piano ma un prerequisito di qualità per le ricette generate a
      valle (vedi nota su questo in `integrazione_flutter_gemma.md`, sezione 3.2) — priorità
      della Fase 2 alzata di conseguenza.

### Fase 6 — Report e triage (pianificata)
- [ ] I fallimenti raccolti dagli N scenari vanno categorizzati (bug reale vs soglia di
      test troppo stretta o giudizio nutrizionale non ancora validato) prima di aprire fix,
      stesso principio già seguito nel Blocco 3 di `test_plan.md` — non ogni fallimento del
      test è per forza un bug dell'app
- [ ] Aggiornare questo doc con l'esito di ogni fase superata

---

## Domande aperte

- Le soglie di grammatura "cucinabile" (min/max per slot) sono giudizio nutrizionale, non
  tecnico — da validare con competenza nutrizionale reale prima di trasformarle in assert
  bloccanti, altrimenti si rischia di codificare come "bug" scelte in realtà corrette.
- Quanti alimenti del dataset CREA hanno `porzione` popolata in modo affidabile come "unità
  naturale" (es. un uovo, una fetta)? Da verificare prima di usarla per l'arrotondamento in
  Fase 2 — se la copertura è bassa non vale la complessità.
