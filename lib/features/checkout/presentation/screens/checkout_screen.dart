import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_line.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/checkout_line_expectation.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/entities/checkout_request.dart';
import '../providers/checkout_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(checkoutControllerProvider.notifier).clearResult();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(String uid, List<CartLine> lines) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (lines.isEmpty || lines.any((line) => !line.isAvailable)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Review unavailable books and quantities in your cart.',
          ),
        ),
      );
      return;
    }

    final request = CheckoutRequest(
      uid: uid,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      items: [
        for (final line in lines)
          CheckoutLineExpectation(
            bookId: line.bookId,
            quantity: line.quantity,
            price: line.book!.price,
            stock: line.book!.stock,
          ),
      ],
    );
    await ref.read(checkoutControllerProvider.notifier).placeOrder(request);
    if (!mounted) return;
    final receipt = ref.read(checkoutControllerProvider).receipt;
    if (receipt != null) {
      context.go(AppRouter.orderConfirmation, extra: receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    final checkoutState = ref.watch(checkoutControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: authUser == null
          ? const ScreenState.empty(message: 'Sign in before placing an order.')
          : ref
                .watch(cartItemsProvider(authUser.id))
                .when(
                  loading: () => const ScreenState.loading(),
                  error: (error, _) => ScreenState.error(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(cartItemsProvider(authUser.id)),
                  ),
                  data: (items) => items.isEmpty
                      ? const ScreenState.empty(message: 'Your cart is empty.')
                      : _checkoutForm(authUser.id, items, checkoutState),
                ),
    );
  }

  Widget _checkoutForm(
    String uid,
    List<CartLine> lines,
    CheckoutState checkoutState,
  ) {
    final subtotal = lines.fold<double>(0, (sum, line) => sum + line.total);
    final blocked = lines.any((line) => !line.isAvailable);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'Delivery details',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _addressController,
                label: 'Street address, city',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Enter a complete delivery address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phoneController,
                label: 'Phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final digits = (value ?? '').replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  if (digits.length < 7 || digits.length > 15) {
                    return 'Enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Payment',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.teal),
                    SizedBox(width: AppSpacing.md),
                    Expanded(child: Text('Cash on Delivery (Demo)')),
                    Icon(Icons.check_circle, color: AppColors.teal),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Order summary',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final line in lines) _CheckoutLine(line: line),
              const SizedBox(height: AppSpacing.md),
              _AmountRow(label: 'Subtotal', amount: subtotal),
              const SizedBox(height: AppSpacing.sm),
              const _AmountRow(
                label: 'Delivery',
                amount: CheckoutPricing.deliveryFee,
              ),
              const Divider(height: AppSpacing.xl),
              _AmountRow(
                label: 'Total',
                amount: subtotal + CheckoutPricing.deliveryFee,
                isTotal: true,
              ),
              if (checkoutState.reviewRequired case final review?) ...[
                const SizedBox(height: AppSpacing.lg),
                _ReviewChanges(
                  reviewRequired: review,
                  onReviewCart: () {
                    ref.read(checkoutControllerProvider.notifier).clearResult();
                    context.go(AppRouter.cart);
                  },
                ),
              ],
              if (checkoutState.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  checkoutState.error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Place order',
                isLoading: checkoutState.isSubmitting,
                onPressed: blocked || checkoutState.isSubmitting
                    ? null
                    : () => _submit(uid, lines),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final book = line.book;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${book?.title ?? 'Unavailable book'} × ${line.quantity}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          PriceText(price: line.total, color: AppColors.navy),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final double amount;
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
          price: amount,
          color: isTotal ? AppColors.navy : AppColors.textSecondary,
          fontSize: isTotal ? 18 : 14,
        ),
      ],
    );
  }
}

class _ReviewChanges extends StatelessWidget {
  const _ReviewChanges({
    required this.reviewRequired,
    required this.onReviewCart,
  });

  final CheckoutReviewRequired reviewRequired;
  final VoidCallback onReviewCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Price or stock changed',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final change in reviewRequired.changes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(_changeText(change)),
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onReviewCart,
            child: const Text('Review updated cart'),
          ),
        ],
      ),
    );
  }

  String _changeText(CheckoutChange change) {
    return switch (change.type) {
      CheckoutChangeType.price =>
        '${change.title}: price changed from EGP '
            '${change.previousPrice?.toStringAsFixed(2) ?? '—'} to EGP '
            '${change.currentPrice?.toStringAsFixed(2) ?? '—'}.',
      CheckoutChangeType.stock =>
        '${change.title}: ${change.availableStock ?? 0} in stock; '
            '${change.requestedQuantity ?? 0} requested.',
      CheckoutChangeType.quantity =>
        '${change.title}: cart quantity changed. Review it before ordering.',
      CheckoutChangeType.unavailable =>
        '${change.title} is no longer available.',
      CheckoutChangeType.cartContents =>
        'The cart changed while you were checking out. Review its contents.',
    };
  }
}
