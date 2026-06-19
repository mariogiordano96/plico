# Normalizzazione Nomi Alimenti — Database CREA

> Il database contiene 906 voci con nomi tecnici CREA pensati per ricercatori,
> non per utenti che cercano "petto di pollo" sul telefono. Questo documento
> definisce le convenzioni di normalizzazione e cataloghie i casi problematici.

---

## Problemi rilevati

### 1. Nomi tecnico-scientifici incomprensibili

Nomi che nessun utente userebbe mai in una ricerca:

| Nome attuale | Problema |
|---|---|
| `Bovino adulto o vitellone, tagli anteriori, crudo` | Classificazione macelleria, non nome d'uso comune |
| `Bovino adulto o vitellone, copertina di sotto, copertina di spalla, sottospalla e collo, crudo` | 10 parole per un taglio di carne |
| `Melù o pesce molo` | Nessuno cerca "melù" |
| `Uova di gallina, intero , cotto, alla coque o sodo` | Spazio doppio, eccessivamente verboso |
| `Bufalo, solo tessuto muscolare, crudo` | "Solo tessuto muscolare" non è un nome |
| `Cavallo, tessuto muscolare e grasso, crudo` | Idem |

### 2. Prefisso categoria ripetuto nel nome

Il campo `categoria` esiste già — ripeterlo nel nome è ridondante e appesantisce la ricerca:

| Nome attuale | Categoria | Problema |
|---|---|---|
| `Bevanda alcolica, Birra chiara` | Bevande | "Bevanda alcolica" è ridondante |
| `Bevanda alcolica, Vino da pasto rosso` | Bevande | Idem |
| `Bevanda alcolica, Grappa` | Bevande | Idem |
| `Formaggio molle da tavola` | Formaggi | "Da tavola" non aggiunge informazione utile |
| `Minestre in scatola, crema di pomodori` | Piatti pronti | "In scatola" è ridondante |

### 3. Eccessiva granularità — varianti irrilevanti per il tracking

CREA distingue varianti che per il tracking calorico sono praticamente equivalenti
e che l'utente non saprà mai distinguere:

```
Mele, fresche, annurche
Mele, fresche, deliziose
Mele, fresche, golden
Mele, fresche, granny smith
Mele, fresche, imperatore
Mele, fresche, renette
→ L'utente cerca "Mela". Punto.

Arance bionde, fresche
Arance Valencia, fresche
Arance Washington Navel, fresche
Arance rosse, fresche
Arance Moro, fresche
Arance Sanguinello, fresche
Arance Tarocco, fresche
→ L'utente cerca "Arancia".

Prosciutto crudo, di Modena DOP
Prosciutto crudo, di Modena DOP, sgrassato
Prosciutto crudo di montagna
Prosciutto crudo DOP, di Parma
Prosciutto crudo, di Parma DOP, sgrassato
Prosciutto crudo, di Pietraroja
Prosciutto crudo, di San Daniele DOP
... (8 varianti)
→ Il tracking non richiede di sapere se è DOP di Parma o di San Daniele.
```

### 4. Stato di preparazione implicito o incoerente

Alcune voci specificano lo stato, altre no, creando incoerenza nella ricerca:

```
Spinaci, crudi            ← esplicito
Spinaci, cotti, bolliti   ← esplicito
Lattuga, fresca           ← "fresca" implica cruda ma non è standard
Indivia, fresca           ← idem
Rughetta o rucola, fresca ← "o rucola" è un alias, non parte del nome
```

### 5. Alias nel nome anziché come campo separato

```
Merluzzo o nasello              → alias nel nome
Rughetta o rucola, fresca       → alias nel nome
Sgombro o maccarello            → alias nel nome
Melù o pesce molo               → alias nel nome
Loti o kaki, freschi            → alias nel nome
Tarassaco o dente di leone      → alias nel nome
```

L'alias è utile per la ricerca ma non dovrebbe essere parte del nome visualizzato.

### 6. Capitalizzazione incoerente

