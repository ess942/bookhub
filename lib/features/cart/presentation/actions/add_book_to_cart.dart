import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cart_providers.dart';

Future<void> addBookToCart({
  required BuildContext context,
  required WidgetRef ref,
  required String bookId,
  required String title,
}) async {
  final user = ref.read(authControllerProvider).user;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in to add books to your cart.')),
    );
    context.go(AppRouter.login);
    return;
  }

  try {
    await ref.read(addCartItemProvider)(uid: user.id, bookId: bookId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title added to your cart.')));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
