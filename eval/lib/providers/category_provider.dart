import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/openfoodfacts_service.dart';

class CategoryProvider with ChangeNotifier {
  final OpenFoodFactsService _service = OpenFoodFactsService();
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des catégories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
