import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/profile/data/profile_preferences.dart';
import 'package:modern_learner_production/features/push_notification/service/push_notification_service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ProfileNotificationTopic {
  dailyReminder('daily_reminders'),
  achievementAlerts('achievement_alerts'),
  streakAlerts('streak_alerts'),
  weeklyDigest('weekly_digest'),
  schoolCourseCreated('school_course_created'),
  voiceLessonCreated('voice_lesson_created');

  const ProfileNotificationTopic(this.topic);

  final String topic;
}

class ProfileNotificationPreferencesService {
  ProfileNotificationPreferencesService._();

  static final instance = ProfileNotificationPreferencesService._();

  static const _dailyReminderKey = 'profile_notifications_daily_reminder';
  static const _achievementAlertsKey =
      'profile_notifications_achievement_alerts';
  static const _streakAlertsKey = 'profile_notifications_streak_alerts';
  static const _weeklyDigestKey = 'profile_notifications_weekly_digest';
  static const _schoolCourseCreationKey =
      'profile_notifications_school_course_creation';
  static const _voiceLessonCreationKey =
      'profile_notifications_voice_lesson_creation';
  bool _initialized = false;

  final ValueNotifier<ProfilePreferences> preferencesListenable =
      ValueNotifier<ProfilePreferences>(const ProfilePreferences());

  ProfilePreferences get preferences => preferencesListenable.value;

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final loaded = ProfilePreferences(
      dailyReminder: prefs.getBool(_dailyReminderKey) ?? true,
      achievementAlerts: prefs.getBool(_achievementAlertsKey) ?? true,
      streakAlerts: prefs.getBool(_streakAlertsKey) ?? true,
      weeklyDigest: prefs.getBool(_weeklyDigestKey) ?? false,
      schoolCourseCreationNotifications:
          prefs.getBool(_schoolCourseCreationKey) ?? true,
      voiceLessonCreationNotifications:
          prefs.getBool(_voiceLessonCreationKey) ?? true,
    );
    preferencesListenable.value = loaded;
    await _syncFcmSubscriptions(loaded);
    _initialized = true;
  }

  Future<void> update(ProfilePreferences preferences) async {
    preferencesListenable.value = preferences;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_dailyReminderKey, preferences.dailyReminder),
      prefs.setBool(_achievementAlertsKey, preferences.achievementAlerts),
      prefs.setBool(_streakAlertsKey, preferences.streakAlerts),
      prefs.setBool(_weeklyDigestKey, preferences.weeklyDigest),
      prefs.setBool(
        _schoolCourseCreationKey,
        preferences.schoolCourseCreationNotifications,
      ),
      prefs.setBool(
        _voiceLessonCreationKey,
        preferences.voiceLessonCreationNotifications,
      ),
    ]);

    await _syncFcmSubscriptions(preferences);
    await _persistRemotePreferences(preferences);
  }

  Future<void> _syncFcmSubscriptions(ProfilePreferences preferences) async {
    await pushNotificationService.setPushDeliveryEnabled(
      preferences.anyNotificationEnabled,
    );

    if (preferences.dailyReminder) {
      await pushNotificationService.scheduleDailyReminderEvery24Hours();
    } else {
      await pushNotificationService.cancelDailyReminder();
    }

    await Future.wait([
      _setTopic(
        ProfileNotificationTopic.dailyReminder,
        preferences.dailyReminder,
      ),
      _setTopic(
        ProfileNotificationTopic.achievementAlerts,
        preferences.achievementAlerts,
      ),
      _setTopic(
        ProfileNotificationTopic.streakAlerts,
        preferences.streakAlerts,
      ),
      _setTopic(
        ProfileNotificationTopic.weeklyDigest,
        preferences.weeklyDigest,
      ),
      _setTopic(
        ProfileNotificationTopic.schoolCourseCreated,
        preferences.schoolCourseCreationNotifications,
      ),
      _setTopic(
        ProfileNotificationTopic.voiceLessonCreated,
        preferences.voiceLessonCreationNotifications,
      ),
    ]);
  }

  Future<void> _setTopic(ProfileNotificationTopic topic, bool enabled) async {
    if (enabled) {
      await pushNotificationService.subscribeToTopic(topic.topic);
      return;
    }
    await pushNotificationService.unsubscribeFromTopic(topic.topic);
  }

  Future<void> _persistRemotePreferences(ProfilePreferences preferences) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({
            'push_notifications_enabled': preferences.anyNotificationEnabled,
            'daily_reminder_notifications': preferences.dailyReminder,
            'achievement_alert_notifications': preferences.achievementAlerts,
            'streak_alert_notifications': preferences.streakAlerts,
            'weekly_digest_notifications': preferences.weeklyDigest,
            'school_course_creation_notifications':
                preferences.schoolCourseCreationNotifications,
            'voice_lesson_creation_notifications':
                preferences.voiceLessonCreationNotifications,
          })
          .eq('id', userId);
    } catch (_) {
      // Older databases may not have these preference columns yet. Local
      // storage and FCM topic subscriptions still keep the toggles functional.
    }
  }
}
