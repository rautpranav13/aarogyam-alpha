import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_schedule.dart';

class MedicationStorageService extends ChangeNotifier {
  static final MedicationStorageService _instance = MedicationStorageService._internal();
  factory MedicationStorageService() => _instance;
  MedicationStorageService._internal();

  static const String _prescriptionsKey = 'aarogyam_prescriptions_v1';
  static const String _medicinesKey = 'aarogyam_medicines_v1';
  static const String _doseLogsKey = 'aarogyam_dose_logs_v1';
  static const String _lastDateKey = 'aarogyam_last_dose_date_v1';

  List<PrescriptionRecord> _prescriptions = [];
  List<MedicineItem> _medicines = [];
  List<DoseLogEntry> _todayDoseLogs = [];
  bool _initialized = false;

  List<PrescriptionRecord> get prescriptions => List.unmodifiable(_prescriptions);
  List<PrescriptionRecord> get rxRecords => List.unmodifiable(_prescriptions);
  List<MedicineItem> get medicines => List.unmodifiable(_medicines.where((m) => m.isPrescriptionActive));
  List<MedicineItem> get activeMedications => List.unmodifiable(_medicines.where((m) => m.isPrescriptionActive));
  List<DoseLogEntry> get todayDoseLogs => List.unmodifiable(_todayDoseLogs);

  DoseLogEntry? get nextDose {
    final pending = _todayDoseLogs.where((d) => d.status == DoseStatus.pending).toList();
    if (pending.isEmpty) return null;
    return pending.first;
  }

