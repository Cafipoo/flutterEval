import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/search_response.dart';
import '../models/super_category.dart';

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

      final url = Uri.parse(
        '$baseUrl/api/v2/search?search_terms=${Uri.encodeComponent(query)}'
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
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  /// Retourne tes 10 catégories spécifiques pour le filtrage
  List<Category> _getDefaultCategories() {
    return [
      Category(id: 'en:fruits', name: 'Fruits'),
      Category(id: 'en:vegetables', name: 'Légumes'),
      Category(id: 'en:meats', name: 'Viandes'),
      Category(id: 'en:dairy', name: 'Laitages'),
      Category(id: 'en:beverages', name: 'Boissons'),
      Category(id: 'en:cereals', name: 'Céréales'),
      Category(id: 'en:snacks', name: 'Snacks'),
      Category(id: 'en:fish', name: 'Poissons'),
      Category(id: 'en:sweets', name: 'Sucreries'),
      Category(id: 'en:others', name: 'Autres'),
    ];
  }

  // --- Garde le reste de tes méthodes (getSuperCategories, etc.) ci-dessous ---
  
  Future<List<SuperCategory>> getSuperCategories() async {
    final allCategories = await getCategories(limit: 30);
    return _organizeCategoriesIntoSuperCategories(allCategories);
  }

  Future<List<Category>> getCategories({int limit = 30}) async {
    return _getDefaultCategories(); // Utilisation directe des catégories demandées
  }

  List<SuperCategory> _organizeCategoriesIntoSuperCategories(List<Category> categories) {
    // Cette méthode peut rester telle quelle ou être simplifiée selon tes modèles SuperCategory
    final superCategoryDefinitions = [
      {'id': 'fruits', 'name': 'Fruits', 'icon': '🍎', 'keywords': ['fruit']},
      {'id': 'vegetables', 'name': 'Légumes', 'icon': '🥕', 'keywords': ['vegetable', 'legume']},
      {'id': 'meats', 'name': 'Viandes', 'icon': '🥩', 'keywords': ['meat', 'viande', 'boeuf', 'porc']},
      {'id': 'dairy', 'name': 'Laitages', 'icon': '🥛', 'keywords': ['dairy', 'lait', 'fromage', 'yaourt']},
      {'id': 'beverages', 'name': 'Boissons', 'icon': '🥤', 'keywords': ['beverage', 'boisson', 'eau', 'jus']},
      {'id': 'cereals', 'name': 'Céréales', 'icon': '🌾', 'keywords': ['cereal', 'pain', 'pâtes', 'riz']},
      {'id': 'snacks', 'name': 'Snacks', 'icon': '🍿', 'keywords': ['snack', 'chips', 'biscuit']},
      {'id': 'fish', 'name': 'Poissons', 'icon': '🐟', 'keywords': ['fish', 'poisson', 'saumon']},
      {'id': 'sweets', 'name': 'Sucreries', 'icon': '🍬', 'keywords': ['sweet', 'chocolat', 'bonbon', 'dessert']},
      {'id': 'other', 'name': 'Autres', 'icon': '📦', 'keywords': []},
    ];

    final Map<String, List<Category>> categorized = {};
    for (final def in superCategoryDefinitions) {
      categorized[def['id'] as String] = [];
    }

    for (final category in categories) {
      final nameLower = category.name.toLowerCase();
      bool isCategorized = false;

      for (var def in superCategoryDefinitions) {
        if (def['id'] == 'other') continue;
        final keywords = def['keywords'] as List<String>;
        if (keywords.any((k) => nameLower.contains(k))) {
          categorized[def['id']]!.add(category);
          isCategorized = true;
          break;
        }
      }
      if (!isCategorized) categorized['other']!.add(category);
    }

    return superCategoryDefinitions
        .map((def) => SuperCategory(
              id: def['id'] as String,
              name: def['name'] as String,
              icon: def['icon'] as String,
              categories: categorized[def['id']] ?? [],
            ))
        .where((sc) => sc.categories.isNotEmpty)
        .toList();
  }
}