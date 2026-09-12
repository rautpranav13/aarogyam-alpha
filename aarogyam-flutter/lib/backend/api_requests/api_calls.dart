import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/utils/firestore_helpers.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

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
      apiUrl: dotenv.env['LVM_API_URL'] ?? 'https://ibmaarogyam.onrender.com/process-image',
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
      apiUrl: dotenv.env['RAG_API_URL'] ?? 'https://aarogyam.onrender.com/watsonchat',
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

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
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
