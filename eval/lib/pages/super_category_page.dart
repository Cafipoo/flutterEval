import 'package:flutter/material.dart';
import '../models/super_category.dart';
import '../pages/category_products_page.dart';

class SuperCategoryPage extends StatelessWidget {
  final SuperCategory superCategory;

  const SuperCategoryPage({
    super.key,
    required this.superCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${superCategory.icon} ${superCategory.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: superCategory.categories.isEmpty
          ? const Center(
              child: Text('Aucune catégorie disponible'),
            )
          : ListView.builder(
              itemCount: superCategory.categories.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final category = superCategory.categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        category.name.isNotEmpty
                            ? category.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: category.productsCount != null
                        ? Text('${category.productsCount} produits')
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsPage(
                            categoryName: category.name,
                            categoryId: category.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
