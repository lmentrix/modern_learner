class ProfileActivityDay {
  const ProfileActivityDay({
    required this.label,
    required this.minutes,
    this.date,
  });

  final String label;
  final int minutes;
  final DateTime? date;
}
