import 'package:modern_learner_production/voice/model/voice_models.dart';

const List<VoiceNote> mockVoiceNotes = [
  VoiceNote(
    id: 'v1',
    title: 'Photosynthesis Summary',
    transcript:
        'Plants convert sunlight into glucose through chlorophyll in the chloroplasts. The process requires CO₂ and water, producing oxygen as a byproduct. Light reactions and the Calvin cycle work together...',
    duration: '2:34',
    subject: 'Biology',
    subjectColor: 0xFFBBF0D9,
    wordCount: 127,
    createdAt: 'Today, 9:15 AM',
  ),
  VoiceNote(
    id: 'v2',
    title: "Newton's Laws Review",
    transcript:
        "First law: an object at rest stays at rest unless acted upon by a force. Second law: F equals m times a. Third law: for every action there's an equal and opposite reaction...",
    duration: '3:12',
    subject: 'Physics',
    subjectColor: 0xFFE9D5FF,
    wordCount: 203,
    createdAt: 'Yesterday, 4:22 PM',
  ),
  VoiceNote(
    id: 'v3',
    title: 'French Revolution Key Events',
    transcript:
        'The storming of the Bastille in 1789 marked the beginning. The Declaration of the Rights of Man followed, establishing principles of liberty and equality for all citizens...',
    duration: '4:45',
    subject: 'History',
    subjectColor: 0xFFFDE68A,
    wordCount: 318,
    createdAt: 'Jun 12, 10:00 AM',
  ),
];

const List<String> mockTranscriptChunks = [
  'The mitochondria are the powerhouse of the cell.',
  'They produce ATP through a process called cellular respiration.',
  'The inner membrane has folds called cristae,',
  'which increase the surface area available for chemical reactions.',
  'The matrix contains enzymes essential for the Krebs cycle.',
];
