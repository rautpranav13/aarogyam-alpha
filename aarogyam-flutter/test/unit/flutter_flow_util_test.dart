// test/unit/flutter_flow_util_test.dart
// Unit tests for shim utility functions (flutter_flow_util.dart)

import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_util.dart';

void main() {
  group('valueOrDefault', () {
    test('returns value when non-null and non-empty', () {
      expect(valueOrDefault('hello', 'default'), equals('hello'));
    });

    test('returns defaultValue when null', () {
      expect(valueOrDefault<String>(null, 'fallback'), equals('fallback'));
    });

    test('returns defaultValue for empty string', () {
      expect(valueOrDefault('', 'fallback'), equals('fallback'));
    });

    test('works with integers — zero is a valid non-null value', () {
      expect(valueOrDefault<int>(null, 42), equals(42));
      expect(valueOrDefault<int>(5, 42), equals(5));
    });
  });

  group('divide extension on Iterable<Widget>', () {
    test('adds divider between items', () {
      final items = [
        const Text('a'),
        const Text('b'),
        const Text('c'),
      ];
      final result = items.divide(const SizedBox(height: 8));
      // Original 3 items + 2 dividers = 5
      expect(result.length, equals(5));
    });

    test('single item has no dividers', () {
      final items = [const Text('only')];
      final result = items.divide(const SizedBox(height: 8));
      expect(result.length, equals(1));
    });

    test('empty list has no output', () {
      final items = <Text>[];
      final result = items.divide(const SizedBox(height: 8));
      expect(result, isEmpty);
    });
  });

  group('getJsonField', () {
    final json = <String, dynamic>{
      'key': 'value',
      'nested': {'inner': 42},
      'list': [1, 2, 3],
    };

    test('retrieves top-level string field', () {
      expect(getJsonField(json, r'$.key'), equals('value'));
    });

    test('retrieves nested field', () {
      expect(getJsonField(json, r'$.nested.inner'), equals(42));
    });

    test('returns null for missing key', () {
      expect(getJsonField(json, r'$.missing'), isNull);
    });

    test('handles null json input', () {
      expect(getJsonField(null, r'$.key'), isNull);
    });
  });

  group('TextStyle.override extension', () {
    test('applies color override', () {
      const base = TextStyle(fontSize: 16, color: Colors.black);
      final overridden = base.override(color: Colors.red);
      expect(overridden.color, equals(Colors.red));
    });

    test('applies fontSize override', () {
      const base = TextStyle(fontSize: 16);
      final overridden = base.override(fontSize: 24);
      expect(overridden.fontSize, equals(24.0));
    });

    test('preserves unmodified properties', () {
      const base = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
      final overridden = base.override(color: Colors.blue);
      expect(overridden.fontWeight, equals(FontWeight.bold));
    });
  });

  group('FFLocalizations', () {
    testWidgets('getText returns the key when no translation found',
        (WidgetTester tester) async {
      late FFLocalizations localization;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            localization = FFLocalizations.of(ctx);
            return const SizedBox();
          }),
        ),
      );
      // In shim mode, returns key unchanged
      expect(localization.getText('some_key'), equals('some_key'));
    });
  });
}
