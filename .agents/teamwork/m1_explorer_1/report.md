# Architectural & Implementation Design Report: Flutter Edge PII Sanitizer

**Component**: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`  
**Test Suite**: `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`  
**Author**: Milestone 1 Explorer 1 (Flutter Edge PII Sanitizer)  
**Date**: 2026-09-28  
**Compliance Standards**: Digital Personal Data Protection Act 2023 (DPDP Act, India §8), HIPAA Safe Harbor (45 CFR § 164.514), Ayushman Bharat Digital Mission (ABDM) Health Data Management Policy.

---

## 1. Executive Architectural Overview

In the Aarogyam hybrid edge-cloud vision processing pipeline, prescription slips and medicine foils captured by the Flutter mobile client (`aarogyam-flutter`) are transcribed on-device via Google ML Kit OCR. When ML Kit confidence falls below acceptable thresholds (e.g. illegible handwriting or short text < 15 characters), payloads must be escalated to the IBM WatsonX Granite Vision 3.2 2B cloud multimodal model.

Transmitting unredacted clinical artifacts or raw OCR text directly to cloud vision endpoints introduces critical privacy and compliance liabilities under the **Digital Personal Data Protection Act 2023 (DPDP Act)** and **HIPAA Safe Harbor**. Prescription slips routinely contain highly sensitive personal identifiers:
- 12-digit UIDAI Aadhaar numbers
- 10-digit Indian mobile and clinic landline contact numbers
- 14-digit ABHA (Ayushman Bharat Health Account) IDs
- Patient names, ages, gender, and Unique Hospital Identifiers (UHID / OPD slip numbers)

The **`EdgePiiSanitizer`** utility provides a deterministic, zero-dependency (using only Flutter's existing `crypto: ^3.0.5` package), on-device redaction engine. It sanitizes text before network transmission and produces a tamper-evident **`SanitizationManifest`** containing SHA-256 pre/post cryptographic hashes.

```
[ Camera Capture ] 
       │
       ▼
[ MLKitOcrService ] (Extracts raw OCR text)
       │
       ▼
[ EdgePiiSanitizer.sanitize() ]
  ├── 1. Multilingual Patient De-Identification ([PATIENT-ANON-XXXX])
  │      └── Doctor & Clinic Exclusion Safeguards (Preserve Dr. & Hospital names)
  ├── 2. Demographic Redaction (Age, Gender, UHID, ABHA)
  ├── 3. Verhoeff D5 Checksum Aadhaar Masking (XXXXXXXX1234)
  │      └── Medicine Batch / Lot Number False-Positive Protection
  ├── 4. Indian Mobile (+91, 0, 5+5) & Landline STD Masking
  └── 5. SHA-256 Pre/Post Digest & SanitizationManifest Generation
       │
       ▼
[ DigitizeRxAPICall.call() ] (Cloud Dispatch with Clean Payload & Proof Token)
       │
       ▼
