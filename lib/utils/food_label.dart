/// Accorcia il nome di un alimento per mostrarlo su una chip, provando a
/// tagliare a una virgola invece che a metà parola.
///
/// I nomi CREA in italiano mettono la variante prima della virgola
/// ("Fagioli borlotti, secchi"), mentre quelli inglesi la mettono dopo
/// ("Beans, Borlotti, dried, raw"): tagliare sempre alla prima virgola fa
/// collassare varianti diverse sulla stessa etichetta in inglese (es. i
/// fagioli borlotti e cannellini diventano entrambi "Beans"). Se la prima
/// virgola arriva troppo presto, si prova con la successiva per non perdere
/// la parte che distingue le varietà.
String shortFoodLabel(String nome, {int maxLength = 26, int earlyCommaThreshold = 8}) {
  if (nome.length <= maxLength) return nome;
  var comma = nome.indexOf(',');
  if (comma > 0 && comma <= earlyCommaThreshold) {
    final next = nome.indexOf(',', comma + 1);
    if (next > 0) comma = next;
  }
  if (comma > 0 && comma <= maxLength) return nome.substring(0, comma);
  return '${nome.substring(0, maxLength - 3)}…';
}
