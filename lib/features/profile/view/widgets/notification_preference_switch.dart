import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/profile/service/profile_notification_preferences_service.dart';

class NotificationPreferenceSwitch extends StatefulWidget {
  const NotificationPreferenceSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.valueOf,
    required this.copyWithValue,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool Function(ProfilePreferences preferences) valueOf;
  final ProfilePreferences Function(ProfilePreferences preferences, bool value)
  copyWithValue;

  @override
  State<NotificationPreferenceSwitch> createState() =>
      _NotificationPreferenceSwitchState();
}

class _NotificationPreferenceSwitchState
    extends State<NotificationPreferenceSwitch> {
  bool _updating = false;

  Future<void> _setValue(ProfilePreferences preferences, bool value) async {
    setState(() => _updating = true);
    try {
      await ProfileNotificationPreferencesService.instance.update(
        widget.copyWithValue(preferences, value),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update notifications.')),
      );
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfilePreferences>(
      valueListenable:
          ProfileNotificationPreferencesService.instance.preferencesListenable,
      builder: (context, preferences, _) {
        final value = widget.valueOf(preferences);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        height: 1.35,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: value,
                onChanged: _updating
                    ? null
                    : (next) => _setValue(preferences, next),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                inactiveTrackColor: AppColors.surfaceContainerHighest,
                inactiveThumbColor: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}
