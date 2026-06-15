import 'package:modern_learner_production/profile/model/profile_models.dart';

const mockUser = UserProfile(
  name: 'Alex Morgan',
  username: '@alexmorgan',
  email: 'alex.morgan@email.com',
  bio: 'Lifelong learner. Exploring ML, philosophy & biology one note at a time. 📚',
  level: 14,
  xp: 3760,
  xpGoal: 5000,
  streak: 14,
  joinedDate: 'Jan 2024',
  avatarInitials: 'AM',
  avatarGradient: [0xFF7C5CFC, 0xFFA78BFA],
);

const mockStats = [
  StatItem(
    label: 'Lessons',
    value: '124',
    icon: 0xe80c,
    accentColor: 0xFFBBF0D9,
  ),
  StatItem(
    label: 'Hours',
    value: '38',
    icon: 0xe40c,
    accentColor: 0xFFFDE68A,
  ),
  StatItem(
    label: 'Notes',
    value: '47',
    icon: 0xe3b7,
    accentColor: 0xFFE9D5FF,
  ),
  StatItem(
    label: 'Streak',
    value: '14d',
    icon: 0xe61c,
    accentColor: 0xFFFDE68A,
  ),
];

// 10-week activity grid (Mon–Sun columns)
List<ActivityDay> generateActivityGrid() {
  final now = DateTime.now();
  final days = <ActivityDay>[];
  for (var i = 69; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    // Mock realistic activity pattern
    final seed = (date.day * 3 + date.month * 7) % 10;
    final intensity = seed < 2 ? 0 : seed < 5 ? 1 : seed < 8 ? 2 : 3;
    days.add(ActivityDay(date: date, intensity: intensity));
  }
  return days;
}

const settingsSections = [
  // Account
  [
    SettingsTile(label: 'Edit Profile', icon: 0xe3c9, trailing: ''),
    SettingsTile(label: 'Change Password', icon: 0xe897, trailing: ''),
    SettingsTile(label: 'Notifications', icon: 0xe7f4, hasToggle: true, toggleValue: true),
    SettingsTile(label: 'Language', icon: 0xe894, value: 'English'),
  ],
  // Preferences
  [
    SettingsTile(label: 'Daily Goal', icon: 0xe425, value: '30 min'),
    SettingsTile(label: 'Dark Mode', icon: 0xe518, hasToggle: false, toggleValue: false),
    SettingsTile(label: 'AI Features', icon: 0xe0da, hasToggle: true, toggleValue: true),
  ],
  // Support
  [
    SettingsTile(label: 'Help & FAQ', icon: 0xe887, trailing: ''),
    SettingsTile(label: 'Send Feedback', icon: 0xe8d0, trailing: ''),
    SettingsTile(label: 'Privacy Policy', icon: 0xe88d, trailing: ''),
  ],
  // Danger
  [
    SettingsTile(label: 'Sign Out', icon: 0xe9ba, isDestructive: true),
  ],
];

const settingsSectionTitles = ['Account', 'Preferences', 'Support', ''];
