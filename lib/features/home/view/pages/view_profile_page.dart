import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_actions_section.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_hero_section.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_stats_section.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = getIt<LocalProfileService>();

    return ValueListenableBuilder<ProfileIdentity>(
      valueListenable: profileService.identityListenable,
      builder: (context, identity, _) {
        return Material(
          color: AppColors.surface,
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ViewProfileHeroSection(
                    initial: identity.initial,
                    displayName: identity.displayName,
                    email: identity.email,
                    isVip: false,
                    onBackTap: () => Navigator.pop(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: ViewProfileStatsSection()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: ViewProfileActionsSection(
                      onManageProfileTap: () {
                        Navigator.pop(context);
                        context.go(Routes.profile);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}
