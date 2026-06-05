import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/core/l10n/app_locale_controller.dart';
import 'package:modern_learner_production/core/l10n/app_locale_option.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/model/profile_moderl.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';
import 'package:modern_learner_production/features/profile/state/learning_activity_monitor.dart';
import 'package:modern_learner_production/features/profile/view/bloc/profile_bloc.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_account_sheet_section.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_achievement_section.dart';
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
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:modern_learner_production/features/subscription/service/subscription_service.dart';
import 'package:modern_learner_production/features/subscription/view/subscription_page.dart';
import 'package:modern_learner_production/l10n/generated/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scrollController = ScrollController();
  final _profileService = LocalProfileService.instance;
  ProfilePreferences _preferences = const ProfilePreferences();
  late final Future<ProfileModel?> _supabaseProfile;

  @override
  void initState() {
    super.initState();
    _supabaseProfile = ProfileService().getCurrentProfile();
    LearningActivityMonitor.instance.refresh();
    SubscriptionService.instance.refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSubscriptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
    ).then((_) => SubscriptionService.instance.refresh());
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
        selectedLocale: AppLocaleController.instance.locale,
        onLanguageSelected: (selectedOption) {
          AppLocaleController.instance.setLocale(selectedOption.locale);
          setState(() {
            _preferences = _preferences.copyWith(
              selectedLanguage: selectedOption.label,
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

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOutConfirmTitle),
        content: Text(l10n.logOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.instance.signOut();
    }
  }

  void _showEditProfileSheet() {
    final identity = _profileService.currentIdentity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (_) =>
            ProfileBloc(LocalProfileService.instance)
              ..add(const ProfileLoadRequested()),
        child: EditProfileSheet(
          currentName: identity.displayName,
          currentEmail: identity.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = Responsive.pagePadding(context);

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
                  child: FutureBuilder<ProfileModel?>(
                    future: _supabaseProfile,
                    builder: (context, profileSnapshot) {
                      final profile = profileSnapshot.data;
                      final supabaseIdentity = profile != null
                          ? ProfileIdentity(
                              displayName: profile.name.isNotEmpty
                                  ? profile.name
                                  : identity.displayName,
                              email: profile.email,
                            )
                          : identity;
                      return ValueListenableBuilder<int>(
                        valueListenable:
                            CourseXpService.instance.totalExerciseXp,
                        builder: (context, totalXp, _) {
                          return ProfileHeaderSection(
                            identity: supabaseIdentity,
                            totalXp: totalXp,
                            onEditTap: _showAccountSheet,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Responsive.maxContentWidth,
                        ),
                        child: const ProfileStatsSection(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Responsive.maxContentWidth,
                        ),
                        child: const ProfileAchievementSection(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Responsive.maxContentWidth,
                        ),
                        child: const ProfileActivitySection(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Responsive.maxContentWidth,
                        ),
                        child: ProfileSettingsSection(
                          identity: identity,
                          preferences: _preferences.copyWith(
                            selectedLanguage: appLocaleOptionForLocale(
                              AppLocaleController.instance.locale,
                            ).label,
                          ),
                          onAccountTap: _showAccountSheet,
                          onSubscriptionTap: _showSubscriptionPage,
                          onNotificationsTap: _showNotificationsSheet,
                          onAppearanceTap: _showAppearanceSheet,
                          onLanguageTap: _showLanguageSheet,
                          onPrivacyTap: _showPrivacySheet,
                          onHelpTap: _showHelpSheet,
                          onLogoutTap: _logout,
                        ),
                      ),
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
