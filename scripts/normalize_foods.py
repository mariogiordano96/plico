"""
Normalizza i nomi del database alimenti CREA.
Input:  assets/data/crea_seed.json
Output: assets/data/crea_seed_normalized.json

Regole applicate (in ordine):
  1. Elimina varianti cotte (al forno, in padella, bollito, ecc.) — si pesa sempre a crudo
  2. Rimuovi prefissi categoria ridondanti
  3. Sostituisci nomi tecnici con nomi comuni (lookup RENAMES)
  4. Applica pattern generici residuali
  5. Rimuovi suffisso ", crudo/a/i/e" dai nomi rimasti
  6. Accorpa varianti irrilevanti (varietà frutta, prosciutti DOP, ecc.)
  7. Deduplicazione finale
"""

import json
import re
import copy
from pathlib import Path

ROOT = Path(__file__).parent.parent
INPUT  = ROOT / 'assets/data/crea_seed_backup.json'
OUTPUT = ROOT / 'assets/data/crea_seed.json'

# ---------------------------------------------------------------------------
# Suffissi che indicano una preparazione cotta — queste voci vengono eliminate
# (si pesa sempre a crudo; i valori nutrizionali del crudo sono il riferimento)
# ---------------------------------------------------------------------------
COOKED_SUFFIXES = (
    ", cotto", ", cotta", ", cotti", ", cotte",
    ", al forno", ", in padella", ", bollito", ", bollita",
    ", bolliti", ", bollite", ", allo spiedo", ", arrosto",
    ", al microonde", ", strapazzato", ", sodo", ", fritta",
    ", fritte", ", fritto", ", fritti",
)

# Voci che contengono "cotto" ma nel NOME COMMERCIALE — da NON eliminare
COOKED_WHITELIST = {
    # Salumi (prosciutto cotto è un prodotto, non una preparazione)
    "Prosciutto cotto",
    "Prosciutto cotto, sgrassato",
    "Prosciutto cotto, alta qualità",
    "Prosciutto cotto, alta qualità, sgrassato",
    "Prosciutto cotto, scelto",
    "Prosciutto cotto, scelto, sgrassato",
    "Cotechino, confezionato precotto",
    "Cotechino Modena IGP, cotto",
    "Zampone confezionato, precotto",
    "Zampone Modena IGP, cotto",
    "Wurstel di puro suino, cotto",   # prodotto già pronto
    # Piatti pronti (non hanno versione cruda di riferimento)
    "Minestrone, cotto",
    "Brasato al Barolo",
    "Baccalà alla vicentina",
    "Sugo di pomodoro",
    "Ragù alla bolognese",
    "Pesto alla genovese",
    "Risotto alla parmigiana",
    "Pasta e fagioli",
    "Frittata",
    "Spezzatino di vitellone al vino rosso",
    "Scaloppina di tacchino al limone",
    "Trota al forno",
    "Merluzzo in umido",
    "Pasta al sugo di pomodoro",
    "Pasta al ragù alla bolognese",
    "Pasta al pesto alla genovese",
    "Riso al sugo di pomodoro",
    "Riso al ragù alla bolognese",
    "Riso burro e Parmigiano reggiano",
    "Gnocchi al sugo di pomodoro",
    "Gnocchi al ragù alla bolognese",
    "Gnocchi al pesto alla genovese",
    "Ravioli al burro e salvia",
    "Ravioli al sugo di pomodoro",
    "Polenta al sugo di pomodoro",
    "Polenta al ragù alla bolognese",
    "Alici al forno",
    "Spigola al cartoccio",
    "Sogliola al vino bianco",
    "Frittata prosciutto e formaggio",
    "Pasta cacio e pepe",
    "Pasta burro e parmigiano",
    "Pasta aglio, olio e peperoncino",
    "Alici marinate",
    "Pasta alla carbonara",
    "Pasta alle vongole",
    "Pasta alla amatriciana",
    "Carciofi alla romana",
    "Pomodori al riso",
    "Parmigiana di melanzane",
    "Gateau",
    "Besciamella",
    "Pan di Spagna",
    "Pastiera",
    "Torta di mele",
    "Lasagna",
    "Pasta integrale al sugo di pomodoro",
    "Zucchine grigliate",
    "Riso Cantonese",
    "Pollo all'ananas",
    "Pollo alle mandorle",
    "Maiale in agrodolce",
    "Gamberetti con funghi e bambù",
    "Gelato misto fritto",
    # Tofu: ", sodo" indica la consistenza, non la cottura
    "Tofu, sodo",
    # Conserve (il cotto è parte del processo di conservazione)
    "Mais, dolce, in scatola, sgocciolato",
    "Carne bovina in gelatina, in scatola",
    "Carne bovina pressata, in scatola",
    "Aragosta, bollita",   # non esiste versione cruda pratica
    "Granchio, in scatola",
    "Castagne, arrostite",  # le castagne crude non si mangiano
    "Castagne, bollite",
}

ELIMINATE_CATEGORIES = {
    "Ricette Italiane",
    "Alimenti Etnici",
    "Fast-food a base di carne",
}

def is_cooked(nome_originale: str) -> bool:
    """Restituisce True se la voce è una variante cotta da eliminare."""
    if nome_originale in COOKED_WHITELIST:
        return False
    nome_lower = nome_originale.lower()
    return any(nome_lower.endswith(s) for s in COOKED_SUFFIXES)

