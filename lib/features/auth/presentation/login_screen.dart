import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_state_provider.dart';
import '../../../core/widgets/idempotent_submit_button.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await ref.read(authStateProvider.notifier).signIn(
        access: result.access,
        refresh: result.refresh,
        vendorStatus: result.vendorStatus,
      );

      if (mounted) context.go(Routes.orders);
    } catch (e) {
      setState(() {
        _error = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final success = await ref.read(authStateProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    if (!success) {
      setState(() {
        _error = 'Google Login failed.';
        _isLoading = false;
      });
    } else {
      // The auth listener will redirect when signed in.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Brand
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PlateRoute',
                    style: AppTextStyles.titleL.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingXL),
              Text(
                'Sign in to your restaurant',
                style: AppTextStyles.titleL.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                'Manage orders, menus, and payouts.',
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _EmailField(controller: _emailCtrl),
                    const SizedBox(height: AppSizes.spacingM),
                    _PasswordField(
                      controller: _passwordCtrl,
                      obscure: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSizes.spacingM),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.rejectSurface,
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          border: Border.all(color: AppColors.rejectOutline.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.rejectOutline, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: AppTextStyles.dense.copyWith(
                                  color: AppColors.rejectOutline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.spacingL),
                    SizedBox(
                      height: AppSizes.touchPrimary,
                      child: IdempotentSubmitButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          ),
                        ),
                        child: Text(
                                'Sign in',
                                style: AppTextStyles.button.copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
                          child: Text(
                            'OR',
                            style: AppTextStyles.body.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingL),

                    SizedBox(
                      height: AppSizes.touchPrimary,
                      child: IdempotentSubmitButton(
                        onPressed: _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                          ),
                        ),
                        child: Text(
                          'Continue with Google',
                          style: AppTextStyles.button.copyWith(
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email address',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        return null;
      },
    );
  }
}
