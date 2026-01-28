import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/search_response.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org';
  static const String userAgent = 'FlutterEval/1.0 (flutter-app@example.com)';
  static const int defaultPageSize = 1;
  static const int maxPageSize = 100;

  // Optimisation : On ne demande que le strict nécessaire pour alléger la réponse JSON
  static const String _optimizedFields = 
      'code,product_name,product_name_fr,brands,image_url,'
      'nutriscore_grade,categories_tags,nutriments,quantity';

  Map<String, String> get _headers => {
    'User-Agent': userAgent,
    'Accept': 'application/json',
  };

  /// Récupère les détails d'un produit par son code-barres (Optimisé)
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/v2/product/$barcode.json?fields=$_optimizedFields',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return Product.fromJson(data['product']);
        } else {
          throw Exception('Produit non trouvé');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit: $e');
    }
  }

  /// Recherche des produits par catégorie avec pagination (Optimisé)
  Future<SearchResponse> getProductsByCategory(
    String category, {
    int page = 1,
    int pageSize = defaultPageSize,
  }) async {
    try {
      final limitedPageSize = pageSize > maxPageSize ? maxPageSize : pageSize;

      final url = Uri.parse(
        '$baseUrl/api/v2/search?categories_tags_en=$category'
        '&page=$page'
        '&page_size=$limitedPageSize'
        '&fields=$_optimizedFields',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchResponse.fromJson(data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits: $e');
    }
  }

  /// Recherche de produits par texte (Optimisé)
  Future<SearchResponse> searchProducts(
    String query, {
    int page = 1,
    int pageSize = defaultPageSize,
  }) async {
    try {
      final limitedPageSize = pageSize > maxPageSize ? maxPageSize : pageSize;

      final String encodedQuery = Uri.encodeComponent(query);

      final url = Uri.parse('$baseUrl/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=$limitedPageSize&fields=$_optimizedFields');

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchResponse.fromJson(data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  /// Retourne les catégories principales
  Future<List<Category>> getCategories() async {
    return [
      Category(id: 'en:fruits-based-foods', name: 'Fruits', icon: '🍎'),
      Category(id: 'en:vegetables-based-foods', name: 'Légumes', icon: '🥕'),
      Category(id: 'en:meats', name: 'Viandes', icon: '🥩'),
      Category(id: 'en:dairy', name: 'Laitages', icon: '🥛'),
      Category(id: 'en:beverages', name: 'Boissons', icon: '🥤'),
      Category(id: 'en:cereals', name: 'Céréales', icon: '🌾'),
      Category(id: 'en:snacks', name: 'Snacks', icon: '🍿'),
      Category(id: 'en:fish', name: 'Poissons', icon: '🐟'),
      Category(id: 'en:sweets', name: 'Sucreries', icon: '🍬'),
      Category(id: 'en:others', name: 'Autres', icon: '📦'),
    ];
  }
}