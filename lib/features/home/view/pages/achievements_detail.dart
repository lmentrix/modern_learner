import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/view/section/achievement_detail_action_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievement_detail_description_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievement_detail_hero_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievement_detail_level_progression_section.dart';
import 'package:modern_learner_production/features/home/view/section/achievement_detail_status_section.dart';

class AchievementsDetailPage extends StatelessWidget {
  const AchievementsDetailPage({super.key, required this.achievement});

  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AchievementDetailHeroSection(
                achievement: achievement,
                onBackTap: () => Navigator.pop(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    AchievementDetailStatusSection(achievement: achievement),
                    const SizedBox(height: 12),
                    AchievementDetailLevelProgressionSection(
                      achievement: achievement,
                    ),
                    const SizedBox(height: 12),
                    AchievementDetailDescriptionSection(
                      achievement: achievement,
                    ),
                    const SizedBox(height: 32),
                    AchievementDetailActionSection(
                      achievement: achievement,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
