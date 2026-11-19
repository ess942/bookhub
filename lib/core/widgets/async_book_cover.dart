import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AsyncBookCover extends StatelessWidget {
  const AsyncBookCover({
    super.key,
    this.coverUrl,
    this.height = 160,
  });

  final String? coverUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: coverUrl == null || coverUrl!.isEmpty
          ? const Icon(
              Icons.book_rounded,
              size: 42,
              color: AppColors.actionBlue,
            )
          : Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                size: 42,
                color: AppColors.textSecondary,
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }
}
