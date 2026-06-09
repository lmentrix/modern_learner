class ProfilePreferences {
  const ProfilePreferences({
    this.dailyReminder = true,
    this.achievementAlerts = true,
    this.streakAlerts = true,
    this.weeklyDigest = false,
    this.schoolCourseCreationNotifications = true,
    this.voiceLessonCreationNotifications = true,
    this.selectedLanguage = 'English (US)',
    this.shareProgress = true,
    this.showInLeaderboard = true,
    this.analyticsEnabled = true,
  });

  final bool dailyReminder;
  final bool achievementAlerts;
  final bool streakAlerts;
  final bool weeklyDigest;
  final bool schoolCourseCreationNotifications;
  final bool voiceLessonCreationNotifications;
  final String selectedLanguage;
  final bool shareProgress;
  final bool showInLeaderboard;
  final bool analyticsEnabled;

  bool get anyNotificationEnabled =>
      dailyReminder ||
      achievementAlerts ||
      streakAlerts ||
      weeklyDigest ||
      schoolCourseCreationNotifications ||
      voiceLessonCreationNotifications;

  bool get anyReminderNotificationEnabled =>
      dailyReminder || achievementAlerts || streakAlerts || weeklyDigest;

  ProfilePreferences copyWith({
    bool? dailyReminder,
    bool? achievementAlerts,
    bool? streakAlerts,
    bool? weeklyDigest,
    bool? schoolCourseCreationNotifications,
    bool? voiceLessonCreationNotifications,
    String? selectedLanguage,
    bool? shareProgress,
    bool? showInLeaderboard,
    bool? analyticsEnabled,
  }) {
    return ProfilePreferences(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      schoolCourseCreationNotifications:
          schoolCourseCreationNotifications ??
          this.schoolCourseCreationNotifications,
      voiceLessonCreationNotifications:
          voiceLessonCreationNotifications ??
          this.voiceLessonCreationNotifications,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      shareProgress: shareProgress ?? this.shareProgress,
      showInLeaderboard: showInLeaderboard ?? this.showInLeaderboard,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}
