// test/widget_test/settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ ADJUST THIS IMPORT PATH to match your project structure:
// Option A: If your lib folder is at project root:
import 'package:news_ai_app/screens/settings_screen.dart';
// Option B: If that doesn't work, use relative path:
// import '../../lib/screens/settings_screen.dart';

void main() {
  // ✅ Setup: Initialize SharedPreferences mock before tests
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  // ✅ Helper: Pump SettingsScreen with proper theme setup
  Future<void> pumpSettingsScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('should display Display Name field',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('should show error when name is empty',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      await tester.tap(find.text('Save Profile'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should show error when name is less than 6 characters',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'John');
      await tester.tap(find.text('Save Profile'));
      await tester.pump();

      expect(find.text('Minimum 6 characters'), findsOneWidget);
    });

    testWidgets('should save successfully when name is valid',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'Johnny');
      await tester.tap(find.text('Save Profile'));
      await tester.pump();

      expect(find.text('✓ Saved: Johnny'), findsOneWidget);
    });

    // ✅ FIXED: Dark mode toggle test - Reliable version
    testWidgets('should toggle dark mode switch', (WidgetTester tester) async {
      // Arrange: Pump the widget with theme to avoid brightness errors
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      // ✅ Find the actual Switch widget (not SwitchListTile)
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // ✅ Get initial state
      final Switch initialSwitch = tester.widget(switchFinder);
      final bool initialState = initialSwitch.value;

      // ✅ Tap the actual Switch widget
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // ✅ Verify state actually changed
      final Switch updatedSwitch = tester.widget(switchFinder);
      expect(updatedSwitch.value, !initialState);
    });

    // ✅ Simple test: Verify switch is tappable and has callback
    testWidgets('dark mode switch is tappable and has callback',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      // Find the switch
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // Verify it has an onChanged callback (so it's interactive)
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.onChanged, isNotNull);

      // Tap it - should not throw any errors
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify switch still exists after tap (no crash)
      expect(switchFinder, findsOneWidget);
    });

    testWidgets('should display character counter',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'Johnny');
      await tester.pump();

      expect(find.text('6/30'), findsOneWidget);
    });

    // ✅ BONUS: Test that helper text is visible
    testWidgets('should display helper text for name field',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Minimum 6 characters required'), findsOneWidget);
    });

    // ✅ BONUS: Test dark mode label exists
    testWidgets('should display dark mode toggle label',
        (WidgetTester tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);
    });
  });
}