# ---------------------------------------------------------------------------
# Lookup: id da ELIMINARE (varianti accorpate in un'altra voce)
# ---------------------------------------------------------------------------
# Varietà di mele → mantenere "Mele, fresche, senza buccia" (rinominata "Mela")
ELIMINATE = {
    "Mele, fresche, annurche",
    "Mele, fresche, deliziose",
    "Mele, fresche, golden",
    "Mele, fresche, granny smith",
    "Mele, fresche, imperatore",
    "Mele, fresche, renette",
    "Mele cotogne, fresche",
    # Varietà di arance → mantenere "Arance, fresche"
    "Arance bionde, fresche",
    "Arance Valencia, fresche",
    "Arance Washington Navel, fresche",
    "Arance rosse, fresche",
    "Arance Moro, fresche",
    "Arance Sanguinello, fresche",
    "Arance Tarocco, fresche",
    # Varietà di pere → mantenere "Pere, fresche, senza buccia"
    "Pere, fresche, Abate Fetel",
    "Pere, fresche, Coscia",
    "Pere, fresche, Kaiser",
    "Pere, fresche, Max-Red Barlett",
    "Pere, fresche, William",
    # Prosciutto crudo: troppe varianti DOP → mantenere "Prosciutto crudo DOP, di Parma" e "sgrassato"
    "Prosciutto crudo, di Modena DOP",
    "Prosciutto crudo, di Modena DOP, sgrassato",
    "Prosciutto crudo di montagna",
    "Prosciutto crudo, di Pietraroja",
    "Prosciutto crudo, di San Daniele DOP",
    "Prosciutto crudo, di San Daniele DOP, sgrassato",
    "Prosciutto crudo, disossato",
    "Prosciutto crudo, disossato, sgrassato",
    "Prosciutto crudo, gambuccio",
    "Prosciutto crudo, Nazionale",
    "Prosciutto crudo, Nazionale, sgrassato",
    # Zucchine: varianti chiare/scure irrilevanti per il tracking
    "Zucchine, chiare",
    "Zucchine chiare, cotte, al vapore",
    "Zucchine chiare, cotte, in padella grigliate",
    "Zucchine, chiare, cotte, al microonde",
    "Zucchine, scure, crude",
    "Zucchine, scure, cotte, al vapore",
    "Zucchine, scure, cotte, in padella grigliate",
    "Zucchine, scure, cotte, al microonde",
    # Aglio varietà locali → mantenere solo "Aglio"
    "Aglio Rosso di Castelliri",
    "Aglio Rosso di Procerno",
    "Aglio Rosso di Sulmona",
    "Aglio Bianco Piacentino",
    # Carciofi varietà locali → mantenere "Carciofi, crudi" e "cotti"
    "Carciofo Romanesco IGP",
    "Carciofo, verde, precoce",
    "Carciofo, violetto, precoce",
    "Carciofo, Spinoso sardo",
    # Radicchio varietà locali → mantenere "Radicchio, rosso" e "verde"
    "Radicchio rosso di Treviso IGP, precoce",
    "Radicchio rosso di Treviso IGP, tardivo",
    "Radicchio variegato di Castelfranco IGP",
    # Lattuga: troppi sinonimi
    "Lattuga, a cappuccio, fresca",
    "Lattuga, da taglio, fresca",
    # Asparagi: varianti poco rilevanti
    "Asparagi di bosco, crudi",
    "Asparagi di campo, crudi",
    "Asparagi di campo, cotti, bolliti",
    # Arance succo varianti
    "Arance bionde succo, fresco",
    "Arance rosse succo, fresco",
    # Uova varianti meno usate e cotte
    "Uova di anatra, intero",
    "Uova di oca, intero",
    "Uova di tacchina, intero",
    "Uova di gallina, intero, congelato",
    "Uova di gallina, intero, in polvere",
    "Uova di gallina, intero , cotto, alla coque o sodo",     # cotto
    "Uova di gallina, intero, cotto, a frittata o strapazzato", # cotto
    "Uova di gallina, tuorlo , cotto, in camicia",
    "Uova di gallina, tuorlo, congelato",
    "Uova di gallina, tuorlo, in polvere",
    # Carni cotte con nomi non standard (sfuggite a is_cooked)
    "Vitello, filetto, cotto in padella",
    "Wurstel di puro suino, cotto",
    # Patate novelle cotte (typo "bollte" sfugge al pattern)
    "Patate novelle, cotte, al microonde",
    "Patate novelle, cotte, bollte",
    # Pesce cotto
    "Trota surgelata, cotta, al microonde",
    "Trota surgelata, cotta, in forno",
    "Merluzzo o nasello, surgelato, cotto, in forno",
    "Merluzzo o nasello, surgelato, cotto, al microonde",
    "Aragosta, bollita",
    # Latte varianti poco usate
    "Latte di vacca, condensato, zuccherato",
    "Latte di vacca, evaporato, non zuccherato",
    "Latte di vacca, in polvere, intero",
    "Latte di vacca, in polvere, parzialmente scremato",
    "Latte di vacca, in polvere, scremato",
    # Pomodori varietà eccessive
    "Pomodori, Nerina, verdi, freschi",
    "Pomodori, Nerina, rossi, freschi",
}

