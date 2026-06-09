import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_xp_card.dart';

List<Color> get _courseColors => [
  AppColors.primary,
  AppColors.secondary,
  AppColors.tertiary,
  const Color(0xFFFF9F43),
  const Color(0xFF26C6DA),
  const Color(0xFFCE93D8),
];

class ProfileCourseXpList extends StatelessWidget {
  const ProfileCourseXpList({required this.courseXp, super.key});

  final List<ProfileCourseXpModel> courseXp;

  @override
  Widget build(BuildContext context) {
    if (courseXp.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.onSurfaceVariant,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              'Complete exercises to start tracking\ncourse XP',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < courseXp.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < courseXp.length - 1 ? 12 : 0),
            child: ProfileCourseXpCard(
              data: courseXp[i],
              color: _courseColors[i % _courseColors.length],
            ),
          ),
      ],
    );
  }
}