```
Aglio Rosso di Castelliri       ← Maiuscolo
Radicchio rosso di Treviso IGP  ← Misto
Mozzarella di bufala campana DOP ← DOP maiuscolo
Yogurt greco, 0% lipidi         ← Minuscolo
Uova di gallina, intero , cotto ← Spazio prima della virgola
```

### 7. Piatti pronti CREA — utili ma con nomi ridondanti

```
Pasta al sugo di pomodoro
Pasta al ragù alla bolognese
Pasta al pesto alla genovese
Riso al sugo di pomodoro
...
```
Questi piatti composti sono utili ma andrebbero rinominati in modo più conciso
e spostati in una categoria "Piatti pronti / Ricette".

---

## Convenzioni di normalizzazione

### Regola 1 — Forma base: `Nome principale, [qualificatore]`

```
Nome principale → nome comune italiano, singolare, minuscolo
Qualificatore   → stato (crudo/cotto), metodo cottura, variante rilevante
```

**Esempi:**
```
Petto di pollo, crudo
Petto di pollo, cotto
Riso bianco, crudo
Riso bianco, cotto
Salmone, fresco
Salmone, affumicato
```

### Regola 2 — No prefisso categoria nel nome

Il campo `categoria` già classifica l'alimento. Il nome non deve ripeterlo.

```
❌ Bevanda alcolica, Birra chiara    →  ✅ Birra chiara
❌ Minestre in scatola, crema di pomodori  →  ✅ Crema di pomodori
❌ Formaggio molle da tavola  →  ✅ (valutare se mantenere o unire ad altra voce)
```

### Regola 3 — Alias nel campo `alias`, non nel nome

Aggiungere un campo `alias: List<String>` in `FoodItem` per la ricerca fuzzy:

```json
{
  "nome": "Merluzzo",
  "alias": ["nasello", "baccalà"],
  "categoria": "Pesce"
}
```

In questo modo la ricerca trova "nasello" ma la voce si chiama "Merluzzo".

### Regola 4 — Accorpare le varianti irrilevanti per il tracking

Se le differenze caloriche tra varianti sono < 5%, accorparle in una voce unica
con i valori medi. Mantenere solo le varianti con differenze significative.

```
❌ Mele, annurche / Mele, golden / Mele, granny smith / ...
✅ Mela (media varietà)

❌ Arance bionde / Arance Valencia / Arance Sanguinello / ...
✅ Arancia (media varietà)

❌ 8 varianti di prosciutto crudo DOP
✅ Prosciutto crudo (media)
   Prosciutto crudo, sgrassato
```

**Eccezione:** mantenere separati crudo/cotto perché le kcal cambiano significativamente.

### Regola 5 — Stato di preparazione esplicito e consistente

| Stato | Label da usare |
|---|---|
| Non cotto, fresco | `, crudo` |
| Cotto in acqua | `, cotto` |
| Cotto al forno | `, al forno` |
| Cotto in padella | `, in padella` |
| Affumicato | `, affumicato` |
| Conservato sott'olio | `, sott'olio` |
| Conservato in salamoia | `, in salamoia` |
| Surgelato (non cotto) | `, surgelato` |
| Secco/disidratato | `, secco` |
| In scatola | `, in scatola` |

`fresco` da solo è ambiguo — sostituire con `, crudo` per alimenti che possono
essere cucinati, mantenerlo solo per frutte/verdure dove è atteso.

### Regola 6 — Nomi in minuscolo, eccezioni per nomi propri e DOP/IGP

```
✅ petto di pollo, crudo
✅ Parmigiano Reggiano DOP
✅ Bresaola della Valtellina IGP
✅ Prosciutto di Parma DOP
❌ Pollo, Petto, Crudo
```

---

## Mappa di normalizzazione — esempi prioritari

### Carni

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Bovino adulto o vitellone, fesa, crudo` | `Manzo, fesa, crudo` | |
| `Bovino adulto o vitellone, filetto, crudo` | `Manzo, filetto, crudo` | |
| `Bovino adulto o vitellone, tagli anteriori, crudo` | `Manzo, tagli anteriori, crudo` | |
| `Bovino adulto o vitellone, copertina di sotto, copertina di spalla, ...` | `Manzo, spalla e collo, crudo` | Accorpare |
| `Vitello, filetto, crudo` | `Vitello, filetto, crudo` | OK |
| `Maiale, bistecca, crudo` | `Maiale, bistecca, cruda` | |
| `Pollo, petto, crudo` | `Petto di pollo, crudo` | Forma più naturale |
| `Pollo, petto, cotto, in padella` | `Petto di pollo, cotto` | |
| `Pollo, intero, con pelle, cotto, al forno` | `Pollo arrosto, con pelle` | |
| `Tacchino, fesa, crudo` | `Fesa di tacchino, cruda` | |

