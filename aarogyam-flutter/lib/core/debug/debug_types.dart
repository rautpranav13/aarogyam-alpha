// ignore_for_file: constant_identifier_names
// Stub debug types — replaces flutter_flow/debug_util.dart.
// All debug functionality is intentionally removed; these stubs exist so that
// existing Firestore record and model code compiles without modification.

// ignore_for_file: unused_element

/// No-op mixin; previously provided structured debug logging.
mixin DebugLoggable {}

/// Placeholder for a serialisable debug field.
class DebugDataField {
  const DebugDataField({
    this.value,
    this.type,
    this.link,
    this.name,
    this.nullable = true,
  });

  final dynamic value;
  final String? type;
  final String? link;
  final String? name;
  final bool nullable;
}

/// Enum that labels the Dart/FF type for debug serialisation.
enum ParamType {
  int,
  double,
  String,
  bool,
  DateTime,
  LatLng,
  Color,
  FFPlace,
  FFUploadedFile,
  DataStruct,
  Enum,
  Document,
  DocumentReference,
  ApiResponse,
  JSON,
  SqliteRow,
}

/// No-op serialiser — returns an empty [DebugDataField].
DebugDataField debugSerializeParam(
  dynamic value,
  ParamType paramType, {
  String? link,
  String? name,
  String? searchReference,
  bool nullable = true,
  bool isList = false,
  bool isMap = false,
}) =>
    DebugDataField(
      value: value,
      type: paramType.name,
      link: link,
      name: name,
      nullable: nullable,
    );

/// No-op — previously logged the authenticated user to the FF debug panel.
void debugLogAuthenticatedUser() {}

/// No-op — previously logged widget state to the FF debug panel.
void debugLogWidgetClass(dynamic model) {}

/// No-op — previously logged global properties to the FF debug panel.
void debugLogGlobalProperty(dynamic context, {String? locale, String? routePath, List<String>? routeStack}) {}

/// Holds widget-class-level debug metadata (no-op in production).
class WidgetClassDebugData {
  const WidgetClassDebugData({
    this.generatorVariables = const {},
    this.backendQueries = const {},
    this.componentStates = const {},
    this.widgetParameters = const {},
    this.actionOutputs = const {},
    this.widgetStates = const {},
    this.dynamicComponentStates = const {},
    this.link,
    this.searchReference,
    this.widgetClassName,
  });

  final Map<String, dynamic> generatorVariables;
  final Map<String, dynamic> backendQueries;
  final Map<String, dynamic> componentStates;
  final Map<String, dynamic> widgetParameters;
  final Map<String, dynamic> actionOutputs;
  final Map<String, dynamic> widgetStates;
  final Map<String, dynamic> dynamicComponentStates;
  final String? link;
  final String? searchReference;
  final String? widgetClassName;
}
