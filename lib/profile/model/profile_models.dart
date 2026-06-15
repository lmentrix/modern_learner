class UserProfile {
  const UserProfile({
    required this.name,
    required this.username,
    required this.email,
    required this.bio,
    required this.level,
    required this.xp,
    required this.xpGoal,
    required this.streak,
    required this.joinedDate,
    required this.avatarInitials,
    required this.avatarGradient,
  });

  final String name;
  final String username;
  final String email;
  final String bio;
  final int level;
  final int xp;
  final int xpGoal;
  final int streak;
  final String joinedDate;
  final String avatarInitials;
  final List<int> avatarGradient; // two hex colors
}

class ActivityDay {
  const ActivityDay({required this.date, required this.intensity});

  final DateTime date;
  final int intensity; // 0 = none, 1 = light, 2 = medium, 3 = high
}

class StatItem {
  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final int icon;
  final int accentColor;
}

class SettingsTile {
  const SettingsTile({
    required this.label,
    required this.icon,
    this.trailing,
    this.value,
    this.isDestructive = false,
    this.hasToggle = false,
    this.toggleValue = false,
  });

  final String label;
  final int icon;
  final String? trailing;
  final String? value;
  final bool isDestructive;
  final bool hasToggle;
  final bool toggleValue;
}
