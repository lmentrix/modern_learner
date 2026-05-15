import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_contact_row.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_faq_tile.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';

class ProfileHelpSheetSection extends StatelessWidget {
  const ProfileHelpSheetSection({super.key});

  static const _helpAccent = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            const Center(child: ProfileSheetHandle()),
            const SizedBox(height: 20),
            const ProfileSheetTitle(
              title: 'Help & Support',
              icon: Icons.help_outline_rounded,
              color: _helpAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'FREQUENTLY ASKED',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            for (final faq in ProfilePageData.faqs)
              ProfileFaqTile(question: faq.question, answer: faq.answer),
            const SizedBox(height: 20),
            Text(
              'CONTACT',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            for (
              var index = 0;
              index < ProfilePageData.contacts.length;
              index++
            ) ...[
              if (index > 0) const SizedBox(height: 8),
              ProfileContactRow(
                icon: ProfilePageData.contacts[index].icon,
                label: ProfilePageData.contacts[index].label,
                subtitle: ProfilePageData.contacts[index].subtitle,
                color: ProfilePageData.contacts[index].color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
