class ProfilePreferences {
  const ProfilePreferences({
    this.dailyReminder = true,
    this.streakAlerts = true,
    this.weeklyDigest = false,
    this.achievementAlerts = true,
    this.selectedLanguage = 'English (US)',
    this.shareProgress = true,
    this.showInLeaderboard = true,
    this.analyticsEnabled = true,
  });

  final bool dailyReminder;
  final bool streakAlerts;
  final bool weeklyDigest;
  final bool achievementAlerts;
  final String selectedLanguage;
  final bool shareProgress;
  final bool showInLeaderboard;
  final bool analyticsEnabled;

  bool get anyNotificationEnabled =>
      dailyReminder || streakAlerts || weeklyDigest || achievementAlerts;

  ProfilePreferences copyWith({
    bool? dailyReminder,
    bool? streakAlerts,
    bool? weeklyDigest,
    bool? achievementAlerts,
    String? selectedLanguage,
    bool? shareProgress,
    bool? showInLeaderboard,
    bool? analyticsEnabled,
  }) {
    return ProfilePreferences(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      shareProgress: shareProgress ?? this.shareProgress,
      showInLeaderboard: showInLeaderboard ?? this.showInLeaderboard,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}