# ---------------------------------------------------------------------------
# Lookup: rename esatti (nome attuale → nome normalizzato + eventuali alias)
# ---------------------------------------------------------------------------
RENAMES = {
    # Cereali
    "Riso, brillato":                         ("Riso bianco, crudo", []),
    "Riso, brillato, cotto, bollito":          ("Riso bianco, cotto", []),
    "Riso, integrale":                         ("Riso integrale, crudo", []),
    "Riso, integrale, cotto, bollito":         ("Riso integrale, cotto", []),
    "Riso, parboiled":                         ("Riso parboiled, crudo", []),
    "Riso, parboiled, cotto, bollito":         ("Riso parboiled, cotto", []),
    "Farina d'avena":                          ("Farina d'avena", []),
    "Fiocchi d'avena":                         ("Fiocchi d'avena", ["avena"]),
    "Farina di frumento, tipo 00":             ("Farina 00", []),
    "Farina di frumento, tipo 0":              ("Farina 0", []),
    "Farina di frumento, integrale":           ("Farina integrale", []),
    "Farina di frumento, duro":                ("Semola di grano duro", []),
    "Crusca di frumento":                      ("Crusca di frumento", ["crusca"]),
    "Germe di frumento":                       ("Germe di grano", []),
    "Pasta di semola":                         ("Pasta, cruda", []),
    "Pasta di semola, cotta, bollita":         ("Pasta, cotta", []),
    "Pasta di semola, integrale":              ("Pasta integrale, cruda", []),
    "Pasta di semola, integrale, cotta, bollita": ("Pasta integrale, cotta", []),
    "Pasta all'uovo, secca":                   ("Pasta all'uovo, cruda", []),
    "Pasta all'uovo, secca, cotta, bollita":   ("Pasta all'uovo, cotta", []),
    "Pane bianco":                             ("Pane bianco", []),
    "Pane di tipo semintegrale":               ("Pane semintegrale", []),
    "Pane di tipo integrale":                  ("Pane integrale", []),
    "Pane formato rosetta":                    ("Rosetta", ["pane rosetta"]),
    "Mais, dolce, in scatola, sgocciolato":    ("Mais dolce in scatola", ["granturco"]),
    "Polenta, cruda":                          ("Farina di mais per polenta", ["polenta"]),
    "Polenta, cotta":                          ("Polenta, cotta", []),
    # Verdure
    "Spinaci, cotti, al microonde":            ("Spinaci, cotti", []),
    "Spinaci, cotti, bolliti":                 ("Spinaci, cotti", []),
    "Zucchine, cotte, bollite":                ("Zucchine, cotte", []),
    "Carote, cotte, al microonde":             ("Carote, cotte", []),
    "Carote, cotte, bollite":                  ("Carote, cotte", []),
    "Finocchi, cotti, al microonde":           ("Finocchi, cotti", []),
    "Finocchi, cotti, bolliti":                ("Finocchi, cotti", []),
    "Cavolfiore, cotto, al microonde":         ("Cavolfiore, cotto", []),
    "Cavolfiore, cotto, bollito":              ("Cavolfiore, cotto", []),
    "Bieta, cotta, al microonde":              ("Bieta, cotta", []),
    "Bieta, cotta, bollita":                   ("Bieta, cotta", []),
    "Carciofi, cotti, al microonde":           ("Carciofi, cotti", []),
    "Carciofi, cotti, bolliti":                ("Carciofi, cotti", []),
    "Broccolo a testa, cotto, bollito":        ("Broccoli, cotti", []),
    "Broccolo a testa, crudo":                 ("Broccoli, crudi", []),
    "Cavolo broccolo verde ramoso, crudo":     ("Broccoletti, crudi", []),
    "Cavolo broccolo verde ramoso, cotto, bollito": ("Broccoletti, cotti", []),
    "Broccoletti di rapa, crudi":              ("Broccoletti di rapa, crudi", ["cime di rapa"]),
    "Broccoletti di rapa, cotti, bolliti":     ("Broccoletti di rapa, cotti", ["cime di rapa"]),
    "Cavoli di Bruxelles, crudi":              ("Cavolini di Bruxelles, crudi", []),
    "Cavoli di Bruxelles, cotti, bolliti":     ("Cavolini di Bruxelles, cotti", []),
    "Cavolo cappuccio, verde, crudo":          ("Cavolo cappuccio, crudo", []),
    "Cavolo cappuccio, verde, cotto, bollito": ("Cavolo cappuccio, cotto", []),
    "Lattuga, fresca":                         ("Lattuga", []),
    "Lattughino, fresco":                      ("Lattughino", []),
    "Lattughino IV gamma, fresco":             ("Lattughino IV gamma", []),
    "Radicchio, rosso, fresco":                ("Radicchio rosso", []),
    "Radicchio, verde, fresco":                ("Radicchio verde", []),
    "Indivia, fresca":                         ("Indivia", []),
    "Scarola IV gamma, fresca":                ("Scarola IV gamma", []),
    "Peperoni, rossi e gialli, crudi":         ("Peperoni misti, crudi", []),
    "Peperoni, gialli, crudi":                 ("Peperoni gialli, crudi", []),
    "Peperoni, gialli, cotti, al microonde":   ("Peperoni gialli, cotti", []),
    "Peperoni, rossi, crudi":                  ("Peperoni rossi, crudi", []),
    "Peperoni, rossi, cotti, al microonde":    ("Peperoni rossi, cotti", []),
    "Peperoni, verdi, crudi":                  ("Peperoni verdi, crudi", []),
    "Peperoni, cotti, in padella":             ("Peperoni, cotti", []),
    "Melanzane, cotte, in padella":            ("Melanzane, cotte", []),
    "Melanzane, cotte, al microonde":          ("Melanzane, cotte", []),
    "Sedano rapa, crudo":                      ("Sedano rapa", []),
    "Sedano, cotto, al microonde":             ("Sedano, cotto", []),
    "Porri, cotti, bolliti":                   ("Porri, cotti", []),
    "Rape, cotte, bollite":                    ("Rape, cotte", []),
    "Cipolle, cotte, bollite":                 ("Cipolle, cotte", []),
    "Cipolline, cotte, bollite":               ("Cipolline, cotte", []),
    "Fagiolini, surgelati, cotti, bolliti":    ("Fagiolini, surgelati, cotti", []),
    "Spinaci, surgelati":                      ("Spinaci surgelati", []),
    "Asparagi di serra, crudi":                ("Asparagi, crudi", []),
    "Barbabietole rosse, crude":               ("Barbabietole, crude", []),
    "Barbabietole rosse, cotte, bollite":      ("Barbabietole, cotte", []),
    "Rughetta o rucola, fresca":               ("Rucola", ["rughetta"]),
    "Tarassaco o dente di leone, fresco":      ("Tarassaco", ["dente di leone"]),
    "Cicoria, witloof o indivia belga, cruda": ("Indivia belga", ["witloof"]),
    "Cicoria, di campo, cotta, bollita":       ("Cicoria di campo, cotta", []),
    "Cicoria, di campo, cruda":                ("Cicoria di campo, cruda", []),
    "Cicoria, da taglio, coltivata, cruda":    ("Cicoria da taglio, cruda", []),
    "Funghi coltivati, prataioli, crudi":      ("Funghi champignon, crudi", ["funghi prataioli"]),
    "Funghi coltivati, prataioli, cotti, in padella": ("Funghi champignon, cotti", ["funghi prataioli"]),
    "Funghi coltivati, pleurotes, crudi":      ("Funghi pleurotus, crudi", ["funghi ostrica"]),
    "Funghi coltivati, pleurotes, cotti, in padella": ("Funghi pleurotus, cotti", []),
    "Funghi porcini, crudi":                   ("Funghi porcini, crudi", []),
    "Patate, con buccia, cotte, bollite":      ("Patate, cotte con buccia", []),
    "Patate, senza buccia, cotte, bollite":    ("Patate, cotte", []),
    "Patate, cotte, arrosto":                  ("Patate al forno", []),
    "Patate, cotte, al microonde":             ("Patate, cotte", []),
    "Patate novelle, cotte, al microonde":     ("Patate novelle, cotte", []),
    "Patate novelle, cotte, bollte":           ("Patate novelle, cotte", []),
    "Gnocchi di patate, crudi":               ("Gnocchi di patate, crudi", []),
    "Gnocchi di patate, cotti":               ("Gnocchi di patate, cotti", []),
    "Pomodori, da insalata, freschi":          ("Pomodori da insalata", []),
    "Pomodori, maturi, freschi":               ("Pomodori, maturi", []),
    "Pomodori, San Marzano, freschi":          ("Pomodori San Marzano", []),
    "Pomodorini ciliegino, freschi":           ("Pomodorini ciliegino", []),
    "Pomodori, pelati in scatola":             ("Pomodori pelati", []),
    "Vegetali misti, surgelati":               ("Verdure miste surgelate", []),
    # Frutta
    "Mele, fresche, senza buccia":             ("Mela", []),
    "Mele, fresche, con buccia":               ("Mela con buccia", []),
    "Mele, disidratate":                       ("Mele secche", []),
    "Pere, fresche, senza buccia":             ("Pera", []),
    "Arance, fresche":                         ("Arancia", []),
    "Arance succo, fresco":                    ("Succo d'arancia fresco", []),
    "Banane, fresche":                         ("Banana", []),
    "Kiwi, freschi":                           ("Kiwi", []),
    "Avocado, fresco":                         ("Avocado", []),
    "Ananas, fresco":                          ("Ananas, fresco", []),
    "Ananas, sciroppato":                      ("Ananas sciroppato", []),
    "Fragole, fresche":                        ("Fragole", []),
    "Lamponi, freschi":                        ("Lamponi", []),
    "Mirtilli, freschi":                       ("Mirtilli", []),
    "Albicocche, fresche":                     ("Albicocche", []),
    "Albicocche, secche":                      ("Albicocche secche", []),
    "Albicocche, disidratate":                 ("Albicocche disidratate", []),
    "Albicocche, sciroppate":                  ("Albicocche sciroppate", []),
    "Pesche, fresche, senza buccia":           ("Pesca", []),
    "Pesche, fresche, con buccia":             ("Pesca con buccia", []),
    "Pesche, secche":                          ("Pesche secche", []),
    "Pesche, disidratate":                     ("Pesche disidratate", []),
    "Pesche, sciroppate":                      ("Pesche sciroppate", []),
    "Peschenoci, fresche":                     ("Pesca noce", ["nettarina"]),
    "Prugne, fresche":                         ("Prugna", ["susina"]),
    "Prugne, gialle":                          ("Prugna gialla", []),
    "Prugne, rosse":                           ("Prugna rossa", []),
    "Prugne, secche":                          ("Prugne secche", []),
    "Uva, fresca":                             ("Uva", []),
    "Uva, bianca, fresca":                     ("Uva bianca", []),
    "Uva, nera, fresca":                       ("Uva nera", []),
    "Uva, secca":                              ("Uvetta", ["uva passa"]),
    "Cocomero, fresco":                        ("Anguria", ["cocomero"]),
    "Melone, d'estate, fresco":                ("Melone", []),
    "Melone, d'inverno, fresco":               ("Melone invernale", []),
    "Fichi, freschi":                          ("Fichi", []),
    "Fichi, secchi":                           ("Fichi secchi", []),
    "Fichi d'india, freschi":                  ("Fichi d'India", []),
    "Loti o kaki, freschi":                    ("Cachi", ["loti", "kaki"]),
    "Ciliege, fresche":                        ("Ciliegie", []),
    "Amarene, fresche":                        ("Amarene", []),
    "Mora di rovo":                            ("More", []),
    "Ribes, freschi":                          ("Ribes", []),
    "Mandarini, freschi":                      ("Mandarini", []),
    "Clementine, fresche":                     ("Clementine", []),
    "Limoni, freschi":                         ("Limone", []),
    "Pompelmo, fresco":                        ("Pompelmo", []),
    "Nespole, fresche":                        ("Nespole", []),
    "Mango, fresco":                           ("Mango", []),
    "Papaia, fresca":                          ("Papaia", []),
    "Cocco, fresco":                           ("Cocco fresco", []),
    "Datteri, secchi":                         ("Datteri", []),
    "Arachidi, tostate":                       ("Arachidi tostate", ["noccioline"]),
    "Mandorle dolci, secche":                  ("Mandorle", []),
    "Nocciole, secche":                        ("Nocciole", []),
    "Noci, secche":                            ("Noci", []),
    "Castagne, arrostite":                     ("Castagne arrostite", []),
    "Castagne, bollite":                       ("Castagne bollite", []),
    "Castagne, secche":                        ("Castagne secche", []),
    # Carni
    "Bovino adulto o vitellone, tagli anteriori, crudo":  ("Manzo, tagli anteriori, crudo", []),
    "Bovino adulto o vitellone, tagli posteriori, crudo": ("Manzo, tagli posteriori, crudo", []),
    "Bovino adulto o vitellone, costata, crudo":          ("Manzo, costata, cruda", []),
    "Bovino adulto o vitellone, fesa, crudo":             ("Manzo, fesa, cruda", []),
    "Bovino adulto o vitellone, filetto, crudo":          ("Manzo, filetto, crudo", []),
    "Bovino adulto o vitellone, girello, crudo":          ("Manzo, girello, crudo", []),
    "Bovino adulto o vitellone, lombata, crudo":          ("Manzo, lombata, cruda", []),
    "Bovino adulto o vitellone, noce, crudo":             ("Manzo, noce, cruda", []),
    "Bovino adulto o vitellone, scamone, crudo":          ("Manzo, scamone, crudo", []),
    "Bovino adulto o vitellone, sottofesa, crudo":        ("Manzo, sottofesa, cruda", []),
    "Bovino adulto o vitellone, copertina di sotto, copertina di spalla, sottospalla e collo, crudo": ("Manzo, spalla e collo, crudo", []),
    "Bovino adulto o vitellone, geretto anteriore e posteriore, crudo": ("Manzo, geretto, crudo", []),
    "Bovino adulto o vitellone, pancia, biancostato e punta di petto, crudo": ("Manzo, pancia e biancostato, crudo", []),
    "Bovino adulto o vitellone, spalla, muscolo, girello e fesone, crudo": ("Manzo, spalla, cruda", []),
    # "Vitello, filetto, cotto in padella" → in ELIMINATE
    "Bufalo, solo tessuto muscolare, crudo":    ("Carne di bufalo, cruda", []),
    "Cavallo, tessuto muscolare e grasso, crudo": ("Carne di cavallo, cruda", []),
    "Cavallo, solo tessuto muscolare, crudo":   ("Carne di cavallo magra, cruda", []),
    "Agnello, coscio, cotto, al forno":         ("Agnello, coscio, al forno", []),
    "Agnello, costoletta, cotto, al forno":     ("Agnello, costoletta, al forno", []),
    "Maiale, bistecca, cotto, in padella":      ("Maiale, bistecca, cotta", []),
    "Pollo, intero, con pelle, crudo":          ("Pollo intero con pelle, crudo", []),
    "Pollo, intero, con pelle, cotto, al forno": ("Pollo intero con pelle, al forno", []),
    "Pollo, intero, senza pelle, crudo":        ("Pollo intero, crudo", []),
    "Pollo, intero, senza pelle, cotto, al forno": ("Pollo intero, al forno", []),
    "Pollo, intero, con pelle, cotto, arrosto": ("Pollo arrosto con pelle", []),
    "Pollo, intero, senza pelle, cotto, arrosto": ("Pollo arrosto", []),
    "Pollo, ala, con pelle, crudo":             ("Ala di pollo, cruda", []),
    "Pollo, ala, con pelle, cotta, al forno":   ("Ala di pollo, al forno", []),
    "Pollo, fuso, con pelle, crudo":            ("Fuso di pollo con pelle, crudo", []),
    "Pollo, fuso, con pelle, cotto, al forno":  ("Fuso di pollo con pelle, al forno", []),
    "Pollo, fuso, senza pelle, crudo":          ("Fuso di pollo, crudo", []),
    "Pollo, fuso, senza pelle, cotto, al forno": ("Fuso di pollo, al forno", []),
    "Pollo, petto, crudo":                      ("Petto di pollo, crudo", []),
    "Pollo, petto, cotto, in padella":          ("Petto di pollo, cotto", []),
    "Pollo, sovracoscio, con pelle, crudo":     ("Sovracoscio di pollo con pelle, crudo", []),
    "Pollo, sovracoscio, con pelle, cotto, al forno": ("Sovracoscio di pollo con pelle, al forno", []),
    "Pollo, sovracoscio, senza pelle, crudo":   ("Sovracoscio di pollo, crudo", []),
    "Pollo, sovracoscio, senza pelle, cotto, al forno": ("Sovracoscio di pollo, al forno", []),
    "Tacchino intero, con pelle, crudo":        ("Tacchino intero con pelle, crudo", []),
    "Tacchino intero, senza pelle, crudo":      ("Tacchino intero, crudo", []),
    "Tacchino intero, senza pelle, cotto, al forno": ("Tacchino intero, al forno", []),
    "Tacchino, coscio, con pelle, crudo":       ("Coscio di tacchino, crudo", []),
    "Tacchino, fesa, crudo":                    ("Fesa di tacchino, cruda", []),
    "Tacchino, fesa, cotta, al forno":          ("Fesa di tacchino, al forno", []),
    "Tacchino, fuso, con pelle, crudo":         ("Fuso di tacchino con pelle, crudo", []),
    "Tacchino, fuso, con pelle, cotto, al forno": ("Fuso di tacchino, al forno", []),
    "Tacchino, fuso, senza pelle, crudo":       ("Fuso di tacchino, crudo", []),
    "Tacchino, fuso, senza pelle, cotto, al forno": ("Fuso di tacchino, al forno", []),
    "Tacchino, sovracoscio, senza pelle, crudo": ("Sovracoscio di tacchino, crudo", []),
    "Tacchino, sovracoscio, senza pelle, cotto, al forno": ("Sovracoscio di tacchino, al forno", []),
    "Faraona, coscio, con pelle, crudo":        ("Faraona, coscio con pelle, cruda", []),
    "Faraona, coscio, senza pelle, crudo":      ("Faraona, coscio, crudo", []),
    "Faraona, coscio, senza pelle, cotto, allo spiedo": ("Faraona, coscio, allo spiedo", []),
    "Faraona, petto, senza pelle, crudo":       ("Faraona, petto, crudo", []),
    "Faraona, petto, senza pelle, cotto, allo spiedo": ("Faraona, petto, allo spiedo", []),
    "Coniglio intero, cotto":                   ("Coniglio, cotto", []),
    "Coniglio intero surgelato, crudo":         ("Coniglio surgelato, crudo", []),
    "Coniglio, coscio, crudo":                  ("Coniglio, coscio, crudo", []),
    "Struzzo, solo tessuto muscolare, crudo":   ("Carne di struzzo, cruda", []),
    "Struzzo, solo tessuto muscolare, cotto, al forno": ("Carne di struzzo, al forno", []),
    "Cervo, solo tessuto muscolare, crudo":     ("Carne di cervo, cruda", []),
    "Daino, solo tessuto muscolare, crudo":     ("Carne di daino, cruda", []),
    "Capra, solo tessuto muscolare, crudo":     ("Carne di capra, cruda", []),
    "Pecora, solo tessuto muscolare, crudo":    ("Carne di pecora, cruda", []),
    # Insaccati
    "Prosciutto cotto, sgrassato":              ("Prosciutto cotto magro", []),
    "Prosciutto cotto, alta qualità":           ("Prosciutto cotto alta qualità", []),
    "Prosciutto cotto, alta qualità, sgrassato": ("Prosciutto cotto alta qualità, magro", []),
    "Prosciutto cotto, scelto":                 ("Prosciutto cotto scelto", []),
    "Prosciutto cotto, scelto, sgrassato":      ("Prosciutto cotto scelto, magro", []),
    "Prosciutto crudo DOP, di Parma":           ("Prosciutto di Parma DOP", []),
    "Prosciutto crudo, di Parma DOP, sgrassato": ("Prosciutto di Parma DOP, magro", []),
    "Salsiccia di suino, fresca, cotta, in padella": ("Salsiccia, cotta", []),
    "Wurstel di puro suino, crudo":             ("Wurstel", []),
    # "Wurstel di puro suino, cotto" → in ELIMINATE
    # Pesce
    "Acciuga o alice":                          ("Acciuga", ["alice"]),
    "Acciuga o alice, sott'olio":               ("Acciuga sott'olio", ["alice sott'olio"]),
    "Acciuga o alice, sotto sale":              ("Acciuga sotto sale", ["alice sotto sale"]),
    "Merluzzo o nasello":                       ("Merluzzo, crudo", ["nasello"]),
    "Merluzzo o nasello, surgelato":            ("Merluzzo surgelato", ["nasello surgelato"]),
    # "Merluzzo o nasello, surgelato, cotto, *" → in ELIMINATE
    "Merluzzo o nasello, surgelato, filetti":   ("Filetti di merluzzo surgelati", []),
    "Merluzzo o nasello, baccalà, secco":       ("Baccalà, secco", []),
    "Merluzzo o nasello, baccalà, ammollato":   ("Baccalà, ammollato", []),
    "Merluzzo o nasello, bastoncini di pesce, surgelati": ("Bastoncini di pesce surgelati", []),
    "Sgombro o maccarello":                     ("Sgombro", ["maccarello"]),
    "Sgombro o maccarello, in salamoia":        ("Sgombro in salamoia", []),
    "Melù o pesce molo":                        ("Melù", ["pesce molo"]),
    "Melù o pesce molo, stoccafisso, secco":    ("Stoccafisso, secco", ["melù secco"]),
    "Melù o pesce molo, stoccafisso, ammollato": ("Stoccafisso, ammollato", []),
    "Tonno in salamoia, sgocciolato":           ("Tonno al naturale", []),
    "Tonno sott'olio, sgocciolato":             ("Tonno sott'olio", []),
    "Salmone, in salamoia":                     ("Salmone in salamoia", []),
    "Orata fresca, filetti":                    ("Orata, filetti", []),
    "Orata fresca d'allevamento, filetti":      ("Orata d'allevamento, filetti", []),
    "Spigola d'allevamento, filetti":           ("Spigola, filetti", []),
    "Trota iridea d'allevamento, filetti":      ("Trota iridea, filetti", []),
    # "Trota surgelata, cotta, *" → in ELIMINATE
    "Gamberi sgusciati, surgelati":             ("Gamberi surgelati", []),
    "Granchio, in scatola":                     ("Granchio in scatola", []),
    "Calamaro surgelato":                       ("Calamaro surgelato", []),
    "Cozza o mitilo":                           ("Cozze", ["mitili"]),
    "Suro o sugarello":                         ("Sugarello", ["suro"]),
    "Bottarga, cefalo muggine":                 ("Bottarga di muggine", []),
    # Latticini
    "Latte di vacca, pastorizzato, intero":              ("Latte intero", []),
    "Latte di vacca, pastorizzato, parzialmente scremato": ("Latte parzialmente scremato", []),
    "Latte di vacca, pastorizzato, scremato":            ("Latte scremato", []),
    "Latte di vacca, UHT, intero":                       ("Latte intero UHT", []),
    "Latte di vacca, UHT, parzialmente scremato":        ("Latte parzialmente scremato UHT", []),
    "Crema di latte, 12% di lipidi":                     ("Panna leggera 12%", []),
    "Panna da montare, 35% di lipidi":                   ("Panna da montare", []),
    "Panna da cucina, sterilizzata, 23% di lipidi":      ("Panna da cucina", []),
    "Yogurt, da latte intero":                            ("Yogurt intero", []),
    "Yogurt, 0% lipidi":                                  ("Yogurt magro", []),
    "Yogurt greco, da latte intero":                      ("Yogurt greco intero", []),
    "Yogurt greco, da latte magro, alla frutta":          ("Yogurt greco magro alla frutta", []),
    "Yogurt greco, 0% lipidi":                            ("Yogurt greco 0%", []),
    "Yogurt greco, 0% lipidi, aromatizzato":              ("Yogurt greco 0% aromatizzato", []),
    "Yogurt da latte intero, alla frutta":                ("Yogurt intero alla frutta", []),
    "Yogurt da latte, parzialmente scremato":             ("Yogurt parzialmente scremato", []),
    "Yogurt da latte, scremato":                          ("Yogurt magro", []),
    "Mozzarella di vacca":                                ("Mozzarella", []),
    "Fiocchi di formaggio magro":                         ("Fiocchi di latte", []),
    "Formaggio cremoso spalmabile":                       ("Formaggio spalmabile", ["Philadelphia"]),
    "Formaggio cremoso spalmabile, light":                ("Formaggio spalmabile light", []),
    "Formaggio molle da tavola":                          ("Formaggio molle", []),
    "Grana Padano, DOP":                                  ("Grana Padano", []),
    # Uova
    "Uova di gallina, intero":                            ("Uovo intero, crudo", []),
    "Tofu, sodo":                              ("Tofu", []),
    # "Uova di gallina, intero, cotto, *" → in ELIMINATE
    "Uova di gallina, albume":                            ("Albume d'uovo", []),
    "Uova di gallina, tuorlo":                            ("Tuorlo d'uovo", []),
    # Grassi e oli
    "Olio di oliva":                                      ("Olio d'oliva", []),
    "Olio di oliva extra vergine":                        ("Olio extravergine d'oliva", ["EVO"]),
    "Olio di arachide":                                   ("Olio di arachidi", []),
    "Olio di germe di grano":                             ("Olio di germe di grano", []),
    "Margarina, 100% vegetale":                           ("Margarina vegetale", []),
    "Margarina, 2/3 di grassi animali, 1/3 di grassi vegetali": ("Margarina mista", []),
    # Legumi
    "Ceci, secchi":                                       ("Ceci, secchi", []),
    "Ceci, secchi, cotti, bolliti":                       ("Ceci, cotti", []),
    "Ceci, in scatola, scolati":                          ("Ceci in scatola", []),
    "Fagioli, Borlotti, freschi":                         ("Fagioli borlotti, freschi", []),
    "Fagioli, Borlotti, freschi, cotti, bolliti":         ("Fagioli borlotti freschi, cotti", []),
    "Fagioli, Borlotti, secchi":                          ("Fagioli borlotti, secchi", []),
    "Fagioli, Borlotti, secchi, cotti, bolliti":          ("Fagioli borlotti, cotti", []),
    "Fagioli, Borlotti, in scatola, scolati":             ("Fagioli borlotti in scatola", []),
    "Fagioli, Cannellini, secchi":                        ("Fagioli cannellini, secchi", []),
    "Fagioli, Cannellini, secchi, cotti, bolliti":        ("Fagioli cannellini, cotti", []),
    "Fagioli, Cannellini in scatola, scolati":            ("Fagioli cannellini in scatola", []),
    "Fagioli dall'occhio, secchi":                        ("Fagioli dall'occhio, secchi", []),
    "Fagiolini a corallo, cotti, bolliti":                ("Fagiolini cotti", []),
    "Fave, fresche":                                      ("Fave, fresche", []),
    "Fave, fresche, cotte, in padella":                   ("Fave, cotte", []),
    "Fave, secche":                                       ("Fave, secche", []),
    "Fave, secche, sgusciate, crude":                     ("Fave secche sgusciate", []),
    "Fave, secche, sgusciate, cotte, bollite":            ("Fave secche, cotte", []),
    "Lenticchie, secche":                                 ("Lenticchie, secche", []),
    "Lenticchie, secche, cotte, bollite":                 ("Lenticchie, cotte", []),
    "Lenticchie, in scatola, scolate":                    ("Lenticchie in scatola", []),
    "Piselli, freschi":                                   ("Piselli, freschi", []),
    "Piselli, freschi, cotti, in padella":                ("Piselli, cotti", []),
    "Piselli, in scatola, scolati":                       ("Piselli in scatola", []),
    "Piselli, surgelati":                                 ("Piselli surgelati", []),
    # Bevande alcoliche
    "Bevanda alcolica, Aperitivo a base di vino": ("Aperitivo a base di vino", []),
    "Bevanda alcolica, Birra chiara":             ("Birra chiara", []),
    "Bevanda alcolica, Vino da pasto bianco":     ("Vino bianco", []),
    "Bevanda alcolica, Vino da pasto rosso":      ("Vino rosso", []),
    "Bevanda alcolica, Marsala tipico":           ("Marsala", []),
    "Bevanda alcolica, Vermouth dolce":           ("Vermouth dolce", []),
    "Bevanda alcolica, Vermouth secco":           ("Vermouth secco", []),
    "Bevanda alcolica, Liquori da dessert":       ("Liquori da dessert", []),
    "Bevanda alcolica, Marsala all'uovo":         ("Marsala all'uovo", []),
    "Bevanda alcolica, Brandy":                   ("Brandy", []),
    "Bevanda alcolica, Grappa":                   ("Grappa", []),
    "Bevanda alcolica, Whisky":                   ("Whisky", []),
    "Bevanda alcolica, Spumante":                 ("Spumante", []),
    # Minestre
    "Minestre in scatola, crema di asparagi":  ("Crema di asparagi", []),
    "Minestre in scatola, crema di cipolle":   ("Crema di cipolle", []),
    "Minestre in scatola, crema di funghi":    ("Crema di funghi", []),
    "Minestre in scatola, crema di pollo":     ("Crema di pollo", []),
    "Minestre in scatola, crema di pomodori":  ("Crema di pomodori", []),
    # Frutta secca / semi
    "Olive, verdi, in salamoia":               ("Olive verdi in salamoia", []),
    "Olive da tavola conservate":              ("Olive da tavola", []),
    # Fast food
    "Cheese burger, fast food":                ("Cheeseburger", []),
    "Hamburger, fast food":                    ("Hamburger", []),
    "Chicken Nuggets, fast food":              ("Chicken nuggets", []),
    "Hamburger piccolo, solo carne, fast food": ("Hamburger piccolo", []),
    "Panino, fast food":                       ("Panino fast food", []),
    "Panino con hamburger piccolo, fast food": ("Panino con hamburger", []),
    "Patatine, fritte, fast food":             ("Patatine fritte fast food", []),
    # Frattaglie
    "Animelle di bovini":                      ("Animelle", []),
    "Animelle di bovini, cotte":               ("Animelle, cotte", []),
    "Cervello di bovini":                      ("Cervello", []),
    "Cuore di bovini":                         ("Cuore di manzo", []),
    "Cuore di bovini, cotto":                  ("Cuore di manzo, cotto", []),
    "Cuore di equini":                         ("Cuore di cavallo", []),
    "Cuore di ovini":                          ("Cuore di agnello", []),
    "Cuore di pollo":                          ("Cuore di pollo", []),
    "Cuore di pollo, cotto":                   ("Cuore di pollo, cotto", []),
    "Cuore di suino":                          ("Cuore di maiale", []),
    "Cuore di tacchino":                       ("Cuore di tacchino", []),
    "Cuore di tacchino, cotto":                ("Cuore di tacchino, cotto", []),
    "Fegato di bovini":                        ("Fegato di manzo", []),
    "Fegato di bovini, cotto":                 ("Fegato di manzo, cotto", []),
    "Fegato di equini":                        ("Fegato di cavallo", []),
    "Fegato di ovini":                         ("Fegato di agnello", []),
    "Fegato di pollo":                         ("Fegato di pollo", []),
    "Fegato di pollo, cotto":                  ("Fegato di pollo, cotto", []),
    "Fegato di suini":                         ("Fegato di maiale", []),
    "Fegato di suini, cotto":                  ("Fegato di maiale, cotto", []),
    "Fegato di tacchino":                      ("Fegato di tacchino", []),
    "Fegato di tacchino, cotto":               ("Fegato di tacchino, cotto", []),
    "Lingua di bovini":                        ("Lingua di manzo", []),
    "Lingua di bovini, cotta, fritta":         ("Lingua di manzo, fritta", []),
    "Milza di bovini":                         ("Milza di manzo", []),
    "Polmone di bovini":                       ("Polmone di manzo", []),
    "Rene di bovini":                          ("Rene di manzo", []),
    "Trippa di bovini":                        ("Trippa", []),
    "Mortadella di bovini e suini":            ("Mortadella (mista)", []),
    "Coratella di vitello":                    ("Coratella di vitello", []),
    "Coratella di agnello":                    ("Coratella di agnello", []),
    # Varie
    "Bevanda tipo cola":                       ("Cola", ["coca cola", "pepsi"]),
    "Burro d'arachidi":                        ("Burro di arachidi", ["peanut butter"]),
    "Kebab solo carne":                        ("Kebab (solo carne)", []),
    "Succo di frutta":                         ("Succo di frutta", []),
    "Cocktail di frutta sciroppata":           ("Cocktail di frutta sciroppato", []),
    "Crema di nocciole e cacao":               ("Crema spalmabile nocciole e cacao", ["nutella"]),
    "Maionese, industriale":                   ("Maionese", []),
    "Maionese, artigianale":                   ("Maionese artigianale", []),
    "Ketchup, salsa":                          ("Ketchup", []),
    "Dadi da brodo":                           ("Dado da brodo", []),
    "Cacao amaro, in polvere":                 ("Cacao in polvere", []),
    "Tè, foglie":                              ("Tè", []),
    "Caffe' tostato":                          ("Caffè", []),
    "Soia, bevanda":                           ("Bevanda di soia", ["latte di soia"]),
    "Soia, salsa":                             ("Salsa di soia", []),
    "Soia, yogurt":                            ("Yogurt di soia", []),
    "Soia, isolato proteico":                  ("Isolato proteico di soia", []),
    "Lievito di birra, compresso":             ("Lievito di birra", []),
    "Fecola di patate":                        ("Fecola di patate", ["amido di patate"]),
}

