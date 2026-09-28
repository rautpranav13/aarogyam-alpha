import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/main_pages/reminder_page/reminder_page_widget.dart';
import 'package:aarogyam/core/services/medication_storage_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_theme.dart';

void main() {
  late MedicationStorageService storageService;
  late VernacularService vernService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: '''
BACKEND_URL=http://localhost:5001
''');
    await FlutterFlowTheme.initialize();
  });

  setUp(() async {
    storageService = MedicationStorageService();
    await storageService.initialize();
    vernService = VernacularService();
    await vernService.initialize();
  });

  testWidgets('ReminderPageWidget renders tabs and today schedule list',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: ReminderPageWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.textContaining('दवा समय सारणी'), findsOneWidget);

    // Verify Tab labels
    expect(find.text('आज की खुराकें'), findsOneWidget);
    expect(find.text('सक्रिय दवाइयाँ'), findsOneWidget);
    expect(find.text('पर्चा इतिहास'), findsOneWidget);

    // Verify FAB
    expect(find.text('दवा जोड़ें'), findsOneWidget);
  });

  testWidgets('ReminderPageWidget tab switching works smoothly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: ReminderPageWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 'सक्रिय दवाइयाँ' tab
    await tester.tap(find.text('सक्रिय दवाइयाँ'));
    await tester.pumpAndSettle();

    // Should display active medicines list
    expect(find.textContaining('Metformin'), findsWidgets);

    // Tap 'पर्चा इतिहास' tab
    await tester.tap(find.text('पर्चा इतिहास'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Dr. Anand Deshmukh'), findsWidgets);
  });
}
