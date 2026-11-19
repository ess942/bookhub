import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthState authState) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept the terms to create an account.')),
      );
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    if (authState.profileSetupPending) {
      await controller.retryProfileSetup(fullName: _nameController.text);
    } else {
      await controller.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    final result = ref.read(authControllerProvider);
    if (result.user != null &&
        result.error == null &&
        !result.profileSetupPending) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final pendingProfile = authState.profileSetupPending;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      pendingProfile
                          ? 'Finish setting up your account'
                          : 'Create Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      pendingProfile
                          ? 'Your account exists. Retry saving your profile.'
                          : 'Join BookHub to explore and save books.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _nameController,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your full name.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Use at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      prefixIcon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirmation,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                        icon: Icon(
                          _obscureConfirmation
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _acceptedTerms,
                      onChanged: (value) =>
                          setState(() => _acceptedTerms = value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('I agree to the Terms and Conditions'),
                    ),
                    if (authState.error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        authState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: pendingProfile
                          ? 'Retry profile setup'
                          : 'Create account',
                      isLoading: authState.isBusy,
                      onPressed: () => _submit(authState),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRouter.login),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
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

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}
