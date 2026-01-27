import 'category.dart';

class SuperCategory {
  final String id;
  final String name;
  final String icon;
  final List<Category> categories;

  SuperCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.categories,
  });

  int get totalProducts {
    return categories.fold(
      0,
      (sum, category) => sum + (category.productsCount ?? 0),
    );
  }
}
