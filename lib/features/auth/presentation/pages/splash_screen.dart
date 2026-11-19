import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/config/firebase_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await ref.read(firebaseBootstrapProvider.notifier).initialize();
    if (!mounted) return;
    if (ref.read(firebaseBootstrapProvider).hasValue) {
      AppRouter.authRefresh.start();
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(firebaseBootstrapProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: bootstrap.when(
                loading: () => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.actionBlue,
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    Text(
                      'BookHub',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    CircularProgressIndicator(),
                  ],
                ),
                data: (_) => const CircularProgressIndicator(),
                error: (error, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'BookHub could not connect to Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error is FirebaseException
                          ? error.message ?? error.code
                          : error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(text: 'Retry', onPressed: _initialize),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
