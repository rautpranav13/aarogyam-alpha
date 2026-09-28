import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogyam/core/models/medication_schedule.dart';
import 'package:aarogyam/core/services/medication_storage_service.dart';
import 'package:aarogyam/core/services/mlkit_ocr_service.dart';
import 'package:aarogyam/core/services/vernacular_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('End-to-End Pipeline: Digitize Rx -> Schedule Doses -> Verify Blister Strip', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = MedicationStorageService();
    await storage.initialize();

    final vernService = VernacularService();
    await vernService.initialize();

    final ocrService = MLKitOcrService();

    // 1. Initial State: Defaults loaded (3 default meds)
    expect(storage.medicines.isNotEmpty, true);
    final initialMedicineCount = storage.medicines.length;

    // 2. Simulate Prescription Ingestion & Digitize (New Distinct Medicine)
    final newPrescription = PrescriptionRecord(
      id: 'rx_test_001',
      doctorName: 'Dr. Ramesh Sharma, MD',
      clinicHospital: 'AIIMS New Delhi',
      scannedDate: DateTime.now(),
      diagnosis: 'Hypercholesterolemia Management',
      medicines: [
        MedicineItem(
          id: 'med_test_atorvastatin',
          name: 'Atorvastatin 20mg',
          dosage: '20mg',
          morning: true,
          afternoon: false,
          night: true,
          foodRelation: 'After Food',
          durationDays: 30,
          instructionsHindi: 'रात भोजन के बाद एक गोली',
          instructionsMarathi: 'रात्री जेवणानंतर एक गोळी',
          instructionsEnglish: '1 tablet at bedtime after dinner',
          pillColorHex: '#4CAF50',
        ),
      ],
      rawOcrText: 'Dr Ramesh Sharma AIIMS Atorvastatin 20mg 1-0-1 after food 30 days',
      redactedPiiProof: '[DOCTOR] AIIMS Atorvastatin 20mg 1-0-1 after food 30 days',
      vernacularSummaryHindi: 'डॉक्टर शर्मा ने अटोर्वास्टेटिन दी है।',
      vernacularSummaryMarathi: 'डॉक्टर शर्मा यांनी अटोर्वास्टेटिन दिली आहे.',
    );

    await storage.addPrescription(newPrescription);
    expect(storage.medicines.length, initialMedicineCount + 1);

    // 3. Verify Today Dose Logs Generated for New Medicine
    final todayLogs = storage.todayDoseLogs;
    final atorvastatinMorningDose = todayLogs.firstWhere(
      (d) => d.medicineId == 'med_test_atorvastatin' && d.scheduledSlot == 'Morning',
    );
    expect(atorvastatinMorningDose.status, DoseStatus.pending);

    // 4. Mark Morning Dose Taken
    await storage.markDoseTaken(atorvastatinMorningDose.id);
    final updatedDose = storage.todayDoseLogs.firstWhere((d) => d.id == atorvastatinMorningDose.id);
    expect(updatedDose.status, DoseStatus.taken);
    expect(storage.adherenceRate > 0, true);

    // 5. Verify Blister Strip Match with OCR Service Logic
    final targetMed = storage.medicines.firstWhere((m) => m.id == 'med_test_atorvastatin');
    
    // Simulate OCR text read from actual foil strip
    const mockFoilText = 'ATORVASTATIN TABLETS IP 20 mg Exp: 12/2027 B.No. AT8910';
    final resultSafe = ocrService.analyzeFoilText(
      rawText: mockFoilText,
      targetMedicine: targetMed,
      activeMedicines: storage.medicines,
    );

    expect(resultSafe.status, VerificationStatus.matchSafe);
    expect(resultSafe.isSafe, true);
    expect(resultSafe.isExpired, false);
    expect(resultSafe.confidenceScore >= 0.7, true);

    // 6. Verify Blister Mismatch Alert (valid future expiry 11/2028)
    const mockWrongFoilText = 'AMLODIPINE BESYLATE TABLETS IP 5 mg Exp: 11/2028';
    final resultMismatch = ocrService.analyzeFoilText(
      rawText: mockWrongFoilText,
      targetMedicine: targetMed,
      activeMedicines: storage.medicines,
    );

    expect(resultMismatch.status, VerificationStatus.mismatchDanger);
    expect(resultMismatch.isSafe, false);

    // 7. Verify Expired Alert
    const mockExpiredFoilText = 'ATORVASTATIN TABLETS IP 20 mg Exp: 01/2021';
    final resultExpired = ocrService.analyzeFoilText(
      rawText: mockExpiredFoilText,
      targetMedicine: targetMed,
      activeMedicines: storage.medicines,
    );

    expect(resultExpired.status, VerificationStatus.expired);
    expect(resultExpired.isSafe, false);
    expect(resultExpired.isExpired, true);

    // 8. Vernacular TTS Output Synthesis
    expect(vernService.langCode, 'hi');
    vernService.setLanguage(AppLanguage.marathi);
    expect(vernService.langCode, 'mr');
    vernService.setLanguage(AppLanguage.english);
    expect(vernService.langCode, 'en');
  });
}
