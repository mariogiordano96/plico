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

  factory OFFFood.fromJson(Map<String, dynamic> json) {
    final n = json['nutriments'] as Map<String, dynamic>? ?? {};
    return OFFFood(
      offCode: json['code']?.toString() ?? '',
      nome: (json['product_name_it'] ?? json['product_name'])?.toString().trim() ?? '',
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

  static Future<List<OFFFood>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(
      '$_base/cgi/search.pl'
      '?search_terms=${Uri.encodeComponent(query.trim())}'
      '&search_simple=1&action=process&json=1'
      '&page_size=25&fields=product_name,product_name_it,brands,nutriments,code&lc=it&cc=it',
    );
    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final products = data['products'] as List? ?? [];
      return products
          .map((p) => OFFFood.fromJson(p as Map<String, dynamic>))
          .where((f) => f.nome.isNotEmpty && f.kcalPer100g > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<OFFFood?> searchByBarcode(String barcode) async {
    final uri = Uri.parse('$_base/api/v0/product/$barcode.json');
    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;
      final food = OFFFood.fromJson(product);
      return food.nome.isNotEmpty && food.kcalPer100g > 0 ? food : null;
    } catch (_) {
      return null;
    }
  }
}
