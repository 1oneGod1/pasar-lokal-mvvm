import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/home_tab_scope.dart';
import '../../categories/viewmodels/category_view_model.dart';
import '../../products/viewmodels/product_view_model.dart';
import '../../sellers/viewmodels/seller_view_model.dart';

class SellerCatalogPage extends StatelessWidget {
  const SellerCatalogPage({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final productViewModel = context.watch<ProductViewModel>();
    final categoryViewModel = context.watch<CategoryViewModel>();
    final sellerViewModel = context.watch<SellerViewModel>();
    final sellerName = sellerViewModel.findById(sellerId)?.name ?? 'Toko Anda';

    final products =
        productViewModel.products
            .where((product) => product.sellerId == sellerId)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Katalog $sellerName'),
        actions: [
          TextButton.icon(
            onPressed: () {
              final tabScope = HomeTabScope.maybeOf(context);
              tabScope?.onSelectTab(0);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Kelola'),
          ),
        ],
      ),
      body:
          products.isEmpty
              ? _EmptyCatalogState(sellerName: sellerName)
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final category =
                      categoryViewModel.findById(product.categoryId)?.name ??
                      'Kategori belum diatur';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(category),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${product.price.toStringAsFixed(0)} • Stok ${product.stock}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            if (product.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  product.description,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState({required this.sellerName});

  final String sellerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              'Belum ada produk di katalog $sellerName.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk dari halaman Kelola toko.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
