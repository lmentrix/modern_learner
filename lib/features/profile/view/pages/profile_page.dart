import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/bloc/profile_bloc.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_account_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_achievements_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_activity_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_appearance_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_header_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_help_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_language_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_notifications_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_privacy_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_settings_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_stats_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_version_footer_section.dart';
import 'package:modern_learner_production/features/profile/view/widgets/edit_profile_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();
  final _profileService = getIt<LocalProfileService>();
  late final AchievementState _achievementState;
  ProfilePreferences _preferences = const ProfilePreferences();

  @override
  void initState() {
    super.initState();
    _achievementState = buildAchievementState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAccountSheet() {
    final identity = _profileService.currentIdentity;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileAccountSheetSection(
        identity: identity,
        onEditProfileTap: () {
          Navigator.pop(context);
          _showEditProfileSheet();
        },
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileNotificationsSheetSection(
        preferences: _preferences,
        onPreferencesChanged: (preferences) {
          setState(() => _preferences = preferences);
        },
      ),
    );
  }

  void _showAppearanceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ProfileAppearanceSheetSection(),
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileLanguageSheetSection(
        selectedLanguage: _preferences.selectedLanguage,
        onLanguageSelected: (selectedLanguage) {
          setState(() {
            _preferences = _preferences.copyWith(
              selectedLanguage: selectedLanguage,
            );
          });
        },
      ),
    );
  }

  void _showPrivacySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfilePrivacySheetSection(
        preferences: _preferences,
        onPreferencesChanged: (preferences) {
          setState(() => _preferences = preferences);
        },
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ProfileHelpSheetSection(),
    );
  }

  void _showEditProfileSheet() {
    final identity = _profileService.currentIdentity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
        child: EditProfileSheet(
          currentName: identity.displayName,
          currentEmail: identity.email,
        ),
      ),
    );
  }

  void _openAchievementDetail(AchievementEntity achievement) {
    context.push(Routes.achievementDetail, extra: achievement);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileIdentity>(
      valueListenable: _profileService.identityListenable,
      builder: (context, identity, _) {
        return Container(
          color: AppColors.surface,
          child: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeaderSection(
                    identity: identity,
                    onEditTap: _showAccountSheet,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(child: ProfileStatsSection()),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: ProfileAchievementsSection(
                      achievementState: _achievementState,
                      onViewAllTap: () => context.push(Routes.achievements),
                      onAchievementTap: _openAchievementDetail,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                const SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(child: ProfileActivitySection()),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: ProfileSettingsSection(
                      identity: identity,
                      preferences: _preferences,
                      onAccountTap: _showAccountSheet,
                      onNotificationsTap: _showNotificationsSheet,
                      onAppearanceTap: _showAppearanceSheet,
                      onLanguageTap: _showLanguageSheet,
                      onPrivacyTap: _showPrivacySheet,
                      onHelpTap: _showHelpSheet,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                const SliverToBoxAdapter(
                  child: Center(child: ProfileVersionFooterSection()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }
}
