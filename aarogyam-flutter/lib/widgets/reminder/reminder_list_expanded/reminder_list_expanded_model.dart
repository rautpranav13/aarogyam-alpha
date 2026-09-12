import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/switch_remainder/switch_remainder_widget.dart';
import 'dart:ui';
import 'reminder_list_expanded_widget.dart' show ReminderListExpandedWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReminderListExpandedModel
    extends FlutterFlowModel<ReminderListExpandedWidget> {
  ///  State fields for stateful widgets in this component.

  // Models for switchRemainder dynamic component.
  late FlutterFlowDynamicModels<SwitchRemainderModel> switchRemainderModels;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {
    switchRemainderModels =
        FlutterFlowDynamicModels(() => SwitchRemainderModel());
  }

  @override
  void dispose() {
    switchRemainderModels.dispose();
  }

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
        dynamicComponentStates: {
          'switchRemainderModels (List<switchRemainder>)':
              switchRemainderModels.toDynamicWidgetClassDebugData(),
        }.withoutNulls,
        link:
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ReminderListExpanded',
        searchReference:
            'reference=OhRSZW1pbmRlckxpc3RFeHBhbmRlZFAAWhRSZW1pbmRlckxpc3RFeHBhbmRlZA==',
        widgetClassName: 'ReminderListExpanded',
      );
}
