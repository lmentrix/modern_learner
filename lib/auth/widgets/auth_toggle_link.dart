import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/auth/widgets/auth_tab_switcher.dart';
import 'package:modern_learner_production/theme/theme.dart';

class AuthToggleLink extends StatelessWidget {
  const AuthToggleLink({
    super.key,
    required this.mode,
    required this.onSwitch,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onSwitch;

  @override
  Widget build(BuildContext context) {
    final isSignIn = mode == AuthMode.signIn;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignIn
              ? "Don't have an account? "
              : 'Already have an account? ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: EduColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () =>
              onSwitch(isSignIn ? AuthMode.signUp : AuthMode.signIn),
          child: Text(
            isSignIn ? 'Sign Up' : 'Sign In',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EduColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
