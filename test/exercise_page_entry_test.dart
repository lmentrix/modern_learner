import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/pages/exercise_page.dart';
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
}
