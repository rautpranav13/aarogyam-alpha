import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/utils/firestore_helpers.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

String _getBackendUrl() {
  return dotenv.env['BACKEND_URL'] ??
      dotenv.env['LVM_API_URL'] ??
      'http://localhost:5001';
}

/// Step 2: Digitize Prescription via IBM Granite Vision 3.2 2B
class DigitizeRxAPICall {
  static Future<ApiCallResponse> call({
    String? imageBase64,
    String? imageUrl,
    String? rawOcrText,
    bool ocrFailed = false,
    String language = 'hi',
  }) async {
    final Map<String, dynamic> body = {
      'language': language,
      'ocr_failed': ocrFailed,
    };
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      body['image_base64'] = imageBase64;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      body['image_url'] = imageUrl;
    }
    if (rawOcrText != null && rawOcrText.isNotEmpty) {
      body['raw_ocr_text'] = rawOcrText;
    }

    final backendUrl = _getBackendUrl();
    return ApiManager.instance.makeApiCall(
      callName: 'digitizeRxAPI',
      apiUrl: '$backendUrl/api/digitize-rx',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: jsonEncode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<dynamic> medicationsList(dynamic response) {
    final list = getJsonField(response, r'$.data.medications');
    if (list is List) return list;
    return [];
  }
}

/// Step 5: Blister Strip Verifier via IBM Granite Vision 3.2 2B
class VerifyStripAPICall {
  static Future<ApiCallResponse> call({
    String? imageBase64,
    String? imageUrl,
    String? rawOcrText,
    bool ocrFailed = false,
    required String expectedDrug,
    String expectedStrength = '',
    String language = 'hi',
  }) async {
    final Map<String, dynamic> body = {
      'expected_drug': expectedDrug,
      'expected_strength': expectedStrength,
      'language': language,
      'ocr_failed': ocrFailed,
    };
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      body['image_base64'] = imageBase64;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      body['image_url'] = imageUrl;
    }
    if (rawOcrText != null && rawOcrText.isNotEmpty) {
      body['raw_ocr_text'] = rawOcrText;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      body['image_url'] = imageUrl;
    }

    final backendUrl = _getBackendUrl();
    return ApiManager.instance.makeApiCall(
      callName: 'verifyStripAPI',
      apiUrl: '$backendUrl/api/verify-strip',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: jsonEncode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool isVerified(dynamic response) =>
      getJsonField(response, r'$.verified') == true;

  static String detectedText(dynamic response) =>
      getJsonField(response, r'$.detected_text')?.toString() ?? '';

  static String voiceAlert(dynamic response) =>
      getJsonField(response, r'$.voice_alert_vernacular')?.toString() ?? '';

  static String action(dynamic response) =>
      getJsonField(response, r'$.action')?.toString() ?? 'BLOCK_CONSUMPTION';
}

/// Step 3: Vernacular Text-to-Speech via IBM Watson TTS
class VernacularTTSAPICall {
  static Future<ApiCallResponse> call({
    required String text,
    String language = 'hi',
  }) async {
    final backendUrl = _getBackendUrl();
    return ApiManager.instance.makeApiCall(
      callName: 'vernacularTTSAPI',
      apiUrl: '$backendUrl/api/vernacular-tts',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: jsonEncode({
        'text': text,
        'language': language,
      }),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ---------------------------------------------------------------------------
// Backward-compatibility classes for legacy tests
// ---------------------------------------------------------------------------

class ProcessImageAPICall {
  static Future<ApiCallResponse> call({
    String? imageUrl,
    String? userQuery,
  }) async {
    imageUrl ??= '';
    userQuery ??= '';

    final ffApiRequestBody = '''
{
  "image_url": "${escapeStringForJson(imageUrl)}",
  "user_query": "${escapeStringForJson(userQuery)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'processImageAPI',
      apiUrl: dotenv.env['LVM_API_URL'] ?? '',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic imageAPIresponse(dynamic response) => getJsonField(
        response,
        r'''$.response''',
      );
}

class RagAPICall {
  static Future<ApiCallResponse> call({
    String? query,
  }) async {
    query ??= '';

    final ffApiRequestBody = '''
{
  "query": "${escapeStringForJson(query)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'ragAPI',
      apiUrl: dotenv.env['RAG_API_URL'] ?? '',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic ragResponsePath(dynamic response) => getJsonField(
        response,
        r'''$.response''',
      );
  static dynamic ragQueryPath(dynamic response) => getJsonField(
        response,
        r'''$.query''',
      );
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