  int get completedDosesCount => _todayDoseLogs.where((d) => d.status == DoseStatus.taken).length;
  int get totalDosesToday => _todayDoseLogs.length;
  double get adherenceRate => totalDosesToday == 0 ? 1.0 : completedDosesCount / totalDosesToday;

  Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) {
      if (_todayDoseLogs.isEmpty && _medicines.isNotEmpty) {
        _generateTodayDoseLogs();
        notifyListeners();
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    final rxRaw = prefs.getString(_prescriptionsKey);
    final medRaw = prefs.getString(_medicinesKey);
    final logsRaw = prefs.getString(_doseLogsKey);
    final lastDate = prefs.getString(_lastDateKey);
    final todayStr = _formatToday();

    if (rxRaw != null && medRaw != null) {
      try {
        final List<dynamic> rxList = jsonDecode(rxRaw) as List<dynamic>;
        _prescriptions = rxList.map((e) => PrescriptionRecord.fromJson(e as Map<String, dynamic>)).toList();

        final List<dynamic> medList = jsonDecode(medRaw) as List<dynamic>;
        _medicines = medList.map((e) => MedicineItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Error parsing saved medications: $e');
        _loadDefaultData();
      }
    } else {
      _loadDefaultData();
    }

    if (lastDate == todayStr && logsRaw != null) {
      try {
        final List<dynamic> logsList = jsonDecode(logsRaw) as List<dynamic>;
        _todayDoseLogs = logsList.map((e) => DoseLogEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _generateTodayDoseLogs();
      }
    } else {
      _generateTodayDoseLogs();
      await prefs.setString(_lastDateKey, todayStr);
    }

    if (_todayDoseLogs.isEmpty && _medicines.isNotEmpty) {
      _generateTodayDoseLogs();
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadDefaultData() {
    final med1 = MedicineItem(
      id: 'med_metformin_500',
      name: 'Metformin Hydrochloride 500mg',
      dosage: '500 mg (1 Tablet)',
      form: 'Tablet',
      frequency: '1-0-1',
      morning: true,
      afternoon: false,
      night: true,
      morningTime: '08:00 AM',
      nightTime: '08:30 PM',
      foodRelation: 'After Food',
      durationDays: 30,
      instructionsHindi: 'मधुमेह नियंत्रण के लिए - सुबह और रात भोजन के बाद 1 गोली लें।',
      instructionsMarathi: 'मधुमेह नियंत्रणासाठी - सकाळी आणि रात्री जेवणानंतर १ गोळी घ्या.',
      instructionsEnglish: 'For blood sugar control - Take 1 tablet after breakfast and dinner.',
      pillColorHex: '#00796B',
      pillShape: 'round',
    );

    final med2 = MedicineItem(
      id: 'med_telmisartan_40',
      name: 'Telmisartan 40mg',
      dosage: '40 mg (1 Tablet)',
      form: 'Tablet',
      frequency: '1-0-0',
      morning: true,
      afternoon: false,
      night: false,
      morningTime: '08:00 AM',
      foodRelation: 'After Breakfast',
      durationDays: 30,
      instructionsHindi: 'रक्तचाप (BP) नियंत्रण - सुबह नाश्ते के बाद 1 गोली लें।',
      instructionsMarathi: 'रक्तदाब (BP) नियंत्रणासाठी - सकाळी नाश्त्यानंतर १ गोळी घ्या.',
      instructionsEnglish: 'For blood pressure control - Take 1 tablet every morning after breakfast.',
      pillColorHex: '#E53935',
      pillShape: 'capsule',
    );

    final med3 = MedicineItem(
      id: 'med_pantoprazole_40',
      name: 'Pantoprazole 40mg',
      dosage: '40 mg (1 Capsule)',
      form: 'Capsule',
      frequency: '1-0-0',
      morning: true,
      afternoon: false,
      night: false,
      morningTime: '07:30 AM',
      foodRelation: 'Before Food',
      durationDays: 14,
      instructionsHindi: 'गैस और एसिडिटी से राहत - सुबह खाली पेट 1 कैप्सूल लें।',
      instructionsMarathi: 'अॅसिडिटी आणि गॅसपासून आराम - सकाळी उपाशी पोटी १ कॅप्सूल घ्या.',
      instructionsEnglish: 'For acidity & gastroprotection - Take 1 capsule early morning empty stomach.',
      pillColorHex: '#FB8C00',
      pillShape: 'capsule',
    );

    _medicines = [med1, med2, med3];

    _prescriptions = [
      PrescriptionRecord(
        id: 'rx_default_phc_1',
        doctorName: 'Dr. Anand Deshmukh, MD (Med)',
        clinicHospital: 'Rural Community Health Centre (PHC)',
        diagnosis: 'Essential Hypertension & T2 Diabetes Mellitus',
        scannedDate: DateTime.now().subtract(const Duration(days: 2)),
        medicines: [med1, med2, med3],
        rawOcrText: 'Rx: Tab Metformin 500mg 1-0-1 PC | Tab Telmisartan 40mg 1-0-0 PC | Cap Pantoprazole 40mg 1-0-0 AC',
        redactedPiiProof: 'PII Protected: Patient Name & Aadhaar de-identified via Granite Vision De-ID',
        vernacularSummaryHindi: 'डॉ. देशमुख का पर्चा: सुबह खाली पेट पैंटोप्राज़ोल, नाश्ते के बाद टेल्मीसार्टन व मेटफॉर्मिन, और रात भोजन के बाद मेटफॉर्मिन लें।',
        vernacularSummaryMarathi: 'डॉ. देशमुख यांचे प्रिस्क्रिप्शन: सकाळी उपाशीपोटी पॅन्टॉप्राझोल, नाश्त्यानंतर टेल्मीसार्टन व मेटफॉर्मिन आणि रात्री जेवणानंतर मेटफॉर्मिन घ्या.',
        vernacularSummaryEnglish: 'Dr. Deshmukh Rx: Pantoprazole before food morning, Telmisartan & Metformin after breakfast, Metformin after dinner.',
      ),
    ];
  }

  void _generateTodayDoseLogs() {
    final existingLogsMap = {for (final d in _todayDoseLogs) d.id: d};
    _todayDoseLogs.clear();

    for (final med in _medicines.where((m) => m.isPrescriptionActive)) {
      if (med.morning) {
        final id = '${med.id}_morning';
        final existing = existingLogsMap[id];
        _todayDoseLogs.add(
          DoseLogEntry(
            id: id,
            medicineId: med.id,
            medicineName: med.name,
            dosage: med.dosage,
            scheduledSlot: 'Morning',
            scheduledTime: med.morningTime,
            status: existing?.status ?? DoseStatus.pending,
            takenAt: existing?.takenAt,
            verifiedViaFoil: existing?.verifiedViaFoil ?? false,
            detectedFoilText: existing?.detectedFoilText,
            pillColorHex: med.pillColorHex,
            foodRelation: med.foodRelation,
          ),
        );
      }
      if (med.afternoon) {
        final id = '${med.id}_afternoon';
        final existing = existingLogsMap[id];
        _todayDoseLogs.add(
          DoseLogEntry(
            id: id,
            medicineId: med.id,
            medicineName: med.name,
            dosage: med.dosage,
            scheduledSlot: 'Afternoon',
            scheduledTime: med.afternoonTime,
            status: existing?.status ?? DoseStatus.pending,
            takenAt: existing?.takenAt,
            verifiedViaFoil: existing?.verifiedViaFoil ?? false,
            detectedFoilText: existing?.detectedFoilText,
            pillColorHex: med.pillColorHex,
            foodRelation: med.foodRelation,
          ),
        );
      }
      if (med.night) {
        final id = '${med.id}_night';
        final existing = existingLogsMap[id];
        _todayDoseLogs.add(
          DoseLogEntry(
            id: id,
            medicineId: med.id,
            medicineName: med.name,
            dosage: med.dosage,
            scheduledSlot: 'Night',
            scheduledTime: med.nightTime,
            status: existing?.status ?? DoseStatus.pending,
            takenAt: existing?.takenAt,
            verifiedViaFoil: existing?.verifiedViaFoil ?? false,
            detectedFoilText: existing?.detectedFoilText,
            pillColorHex: med.pillColorHex,
            foodRelation: med.foodRelation,
          ),
        );
      }
    }
    // Sort logs by time (Morning -> Afternoon -> Night)
    _todayDoseLogs.sort((a, b) {
      final order = {'Morning': 0, 'Afternoon': 1, 'Night': 2};
      return (order[a.scheduledSlot] ?? 0).compareTo(order[b.scheduledSlot] ?? 0);
    });
  }

  Future<void> markDoseTaken(String doseLogId, {bool verifiedWithFoil = false, String? detectedFoilText}) async {
    final index = _todayDoseLogs.indexWhere((d) => d.id == doseLogId);
    if (index != -1) {
      final current = _todayDoseLogs[index];
      _todayDoseLogs[index] = current.copyWith(
        status: DoseStatus.taken,
        takenAt: DateTime.now(),
        verifiedViaFoil: verifiedWithFoil,
        detectedFoilText: detectedFoilText,
      );
      await _saveLogs();
      notifyListeners();
    }
  }

  Future<void> resetDoseStatus(String doseLogId) async {
    final index = _todayDoseLogs.indexWhere((d) => d.id == doseLogId);
    if (index != -1) {
      final current = _todayDoseLogs[index];
      _todayDoseLogs[index] = current.copyWith(
        status: DoseStatus.pending,
        takenAt: null,
        verifiedViaFoil: false,
      );
      await _saveLogs();
      notifyListeners();
    }
  }

  Future<void> addPrescription(PrescriptionRecord record) async {
    _prescriptions.insert(0, record);
    for (final newMed in record.medicines) {
      final existingIndex = _medicines.indexWhere((m) => m.name.toLowerCase() == newMed.name.toLowerCase());
      if (existingIndex >= 0) {
        _medicines[existingIndex] = newMed;
      } else {
        _medicines.add(newMed);
      }
    }
    _generateTodayDoseLogs();
    await _saveAll();
    notifyListeners();
  }

  Future<void> addMedicine(MedicineItem medicine) async {
    _medicines.add(medicine);
    _generateTodayDoseLogs();
    await _saveAll();
    notifyListeners();
  }

  Future<void> removeMedicine(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    _generateTodayDoseLogs();
    await _saveAll();
    notifyListeners();
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prescriptionsKey, jsonEncode(_prescriptions.map((e) => e.toJson()).toList()));
    await prefs.setString(_medicinesKey, jsonEncode(_medicines.map((e) => e.toJson()).toList()));
    await _saveLogs();
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_doseLogsKey, jsonEncode(_todayDoseLogs.map((e) => e.toJson()).toList()));
    await prefs.setString(_lastDateKey, _formatToday());
  }

  String _formatToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
