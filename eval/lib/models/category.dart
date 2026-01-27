class Category {
  final String id;
  final String name;
  final int? productsCount;

  Category({
    required this.id,
    required this.name,
    this.productsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? json['tag']?.toString() ?? '',
      name: json['name'] ?? json['value'] ?? json['id'] ?? '',
      productsCount: json['products'] ?? json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'products': productsCount,
    };
  }
}
