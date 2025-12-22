import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../viewmodels/order_view_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderViewModel = context.watch<OrderViewModel>();
    final orders = orderViewModel.orders;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child:
          orders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final itemsDescription = order.items
                      .map((item) => '${item.product.name} x${item.quantity}')
                      .join(', ');
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ${order.id}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Created ${order.createdAtLabel}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Rp ${order.total.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DropdownButton<OrderStatus>(
                                    value: order.status,
                                    items:
                                        OrderStatus.values
                                            .map(
                                              (status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(status.label),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (status) {
                                      if (status == null ||
                                          status == order.status) {
                                        return;
                                      }
                                      context
                                          .read<OrderViewModel>()
                                          .updateStatus(order.id, status);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Order ${order.id} is now ${status.label}.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Delete order',
                                    onPressed:
                                        () => _confirmDelete(context, order),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemsDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: Text('Delete order ${order.id}?'),
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

    if (!context.mounted) {
      return;
    }

    if (confirmed == true) {
      context.read<OrderViewModel>().deleteOrder(order.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order ${order.id} deleted.')));
    }
  }
}
