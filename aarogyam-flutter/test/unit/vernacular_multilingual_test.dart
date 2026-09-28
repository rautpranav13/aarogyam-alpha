import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/core/models/medication_schedule.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';

void main() {
  late VernacularService vernService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    vernService = VernacularService();
    await vernService.initialize();
  });

  group('VernacularService Trilingual Dictionary Tests', () {
    test('Default language is Hindi', () {
      expect(vernService.currentLanguage, AppLanguage.hindi);
      expect(vernService.langCode, 'hi');
      expect(vernService.langDisplayName, 'हिंदी');
      expect(vernService.t('appName'), 'आरोग्यम्');
      expect(vernService.t('actionScanRxTitle'), 'पर्चा स्कैन करें');
      expect(vernService.t('btnCamera'), 'कैमरा (Camera)');
    });

    test('Switching to Marathi dynamically updates all keys', () async {
      await vernService.setLanguage(AppLanguage.marathi);

      expect(vernService.currentLanguage, AppLanguage.marathi);
      expect(vernService.langCode, 'mr');
      expect(vernService.langDisplayName, 'मराठी');
      expect(vernService.t('appName'), 'आरोग्यम्');
      expect(vernService.t('actionScanRxTitle'), 'प्रिस्क्रिप्शन स्कॅन करा');
      expect(vernService.t('actionVerifyStripTitle'), 'औषध पट्टी तपासा');
      expect(vernService.t('actionScheduleTitle'), 'औषध वेळापत्रक');
      expect(vernService.t('tabTodayDoses'), 'आजचे डोस');
      expect(vernService.t('tabActiveMeds'), 'सक्रिय औषधे');
      expect(vernService.t('tabRxHistory'), 'प्रिस्क्रिप्शन इतिहास');
      expect(vernService.t('btnFoilPhoto'), 'पट्टीचा फोटो काढा');
    });

    test('Switching to English dynamically updates all keys', () async {
      await vernService.setLanguage(AppLanguage.english);

      expect(vernService.currentLanguage, AppLanguage.english);
      expect(vernService.langCode, 'en');
      expect(vernService.langDisplayName, 'English');
      expect(vernService.t('appName'), 'Aarogyam');
      expect(vernService.t('actionScanRxTitle'), 'Scan Prescription');
      expect(vernService.t('actionVerifyStripTitle'), 'Verify Blister Strip');
      expect(vernService.t('actionScheduleTitle'), 'Daily Schedule');
      expect(vernService.t('tabTodayDoses'), 'Today Doses');
      expect(vernService.t('tabActiveMeds'), 'Active Medicines');
      expect(vernService.t('tabRxHistory'), 'Prescriptions');
      expect(vernService.t('btnCamera'), 'Camera');
      expect(vernService.t('btnFoilPhoto'), 'Capture Foil Photo');
    });

    test('Slot name and food relation translations work correctly across languages', () async {
      // Hindi
      await vernService.setLanguage(AppLanguage.hindi);
      expect(vernService.slotName('Morning'), 'सुबह (Morning)');
      expect(vernService.slotName('Afternoon'), 'दोपहर (Noon)');
      expect(vernService.slotName('Night'), 'रात (Night)');
      expect(vernService.foodRelation('After Food'), 'भोजन के बाद');
      expect(vernService.foodRelation('Before Food'), 'भोजन से पहले (खाली पेट)');

      // Marathi
      await vernService.setLanguage(AppLanguage.marathi);
      expect(vernService.slotName('Morning'), 'सकाळ (Morning)');
      expect(vernService.slotName('Afternoon'), 'दुपार (Noon)');
      expect(vernService.slotName('Night'), 'रात्र (Night)');
      expect(vernService.foodRelation('After Food'), 'जेवणानंतर');
      expect(vernService.foodRelation('Before Food'), 'जेवणापूर्वी (उपाशीपोटी)');

      // English
      await vernService.setLanguage(AppLanguage.english);
      expect(vernService.slotName('Morning'), 'Morning');
      expect(vernService.slotName('Afternoon'), 'Afternoon');
      expect(vernService.slotName('Night'), 'Night');
      expect(vernService.foodRelation('After Food'), 'After Food');
      expect(vernService.foodRelation('Before Food'), 'Before Food');
    });

    test('Medicine instruction and Prescription summary translation helpers', () async {
      final sampleMed = MedicineItem(
        id: 'med_test',
        name: 'Paracetamol 650mg',
        dosage: '650mg',
        frequency: '1-0-1',
        morning: true,
        night: true,
        foodRelation: 'After Food',
        instructionsHindi: 'भोजन के बाद 1 गोली लें।',
        instructionsMarathi: 'जेवणानंतर १ गोळी घ्या.',
        instructionsEnglish: 'Take 1 tablet after food.',
      );

      final sampleRx = PrescriptionRecord(
        id: 'rx_test',
        doctorName: 'Dr. Patil',
        clinicHospital: 'City Clinic',
        diagnosis: 'Fever',
        medicines: [sampleMed],
        vernacularSummaryHindi: 'कृपया बुखार की दवा समय पर लें।',
        vernacularSummaryMarathi: 'कृपया तापाचे औषध वेळेवर घ्या.',
        vernacularSummaryEnglish: 'Please take fever medication on time.',
      );

      await vernService.setLanguage(AppLanguage.hindi);
      expect(vernService.getMedicineInstruction(sampleMed), 'भोजन के बाद 1 गोली लें।');
      expect(vernService.getPrescriptionSummary(sampleRx), 'कृपया बुखार की दवा समय पर लें।');

      await vernService.setLanguage(AppLanguage.marathi);
      expect(vernService.getMedicineInstruction(sampleMed), 'जेवणानंतर १ गोळी घ्या.');
      expect(vernService.getPrescriptionSummary(sampleRx), 'कृपया तापाचे औषध वेळेवर घ्या.');

      await vernService.setLanguage(AppLanguage.english);
      expect(vernService.getMedicineInstruction(sampleMed), 'Take 1 tablet after food.');
      expect(vernService.getPrescriptionSummary(sampleRx), 'Please take fever medication on time.');
    });
  });
}
