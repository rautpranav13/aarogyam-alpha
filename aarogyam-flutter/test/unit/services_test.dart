import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/core/models/medication_schedule.dart';
import 'package:aarogyam/core/services/medication_storage_service.dart';
import 'package:aarogyam/core/services/mlkit_ocr_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MedicationStorageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with realistic default Indian PHC prescriptions', () async {
      final service = MedicationStorageService();
      await service.initialize();

      expect(service.medicines.isNotEmpty, isTrue);
      expect(service.medicines.any((m) => m.name.contains('Metformin')), isTrue);
      expect(service.prescriptions.isNotEmpty, isTrue);
      expect(service.todayDoseLogs.isNotEmpty, isTrue);
      expect(service.adherenceRate, equals(0.0));
    });

    test('Marks dose taken and updates adherence score', () async {
      final service = MedicationStorageService();
      await service.initialize();

      final firstDose = service.todayDoseLogs.first;
      await service.markDoseTaken(firstDose.id, verifiedWithFoil: true);

      expect(service.completedDosesCount, equals(1));
      expect(service.adherenceRate, greaterThan(0.0));

      final updatedDose = service.todayDoseLogs.firstWhere((d) => d.id == firstDose.id);
      expect(updatedDose.status, equals(DoseStatus.taken));
      expect(updatedDose.verifiedViaFoil, isTrue);
    });

    test('Adds and removes medicine dynamically', () async {
      final service = MedicationStorageService();
      await service.initialize();

      final initialCount = service.medicines.length;
      final newMed = MedicineItem(
        id: 'test_amox_500',
        name: 'Amoxicillin 500mg',
        dosage: '500 mg',
        frequency: '1-1-1',
        morning: true,
        afternoon: true,
        night: true,
      );

      await service.addMedicine(newMed);
      expect(service.medicines.length, equals(initialCount + 1));

      await service.removeMedicine('test_amox_500');
      expect(service.medicines.length, equals(initialCount));
    });
  });

  group('MLKitOcrService Algorithm & Foil Matcher Tests', () {
    final ocrService = MLKitOcrService();
    final activeMeds = [
      MedicineItem(
        id: 'med_1',
        name: 'Metformin Hydrochloride 500mg',
        dosage: '500 mg',
      ),
      MedicineItem(
        id: 'med_2',
        name: 'Telmisartan 40mg',
        dosage: '40 mg',
      ),
    ];

    test('Detects exact safe match for target medicine', () {
      const rawFoil = 'METFORMIN HYDROCHLORIDE 500MG IP BATCH: IND-882 EXP 12/2026';
      final result = ocrService.analyzeFoilText(
        rawText: rawFoil,
        activeMedicines: activeMeds,
        targetMedicine: activeMeds.first,
      );

      expect(result.isSafe, isTrue);
      expect(result.status, equals(VerificationStatus.matchSafe));
      expect(result.confidenceScore, greaterThanOrEqualTo(0.7));
      expect(result.isExpired, isFalse);
    });

    test('Detects lethal mismatch when foil does not match target', () {
      const rawFoil = 'AMLODIPINE BESYLATE 5MG IP BATCH: AML-102 EXP 10/2027';
      final result = ocrService.analyzeFoilText(
        rawText: rawFoil,
        activeMedicines: activeMeds,
        targetMedicine: activeMeds.first, // Expected Metformin
      );

      expect(result.isSafe, isFalse);
      expect(result.status, equals(VerificationStatus.mismatchDanger));
      expect(result.vernacularMessageHindi, contains('चेतावनी'));
    });

    test('Detects expired date on foil stamp', () {
      const rawFoil = 'METFORMIN HYDROCHLORIDE 500MG IP EXP 01/2023';
      final result = ocrService.analyzeFoilText(
        rawText: rawFoil,
        activeMedicines: activeMeds,
        targetMedicine: activeMeds.first,
      );

      expect(result.isSafe, isFalse);
      expect(result.status, equals(VerificationStatus.expired));
      expect(result.isExpired, isTrue);
    });

    test('Handles unclear image text gracefully', () {
      final result = ocrService.analyzeFoilText(
        rawText: '   ',
        activeMedicines: activeMeds,
      );

      expect(result.isSafe, isFalse);
      expect(result.status, equals(VerificationStatus.unclear));
    });
  });

  group('VernacularService Language & Locale Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Changes language and persists preference', () async {
      final vern = VernacularService();
      await vern.initialize();

      expect(vern.langCode, equals('hi'));
      expect(vern.langDisplayName, equals('हिंदी'));

      await vern.setLanguage(AppLanguage.marathi);
      expect(vern.langCode, equals('mr'));
      expect(vern.langDisplayName, equals('मराठी'));

      await vern.setLanguage(AppLanguage.english);
      expect(vern.langCode, equals('en'));
      expect(vern.langDisplayName, equals('English'));
    });
  });
}