[ MedicationStorageService ] & [ _buildPrivacyBadge UI ] (Verified Proof)
```

---

## 2. Core Algorithmic Specifications & Mathematical Foundations

### 2.1 The Verhoeff Checksum Algorithm ($D_5$ Dihedral Group)

The 12th digit of a UIDAI Aadhaar number is a checksum calculated using the dihedral group $D_5$ (symmetries of a regular pentagon). Unlike standard Luhn ($D_1$ modulo 10) checks, Verhoeff detects **100% of all single-digit transcription errors** and **100% of all adjacent two-digit transposition errors** (e.g., swapping `45` to `54`), along with over 95% of jump transpositions (e.g., `4_5` to `5_4`).

The algorithm relies on three constant lookup tables:
1. **Multiplication table ($d_{10 \times 10}$)**: The Cayley table representing the non-abelian dihedral group $D_5$.
2. **Permutation table ($p_{8 \times 10}$)**: Successive permutations applied to digit positions modulo 8.
3. **Inversion table ($inv_{10}$)**: The inverse elements under operation $d$.

#### Table 1: Multiplication Table ($d_{10 \times 10}$)
```dart
const List<List<int>> d = [
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
```

#### Table 2: Permutation Table ($p_{8 \times 10}$)
```dart
const List<List<int>> p = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];
```

#### Table 3: Inversion Table ($inv_{10}$)
```dart
const List<int> inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];
```

#### Mathematical Validation Procedure
Given a 12-digit string $S = s_0 s_1 \dots s_{11}$:
1. Strip all non-digit characters. Verify that length equals 12 and the leading digit $s_0 \in [2, 9]$ (UIDAI regulation: numbers starting with `0` or `1` are never issued).
2. Reverse the string: $R = \text{reverse}(S) = r_0 r_1 \dots r_{11}$, where $r_0$ is the 12th digit (checksum).
3. Initialize accumulator $c = 0$.
4. For $i \in [0, 11]$:
   $$c = d[c][p[i \pmod 8][\text{int}(r_i)]]$$
5. Valid if and only if $c == 0$.

#### Checksum Generation Procedure
Given an 11-digit prefix $P = p_0 p_1 \dots p_{10}$:
1. Reverse prefix: $R = \text{reverse}(P) = r_0 r_1 \dots r_{10}$.
2. Initialize $c = 0$.
3. For $i \in [0, 10]$:
   $$c = d[c][p[(i + 1) \pmod 8][\text{int}(r_i)]]$$
4. Checksum digit $= inv[c]$.

---

### 2.2 Aadhaar False Positive Prevention (Pharmaceutical Batch Safeguard)

In a clinical OCR setting, pharmaceutical blister packaging and prescription notes frequently feature 12-digit numbers that are NOT Aadhaar identifiers:
- Medicine batch/lot numbers: e.g. `Batch No: 1234-5678-9012` or `Lot: 3675 9834 5212`
- GTIN barcodes and invoice tracking IDs
- Expiry timestamps and serial numbers

Because random 12-digit numbers have an inherent $10\%$ probability of passing the Verhoeff checksum by pure coincidence, relying on checksum validation alone causes severe false-positive redaction of critical medication metadata!

#### Safeguard Rules:
1. **Explicit Aadhaar Label**: If preceded by an explicit label within 40 characters (`Aadhaar`, `Aadhar`, `Adhar`, `UID`, `UIDAI`, `आधार`, `आधार क्र.`), mask immediately.
2. **Contextual Keyword Exclusion**: If preceded by pharmaceutical/supply chain keywords (`Batch`, `Lot`, `Exp`, `Expiry`, `Mfg`, `Barcode`, `GTIN`, `Invoice`, `Ref`, `Item`, `SN`, `Serial`) and lacks an explicit Aadhaar label, **DO NOT REDACT**.
3. **Structural Format**: Must start with digits $2..9$. Numbers starting with 0 or 1 are immediately rejected.
4. **Masking Format**: Formatted as `XXXXXXXX${last4}` (e.g., `3675 9834 5212` $\to$ `XXXXXXXX5212`), preserving the audit trail without revealing the 8 identifying digits.

---

### 2.3 Indian Phone Number Detection & Masking

Compliant with Department of Telecommunications (DoT) National Numbering Plan (NNP):
- **Mobile Numbers**:
  - Exactly 10 digits starting with `6, 7, 8, or 9`.
  - Common prefixes: `+91`, `+91-`, `0091`, `91 `, or trunk `0`.
  - Delimiters: Contiguous (`9876543210`), $5+5$ Indian banking standard (`98765 43210`, `98765-43210`), or $3+3+4$ (`987-654-3210`).
  - Serial Number Rejection: 10-digit serial numbers starting with `1..5` (e.g. `SN: 5432109876`) or preceded by `SN:`, `PIN:`, `Invoice:` are preserved.
- **Clinic Landline Numbers**:
  - Contextual keyword required (`tel`, `telephone`, `phone`, `ph`, `contact`, `call`, `फोन`, `संपर्क`, `दूरध्वनी`).
  - STD codes (2-4 digits starting with 0, such as `011` Delhi, `022` Mumbai, `020` Pune, `080` Bengaluru) followed by 6-8 digit subscriber numbers.
- **Masking Format**:
  - Mobile: `+91-XXXXX-XX${last3}` (e.g. `+91-XXXXX-XX210`) or `XXXXX-XX${last3}`.
  - Landline: `[MASKED-PHONE-XXXX]`.

---

### 2.4 Multilingual Patient Name De-Identification & Doctor Safeguard

Prescriptions must preserve the legitimacy of healthcare providers and medical facilities while scrubbing patient identifying details.

#### Entities to Preserve (Doctor & Hospital Safeguard):
- Salutations and titles: `Dr.`, `Dr`, `Doctor`, `डॉ.`, `डॉ`, `वैद्य`, `Prof.`, `Professor`
- Medical credentials: `MBBS`, `MD`, `MS`, `BAMS`, `BHMS`, `BDS`, `FRCS`, `DM`, `MCh`, `DGO`, `DNB`
- Medical council registrations: `Reg No`, `MCI`, `MMC`
- Facility types: `Hospital`, `Clinic`, `Dispensary`, `Health Centre`, `PHC`, `CHC`, `AIIMS`, `Nursing Home`, `रुग्णालय`, `दवाखाना`, `अस्पताल`, `आरोग्य केंद्र`

#### Entities to De-Identify:
- Patient Name: Anchored by demographic indicators:
  - English: `Patient Name`, `Pt. Name`, `Pt Name`, `Patient`, `Pt:`
  - Hindi: `मरीज का नाम`, `रोगी का नाम`, `मरीज`, `रोगी`
  - Marathi: `रुग्णाचे नाव`, `रुग्ण`
- Replaced with synthetic pseudonym: `[PATIENT-ANON-<4-HEX-HASH>]` (e.g., `[PATIENT-ANON-F188]`), derived deterministically from the SHA-256 hash of the patient name. This ensures that repeated occurrences in the same document correlate to the same pseudonym while remaining strictly non-reversible.
- Associated Demographics:
  - Age (`Age: 54 Yrs`, `उम्र: ५४ वर्ष`, `वय: ३८`) $\to$ `Age: [REDACTED]`
  - Gender (`Gender: Male`, `Sex: F`, `लिंग: पुरुष`) $\to$ `Gender: [REDACTED]`
  - UHID / OPD Slip (`UHID: 98124`, `OPD No: 4421`) $\to$ `UHID: [REDACTED]`

#### Critical Dart RegExp Technical Finding:
In Dart's standard `RegExp` engine:
1. **Inline mode flags like `(?i)` are UNSUPPORTED** and throw a fatal `FormatException: Invalid group` at runtime. Case-insensitivity must be declared via the constructor parameter `caseSensitive: false`.
2. **ASCII word boundary `\b` fails on Devanagari text**: In standard regex, `\b` defines a boundary between `\w` (`[A-Za-z0-9_]`) and non-word characters. Because Devanagari characters are outside ASCII `\w`, regexes like `\b(लिंग|उम्र|वय)\b` fail to match when surrounded by spaces or punctuation.
3. **Digit `\d` does not match Indic numerals**: `\d` matches only ASCII `[0-9]`, failing on Devanagari numerals `[०-९]` (`\u0966-\u096F`).
4. **Resolution**: All multilingual patterns must use explicit boundary groupings `(?:^|[\s,;:\n])` and include `[0-9\u0966-\u096F]` with `unicode: true`.

---

### 2.5 Cryptographic Audit Manifest & SHA-256 Verification

To satisfy DPDP Act 2023 Section 8 and ABDM Audit Logging:
1. **Pre-Sanitization Digest**:
   $$\text{Digest}_{\text{raw}} = \text{SHA256}(\text{RawOCRText} \parallel \text{ImageRawSHA256})$$
2. **Post-Sanitization Digest**:
   $$\text{Digest}_{\text{clean}} = \text{SHA256}(\text{SanitizedText} \parallel \text{RedactedImageSHA256})$$
3. **Tamper-Evident Proof Token**:
   $$\text{ProofToken} = \text{"PRV-" } \parallel \text{MicrosecondHex} \parallel \text{"-" } \parallel \text{Digest}_{\text{clean}}[:8]$$
4. **Verification Security Invariant**:
   The `SanitizationManifest` records strictly cryptographic hashes, entity counts, character spans, and masked values. It **NEVER stores raw PII strings** in the export JSON.

---

## 3. Production Implementation: `edge_pii_sanitizer.dart`

File path: `aarogyam-flutter/lib/core/utils/edge_pii_sanitizer.dart`

```dart
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
    r'\b(?:aadhaar|aadhar|adhar|uid|uidai|आधार(?:\s*क्र\.?)?)\s*[:\-\s]*([0-9]{4}[\s\-]?[0-9]{4}[\s\-]?[0-9]{4})\b',
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
      final has91 = phone.contains('+91') || digits.length > 10;
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
```

---

## 4. Test Suite Specification: `test/unit/edge_pii_sanitizer_test.dart`

File path: `aarogyam-flutter/test/unit/edge_pii_sanitizer_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/core/utils/edge_pii_sanitizer.dart';

