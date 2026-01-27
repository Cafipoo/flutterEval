import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scanned_products_provider.dart';
import '../widgets/product_card.dart';
import '../pages/product_detail_page.dart';
import '../pages/scan_pages.dart';

class ScannedProductsPage extends StatelessWidget {
  const ScannedProductsPage({super.key});

  void _scanProduct(BuildContext context) async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScanPage()),
    );

    if (scannedCode != null && context.mounted) {
      final provider = context.read<ScannedProductsProvider>();
      final product = await provider.scanAndAddProduct(scannedCode);

      if (product == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit inconnu : $scannedCode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📷 Mes produits scannés'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<ScannedProductsProvider>(
            builder: (context, provider, child) {
              if (provider.scannedProducts.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Tout supprimer',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmer'),
                      content: const Text(
                        'Voulez-vous supprimer tous les produits scannés ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearAll();
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ScannedProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.scannedProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.scannedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun produit scanné',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur le bouton pour scanner un produit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: provider.scannedProducts.length,
                itemBuilder: (context, index) {
                  final product = provider.scannedProducts[index];
                  return Dismissible(
                    key: Key(product.code),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      provider.removeProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.productName ?? "Produit"} supprimé'),
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scanProduct(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('SCANNER'),
      ),
    );
  }
}
