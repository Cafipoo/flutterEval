import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            if (product.imageUrl != null)
              Center(
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Nom du produit
            Text(
              product.productName ?? 'Nom non disponible',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Code-barres
            Text(
              'Code-barres: ${product.code}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // Nutri-Score
            if (product.nutritionGrade != null)
              Card(
                color: _getNutriScoreColor(product.nutritionGrade!),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Nutri-Score: ',
                        style: TextStyle(
                          color: _getNutriScoreTextColor(product.nutritionGrade!),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.nutritionGrade!.toUpperCase(),
                        style: TextStyle(
                          color: _getNutriScoreTextColor(product.nutritionGrade!),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Marque
            if (product.brand != null)
              _buildInfoRow('Marque', product.brand!),

            // Quantité
            if (product.quantity != null)
              _buildInfoRow('Quantité', product.quantity!),

            // Catégories
            if (product.categories != null && product.categories!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catégories:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.categories!
                        .map((category) => Chip(
                              label: Text(category),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Nutriments
            if (product.nutriments != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valeurs nutritionnelles (pour 100g)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...product.nutriments!.entries
                          .where((entry) => entry.key.contains('_100g'))
                          .take(10)
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatNutrientName(entry.key),
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.value} ${_getNutrientUnit(entry.key)}',
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getNutriScoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.yellow;
      case 'd':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getNutriScoreTextColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
      case 'b':
      case 'c':
        return Colors.black;
      case 'd':
      case 'e':
        return Colors.white;
      default:
        return Colors.black;
    }
  }

  String _formatNutrientName(String key) {
    return key
        .replaceAll('_100g', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getNutrientUnit(String key) {
    if (key.contains('energy')) {
      return 'kJ';
    } else if (key.contains('sodium') || key.contains('salt')) {
      return 'g';
    } else {
      return 'g';
    }
  }
}
