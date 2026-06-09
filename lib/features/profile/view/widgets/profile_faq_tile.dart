import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileFaqTile extends StatefulWidget {
  const ProfileFaqTile({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<ProfileFaqTile> createState() => _ProfileFaqTileState();
}

class _ProfileFaqTileState extends State<ProfileFaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.surfaceContainerHighest.withValues(alpha: 0.6)
              : AppColors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? AppColors.outlineVariant.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              SizedBox(height: 10),
              Text(
                widget.answer,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
