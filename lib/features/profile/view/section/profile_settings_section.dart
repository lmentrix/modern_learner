import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_on_off_chip.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/profile/view/widgets/setting_item.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.identity,
    required this.preferences,
    required this.onAccountTap,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel(text: 'SETTINGS'),
        const SizedBox(height: 14),
        SettingItem(
          icon: Icons.person_outline_rounded,
          title: 'Account',
          subtitle: _accountSubtitle,
          accentColor: AppColors.primary,
          onTap: onAccountTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: preferences.anyNotificationEnabled
              ? 'Reminders active'
              : 'All notifications off',
          accentColor: AppColors.secondary,
          trailing: ProfileOnOffChip(isOn: preferences.anyNotificationEnabled),
          onTap: onNotificationsTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Dark · Medium text',
          accentColor: AppColors.tertiaryContainer,
          onTap: onAppearanceTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: preferences.selectedLanguage,
          accentColor: const Color(0xFFFF9500),
          onTap: onLanguageTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.shield_outlined,
          title: 'Privacy',
          subtitle: 'Data & visibility controls',
          accentColor: const Color(0xFF00DC82),
          onTap: onPrivacyTap,
        ),
        const SizedBox(height: 8),
        SettingItem(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'FAQs and contact us',
          accentColor: const Color(0xFFFF6B9D),
          onTap: onHelpTap,
        ),
        const SizedBox(height: 24),
        SettingItem(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          subtitle: 'Sign out of your account',
          accentColor: Colors.redAccent,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
