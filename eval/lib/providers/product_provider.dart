import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/openfoodfacts_service.dart';

class ProductProvider with ChangeNotifier {
  final OpenFoodFactsService _service = OpenFoodFactsService();
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;
  static const int _pageSize = 24;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadProductsByCategory(String category, {bool refresh = false}) async {
    if (refresh) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getProductsByCategory(
        category,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _products = response.products;
      } else {
        _products.addAll(response.products);
      }

      _hasMore = _currentPage < response.pageCount;
      _currentPage++;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des produits: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
}
