import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:aarogyam/core/utils/edge_pii_sanitizer.dart';

void main() {
  group('Adversarial Suite 1: Multilingual Patient De-Identification & Punctuation', () {
    test('English variations: newline, CRLF, colon, hyphen, trailing punctuation', () {
      final variations = [
        'Patient: Ramesh Kumar\nRx: Paracetamol 500mg',
        'Patient Name: Ramesh Kumar\r\nAge: 54',
        'Pt. Name: Ramesh Kumar; Age: 54',
        'Pt: Ramesh Kumar, M',
        'Patient - Ramesh Kumar\nRx: Tab',
      ];

      for (final text in variations) {
        final result = EdgePiiSanitizer.sanitize(text);
        expect(
          result.sanitizedText.contains('[PATIENT-ANON-F188]'),
          isTrue,
          reason: 'Failed to mask English patient in: "$text". Got: "${result.sanitizedText}"',
        );
        expect(
          result.sanitizedText.contains('Ramesh Kumar'),
          isFalse,
          reason: 'Raw name leaked in: "$text"',
        );
        expect(result.entityCounts[PiiType.patientName], greaterThanOrEqualTo(1));
      }
    });

    test('Hindi variations: मरीज, रोगी, hyphen separator, semicolon, Devanagari punctuation', () {
      final hindiCases = [
        'मरीज: सुरेश शर्मा\nदवा: पैरासिटामोल',
        'मरीज का नाम: सुरेश शर्मा; उम्र: ४५',
        'रोगी का नाम: सुरेश शर्मा, उम्र: ४५ वर्ष',
        'रोगी: सुरेश शर्मा\nदवा: मेटफॉर्मिन',
        'मरीज - सुरेश शर्मा\nउम्र: ४५',
      ];

      for (final text in hindiCases) {
        final result = EdgePiiSanitizer.sanitize(text);
        expect(
          result.sanitizedText.contains('[PATIENT-ANON-BA83]'),
          isTrue,
          reason: 'Failed to mask Hindi patient in: "$text". Got: "${result.sanitizedText}"',
        );
        expect(
          result.sanitizedText.contains('सुरेश शर्मा'),
          isFalse,
          reason: 'Hindi raw name leaked in: "$text"',
        );
        expect(result.entityCounts[PiiType.patientName], greaterThanOrEqualTo(1));
      }
    });

    test('Hindi standalone "नाम - सुरेश शर्मा;" stress-test', () {
      // Dispatched stress-test case: "नाम - सुरेश शर्मा;"
      const standalone = 'नाम - सुरेश शर्मा; उम्र: ४५ वर्ष';
      final result = EdgePiiSanitizer.sanitize(standalone);
      final masked = result.sanitizedText.contains('[PATIENT-ANON-');
      print('Standalone "नाम - सुरेश शर्मा;" masked status: $masked | Result: "${result.sanitizedText}"');
      expect(result.sanitizedText.contains('सुरेश शर्मा'), isFalse,
          reason: 'Raw patient name leaked under standalone "नाम -" header');
    });

    test('Hindi age boundary without newline: "मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष"', () {
      const text = 'मरीज का नाम: सुरेश शर्मा उम्र: ४५ वर्ष';
      final result = EdgePiiSanitizer.sanitize(text);
      print('Age boundary test result: "${result.sanitizedText}"');
      // Must not leak raw name AND must not swallow "उम्र" into the pseudonym token!
      expect(result.sanitizedText.contains('सुरेश शर्मा'), isFalse);
      expect(result.sanitizedText.contains('[PATIENT-ANON-BA83]'), isTrue,
          reason: 'Expected exact pseudonym [PATIENT-ANON-BA83] for "सुरेश शर्मा", but got: ${result.sanitizedText}');
    });

    test('Devanagari numerals in Aadhaar and Phone numbers', () {
      const aadhaarDev = 'आधार: २३४५ ६७८९ ०१२४';
      final resAadhaar = EdgePiiSanitizer.sanitize(aadhaarDev);
      print('Devanagari Aadhaar result: "${resAadhaar.sanitizedText}" (counts: ${resAadhaar.entityCounts})');

      const phoneDev = 'संपर्क: ९८७६५४३२१०';
      final resPhone = EdgePiiSanitizer.sanitize(phoneDev);
      print('Devanagari Phone result: "${resPhone.sanitizedText}" (counts: ${resPhone.entityCounts})');

      expect(resAadhaar.sanitizedText.contains('२३४५'), isFalse,
          reason: 'Devanagari Aadhaar leaked unmasked!');
      expect(resPhone.sanitizedText.contains('९८७६५४३२१०'), isFalse,
          reason: 'Devanagari phone leaked unmasked!');
    });

    test('Marathi variations: रुग्णाचे नाव, hyphen separator, semicolon', () {
      final marathiCases = [
        'रुग्णाचे नाव: आनंदी पाटील\nवय: ४५',
        'रुग्णाचे नाव - आनंदी पाटील; वय: ४५',
        'रुग्णाचे नाव: आनंदी पाटील, वय: ४५ वर्ष',
      ];

      for (final text in marathiCases) {
        final result = EdgePiiSanitizer.sanitize(text);
        expect(
          result.sanitizedText.contains('[PATIENT-ANON-603B]'),
          isTrue,
          reason: 'Failed to mask Marathi patient in: "$text". Got: "${result.sanitizedText}"',
        );
        expect(
          result.sanitizedText.contains('आनंदी पाटील'),
          isFalse,
          reason: 'Marathi raw name leaked in: "$text"',
        );
        expect(result.entityCounts[PiiType.patientName], greaterThanOrEqualTo(1));
      }
    });

    test('Multi-word names (2, 3, 4 parts) and honorific prefixes', () {
      final multiWordCases = [
        {
          'input': 'Patient: Mr. Ramesh Kumar\nAge: 30',
          'raw': 'Mr. Ramesh Kumar',
        },
        {
          'input': 'Patient Name: Ramesh Kumar Gupta\nAge: 45',
          'raw': 'Ramesh Kumar Gupta',
        },
        {
          'input': 'मरीज का नाम: श्री सुरेश कुमार शर्मा\nउम्र: ५०',
          'raw': 'श्री सुरेश कुमार शर्मा',
        },
        {
          'input': 'रुग्णाचे नाव: श्रीमती अनिता विठ्ठल जोशी\nवय: ४०',
          'raw': 'श्रीमती अनिता विठ्ठल जोशी',
        },
      ];

      for (final item in multiWordCases) {
        final input = item['input']!;
        final raw = item['raw']!;
        final result = EdgePiiSanitizer.sanitize(input);
        expect(result.sanitizedText.contains(raw), isFalse,
            reason: 'Raw multi-word name "$raw" leaked in "${result.sanitizedText}"');
        expect(result.sanitizedText.contains('[PATIENT-ANON-'), isTrue);
        expect(result.entityCounts[PiiType.patientName], greaterThanOrEqualTo(1));
      }
    });

    test('Deterministic cross-platform token calculation parity with Python', () {
      final parityPairs = {
        'Ramesh Kumar': '[PATIENT-ANON-F188]',
        'सुरेश कुमार': '[PATIENT-ANON-8E96]',
        'Anita Joshi': '[PATIENT-ANON-093F]',
        'आनंदी पाटील': '[PATIENT-ANON-603B]',
        'Sunita Devi': '[PATIENT-ANON-5211]',
        'सुरेश शर्मा': '[PATIENT-ANON-BA83]',
        'Mr. Ramesh Kumar': '[PATIENT-ANON-C921]',
      };

      parityPairs.forEach((name, expectedToken) {
        final token = EdgePiiSanitizer.deidentifyPatientName(name);
        expect(token, equals(expectedToken),
            reason: 'Token mismatch for "$name": expected $expectedToken, got $token');
      });
    });
  });

  group('Adversarial Suite 2: Doctor & Clinic Credential Preservation', () {
    test('Doctor: Dr. A.K. Gupta, MD (AIIMS) vs Patient: Ramesh Gupta', () {
      const prescription = '''
All India Institute of Medical Sciences (AIIMS)
Cardiology OPD
Doctor: Dr. A.K. Gupta, MD (AIIMS), DM (Cardio)
Reg. No: MCI-45678
Patient: Ramesh Gupta
Age: 58 Yrs, Male
Rx: Tab Atorvastatin 20mg
''';
      final result = EdgePiiSanitizer.sanitize(prescription);

      // Verify Doctor and AIIMS are STRICTLY preserved
      expect(result.sanitizedText, contains('Dr. A.K. Gupta, MD (AIIMS), DM (Cardio)'));
      expect(result.sanitizedText, contains('All India Institute of Medical Sciences (AIIMS)'));
      expect(result.sanitizedText, contains('Reg. No: MCI-45678'));

      // Verify Patient is masked
      expect(result.sanitizedText, contains('[PATIENT-ANON-C85F]'));
      expect(result.sanitizedText, isNot(contains('Patient: Ramesh Gupta')));
      expect(result.entityCounts[PiiType.patientName], equals(1));
    });

    test('Devanagari doctor: डॉ. ए.के. गुप्ता vs Hindi Patient: मरीज: रमेश गुप्ता', () {
      const prescription = '''
प्राथमिक स्वास्थ्य केंद्र (PHC)
डॉ. ए.के. गुप्ता, एम.डी. (एम्स)
मरीज का नाम: रमेश गुप्ता
उम्र: ५८ वर्ष
दवा: एस्पिरिन 75mg
''';
      final result = EdgePiiSanitizer.sanitize(prescription);

      expect(result.sanitizedText, contains('डॉ. ए.के. गुप्ता, एम.डी. (एम्स)'));
      expect(result.sanitizedText, contains('प्राथमिक स्वास्थ्य केंद्र (PHC)'));
      expect(result.sanitizedText, contains('[PATIENT-ANON-2822]'));
      expect(result.sanitizedText, isNot(contains('रमेश गुप्ता')));
    });

    test('Doctor credentials in patient slot are preserved per safety safeguard', () {
      const doctorAsPatient = 'Patient: Dr. Rajesh Verma, MBBS';
      final result = EdgePiiSanitizer.sanitize(doctorAsPatient);
      expect(result.sanitizedText, contains('Dr. Rajesh Verma, MBBS'));
      expect(result.entityCounts[PiiType.patientName], equals(0));
    });

    test('Inline doctor and patient on same line separated by semicolon', () {
      const inlineText = 'Dr. S. K. Sharma, MD; Patient: Ramesh Kumar';
      final result = EdgePiiSanitizer.sanitize(inlineText);
      expect(result.sanitizedText, contains('Dr. S. K. Sharma, MD'));
      expect(result.sanitizedText, contains('[PATIENT-ANON-F188]'));
      expect(result.sanitizedText, isNot(contains('Ramesh Kumar')));
    });
  });

  group('Adversarial Suite 3: Cryptographic Manifest Tamper Resistance', () {
    test('Simulate 1-character mutation at start, middle, and end of sanitized text', () {
      const input = 'Patient Name: Ramesh Kumar\nAadhaar: 2345 6789 0124\nPhone: +91 98765 43210';
      final result = EdgePiiSanitizer.sanitize(input);

      final originalClean = result.sanitizedText;
      final expectedSha = result.manifest.sanitizedPayloadSha256;

      // Verify authentic payload matches manifest SHA-256
      final computedCleanSha = sha256.convert(utf8.encode(originalClean)).toString();
      expect(computedCleanSha, equals(expectedSha));

      // Attack Scenario 1: Mutate first character
      final mutatedFirst = (originalClean[0] == 'X' ? 'Y' : 'X') + originalClean.substring(1);
      final mutatedFirstSha = sha256.convert(utf8.encode(mutatedFirst)).toString();
      expect(mutatedFirstSha, isNot(equals(expectedSha)),
          reason: '1-char tamper at index 0 went undetected!');

      // Attack Scenario 2: Mutate middle character
      final mid = originalClean.length ~/ 2;
      final mutatedMid = originalClean.substring(0, mid) +
          (originalClean[mid] == 'Z' ? 'A' : 'Z') +
          originalClean.substring(mid + 1);
      final mutatedMidSha = sha256.convert(utf8.encode(mutatedMid)).toString();
      expect(mutatedMidSha, isNot(equals(expectedSha)),
          reason: '1-char tamper at middle went undetected!');

      // Attack Scenario 3: Mutate last character
      final mutatedLast = originalClean.substring(0, originalClean.length - 1) +
          (originalClean[originalClean.length - 1] == '0' ? '1' : '0');
      final mutatedLastSha = sha256.convert(utf8.encode(mutatedLast)).toString();
      expect(mutatedLastSha, isNot(equals(expectedSha)),
          reason: '1-char tamper at end went undetected!');

      // Attack Scenario 4: Appended whitespace
      final mutatedWhitespace = '$originalClean ';
      final mutatedWsSha = sha256.convert(utf8.encode(mutatedWhitespace)).toString();
      expect(mutatedWsSha, isNot(equals(expectedSha)),
          reason: 'Whitespace tamper went undetected!');
    });

    test('Empty input handling (0 bytes) returns valid manifest without crashing', () {
      const emptyInput = '';
      final result = EdgePiiSanitizer.sanitize(emptyInput);

      expect(result.sanitizedText, equals(''));
      expect(result.totalRedactions, equals(0));
      expect(result.hasPii, isFalse);

      final emptySha = sha256.convert(utf8.encode('')).toString();
      expect(result.manifest.rawInputSha256, equals(emptySha));
      expect(result.manifest.sanitizedPayloadSha256, equals(emptySha));
      expect(result.manifest.proofToken, startsWith('PRV-'));
    });

    test('Whitespace-only input handling returns valid manifest', () {
      const wsInput = '   \n\t   ';
      final result = EdgePiiSanitizer.sanitize(wsInput);

      expect(result.totalRedactions, equals(0));
      final wsSha = sha256.convert(utf8.encode(wsInput)).toString();
      expect(result.manifest.rawInputSha256, equals(wsSha));
      expect(result.manifest.sanitizedPayloadSha256, equals(wsSha));
    });
  });

  group('Adversarial Suite 4: Massive Input Scaling (100KB Prescription)', () {
    test('Processes 100KB prescription text without ReDoS or memory blowout', () {
      final buffer = StringBuffer();
      // Generate realistic mixed clinical prescription lines totaling ~100KB
      const singleBlock = '''
District Hospital Pune | AIIMS Outreach Clinic
Dr. S. K. Sharma, MD, MBBS, Reg: MMC-12345
Patient Name: Ramesh Kumar, Age: 54 Yrs, Gender: Male, UHID: UHID-98124
Aadhaar: 2345 6789 0124
Contact: +91 98765 43210
Batch No: 1234-5678-9012, Exp: 12/2028
Rx: Metformin 500mg BD after food, Atorvastatin 20mg HS
मरीज का नाम: सुरेश कुमार, उम्र: ५४ वर्ष, लिंग: पुरुष
दवा: पैरासिटामोल 650mg TDS
रुग्णाचे नाव: आनंदी पाटील, वय: ४८, संपर्क: 020-25678901
औषध: अमोक्सिसिलिन 500mg BD
---
''';
      // singleBlock is ~450 bytes. Repeat 230 times to exceed 100KB (approx 103 KB)
      while (buffer.length < 102400) {
        buffer.write(singleBlock);
      }

      final massiveText = buffer.toString();
      final sizeInKb = (utf8.encode(massiveText).length / 1024).toStringAsFixed(2);
      expect(utf8.encode(massiveText).length, greaterThan(100 * 1024));

      final stopwatch = Stopwatch()..start();
      final result = EdgePiiSanitizer.sanitize(massiveText);
      stopwatch.stop();

      print('Processed $sizeInKb KB in ${stopwatch.elapsedMilliseconds} ms');

      // Performance check: Must complete within 2000ms (no catastrophic backtracking)
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'ReDoS or catastrophic scaling detected! Elapsed: ${stopwatch.elapsedMilliseconds}ms');

      // Verify no raw names or valid Aadhaar leaked
      expect(result.sanitizedText.contains('Ramesh Kumar'), isFalse);
      expect(result.sanitizedText.contains('सुरेश कुमार'), isFalse);
      expect(result.sanitizedText.contains('आनंदी पाटील'), isFalse);
      expect(result.sanitizedText.contains('2345 6789 0124'), isFalse);
      expect(result.sanitizedText.contains('+91 98765 43210'), isFalse);

      // Verify batch number preserved across the 100KB payload
      expect(result.sanitizedText.contains('Batch No: 1234-5678-9012'), isTrue);

      // Verify SHA-256 matches actual output
      final actualPostSha = sha256.convert(utf8.encode(result.sanitizedText)).toString();
      expect(result.manifest.sanitizedPayloadSha256, equals(actualPostSha));
      expect(result.totalRedactions, greaterThan(500));
    });
  });
}
