import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/search_response.dart';
import '../models/super_category.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org';
  static const String userAgent = 'FlutterEval/1.0 (flutter-app@example.com)';
  static const int defaultPageSize = 24;
  static const int maxPageSize = 100;

  // Headers pour toutes les requêtes
  Map<String, String> get _headers => {
    'User-Agent': userAgent,
    'Accept': 'application/json',
  };

  /// Organise les catégories en super-catégories
  Future<List<SuperCategory>> getSuperCategories() async {
    // Réduire le nombre de catégories pour accélérer le chargement
    final allCategories = await getCategories(limit: 30);
    return _organizeCategoriesIntoSuperCategories(allCategories);
  }

  /// Récupère les catégories populaires
  /// Limite à 30 catégories pour accélérer le chargement
  Future<List<Category>> getCategories({int limit = 30}) async {
    try {
      // Essayer d'abord l'API search-a-licious avec timeout
      try {
        final url = Uri.parse(
          'https://search.openfoodfacts.org/categories.json?limit=$limit',
        );

        final response = await http
            .get(url, headers: _headers)
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['tags'] != null && (data['tags'] as List).isNotEmpty) {
            return (data['tags'] as List)
                .map((tag) => Category.fromJson(tag))
                .toList();
          }
        }
      } catch (e) {
        // Si timeout ou erreur, utiliser directement les catégories par défaut
        return _getDefaultCategories();
      }

      // Si l'API ne retourne rien, utiliser les catégories par défaut
      return _getDefaultCategories();
    } catch (e) {
      // Dernier fallback: retourner des catégories populaires en dur
      return _getDefaultCategories();
    }
  }

  /// Retourne des catégories par défaut populaires
  /// Utilisé pour un chargement rapide sans requête API
  List<Category> _getDefaultCategories() {
    return [
      Category(id: 'en:beverages', name: 'Boissons'),
      Category(id: 'en:snacks', name: 'Snacks'),
      Category(id: 'en:dairy', name: 'Produits laitiers'),
      Category(id: 'en:meats', name: 'Viandes'),
      Category(id: 'en:fruits', name: 'Fruits'),
      Category(id: 'en:vegetables', name: 'Légumes'),
      Category(id: 'en:cereals', name: 'Céréales'),
      Category(id: 'en:sweets', name: 'Sucreries'),
      Category(id: 'en:bread', name: 'Pain'),
      Category(id: 'en:fish', name: 'Poissons'),
      Category(id: 'en:chocolate', name: 'Chocolat'),
      Category(id: 'en:yogurts', name: 'Yaourts'),
      Category(id: 'en:cheeses', name: 'Fromages'),
      Category(id: 'en:juices', name: 'Jus de fruits'),
      Category(id: 'en:pasta', name: 'Pâtes'),
      Category(id: 'en:rice', name: 'Riz'),
      Category(id: 'en:oils', name: 'Huiles'),
      Category(id: 'en:spices', name: 'Épices'),
      Category(id: 'en:sauces', name: 'Sauces'),
      Category(id: 'en:canned-foods', name: 'Conserves'),
    ];
  }

  /// Recherche des produits par catégorie avec pagination
  Future<SearchResponse> getProductsByCategory(
    String category, {
    int page = 1,
    int pageSize = defaultPageSize,
  }) async {
    try {
      // Limiter la taille de page pour éviter de surcharger
      final limitedPageSize = pageSize > maxPageSize ? maxPageSize : pageSize;

      final url = Uri.parse(
        '$baseUrl/api/v2/search?categories_tags_en=$category'
        '&page=$page'
        '&page_size=$limitedPageSize'
        '&fields=code,product_name,product_name_fr,brands,brands_tags,'
        'image_url,image_front_url,image_front_small_url,'
        'nutrition_grades,nutrition_grade_fr,categories_tags,'
        'nutriments,quantity,packaging',
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

  /// Recherche de produits par terme de recherche avec pagination
  Future<SearchResponse> searchProducts(
    String query, {
    int page = 1,
    int pageSize = defaultPageSize,
  }) async {
    try {
      // Limiter la taille de page
      final limitedPageSize = pageSize > maxPageSize ? maxPageSize : pageSize;

      // Utilisation de l'API v2 search avec search_terms
      final url = Uri.parse(
        '$baseUrl/api/v2/search?search_terms=${Uri.encodeComponent(query)}'
        '&page=$page'
        '&page_size=$limitedPageSize'
        '&fields=code,product_name,product_name_fr,brands,brands_tags,'
        'image_url,image_front_url,image_front_small_url,'
        'nutrition_grades,nutrition_grade_fr,categories_tags,'
        'nutriments,quantity,packaging',
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

  /// Récupère les détails d'un produit par son code-barres
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/v2/product/$barcode.json'
        '?fields=code,product_name,product_name_fr,brands,brands_tags,'
        'image_url,image_front_url,image_front_small_url,'
        'nutrition_grades,nutrition_grade_fr,categories_tags,'
        'nutriments,quantity,packaging',
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

  /// Organise les catégories en super-catégories
  List<SuperCategory> _organizeCategoriesIntoSuperCategories(
    List<Category> categories,
  ) {
    // Définir les super-catégories avec leurs mots-clés de correspondance
    final superCategoryDefinitions = [
      {
        'id': 'fruits',
        'name': 'Fruits',
        'icon': '🍎',
        'keywords': [
          'fruit',
          'fruits',
          'pomme',
          'orange',
          'banane',
          'fraise',
          'cerise',
          'raisin',
          'citron',
          'pêche',
          'poire',
          'ananas',
          'mangue',
          'kiwi',
          'melon',
        ],
      },
      {
        'id': 'vegetables',
        'name': 'Légumes',
        'icon': '🥕',
        'keywords': [
          'vegetable',
          'vegetables',
          'légume',
          'légumes',
          'carotte',
          'tomate',
          'salade',
          'chou',
          'brocoli',
          'courgette',
          'aubergine',
          'poivron',
          'oignon',
          'ail',
          'épinard',
        ],
      },
      {
        'id': 'meats',
        'name': 'Viandes',
        'icon': '🥩',
        'keywords': [
          'meat',
          'meats',
          'viande',
          'viandes',
          'boeuf',
          'porc',
          'veau',
          'agneau',
          'volaille',
          'poulet',
          'dinde',
          'jambon',
          'saucisse',
          'charcuterie',
        ],
      },
      {
        'id': 'dairy',
        'name': 'Laitages',
        'icon': '🥛',
        'keywords': [
          'dairy',
          'lait',
          'laitage',
          'laitages',
          'fromage',
          'yaourt',
          'yogurt',
          'beurre',
          'crème',
          'fromages',
          'laitages',
        ],
      },
      {
        'id': 'beverages',
        'name': 'Boissons',
        'icon': '🥤',
        'keywords': [
          'beverage',
          'beverages',
          'boisson',
          'boissons',
          'eau',
          'jus',
          'soda',
          'café',
          'thé',
          'infusion',
        ],
      },
      {
        'id': 'cereals',
        'name': 'Céréales',
        'icon': '🌾',
        'keywords': [
          'cereal',
          'cereals',
          'céréale',
          'céréales',
          'pain',
          'pâtes',
          'riz',
          'blé',
          'avoine',
          'orge',
          'quinoa',
        ],
      },
      {
        'id': 'snacks',
        'name': 'Snacks',
        'icon': '🍿',
        'keywords': [
          'snack',
          'snacks',
          'chips',
          'biscuit',
          'biscuits',
          'gâteau',
          'gâteaux',
          'bonbon',
          'bonbons',
          'chocolat',
        ],
      },
      {
        'id': 'fish',
        'name': 'Poissons',
        'icon': '🐟',
        'keywords': [
          'fish',
          'poisson',
          'poissons',
          'saumon',
          'thon',
          'sardine',
          'maquereau',
          'cabillaud',
          'fruits de mer',
          'seafood',
        ],
      },
      {
        'id': 'sweets',
        'name': 'Sucreries',
        'icon': '🍬',
        'keywords': [
          'sweet',
          'sweets',
          'sucrerie',
          'sucreries',
          'confiserie',
          'confiseries',
          'dessert',
          'desserts',
        ],
      },
      {'id': 'other', 'name': 'Autres', 'icon': '📦', 'keywords': []},
    ];

    final Map<String, List<Category>> categorized = {};

    // Initialiser toutes les super-catégories
    for (final def in superCategoryDefinitions) {
      categorized[def['id'] as String] = [];
    }

    // Classer chaque catégorie dans la bonne super-catégorie
    for (final category in categories) {
      final categoryNameLower = category.name.toLowerCase();
      bool isCategorized = false;

      // Chercher dans chaque super-catégorie (sauf "other")
      for (int i = 0; i < superCategoryDefinitions.length - 1; i++) {
        final def = superCategoryDefinitions[i];
        final keywords = def['keywords'] as List<String>;
        for (final keyword in keywords) {
          if (categoryNameLower.contains(keyword.toLowerCase())) {
            categorized[def['id'] as String]!.add(category);
            isCategorized = true;
            break;
          }
        }
        if (isCategorized) break;
      }

      // Si non classée, mettre dans "Autres"
      if (!isCategorized) {
        categorized['other']!.add(category);
      }
    }

    // Créer les super-catégories
    return superCategoryDefinitions
        .map((def) {
          final categoriesList = categorized[def['id'] as String] ?? [];
          return SuperCategory(
            id: def['id'] as String,
            name: def['name'] as String,
            icon: def['icon'] as String,
            categories: categoriesList,
          );
        })
        .where((superCat) => superCat.categories.isNotEmpty)
        .toList();
  }
}
