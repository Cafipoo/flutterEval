import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;

  bool isFavorite(String productCode) {
    return _favorites.any((p) => p.code == productCode);
  }

  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere((p) => p.code == product.code);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.insert(0, product);
    }
    notifyListeners();
  }

  void addFavorite(Product product) {
    if (!isFavorite(product.code)) {
      _favorites.insert(0, product);
      notifyListeners();
    }
  }

  void removeFavorite(String productCode) {
    _favorites.removeWhere((p) => p.code == productCode);
    notifyListeners();
  }

  void clearAll() {
    _favorites.clear();
    notifyListeners();
  }
}