### Pesce

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Acciuga o alice` | `Acciuga` | alias: alice |
| `Merluzzo o nasello` | `Merluzzo` | alias: nasello |
| `Merluzzo o nasello, surgelato` | `Merluzzo, surgelato` | |
| `Merluzzo o nasello, baccalà, secco` | `Baccalà, secco` | voce separata |
| `Sgombro o maccarello` | `Sgombro` | alias: maccarello |
| `Melù o pesce molo` | `Melù` | alias: pesce molo |
| `Tonno in salamoia, sgocciolato` | `Tonno al naturale` | nome d'uso comune |
| `Tonno sott'olio, sgocciolato` | `Tonno sott'olio` | |

### Uova

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Uova di gallina, intero` | `Uovo intero, crudo` | |
| `Uova di gallina, intero , cotto, alla coque o sodo` | `Uovo, sodo` | |
| `Uova di gallina, intero, cotto, a frittata o strapazzato` | `Uovo, strapazzato` | |
| `Uova di gallina, albume` | `Albume d'uovo` | |
| `Uova di gallina, tuorlo` | `Tuorlo d'uovo` | |

### Latticini

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Latte di vacca, pastorizzato, intero` | `Latte intero` | |
| `Latte di vacca, pastorizzato, parzialmente scremato` | `Latte parzialmente scremato` | |
| `Latte di vacca, pastorizzato, scremato` | `Latte scremato` | |
| `Latte di vacca, UHT, intero` | `Latte intero UHT` | |
| `Yogurt, da latte intero` | `Yogurt intero` | |
| `Yogurt, 0% lipidi` | `Yogurt magro` | |
| `Yogurt greco, da latte intero` | `Yogurt greco intero` | |
| `Yogurt greco, 0% lipidi` | `Yogurt greco 0%` | |
| `Mozzarella di vacca` | `Mozzarella` | |
| `Mozzarella di bufala` | `Mozzarella di bufala` | |
| `Fiocchi di formaggio magro` | `Fiocchi di latte` | nome d'uso comune |
| `Parmigiano Reggiano DOP` | `Parmigiano Reggiano` | DOP implicito |

### Verdure

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Spinaci, crudi` | `Spinaci, crudi` | OK |
| `Spinaci, cotti, bolliti` | `Spinaci, cotti` | "bolliti" ridondante |
| `Zucchine, crude` | `Zucchine, crude` | OK |
| `Zucchine, cotte, bollite` | `Zucchine, cotte` | |
| `Zucchine chiare` | **unire a** `Zucchine, crude` | variante irrilevante |
| `Lattuga, fresca` | `Lattuga` | |
| `Lattuga, a cappuccio, fresca` | `Lattuga, cappuccio` | |
| `Lattughino, fresco` | `Lattughino` | |
| `Rughetta o rucola, fresca` | `Rucola` | alias: rughetta |
| `Tarassaco o dente di leone, fresco` | `Tarassaco` | alias: dente di leone |
| `Loti o kaki, freschi` | `Cachi` | alias: loti |
| `Cicoria, witloof o indivia belga, cruda` | `Indivia belga` | alias: witloof |

