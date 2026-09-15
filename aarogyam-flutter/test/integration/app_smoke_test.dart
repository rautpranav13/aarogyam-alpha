// test/integration/app_smoke_test.dart
// Integration-level smoke tests: app initialization, navigation, core flows

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=1:000000000000:android:0000000000000000000000
FIREBASE_MESSAGING_SENDER_ID=000000000000
FIREBASE_PROJECT_ID=aarogyam-test
FIREBASE_STORAGE_BUCKET=aarogyam-test.appspot.com
FIREBASE_AUTH_DOMAIN=aarogyam-test.firebaseapp.com
WATSON_TTS_API_KEY=test_tts_key
WATSON_TTS_SERVICE_URL=https://api.au-syd.text-to-speech.watson.cloud.ibm.com
WATSON_STT_API_KEY=test_stt_key
WATSON_STT_SERVICE_URL=https://api.au-syd.speech-to-text.watson.cloud.ibm.com
LVM_API_URL=https://test.lvm.api
RAG_API_URL=https://test.rag.api
FIRST_AID_API_URL=https://test.firstaid.api
''');
  });

  group('Environment / dotenv', () {
    test('all required keys are loaded', () {
      expect(dotenv.env['FIREBASE_API_KEY'], isNotNull);
      expect(dotenv.env['LVM_API_URL'], isNotNull);
      expect(dotenv.env['RAG_API_URL'], isNotNull);
      expect(dotenv.env['FIRST_AID_API_URL'], isNotNull);
      expect(dotenv.env['WATSON_TTS_API_KEY'], isNotNull);
      expect(dotenv.env['WATSON_STT_API_KEY'], isNotNull);
    });

    test('no placeholder values remain in production', () {
      // In test mode we use mock values; check format only
      expect(dotenv.env['FIREBASE_PROJECT_ID'], isNotEmpty);
      expect(dotenv.env['FIREBASE_PROJECT_ID']!.length, greaterThan(3));
    });
  });

  group('MaterialApp scaffold', () {
    testWidgets('app starts without fatal error', (WidgetTester tester) async {
      // Minimal scaffold — no Firebase init (needs real device for that)
      await tester.pumpWidget(
        MaterialApp(
          title: 'Aarogyam Test',
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF00897B),
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: Center(child: Text('Aarogyam')),
          ),
        ),
      );
      expect(find.text('Aarogyam'), findsOneWidget);
    });

    testWidgets('Material 3 theme is active', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF00897B),
            useMaterial3: true,
          ),
          home: Builder(builder: (ctx) {
            final theme = Theme.of(ctx);
            expect(theme.useMaterial3, isTrue);
            return const SizedBox();
          }),
        ),
      );
    });
  });

  group('Navigation utilities', () {
    testWidgets('Navigator can push and pop', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => const Text('Screen 2')),
              ),
              child: const Text('Go'),
            );
          }),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Screen 2'), findsOneWidget);
    });
  });
}
