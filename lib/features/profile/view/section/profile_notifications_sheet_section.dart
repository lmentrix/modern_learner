import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_divider.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_handle.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_sheet_title.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_toggle_row.dart';

class ProfileNotificationsSheetSection extends StatefulWidget {
  const ProfileNotificationsSheetSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  final ProfilePreferences preferences;
  final ValueChanged<ProfilePreferences> onPreferencesChanged;

  @override
  State<ProfileNotificationsSheetSection> createState() =>
      _ProfileNotificationsSheetSectionState();
}

class _ProfileNotificationsSheetSectionState
    extends State<ProfileNotificationsSheetSection> {
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
      decoration: const BoxDecoration(
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
          const ProfileSheetHandle(),
          const SizedBox(height: 20),
          const ProfileSheetTitle(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          ProfileToggleRow(
            emoji: '🔔',
            label: 'Daily Reminder',
            description: 'Get reminded to practice each day',
            value: _preferences.dailyReminder,
            onChanged: (value) {
              _updatePreferences(_preferences.copyWith(dailyReminder: value));
            },
          ),
          const ProfileSheetDivider(),
          ProfileToggleRow(
            emoji: '🔥',
            label: 'Streak Alerts',
            description: 'Know when your streak is at risk',
            value: _preferences.streakAlerts,
            onChanged: (value) {
              _updatePreferences(_preferences.copyWith(streakAlerts: value));
            },
          ),
          const ProfileSheetDivider(),
          ProfileToggleRow(
            emoji: '📊',
            label: 'Weekly Digest',
            description: 'A summary of your weekly progress',
            value: _preferences.weeklyDigest,
            onChanged: (value) {
              _updatePreferences(_preferences.copyWith(weeklyDigest: value));
            },
          ),
          const ProfileSheetDivider(),
          ProfileToggleRow(
            emoji: '🏆',
            label: 'Achievement Alerts',
            description: 'Celebrate when you earn badges',
            value: _preferences.achievementAlerts,
            onChanged: (value) {
              _updatePreferences(
                _preferences.copyWith(achievementAlerts: value),
              );
            },
          ),
        ],
      ),
    );
  }
}
