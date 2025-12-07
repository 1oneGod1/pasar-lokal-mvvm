import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/category.dart';
import '../../../core/models/order.dart';
import '../../../core/models/product.dart';
import '../../../core/models/seller.dart';
import '../../../core/models/user.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../../categories/viewmodels/category_view_model.dart';
import '../../products/viewmodels/product_view_model.dart';
import '../../sellers/viewmodels/seller_view_model.dart';
import '../../orders/viewmodels/order_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _allCategoryId = 'all';
  String _selectedCategoryId = _allCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = context.watch<CategoryViewModel>().categories;
    final products = context.watch<ProductViewModel>().products;
    final sellers = context.watch<SellerViewModel>().sellers;
    final orders = context.watch<OrderViewModel>().orders;
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;

    if (user != null && user.isSeller && user.sellerId != null) {
      final sellerId = user.sellerId!;
      final sellerProducts =
          products.where((product) => product.sellerId == sellerId).toList();
      final sellerOrders =
          orders
              .where(
                (order) => order.items.any(
                  (item) => item.product.sellerId == sellerId,
                ),
              )
              .toList();

      Seller? store;
      try {
        store = sellers.firstWhere((seller) => seller.id == sellerId);
      } catch (_) {
        store = null;
      }

      return _SellerDashboard(
        theme: theme,
        user: user,
        store: store,
        products: sellerProducts,
        orders: sellerOrders,
      );
    }

    final filteredProducts =
        _selectedCategoryId == _allCategoryId
            ? products.toList()
            : products
                .where((product) => product.categoryId == _selectedCategoryId)
                .toList();

    final nearest = filteredProducts.take(6).toList();
    final recommendations = filteredProducts.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(theme: theme),
          const SizedBox(height: 16),
          _SearchField(theme: theme),
          const SizedBox(height: 20),
          _CategoryScroller(
            categories: categories,
            theme: theme,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (value) {
              setState(() => _selectedCategoryId = value);
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'PALING DEKAT', onViewAll: () {}),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child:
                nearest.isEmpty
                    ? const _EmptyPlaceholder(
                      message: 'Belum ada produk di sekitar Anda.',
                    )
                    : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: nearest.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = nearest[index];
                        final seller = _sellerFor(product, sellers);
                        return _NearestProductCard(
                          product: product,
                          seller: seller,
                        );
                      },
                    ),
          ),
          const SizedBox(height: 28),
          Text(
            'REKOMENDASI TETANGGA',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 16),
          if (recommendations.isEmpty)
            const _EmptyPlaceholder(
              message: 'Tambah produk untuk melihat rekomendasi.',
            )
          else
            Column(
              children:
                  recommendations
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RecommendationCard(
                            product: product,
                            seller: _sellerFor(product, sellers),
                          ),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Seller? _sellerFor(Product product, List<Seller> sellers) {
    try {
      return sellers.firstWhere((seller) => seller.id == product.sellerId);
    } catch (_) {
      return null;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOKASI SAAT INI',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Jl. Cendrawasih No. 10',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '< 3 KM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari jajanan tetangga...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.tune_rounded),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _CategoryScroller extends StatelessWidget {
  const _CategoryScroller({
    required this.categories,
    required this.theme,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final ThemeData theme;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'Semua',
            isSelected:
                selectedCategoryId == _DashboardPageState._allCategoryId,
            onTap: () => onSelected(_DashboardPageState._allCategoryId),
          ),
          const SizedBox(width: 8),
          ...categories.map((category) {
            final isSelected = category.id == selectedCategoryId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: category.name,
                isSelected: isSelected,
                onTap: () => onSelected(category.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: Colors.black, width: 1.4),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            Text(
              'Siap antar dalam hitungan menit',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: const Text('Lihat Semua')),
      ],
    );
  }
}

class _NearestProductCard extends StatelessWidget {
  const _NearestProductCard({required this.product, required this.seller});

  final Product product;
  final Seller? seller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 140,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                seller?.name ?? 'Warung tetangga',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _priceLabel(product.price),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.product, required this.seller});

  final Product product;
  final Seller? seller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child:
                product.imageUrl.isEmpty
                    ? Container(
                      color: Colors.black.withValues(alpha: 0.08),
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    )
                    : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: Colors.black.withValues(alpha: 0.08),
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black,
                      child: Text(
                        seller == null ? '?' : seller!.name.characters.first,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller?.name ?? 'Tetangga',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'JARAK 0.${(product.price % 5).round() + 2} KM',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 18),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _priceLabel(product.price),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Chat')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Beli'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerDashboard extends StatelessWidget {
  const _SellerDashboard({
    required this.theme,
    required this.user,
    required this.store,
    required this.products,
    required this.orders,
  });

  final ThemeData theme;
  final User user;
  final Seller? store;
  final List<Product> products;
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final totalStock = products.fold<int>(
      0,
      (sum, product) => sum + product.stock,
    );
    final averagePrice =
        products.isEmpty
            ? 0.0
            : products.fold<double>(
                  0.0,
                  (sum, product) => sum + product.price,
                ) /
                products.length;
    final totalInventoryValue = products.fold<double>(
      0.0,
      (sum, product) => sum + (product.price * product.stock),
    );
    final pendingCount =
        orders.where((order) => order.status == OrderStatus.pending).length;
    final processingCount =
        orders.where((order) => order.status == OrderStatus.processing).length;
    final completedCount =
        orders.where((order) => order.status == OrderStatus.completed).length;
    final revenue = orders.fold<double>(0.0, (sum, order) => sum + order.total);

    final greetingName = user.name.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Penjual',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Halo $greetingName, pantau performa tokomu hari ini.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.black,
                        child: Text(
                          (store?.name ?? user.name).isNotEmpty
                              ? (store?.name ?? user.name)[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store?.name ?? 'Toko belum ditautkan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store?.location ??
                                  'Hubungi admin untuk menautkan toko.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (store != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                store!.rating.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.store_mall_directory_outlined),
                          label: const Text('Lihat etalase'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Tambah produk'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SellerStatCard(
                title: 'Produk aktif',
                value: products.length.toString(),
                subtitle: 'Total listing',
              ),
              _SellerStatCard(
                title: 'Total stok',
                value: totalStock.toString(),
                subtitle: 'Unit tersedia',
              ),
              _SellerStatCard(
                title: 'Harga rata-rata',
                value: _priceLabel(averagePrice),
                subtitle: 'Per produk',
              ),
              _SellerStatCard(
                title: 'Nilai stok',
                value: _priceLabel(totalInventoryValue),
                subtitle: 'Estimasi rupiah',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SellerOrdersSummary(
            theme: theme,
            pending: pendingCount,
            processing: processingCount,
            completed: completedCount,
            revenue: revenue,
          ),
          const SizedBox(height: 20),
          _SellerProductList(theme: theme, products: products),
        ],
      ),
    );
  }
}

