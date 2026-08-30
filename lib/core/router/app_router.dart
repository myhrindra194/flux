import 'package:api/features/auth/presentation/providers/auth_notifier.dart';
import 'package:api/features/auth/presentation/screens/home_screen.dart';
import 'package:api/features/auth/presentation/screens/login_screen.dart';
import 'package:api/features/auth/presentation/screens/register_screen.dart';
import 'package:api/features/products/presentation/screens/product_detail_screen.dart';
import 'package:api/features/products/presentation/screens/product_search_screen.dart';
import 'package:api/features/products/presentation/screens/products_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',

    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),

      GoRoute(
        path: '/products',
        builder: (context, state) {
          return const ProductsScreen();
        },
      ),

      GoRoute(
        path: '/products/search',
        builder: (context, state) {
          return const ProductSearchScreen();
        },
      ),

      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);

          return ProductDetailScreen(productId: id);
        },
      ),
    ],
  );
});
