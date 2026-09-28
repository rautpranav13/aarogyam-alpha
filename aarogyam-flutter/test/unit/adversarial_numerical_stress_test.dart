import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/core/utils/edge_pii_sanitizer.dart';

void main() {
  group('1. Verhoeff D5 Algorithm Mathematical Integrity (Dart)', () {
    test('100% detection of adjacent digit transpositions', () {
      // Test across multiple authentic Aadhaar numbers
      final authenticNumbers = [
        '234567890124',
        '345678901238',
        '987654321096',
        '555544443333',
        '412345678902',
        '890123456784',
      ];


      int tested = 0;
      int missed = 0;

      for (final num in authenticNumbers) {
        expect(VerhoeffAlgorithm.validate(num), isTrue);
        for (int i = 0; i < 11; i++) {
          if (num[i] != num[i + 1]) {
            final transposed = num.substring(0, i) +
                num[i + 1] +
                num[i] +
                num.substring(i + 2);
            tested++;
            if (VerhoeffAlgorithm.validate(transposed)) {
              missed++;
            }
          }
        }
      }

      expect(tested, greaterThan(50));
      expect(missed, equals(0), reason: 'Verhoeff D5 must detect 100% of adjacent transpositions');
    });

    test('Empirical measurement of twin error detection rate', () {
      final authenticNumbers = [
        '234567890124',
        '345678901238',
        '987654321096',
        '555544443333',
      ];

      int tested = 0;
      int missed = 0;

      for (final num in authenticNumbers) {
        for (int i = 0; i < 11; i++) {
          if (num[i] == num[i + 1]) {
            final orig = num[i];
            for (final d in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) {
              if (d != orig) {
                final twin = num.substring(0, i) + d + d + num.substring(i + 2);
                tested++;
                if (VerhoeffAlgorithm.validate(twin)) {
                  missed++;
                }
              }
            }
          }
        }
      }

      if (tested > 0) {
        final rate = (tested - missed) / tested;
        expect(rate, greaterThanOrEqualTo(0.90));
      }
    });

    test('Empirical measurement of jump transposition detection rate', () {
      final authenticNumbers = [
        '234567890124',
        '345678901238',
        '987654321096',
        '555544443333',
      ];

      int tested = 0;
      int missed = 0;

      for (final num in authenticNumbers) {
        for (int i = 0; i < 10; i++) {
          if (num[i] != num[i + 2]) {
            final jumped = num.substring(0, i) +
                num[i + 2] +
                num[i + 1] +
                num[i] +
                num.substring(i + 3);
            tested++;
            if (VerhoeffAlgorithm.validate(jumped)) {
              missed++;
            }
          }
        }
      }

      expect(tested, greaterThan(30));
      final rate = (tested - missed) / tested;
      expect(rate, greaterThanOrEqualTo(0.90));
    });


    test('Rejects invalid leading digits 0 and 1, lengths, and boundaries', () {
      expect(VerhoeffAlgorithm.validate('000000000000'), isFalse);
      expect(VerhoeffAlgorithm.validate('111111111111'), isFalse);
      expect(VerhoeffAlgorithm.validate('012345678901'), isFalse);
      expect(VerhoeffAlgorithm.validate('123456789012'), isFalse);
      expect(VerhoeffAlgorithm.validate('23456789012'), isFalse); // 11 digits
      expect(VerhoeffAlgorithm.validate('2345678901245'), isFalse); // 13 digits
      expect(VerhoeffAlgorithm.validate(''), isFalse);
      expect(VerhoeffAlgorithm.validate('23456789ABCD'), isFalse);
    });
  });

  group('2. Pharmaceutical Batch Collision & Context Shield (Dart)', () {
    test('Preserves 12-digit Verhoeff batch numbers under standard supply chain keywords', () {
      final keywords = [
        'Batch:', 'Batch No:', 'Batch#', 'Lot:', 'Lot No:',
        'Exp:', 'Expiry:', 'Mfg:', 'GTIN:', 'Barcode:', 'Invoice:'
      ];
      // 2345 6789 0124 and 5555 4444 3333 are valid Verhoeff numbers
      // (avoiding starting with 6-9 in 3rd digit to isolate Aadhaar shield behavior)
      final codes = ['2345 6789 0124', '5555 4444 3333'];

      for (final kw in keywords) {
        for (final code in codes) {
          final text = 'Medication: Paracetamol 500mg, $kw $code';
          final result = EdgePiiSanitizer.sanitize(text);
          expect(result.entityCounts[PiiType.aadhaar], equals(0),
              reason: 'False Aadhaar masking under $kw for $code');
          expect(result.sanitizedText, contains(code),
              reason: 'Batch number was altered under $kw for $code');
        }
      }
    });

    test('Demonstrates Phone Regex Cross-Interference on contiguous 12-digit batch codes', () {
      // 987654321096 is a valid Verhoeff batch code
      const input = 'Medication: Paracetamol, Batch: 987654321096';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // Both Aadhaar and Phone masking must be suppressed:
      expect(result.entityCounts[PiiType.aadhaar], equals(0),
          reason: 'Aadhaar shield must protect batch code');
      expect(result.entityCounts[PiiType.phone], equals(0),
          reason: 'Phone regex must NOT capture inside 12-digit batch code');
      expect(result.sanitizedText, contains('987654321096'),
          reason: 'Batch code must be preserved intact');
    });

    test('Demonstrates Rx# regex word-boundary defect in Dart', () {
      const input = 'Pharmacy: Rx# 2345 6789 0124';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // Rx# must be recognized, suppressing Aadhaar masking:
      expect(result.entityCounts[PiiType.aadhaar], equals(0),
          reason: 'Rx# must successfully shield the batch code from Aadhaar masking');
      expect(result.sanitizedText, contains('2345 6789 0124'),
          reason: 'Prescription batch code under Rx# must be preserved');
    });
  });

  group('3. Indian Phone Number Edge Cases (Dart)', () {
    test('Rejects 9-digit numbers from phone masking', () {
      final cases = [
        'Call 987654321 today',
        'Call 98765 4321 today',
        'Ref: +91 987654321',
      ];
      for (final text in cases) {
        final result = EdgePiiSanitizer.sanitize(text);
        expect(result.entityCounts[PiiType.phone], equals(0));
        expect(result.sanitizedText, equals(text));
      }
    });

    test('Demonstrates 11-digit boundary defect in Dart', () {
      const input = 'Transaction Ref: 98765432101';
      final result = EdgePiiSanitizer.sanitize(input);

      // In Iteration 2 (Hardened):
      // 11-digit identifier must NOT be masked as phone:
      expect(result.entityCounts[PiiType.phone], equals(0),
          reason: '11-digit identifier must not have trailing 10 digits masked');
      expect(result.sanitizedText, equals('Transaction Ref: 98765432101'),
          reason: 'Transaction reference must be preserved intact');
    });

    test('Demonstrates non-standard spaced phone numbers LEAKING unmasked in Dart', () {
      // 4+6 format
      final res4_6 = EdgePiiSanitizer.sanitize('Call 9876 543210 immediately');
      expect(res4_6.entityCounts[PiiType.phone], equals(1),
          reason: '4+6 spaced Indian phone number must be masked');
      expect(res4_6.sanitizedText, isNot(contains('9876 543210')),
          reason: 'Raw 4+6 phone number must not leak');

      // 3+3+4 format
      final res3_3_4 = EdgePiiSanitizer.sanitize('Call 987 654 3210 immediately');
      expect(res3_3_4.entityCounts[PiiType.phone], equals(1),
          reason: '3+3+4 spaced Indian phone number must be masked');
      expect(res3_3_4.sanitizedText, isNot(contains('987 654 3210')),
          reason: 'Raw 3+3+4 phone number must not leak');
    });

    test('Demonstrates Cross-Platform V10 Phone Masking Mismatch', () {
      // In V10, Dart defaults to partial phone masking while Python uses tokenized
      const input = 'Patient Phone: +91 98765 43210';
      final dartResult = EdgePiiSanitizer.sanitize(input);
      expect(dartResult.sanitizedText, contains('+91-XXXXX-XX210'));
      expect(dartResult.sanitizedText, isNot(contains('[MASKED-PHONE-XXXX]')));
    });
  });
}
