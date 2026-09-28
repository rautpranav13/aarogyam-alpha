import 'package:flutter/material.dart';

enum DoseStatus { pending, taken, missed, skipped }

enum VerificationStatus { matchSafe, mismatchDanger, expired, unclear }

class MedicineItem {
  final String id;
  final String name;
  final String dosage;
  final String form; // Tablet, Capsule, Syrup, Drops, Injection
  final String frequency; // 1-0-1, 1-0-0, 0-0-1, etc.
  final bool morning;
  final bool afternoon;
  final bool night;
  final String morningTime;
  final String afternoonTime;
  final String nightTime;
  final String foodRelation; // After Food, Before Food, With Food
  final int durationDays;
  final String instructionsHindi;
  final String instructionsMarathi;
  final String instructionsEnglish;
  final String pillColorHex;
  final String pillShape; // round, capsule, oval
  final DateTime startDate;
  final String? expiryDate;
  final bool isPrescriptionActive;

  MedicineItem({
    required this.id,
    required this.name,
    required this.dosage,
    this.form = 'Tablet',
    this.frequency = '1-0-1',
    this.morning = true,
    this.afternoon = false,
    this.night = true,
    this.morningTime = '08:00 AM',
    this.afternoonTime = '01:30 PM',
    this.nightTime = '08:30 PM',
    this.foodRelation = 'After Food',
    this.durationDays = 7,
    this.instructionsHindi = 'भोजन के बाद पानी के साथ लें।',
    this.instructionsMarathi = 'जेवणानंतर पाण्यासोबत घ्या.',
    this.instructionsEnglish = 'Take with water after meals.',
    this.pillColorHex = '#00796B',
    this.pillShape = 'capsule',
    DateTime? startDate,
    this.expiryDate,
    this.isPrescriptionActive = true,
  }) : startDate = startDate ?? DateTime.now();

  Color get pillColor {
    try {
      final hex = pillColorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF00796B);
    }
  }

  List<String> get timing24hr {
    final list = <String>[];
    if (morning) list.add('08:00');
    if (afternoon) list.add('13:30');
    if (night) list.add('20:30');
    return list;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'form': form,
        'frequency': frequency,
        'morning': morning,
        'afternoon': afternoon,
        'night': night,
        'morningTime': morningTime,
        'afternoonTime': afternoonTime,
        'nightTime': nightTime,
        'foodRelation': foodRelation,
        'durationDays': durationDays,
        'instructionsHindi': instructionsHindi,
        'instructionsMarathi': instructionsMarathi,
        'instructionsEnglish': instructionsEnglish,
        'pillColorHex': pillColorHex,
        'pillShape': pillShape,
        'startDate': startDate.toIso8601String(),
        'expiryDate': expiryDate,
        'isPrescriptionActive': isPrescriptionActive,
      };

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: json['id'] as String? ?? 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Unknown Medicine',
      dosage: json['dosage'] as String? ?? '500 mg',
      form: json['form'] as String? ?? 'Tablet',
      frequency: json['frequency'] as String? ?? '1-0-1',
      morning: json['morning'] as bool? ?? true,
      afternoon: json['afternoon'] as bool? ?? false,
      night: json['night'] as bool? ?? true,
      morningTime: json['morningTime'] as String? ?? '08:00 AM',
      afternoonTime: json['afternoonTime'] as String? ?? '01:30 PM',
      nightTime: json['nightTime'] as String? ?? '08:30 PM',
      foodRelation: json['foodRelation'] as String? ?? 'After Food',
      durationDays: json['durationDays'] as int? ?? 7,
      instructionsHindi: json['instructionsHindi'] as String? ?? 'भोजन के बाद पानी के साथ लें।',
      instructionsMarathi: json['instructionsMarathi'] as String? ?? 'जेवणानंतर पाण्यासोबत घ्या.',
      instructionsEnglish: json['instructionsEnglish'] as String? ?? 'Take with water after meals.',
      pillColorHex: json['pillColorHex'] as String? ?? '#00796B',
      pillShape: json['pillShape'] as String? ?? 'capsule',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      expiryDate: json['expiryDate'] as String?,
      isPrescriptionActive: json['isPrescriptionActive'] as bool? ?? true,
    );
  }

  MedicineItem copyWith({
    String? id,
    String? name,
    String? dosage,
    String? form,
    String? frequency,
    bool? morning,
    bool? afternoon,
    bool? night,
    String? morningTime,
    String? afternoonTime,
    String? nightTime,
    String? foodRelation,
    int? durationDays,
    String? instructionsHindi,
    String? instructionsMarathi,
    String? instructionsEnglish,
    String? pillColorHex,
    String? pillShape,
    DateTime? startDate,
    String? expiryDate,
    bool? isPrescriptionActive,
  }) {
    return MedicineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      night: night ?? this.night,
      morningTime: morningTime ?? this.morningTime,
      afternoonTime: afternoonTime ?? this.afternoonTime,
      nightTime: nightTime ?? this.nightTime,
      foodRelation: foodRelation ?? this.foodRelation,
      durationDays: durationDays ?? this.durationDays,
      instructionsHindi: instructionsHindi ?? this.instructionsHindi,
      instructionsMarathi: instructionsMarathi ?? this.instructionsMarathi,
      instructionsEnglish: instructionsEnglish ?? this.instructionsEnglish,
      pillColorHex: pillColorHex ?? this.pillColorHex,
      pillShape: pillShape ?? this.pillShape,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isPrescriptionActive: isPrescriptionActive ?? this.isPrescriptionActive,
    );
  }
}

