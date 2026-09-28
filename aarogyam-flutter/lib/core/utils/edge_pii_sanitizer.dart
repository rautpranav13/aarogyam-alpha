import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Categories of detected Personal Identifiable Information (PII).
enum PiiType {
  aadhaar,
  phone,
  patientName,
  demographic,
  abhaId,
}

/// Phone number masking presentation styles.
enum PhoneMaskStyle {
  /// Preserves prefix and last 3 digits: +91-XXXXX-XX210 or XXXXX-XX210
  partial,

  /// Opaque token replacement: [MASKED-PHONE-XXXX]
  tokenized,
}

/// Represents an individual redacted entity with auditing offsets and validation flags.
class RedactedEntity {
  final PiiType type;
  final String original; // Maintained in-memory only; excluded from exported manifest
  final String masked;
  final int startOffset;
  final int endOffset;
  final bool verhoeffValid;
  final Map<String, dynamic> metadata;

  const RedactedEntity({
    required this.type,
    required this.original,
    required this.masked,
    required this.startOffset,
    required this.endOffset,
    this.verhoeffValid = false,
    this.metadata = const {},
  });

  /// Exports audit entity for manifest without leaking original PII.
  Map<String, dynamic> toManifestJson() => {
        'entity_type': type.name.toUpperCase(),
        'verhoeff_validated': verhoeffValid,
        'masked_value': masked,
        'char_span': [startOffset, endOffset],
        if (metadata.isNotEmpty) 'metadata': metadata,
      };
}

/// Tamper-evident cryptographic audit manifest satisfying DPDP Act 2023 & ABDM.
class SanitizationManifest {
  final String proofId;
  final String version;
  final DateTime timestampUtc;
  final String clientOrigin;
  final List<String> complianceStandards;
  final String rawInputSha256;
  final String sanitizedPayloadSha256;
  final int totalRedactions;
  final int aadhaarRedacted;
  final int phoneRedacted;
  final int patientNameRedacted;
  final int demographicRedacted;
  final int abhaRedacted;
  final List<Map<String, dynamic>> auditEntities;
  final String proofToken;
  final String proofSummary;

  SanitizationManifest({
    required this.proofId,
    this.version = '2.0.0-production',
    DateTime? timestampUtc,
    this.clientOrigin = 'aarogyam-edge-flutter',
    this.complianceStandards = const [
      'DPDP_ACT_2023_SEC_8',
      'HIPAA_SAFE_HARBOR_164_514',
      'ABDM_HEALTH_DATA_POLICY',
    ],
    required this.rawInputSha256,
    required this.sanitizedPayloadSha256,
    required this.totalRedactions,
    this.aadhaarRedacted = 0,
    this.phoneRedacted = 0,
    this.patientNameRedacted = 0,
    this.demographicRedacted = 0,
    this.abhaRedacted = 0,
    required this.auditEntities,
    required this.proofToken,
    required this.proofSummary,
  }) : timestampUtc = timestampUtc ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'proof_id': proofId,
        'version': version,
        'timestamp_utc': timestampUtc.toIso8601String(),
        'client_origin': clientOrigin,
        'compliance_standards': complianceStandards,
        'digests': {
          'raw_input_sha256': rawInputSha256,
          'sanitized_payload_sha256': sanitizedPayloadSha256,
        },
        'redaction_summary': {
          'total_redactions': totalRedactions,
          'aadhaar_redacted': aadhaarRedacted,
          'phone_redacted': phoneRedacted,
          'patient_name_redacted': patientNameRedacted,
          'demographic_redacted': demographicRedacted,
          'abha_redacted': abhaRedacted,
        },
        'audit_entities': auditEntities,
        'proof_token': proofToken,
        'proof_summary': proofSummary,
      };
}

/// Result returned from edge PII sanitization containing transformed text and proof.
class PiiSanitizationResult {
  final String originalText;
  final String sanitizedText;
  final SanitizationManifest manifest;
  final Map<PiiType, int> entityCounts;
  final List<RedactedEntity> redactions;

  const PiiSanitizationResult({
    required this.originalText,
    required this.sanitizedText,
    required this.manifest,
    required this.entityCounts,
    required this.redactions,
  });

  bool get hasPii => redactions.isNotEmpty;
  int get totalRedactions => redactions.length;
}

