import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/auth_repository.dart';

/// Password reset — 3 stages: enter email, enter OTP + new password, success.
class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  int _stage = 0; // 0=email, 1=otp+password, 2=done
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_stage == 0) _EmailStage(
              ctrl: _emailCtrl,
              isLoading: _isLoading,
              error: _error,
              onSubmit: _sendOtp,
            ),
            if (_stage == 1) _OtpStage(
              email: _emailCtrl.text,
              otpCtrl: _otpCtrl,
              passwordCtrl: _passwordCtrl,
              isLoading: _isLoading,
              error: _error,
              onSubmit: _confirmReset,
            ),
            if (_stage == 2) _SuccessView(
              onLogin: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestPasswordReset(_emailCtrl.text.trim());
      setState(() {
        _stage = 1;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to send reset email. Please check the address.';
      });
    }
  }

  Future<void> _confirmReset() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.confirmPasswordReset(
        email: _emailCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      setState(() {
        _stage = 2;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Invalid or expired code. Please try again.';
      });
    }
  }
}

class _EmailStage extends StatelessWidget {
  const _EmailStage({
    required this.ctrl,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController ctrl;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter your email address',
          style: AppTextStyles.titleL.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Text(
          'We\'ll send a 6-digit reset code.',
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingL),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          Text(error!, style: AppTextStyles.body.copyWith(color: AppColors.lateAlarm)),
        ],
        const SizedBox(height: AppSizes.spacingL),
        SizedBox(
          height: AppSizes.touchPrimary,
          child: FilledButton(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Send reset email',
                    style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _OtpStage extends StatelessWidget {
  const _OtpStage({
    required this.email,
    required this.otpCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final String email;
  final TextEditingController otpCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the code from your email',
          style: AppTextStyles.titleL.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Text(
          'Sent to $email',
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.spacingL),
        TextField(
          controller: otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit code',
            prefixIcon: Icon(Icons.pin_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSizes.spacingM),
        TextField(
          controller: passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New password',
            prefixIcon: Icon(Icons.lock_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSizes.spacingM),
          Text(error!, style: AppTextStyles.body.copyWith(color: AppColors.lateAlarm)),
        ],
        const SizedBox(height: AppSizes.spacingL),
        SizedBox(
          height: AppSizes.touchPrimary,
          child: FilledButton(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Set new password',
                    style: AppTextStyles.button.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 72),
        const SizedBox(height: AppSizes.spacingL),
        Text(
          'Password updated!',
          style: AppTextStyles.titleL.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.spacingL),
        FilledButton(
          onPressed: onLogin,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, AppSizes.touchPrimary),
            backgroundColor: AppColors.primary,
          ),
          child: Text(
            'Sign in',
            style: AppTextStyles.button.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
