import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_book_cover.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../domain/models/book.dart';
import '../../../cart/presentation/actions/add_book_to_cart.dart';
import '../providers/catalog_providers.dart';

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailsProvider(bookId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: bookAsync.when(
        loading: () => const ScreenState.loading(),
        error: (error, _) => ScreenState.error(
          message: error.toString(),
          onRetry: () => ref.invalidate(bookDetailsProvider(bookId)),
        ),
        data: (book) => book == null
            ? const ScreenState.empty(
                message: 'This book is no longer available.',
              )
            : _BookDetailsContent(book: book),
      ),
      bottomNavigationBar: bookAsync.when(
        loading: () => null,
        error: (_, _) => null,
        data: (book) => book == null ? null : _AddToCartBar(book: book),
      ),
    );
  }
}

class _BookDetailsContent extends StatelessWidget {
  const _BookDetailsContent({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isAvailable = book.stock > 0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          children: [
            Center(
              child: SizedBox(
                width: 240,
                child: AsyncBookCover(coverUrl: book.coverUrl, height: 320),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'by ${book.author}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                PriceText(price: book.price, fontSize: 18),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isAvailable ? '${book.stock} in stock' : 'Out of stock',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isAvailable ? AppColors.teal : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Description',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              book.description.isEmpty
                  ? 'No description is available for this book.'
                  : book.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartBar extends ConsumerWidget {
  const _AddToCartBar({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = book.stock > 0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            PriceText(price: book.price, fontSize: 18),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: AppButton(
                text: isAvailable ? 'Add to Cart' : 'Out of stock',
                onPressed: isAvailable
                    ? () => addBookToCart(
                        context: context,
                        ref: ref,
                        bookId: book.id,
                        title: book.title,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