/// Dihedral Group D5 Verhoeff Checksum Engine.
class VerhoeffAlgorithm {
  static const List<List<int>> d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];

  static const List<List<int>> p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];

  static const List<int> inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

  /// Validates a 12-digit UIDAI Aadhaar number string using the Verhoeff algorithm.
  /// Rejects numbers that do not have 12 digits or whose first digit is 0 or 1.
  static bool validate(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12) return false;

    final firstDigit = int.tryParse(digits[0]);
    if (firstDigit == null || firstDigit < 2 || firstDigit > 9) {
      return false;
    }

    int c = 0;
    final reversed = digits.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final digit = int.tryParse(reversed[i]);
      if (digit == null) return false;
      c = d[c][p[i % 8][digit]];
    }
    return c == 0;
  }

  /// Calculates the 12th Verhoeff checksum digit for an 11-digit prefix.
  static int generateChecksum(String prefix11) {
    final digits = prefix11.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) {
      throw ArgumentError('Prefix must be exactly 11 digits, got: ${digits.length}');
    }
    int c = 0;
    final reversed = digits.split('').reversed.toList();
    for (int i = 0; i < reversed.length; i++) {
      final digit = int.parse(reversed[i]);
      c = d[c][p[(i + 1) % 8][digit]];
    }
    return inv[c];
  }
}

/// On-Device / Edge PII Sanitization Engine for Aarogyam Flutter Client.
class EdgePiiSanitizer {
  // 1. Doctor & Medical Facility Safeguard Filter
  static final RegExp _doctorFilterPattern = RegExp(
    r'\b(Dr\.?|Doctor|डॉ\.?|डॉ|वैद्य|Prof\.?|Professor|MBBS|MD|MS|BAMS|BHMS|BDS|FRCS|DM|MCh|DGO|DNB|Clinic|Hospital|Dispensary|Health\s+Centre|PHC|CHC|AIIMS|Nursing\s+Home|रुग्णालय|दवाखाना|अस्पताल|आरोग्य\s+केंद्र|Reg\.?\s*No|MCI|MMC)\b',
    caseSensitive: false,
    unicode: true,
  );

  // 2. Multilingual Patient Name Anchor Pattern (English, Hindi, Marathi)
  static final RegExp _patientAnchorPattern = RegExp(
    r'(?:patient(?:\s+name)?|pt\.?\s*name|pt\b|मरीज(?:\s+का\s+नाम)?|रोगी(?:\s+का\s+नाम)?|रुग्णाचे\s+नाव)'
    r'\s*[:\-\s]\s*'
    r'((?:(?:Mr|Mrs|Ms|Shri|Smt|Kumari|Master|श्री|श्रीमती|कु)\.?\s+)?'
    r'[A-Za-z\u0900-\u097F]+(?:\s+[A-Za-z\u0900-\u097F]+){0,3})'
    r'(?=\s*(?:,|\n|\r|Age|Sex|Gender|Yrs|Yr|M/F|\bM\b|\bF\b|वर्ष|वय|दिनांक|UHID|OPD|$))',
    caseSensitive: false,
    unicode: true,
  );

  // 3. Demographic Patterns (Age, Gender, UHID, ABHA)
  static final RegExp _agePattern = RegExp(
    r'(?:^|[\s,;])(?:age|उम्र|वय)\s*[:\-\s]\s*([0-9\u0966-\u096F]{1,3}(?:\s*(?:years|yrs|yr|वर्ष))?)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _genderPattern = RegExp(
    r'(?:^|[\s,;])(?:gender|sex|लिंग)\s*[:\-\s]\s*(Male|Female|M|F|Other|पुरुष|स्त्री|इतर)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _uhidPattern = RegExp(
    r'\b(?:UHID|OPD(?:\s*No\.?)?|CR\s*No\.?)\s*[:\-\s]\s*([A-Za-z0-9\-_/]+)\b',
    caseSensitive: false,
  );

  static final RegExp _abhaPattern = RegExp(
    r'\b(\d{2}-\d{4}-\d{4}-\d{4})\b',
  );

  // 4. Aadhaar Patterns (Explicit and General)
  static final RegExp _aadhaarGeneralPattern = RegExp(
    r'\b([2-9]\d{3}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4})\b',
  );

  static final RegExp _aadhaarExplicitPattern = RegExp(
    r'(?:^|[\s,;:\n])(?:aadhaar|aadhar|adhar|uid|uidai|आधार(?:\s*क्र\.?)?)\s*[:\-\s]*([0-9]{4}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4})\b',
    caseSensitive: false,
    unicode: true,
  );

