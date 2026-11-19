import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../domain/entities/checkout_receipt.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.receipt});

  final CheckoutReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.teal,
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Order confirmed',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Your order has been saved successfully.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SelectableText(
                    'Order ID: ${receipt.orderId}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PriceText(price: receipt.total, fontSize: 20),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    text: 'Continue shopping',
                    onPressed: () => context.go(AppRouter.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
