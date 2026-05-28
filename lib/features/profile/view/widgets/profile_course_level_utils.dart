typedef ProfileCourseLevelInfo = ({
  int level,
  String rank,
  int xpInLevel,
  int xpNeeded,
  double progress,
});

const profileCourseLevelThresholds = [
  0,
  500,
  1200,
  2200,
  3500,
  5000,
  7000,
  10000,
];
const profileCourseRankTitles = [
  'Starter',
  'Explorer',
  'Practitioner',
  'Achiever',
  'Expert',
  'Master',
  'Legend',
  'Grandmaster',
];

ProfileCourseLevelInfo computeProfileCourseLevel(int xp) {
  int level = 1;
  for (int i = 1; i < profileCourseLevelThresholds.length; i++) {
    if (xp >= profileCourseLevelThresholds[i]) {
      level = i + 1;
    } else {
      break;
    }
  }
  level = level.clamp(1, profileCourseRankTitles.length);
  final floor = profileCourseLevelThresholds[level - 1];
  final ceil = level < profileCourseLevelThresholds.length
      ? profileCourseLevelThresholds[level]
      : profileCourseLevelThresholds.last + 5000;
  final xpInLevel = xp - floor;
  final xpNeeded = ceil - floor;
  return (
    level: level,
    rank: profileCourseRankTitles[level - 1],
    xpInLevel: xpInLevel,
    xpNeeded: xpNeeded,
    progress: (xpInLevel / xpNeeded).clamp(0.0, 1.0),
  );
}
