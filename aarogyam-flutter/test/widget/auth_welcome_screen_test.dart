// test/widget/auth_welcome_screen_test.dart
// Widget tests for the auth welcome/landing screen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aarogyam/authentication/auth_welcome_screen/auth_welcome_screen_widget.dart';

Widget _wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: child,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF00897B)),
  );
}

void main() {
  setUpAll(() async {
    // Load a minimal .env so dotenv.env['KEY'] doesn't throw
    dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender
FIREBASE_PROJECT_ID=test_project
FIREBASE_STORAGE_BUCKET=test_bucket
FIREBASE_AUTH_DOMAIN=test_auth_domain
WATSON_TTS_API_KEY=test_tts
WATSON_TTS_SERVICE_URL=https://test.tts.watson.com
WATSON_STT_API_KEY=test_stt
WATSON_STT_SERVICE_URL=https://test.stt.watson.com
LVM_API_URL=https://test.lvm.api
RAG_API_URL=https://test.rag.api
FIRST_AID_API_URL=https://test.firstaid.api
''');
  });

  group('AuthWelcomeScreen', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithMaterial(const AuthWelcomeScreenWidget()));
      await tester.pump();
      // Should not throw
      expect(find.byType(AuthWelcomeScreenWidget), findsOneWidget);
    });

    testWidgets('has a sign-in button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithMaterial(const AuthWelcomeScreenWidget()));
      await tester.pump();
      // Look for any ElevatedButton, OutlinedButton, or TextButton
      final buttons = find.byWidgetPredicate(
        (w) => w is ElevatedButton || w is OutlinedButton || w is TextButton,
      );
      expect(buttons, findsAtLeastNWidgets(1));
    });
  });
}
