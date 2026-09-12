import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/reminder_empty/reminder_empty_widget.dart';
import 'dart:ui';
import 'reminder_list_collapsed_widget.dart' show ReminderListCollapsedWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReminderListCollapsedModel
    extends FlutterFlowModel<ReminderListCollapsedWidget> {
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ReminderListCollapsed',
        searchReference:
            'reference=OhVSZW1pbmRlckxpc3RDb2xsYXBzZWRQAFoVUmVtaW5kZXJMaXN0Q29sbGFwc2Vk',
        widgetClassName: 'ReminderListCollapsed',
      );
}
