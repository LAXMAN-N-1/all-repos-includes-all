import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../core/result.dart';
import '../../utils/app_haptics.dart';
import '../../core/base_notifier.dart';
import '../auth/providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    AppHaptics.selection();
    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      result.when(
        success: (user) {
          AppHaptics.success();
          // Force auth state refresh to update UI immediately
          // Actually updateProfile already updates cache, but we might want to manually 
          // ensure providers see the new value if they don't listen to cache.
          // The restoreSession() call or explicit state update is safer.
          // But authStateProvider typically loads from restoreSession or login.
          // Let's manually trigger a reload or update the state.
          // AuthNotifier *could* have an update method, but strictly speaking 
          // we can just let the repository handle it and maybe simply pop with success.
          // Wait, if AuthNotifier is watching something or if we just want to update the UI:
          // The returned user is the fresh one.
          
          // Let's assume updating the repository cache is enough for next reload, 
          // but for *immediate* UI update (like side drawer), we might need to tell AuthNotifier.
          // However, AuthNotifier implementation I saw:
          // restoreSession() reads from cache/api.
          // So calling restoreSession() is a safe bet.
          ref.read(authStateProvider.notifier).restoreSession();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        },
        failure: (message, _) {
          AppHaptics.warning();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $message'), backgroundColor: AppColors.error),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Edit Profile'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatar(),
                    AppSpacing.gapH24,
                    
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    AppSpacing.gapH16,
                    
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 40),
                    
                    AppButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      label: 'Save Changes',
                      isLoading: _isLoading,
                      icon: Icons.check,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
