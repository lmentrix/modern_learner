enum VoiceState { idle, recording, processing, done }

class VoiceNote {
  const VoiceNote({
    required this.id,
    required this.title,
    required this.transcript,
    required this.duration,
    required this.subject,
    required this.subjectColor,
    required this.wordCount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String transcript;
  final String duration;
  final String subject;
  final int subjectColor;
  final int wordCount;
  final String createdAt;
}
