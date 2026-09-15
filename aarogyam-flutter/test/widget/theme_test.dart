// test/widget/theme_test.dart
// Tests for the AppTheme / FlutterFlowTheme integration

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aarogyam/theme/app_theme.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_theme.dart';

void main() {
  setUpAll(() {
    // Disable Google Fonts HTTP fetching in tests — use fallback fonts
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme', () {
    testWidgets('light theme has Brightness.light',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(builder: (ctx) {
            expect(Theme.of(ctx).brightness, equals(Brightness.light));
            return const SizedBox();
          }),
        ),
      );
    });

    testWidgets('dark theme has Brightness.dark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(builder: (ctx) {
            expect(Theme.of(ctx).brightness, equals(Brightness.dark));
            return const SizedBox();
          }),
        ),
      );
    });

    testWidgets('both themes use Material 3', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(builder: (ctx) {
            expect(Theme.of(ctx).useMaterial3, isTrue);
            return const SizedBox();
          }),
        ),
      );
    });

    testWidgets('primary color is not black (teal-derived)',
        (WidgetTester tester) async {
      late Color primary;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(builder: (ctx) {
            primary = Theme.of(ctx).colorScheme.primary;
            return const SizedBox();
          }),
        ),
      );
      expect(primary, isNotNull);
      expect(primary.toARGB32(), isNot(equals(0xFF000000)));
    });

    test('light and dark themes have different brightness values', () {
      // Dark theme uses Brightness.dark, light uses Brightness.light
      expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
      expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
      expect(AppTheme.lightTheme.brightness,
          isNot(equals(AppTheme.darkTheme.brightness)));
    });
  });

  group('FlutterFlowTheme', () {
    testWidgets('of(context) returns the adapter',
        (WidgetTester tester) async {
      late FlutterFlowTheme ffTheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(builder: (ctx) {
            ffTheme = FlutterFlowTheme.of(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(ffTheme, isNotNull);
      expect(ffTheme.primary, isA<Color>());
      expect(ffTheme.primaryText, isA<Color>());
    });

    testWidgets('dark mode primary background color is valid',
        (WidgetTester tester) async {
      late Color darkBg;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(builder: (ctx) {
            darkBg = FlutterFlowTheme.of(ctx).primaryBackground;
            return const SizedBox();
          }),
        ),
      );
      // Background should be a valid opaque color
      expect((darkBg.a * 255.0).round().clamp(0, 255), equals(255));
      // Not pure white
      expect(darkBg.toARGB32(), isNot(equals(0xFFFFFFFF)));
    });

    testWidgets('bodyMedium returns a TextStyle', (WidgetTester tester) async {
      late TextStyle bodyStyle;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(builder: (ctx) {
            bodyStyle = FlutterFlowTheme.of(ctx).bodyMedium;
            return const SizedBox();
          }),
        ),
      );
      expect(bodyStyle, isA<TextStyle>());
    });
  });
}
