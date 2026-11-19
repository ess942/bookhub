import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bookhub2/core/theme/app_colors.dart';
import 'package:bookhub2/features/cart/presentation/screens/cart_screen.dart';
import 'package:bookhub2/features/catalog/presentation/screens/home_screen.dart';
import 'package:bookhub2/features/profile/presentation/screens/profile_screen.dart';
import 'package:bookhub2/features/library/presentation/screens/my_favorites_screen.dart';
import 'package:bookhub2/core/widgets/app_bottom_navigation.dart';
import 'package:bookhub2/features/auth/presentation/providers/auth_providers.dart';
import 'package:bookhub2/features/cart/presentation/providers/cart_providers.dart';

import 'router/app_router.dart';

class MainBookHubShell extends ConsumerStatefulWidget {
  const MainBookHubShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainBookHubShell> createState() => _MainBookHubShellState();
}

class _MainBookHubShellState extends ConsumerState<MainBookHubShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    final cartItems = user == null
        ? null
        : ref.watch(cartItemsProvider(user.id)).value;
    final cartItemCount =
        cartItems?.fold<int>(0, (total, line) => total + line.quantity) ?? 0;
    final pages = const <Widget>[
      HomeScreen(),
      MyFavoritesScreen(),
      CartScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: AppBottomNavigation(
            selectedIndex: _selectedIndex,
            cartItemCount: cartItemCount,
            onDestinationSelected: (index) {
              if (index == _selectedIndex) {
                return;
              }
              setState(() => _selectedIndex = index);

              switch (index) {
                case 0:
                  context.go(AppRouter.home);
                  break;
                case 1:
                  context.go(AppRouter.favorites);
                  break;
                case 2:
                  context.go(AppRouter.cart);
                  break;
                case 3:
                  context.go(AppRouter.profile);
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
