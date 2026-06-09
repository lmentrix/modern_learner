import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/service/profile_notification_preferences_service.dart';
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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences;
  }

  Future<void> _updatePreferences(ProfilePreferences preferences) async {
    final previous = _preferences;
    setState(() => _preferences = preferences);
    widget.onPreferencesChanged(preferences);

    setState(() => _isUpdating = true);
    try {
      await ProfileNotificationPreferencesService.instance.update(preferences);
    } catch (_) {
      if (!mounted) return;
      setState(() => _preferences = previous);
      widget.onPreferencesChanged(previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update notification settings.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
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
          ProfileSheetTitle(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          _NotificationToggle(
            emoji: '24',
            label: 'Daily Reminder',
            description: 'Get reminded to practice each day',
            value: _preferences.dailyReminder,
            isUpdating: _isUpdating,
            onChanged: (value) =>
                _updatePreferences(_preferences.copyWith(dailyReminder: value)),
          ),
          ProfileSheetDivider(),
          _NotificationToggle(
            emoji: 'XP',
            label: 'Achievement Alerts',
            description: 'Notify when an achievement unlocks',
            value: _preferences.achievementAlerts,
            isUpdating: _isUpdating,
            onChanged: (value) => _updatePreferences(
              _preferences.copyWith(achievementAlerts: value),
            ),
          ),
          ProfileSheetDivider(),
          _NotificationToggle(
            emoji: 'ST',
            label: 'Streak Alerts',
            description: 'Know when your streak is at risk',
            value: _preferences.streakAlerts,
            isUpdating: _isUpdating,
            onChanged: (value) =>
                _updatePreferences(_preferences.copyWith(streakAlerts: value)),
          ),
          ProfileSheetDivider(),
          _NotificationToggle(
            emoji: 'WK',
            label: 'Weekly Digest',
            description: 'A summary of your weekly progress',
            value: _preferences.weeklyDigest,
            isUpdating: _isUpdating,
            onChanged: (value) =>
                _updatePreferences(_preferences.copyWith(weeklyDigest: value)),
          ),
          ProfileSheetDivider(),
          _NotificationToggle(
            emoji: 'SC',
            label: 'School Lesson Created',
            description: 'Notify when a school course is created',
            value: _preferences.schoolCourseCreationNotifications,
            isUpdating: _isUpdating,
            onChanged: (value) => _updatePreferences(
              _preferences.copyWith(schoolCourseCreationNotifications: value),
            ),
          ),
          ProfileSheetDivider(),
          _NotificationToggle(
            emoji: 'VC',
            label: 'Voice Lesson Created',
            description: 'Notify when a voice lesson is created',
            value: _preferences.voiceLessonCreationNotifications,
            isUpdating: _isUpdating,
            onChanged: (value) => _updatePreferences(
              _preferences.copyWith(voiceLessonCreationNotifications: value),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.emoji,
    required this.label,
    required this.description,
    required this.value,
    required this.isUpdating,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final String description;
  final bool value;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileToggleRow(
      emoji: emoji,
      label: label,
      description: description,
      value: value,
      onChanged: isUpdating ? null : onChanged,
    );
  }
}
