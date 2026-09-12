import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'custom_query_widget.dart' show CustomQueryWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomQueryModel extends FlutterFlowModel<CustomQueryWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for titleTextfield widget.
  FocusNode? titleTextfieldFocusNode;
  TextEditingController? titleTextfieldTextController;
  String? Function(BuildContext, String?)?
      titleTextfieldTextControllerValidator;
  // State field(s) for queryTextfield widget.
  FocusNode? queryTextfieldFocusNode;
  TextEditingController? queryTextfieldTextController;
  String? Function(BuildContext, String?)?
      queryTextfieldTextControllerValidator;

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
  void dispose() {
    titleTextfieldFocusNode?.dispose();
    titleTextfieldTextController?.dispose();

    queryTextfieldFocusNode?.dispose();
    queryTextfieldTextController?.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        widgetStates: {
          'titleTextfieldText': debugSerializeParam(
            titleTextfieldTextController?.text,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=CustomQuery',
            name: 'String',
            nullable: true,
          ),
          'queryTextfieldText': debugSerializeParam(
            queryTextfieldTextController?.text,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=CustomQuery',
            name: 'String',
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=CustomQuery',
        searchReference: 'reference=OgtDdXN0b21RdWVyeVABWgtDdXN0b21RdWVyeQ==',
        widgetClassName: 'CustomQuery',
      );
}
