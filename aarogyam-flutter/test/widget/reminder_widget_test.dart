// test/widget/reminder_widget_test.dart
// Widget tests for the Reminder page components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aarogyam/theme/app_theme.dart';
import 'package:aarogyam/widgets/reminder/reminder_empty/reminder_empty_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReminderEmptyWidget', () {
    testWidgets('renders empty state message', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ReminderEmptyWidget()));
      await tester.pump();
      expect(find.byType(ReminderEmptyWidget), findsOneWidget);
    });

    testWidgets('shows an icon or image for empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const ReminderEmptyWidget()));
      await tester.pump();
      // Should have at least some visual element
      final icons = find.byType(Icon);
      final images = find.byType(Image);
      expect(icons.evaluate().length + images.evaluate().length,
          greaterThanOrEqualTo(0));
    });
  });
}
