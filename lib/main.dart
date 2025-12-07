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

ColorScheme _buildGrayscaleScheme() {
  final base = ColorScheme.fromSeed(
    seedColor: Colors.black,
    brightness: Brightness.light,
  );

  return base.copyWith(
    primary: Colors.black,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF1A1A1A),
    onPrimaryContainer: Colors.white,
    secondary: const Color(0xFF3C3C3C),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFF5A5A5A),
    onSecondaryContainer: Colors.white,
    tertiary: const Color(0xFF707070),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFF9E9E9E),
    onTertiaryContainer: Colors.black,
    surface: Colors.white,
    surfaceTint: Colors.black,
    surfaceContainerHighest: const Color(0xFFE0E0E0),
    outline: const Color(0xFF8D8D8D),
    outlineVariant: const Color(0xFFBDBDBD),
    inversePrimary: Colors.white,
  );
}

void main() {
  runApp(const PasarLokalApp());
}

class PasarLokalApp extends StatelessWidget {
  const PasarLokalApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          colorScheme: _buildGrayscaleScheme(),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: const CardTheme(
            color: Colors.white,
            elevation: 1,
            surfaceTintColor: Colors.transparent,
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xFFD6D6D6);
                }
                return Colors.black;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xFF7A7A7A);
                }
                return Colors.white;
              }),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.black),
              side: WidgetStateProperty.all(
                const BorderSide(color: Colors.black, width: 1.2),
              ),
            ),
          ),
          tabBarTheme: const TabBarTheme(
            labelColor: Colors.black,
            unselectedLabelColor: Color(0xFF5A5A5A),
            indicatorColor: Colors.black,
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.black,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color:
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.black,
              ),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color:
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8D8D8D)),
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

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(_titles[_selectedIndex])) : null,
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
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
