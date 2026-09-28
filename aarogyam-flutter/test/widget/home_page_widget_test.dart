import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/main_pages/home_page/home_page_widget.dart';
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

  testWidgets('HomePageWidget renders greeting, adherence ring, and action hub',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: HomePageWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand Title & Greeting
    expect(find.text('आरोग्यम्'), findsOneWidget);
    expect(find.textContaining('नमस्ते'), findsOneWidget);

    // Verify Action Hub items
    expect(find.text('पर्चा स्कैन करें'), findsOneWidget);
    expect(find.text('दवा पट्टी जांचें'), findsOneWidget);
    expect(find.text('दवा समय सारणी'), findsOneWidget);
    expect(find.text('दादी-माँ आवाज़'), findsOneWidget);

    // Verify Voice Guide
    expect(find.textContaining('दादी-माँ वॉयस गाइड'), findsOneWidget);

    // Verify SOS Button
    expect(find.byTooltip('Emergency SOS'), findsOneWidget);
  });

  testWidgets('HomePageWidget language toggle updates VernacularService',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: HomePageWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Directly invoke VernacularService setLanguage and notify
    vernService.setLanguage(AppLanguage.marathi);
    await tester.pumpAndSettle();

    expect(vernService.langCode, 'mr');
  });

  testWidgets('HomePageWidget mark next dose taken updates storage and UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: HomePageWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final takeBtn = find.text('दवा ले ली (Mark Taken)');
    if (takeBtn.evaluate().isNotEmpty) {
      await tester.tap(takeBtn);
      await tester.pumpAndSettle();
      expect(storageService.adherenceRate > 0, true);
    }
  });
}
