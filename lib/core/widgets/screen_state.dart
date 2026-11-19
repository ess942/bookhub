import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

enum ScreenStateType { loading, empty, error }

class ScreenState extends StatelessWidget {
  const ScreenState({
    super.key,
    required this.type,
    this.message,
    this.onRetry,
  });

  const ScreenState.loading({super.key, this.message})
      : type = ScreenStateType.loading,
        onRetry = null;

  const ScreenState.empty({super.key, this.message})
      : type = ScreenStateType.empty,
        onRetry = null;

  const ScreenState.error({
    super.key,
    this.message,
    this.onRetry,
  }) : type = ScreenStateType.error;

  final ScreenStateType type;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (type == ScreenStateType.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isError = type == ScreenStateType.error;
    final title = message ??
        (isError ? 'Something went wrong' : 'No items found');
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.inbox_outlined;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: isError ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: AppButton(text: 'Retry', onPressed: onRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
