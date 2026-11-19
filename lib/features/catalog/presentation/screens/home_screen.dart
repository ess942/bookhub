import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/book_card.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../cart/presentation/actions/add_book_to_cart.dart';
import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../providers/catalog_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredBooksProvider);
    final arrivals = ref.watch(newArrivalsProvider);

    if (categories.hasError || featured.hasError || arrivals.hasError) {
      final error = categories.error ?? featured.error ?? arrivals.error!;
      return Scaffold(
        body: ScreenState.error(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredBooksProvider);
            ref.invalidate(newArrivalsProvider);
          },
        ),
      );
    }

    if (categories.isLoading || featured.isLoading || arrivals.isLoading) {
      return const Scaffold(body: _HomeLoadingSkeleton());
    }

    final categoryItems = categories.value ?? const <Category>[];
    final featuredItems = featured.value ?? const <Book>[];
    final arrivalItems = arrivals.value ?? const <Book>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BookHub',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push(AppRouter.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 600
                  ? AppSpacing.lg
                  : AppSpacing.xxl;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  AppSpacing.xxl,
                ),
                children: [
                  const Text(
                    'Find your next great read',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: () => context.push(AppRouter.search),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: IgnorePointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search books and authors',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeading(
                    title: 'Categories',
                    trailing: TextButton(
                      onPressed: () => context.push(AppRouter.search),
                      child: const Text('See all'),
                    ),
                  ),
                  if (categoryItems.isEmpty)
                    const SizedBox(
                      height: 100,
                      child: ScreenState.empty(
                        message: 'No categories available.',
                      ),
                    )
                  else
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryItems.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final category = categoryItems[index];
                          return CategoryChip(
                            label: category.name,
                            isSelected: false,
                            onTap: () => context.push(
                              '${AppRouter.search}?category=${Uri.encodeComponent(category.id)}',
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'Featured'),
                  if (featuredItems.isEmpty)
                    const SizedBox(
                      height: 100,
                      child: ScreenState.empty(
                        message: 'No featured books yet.',
                      ),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredItems.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) => SizedBox(
                          width: 184,
                          child: _CatalogBookCard(book: featuredItems[index]),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'New arrivals'),
                  if (arrivalItems.isEmpty)
                    const SizedBox(
                      height: 120,
                      child: ScreenState.empty(
                        message: 'No new arrivals available.',
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1000
                            ? 5
                            : constraints.maxWidth >= 650
                            ? 3
                            : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: arrivalItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 0.62,
                              ),
                          itemBuilder: (context, index) =>
                              _CatalogBookCard(book: arrivalItems[index]),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CatalogBookCard extends ConsumerWidget {
  const _CatalogBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BookCard(
      title: book.title,
      author: book.author,
      price: book.price,
      coverUrl: book.coverUrl,
      isFeatured: book.isFeatured,
      isAvailable: book.stock > 0,
      onTap: () => context.push(AppRouter.bookDetailsPath(book.id)),
      onAddToCart: book.stock > 0
          ? () => addBookToCart(
              context: context,
              ref: ref,
              bookId: book.id,
              title: book.title,
            )
          : null,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _placeholder(width: 260, height: 28),
            const SizedBox(height: AppSpacing.lg),
            _placeholder(width: double.infinity, height: 52),
            const SizedBox(height: AppSpacing.xxl),
            _placeholder(width: 140, height: 22),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, _) => _placeholder(width: 92, height: 42),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _placeholder(width: 150, height: 22),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, _) => _placeholder(width: 180, height: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
