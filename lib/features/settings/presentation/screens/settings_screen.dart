import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeletingAccount = false;

  Future<void> _savePreference(Future<void> Function() save) async {
    try {
      await save();
    } catch (error) {
      _showMessage('Could not save this setting: $error');
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    if (error != null) {
      _showMessage(error);
    } else {
      context.go(AppRouter.login);
    }
  }

  Future<void> _deleteAccount() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      _showMessage('Sign in before deleting your account.');
      return;
    }
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your account, profile photo, orders, '
              'library, favorites, and cart. Confirm your password to '
              're-authenticate.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () =>
                Navigator.pop(dialogContext, passwordController.text),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null) return;
    if (password.isEmpty) {
      _showMessage('Enter your password to re-authenticate.');
      return;
    }

    setState(() => _isDeletingAccount = true);
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .deleteAccount(uid: user.id, password: password);
      if (mounted) context.go(AppRouter.login);
    } catch (error) {
      _showMessage('Could not delete the account: $error');
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ref
          .watch(appPreferencesProvider)
          .when(
            loading: () => const ScreenState.loading(),
            error: (error, _) => ScreenState.error(
              message: error.toString(),
              onRetry: () => ref.invalidate(appPreferencesProvider),
            ),
            data: (preferences) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Card(
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            title: const Text('Dark mode'),
                            subtitle: const Text(
                              'Use a dark theme for BookHub',
                            ),
                            value: preferences.darkMode,
                            onChanged: _isDeletingAccount
                                ? null
                                : (value) => _savePreference(
                                    () => ref
                                        .read(appPreferencesProvider.notifier)
                                        .setDarkMode(value),
                                  ),
                          ),
                          SwitchListTile.adaptive(
                            title: const Text('Notifications'),
                            subtitle: const Text(
                              'Enable BookHub notification preferences',
                            ),
                            value: preferences.notificationsEnabled,
                            onChanged: _isDeletingAccount
                                ? null
                                : (value) => _savePreference(
                                    () => ref
                                        .read(appPreferencesProvider.notifier)
                                        .setNotificationsEnabled(value),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SettingsSection(
                      title: 'Account',
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout_rounded),
                          title: const Text('Sign out'),
                          onTap: _isDeletingAccount ? null : _signOut,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever_rounded,
                            color: AppColors.error,
                          ),
                          title: const Text('Delete account'),
                          textColor: AppColors.error,
                          trailing: _isDeletingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                          onTap: _isDeletingAccount ? null : _deleteAccount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
