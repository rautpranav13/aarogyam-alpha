// test/unit/api_calls_test.dart
// Unit tests for ApiCallResponse and ApiPagingParams

import 'package:flutter_test/flutter_test.dart';
import 'package:aarogyam/backend/api_requests/api_calls.dart';
import 'package:aarogyam/flutter_flow/flutter_flow_util.dart';

void main() {
  group('ApiCallResponse', () {
    test('succeeded is true for HTTP 200', () {
      const r = ApiCallResponse({'result': 'ok'}, {}, 200);
      expect(r.succeeded, isTrue);
    });

    test('succeeded is true for HTTP 201', () {
      const r = ApiCallResponse({'id': 'new'}, {}, 201);
      expect(r.succeeded, isTrue);
    });

    test('succeeded is false for HTTP 400', () {
      const r = ApiCallResponse({'error': 'bad request'}, {}, 400);
      expect(r.succeeded, isFalse);
    });

    test('succeeded is false for HTTP 404', () {
      const r = ApiCallResponse(null, {}, 404);
      expect(r.succeeded, isFalse);
    });

    test('succeeded is false for HTTP 500', () {
      const r = ApiCallResponse({'error': 'server error'}, {}, 500);
      expect(r.succeeded, isFalse);
    });

    test('jsonBody returns the body map', () {
      final body = {'key': 'value', 'count': 5};
      final r = ApiCallResponse(body, {}, 200);
      expect(r.jsonBody, equals(body));
    });

    test('bodyText is non-null for string body', () {
      const r = ApiCallResponse('plain text response', {}, 200);
      expect(r.bodyText, isNotNull);
    });

    test('statusCode is preserved', () {
      const r = ApiCallResponse({}, {}, 403);
      expect(r.statusCode, equals(403));
    });
  });

  group('ApiPagingParams', () {
    test('default construction works', () {
      final params = ApiPagingParams(nextPageNumber: 0, numItems: 0, lastResponse: null);
      expect(params.nextPageNumber, equals(0));
      expect(params.numItems, equals(0));
    });

    test('custom values preserved', () {
      final params = ApiPagingParams(nextPageNumber: 2, numItems: 20, lastResponse: null);
      expect(params.nextPageNumber, equals(2));
      expect(params.numItems, equals(20));
    });

    test('toString includes page number', () {
      final params = ApiPagingParams(nextPageNumber: 3, numItems: 10, lastResponse: null);
      expect(params.toString(), contains('3'));
    });
  });

  group('getJsonField utility', () {
    test('extracts top-level string', () {
      final json = {'answer': 'Paracetamol', 'confidence': 0.95};
      expect(getJsonField(json, r'$.answer'), equals('Paracetamol'));
    });

    test('extracts nested value', () {
      final json = {'data': {'result': 'fever'}};
      expect(getJsonField(json, r'$.data.result'), equals('fever'));
    });

    test('returns null for missing key', () {
      final json = {'key': 'val'};
      expect(getJsonField(json, r'$.missing'), isNull);
    });

    test('returns null for null json', () {
      expect(getJsonField(null, r'$.key'), isNull);
    });

    test('extracts from list', () {
      final json = [
        {'id': 1, 'name': 'Paracetamol'},
        {'id': 2, 'name': 'Ibuprofen'}
      ];
      final result = getJsonField(json, r'$[0].name');
      expect(result, equals('Paracetamol'));
    });
  });

  group('ProcessImageAPICall static helpers', () {
    test('imageAPIresponse extracts response field', () {
      const mockResponse = ApiCallResponse(
          {'response': 'This is a medical image.'}, {}, 200);
      final extracted = ProcessImageAPICall.imageAPIresponse(mockResponse.jsonBody);
      expect(extracted, equals('This is a medical image.'));
    });
  });

  group('RagAPICall static helpers', () {
    test('ragResponsePath extracts response field', () {
      final mockBody = {'response': 'Paracetamol treats fever.'};
      final extracted = RagAPICall.ragResponsePath(mockBody);
      expect(extracted, equals('Paracetamol treats fever.'));
    });

    test('ragQueryPath extracts query field', () {
      final mockBody = {'query': 'What is Paracetamol?'};
      final extracted = RagAPICall.ragQueryPath(mockBody);
      expect(extracted, equals('What is Paracetamol?'));
    });
  });

  group('DigitizeRxAPICall static helpers', () {
    test('medicationsList extracts medication list', () {
      final mockBody = {
        'data': {
          'medications': [
            {'name': 'Metformin', 'strength': '500mg'},
            {'name': 'Amlodipine', 'strength': '5mg'}
          ]
        }
      };
      final list = DigitizeRxAPICall.medicationsList(mockBody);
      expect(list.length, equals(2));
      expect(list[0]['name'], equals('Metformin'));
    });

    test('medicationsList returns empty list for null input', () {
      final list = DigitizeRxAPICall.medicationsList(null);
      expect(list, isEmpty);
    });
  });

  group('VerifyStripAPICall static helpers', () {
    test('isVerified returns true when verified', () {
      final mockBody = {'verified': true, 'action': 'ALLOW_CONSUMPTION'};
      expect(VerifyStripAPICall.isVerified(mockBody), isTrue);
      expect(VerifyStripAPICall.action(mockBody), equals('ALLOW_CONSUMPTION'));
    });

    test('isVerified returns false when not verified', () {
      final mockBody = {'verified': false, 'action': 'BLOCK_CONSUMPTION'};
      expect(VerifyStripAPICall.isVerified(mockBody), isFalse);
      expect(VerifyStripAPICall.action(mockBody), equals('BLOCK_CONSUMPTION'));
    });

    test('detectedText and voiceAlert extraction', () {
      final mockBody = {
        'detected_text': 'METFORMIN 500MG',
        'voice_alert_vernacular': 'Verified Metformin'
      };
      expect(VerifyStripAPICall.detectedText(mockBody), equals('METFORMIN 500MG'));
      expect(VerifyStripAPICall.voiceAlert(mockBody), equals('Verified Metformin'));
    });
  });
}
