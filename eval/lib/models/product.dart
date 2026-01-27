class Product {
  final String code;
  final String? productName;
  final String? brand;
  final String? imageUrl;
  final String? nutritionGrade;
  final List<String>? categories;
  final Map<String, dynamic>? nutriments;
  final String? quantity;
  final String? packaging;

  Product({
    required this.code,
    this.productName,
    this.brand,
    this.imageUrl,
    this.nutritionGrade,
    this.categories,
    this.nutriments,
    this.quantity,
    this.packaging,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code']?.toString() ?? '',
      productName: json['product_name'] ?? json['product_name_fr'],
      brand: json['brands'] ?? json['brands_tags']?.first,
      imageUrl: json['image_url'] ?? json['image_front_url'] ?? json['image_front_small_url'],
      nutritionGrade: json['nutrition_grades'] ?? json['nutrition_grade_fr'],
      categories: json['categories_tags'] != null
          ? List<String>.from(json['categories_tags'])
          : (json['categories'] != null ? [json['categories']] : null),
      nutriments: json['nutriments'],
      quantity: json['quantity'],
      packaging: json['packaging'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'product_name': productName,
      'brands': brand,
      'image_url': imageUrl,
      'nutrition_grades': nutritionGrade,
      'categories_tags': categories,
      'nutriments': nutriments,
      'quantity': quantity,
      'packaging': packaging,
    };
  }
}