void main() {
  group('VerhoeffAlgorithm Mathematical Integrity Tests', () {
    test('Validates authentic 12-digit Aadhaar numbers', () {
      // 36759834521 with checksum 2
      expect(VerhoeffAlgorithm.validate('367598345212'), isTrue);
      // Valid Aadhaar starting with 2..9
      const pfx = '21834927561';
      final chk = VerhoeffAlgorithm.generateChecksum(pfx);
      expect(VerhoeffAlgorithm.validate('$pfx$chk'), isTrue);
    });

    test('Rejects adjacent digit transpositions', () {
      // Transposition of digits at positions 4 and 5
      expect(VerhoeffAlgorithm.validate('367589345212'), isFalse);
    });

    test('Rejects jump transpositions', () {
      // Swapping 7 and 9 across distance
      expect(VerhoeffAlgorithm.validate('397598345212'), isFalse);
    });

    test('Rejects invalid leading digits (0 and 1)', () {
      final chk0 = VerhoeffAlgorithm.generateChecksum('06759834521');
      expect(VerhoeffAlgorithm.validate('06759834521$chk0'), isFalse);

      final chk1 = VerhoeffAlgorithm.generateChecksum('16759834521');
      expect(VerhoeffAlgorithm.validate('16759834521$chk1'), isFalse);
    });

    test('Rejects numbers with invalid lengths', () {
      expect(VerhoeffAlgorithm.validate('12345'), isFalse);
      expect(VerhoeffAlgorithm.validate('1234567890123'), isFalse);
    });
  });

  group('Aadhaar Redaction & False Positive Prevention Tests', () {
    test('Masks valid Aadhaar numbers to XXXXXXXX1234', () {
      final input = 'Patient Aadhaar: 3675 9834 5212 for registration.';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXXXXX5212'));
      expect(result.sanitizedText, isNot(contains('3675 9834 5212')));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });

    test('Safeguards pharmaceutical batch numbers from false-positive masking', () {
      final input = 'Paracetamol 650mg, Batch Number: 1234-5678-9012, Exp: 12/28';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('1234-5678-9012'));
      expect(result.sanitizedText, isNot(contains('XXXXXXXX')));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('Preserves batch number even if digits pass Verhoeff', () {
      final input = 'Lot No: 3675 9834 5212 Mfg: 05/2026';
      final result = EdgePiiSanitizer.sanitize(input);

      // Preceded by Lot No keyword -> should NOT be masked as Aadhaar
      expect(result.sanitizedText, contains('3675 9834 5212'));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('Masks explicitly labeled Aadhaar even with hyphens', () {
      final input = 'UIDAI: 3675-9834-5212 verified.';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXXXXX5212'));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });
  });

  group('Indian Phone Number Masking Tests', () {
    test('Masks standard +91 Indian mobile number', () {
      final input = 'Contact: +91 98765 43210 for emergency';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('+91-XXXXX-XX210'));
      expect(result.sanitizedText, isNot(contains('98765 43210')));
      expect(result.entityCounts[PiiType.phone], equals(1));
    });

    test('Masks bare 10-digit mobile number with 5+5 spacing', () {
      final input = 'Call 98765 43210 immediately';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXX-XX210'));
      expect(result.entityCounts[PiiType.phone], equals(1));
    });

    test('Masks clinic landline numbers with STD code', () {
      final input = 'Hospital Phone: 020-25678901, Desk Tel: 011 23456789';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXX-XX901'));
      expect(result.sanitizedText, contains('XXXXX-XX789'));
      expect(result.entityCounts[PiiType.phone], equals(2));
    });

    test('Does not mask serial numbers starting with 1-5', () {
      final input = 'Device SN: 5432109876, PIN: 411001';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('5432109876'));
      expect(result.entityCounts[PiiType.phone], equals(0));
    });
  });

  group('Multilingual Patient De-Identification & Doctor Safeguard Tests', () {
    test('Sanitizes English patient name while preserving Doctor and Hospital', () {
      final input = '''
District Hospital Pune
Dr. S. K. Sharma, MD, MBBS, Reg: MMC-12345
Patient Name: Ramesh Kumar, Age: 54 Yrs, Gender: Male, UHID: 98124
Rx: Metformin 500mg
''';
      final result = EdgePiiSanitizer.sanitize(input);

      // Doctor and hospital must be preserved
      expect(result.sanitizedText, contains('District Hospital Pune'));
      expect(result.sanitizedText, contains('Dr. S. K. Sharma, MD, MBBS'));
      expect(result.sanitizedText, contains('MMC-12345'));

      // Patient demographics must be de-identified
      expect(result.sanitizedText, contains('[PATIENT-ANON-'));
      expect(result.sanitizedText, isNot(contains('Ramesh Kumar')));
      expect(result.sanitizedText, contains('Age: [REDACTED]'));
      expect(result.sanitizedText, contains('Gender: [REDACTED]'));
      expect(result.sanitizedText, contains('UHID: [REDACTED]'));

      // Clinical prescription content preserved
      expect(result.sanitizedText, contains('Metformin 500mg'));
    });

    test('Sanitizes Hindi patient name while preserving Hindi doctor and hospital', () {
      final input = '''
प्राथमिक स्वास्थ्य केंद्र
डॉ. राजेश वर्मा, एम.डी.
मरीज का नाम: सुरेश कुमार, उम्र: ५४ वर्ष, लिंग: पुरुष
दवा: पैरासिटामोल 650mg
''';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('प्राथमिक स्वास्थ्य केंद्र'));
      expect(result.sanitizedText, contains('डॉ. राजेश वर्मा, एम.डी.'));
      expect(result.sanitizedText, contains('[PATIENT-ANON-'));
      expect(result.sanitizedText, isNot(contains('सुरेश कुमार')));
      expect(result.sanitizedText, contains('पैरासिटामोल 650mg'));
    });

    test('Sanitizes Marathi patient name while preserving Marathi doctor', () {
      final input = '''
प्राथमिक आरोग्य केंद्र शिरूर
डॉ. अमोल जोशी, एम.बी.बी.एस.
रुग्णाचे नाव: आनंदी पाटील, वय: ३८
संपर्क: 020-25678901
औषध: अमोक्सिसिलिन 500mg
''';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('प्राथमिक आरोग्य केंद्र शिरूर'));
      expect(result.sanitizedText, contains('डॉ. अमोल जोशी'));
      expect(result.sanitizedText, contains('[PATIENT-ANON-'));
      expect(result.sanitizedText, isNot(contains('आनंदी पाटील')));
      expect(result.sanitizedText, contains('अमोक्सिसिलिन 500mg'));
    });
  });

  group('Cryptographic Sanitization Manifest & SHA-256 Tests', () {
    test('Generates valid 64-char SHA-256 digests and proof token', () {
      final input = 'Patient Name: Anita Roy, Phone: 9876543210';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.manifest.rawInputSha256.length, equals(64));
      expect(result.manifest.sanitizedPayloadSha256.length, equals(64));
      expect(result.manifest.rawInputSha256, isNot(equals(result.manifest.sanitizedPayloadSha256)));
      expect(result.manifest.proofToken, startsWith('PRV-'));
      expect(result.manifest.proofSummary, contains('DPDP-VERIFIED'));
      expect(result.hasPii, isTrue);
    });

    test('Pre-hash equals post-hash when no PII is present', () {
      final cleanText = 'Paracetamol 500mg 1-0-1 after food for 5 days';
      final result = EdgePiiSanitizer.sanitize(cleanText);

      expect(result.manifest.rawInputSha256, equals(result.manifest.sanitizedPayloadSha256));
      expect(result.totalRedactions, equals(0));
      expect(result.hasPii, isFalse);
      expect(result.manifest.proofSummary, contains('NO PII DETECTED'));
    });

    test('Manifest JSON does not expose raw PII values', () {
      final input = 'Patient Name: Suresh Patil, Aadhaar: 3675 9834 5212';
      final result = EdgePiiSanitizer.sanitize(input);
      final manifestJson = result.manifest.toJson();

      final manifestString = manifestJson.toString();
      expect(manifestString, isNot(contains('Suresh Patil')));
      expect(manifestString, isNot(contains('3675 9834 5212')));
    });
  });
}
```

---

## 5. Downstream Integration Guide for Milestone 1 Implementer

### 5.1 Integrating with `ReportSannerWidget`
In `aarogyam-flutter/lib/main_pages/report_sanner/report_sanner_widget.dart`:
```dart
// Import edge PII sanitizer
import '/core/utils/edge_pii_sanitizer.dart';

// In _digitizeWithGraniteVision():
Future<void> _digitizeWithGraniteVision() async {
  final vernService = Provider.of<VernacularService>(context, listen: false);
  setState(() => _model.isDigitizing = true);

  final rawOcr = _model.rawOcrText ?? '';
  
  // 1. Execute edge on-device PII sanitization
  final sanitization = EdgePiiSanitizer.sanitize(rawOcr);
  final cleanOcrText = sanitization.sanitizedText;
  _redactedProof = sanitization.manifest.proofSummary;

  final isOcrFailed = cleanOcrText.trim().length < 15;

  try {
    final response = await DigitizeRxAPICall.call(
      imageBase64: _model.imageBase64,
      rawOcrText: cleanOcrText,
      ocrFailed: isOcrFailed,
      language: vernService.langCode,
    );
    // ...
```

### 5.2 Storage Persistence in `PrescriptionRecord`
In `aarogyam-flutter/lib/core/models/medication_schedule.dart`:
`PrescriptionRecord.redactedPiiProof` already takes a `String`. By assigning `sanitization.manifest.proofSummary`, the verified cryptographic proof token `PRV-XXXX-XXXX` is stored in SQLite and displayed in the `_buildPrivacyBadge` container without requiring schema migrations.
