import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../orders/viewmodels/order_view_model.dart';
import '../viewmodels/cart_view_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final items = cartViewModel.items;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Expanded(
            child:
                items.isEmpty
                    ? const Center(child: Text('Your cart is empty.'))
                    : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed:
                                          () => cartViewModel.remove(item.id),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Price: Rp ${item.product.price.toStringAsFixed(0)}',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed:
                                          () => cartViewModel.decrementQuantity(
                                            item.id,
                                          ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text('Qty ${item.quantity}'),
                                    IconButton(
                                      onPressed:
                                          () => cartViewModel.incrementQuantity(
                                            item.id,
                                          ),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Subtotal Rp ${item.subtotal.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items: ${cartViewModel.itemCount}'),
                  const SizedBox(height: 4),
                  Text(
                    'Total: Rp ${cartViewModel.total.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: items.isEmpty ? null : cartViewModel.clear,
                        child: const Text('Clear Cart'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed:
                            items.isEmpty
                                ? null
                                : () => _handleCheckout(context, cartViewModel),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Checkout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartViewModel cartViewModel) {
    final order = cartViewModel.checkout();
    if (order == null) {
      return;
    }

    context.read<OrderViewModel>().addOrder(order);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order ${order.id} created.')));
  }
}
