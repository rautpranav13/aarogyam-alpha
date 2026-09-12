import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'a_i_disclaimer_widget.dart' show AIDisclaimerWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AIDisclaimerModel extends FlutterFlowModel<AIDisclaimerWidget> {
  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=AIDisclaimer',
        searchReference: 'reference=OgxBSURpc2NsYWltZXJQAFoMQUlEaXNjbGFpbWVy',
        widgetClassName: 'AIDisclaimer',
      );
}
