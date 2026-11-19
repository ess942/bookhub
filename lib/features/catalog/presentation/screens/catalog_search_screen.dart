import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/book_card.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../domain/models/book.dart';
import '../../domain/models/catalog_sort.dart';
import '../../domain/models/category.dart';
import '../providers/catalog_providers.dart';

class CatalogSearchScreen extends ConsumerStatefulWidget {
  const CatalogSearchScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  ConsumerState<CatalogSearchScreen> createState() =>
      _CatalogSearchScreenState();
}

class _CatalogSearchScreenState extends ConsumerState<CatalogSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _prefix = '';
  String? _selectedCategoryId;
  CatalogSort _sort = CatalogSort.relevance;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _prefix = value.trim().toLowerCase());
    });
  }

  void _clearFilters() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _prefix = '';
      _selectedCategoryId = null;
      _sort = CatalogSort.relevance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final request = (
      prefix: _prefix,
      categoryId: _selectedCategoryId,
      sort: _sort,
    );
    final results = ref.watch(searchBooksProvider(request));
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 5
        : width >= 750
        ? 4
        : width >= 520
        ? 3
        : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search books'),
        actions: [
          TextButton.icon(
            onPressed: _hasFilters ? _clearFilters : null,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Clear'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _searchController,
                  label: 'Book title',
                  hintText: 'Start typing a title',
                  prefixIcon: Icons.search_rounded,
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: AppSpacing.md),
                categories.when(
                  loading: () => const SizedBox(
                    height: 44,
                    child: Center(child: LinearProgressIndicator()),
                  ),
                  error: (error, _) => Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Could not load categories.',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Retry categories',
                        onPressed: () => ref.invalidate(categoriesProvider),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  data: (items) => _CategoryFilters(
                    categories: items,
                    selectedId: _selectedCategoryId,
                    onSelected: (id) =>
                        setState(() => _selectedCategoryId = id),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<CatalogSort>(
                  initialValue: _sort,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: CatalogSort.relevance,
                      child: Text('Relevance / title'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.newest,
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.priceLowToHigh,
                      child: Text('Price: low to high'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.priceHighToLow,
                      child: Text('Price: high to low'),
                    ),
                    DropdownMenuItem(
                      value: CatalogSort.rating,
                      child: Text('Top rated'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sort = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: results.when(
                    loading: () => const ScreenState.loading(),
                    error: (error, _) => ScreenState.error(
                      message: error.toString(),
                      onRetry: () =>
                          ref.invalidate(searchBooksProvider(request)),
                    ),
                    data: (books) {
                      if (books.isEmpty) {
                        return ScreenState.empty(
                          message: _hasFilters
                              ? 'No books match these filters.'
                              : 'No books are available yet.',
                        );
                      }
                      return GridView.builder(
                        itemCount: books.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: width < 520 ? 0.58 : 0.62,
                        ),
                        itemBuilder: (context, index) =>
                            _SearchBookCard(book: books[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasFilters =>
      _prefix.isNotEmpty ||
      _selectedCategoryId != null ||
      _sort != CatalogSort.relevance;
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: CategoryChip(
              label: 'All',
              isSelected: selectedId == null,
              onTap: () => onSelected(null),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: CategoryChip(
                label: category.name,
                isSelected: selectedId == category.id,
                onTap: () => onSelected(category.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBookCard extends StatelessWidget {
  const _SearchBookCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return BookCard(
      title: book.title,
      author: book.author,
      price: book.price,
      coverUrl: book.coverUrl,
      isAvailable: book.stock > 0,
      onTap: () => context.push(AppRouter.bookDetailsPath(book.id)),
    );
  }
}
