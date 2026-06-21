class UserProfile {

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?) ?? '';
    final email = (json['email'] as String?) ?? '';
    final createdAt = json['created_at'] as String?;
    final progress = json['user_progress'] as Map<String, dynamic>?;

    String joinedDate = '';
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        joinedDate = '${_months[dt.month - 1]} ${dt.year}';
      }
    }

    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .where((w) => w.isNotEmpty)
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase()
        : email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';

    return UserProfile(
      name: name,
      username: email.isNotEmpty ? email.split('@').first : '',
      email: email,
      bio: '',
      level: progress?['level'] ?? 1,
      xp: progress?['total_xp'] ?? 0,
      xpGoal: progress?['xp_goal'] ?? 100,
      streak: progress?['streak'] ?? 0,
      joinedDate: joinedDate,
      avatarInitials: initials,
      avatarGradient: const [0xFF6C63FF, 0xFF3F51B5],
    );
  }
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
  final List<int> avatarGradient;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Map<String, dynamic> toJson() => {'name': name, 'email': email};
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