### Frutta

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Mele, fresche, senza buccia` | `Mela (media)` | accorpare le varianti |
| `Mele, fresche, golden` | eliminare | accorpata |
| `Mele, fresche, granny smith` | eliminare | accorpata |
| `Mele, fresche, annurche` | eliminare | accorpata |
| `Arance, fresche` | `Arancia (media)` | accorpare le 7 varianti |
| `Banane, fresche` | `Banana` | |
| `Kiwi, freschi` | `Kiwi` | |
| `Avocado, fresco` | `Avocado` | |

### Cereali e legumi

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Riso, brillato` | `Riso bianco, crudo` | "brillato" non è termine comune |
| `Riso, brillato, cotto, bollito` | `Riso bianco, cotto` | |
| `Pasta di semola` | `Pasta (semola), cruda` | |
| `Pasta di semola, cotta, bollita` | `Pasta (semola), cotta` | |
| `Ceci, secchi, cotti, bolliti` | `Ceci, cotti` | |
| `Ceci, in scatola, scolati` | `Ceci in scatola` | |
| `Lenticchie, secche, cotte, bollite` | `Lenticchie, cotte` | |
| `Lenticchie, in scatola, scolate` | `Lenticchie in scatola` | |

### Bevande alcoliche

| Nome attuale | Nome normalizzato | Note |
|---|---|---|
| `Bevanda alcolica, Birra chiara` | `Birra chiara` | |
| `Bevanda alcolica, Vino da pasto bianco` | `Vino bianco` | |
| `Bevanda alcolica, Vino da pasto rosso` | `Vino rosso` | |
| `Bevanda alcolica, Grappa` | `Grappa` | |
| `Bevanda alcolica, Whisky` | `Whisky` | |

---

## Proposta struttura `FoodItem` aggiornata

```dart
@collection
class FoodItem {
  Id id = Isar.autoIncrement;
  late String nome;              // nome normalizzato visualizzato
  List<String> alias = [];       // termini alternativi per la ricerca
  String? nomeEn;                // per internazionalizzazione (vedi doc i18n)
  late String categoria;
  late String fonte;             // "crea" | "custom"
  late double kcalPer100g;
  late double proteinPer100g;
  late double fatPer100g;
  late double carbsPer100g;
  double? fibraPer100g;
  // ... altri campi esistenti invariati
}
```

La ricerca testuale diventa:
```dart
// Cerca su nome E alias
_isar.foodItems
  .filter()
  .nomeContains(query, caseSensitive: false)
  .or()
  .aliasElementContains(query, caseSensitive: false)
  .findAll();
```

---

## Piano di normalizzazione

Il DB ha 906 voci ma quelle realmente usate dagli utenti nel tracking quotidiano
sono un sottoinsieme molto più piccolo. Strategia in due passate:

### Passata 1 — Alta priorità (alimenti ad alta frequenza d'uso)
Circa 150 voci: carni comuni, pesce comune, uova, latticini, cereali base, legumi base,
verdure comuni, frutta comune, condimenti. Queste coprono >90% dei log reali.

- [ ] Rinominare secondo le convenzioni sopra
- [ ] Aggiungere campo `alias` alle voci con nomi alternativi
- [ ] Accorpare le varianti irrilevanti (varietà di mele, arance, prosciutti DOP)

### Passata 2 — Bassa priorità (voci di nicchia)
Resto del DB: tagli di carne specifici, varietà locali, piatti etnici, frattaglie, ecc.
Si normalizzano in batch con minore priorità, o si nascondono dalla ricerca base
con un flag `mostraInRicercaBase: bool`.

### Implementazione tecnica

La normalizzazione avviene nel file `assets/data/crea_seed.json`:
- Nessuna migrazione Isar necessaria se si aggiorna il seed e si re-esegue il seed
  con un reset del flag `creaSeeded` in `AppSettings`
- In alternativa, aggiungere una funzione `migrationV2_normalizeNames()` che aggiorna
  solo i record esistenti senza cancellare i log dell'utente

> **Attenzione:** `MealEntry.foodNome` è un snapshot del nome al momento del log.
> Le voci storiche nel diario non vengono aggiornate dalla normalizzazione —
> solo i nuovi inserimenti useranno i nomi normalizzati. Comportamento accettabile.

---

## Riferimenti

- [CREA — BDA](https://www.alimentinutrizione.it) — fonte dati originale
- [docs/internazionalizzazione.md](internazionalizzazione.md) — strategia traduzioni nomi alimenti
- [docs/database.md](database.md) — struttura collezione `FoodItem`
