import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/main_pages/report_sanner/report_sanner_widget.dart';
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

  testWidgets('ReportSannerWidget renders production UI and scanner options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: ReportSannerWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.textContaining('पर्चा स्कैनर'), findsOneWidget);

    // Verify Action Buttons
    expect(find.textContaining('कैमरा'), findsOneWidget);
    expect(find.text('गैलरी (Gallery)'), findsOneWidget);
  });
}
