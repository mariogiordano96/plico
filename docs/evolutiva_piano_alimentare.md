# Evolutiva — Generatore Piano Alimentare

## Idea

L'utente risponde a un questionario sulle sue preferenze alimentari. L'app genera una **lista giornaliera di alimenti con grammature** che soddisfa i suoi macro target calcolati dal TDEE. Per ogni alimento è disponibile una lista di alternative nutritivamente equivalenti con le grammature ricalcolate — l'utente sceglie ogni giorno cosa mangiare in base a ciò che ha disponibile.

---

## Concetto chiave — alternative equivalenti

Il piano non dice "mangia pollo a pranzo". Dice:

```
Proteina principale
  → 180g pollo petto       (40g P · 189 kcal)
     oppure 180g tacchino
     oppure 150g manzo
     oppure 3 uova + 100g albumi

Carboidrato
  → 120g riso
     oppure 110g pasta
     oppure 130g farro
     oppure 100g pane integrale

Verdura
  → 200g zucchine
     oppure 200g spinaci
     oppure 150g broccoli

Grasso
  → 15g olio d'oliva
     oppure 30g avocado
     oppure 15g frutta secca

Latticino / extra proteina
  → 200g yogurt greco
     oppure 150g fiocchi di latte
```

Le grammature delle alternative non sono fisse: vengono ricalcolate per mantenere lo stesso contributo in kcal e macro rispetto all'alimento principale. L'utente ha un piano unico ma con libertà di sostituzione quotidiana.

---

## Flusso utente

