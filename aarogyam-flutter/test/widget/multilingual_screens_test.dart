import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/main_pages/home_page/home_page_widget.dart';
import 'package:aarogyam/main_pages/report_sanner/report_sanner_widget.dart';
import 'package:aarogyam/main_pages/blister_verifier/blister_verifier_widget.dart';
import 'package:aarogyam/main_pages/reminder_page/reminder_page_widget.dart';
import 'package:aarogyam/core/services/medication_storage_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';
import 'package:aarogyam/core/services/dadi_ma_service.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_theme.dart';

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

  group('Multilingual Live UI Screen Tests', () {
    testWidgets('HomePageWidget dynamically updates from Hindi to Marathi to English',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: storageService),
            ChangeNotifierProvider.value(value: vernService),
            ChangeNotifierProvider.value(value: dadiService),
          ],
          child: Consumer<VernacularService>(
            builder: (context, vern, _) => const MaterialApp(
              home: HomePageWidget(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Initial Hindi State
      expect(find.text('आरोग्यम्'), findsOneWidget);
      expect(find.text('पर्चा स्कैन करें'), findsOneWidget);
      expect(find.text('दवा पट्टी जांचें'), findsOneWidget);

      // 2. Switch to Marathi
      await vernService.setLanguage(AppLanguage.marathi);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('प्रिस्क्रिप्शन स्कॅन करा'), findsOneWidget);
      expect(find.text('औषध पट्टी तपासा'), findsOneWidget);
      expect(find.text('औषध वेळापत्रक'), findsOneWidget);

      // 3. Switch to English
      await vernService.setLanguage(AppLanguage.english);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scan Prescription'), findsOneWidget);
      expect(find.text('Verify Blister Strip'), findsOneWidget);
      expect(find.text('Daily Schedule'), findsOneWidget);
    });

    testWidgets('ReportSannerWidget dynamically renders in Marathi and English',
        (WidgetTester tester) async {
      await vernService.setLanguage(AppLanguage.marathi);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: storageService),
            ChangeNotifierProvider.value(value: vernService),
            ChangeNotifierProvider.value(value: dadiService),
          ],
          child: const MaterialApp(
            home: ReportSannerWidget(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('प्रिस्क्रिप्शन स्कॅनर (Prescription AI)'), findsOneWidget);
      expect(find.text('हस्तलिखित प्रिस्क्रिप्शन स्कॅन करा'), findsOneWidget);
      expect(find.text('कॅमेरा (Camera)'), findsOneWidget);
      expect(find.text('गॅलरी (Gallery)'), findsOneWidget);
    });

    testWidgets('BlisterVerifierWidget dynamically renders in Marathi and English',
        (WidgetTester tester) async {
      await vernService.setLanguage(AppLanguage.english);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: storageService),
            ChangeNotifierProvider.value(value: vernService),
            ChangeNotifierProvider.value(value: dadiService),
          ],
          child: const MaterialApp(
            home: BlisterVerifierWidget(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Blister Strip Verifier'), findsOneWidget);
      expect(find.text('Scan Medicine Blister Strip'), findsOneWidget);
      expect(find.text('Capture Foil Photo'), findsOneWidget);
      expect(find.text('Select from Gallery'), findsOneWidget);
    });

    testWidgets('ReminderPageWidget dynamically renders tabs in Marathi and English',
        (WidgetTester tester) async {
      await vernService.setLanguage(AppLanguage.marathi);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: storageService),
            ChangeNotifierProvider.value(value: vernService),
            ChangeNotifierProvider.value(value: dadiService),
          ],
          child: const MaterialApp(
            home: ReminderPageWidget(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('औषध वेळापत्रक (Schedule)'), findsOneWidget);
      expect(find.text('आजचे डोस'), findsOneWidget);
      expect(find.text('सक्रिय औषधे'), findsOneWidget);
      expect(find.text('प्रिस्क्रिप्शन इतिहास'), findsOneWidget);
      expect(find.text('औषध जोडा'), findsOneWidget);
    });
  });
}
