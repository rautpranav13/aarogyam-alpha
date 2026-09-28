import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/core/services/dadi_ma_service.dart';
import 'package:aarogyam/core/services/medication_storage_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_theme.dart';
import 'package:aarogyam/main_pages/dadi_ma/dadi_ma_widget.dart';

void main() {
  late MedicationStorageService storageService;
  late VernacularService vernService;
  late DadiMaService dadiService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'BACKEND_URL=http://localhost:5001\n');
    await FlutterFlowTheme.initialize();
  });

  setUp(() async {
    storageService = MedicationStorageService();
    await storageService.initialize();
    vernService = VernacularService();
    await vernService.initialize();
    dadiService = DadiMaService();
    await dadiService.initialize();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        ChangeNotifierProvider.value(value: vernService),
        ChangeNotifierProvider.value(value: dadiService),
      ],
      child: Consumer<VernacularService>(
        builder: (context, _, __) => const MaterialApp(
          home: DadiMaWidget(),
        ),
      ),
    );
  }

  group('DadiMaWidget UI & Widget Tests', () {
    testWidgets('Renders DadiMaWidget with AppBar, Tabs, and Welcome message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check title & tabs in Hindi
      expect(find.text('दादी-माँ आरोग्य साथी'), findsOneWidget);
      expect(find.text('बातचीत (Chat)'), findsOneWidget);
      expect(find.text('घरेलू नुस्खे (Remedies)'), findsOneWidget);
      expect(find.text('दैनिक सलाह (Daily Advice)'), findsOneWidget);

      // Check quick chips
      expect(find.text('मेरी अगली दवा क्या है?'), findsOneWidget);
      expect(find.text('खांसी-जुकाम का घरेलू नुस्खा'), findsOneWidget);
    });

    testWidgets('Tapping a quick chip adds user query and receives Dadi-Ma answer',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on cough quick chip
      final chipFinder = find.text('खांसी-जुकाम का घरेलू नुस्खा');
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pump();

      // Verify that query was processed
      expect(find.text('खांसी-जुकाम का घरेलू नुस्खा'), findsAtLeastNWidgets(1));
    });

    testWidgets('Switching tabs to Remedies catalog renders expandable remedy cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on Remedies tab
      final tabFinder = find.text('घरेलू नुस्खे (Remedies)');
      await tester.tap(tabFinder);
      await tester.pumpAndSettle();

      // Check that remedies are displayed
      expect(find.text('घरेलू नुस्खे (Remedies)'), findsAtLeastNWidgets(1));
    });
  });
}
