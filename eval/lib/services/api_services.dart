import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  Future<Product?> fetchProduct(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return Product.fromJson(data['product']);
        }
      }
    } catch (e) {
      print("Erreur API: $e");
    }
    return null;
  }
}