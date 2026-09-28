import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/utils/firestore_helpers.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

String _getBackendUrl() {
  try {
    if (dotenv.isInitialized) {
      return dotenv.env['BACKEND_URL'] ??
          dotenv.env['LVM_API_URL'] ??
          'http://localhost:5001';
    }
  } catch (_) {}
  return 'http://localhost:5001';
}

/// Step 1: De-Identify & Redact PII via Backend Gateway
class RedactPiiAPICall {
  static Future<ApiCallResponse> call({
    required String text,
    String? patientId,
    bool generateProof = true,
  }) async {
    final Map<String, dynamic> body = {
      'text': text,
      'generate_proof': generateProof,
    };
    if (patientId != null && patientId.isNotEmpty) {
      body['patient_id'] = patientId;
    }

    final backendUrl = _getBackendUrl();
    return ApiManager.instance.makeApiCall(
      callName: 'redactPiiAPI',
      apiUrl: '$backendUrl/api/redact-pii',
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

  /// Extracts the sanitized text, falling back to legacy masked_text.
  static String sanitizedText(dynamic response) {
    final sanitized = getJsonField(response, r'$.sanitized_text');
    if (sanitized != null && sanitized.toString().isNotEmpty) {
      return sanitized.toString();
    }
    return getJsonField(response, r'$.masked_text')?.toString() ?? '';
  }

  /// Extracts entities_masked map.
  static Map<String, dynamic> entitiesMasked(dynamic response) {
    final map = getJsonField(response, r'$.entities_masked');
    if (map is Map<String, dynamic>) return map;
    if (map is Map) return Map<String, dynamic>.from(map);
    return {};
  }

  /// Number of Aadhaar numbers masked.
  static int aadhaarCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.aadhaar');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Number of phone numbers masked.
  static int phoneCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.phone');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Number of patient names de-identified.
  static int patientNameCount(dynamic response) {
    final count = getJsonField(response, r'$.entities_masked.patient_name');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  /// Total redactions count.
  static int redactionsCount(dynamic response) {
    final count = getJsonField(response, r'$.redactions_count');
    if (count is int) return count;
    if (count is num) return count.toInt();
    return aadhaarCount(response) + phoneCount(response) + patientNameCount(response);
  }

  /// Whether backend validated privacy.
  static bool privacyVerified(dynamic response) =>
      getJsonField(response, r'$.privacy_verified') == true;

  /// Returns the proof manifest object.
  static dynamic proof(dynamic response) =>
      getJsonField(response, r'$.proof') ??
      getJsonField(response, r'$.proof_manifest');

  /// Returns the manifest ID / proof ID.
  static String manifestId(dynamic response) =>
      getJsonField(response, r'$.proof.manifest_id')?.toString() ??
      getJsonField(response, r'$.proof_manifest.proof_id')?.toString() ??
      '';

  /// Pre-sanitization SHA-256 digest.
  static String preHash(dynamic response) =>
      getJsonField(response, r'$.proof.pre_hash_sha256')?.toString() ??
      getJsonField(response, r'$.proof_manifest.raw_text_sha256')?.toString() ??
      '';

  /// Post-sanitization SHA-256 digest.
  static String postHash(dynamic response) =>
      getJsonField(response, r'$.proof.post_hash_sha256')?.toString() ??
      getJsonField(response, r'$.proof_manifest.masked_text_sha256')?.toString() ??
      '';

  /// Verification proof token for UI display.
  static String proofToken(dynamic response) =>
      getJsonField(response, r'$.proof.proof_token')?.toString() ??
      getJsonField(response, r'$.proof_manifest.proof_token')?.toString() ??
      '';
}

/// Step 2: Digitize Prescription via IBM Granite Vision 3.2 2B
class DigitizeRxAPICall {
  static Future<ApiCallResponse> call({
    String? imageBase64,
    String? imageUrl,
    String? rawOcrText,
    bool ocrFailed = false,
    String language = 'hi',
    Map<String, dynamic>? piiManifest,
    bool clientSanitized = false,
  }) async {
    final Map<String, dynamic> body = {
      'language': language,
      'ocr_failed': ocrFailed,
      'client_sanitized': clientSanitized || (piiManifest != null),
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
    if (piiManifest != null && piiManifest.isNotEmpty) {
      body['pii_manifest'] = piiManifest;
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
