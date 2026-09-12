import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'first_aid_widget.dart' show FirstAidWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FirstAidModel extends FlutterFlowModel<FirstAidWidget> {
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=FirstAid',
        searchReference: 'reference=OghGaXJzdEFpZFABWghGaXJzdEFpZA==',
        widgetClassName: 'FirstAid',
      );
}
