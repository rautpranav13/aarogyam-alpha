// test/unit/app_state_test.dart
// Unit tests for AppState singleton & persisted fields

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset singleton + mock prefs before each test
    AppState.reset();
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState singleton', () {
    test('factory always returns the same instance', () {
      final a = AppState();
      final b = AppState();
      expect(identical(a, b), isTrue);
    });

    test('reset() creates a fresh instance', () {
      final before = AppState();
      AppState.reset();
      final after = AppState();
      expect(identical(before, after), isFalse);
    });
  });

  group('AppState default values', () {
    test('genderValue defaults to empty string', () {
      expect(AppState().genderValue, equals(''));
    });

    test('ageValue defaults to 18', () {
      expect(AppState().ageValue, equals(18));
    });

    test('heightValue defaults to 140', () {
      expect(AppState().heightValue, equals(140));
    });

    test('weightValue defaults to 30', () {
      expect(AppState().weightValue, equals(30));
    });

    test('isRecording defaults to false', () {
      expect(AppState().isRecording, isFalse);
    });

    test('typedMessage defaults to empty string', () {
      expect(AppState().typedMessage, equals(''));
    });

    test('userTitle defaults to empty string', () {
      expect(AppState().userTitle, equals(''));
    });

    test('userQuery defaults to empty string', () {
      expect(AppState().userQuery, equals(''));
    });
  });

  group('AppState mutations', () {
    test('setting genderValue updates value', () {
      AppState().genderValue = 'Male';
      expect(AppState().genderValue, equals('Male'));
    });

    test('setting ageValue updates value', () {
      AppState().ageValue = 25;
      expect(AppState().ageValue, equals(25));
    });

    test('update() calls notifyListeners', () {
      var notified = false;
      AppState().addListener(() => notified = true);
      AppState().update(() {
        AppState().typedMessage = 'Hello';
      });
      expect(notified, isTrue);
      AppState().removeListener(() {});
    });
  });

  group('AppState persistence', () {
    test('initializePersistedState loads from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'ff_genderValue': 'Female',
        'ff_ageValue': 30,
      });
      await AppState().initializePersistedState();
      expect(AppState().genderValue, equals('Female'));
      expect(AppState().ageValue, equals(30));
    });

    test('missing keys use defaults', () async {
      SharedPreferences.setMockInitialValues({});
      await AppState().initializePersistedState();
      expect(AppState().genderValue, equals(''));
      expect(AppState().ageValue, equals(18));
    });
  });
}
