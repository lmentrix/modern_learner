import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_on_off_chip.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/profile/view/widgets/setting_item.dart';
import 'package:modern_learner_production/features/subscription/service/subscription_service.dart';
import 'package:modern_learner_production/l10n/generated/app_localizations.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.identity,
    required this.preferences,
    required this.onAccountTap,
    required this.onSubscriptionTap,
    required this.onNotificationsTap,
    required this.onAppearanceTap,
    required this.onLanguageTap,
    required this.onPrivacyTap,
    required this.onHelpTap,
    required this.onLogoutTap,
  });

  final ProfileIdentity identity;
  final ProfilePreferences preferences;
  final VoidCallback onAccountTap;
  final VoidCallback onSubscriptionTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback onLanguageTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onHelpTap;
  final VoidCallback onLogoutTap;

  String get _accountSubtitle {
    if (identity.email.isEmpty) {
      return identity.displayName;
    }
    if (identity.displayName == 'User') {
      return identity.email;
    }
    return '${identity.displayName} · ${identity.email}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(text: l10n.settings),
        const SizedBox(height: 14),
        SettingItem(
          icon: Icons.person_outline_rounded,
          title: l10n.account,
          subtitle: _accountSubtitle,
          accentColor: AppColors.primary,
          onTap: onAccountTap,
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: SubscriptionService.instance.isVip,
          builder: (context, isVip, _) {
            return SettingItem(
              icon: Icons.workspace_premium_rounded,
              title: l10n.subscription,
              subtitle: isVip ? l10n.vipActive : l10n.upgradeToVip,
              accentColor: const Color(0xFFFFD700),
              onTap: onSubscriptionTap,
            );
          },
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: preferences.anyNotificationEnabled
              ? l10n.remindersActive
              : l10n.allNotificationsOff,
          accentColor: AppColors.secondary,
          trailing: ProfileOnOffChip(isOn: preferences.anyNotificationEnabled),
          onTap: onNotificationsTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.palette_outlined,
          title: l10n.appearance,
          subtitle: l10n.darkMediumText,
          accentColor: AppColors.tertiaryContainer,
          onTap: onAppearanceTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.language_rounded,
          title: l10n.language,
          subtitle: _localizedLanguageLabel(l10n, preferences.selectedLanguage),
          accentColor: const Color(0xFFFF9500),
          onTap: onLanguageTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.shield_outlined,
          title: l10n.privacy,
          subtitle: l10n.privacySubtitle,
          accentColor: const Color(0xFF00DC82),
          onTap: onPrivacyTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.help_outline_rounded,
          title: l10n.helpSupport,
          subtitle: l10n.helpSupportSubtitle,
          accentColor: const Color(0xFFFF6B9D),
          onTap: onHelpTap,
        ),
        const SizedBox(height: 24),
        SettingItem(
          icon: Icons.logout_rounded,
          title: l10n.logOut,
          subtitle: l10n.logOutSubtitle,
          accentColor: Colors.redAccent,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}

String _localizedLanguageLabel(AppLocalizations l10n, String label) {
  return switch (label) {
    'English (US)' => l10n.englishUs,
    'Spanish' => l10n.spanish,
    'French' => l10n.french,
    'German' => l10n.german,
    'Italian' => l10n.italian,
    'Portuguese' => l10n.portuguese,
    'Japanese' => l10n.japanese,
    'Korean' => l10n.korean,
    'Mandarin' => l10n.mandarin,
    _ => label,
  };
}
