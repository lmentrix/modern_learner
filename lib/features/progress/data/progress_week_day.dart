class ProgressWeekDay {
  const ProgressWeekDay({
    required this.label,
    required this.minutes,
    required this.goalMinutes,
    required this.isToday,
  });

  final String label;
  final int minutes;
  final int goalMinutes;
  final bool isToday;
}
