class ProfileOptionItem {
  const ProfileOptionItem({
    required this.emoji,
    required this.label,
    this.subtitle = '',
  });

  final String emoji;
  final String label;
  final String subtitle;
}
