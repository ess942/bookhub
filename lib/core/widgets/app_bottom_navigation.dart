import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNavigationItem {
  const AppBottomNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.cartItemCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int cartItemCount;

  static const items = [
    AppBottomNavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppBottomNavigationItem(
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      label: 'Favorites',
    ),
    AppBottomNavigationItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart_rounded,
      label: 'Cart',
    ),
    AppBottomNavigationItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      height: 74,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (var index = 0; index < items.length; index++)
          _destination(items[index], index),
      ],
    );
  }

  NavigationDestination _destination(AppBottomNavigationItem item, int index) {
    Widget icon(IconData data) {
      final child = Icon(data);
      if (index != 2 || cartItemCount == 0) return child;
      return Badge(label: Text('$cartItemCount'), child: child);
    }

    return NavigationDestination(
      icon: icon(item.icon),
      selectedIcon: icon(item.selectedIcon),
      label: item.label,
    );
  }
}
