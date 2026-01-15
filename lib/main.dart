import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/repositories/auth_repository.dart';
import 'core/repositories/cart_repository.dart';
import 'core/repositories/category_repository.dart';
import 'core/repositories/map_repository.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/payment_method_repository.dart';
import 'core/repositories/payment_repository.dart';
import 'core/repositories/product_repository.dart';
import 'core/repositories/seller_repository.dart';
import 'core/storage/local_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/widgets/home_tab_scope.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/auth/views/login_page.dart';
import 'features/cart/viewmodels/cart_view_model.dart';
import 'features/categories/viewmodels/category_view_model.dart';
import 'features/dashboard/views/dashboard_page.dart';
import 'features/map/views/map_page.dart';
import 'features/map/viewmodels/map_view_model.dart';
import 'features/orders/viewmodels/order_view_model.dart';
import 'features/orders/views/orders_page.dart';
import 'features/payments/viewmodels/payment_view_model.dart';
import 'features/payments/viewmodels/payment_methods_view_model.dart';
import 'features/products/viewmodels/product_view_model.dart';
import 'features/profile/views/profile_page.dart';
import 'features/sellers/viewmodels/seller_view_model.dart';

ColorScheme _buildColorScheme() {
  return ColorScheme.fromSeed(
    seedColor: const Color(0xFF059669),
    brightness: Brightness.light,
  );
}

void main() {
  runApp(const _Bootstrapper());
}

class _Bootstrapper extends StatefulWidget {
  const _Bootstrapper();

  @override
  State<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<_Bootstrapper> {
  LocalStore? _store;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    final store = await LocalStore.open();
    if (!mounted) {
      return;
    }
    setState(() => _store = store);
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return PasarLokalApp(store: store);
  }
}

class PasarLokalApp extends StatelessWidget {
  const PasarLokalApp({super.key, this.store});

  final LocalStore? store;

  @override
  Widget build(BuildContext context) {
    final scheme = _buildColorScheme();
    final apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthRepository(store: store)),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(CategoryRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SellerViewModel(SellerRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(ProductRepository(store: store)),
        ),
        ChangeNotifierProvider(
          create: (_) => CartViewModel(CartRepository(store: store)),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderViewModel(OrderRepository(store: store)),
        ),
        ChangeNotifierProvider(
          create:
              (_) => PaymentViewModel(PaymentRepository(apiClient: apiClient)),
        ),
        ChangeNotifierProvider(
          create:
              (_) => PaymentMethodsViewModel(
                PaymentMethodRepository(store: store),
              ),
        ),
        ChangeNotifierProvider(create: (_) => MapViewModel(MapRepository())),
      ],
      child: MaterialApp(
        title: 'Pasar Lokal',
        theme: ThemeData(
          colorScheme: scheme,
          useMaterial3: true,
          scaffoldBackgroundColor: scheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: const CardTheme(
            elevation: 1,
            surfaceTintColor: Colors.transparent,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: scheme.inverseSurface,
            contentTextStyle: TextStyle(color: scheme.onInverseSurface),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            indicatorColor: scheme.primary,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color:
                    states.contains(WidgetState.selected)
                        ? Colors.yellow.shade700
                        : scheme.onSurface,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color:
                    states.contains(WidgetState.selected)
                        ? Colors.yellow.shade700
                        : scheme.onSurface,
                fontWeight:
                    states.contains(WidgetState.selected)
                        ? FontWeight.w700
                        : FontWeight.w500,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: scheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: scheme.outline),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _titles = ['', 'Peta', 'Pesanan', 'Akun'];

  @override
  Widget build(BuildContext context) {
    final showAppBar = _selectedIndex != 0;

    void setIndex(int index) {
      if (index == _selectedIndex) {
        return;
      }
      setState(() => _selectedIndex = index);
    }

    return HomeTabScope(
      onSelectTab: setIndex,
      child: Scaffold(
        appBar:
            showAppBar ? AppBar(title: Text(_titles[_selectedIndex])) : null,
        body: switch (_selectedIndex) {
          0 => const DashboardPage(),
          1 => const MapPage(),
          2 => const OrdersPage(),
          _ => const ProfilePage(),
        },
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Peta',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
          onDestinationSelected: setIndex,
        ),
      ),
    );
  }
}