# ---------------------------------------------------------------------------
# Trasformazioni pattern (applicate se non c'è un rename esatto)
# ---------------------------------------------------------------------------
def apply_patterns(nome):
    """Applica trasformazioni deterministiche residuali."""
    # Rimuovi prefissi ridondanti
    for prefix in [
        "Bevanda alcolica, ",
        "Minestre in scatola, ",
    ]:
        if nome.startswith(prefix):
            nome = nome[len(prefix):]

    # Bovino → Manzo
    nome = nome.replace("Bovino adulto o vitellone, ", "Manzo, ")

    return nome


def strip_crudo(nome: str) -> str:
    """Rimuove il suffisso ', crudo/a/i/e' dal nome (si pesa sempre a crudo)."""
    for suffix in (", crudo", ", cruda", ", crudi", ", crude"):
        if nome.lower().endswith(suffix):
            return nome[: -len(suffix)]
    return nome

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    with open(INPUT, encoding='utf-8') as f:
        data = json.load(f)

    result = []
    seen_nomes = {}  # nome normalizzato → True (per deduplicazione)
    stats = {"eliminati": 0, "rinominati": 0, "pattern": 0, "invariati": 0, "duplicati": 0}

    for item in data:
        nome_originale = item.get('nome', '')

        # 1. Elimina categorie ricette/piatti composti
        if item.get('categoria') in ELIMINATE_CATEGORIES:
            stats["eliminati"] += 1
            continue

        # 2. Elimina varianti cotte (si pesa sempre a crudo)
        if is_cooked(nome_originale):
            stats["eliminati"] += 1
            continue

        # 3. Elimina varianti accorpate
        if nome_originale in ELIMINATE:
            stats["eliminati"] += 1
            continue

        item = copy.deepcopy(item)

        # 3. Rename esatto
        if nome_originale in RENAMES:
            nuovo_nome, aliases = RENAMES[nome_originale]
            item['nome'] = nuovo_nome
            if aliases:
                item['alias'] = aliases
            stats["rinominati"] += 1
        else:
            # 4. Pattern generici
            nuovo_nome = apply_patterns(nome_originale)
            if nuovo_nome != nome_originale:
                item['nome'] = nuovo_nome
                stats["pattern"] += 1
            else:
                stats["invariati"] += 1

        # 5. Rimuovi suffisso ", crudo/a/i/e"
        item['nome'] = strip_crudo(item['nome'])

        # Deduplicazione: se dopo la normalizzazione due voci hanno lo stesso nome,
        # teniamo la prima e scartiamo le successive
        nome_finale = item['nome']
        if nome_finale in seen_nomes:
            stats["duplicati"] += 1
            continue

        seen_nomes[nome_finale] = True
        result.append(item)

    with open(OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"Input:      {len(data)} voci")
    print(f"Output:     {len(result)} voci")
    print(f"Eliminati:  {stats['eliminati']}")
    print(f"Rinominati: {stats['rinominati']}")
    print(f"Pattern:    {stats['pattern']}")
    print(f"Invariati:  {stats['invariati']}")
    print(f"Duplicati:  {stats['duplicati']}")

if __name__ == '__main__':
    main()