class DoseLogEntry {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final String scheduledSlot; // Morning, Afternoon, Night
  final String scheduledTime;
  final DoseStatus status;
  final DateTime? takenAt;
  final bool verifiedViaFoil;
  final String? detectedFoilText;
  final String pillColorHex;
  final String foodRelation;

  DoseLogEntry({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.scheduledSlot,
    required this.scheduledTime,
    this.status = DoseStatus.pending,
    this.takenAt,
    this.verifiedViaFoil = false,
    this.detectedFoilText,
    this.pillColorHex = '#00796B',
    this.foodRelation = 'After Food',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'scheduledSlot': scheduledSlot,
        'scheduledTime': scheduledTime,
        'status': status.name,
        'takenAt': takenAt?.toIso8601String(),
        'verifiedViaFoil': verifiedViaFoil,
        'detectedFoilText': detectedFoilText,
        'pillColorHex': pillColorHex,
        'foodRelation': foodRelation,
      };

  factory DoseLogEntry.fromJson(Map<String, dynamic> json) {
    return DoseLogEntry(
      id: json['id'] as String? ?? 'dose_${DateTime.now().millisecondsSinceEpoch}',
      medicineId: json['medicineId'] as String? ?? '',
      medicineName: json['medicineName'] as String? ?? 'Unknown Medicine',
      dosage: json['dosage'] as String? ?? '',
      scheduledSlot: json['scheduledSlot'] as String? ?? 'Morning',
      scheduledTime: json['scheduledTime'] as String? ?? '08:00 AM',
      status: DoseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DoseStatus.pending,
      ),
      takenAt: json['takenAt'] != null ? DateTime.tryParse(json['takenAt'] as String) : null,
      verifiedViaFoil: json['verifiedViaFoil'] as bool? ?? false,
      detectedFoilText: json['detectedFoilText'] as String?,
      pillColorHex: json['pillColorHex'] as String? ?? '#00796B',
      foodRelation: json['foodRelation'] as String? ?? 'After Food',
    );
  }

  DoseLogEntry copyWith({
    String? id,
    String? medicineId,
    String? medicineName,
    String? dosage,
    String? scheduledSlot,
    String? scheduledTime,
    DoseStatus? status,
    DateTime? takenAt,
    bool? verifiedViaFoil,
    String? detectedFoilText,
    String? pillColorHex,
    String? foodRelation,
  }) {
    return DoseLogEntry(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      scheduledSlot: scheduledSlot ?? this.scheduledSlot,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
      verifiedViaFoil: verifiedViaFoil ?? this.verifiedViaFoil,
      detectedFoilText: detectedFoilText ?? this.detectedFoilText,
      pillColorHex: pillColorHex ?? this.pillColorHex,
      foodRelation: foodRelation ?? this.foodRelation,
    );
  }
}

class PrescriptionRecord {
  final String id;
  final String doctorName;
  final String clinicHospital;
  final String diagnosis;
  final DateTime scannedDate;
  final List<MedicineItem> medicines;
  final String rawOcrText;
  final String redactedPiiProof;
  final String vernacularSummaryHindi;
  final String vernacularSummaryMarathi;
  final String vernacularSummaryEnglish;
  final String? audioBase64;

