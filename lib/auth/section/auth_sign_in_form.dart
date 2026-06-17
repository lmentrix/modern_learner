import 'package:flutter/material.dart';
import 'package:modern_learner_production/auth/widgets/auth_field.dart';
import 'package:modern_learner_production/auth/widgets/auth_validators.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AuthSignInForm extends StatelessWidget {
  const AuthSignInForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AuthField(
            controller: emailCtrl,
            focusNode: emailFocus,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => passFocus.requestFocus(),
            validator: validateEmail,
          ),
          const SizedBox(height: EduSpacing.s3),
          AuthField(
            controller: passCtrl,
            focusNode: passFocus,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            suffixIcon: AuthVisibilityToggle(
              obscure: obscure,
              onToggle: onToggle,
            ),
            validator: validatePassword,
          ),
        ],
      ),
    );
  }
}
