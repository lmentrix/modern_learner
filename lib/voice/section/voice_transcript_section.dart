import 'package:flutter/material.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/voice/widgets/transcript_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

class VoiceTranscriptSection extends StatelessWidget {
  const VoiceTranscriptSection({
    super.key,
    required this.state,
    required this.transcript,
    required this.wordCount,
  });

  final VoiceState state;
  final String transcript;
  final int wordCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EduSpacing.pagePadding,
      child: TranscriptCard(
        text: transcript.isEmpty ? 'Listening...' : transcript,
        wordCount: wordCount,
        isLive: state == VoiceState.recording,
      ),
    );
  }
}
