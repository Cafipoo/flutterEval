import 'package:flutter/foundation.dart' hide Category;
import '../models/super_category.dart';
import '../services/openfoodfacts_service.dart';

class CategoryProvider with ChangeNotifier {
  final OpenFoodFactsService _service = OpenFoodFactsService();
  List<SuperCategory> _superCategories = [];
  bool _isLoading = false;
  String? _error;

  List<SuperCategory> get superCategories => _superCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSuperCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _superCategories = await _service.getSuperCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des catégories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
