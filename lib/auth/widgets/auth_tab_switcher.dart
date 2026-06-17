import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/theme/theme.dart';

enum AuthMode { signIn, signUp }

class AuthTabSwitcher extends StatelessWidget {
  const AuthTabSwitcher({
    super.key,
    required this.mode,
    required this.onSwitch,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: EduColors.bg,
        borderRadius: EduRadius.borderPill,
        border: Border.all(color: EduColors.border),
      ),
      child: Row(
        children: [
          AuthTabItem(
            label: 'Sign In',
            selected: mode == AuthMode.signIn,
            onTap: () => onSwitch(AuthMode.signIn),
          ),
          AuthTabItem(
            label: 'Sign Up',
            selected: mode == AuthMode.signUp,
            onTap: () => onSwitch(AuthMode.signUp),
          ),
        ],
      ),
    );
  }
}

class AuthTabItem extends StatelessWidget {
  const AuthTabItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? EduColors.surface : Colors.transparent,
            borderRadius: EduRadius.borderPill,
            boxShadow: selected ? EduColors.shadowCard : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.caveat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: selected
                  ? EduColors.textPrimary
                  : EduColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
