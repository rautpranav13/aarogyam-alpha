import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/core/models/dadi_ma_models.dart';
import 'package:aarogyam/core/services/dadi_ma_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';

void main() {
  late DadiMaService dadiService;
  late VernacularService vernService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    vernService = VernacularService();
    await vernService.initialize();
    dadiService = DadiMaService();
    await dadiService.initialize();
  });

  group('DadiMaService Unit Tests', () {
    test('Initialization seeds welcome message in Hindi by default', () {
      expect(dadiService.messages.isNotEmpty, isTrue);
      expect(dadiService.messages.first.sender, DadiMaSender.dadiMa);
      expect(dadiService.messages.first.text, contains('दादी-माँ'));
    });

    test('Switching language updates initial message and remedies in Marathi', () async {
      await vernService.setLanguage(AppLanguage.marathi);
      dadiService.resetForLanguage(AppLanguage.marathi);

      expect(dadiService.messages.first.text, contains('आजी'));
      expect(dadiService.remedies.isNotEmpty, isTrue);
      expect(
        dadiService.remedies.first.title,
        anyOf([contains('काढा'), contains('पाणी'), contains('दूध'), contains('तुळस')]),
      );
    });

    test('Switching language updates initial message in English', () async {
      await vernService.setLanguage(AppLanguage.english);
      dadiService.resetForLanguage(AppLanguage.english);

      expect(dadiService.messages.first.text, contains('Dadi-Ma'));
      expect(
        dadiService.remedies.first.title,
        anyOf([contains('Infusion'), contains('Water'), contains('Milk'), contains('Tulsi')]),
      );
    });

    test('Offline fallback chat accurately answers cough and cold queries with remedies', () async {
      await vernService.setLanguage(AppLanguage.hindi);
      dadiService.resetForLanguage(AppLanguage.hindi);

      await dadiService.sendMessage('मुझे बहुत तेज खांसी हो रही है');

      expect(dadiService.messages.length, greaterThanOrEqualTo(2));
      final lastMsg = dadiService.messages.last;
      expect(lastMsg.sender, DadiMaSender.dadiMa);
      expect(lastMsg.isEmergency, isFalse);
      expect(
        lastMsg.text,
        anyOf([contains('तुलसी'), contains('काढ़ा'), contains('खांसी')]),
      );
      expect(lastMsg.remedies.isNotEmpty, isTrue);
      expect(lastMsg.remedies.first.id, 'cough_cold');
    });

    test('Offline emergency symptom detection flags red-alert for chest pain', () async {
      await vernService.setLanguage(AppLanguage.hindi);
      dadiService.resetForLanguage(AppLanguage.hindi);

      await dadiService.sendMessage('सीने में बहुत तेज दर्द है और सांस रुक रही है');

      final lastMsg = dadiService.messages.last;
      expect(lastMsg.isEmergency, isTrue);
      expect(lastMsg.actionRequired, 'CALL_108_OR_VISIT_DOCTOR');
      expect(
        lastMsg.emergencyWarning,
        anyOf([contains('१०८'), contains('आपातकालीन')]),
      );
    });

    test('Daily guidance generator returns period and localized text', () async {
      await dadiService.fetchDailyGuidance();
      expect(dadiService.dailyGuidance, isNotNull);
      expect(dadiService.dailyGuidance!.title.isNotEmpty, isTrue);
      expect(dadiService.dailyGuidance!.text.isNotEmpty, isTrue);
    });

    test('Slow speech toggle works', () {
      expect(dadiService.isSlowSpeech, isFalse);
      dadiService.toggleSlowSpeech();
      expect(dadiService.isSlowSpeech, isTrue);
      dadiService.toggleSlowSpeech();
      expect(dadiService.isSlowSpeech, isFalse);
    });
  });
}
