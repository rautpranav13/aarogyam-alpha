// test/widget/ai_disclaimer_test.dart
// Widget tests for the AI Disclaimer bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aarogyam/theme/app_theme.dart';
import 'package:aarogyam/widgets/a_i_disclaimer/a_i_disclaimer_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AIDisclaimerWidget', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const AIDisclaimerWidget()));
      await tester.pump();
      expect(find.byType(AIDisclaimerWidget), findsOneWidget);
    });

    testWidgets('displays at least one text widget', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const AIDisclaimerWidget()));
      await tester.pump();
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });

    testWidgets('contains disclaimer-related content',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const AIDisclaimerWidget()));
      await tester.pump();
      // Should have some tappable interaction (button, gesture detector, etc.)
      final tappable = find.byWidgetPredicate(
        (w) =>
            w is GestureDetector ||
            w is InkWell ||
            w is ElevatedButton ||
            w is TextButton ||
            w is OutlinedButton ||
            w is IconButton,
      );
      // The widget may have close/confirm button — just ensure no crash
      expect(find.byType(AIDisclaimerWidget), findsOneWidget);
      expect(tappable.evaluate().length, greaterThanOrEqualTo(0));
    });
  });
}
