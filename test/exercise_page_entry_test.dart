import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/pages/exercise_page.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4YW1wbGUiLCJyb2xlIjoiYW5vbiJ9.'
          'placeholder',
    );
  });

  testWidgets('exercise page lays out on entry', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExercisePage(
          lessonType: LessonType.voice,
          title: 'Voice practice',
          sectionTitle: 'Voice',
          accentColor: Colors.blue,
          emoji: 'A',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Voice practice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('voice practice step uses tts text when provided', () {
    final step = VoicePracticeStepModel.fromJson({
      'step_number': 1,
      'prompt': '今日はいい天気です。',
      'tts_text': '今日は... いい天気です。',
      'tts_audio_b64': 'abc123',
      'coaching_tip': 'Keep the vowel length even.',
    });

    expect(step.prompt, '今日はいい天気です。');
    expect(step.ttsText, '今日は... いい天気です。');
    expect(step.ttsAudioB64, 'abc123');
    expect(step.textForTts, '今日は... いい天気です。');
  });

  test('voice practice step falls back to prompt for legacy data', () {
    final step = VoicePracticeStepModel.fromJson({
      'stepNumber': 2,
      'prompt': 'こんにちは。',
      'coachingTip': 'Open with a relaxed vowel.',
    });

    expect(step.textForTts, 'こんにちは。');
  });
}
