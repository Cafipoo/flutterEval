class Category {
  final String id;
  final String name;
  final String icon;
  final int? productsCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.productsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? json['tag']?.toString() ?? '',
      name: json['name'] ?? json['value'] ?? json['id'] ?? '',
      icon: json['icon'] ?? '📦',
      productsCount: json['products'] ?? json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'products': productsCount,
    };
  }
}
