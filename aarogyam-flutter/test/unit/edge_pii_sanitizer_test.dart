import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/core/utils/edge_pii_sanitizer.dart';
import 'package:aarogyam/backend/api_requests/api_calls.dart';

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
      const input = 'Patient Aadhaar: 3675 9834 5212 for registration.';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXXXXX5212'));
      expect(result.sanitizedText, isNot(contains('3675 9834 5212')));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });

    test('Safeguards pharmaceutical batch numbers from false-positive masking', () {
      const input = 'Paracetamol 650mg, Batch Number: 1234-5678-9012, Exp: 12/28';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('1234-5678-9012'));
      expect(result.sanitizedText, isNot(contains('XXXXXXXX')));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('Preserves batch number even if digits pass Verhoeff', () {
      const input = 'Lot No: 3675 9834 5212 Mfg: 05/2026';
      final result = EdgePiiSanitizer.sanitize(input);

      // Preceded by Lot No keyword -> should NOT be masked as Aadhaar
      expect(result.sanitizedText, contains('3675 9834 5212'));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('Masks explicitly labeled Aadhaar even with hyphens', () {
      const input = 'UIDAI: 3675-9834-5212 verified.';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXXXXX5212'));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });
  });

  group('Indian Phone Number Masking Tests', () {
    test('Masks standard +91 Indian mobile number', () {
      const input = 'Contact: +91 98765 43210 for emergency';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('+91-XXXXX-XX210'));
      expect(result.sanitizedText, isNot(contains('98765 43210')));
      expect(result.entityCounts[PiiType.phone], equals(1));
    });

    test('Masks bare 10-digit mobile number with 5+5 spacing', () {
      const input = 'Call 98765 43210 immediately';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXX-XX210'));
      expect(result.entityCounts[PiiType.phone], equals(1));
    });

    test('Masks clinic landline numbers with STD code', () {
      const input = 'Hospital Phone: 020-25678901, Desk Tel: 011 23456789';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('XXXXX-XX901'));
      expect(result.sanitizedText, contains('XXXXX-XX789'));
      expect(result.entityCounts[PiiType.phone], equals(2));
    });

    test('Does not mask serial numbers starting with 1-5', () {
      const input = 'Device SN: 5432109876, PIN: 411001';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('5432109876'));
      expect(result.entityCounts[PiiType.phone], equals(0));
    });
  });

  group('Multilingual Patient De-Identification & Doctor Safeguard Tests', () {
    test('Sanitizes English patient name while preserving Doctor and Hospital', () {
      const input = '''
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
      const input = '''
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
      const input = '''
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
      const input = 'Patient Name: Anita Roy, Phone: 9876543210';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.manifest.rawInputSha256.length, equals(64));
      expect(result.manifest.sanitizedPayloadSha256.length, equals(64));
      expect(result.manifest.rawInputSha256, isNot(equals(result.manifest.sanitizedPayloadSha256)));
      expect(result.manifest.proofToken, startsWith('PRV-'));
      expect(result.manifest.proofSummary, contains('DPDP-VERIFIED'));
      expect(result.hasPii, isTrue);
    });

    test('Pre-hash equals post-hash when no PII is present', () {
      const cleanText = 'Paracetamol 500mg 1-0-1 after food for 5 days';
      final result = EdgePiiSanitizer.sanitize(cleanText);

      expect(result.manifest.rawInputSha256, equals(result.manifest.sanitizedPayloadSha256));
      expect(result.totalRedactions, equals(0));
      expect(result.hasPii, isFalse);
      expect(result.manifest.proofSummary, contains('NO PII DETECTED'));
    });

    test('Manifest JSON does not expose raw PII values', () {
      const input = 'Patient Name: Suresh Patil, Aadhaar: 3675 9834 5212';
      final result = EdgePiiSanitizer.sanitize(input);
      final manifestJson = result.manifest.toJson();

      final manifestString = manifestJson.toString();
      expect(manifestString, isNot(contains('Suresh Patil')));
      expect(manifestString, isNot(contains('3675 9834 5212')));
    });
  });

  group('RedactPiiAPICall static helpers', () {
    test('sanitizedText extracts sanitized_text and falls back to masked_text', () {
      final mockBody1 = {'sanitized_text': 'Sanitized prescription', 'status': 'success'};
      expect(RedactPiiAPICall.sanitizedText(mockBody1), equals('Sanitized prescription'));

      final mockBody2 = {'masked_text': 'Masked prescription', 'status': 'success'};
      expect(RedactPiiAPICall.sanitizedText(mockBody2), equals('Masked prescription'));

      expect(RedactPiiAPICall.sanitizedText(null), equals(''));
    });

    test('entitiesMasked and entity counters extract correct values', () {
      final mockBody = {
        'entities_masked': {
          'aadhaar': 2,
          'phone': 1,
          'patient_name': 1,
        },
        'redactions_count': 4,
        'privacy_verified': true,
      };
      expect(RedactPiiAPICall.aadhaarCount(mockBody), equals(2));
      expect(RedactPiiAPICall.phoneCount(mockBody), equals(1));
      expect(RedactPiiAPICall.patientNameCount(mockBody), equals(1));
      expect(RedactPiiAPICall.redactionsCount(mockBody), equals(4));
      expect(RedactPiiAPICall.privacyVerified(mockBody), isTrue);
    });

    test('proof helper extracts manifest details and digests', () {
      final mockBody = {
        'proof': {
          'manifest_id': 'manifest-uuid-1234',
          'pre_hash_sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
          'post_hash_sha256': '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
          'proof_token': 'PRV-1234-4a5e1e4b',
        }
      };
      expect(RedactPiiAPICall.manifestId(mockBody), equals('manifest-uuid-1234'));
      expect(RedactPiiAPICall.preHash(mockBody), contains('e3b0c442'));
      expect(RedactPiiAPICall.postHash(mockBody), contains('4a5e1e4b'));
      expect(RedactPiiAPICall.proofToken(mockBody), equals('PRV-1234-4a5e1e4b'));
    });
  });

  group('Canonical Cross-Platform Test Vectors (V1-V10)', () {
    test('V1: Valid Aadhaar (spaced)', () {
      const input = 'Patient Aadhaar: 2345 6789 0124';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('XXXXXXXX0124'));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });

    test('V2: Valid Aadhaar (hyphenated)', () {
      const input = 'UID: 2345-6789-0124';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('XXXXXXXX0124'));
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
    });

    test('V3: Batch Number Protection', () {
      const input = 'Batch Number: 1234-5678-9012 Exp: 12/2026';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('1234-5678-9012'));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('V4: Aadhaar Transposition Error rejection', () {
      const input = 'Ref: 2346 5789 0124';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('2346 5789 0124'));
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
    });

    test('V5: Indian Mobile (+91 format)', () {
      const input = 'Contact: +91 98765 43210';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('+91-XXXXX-XX210'));
      expect(result.entityCounts[PiiType.phone], equals(1));
    });

    test('V6: Serial Number Rejection', () {
      const input = 'Device SN: 5432109876, Lot: 4567';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('5432109876'));
      expect(result.entityCounts[PiiType.phone], equals(0));
    });

    test('V7: English Patient Name deterministic token', () {
      const input = 'Patient Name: Ramesh Kumar, Age: 54';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('[PATIENT-ANON-F188]'));
      expect(result.sanitizedText, isNot(contains('Ramesh Kumar')));
      expect(result.entityCounts[PiiType.patientName], equals(1));
    });

    test('V8: Hindi Patient Name deterministic token', () {
      const input = 'मरीज का नाम: सुरेश कुमार, उम्र: ४५ वर्ष';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, contains('[PATIENT-ANON-8E96]'));
      expect(result.sanitizedText, isNot(contains('सुरेश कुमार')));
      expect(result.entityCounts[PiiType.patientName], equals(1));
    });

    test('V9: Doctor & Clinic Safeguard', () {
      const input = 'Dr. S. K. Sharma, MD, Community Health Centre, AIIMS';
      final result = EdgePiiSanitizer.sanitize(input);
      expect(result.sanitizedText, equals(input));
      expect(result.hasPii, isFalse);
    });

    test('V10: Composite Full Prescription', () {
      const input = '''
Dr. Rajesh Verma, MBBS
Apex Clinic
Patient: Ramesh Kumar
Ph: +91 98765 43210
Aadhaar: 2345 6789 0124
Batch: 1234-5678-9012
Rx: Paracetamol 500mg
''';
      final result = EdgePiiSanitizer.sanitize(input);

      expect(result.sanitizedText, contains('Dr. Rajesh Verma, MBBS'));
      expect(result.sanitizedText, contains('Apex Clinic'));
      expect(result.sanitizedText, contains('[PATIENT-ANON-F188]'));
      expect(result.sanitizedText, contains('+91-XXXXX-XX210'));
      expect(result.sanitizedText, contains('XXXXXXXX0124'));
      expect(result.sanitizedText, contains('Batch: 1234-5678-9012'));
      expect(result.sanitizedText, contains('Rx: Paracetamol 500mg'));

      expect(result.entityCounts[PiiType.aadhaar], equals(1));
      expect(result.entityCounts[PiiType.phone], equals(1));
      expect(result.entityCounts[PiiType.patientName], equals(1));
    });
  });
}
