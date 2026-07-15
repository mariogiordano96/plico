import 'dart:convert';
import 'package:http/http.dart' as http;

class OFFFood {
  final String offCode;
  final String nome;
  final String? brand;
  final double kcalPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;

  const OFFFood({
    required this.offCode,
    required this.nome,
    this.brand,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
  });

  factory OFFFood.fromJson(Map<String, dynamic> json, {String languageCode = 'it'}) {
    final n = json['nutriments'] as Map<String, dynamic>? ?? {};
    // Preferisce il nome nella lingua corrente, poi quello generico
    // restituito dall'API in base al parametro `lc`, poi l'italiano come
    // ultima spiaggia (catalogo con copertura migliore per prodotti IT).
    final nome = (json['product_name_$languageCode'] ??
            json['product_name'] ??
            json['product_name_it'])
        ?.toString()
        .trim() ??
        '';
    return OFFFood(
      offCode: json['code']?.toString() ?? '',
      nome: nome,
      brand: (json['brands'] as String?)?.split(',').first.trim(),
      kcalPer100g: (n['energy-kcal_100g'] as num?)?.toDouble() ?? 0,
      proteinPer100g: (n['proteins_100g'] as num?)?.toDouble() ?? 0,
      fatPer100g: (n['fat_100g'] as num?)?.toDouble() ?? 0,
      carbsPer100g: (n['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OpenFoodFactsService {
  static const _base = 'https://it.openfoodfacts.org';
  static const _headers = {'User-Agent': 'Plico/1.0 (github.com/mariogiordano96/plico_flutter)'};

  static Future<List<OFFFood>> search(String query, {String languageCode = 'it'}) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(
      '$_base/cgi/search.pl'
      '?search_terms=${Uri.encodeComponent(query.trim())}'
      '&search_simple=1&action=process&json=1'
      '&page_size=25&fields=product_name,product_name_it,product_name_en,brands,nutriments,code'
      '&lc=$languageCode&cc=it',
    );
    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final products = data['products'] as List? ?? [];
      return products
          .map((p) => OFFFood.fromJson(p as Map<String, dynamic>, languageCode: languageCode))
          .where((f) => f.nome.isNotEmpty && f.kcalPer100g > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<OFFFood?> searchByBarcode(String barcode, {String languageCode = 'it'}) async {
    final uri = Uri.parse('$_base/api/v0/product/$barcode.json?lc=$languageCode');
    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      final food = OFFFood.fromJson(product, languageCode: languageCode);
      return food.nome.isNotEmpty && food.kcalPer100g > 0 ? food : null;
    } catch (_) {
      return null;
    }
  }
}
