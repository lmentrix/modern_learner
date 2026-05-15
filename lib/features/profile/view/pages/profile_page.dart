import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/presentation/bloc/auth_bloc.dart';
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
import 'package:modern_learner_production/features/profile/view/section/profile_sign_out_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_stats_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_version_footer_section.dart';
import 'package:modern_learner_production/features/profile/view/widgets/edit_profile_sheet.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sign_out_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();
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

  ProfileIdentity get _identity {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['name'] as String? ?? 'User';
    final email = user?.email ?? '';
    return ProfileIdentity(displayName: displayName, email: email);
  }

  void _showAccountSheet() {
    final identity = _identity;
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
        onSignOutTap: () {
          Navigator.pop(context);
          _showSignOutDialog();
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ProfileSignOutDialog(
        onCancel: () => Navigator.pop(dialogContext),
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<AuthBloc>().add(const AuthSignOutRequested());
        },
      ),
    );
  }

  void _showEditProfileSheet() {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String? ?? '';
    final email = user?.email ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
        child: EditProfileSheet(currentName: name, currentEmail: email),
      ),
    );
  }

  void _openAchievementDetail(AchievementEntity achievement) {
    context.push(Routes.achievementDetail, extra: achievement);
  }

  @override
  Widget build(BuildContext context) {
    final identity = _identity;

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
            SliverPadding(
              padding: ProfilePageConstants.pagePadding,
              sliver: SliverToBoxAdapter(
                child: ProfileSignOutSection(onTap: _showSignOutDialog),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(
              child: Center(child: ProfileVersionFooterSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
