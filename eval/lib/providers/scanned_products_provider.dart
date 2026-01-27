import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_services.dart';

class ScannedProductsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Product> _scannedProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get scannedProducts => _scannedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _scannedProducts.length;

  Future<Product?> scanAndAddProduct(String barcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _apiService.fetchProduct(barcode);
      
      if (product != null) {
        // Vérifier si le produit n'est pas déjà dans la liste
        final exists = _scannedProducts.any((p) => p.code == product.code);
        if (!exists) {
          _scannedProducts.insert(0, product);
        }
      } else {
        _error = 'Produit non trouvé: $barcode';
      }
      
      _isLoading = false;
      notifyListeners();
      return product;
    } catch (e) {
      _error = 'Erreur lors du scan: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void removeProduct(Product product) {
    _scannedProducts.removeWhere((p) => p.code == product.code);
    notifyListeners();
  }

  void clearAll() {
    _scannedProducts.clear();
    notifyListeners();
  }
}
