import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_divider.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_toggle_row.dart';

class ProfilePrivacySheetSection extends StatefulWidget {
  const ProfilePrivacySheetSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  final ProfilePreferences preferences;
  final ValueChanged<ProfilePreferences> onPreferencesChanged;

  @override
  State<ProfilePrivacySheetSection> createState() =>
      _ProfilePrivacySheetSectionState();
}

class _ProfilePrivacySheetSectionState
    extends State<ProfilePrivacySheetSection> {
  static const _privacyAccent = Color(0xFF00DC82);

  late ProfilePreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences;
  }

  void _updatePreferences(ProfilePreferences preferences) {
    setState(() => _preferences = preferences);
    widget.onPreferencesChanged(preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileSheetHandle(),
          const SizedBox(height: 20),
          const ProfileSheetTitle(
            title: 'Privacy',
            icon: Icons.shield_outlined,
            color: _privacyAccent,
          ),
          const SizedBox(height: 24),
          ProfileToggleRow(
            emoji: '📈',
            label: 'Share Progress',
            description: 'Let friends see your learning stats',
            value: _preferences.shareProgress,
            onChanged: (value) {
              _updatePreferences(_preferences.copyWith(shareProgress: value));
            },
          ),
          ProfileSheetDivider(),
          ProfileToggleRow(
            emoji: '🏅',
            label: 'Show in Leaderboard',
            description: 'Appear in community rankings',
            value: _preferences.showInLeaderboard,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(showInLeaderboard: value),
              );
            },
          ),
          ProfileSheetDivider(),
          ProfileToggleRow(
            emoji: '📊',
            label: 'Usage Analytics',
            description: 'Help improve the app with usage data',
            value: _preferences.analyticsEnabled,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(analyticsEnabled: value),
              );
            },
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
                side: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(context.tr('Download My Data')),
            ),
          ),
        ],
      ),
    );
  }
}
