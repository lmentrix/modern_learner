import 'package:flutter_test/flutter_test.dart';

import 'package:modern_learner_production/app/app.dart';

void main() {
  testWidgets('App loads with home page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify home page content is visible
    expect(find.text('Good morning,'), findsOneWidget);
    expect(find.text('Alex 👋'), findsOneWidget);
  });

  testWidgets('Bottom navigation bar is visible', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify bottom nav items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Voice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Navigate to Progress page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Tap on Progress in bottom nav
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    // Verify progress page content
    expect(find.text('Level 8'), findsOneWidget);
    expect(find.text('LVL'), findsOneWidget);
  });

  testWidgets('Skill tree nodes are visible on Progress page', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Navigate to Progress page
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    // Verify skill tree nodes (emojis)
    expect(find.text('🌱'), findsOneWidget); // Basics
    expect(find.text('👋'), findsOneWidget); // Greetings
    expect(find.text('📝'), findsOneWidget); // Introductions
  });
}
