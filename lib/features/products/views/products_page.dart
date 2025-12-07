import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/product.dart';
import '../../cart/viewmodels/cart_view_model.dart';
import '../../categories/viewmodels/category_view_model.dart';
import '../viewmodels/product_view_model.dart';
import '../../sellers/viewmodels/seller_view_model.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final categoryViewModel = context.watch<CategoryViewModel>();
    final sellerViewModel = context.watch<SellerViewModel>();
    final products = productViewModel.products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _openProductForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                products.isEmpty
                    ? const Center(child: Text('No products available yet.'))
                    : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final category =
                            categoryViewModel
                                .findById(product.categoryId)
                                ?.name ??
                            'Unknown category';
                        final seller =
                            sellerViewModel.findById(product.sellerId)?.name ??
                            'Unknown seller';
                        return Card(
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$category • $seller'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)} • Stock ${product.stock}',
                                  ),
                                  if (product.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        product.description,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Add to cart',
                                  onPressed: () {
                                    context.read<CartViewModel>().addToCart(
                                      product,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit product',
                                  onPressed:
                                      () => _openProductForm(
                                        context,
                                        product: product,
                                      ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete product',
                                  onPressed:
                                      () => _confirmDelete(context, product),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProductForm(
    BuildContext context, {
    Product? product,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final categoryViewModel = context.read<CategoryViewModel>();
    final sellerViewModel = context.read<SellerViewModel>();

    if (categoryViewModel.categories.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Create a category first.')),
      );
      return;
    }

    if (sellerViewModel.sellers.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Create a seller first.')),
      );
      return;
    }

    final productViewModel = context.read<ProductViewModel>();

    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: product != null ? product.stock.toString() : '',
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    String? selectedCategoryId =
        product?.categoryId ?? categoryViewModel.categories.first.id;
    String? selectedSellerId =
        product?.sellerId ?? sellerViewModel.sellers.first.id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogInnerContext, setState) {
            return AlertDialog(
              title: Text(product == null ? 'Add Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (IDR)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items:
                          categoryViewModel.categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => selectedCategoryId = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSellerId,
                      decoration: const InputDecoration(labelText: 'Seller'),
                      items:
                          sellerViewModel.sellers
                              .map(
                                (seller) => DropdownMenuItem(
                                  value: seller.id,
                                  child: Text(seller.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => selectedSellerId = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final parsedPrice = double.tryParse(
                      priceController.text.trim(),
                    );
                    final parsedStock = int.tryParse(
                      stockController.text.trim(),
                    );

                    if (name.isEmpty ||
                        parsedPrice == null ||
                        parsedStock == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'All fields must be filled with valid values.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (selectedCategoryId == null ||
                        selectedSellerId == null) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Please choose a category and seller.'),
                        ),
                      );
                      return;
                    }

                    final updatedProduct = Product(
                      id:
                          product?.id ??
                          'prod-${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      categoryId: selectedCategoryId!,
                      sellerId: selectedSellerId!,
                      price: parsedPrice,
                      stock: parsedStock,
                      description: descriptionController.text.trim(),
                    );

                    if (product == null) {
                      productViewModel.addProduct(updatedProduct);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('${updatedProduct.name} added.'),
                        ),
                      );
                    } else {
                      productViewModel.updateProduct(updatedProduct);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('${updatedProduct.name} updated.'),
                        ),
                      );
                    }

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Delete ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<ProductViewModel>().deleteProduct(product.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${product.name} deleted.')));
    }
  }
}
