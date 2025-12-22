import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/repositories/auth_repository.dart';
import 'core/repositories/cart_repository.dart';
import 'core/repositories/category_repository.dart';
import 'core/repositories/map_repository.dart';
import 'core/repositories/order_repository.dart';
import 'core/repositories/product_repository.dart';
import 'core/repositories/seller_repository.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/auth/views/login_page.dart';
import 'features/cart/viewmodels/cart_view_model.dart';
import 'features/categories/viewmodels/category_view_model.dart';
import 'features/dashboard/views/dashboard_page.dart';
import 'features/map/views/map_page.dart';
import 'features/map/viewmodels/map_view_model.dart';
import 'features/orders/viewmodels/order_view_model.dart';
import 'features/orders/views/orders_page.dart';
import 'features/products/viewmodels/product_view_model.dart';
import 'features/profile/views/profile_page.dart';
import 'features/sellers/viewmodels/seller_view_model.dart';

ColorScheme _buildColorScheme() {
  return ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  );
}

void main() {
  runApp(const PasarLokalApp());
}

class PasarLokalApp extends StatelessWidget {
  const PasarLokalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = _buildColorScheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthRepository())),
        ChangeNotifierProvider(
          create: (_) => CategoryViewModel(CategoryRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SellerViewModel(SellerRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(ProductRepository()),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel(CartRepository())),
        ChangeNotifierProvider(
          create: (_) => OrderViewModel(OrderRepository()),
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
                        ? scheme.onPrimary
                        : scheme.onSurface,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color:
                    states.contains(WidgetState.selected)
                        ? scheme.onPrimary
                        : scheme.onSurface,
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
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            DashboardPage(),
            MapPage(),
            OrdersPage(),
            ProfilePage(),
          ],
        ),
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

class HomeTabScope extends InheritedWidget {
  const HomeTabScope({
    super.key,
    required this.onSelectTab,
    required super.child,
  });

  final ValueChanged<int> onSelectTab;

  static HomeTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeTabScope>();
  }

  @override
  bool updateShouldNotify(HomeTabScope oldWidget) {
    return oldWidget.onSelectTab != onSelectTab;
  }
}
