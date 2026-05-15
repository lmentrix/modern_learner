import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileSignOutDialog extends StatelessWidget {
  const ProfileSignOutDialog({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Sign Out?',
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      content: Text(
        'Your progress is safely saved. You can sign back in anytime.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
          ),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(
            'Sign Out',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
