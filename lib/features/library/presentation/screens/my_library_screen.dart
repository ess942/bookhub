import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/async_book_cover.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/library_book.dart';
import '../providers/library_providers.dart';

class MyLibraryScreen extends ConsumerWidget {
  const MyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Library')),
        body: ScreenState.empty(message: 'Sign in to view your library.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: ref
          .watch(myLibraryProvider(user.id))
          .when(
            loading: () => const ScreenState.loading(),
            error: (error, _) => ScreenState.error(
              message: error.toString(),
              onRetry: () => ref.invalidate(myLibraryProvider(user.id)),
            ),
            data: (books) => books.isEmpty
                ? const ScreenState.empty(
                    message: 'Books you purchase will appear here.',
                  )
                : _LibraryContents(books: books),
          ),
    );
  }
}

class _LibraryContents extends StatelessWidget {
  const _LibraryContents({required this.books});

  final List<LibraryBook> books;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: books.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              color: AppColors.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () =>
                    context.push(AppRouter.bookDetailsPath(book.bookId)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 88,
                        child: AsyncBookCover(
                          coverUrl: book.coverUrl,
                          height: 88,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            if (book.author.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (book.purchasedAt != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Purchased ${_formatDate(book.purchasedAt!)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
