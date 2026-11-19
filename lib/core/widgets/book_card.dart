import 'package:flutter/material.dart';

import 'package:bookhub2/core/theme/app_colors.dart';
import 'package:bookhub2/core/theme/app_spacing.dart';
import 'package:bookhub2/core/widgets/async_book_cover.dart';
import 'package:bookhub2/core/widgets/price_text.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final double price;
  final String? bookId;
  final String? coverUrl;
  final bool isFavorite;
  final bool isFeatured;
  final bool isAvailable;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;
  final VoidCallback onTap;
  final GlobalKey? flyerKey;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.price,
    this.bookId,
    this.coverUrl,
    this.isFavorite = false,
    this.isFeatured = false,
    this.isAvailable = true,
    this.onFavoriteTap,
    this.onAddToCart,
    required this.onTap,
    this.flyerKey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              key: flyerKey,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: AsyncBookCover(coverUrl: coverUrl, height: 160),
                ),
                if (isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                if (onFavoriteTap != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? Colors.red : AppColors.navy,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                fontSize: 15,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [PriceText(price: price, fontSize: 15)],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAvailable ? onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: Text(
                  isAvailable ? 'Add to Cart' : 'Out of stock',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
