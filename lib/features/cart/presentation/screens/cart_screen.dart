import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_book_cover.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../checkout/domain/entities/checkout_pricing.dart';
import '../../domain/entities/cart_line.dart';
import '../providers/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: user == null
          ? const ScreenState.empty(
              message: 'Sign in to view and sync your cart.',
            )
          : ref
                .watch(cartItemsProvider(user.id))
                .when(
                  loading: () => const ScreenState.loading(),
                  error: (error, _) => ScreenState.error(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(cartItemsProvider(user.id)),
                  ),
                  data: (items) => items.isEmpty
                      ? const ScreenState.empty(message: 'Your cart is empty.')
                      : _CartContents(uid: user.id, items: items),
                ),
    );
  }
}

class _CartContents extends ConsumerWidget {
  const _CartContents({required this.uid, required this.items});

  final String uid;
  final List<CartLine> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = items.fold<double>(0, (sum, line) => sum + line.total);
    final deliveryFee = CheckoutPricing.deliveryFee;
    final hasUnavailableItems = items.any((line) => !line.isAvailable);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            if (hasUnavailableItems)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Text(
                  'Some cart items are unavailable or exceed current stock. '
                  'Remove them or adjust their quantities before checkout.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _CartLineTile(uid: uid, line: items[index]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _TotalRow(label: 'Subtotal', value: subtotal),
                  const SizedBox(height: AppSpacing.sm),
                  _TotalRow(label: 'Delivery', value: deliveryFee),
                  const Divider(height: AppSpacing.xl),
                  _TotalRow(
                    label: 'Total',
                    value: subtotal + deliveryFee,
                    isTotal: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Proceed to Checkout',
                    onPressed: hasUnavailableItems
                        ? null
                        : () => context.push(AppRouter.checkout),
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

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.uid, required this.line});

  final String uid;
  final CartLine line;

  Future<void> _perform(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = line.book;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 88,
            child: AsyncBookCover(coverUrl: book?.coverUrl, height: 88),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book?.title ?? 'Book unavailable',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (book != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PriceText(price: book.price),
                  if (!line.isAvailable)
                    const Text(
                      'Not enough stock',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove item',
            onPressed: () => _perform(
              context,
              () => ref.read(removeCartItemProvider)(
                uid: uid,
                bookId: line.bookId,
              ),
            ),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Increase quantity',
                onPressed: book == null || line.quantity >= book.stock
                    ? null
                    : () => _perform(
                        context,
                        () => ref.read(setCartQuantityProvider)(
                          uid: uid,
                          bookId: line.bookId,
                          quantity: line.quantity + 1,
                        ),
                      ),
                icon: const Icon(Icons.add),
              ),
              Text(
                '${line.quantity}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                tooltip: 'Decrease quantity',
                onPressed: () {
                  if (line.quantity == 1) {
                    _perform(
                      context,
                      () => ref.read(removeCartItemProvider)(
                        uid: uid,
                        bookId: line.bookId,
                      ),
                    );
                  } else {
                    _perform(
                      context,
                      () => ref.read(setCartQuantityProvider)(
                        uid: uid,
                        bookId: line.bookId,
                        quantity: line.quantity - 1,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.navy : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        PriceText(
          price: value,
          fontSize: isTotal ? 18 : 14,
          color: isTotal ? AppColors.navy : AppColors.textSecondary,
        ),
      ],
    );
  }
}
