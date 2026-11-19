import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/screen_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      authControllerProvider.select((state) => state.user),
    );
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 52,
                  color: AppColors.actionBlue,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Sign in to manage your profile.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => context.go(AppRouter.login),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ref
          .watch(userProfileProvider(user.id))
          .when(
            loading: () => const ScreenState.loading(),
            error: (error, _) => ScreenState.error(
              message: error.toString(),
              onRetry: () => ref.invalidate(userProfileProvider(user.id)),
            ),
            data: (profile) => _ProfileDetails(profile: profile),
          ),
    );
  }
}

class _ProfileDetails extends ConsumerStatefulWidget {
  const _ProfileDetails({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<_ProfileDetails> {
  bool _isBusy = false;

  Future<void> _selectAvatar() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      setState(() => _isBusy = true);
      final imageBytes = await image.readAsBytes();
      await ref
          .read(userProfileRepositoryProvider)
          .uploadAvatar(
            uid: widget.profile.uid,
            imageBytes: imageBytes,
            contentType: _contentTypeFor(image.name),
          );
      ref.invalidate(userProfileProvider(widget.profile.uid));
      _showMessage('Profile photo updated.');
    } catch (error) {
      _showMessage('Could not update your photo: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: widget.profile.fullName);
    final phoneController = TextEditingController(text: widget.profile.phone);
    final formKey = GlobalKey<FormState>();
    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit profile'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.profile.email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (shouldSave != true) return;

      setState(() => _isBusy = true);
      await ref
          .read(userProfileRepositoryProvider)
          .updateProfile(
            uid: widget.profile.uid,
            fullName: nameController.text,
            phone: phoneController.text,
          );
      ref.invalidate(userProfileProvider(widget.profile.uid));
      _showMessage('Profile updated.');
    } catch (error) {
      _showMessage('Could not save your profile: $error');
    } finally {
      nameController.dispose();
      phoneController.dispose();
      if (mounted) setState(() => _isBusy = false);
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _contentTypeFor(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final initial = profile.fullName.isEmpty
        ? 'U'
        : profile.fullName.characters.first.toUpperCase();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.actionBlue,
                    child: profile.photoUrl.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              profile.photoUrl,
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      onPressed: _isBusy ? null : _selectAvatar,
                      tooltip: 'Change profile photo',
                      icon: const Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              profile.fullName.isEmpty ? 'BookHub user' : profile.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile details',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProfileField(
                      label: 'Phone',
                      value: profile.phone.isEmpty
                          ? 'Not provided'
                          : profile.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _isBusy ? null : _editProfile,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit profile'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRouter.library),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('My library'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRouter.settings),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
            ),
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
