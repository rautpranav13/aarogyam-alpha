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
        '412345678900',
        '890123456788',
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
        print('Dart Twin Error Detection: Tested=$tested, Missed=$missed, Rate=${(rate * 100).toStringAsFixed(2)}%');
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
      print('Dart Jump Transposition Detection: Tested=$tested, Missed=$missed, Rate=${(rate * 100).toStringAsFixed(2)}%');
      expect(rate, inInclusiveRange(0.90, 0.98));
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
      // When contiguous, digits 2..11 (7654321096) match _mobilePattern
      const input = 'Medication: Paracetamol, Batch: 987654321096';
      final result = EdgePiiSanitizer.sanitize(input);

      print('Dart Batch Cross-Interference: ${result.sanitizedText}');
      print('Aadhaar count: ${result.entityCounts[PiiType.aadhaar]}');
      print('Phone count: ${result.entityCounts[PiiType.phone]}');

      // Aadhaar shield worked:
      expect(result.entityCounts[PiiType.aadhaar], equals(0));
      // BUT Phone regex falsely captured trailing 10 digits:
      expect(result.entityCounts[PiiType.phone], equals(1));
      expect(result.sanitizedText, contains('98XXXXX-XX096'));
    });

    test('Demonstrates Rx# regex word-boundary defect in Dart', () {
      // In Dart, _pharmaContextPattern has 'rx#)\b'
      // '#' is non-word, space is non-word, so \b never matches
      const input = 'Pharmacy: Rx# 2345 6789 0124';
      final result = EdgePiiSanitizer.sanitize(input);

      print('Rx# test: ${result.sanitizedText}, Aadhaar count: ${result.entityCounts[PiiType.aadhaar]}');
      // Demonstrates that Rx# fails to shield the batch code from Aadhaar masking:
      expect(result.entityCounts[PiiType.aadhaar], equals(1));
      expect(result.sanitizedText, contains('XXXXXXXX0124'));
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
      // Missing leading boundary causes trailing 10 digits to be masked as phone
      const input = 'Transaction Ref: 98765432101';
      final result = EdgePiiSanitizer.sanitize(input);

      print('11-digit test: ${result.sanitizedText}, Phone count: ${result.entityCounts[PiiType.phone]}');
      // Trailing 10 digits 8765432101 matched and masked:
      expect(result.entityCounts[PiiType.phone], equals(1));
      expect(result.sanitizedText, contains('9XXXXX-XX101'));
    });

    test('Demonstrates non-standard spaced phone numbers LEAKING unmasked in Dart', () {
      // 4+6 format
      final res4_6 = EdgePiiSanitizer.sanitize('Call 9876 543210 immediately');
      print('4+6 format: "${res4_6.sanitizedText}", phone count: ${res4_6.entityCounts[PiiType.phone]}');
      expect(res4_6.entityCounts[PiiType.phone], equals(0)); // Leaked!
      expect(res4_6.sanitizedText, contains('9876 543210'));

      // 3+3+4 format
      final res3_3_4 = EdgePiiSanitizer.sanitize('Call 987 654 3210 immediately');
      print('3+3+4 format: "${res3_3_4.sanitizedText}", phone count: ${res3_3_4.entityCounts[PiiType.phone]}');
      expect(res3_3_4.entityCounts[PiiType.phone], equals(0)); // Leaked!
      expect(res3_3_4.sanitizedText, contains('987 654 3210'));
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
