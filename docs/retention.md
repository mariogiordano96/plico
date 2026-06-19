# Retention — Plico

> Obiettivo: far tornare l'utente il giorno dopo. Il tracking alimentare ha
> un tasso di abbandono altissimo nelle prime 2 settimane. Ogni punto qui sotto
> attacca una causa specifica di drop-off.

---

## 1. Ridurre il friction del tracciamento

La causa #1 di abbandono è che registrare ogni pasto è lento e tedioso.

- ✅ ~~**Pasto rapido da preferiti** — salva combinazioni di alimenti usate spesso ("la mia colazione"), aggiungibili in un tap~~ — implementato (sezione "I tuoi pasti preferiti" nell'aggiunta alimento)
- ✅ ~~**Ripeti pasto di ieri** — copia uno slot del giorno precedente con un tap~~ — implementato
- ✅ ~~**Pasto dal piano** — se hai il piano attivo, suggerisci gli alimenti previsti per quello slot invece di partire da zero~~ — implementato (sezione "Dal tuo piano")
- ✅ ~~**Ricerca più intelligente** — mostra per primi gli alimenti usati di recente, poi i preferiti, poi il database~~ — implementato
- ✅ ~~**Widget iOS/Android** — aggiunta rapida di un pasto dalla schermata home del telefono senza aprire l'app~~ — implementato su entrambe le piattaforme (riepilogo kcal + tap per apertura rapida aggiunta pasto); verificato su device Android e iPhone (iOS 26)
- **Siri / Google Assistant shortcut** — "Hey Siri, ho mangiato una banana" → aggiunta diretta

---

## 2. Loop di rinforzo positivo

L'utente deve sentirsi bene quando apre l'app, non in colpa.

- ✅ ~~**Streak giorni consecutivi** — badge visivo per ogni giorno di registrazione continua; perdere la streak è un forte motivatore a non saltare~~ — implementato
- ✅ ~~**Celebrazione obiettivo calorico** — già implementato; estendere ai macro (proteine, carboidrati, grassi) con animazioni separate~~ — implementato (check visivo su proteine/carboidrati/grassi)
- ✅ ~~**Riepilogo serale** — notifica alle 21:00 "Oggi hai raggiunto il tuo obiettivo per 5 giorni di fila 🔥"~~ — implementato
- ✅ ~~**Grafico andamento peso** — già presente; aggiungere linea di tendenza (media mobile 7gg) per mostrare progressi anche quando il peso oscilla~~ — implementato
- ✅ ~~**Badge traguardi** — primo kg perso, 7 giorni di streak, 30 giorni registrati, obiettivo raggiunto per una settimana intera~~ — implementato

---

## 3. Notifiche intelligenti

Notifiche generiche vengono disabilitate. Quelle contestuali vengono lette.

- ✅ ~~**Promemoria pasto adattivo** — già implementato; migliorare con orari suggeriti basati sullo storico dell'utente ("di solito pranzi alle 13:00")~~ — implementato (suggerimento tap-to-apply dopo 5+ campioni)
- ✅ ~~**Recap mattutino** — "Ieri hai mangiato 1.840 kcal su 2.100. Ottimo lavoro." — rinforzo del giorno prima~~ — implementato
- ✅ ~~**Notifica pesata** — se l'utente non si pesa da X giorni, ricordarglielo (solo se usa il tracking peso)~~ — implementato (soglia 5 giorni)
- ✅ ~~**Notifica streak a rischio** — "Hai registrato ogni giorno per 6 giorni. Vuoi mantenere la streak?" (serale, solo se il giorno non è stato registrato)~~ — implementato

---

## 4. Personalizzazione e senso di progresso

L'utente deve sentire che l'app è "sua" e che sta andando da qualche parte.

- ✅ ~~**Riepilogo settimanale** — ogni lunedì, una card in home con: media kcal, variazione peso, % aderenza al piano, confronto con la settimana precedente~~ — implementato
- ✅ ~~**Insights automatici** — "Tendi a sforare il giovedì sera" / "La tua proteina è costantemente sotto target" — analisi passiva dei pattern~~ — implementato (2 regole: sforamento per giorno della settimana, proteine sotto target)
- ✅ ~~**Calibrazione TDEE dinamica** — se l'utente registra peso + cibo per 2+ settimane, suggerire aggiustamento automatico del TDEE basato sui dati reali~~ — implementato (solo suggerimento informativo, nessun override automatico)
- ✅ ~~**Obiettivo visibile sempre** — mostrare chiaramente quanto manca all'obiettivo peso (es. "-4.2 kg all'obiettivo") in home~~ — implementato

---

## 5. Social e accountability

Anche solo la percezione di essere osservati aumenta la consistenza.

- **Condivisione progressi** — card condivisibile con grafico peso + streak (stile Duolingo/Strava) per Instagram/WhatsApp
- **Sfida con amici** — "Chi mantiene la streak più lunga questa settimana?" — minima infrastruttura, alto impatto
- **Coach virtuale** — feedback testuale settimanale generato dall'AI basato sui dati reali dell'utente ("questa settimana hai mangiato bene ma le proteine erano basse — prova ad aggiungere uno yogurt greco a colazione")

---

## 6. Onboarding e primo "aha moment"

L'utente deve capire il valore entro i primi 3 minuti.

- **Primo pasto guidato** — dopo l'onboarding, mostrare subito come aggiungere un alimento con un tutorial interattivo
- **Pre-popolare il diario** — suggerire "cosa hai mangiato a colazione stamattina?" subito dopo l'onboarding per far sentire l'app già utile
- **Mostrare subito il piano** — se il piano è generato, farlo vedere prima di qualsiasi altra schermata
- **Ridurre i campi obbligatori** — permettere di usare l'app anche senza inserire peso/obiettivo, rimandando la personalizzazione

---

## Priorità suggerita

| Feature | Impatto retention | Sforzo |
|---|---|---|
| ✅ ~~Pasto rapido da preferiti / ripeti ieri~~ | Alto | Medio |
| ✅ ~~Streak giorni consecutivi~~ | Alto | Basso |
| ✅ ~~Riepilogo settimanale in home~~ | Alto | Medio |
| ✅ ~~Notifica streak a rischio~~ | Medio | Basso |
| ✅ ~~Insights automatici sui pattern~~ | Alto | Alto |
| ✅ ~~Widget iOS/Android~~ | Medio | Alto |
| Condivisione progressi | Medio | Medio |
| Coach virtuale AI | Alto | Alto |