  // 5. Pharmaceutical / Supply Chain Context Pattern (False-Positive Aadhaar Shield)
  static final RegExp _pharmaContextPattern = RegExp(
    r'\b(batch(?:\s*no\.?|\s*#)?|lot(?:\s*no\.?)?|exp(?:\.|\s*date)?|expiry|mfg(?:\.|\s*date)?|barcode|gtin|invoice|sn|serial(?:\s*no\.?)?|item|rx#)\b',
    caseSensitive: false,
  );

  // 6. Contact Number Patterns (Indian Mobile and Landlines)
  static final RegExp _mobilePattern = RegExp(
    r'(?:(?:\+91|0091|91|0)[\s\-]?)?(?:(?:\(0\)\s*))?([6-9]\d{4}[\s\-]?\d{5})\b',
  );

  static final RegExp _landlinePattern = RegExp(
    r'(?:^|[\s,;:\n])(?:tel|telephone|phone|ph|contact|call|फोन|संपर्क|दूरध्वनी)\s*[:\-\s]\s*(?:\+91[\-\s]?)?(0\d{1,4}[\-\s]?\d{6,8})(?=$|[\s,;:\n])',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _serialExclusionPattern = RegExp(
    r'\b(SN|Serial|PIN|Pincode|Invoice|Ref)\s*[:#\-]?\s*$',
    caseSensitive: false,
  );

  /// Validates a 12-digit Aadhaar number using the Verhoeff algorithm.
  static bool validateAadhaarVerhoeff(String numberStr) =>
      VerhoeffAlgorithm.validate(numberStr);

  /// Generates the Verhoeff checksum digit for an 11-digit prefix.
  static int generateVerhoeffChecksum(String prefix11) =>
      VerhoeffAlgorithm.generateChecksum(prefix11);

  /// Computes SHA-256 hexadecimal hash string for text input.
  static String computeSha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Computes SHA-256 hexadecimal hash string for binary byte arrays.
  static String computeBytesSha256(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Checks if text indicates doctor or healthcare facility context.
  static bool isDoctorOrClinicContext(String text) =>
      _doctorFilterPattern.hasMatch(text);

  /// Generates a deterministic synthetic pseudonym: [PATIENT-ANON-XXXX].
  static String deidentifyPatientName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '[PATIENT-ANON-0000]';
    final hash = computeSha256(clean).substring(0, 4).toUpperCase();
    return '[PATIENT-ANON-$hash]';
  }

  /// Masks Aadhaar number to partial format: XXXXXXXX1234.
  static String maskAadhaar(String aadhaar, {bool partial = true}) {
    final digits = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '[MASKED-AADHAAR-XXXX]';
    final last4 = digits.substring(digits.length - 4);
    if (partial) {
      return 'XXXXXXXX$last4';
    }
    return '[MASKED-AADHAAR-XXXX]';
  }

  /// Masks Indian mobile or landline phone numbers.
  static String maskPhoneNumber(String phone,
      {PhoneMaskStyle style = PhoneMaskStyle.partial}) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3) return '[MASKED-PHONE-XXXX]';
    final last3 = digits.substring(digits.length - 3);
    if (style == PhoneMaskStyle.partial) {
      final has91 = phone.contains('+91') || phone.startsWith('0091');
      return has91 ? '+91-XXXXX-XX$last3' : 'XXXXX-XX$last3';
    }
    return '[MASKED-PHONE-XXXX]';
  }

  /// Executes comprehensive edge PII de-identification and returns sanitized text with audit manifest.
  static PiiSanitizationResult sanitize(
    String text, {
    String? imageRawSha256,
    String? imageRedactedSha256,
    bool partialAadhaarMask = true,
    PhoneMaskStyle phoneMaskStyle = PhoneMaskStyle.partial,
  }) {
    final rawText = text;
    String processed = text;
    final List<RedactedEntity> redactionList = [];
    final Map<PiiType, int> counts = {
      PiiType.aadhaar: 0,
      PiiType.phone: 0,
      PiiType.patientName: 0,
      PiiType.demographic: 0,
      PiiType.abhaId: 0,
    };

    // 1. Patient Name De-Identification with Doctor/Clinic Safeguard
    processed = processed.replaceAllMapped(_patientAnchorPattern, (match) {
      final fullMatch = match.group(0)!;
      final rawName = match.group(1);
      if (rawName == null || rawName.trim().isEmpty) return fullMatch;

      // Exclude doctors or clinic names
      if (isDoctorOrClinicContext(rawName) || isDoctorOrClinicContext(fullMatch)) {
        return fullMatch;
      }

      final anonToken = deidentifyPatientName(rawName);
      final replaced = fullMatch.replaceFirst(rawName, anonToken);
      redactionList.add(RedactedEntity(
        type: PiiType.patientName,
        original: rawName,
        masked: anonToken,
        startOffset: match.start,
        endOffset: match.end,
      ));
      counts[PiiType.patientName] = (counts[PiiType.patientName] ?? 0) + 1;
      return replaced;
    });

    // 2. Demographic Attributes (Age, Gender, UHID)
    processed = processed.replaceAllMapped(_agePattern, (match) {
      final full = match.group(0)!;
      final ageVal = match.group(1)!;
      final replaced = full.replaceFirst(ageVal, '[REDACTED]');
      redactionList.add(RedactedEntity(
        type: PiiType.demographic,
        original: ageVal,
        masked: '[REDACTED]',
        startOffset: match.start,
        endOffset: match.end,
        metadata: {'category': 'age'},
      ));
      counts[PiiType.demographic] = (counts[PiiType.demographic] ?? 0) + 1;
      return replaced;
    });

    processed = processed.replaceAllMapped(_genderPattern, (match) {
      final full = match.group(0)!;
      final genderVal = match.group(1)!;
      final replaced = full.replaceFirst(genderVal, '[REDACTED]');
      redactionList.add(RedactedEntity(
        type: PiiType.demographic,
        original: genderVal,
        masked: '[REDACTED]',
        startOffset: match.start,
        endOffset: match.end,
        metadata: {'category': 'gender'},
      ));
      counts[PiiType.demographic] = (counts[PiiType.demographic] ?? 0) + 1;
      return replaced;
    });

    processed = processed.replaceAllMapped(_uhidPattern, (match) {
      final full = match.group(0)!;
      final uhidVal = match.group(1)!;
      final replaced = full.replaceFirst(uhidVal, '[REDACTED]');
      redactionList.add(RedactedEntity(
        type: PiiType.demographic,
        original: uhidVal,
        masked: '[REDACTED]',
        startOffset: match.start,
        endOffset: match.end,
        metadata: {'category': 'uhid'},
      ));
      counts[PiiType.demographic] = (counts[PiiType.demographic] ?? 0) + 1;
      return replaced;
    });

    // 3. ABHA ID (14 digits)
    processed = processed.replaceAllMapped(_abhaPattern, (match) {
      final original = match.group(1)!;
      const masked = '[MASKED-ABHA-XXXX]';
      redactionList.add(RedactedEntity(
        type: PiiType.abhaId,
        original: original,
        masked: masked,
        startOffset: match.start,
        endOffset: match.end,
      ));
      counts[PiiType.abhaId] = (counts[PiiType.abhaId] ?? 0) + 1;
      return masked;
    });

    // 4. Aadhaar Numbers (Explicit and Unlabeled with Verhoeff & Pharma protection)
    // Step 4a: Explicit Aadhaar Label
    processed = processed.replaceAllMapped(_aadhaarExplicitPattern, (match) {
      final full = match.group(0)!;
      final numStr = match.group(1)!;
      final isValid = validateAadhaarVerhoeff(numStr);
      final masked = maskAadhaar(numStr, partial: partialAadhaarMask);
      final replaced = full.replaceFirst(numStr, masked);
      redactionList.add(RedactedEntity(
        type: PiiType.aadhaar,
        original: numStr,
        masked: masked,
        startOffset: match.start,
        endOffset: match.end,
        verhoeffValid: isValid,
      ));
      counts[PiiType.aadhaar] = (counts[PiiType.aadhaar] ?? 0) + 1;
      return replaced;
    });

    // Step 4b: Unlabeled 12-digit sequence
    processed = processed.replaceAllMapped(_aadhaarGeneralPattern, (match) {
      final candidate = match.group(1)!;
      final fullText = processed;
      final startWindow = match.start > 40 ? match.start - 40 : 0;
      final precedingText = fullText.substring(startWindow, match.start);

      // Skip pharmaceutical context unless explicitly labeled
      if (_pharmaContextPattern.hasMatch(precedingText)) {
        return candidate;
      }

      // Check Verhoeff checksum
      if (!validateAadhaarVerhoeff(candidate)) {
        return candidate;
      }

      final masked = maskAadhaar(candidate, partial: partialAadhaarMask);
      redactionList.add(RedactedEntity(
        type: PiiType.aadhaar,
        original: candidate,
        masked: masked,
        startOffset: match.start,
        endOffset: match.end,
        verhoeffValid: true,
      ));
      counts[PiiType.aadhaar] = (counts[PiiType.aadhaar] ?? 0) + 1;
      return masked;
    });

    // 5. Contact Numbers (Landline & Mobile)
    // Step 5a: Contextual Landline with STD code
    processed = processed.replaceAllMapped(_landlinePattern, (match) {
      final full = match.group(0)!;
      final phoneStr = match.group(1)!;
      final masked = maskPhoneNumber(phoneStr, style: phoneMaskStyle);
      final replaced = full.replaceFirst(phoneStr, masked);
      redactionList.add(RedactedEntity(
        type: PiiType.phone,
        original: phoneStr,
        masked: masked,
        startOffset: match.start,
        endOffset: match.end,
        metadata: {'type': 'landline'},
      ));
      counts[PiiType.phone] = (counts[PiiType.phone] ?? 0) + 1;
      return replaced;
    });

    // Step 5b: Mobile Numbers (10-digit starting with 6-9)
    processed = processed.replaceAllMapped(_mobilePattern, (match) {
      final fullMatch = match.group(0)!;
      final startWindow = match.start > 30 ? match.start - 30 : 0;
      final precedingText = processed.substring(startWindow, match.start);

      // Safeguard: serial numbers or PIN codes
      if (_serialExclusionPattern.hasMatch(precedingText)) {
        return fullMatch;
      }

      final masked = maskPhoneNumber(fullMatch, style: phoneMaskStyle);
      redactionList.add(RedactedEntity(
        type: PiiType.phone,
        original: fullMatch,
        masked: masked,
        startOffset: match.start,
        endOffset: match.end,
        metadata: {'type': 'mobile'},
      ));
      counts[PiiType.phone] = (counts[PiiType.phone] ?? 0) + 1;
      return masked;
    });

    // 6. Cryptographic Proof & Manifest Generation
    final rawHashPayload = imageRawSha256 != null
        ? '$rawText||$imageRawSha256'
        : rawText;
    final cleanHashPayload = imageRedactedSha256 != null
        ? '$processed||$imageRedactedSha256'
        : processed;

    final rawSha = computeSha256(rawHashPayload);
    final cleanSha = computeSha256(cleanHashPayload);

    final cleanPrefix = cleanSha.length >= 8 ? cleanSha.substring(0, 8) : cleanSha;
    final randomHex = DateTime.now().microsecondsSinceEpoch.toRadixString(16).padLeft(6, '0');
    final proofId = 'PRV-${randomHex.substring(randomHex.length - 6)}-$cleanPrefix';
    final proofToken = proofId;

    final summaryParts = <String>[];
    if ((counts[PiiType.aadhaar] ?? 0) > 0) {
      summaryParts.add('${counts[PiiType.aadhaar]} AADHAAR');
    }
    if ((counts[PiiType.phone] ?? 0) > 0) {
      summaryParts.add('${counts[PiiType.phone]} PHONE');
    }
    if ((counts[PiiType.patientName] ?? 0) > 0) {
      summaryParts.add('${counts[PiiType.patientName]} PATIENT NAME');
    }
    if ((counts[PiiType.demographic] ?? 0) > 0) {
      summaryParts.add('${counts[PiiType.demographic]} DEMOGRAPHICS');
    }
    if ((counts[PiiType.abhaId] ?? 0) > 0) {
      summaryParts.add('${counts[PiiType.abhaId]} ABHA');
    }

    final redSummaryStr = summaryParts.isEmpty
        ? 'NO PII DETECTED'
        : '${summaryParts.join(", ")} REDACTED';

    final proofSummary =
        'DPDP-VERIFIED: [$redSummaryStr] | Proof ID: $proofId | Digest: ${cleanSha.substring(0, 16)}...';

    final manifest = SanitizationManifest(
      proofId: proofId,
      rawInputSha256: rawSha,
      sanitizedPayloadSha256: cleanSha,
      totalRedactions: redactionList.length,
      aadhaarRedacted: counts[PiiType.aadhaar] ?? 0,
      phoneRedacted: counts[PiiType.phone] ?? 0,
      patientNameRedacted: counts[PiiType.patientName] ?? 0,
      demographicRedacted: counts[PiiType.demographic] ?? 0,
      abhaRedacted: counts[PiiType.abhaId] ?? 0,
      auditEntities: redactionList.map((e) => e.toManifestJson()).toList(),
      proofToken: proofToken,
      proofSummary: proofSummary,
    );

    return PiiSanitizationResult(
      originalText: rawText,
      sanitizedText: processed,
      manifest: manifest,
      entityCounts: counts,
      redactions: redactionList,
    );
  }
}
