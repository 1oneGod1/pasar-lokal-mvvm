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
import '../../products/views/product_detail_page.dart';
import '../../sellers/viewmodels/seller_view_model.dart';
import '../../orders/viewmodels/order_view_model.dart';
import 'package:pasar_lokal_mvvm/features/cart/viewmodels/cart_view_model.dart';
import 'package:pasar_lokal_mvvm/features/cart/views/cart_page.dart';
import 'package:pasar_lokal_mvvm/main.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(theme: theme),
          const SizedBox(height: 14),
          _SearchField(theme: theme),
          const SizedBox(height: 22),
          _CategoryScroller(
            categories: categories,
            theme: theme,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (value) => setState(() => _selectedCategoryId = value),
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            title: 'Tetangga Terdekat',
            onViewAll: () => HomeTabScope.maybeOf(context)?.onSelectTab(1),
          ),
          const SizedBox(height: 12),
          if (nearest.isEmpty)
            const _EmptyPlaceholder(
              message: 'Belum ada produk di sekitar Anda.',
            )
          else
            Column(
              children:
                  nearest
                      .take(3)
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _NearestProductCard(
                            product: product,
                            seller: _sellerFor(product, sellers),
                            onTap: () {
                              final store = _sellerFor(product, sellers);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProductDetailPage(
                                        product: product,
                                        seller: store,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 16),
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
    final scheme = theme.colorScheme;
    final cartCount = context.watch<CartViewModel>().itemCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi Anda',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kebayoran Baru',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: scheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Keranjang',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text('$cartCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: () {},
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '2',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
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
    final scheme = theme.colorScheme;

    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari soto, keripik, atau jasa...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
    final scheme = theme.colorScheme;

    final shortcuts = <({String id, String label, IconData icon, Color bg})>[
      (
        id: _DashboardPageState._allCategoryId,
        label: 'Makanan',
        icon: Icons.restaurant_rounded,
        bg: scheme.primary.withValues(alpha: 0.06),
      ),
      (
        id:
            categories.any((c) => c.id == 'cat-spices')
                ? 'cat-spices'
                : _DashboardPageState._allCategoryId,
        label: 'Jajanan',
        icon: Icons.cookie_outlined,
        bg: scheme.secondary.withValues(alpha: 0.06),
      ),
      (
        id:
            categories.any((c) => c.id == 'cat-handicraft')
                ? 'cat-handicraft'
                : _DashboardPageState._allCategoryId,
        label: 'Kerajinan',
        icon: Icons.content_cut_rounded,
        bg: scheme.tertiary.withValues(alpha: 0.06),
      ),
      (
        id:
            categories.any((c) => c.id == 'cat-produce')
                ? 'cat-produce'
                : _DashboardPageState._allCategoryId,
        label: 'Jasa',
        icon: Icons.checkroom_outlined,
        bg: scheme.primaryContainer.withValues(alpha: 0.06),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              shortcuts
                  .map(
                    (item) => _CategoryShortcut(
                      theme: theme,
                      label: item.label,
                      icon: item.icon,
                      backgroundColor: item.bg,
                      selected: selectedCategoryId == item.id,
                      onTap: () => onSelected(item.id),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _CategoryShortcut extends StatelessWidget {
  const _CategoryShortcut({
    required this.theme,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.selected,
    required this.onTap,
  });

  final ThemeData theme;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border:
                    selected
                        ? Border.all(color: scheme.primary, width: 1.4)
                        : null,
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: Icon(Icons.map_outlined, color: scheme.primary),
            label: Text(
              'Lihat Peta',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _NearestProductCard extends StatelessWidget {
  const _NearestProductCard({
    required this.product,
    required this.seller,
    required this.onTap,
  });

  final Product product;
  final Seller? seller;
  final VoidCallback onTap;

  String _compactPrice(double price) {
    if (price >= 1000) {
      final value = (price / 1000).round();
      return 'Rp${value}k';
    }
    return 'Rp${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sellerName = seller?.name ?? 'Warung tetangga';
    final rating = seller?.rating ?? 4.8;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_outlined,
                            color: scheme.outline,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      '0.3 km',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 16,
                              color: scheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                sellerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _compactPrice(product.price),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
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
    final scheme = theme.colorScheme;

    final pendingOrders =
        orders.where((order) => order.status == OrderStatus.pending).toList();
    final completedRevenue = orders
        .where((order) => order.status == OrderStatus.completed)
        .fold<double>(0.0, (sum, order) => sum + order.total);

    final sorted =
        orders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final incoming = sorted.take(6).toList();

    final displayName = (store?.name ?? user.name).trim();
    final greetingName = user.name.split(' ').first;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SellerTopHeader(
                greetingName: greetingName,
                displayName: displayName,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SellerSummaryCard(
                      title: 'Pesanan Baru',
                      value: pendingOrders.length.toString(),
                      backgroundColor: scheme.primaryContainer,
                      titleColor: scheme.primary,
                      valueStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SellerSummaryCard(
                      title: 'Pendapatan',
                      value: _compactRupiah(completedRevenue),
                      backgroundColor: scheme.secondaryContainer,
                      titleColor: scheme.secondary,
                      valueStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan Masuk',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => HomeTabScope.maybeOf(context)?.onSelectTab(2),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (incoming.isEmpty)
                const _EmptyPlaceholder(message: 'Belum ada pesanan masuk.')
              else
                Column(
                  children: [
                    for (final order in incoming) ...[
                      _SellerOrderCard(
                        order: order,
                        onReject:
                            () => context.read<OrderViewModel>().deleteOrder(
                              order.id,
                            ),
                        onAccept:
                            () => context.read<OrderViewModel>().updateStatus(
                              order.id,
                              OrderStatus.processing,
                            ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _SellerTopHeader extends StatelessWidget {
  const _SellerTopHeader({
    required this.greetingName,
    required this.displayName,
  });

  final String greetingName;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initials = _initials(displayName);
    final greeting = _timeGreeting(DateTime.now());

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: scheme.surfaceContainerHighest,
          child: Text(
            initials,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$greetingName 👋',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _NotificationBell(),
      ],
    );
  }

  String _timeGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final list = parts.toList();
    if (list.isEmpty) return '?';
    final first = list.first.characters.first.toUpperCase();
    final second =
        list.length > 1 ? list[1].characters.first.toUpperCase() : '';
    return '$first$second';
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: scheme.error,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SellerSummaryCard extends StatelessWidget {
  const _SellerSummaryCard({
    required this.title,
    required this.value,
    required this.backgroundColor,
    this.titleColor,
    required this.valueStyle,
  });

  final String title;
  final String value;
  final Color backgroundColor;
  final Color? titleColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: titleColor ?? scheme.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  const _SellerOrderCard({
    required this.order,
    required this.onReject,
    required this.onAccept,
  });

  final Order order;
  final VoidCallback onReject;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isCompleted = order.status == OrderStatus.completed;
    final (buyerName, distanceKm, note) = _demoBuyerMeta(order.id);

    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final title =
        firstItem == null
            ? 'Pesanan'
            : '${firstItem.quantity}x ${firstItem.product.name}';
    final subtitle = 'Pemesan: $buyerName (${distanceKm.toStringAsFixed(1)}km)';

    return Opacity(
      opacity: isCompleted ? 0.55 : 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.restaurant, color: scheme.outline),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _OrderStatusChip(status: order.status),
                ],
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                    color: scheme.surface,
                  ),
                  child: Text(
                    '"$note"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                          side: BorderSide(color: scheme.error),
                        ),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        child: const Text('Terima Order'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (String buyerName, double distanceKm, String note) _demoBuyerMeta(
    String seed,
  ) {
    const buyers = ['Mas Rian', 'Mbak Ani', 'Mas Dito', 'Mbak Sasa'];
    const notes = [
      'Bu, sambalnya yang pedes banget ya!',
      'Tolong bungkus rapi ya, makasih!',
      'Kalau bisa cepat ya bu, lagi lapar.',
      'Jangan pakai bawang goreng ya.',
    ];

    final hash = seed.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final buyer = buyers[hash % buyers.length];
    final note = notes[hash % notes.length];
    final distance = 0.2 + ((hash % 7) / 10.0); // 0.2 - 0.8km
    return (buyer, distance, note);
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (label, bg, fg) = switch (status) {
      OrderStatus.pending => (
        'Baru',
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      OrderStatus.processing => (
        'Diproses',
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      OrderStatus.completed => (
        'Selesai',
        scheme.surfaceContainerHighest,
        scheme.outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

String _compactRupiah(double value) {
  final intValue = value.round();
  if (intValue >= 1000000) {
    final jt = intValue / 1000000.0;
    return 'Rp${jt.toStringAsFixed(jt >= 10 ? 0 : 1)}jt';
  }
  if (intValue >= 1000) {
    final rb = (intValue / 1000.0).round();
    return 'Rp${rb}rb';
  }
  return 'Rp$intValue';
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(child: Text(message, textAlign: TextAlign.center)),
    );
  }
}
