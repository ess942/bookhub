import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/async_book_cover.dart';
import '../widgets/book_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/price_text.dart';
import '../widgets/screen_state.dart';

class ComponentGalleryPage extends StatefulWidget {
  const ComponentGalleryPage({super.key});

  @override
  State<ComponentGalleryPage> createState() => _ComponentGalleryPageState();
}

class _ComponentGalleryPageState extends State<ComponentGalleryPage> {
  bool isLoading = false;
  String selectedCategory = 'All';
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width < 600 ? 180.0 : 220.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Component Gallery')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              const Text(
                'Buttons',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Primary action',
                isLoading: isLoading,
                onPressed: () => setState(() => isLoading = !isLoading),
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppButton(
                text: 'Outlined action',
                isOutlined: true,
                onPressed: null,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Inputs',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Search books',
                controller: controller,
                prefixIcon: Icons.search_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Categories',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ['All', 'Business', 'Fiction', 'Science'].map((name) {
                  return CategoryChip(
                    label: name,
                    isSelected: selectedCategory == name,
                    onTap: () => setState(() => selectedCategory = name),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Book card and price',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Row(
                children: [
                  PriceText(price: 390),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: AsyncBookCover(height: 120)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: cardWidth,
                height: 280,
                child: BookCard(
                  title: 'Atomic Habits',
                  author: 'James Clear',
                  price: 390,
                  onTap: () {},
                  onAddToCart: () {},
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Screen states',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: const ScreenState.empty(
                  message: 'No books in this category',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
