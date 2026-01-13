import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/models/order.dart';
import '../../payments/viewmodels/payment_view_model.dart';
import '../viewmodels/order_view_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final orderViewModel = context.watch<OrderViewModel>();
    final orders = orderViewModel.orders;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child:
          orders.isEmpty
              ? _EmptyOrdersState(theme: theme)
              : ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final itemsDescription = order.items
                      .map((item) => '${item.product.name} x${item.quantity}')
                      .join(', ');
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: scheme.primaryContainer
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '#${order.id.substring(0, 8)}',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'monospace',
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      order.createdAtLabel,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rp ${order.total.toStringAsFixed(0)}',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: scheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status, scheme),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      order.status.label,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: _statusTextColor(
                                              order.status,
                                              scheme,
                                            ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    tooltip: 'Hapus pesanan',
                                    onPressed:
                                        () => _confirmDelete(context, order),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: scheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text(
                            itemsDescription,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed:
                                    () => _checkPayment(context, order.id),
                                icon: const Icon(Icons.payment, size: 18),
                                label: const Text('Cek Pembayaran'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _checkPayment(BuildContext context, String orderId) async {
    final paymentViewModel = context.read<PaymentViewModel>();
    final invoice = await paymentViewModel.refreshByExternalId(orderId);

    if (!context.mounted) return;

    if (invoice == null || !invoice.isValid) {
      final msg = paymentViewModel.errorMessage ?? 'Payment belum ditemukan.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Status pembayaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${invoice.status}'),
                const SizedBox(height: 8),
                const Text('Link pembayaran:'),
                const SizedBox(height: 6),
                SelectableText(invoice.invoiceUrl),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: invoice.invoiceUrl),
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link pembayaran disalin.')),
                  );
                },
                child: const Text('Salin link'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Color _statusColor(OrderStatus status, ColorScheme scheme) {
    switch (status) {
      case OrderStatus.pending:
        return scheme.tertiary.withValues(alpha: 0.2);
      case OrderStatus.processing:
        return scheme.primary.withValues(alpha: 0.2);
      case OrderStatus.completed:
        return Colors.green.withValues(alpha: 0.2);
    }
  }

  Color _statusTextColor(OrderStatus status, ColorScheme scheme) {
    switch (status) {
      case OrderStatus.pending:
        return scheme.tertiary;
      case OrderStatus.processing:
        return scheme.primary;
      case OrderStatus.completed:
        return Colors.green.shade700;
    }
  }

  Future<void> _confirmDelete(BuildContext context, Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Pesanan'),
          content: Text('Hapus pesanan #${order.id.substring(0, 8)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Hapus'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Pesanan #${order.id.substring(0, 8)} dihapus'),
            ],
          ),
        ),
      );
    }
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 70,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Pesanan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Pesanan Anda akan muncul di sini setelah checkout.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