  PrescriptionRecord({
    required this.id,
    this.doctorName = 'Dr. S. K. Sharma, MD',
    this.clinicHospital = 'District Hospital / Community Health Centre',
    this.diagnosis = 'Hypertension & Type 2 Diabetes Management',
    DateTime? scannedDate,
    required this.medicines,
    this.rawOcrText = '',
    this.redactedPiiProof = 'Patient Identity Redacted: [MASKED-AADHAAR-XXXX] [MASKED-PHONE-XXXX]',
    this.vernacularSummaryHindi = 'आपके पर्चे में 3 दवाइयाँ हैं। कृपया समय पर लें।',
    this.vernacularSummaryMarathi = 'तुमच्या प्रिस्क्रिप्शनमध्ये 3 औषधे आहेत. कृपया वेळेवर घ्या.',
    this.vernacularSummaryEnglish = 'Your prescription contains 3 medications. Please take on schedule.',
    this.audioBase64,
  }) : scannedDate = scannedDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorName': doctorName,
        'clinicHospital': clinicHospital,
        'diagnosis': diagnosis,
        'scannedDate': scannedDate.toIso8601String(),
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'rawOcrText': rawOcrText,
        'redactedPiiProof': redactedPiiProof,
        'vernacularSummaryHindi': vernacularSummaryHindi,
        'vernacularSummaryMarathi': vernacularSummaryMarathi,
        'vernacularSummaryEnglish': vernacularSummaryEnglish,
        'audioBase64': audioBase64,
      };

  factory PrescriptionRecord.fromJson(Map<String, dynamic> json) {
    return PrescriptionRecord(
      id: json['id'] as String? ?? 'rx_${DateTime.now().millisecondsSinceEpoch}',
      doctorName: json['doctorName'] as String? ?? 'Dr. S. K. Sharma, MD',
      clinicHospital: json['clinicHospital'] as String? ?? 'Community Health Centre',
      diagnosis: json['diagnosis'] as String? ?? 'General Health Management',
      scannedDate: json['scannedDate'] != null
          ? DateTime.tryParse(json['scannedDate'] as String)
          : DateTime.now(),
      medicines: (json['medicines'] as List<dynamic>?)
              ?.map((m) => MedicineItem.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      rawOcrText: json['rawOcrText'] as String? ?? '',
      redactedPiiProof: json['redactedPiiProof'] as String? ?? '',
      vernacularSummaryHindi: json['vernacularSummaryHindi'] as String? ?? '',
      vernacularSummaryMarathi: json['vernacularSummaryMarathi'] as String? ?? '',
      vernacularSummaryEnglish: json['vernacularSummaryEnglish'] as String? ?? '',
      audioBase64: json['audioBase64'] as String?,
    );
  }
}

class BlisterVerificationResult {
  final bool isSafe;
  final VerificationStatus status;
  final String detectedDrugName;
  final String detectedDosage;
  final String detectedBatch;
  final String detectedExpiry;
  final bool isExpired;
  final double confidenceScore;
  final String matchedMedicineName;
  final String vernacularMessageHindi;
  final String vernacularMessageMarathi;
  final String vernacularMessageEnglish;
  final String rawDetectedText;

  BlisterVerificationResult({
    required this.isSafe,
    required this.status,
    required this.detectedDrugName,
    this.detectedDosage = '',
    this.detectedBatch = '',
    this.detectedExpiry = '',
    this.isExpired = false,
    this.confidenceScore = 0.95,
    required this.matchedMedicineName,
    required this.vernacularMessageHindi,
    required this.vernacularMessageMarathi,
    required this.vernacularMessageEnglish,
    this.rawDetectedText = '',
  });

  Map<String, dynamic> toJson() => {
        'isSafe': isSafe,
        'status': status.name,
        'detectedDrugName': detectedDrugName,
        'detectedDosage': detectedDosage,
        'detectedBatch': detectedBatch,
        'detectedExpiry': detectedExpiry,
        'isExpired': isExpired,
        'confidenceScore': confidenceScore,
        'matchedMedicineName': matchedMedicineName,
        'vernacularMessageHindi': vernacularMessageHindi,
        'vernacularMessageMarathi': vernacularMessageMarathi,
        'vernacularMessageEnglish': vernacularMessageEnglish,
        'rawDetectedText': rawDetectedText,
      };

  factory BlisterVerificationResult.fromJson(Map<String, dynamic> json) {
    return BlisterVerificationResult(
      isSafe: json['isSafe'] as bool? ?? false,
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => json['isSafe'] == true ? VerificationStatus.matchSafe : VerificationStatus.mismatchDanger,
      ),
      detectedDrugName: json['detectedDrugName'] as String? ?? 'Unknown Drug',
      detectedDosage: json['detectedDosage'] as String? ?? '',
      detectedBatch: json['detectedBatch'] as String? ?? '',
      detectedExpiry: json['detectedExpiry'] as String? ?? '',
      isExpired: json['isExpired'] as bool? ?? false,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.9,
      matchedMedicineName: json['matchedMedicineName'] as String? ?? '',
      vernacularMessageHindi: json['vernacularMessageHindi'] as String? ?? '',
      vernacularMessageMarathi: json['vernacularMessageMarathi'] as String? ?? '',
      vernacularMessageEnglish: json['vernacularMessageEnglish'] as String? ?? '',
      rawDetectedText: json['rawDetectedText'] as String? ?? '',
    );
  }
}
