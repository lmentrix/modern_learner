class LeaderboardUser {
  const LeaderboardUser({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatarColor,
    required this.initials,
    this.isCurrentUser = false,
  });
  final int rank;
  final String name;
  final String initials;
  final int xp;
  final int avatarColor;
  final bool isCurrentUser;
}

enum NoteFileType { pdf, image, doc, other }

class NoteItem {
  const NoteItem({
    required this.id,
    required this.title,
    required this.fileType,
    required this.fileSize,
    required this.subject,
    required this.uploadedAt,
    required this.cardColor,
  });
  final String id;
  final String title;
  final NoteFileType fileType;
  final String fileSize;
  final String subject;
  final String uploadedAt;
  final int cardColor;
}

class QuickStat {
  const QuickStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.iconData,
    required this.cardColor,
  });
  final String label;
  final String value;
  final String unit;
  final int iconData;
  final int cardColor;
}
