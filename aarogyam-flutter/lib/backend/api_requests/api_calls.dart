import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/utils/firestore_helpers.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;


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
