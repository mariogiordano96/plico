import 'package:isar/isar.dart';

part 'nutrizione_completa.g.dart';

@embedded
class NutrizioneCompleta {
  // Composizione prossimale
  double? acqua;
  double? energiaKj;
  double? colesterolo;
  double? amido;
  double? zuccheriSolubili;
  double? alcol;
  double? fibreTotali;
  double? fibreSolubili;
  double? fibreInsolubili;

  // Zuccheri specifici
  double? saccarosio;
  double? glucosio;
  double? fruttosio;
  double? lattosio;
  double? galattosio;
  double? maltosio;
  double? maltotriosio;
  double? raffinosio;

  // Minerali
  double? fluoro;
  double? sodio;
  double? magnesio;
  double? fosforo;
  double? cloro;
  double? potassio;
  double? calcio;
  double? cromo;
  double? manganese;
  double? ferro;
  double? nichel;
  double? rame;
  double? zinco;
  double? selenio;
  double? iodio;

  // Carotenoidi
  double? carotenoidiTotali;
  double? alfaCarotene;
  double? betaCarotene;
  double? criptoxantina;
  double? licopene;
  double? luteina;
  double? retinolo;
  double? zeaxantina;

  // Vitamine
  double? vitaminaA;
  double? tiamina;
  double? riboflavina;
  double? niacina;
  double? acidoPantotenico;
  double? vitaminaB6;
  double? biotina;
  double? folati;
  double? vitaminaB12;
  double? vitaminaC;
  double? vitaminaD;
  double? vitaminaE;
  double? alfaTocoferolo;
  double? betaTocoferolo;
  double? gammaTocoferolo;
  double? deltaTocoferolo;
  double? vitaminaK;

  // Acidi grassi - totali
  double? acidiGrassiSaturi;
  double? acidiGrassiMonoinsaturi;
  double? acidiGrassiPolinsaturi;
  double? rapportoPolinsaturiSaturi;

  // Acidi grassi saturi specifici
  double? acidiGrassiC4C10;
  double? acidoButirrico;
  double? acidoCapronico;
  double? acidoEnanterico;
  double? acidoCaprilico;
  double? acidoCaprinico;
  double? acidoLaurico;
  double? acidoTridecanoico;
  double? acidoMiristico;
  double? acidoPentadecanoico;
  double? acidoPalmitico;
  double? acidoEptadecanoico;
  double? acidoStearico;
  double? acidoArachidico;
  double? acidoBenico;
  double? acidoLignocerico;

  // Acidi grassi monoinsaturi specifici
  double? acidoCaproleico;
  double? acidoLauroleico;
  double? acidoTridecenoico;
  double? acidoMiristoleico;
  double? acidoPentadecenoico;
  double? acidoPalmitoleico;
  double? acidoEptadecenoicoMono;
  double? acidoOleico;
  double? acidoEicosenoico;
  double? acidoErucico;

  // Acidi grassi polinsaturi specifici
  double? acidoLinoleico;
  double? acidoLinolenico;
  double? acidoArachidonico;
  double? epa;
  double? dha;

  // Aminoacidi
  double? alanina;
  double? cisteina;
  double? acidoAspartico;
  double? acidoGlutammico;
  double? fenilalanina;
  double? glicina;
  double? istidina;
  double? isoleucina;
  double? lisina;
  double? leucina;
  double? metionina;
  double? prolina;
  double? arginina;
  double? serina;
  double? treonina;
  double? valina;
  double? triptofano;
  double? tirosina;
  double? indiceChimico;
  String? aminoacidoLimitante;

  // Polifenoli e altri composti bioattivi
  double? acidoCaffeico;
  double? acidoCitrico;
  double? acidoFitico;
  double? acidoMalico;
  double? apigenina;
  double? attivitaAntiossidante;
  double? campferolo;
  double? fitosteroli;
  double? fruttooligosaccaridi;
  double? miricetina;
  double? polifenoli;
  double? quercetina;
  double? violaxantina;
}
