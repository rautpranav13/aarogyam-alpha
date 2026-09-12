import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/permissions_util.dart';
import 'response_page_widget.dart' show ResponsePageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ResponsePageModel extends FlutterFlowModel<ResponsePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - extractMedicationDetails] action in Button widget.
  dynamic _medicationjson;
  set medicationjson(dynamic value) {
    _medicationjson = value;
    debugLogWidgetClass(this);
  }

  dynamic get medicationjson => _medicationjson;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }

  @override
  void dispose() {}

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        actionOutputs: {
          'medicationjson': debugSerializeParam(
            medicationjson,
            ParamType.JSON,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ResponsePage',
            name: 'dynamic',
            nullable: true,
          )
        },
        generatorVariables: debugGeneratorVariables,
        backendQueries: debugBackendQueries,
        componentStates: {
          ...widgetBuilderComponents.map(
            (key, value) => MapEntry(
              key,
              value.toWidgetClassDebugData(),
            ),
          ),
        }.withoutNulls,
        link:
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ResponsePage',
        searchReference: 'reference=OgxSZXNwb25zZVBhZ2VQAVoMUmVzcG9uc2VQYWdl',
        widgetClassName: 'ResponsePage',
      );
}