1. **Accesso** — dall'home o dal profilo, sezione "Il mio piano"
2. **Questionario** — l'utente esprime preferenze su un set di alimenti
3. **Generazione** — l'app compone il piano con le alternative
4. **Visualizzazione** — lista alimenti + grammature + alternative espandibili
5. **Importa nel diario** — tap su un alimento (o un'alternativa) per aggiungerlo al diario del giorno con la quantità precompilata

---

## Questionario — struttura

Diviso in 3 blocchi sequenziali con progress bar.

### Blocco 1 — Restrizioni dietetiche
- Sei vegetariano / vegano?
- Hai intolleranze? (lattosio, glutine, frutta secca)
- Eviti qualcosa per scelta? (carne rossa, pesce, uova, latticini)

### Blocco 2 — Preferenze per categoria
Alimenti raggruppati per categoria. L'utente seleziona MI PIACE / NON MI PIACE / INDIFFERENTE.

| Categoria | Esempi |
|---|---|
| Cereali | Riso, pasta, avena, pane integrale, farro |
| Proteine animali | Pollo, tacchino, manzo, uova, tonno, salmone, merluzzo |
| Proteine vegetali | Lenticchie, ceci, tofu, fagioli neri |
| Latticini | Yogurt greco, fiocchi di latte, mozzarella, parmigiano |
| Verdure | Spinaci, zucchine, broccoli, pomodori, carote, insalata |
| Frutta | Banana, mela, frutti di bosco, arancia |
| Grassi buoni | Avocado, olio d'oliva, frutta secca |

### Blocco 3 — Struttura preferita
- Quanti pasti al giorno? (3 / 4 / 5) — serve solo per suggerire come distribuire la lista, non per strutturare il piano
- Fai uno spuntino post-allenamento? — per capire se serve una quota proteica extra isolata

---

## Logica di generazione

### Step 1 — Calcolo quote macro per slot alimentare
I macro giornalieri (da TDEE) vengono distribuiti su slot funzionali, non su pasti:
- **Proteina principale** — fonte proteica primaria (carne, pesce, uova, legumi)
- **Carboidrato** — fonte glucidica primaria (cereali, tuberi)
- **Verdura** — fibra e micronutrienti, apporto calorico secondario
- **Grasso** — fonte lipidica (olio, avocado, frutta secca)
- **Extra proteina** — latticino o secondo apporto proteico (yogurt, fiocchi)

### Step 2 — Selezione alimento principale per slot
Per ogni slot si sceglie l'alimento preferito dall'utente con il profilo macro più adatto:
- Proteina principale → alimento con il miglior rapporto P/kcal tra i preferiti
- Carboidrato → alimento con prevalenza di carboidrati e basso indice lipidico
- ecc.

Si calcola la **grammatura** per colpire la quota macro assegnata allo slot.

### Step 3 — Calcolo alternative
Per ogni alimento principale si cercano gli altri alimenti della stessa categoria tra i preferiti dall'utente. Per ognuno si ricalcola la grammatura in modo che il contributo in kcal e macro sia equivalente all'alimento principale:

```
grammi_alternativa = (macro_target_slot / macro_per_100g_alternativa) * 100
```

Se l'alternativa ha un profilo macro molto diverso (es. manzo vs pollo — più grassi), si aggiusta anche la quota grasso del piano per compensare.

### Step 4 — Verifica finale
Si sommano tutti gli slot e si verifica che il totale rientri nei target:
- kcal ± 50 kcal
- proteine ± 5g
- grassi ± 5g
- carboidrati ± 10g

Se fuori tolleranza, si aggiusta la grammatura dello slot carboidrato (il più flessibile).

---

## Modello dati

```
UserFoodPreferences
  - restrizioni: List<String>        // "vegetariano", "no_lattosio", ecc.
  - preferiti: List<String>          // offCode o nome alimento
  - nonGraditi: List<String>
  - numPasti: int
  - haSpuntinoPostWo: bool

MealPlan
  - id
  - dataCreazione
  - slots: List<PlanSlot>
  - kcalTotali, proteineTotali, grassiTotali, carbsTotali

PlanSlot
  - tipo: SlotTipo (proteina, carboidrato, verdura, grasso, extra)
  - principale: PlanFood
  - alternative: List<PlanFood>

PlanFood
  - nome
  - quantitaG
  - kcal, proteine, grassi, carboidrati (calcolati sulla quantità)
```

---

## UI — schermate principali

### Schermata piano
- Header con data generazione + pulsante "Rigenera"
- Lista slot verticale
- Ogni slot mostra l'alimento principale con grammatura e macro
- Freccia / chip "N alternative" → espande e mostra le varianti con le loro grammature
- Pulsante "Aggiungi al diario" su ogni alimento / alternativa

### Schermata questionario
- Progress bar "1 di 3", "2 di 3", "3 di 3"
- Un blocco per volta con transizione animata
- Bottone "Salta" per le domande facoltative
- "Modifica preferenze" accessibile dal profilo in qualsiasi momento → rigenera il piano

---

## Considerazioni aperte

- **Ricalcolo automatico** — se l'utente aggiorna peso o obiettivo nel profilo, il piano viene marcato come "obsoleto" e viene proposto di rigenerarlo.
- **Conflitti di sostituzione** — se un'alternativa ha un profilo macro molto diverso (es. salmone vs pollo: più grassi), il piano deve aggiustare gli altri slot per compensare, non ignorare la differenza.
- **Caso limite: poche preferenze** — se l'utente ha indicato pochi alimenti graditi, il piano potrebbe avere alternative insufficienti. Gestire con un messaggio "aggiungi altri alimenti preferiti per avere più varietà".

---

## Strategia database alimenti

### Fonte scelta: CREA — BDA (Banca Dati di Composizione degli Alimenti)
Sito di riferimento: https://www.alimentinutrizione.it

Il CREA (Centro di Ricerca Alimenti e Nutrizione) è l'ente italiano autoritativo per la composizione nutrizionale degli alimenti. I dati coprono ~900 alimenti italiani con oltre 120 nutrienti, basati per l'80% su studi sperimentali originali. È la fonte più precisa disponibile per il mercato italiano.

### Perché non le alternative
- **Open Food Facts** — dati user-generated, macros variabili per lo stesso alimento generico. Non affidabile per calcoli di grammatura precisi.
- **USDA FoodData Central** — API aperta ma nomi in inglese e valori calibrati su alimenti americani.
- **CREA via API/download** — il sito non offre API né export. Accesso solo manuale con obbligo di attribuzione.

### Come procediamo
Compilazione manuale una-tantum: si consultano le schede CREA per i ~50 alimenti selezionati e i valori vengono hardcoded nel progetto come file JSON con attribuzione obbligatoria.

**Attribuzione da includere nell'app:** `Dati nutrizionali: CREA — Banca Dati di Composizione degli Alimenti`

### Alimenti da raccogliere (~50 voci)

| Slot | Alimenti |
|---|---|
| Proteine animali (12-15) | Petto di pollo, petto di tacchino, manzo magro, lonza di maiale, uova intere, albume, tonno al naturale, salmone, merluzzo, gamberetti, prosciutto crudo, bresaola |
| Proteine vegetali (6-8) | Lenticchie, ceci, fagioli borlotti, fagioli neri, tofu, tempeh, edamame |
| Cereali / carboidrati (8-10) | Riso bianco, riso integrale, pasta di semola, pasta integrale, avena, farro, orzo, pane integrale, patata, patata dolce |
| Verdure (8-10) | Spinaci, zucchine, broccoli, pomodori, carote, insalata mista, peperoni, fagiolini, cavolfiore, cetrioli |
| Grassi (5-6) | Olio extravergine d'oliva, avocado, mandorle, noci, burro di arachidi |
| Latticini / extra proteina (6-8) | Yogurt greco 0%, fiocchi di latte, mozzarella, ricotta, parmigiano, latte parzialmente scremato |

### Campi da raccogliere per ogni alimento (valori per 100g)
- kcal
- proteine (g)
- grassi totali (g)
- carboidrati disponibili (g)
- fibra (g) — opzionale, utile per future feature

### Prossimo passo
Raccolta dati: consultare le schede su alimentinutrizione.it per ogni alimento della lista e compilare il JSON.
