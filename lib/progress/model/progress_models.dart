enum SkillTier { beginner, intermediate, advanced, master }

enum NodeState { locked, available, inProgress, unlocked }

class SkillNode {
  const SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.state,
    required this.xpReward,
    this.prerequisiteIds = const [],
    this.requiredXp = 0,
    this.requiredLevel = 0,
    this.requiredLessons = 0,
    this.requiredHours = 0,
    this.requiredNotes = 0,
    this.requiredFiles = 0,
    this.requiredStreak = 0,
  });

  final String id;
  final String title;
  final String description;
  final int icon;
  final SkillTier tier;
  final NodeState state;
  final int xpReward;
  final List<String> prerequisiteIds;
  final int requiredXp;
  final int requiredLevel;
  final int requiredLessons;
  final int requiredHours;
  final int requiredNotes;
  final int requiredFiles;
  final int requiredStreak;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.unlockedDate,
    required this.rarityColor,
  });

  final String id;
  final String title;
  final String description;
  final int icon;
  final bool unlocked;
  final String unlockedDate;
  final int rarityColor;
}

class SavedNoteRef {
  const SavedNoteRef({
    required this.noteId,
    required this.title,
    required this.subject,
    required this.tagColor,
    required this.savedDate,
    required this.excerpt,
  });

  final String noteId;
  final String title;
  final String subject;
  final int tagColor;
  final String savedDate;
  final String excerpt;
}
