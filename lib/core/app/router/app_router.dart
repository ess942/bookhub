import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bookhub2/core/app/app_shell.dart';
import 'package:bookhub2/features/checkout/domain/entities/checkout_receipt.dart';
import 'package:bookhub2/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:bookhub2/features/checkout/presentation/screens/order_confirmation_screen.dart';
import 'package:bookhub2/features/catalog/presentation/screens/book_details_screen.dart'
    as catalog;
import 'package:bookhub2/features/catalog/presentation/screens/catalog_search_screen.dart';
import 'package:bookhub2/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:bookhub2/features/auth/presentation/pages/login_screen.dart';
import 'package:bookhub2/features/auth/presentation/pages/register_screen.dart';
import 'package:bookhub2/features/auth/presentation/pages/splash_screen.dart';
import 'package:bookhub2/features/library/presentation/screens/my_library_screen.dart';
import 'package:bookhub2/features/library/presentation/screens/my_orders_screen.dart';
import 'package:bookhub2/features/settings/presentation/screens/settings_screen.dart';
import 'package:bookhub2/core/gallery/component_gallery_page.dart';

class AuthRouterRefresh extends ChangeNotifier {
  StreamSubscription<User?>? _subscription;

  void start() {
    if (Firebase.apps.isEmpty || _subscription != null) return;
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

abstract final class AppRouter {
  static const String home = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String bookDetails = '/book/:bookId';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String library = '/library';
  static const String favorites = '/favorites';
  static const String myOrders = '/my-orders';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String gallery = '/gallery';

  static final AuthRouterRefresh authRefresh = AuthRouterRefresh();
  static String bookDetailsPath(String bookId) => '/book/$bookId';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;
      if (Firebase.apps.isEmpty) {
        return path == splash ? null : splash;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (path == splash) return currentUser == null ? login : home;
      final isAuthRoute =
          path == login || path == register || path == forgotPassword;
      final isProtectedRoute = {library, profile, settings}.contains(path);
      final isGuestAllowedRoute = {
        cart,
        checkout,
        myOrders,
        favorites,
      }.contains(path);

      if (!isAuthRoute && isProtectedRoute && currentUser == null) {
        return login;
      }

      // Registration stays visible after Auth succeeds but profile persistence fails.
      if (path == register) return null;

      if (isGuestAllowedRoute) {
        return null;
      }

      if ((path == login || path == forgotPassword) && currentUser != null) {
        return home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainBookHubShell(initialIndex: 0),
      ),
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => CatalogSearchScreen(
          initialCategoryId: state.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: bookDetails,
        name: 'bookDetails',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId'] ?? '';
          return catalog.BookDetailsScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: cart,
        name: 'cart',
        builder: (context, state) => const MainBookHubShell(initialIndex: 2),
      ),
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: orderConfirmation,
        name: 'orderConfirmation',
        builder: (context, state) {
          final receipt = state.extra;
          if (receipt is CheckoutReceipt) {
            return OrderConfirmationScreen(receipt: receipt);
          }
          return const Scaffold(
            body: Center(child: Text('Order confirmation is unavailable.')),
          );
        },
      ),
      GoRoute(
        path: library,
        name: 'library',
        builder: (context, state) => const MyLibraryScreen(),
      ),
      GoRoute(
        path: favorites,
        name: 'favorites',
        builder: (context, state) => const MainBookHubShell(initialIndex: 1),
      ),
      GoRoute(
        path: myOrders,
        name: 'myOrders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const MainBookHubShell(initialIndex: 3),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: gallery,
        name: 'gallery',
        builder: (context, state) => const ComponentGalleryPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404 - Page Not Found!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
