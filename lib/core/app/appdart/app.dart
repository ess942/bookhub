import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../../../features/settings/presentation/providers/settings_providers.dart';

/// [BookHubApp] هو الـ Widget الجذرية لتطبيق BookHub
/// تربط نظام التصميم (Material 3) ونظام التوجيه (GoRouter) معاً.
class BookHubApp extends ConsumerWidget {
  const BookHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider).value;
    return MaterialApp.router(
      title: 'BookHub',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: preferences?.darkMode == true
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }
}
