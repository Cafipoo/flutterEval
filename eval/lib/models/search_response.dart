import 'product.dart';

class SearchResponse {
  final int count;
  final int page;
  final int pageCount;
  final int pageSize;
  final List<Product> products;

  SearchResponse({
    required this.count,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.products,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      count: json['count'] ?? 0,
      page: json['page'] ?? 1,
      pageCount: json['page_count'] ?? 0,
      pageSize: json['page_size'] ?? 24,
      products: (json['products'] as List<dynamic>?)
              ?.map((product) => Product.fromJson(product as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
