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

const mockNotes = <NoteItem>[
  NoteItem(
    id: '1',
    title: 'Photosynthesis Overview.pdf',
    fileType: NoteFileType.pdf,
    fileSize: '2.4 MB',
    subject: 'Biology',
    uploadedAt: 'Today',
    cardColor: 0xFFBBF0D9,
  ),
  NoteItem(
    id: '2',
    title: 'Quadratic Equations Notes.docx',
    fileType: NoteFileType.doc,
    fileSize: '840 KB',
    subject: 'Math',
    uploadedAt: 'Yesterday',
    cardColor: 0xFFE9D5FF,
  ),
  NoteItem(
    id: '3',
    title: 'WWII Timeline Diagram.png',
    fileType: NoteFileType.image,
    fileSize: '1.1 MB',
    subject: 'History',
    uploadedAt: 'Jun 12',
    cardColor: 0xFFFDE68A,
  ),
];

const currentUserName = 'Alex';
const currentUserXp   = 3760;
const currentUserXpGoal = 5000;
const currentUserStreak = 14;