class _SellerStatCard extends StatelessWidget {
  const _SellerStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerOrdersSummary extends StatelessWidget {
  const _SellerOrdersSummary({
    required this.theme,
    required this.pending,
    required this.processing,
    required this.completed,
    required this.revenue,
  });

  final ThemeData theme;
  final int pending;
  final int processing;
  final int completed;
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Pesanan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OrderStatusPill(
                    label: 'Pending',
                    value: pending,
                    icon: Icons.watch_later_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OrderStatusPill(
                    label: 'Proses',
                    value: processing,
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OrderStatusPill(
                    label: 'Selesai',
                    value: completed,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Potensi omzet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _priceLabel(revenue),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('$value pesanan', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerProductList extends StatelessWidget {
  const _SellerProductList({required this.theme, required this.products});

  final ThemeData theme;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produk Anda',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Kelola')),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              const _EmptyPlaceholder(
                message: 'Tambah produk pertama Anda untuk mulai berjualan.',
              )
            else
              Column(
                children:
                    products
                        .map(
                          (product) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SellerProductTile(product: product),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _SellerProductTile extends StatelessWidget {
  const _SellerProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        title: Text(
          product.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${_priceLabel(product.price)} • Stok ${product.stock}'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () {},
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}

String _priceLabel(double price) {
  return 'Rp ${price.toStringAsFixed(0)}';
}
