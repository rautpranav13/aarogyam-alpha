// Utility functions previously scattered across flutter_flow_util.dart and
// firestore_util.dart, now consolidated here.

import 'dart:convert';

// ---------------------------------------------------------------------------
// getCurrentTimestamp
// ---------------------------------------------------------------------------

/// Returns the current UTC time as a [DateTime].
DateTime get getCurrentTimestamp => DateTime.now().toUtc();

// ---------------------------------------------------------------------------
// getJsonField
// ---------------------------------------------------------------------------

/// Traverses [response] using a JsonPath-like [jsonPath] and returns the
/// matching value(s).  Supports basic dot notation and array wildcards ([*]).
/// Returns [null] when the path doesn't match.
dynamic getJsonField(
  dynamic response,
  String jsonPath, [
  bool isForList = false,
]) {
  try {
    final parts = _parseJsonPath(jsonPath);
    dynamic current = response;
    for (final part in parts) {
      if (current == null) return null;
      if (part == '*') {
        if (current is List) {
          current = current;
        } else if (current is Map) {
          current = current.values.toList();
        } else {
          return null;
        }
      } else if (current is List) {
        final idx = int.tryParse(part);
        if (idx != null) {
          current = current[idx];
        } else {
          // Map over list items
          current = current
              .map((e) => e is Map ? e[part] : null)
              .where((e) => e != null)
              .toList();
        }
      } else if (current is Map) {
        current = current[part];
      } else if (current is String) {
        try {
          current = json.decode(current);
          // Retry with the decoded value
          final decoded = current;
          if (decoded is Map) {
            current = decoded[part];
          } else {
            return null;
          }
        } catch (_) {
          return null;
        }
      } else {
        return null;
      }
    }
    if (isForList) {
      return current is List ? current : (current != null ? [current] : []);
    }
    return current;
  } catch (e) {
    return null;
  }
}

/// Converts a simple JsonPath expression (e.g. `$.foo.bar[*].baz`) into
/// a list of path segments.
List<String> _parseJsonPath(String jsonPath) {
  // Strip leading "$." or "$["
  var path = jsonPath;
  if (path.startsWith(r'$')) path = path.substring(1);
  if (path.startsWith('.')) path = path.substring(1);

  final segments = <String>[];
  final regex = RegExp(r'\[(\*|\d+)\]|([^.\[]+)');
  for (final match in regex.allMatches(path)) {
    if (match.group(1) != null) {
      segments.add(match.group(1)!);
    } else if (match.group(2) != null) {
      segments.add(match.group(2)!);
    }
  }
  return segments;
}

// ---------------------------------------------------------------------------
// castToType
// ---------------------------------------------------------------------------

/// Casts [value] to [T], returning [null] on failure.
T? castToType<T>(dynamic value) {
  if (value == null) return null;
  try {
    return value as T;
  } catch (_) {}
  // Try common conversions
  try {
    if (T == int && value is num) return value.toInt() as T;
    if (T == double && value is num) return value.toDouble() as T;
    if (T == String) return value.toString() as T;
  } catch (_) {}
  return null;
}
