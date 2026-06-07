# Miglioramenti — Plico

## ✅ Completati

- ~~**Onboarding al primo avvio**~~ — 6 step: nome → sesso/nascita → misure → obiettivo → livello attività → tema. Se il peso è inserito, il piano viene auto-attivato alla fine dell'onboarding.
- ~~**Piano Alimentare**~~ — generazione completa con slot macro (proteina, carbo, verdura, grasso, frutta), preferenze utente, restrizioni dietetiche, variante colazione salata/dolce, spuntino post-WO e serale.
- ~~**Peso corporeo con grafico**~~ — ProgressiScreen mostra il grafico peso nel tempo (BodySnapshot) come prima sezione, con filtro temporale 1M/3M/6M/1A/tutto e stat "Ultimo · Variazione · Rilevazioni".
- ~~**Navigazione con bottom bar**~~ — MainScreen con BottomNavigationBar a 4 tab fissi: Home / Diario / Progressi / TDEE. Le card della Home usano tab-switch invece di push.
- ~~**HomeScreen UX**~~ — riorganizzazione gerarchia: greeting personalizzato, hero card Diario con kcal+macro, card Piano Alimentare, rimossa hero card Plicometria.
- ~~**Diario allineato al piano**~~ — `PastoTipo` esteso a 6 valori (aggiunto `postWo` e `spuntinoSerale`); le sezioni appaiono condizionalmente in base alle preferenze utente.
- ~~**Delta trend nelle pesate**~~ — ogni pesata mostra il delta kg rispetto alla precedente con badge verde/rosso.
- ~~**Accesso a Storico Misurazioni**~~ — icona righello in AppBar di ProgressiScreen; rimosso il link dalla Home che era stato perso nel redesign.
- ~~**Dark mode**~~ — già presente al lancio; toggle in HomeScreen e come step dell'onboarding.

---

## Priorità alta

### ~~Storico visivo kcal~~
~~Grafico kcal (e macro) degli ultimi 7/14 giorni dal diario alimentare. Trasforma il diario da registro puntuale a strumento di monitoraggio. Il grafico peso è già presente; manca il grafico kcal che richiede aggregazione di `DailyLog` per data.~~

### Lista della spesa dal piano
Genera una lista della spesa aggregando tutti gli alimenti del piano con le quantità. Riduce il friction tra piano e spesa reale. Prerequisito: piano stabile e usato dall'utente.

### Pasti ricorrenti / preferiti
- Salvataggio di un "pasto" composto da più alimenti (es. "la mia colazione")
- "Ripeti pasto di ieri" per un dato slot
- Riduce il friction del tracciamento quotidiano, causa principale di abbandono

### Aderenza al piano
Schermata o badge: % di pasti del piano effettivamente registrati nel diario. Rinforzo positivo + dato utile per calibrazione futura.

### Feedback raggiungimento obiettivo
Messaggio o colore celebrativo quando la giornata si chiude entro il target calorico e macro. Retention.

### Notifiche promemoria pasti
Notifica opzionale a orari configurabili (es. "hai inserito il pranzo?"). La principale causa di abbandono è dimenticarsi di registrare a metà giornata.

---

## Priorità bassa

### Integrazione Apple Health / Google Fit
Lettura dell'attività fisica per aggiustare il TDEE dinamicamente. Richiede platform channel nativo.

### Export dati
CSV o PDF del diario settimanale/mensile. Utile per chi segue un nutrizionista.

### Ricette
Combinare più alimenti in una ricetta salvata con nome e porzioni. Prerequisito: pasti ricorrenti già implementati.
