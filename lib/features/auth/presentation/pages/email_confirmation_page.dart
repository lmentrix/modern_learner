import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/theme/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailConfirmationPage extends StatefulWidget {
  const EmailConfirmationPage({super.key, required this.email});

  final String email;

  @override
  State<EmailConfirmationPage> createState() => _EmailConfirmationPageState();
}

class _EmailConfirmationPageState extends State<EmailConfirmationPage> {
  static const _resendDelay = 60;

  int _secondsLeft = 0;
  bool _isResending = false;
  String? _resendMessage;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _secondsLeft = _resendDelay);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _resendMessage = null;
    });
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        setState(() => _resendMessage = 'Email resent successfully.');
        _startResendTimer();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _resendMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _resendMessage = 'Failed to resend. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft == 0 && !_isResending;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go(Routes.login),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Check your inbox',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'We sent a confirmation link to',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Instruction card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap the link in the email to activate your account. '
                        "Check your spam folder if you don't see it.",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Feedback message
              if (_resendMessage != null) ...[
                Text(
                  _resendMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _resendMessage!.contains('success')
                        ? AppColors.tertiary
                        : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Resend button
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: canResend ? _resend : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: canResend
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.onSurfaceVariant,
                  ),
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          _secondsLeft > 0
                              ? 'Resend in ${_secondsLeft}s'
                              : 'Resend email',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: canResend
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Back to sign in
              GestureDetector(
                onTap: () => context.go(Routes.login),
                child: Text(
                  'Back to sign in',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
