import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/main_pages/blister_verifier/blister_verifier_widget.dart';
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

  testWidgets('BlisterVerifierWidget renders production UI and camera triggers',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: vernService),
        ],
        child: const MaterialApp(
          home: BlisterVerifierWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.textContaining('दवा पट्टी सत्यापन'), findsOneWidget);

    // Verify Camera / Foil scanner buttons
    expect(find.text('पट्टी फोटो खींचें'), findsOneWidget);
    expect(find.text('गैलरी से चुनें'), findsOneWidget);
  });
}
