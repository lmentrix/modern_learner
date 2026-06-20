import 'package:modern_learner_production/home/model/home_models.dart';

const mockLeaderboard = [
  LeaderboardUser(rank: 1, name: 'Sophia Chen',   initials: 'SC', xp: 4820, avatarColor: 0xFFBB9FFF),
  LeaderboardUser(rank: 2, name: 'Marcus Webb',   initials: 'MW', xp: 4410, avatarColor: 0xFFA7F3D0),
  LeaderboardUser(rank: 3, name: 'Aisha Patel',   initials: 'AP', xp: 3990, avatarColor: 0xFFFDE68A),
  LeaderboardUser(rank: 4, name: 'You',            initials: 'ME', xp: 3760, avatarColor: 0xFFA78BFA, isCurrentUser: true),
  LeaderboardUser(rank: 5, name: 'Daniel Torres', initials: 'DT', xp: 3540, avatarColor: 0xFFBBF0D9),
];

const mockStats = [
  QuickStat(label: 'Lessons', value: '124', unit: 'completed', iconData: 0xe80c, cardColor: 0xFFBBF0D9),
  QuickStat(label: 'Hours',   value: '38',  unit: 'this month', iconData: 0xe40c, cardColor: 0xFFFDE68A),
];

// Uploaded files are now fetched from Supabase via UploadService.

const currentUserName = 'Alex';
const currentUserXp   = 3760;
const currentUserXpGoal = 5000;
const currentUserStreak = 14;
