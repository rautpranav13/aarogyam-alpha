import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/widgets/reminder/reminder_list_expanded/reminder_list_expanded_widget.dart';
import '/widgets/reminder/set_reminder/set_reminder_widget.dart';
import 'dart:ui';
import 'reminder_page_widget.dart' show ReminderPageWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReminderPageModel extends FlutterFlowModel<ReminderPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ReminderListExpanded component.
  late ReminderListExpandedModel reminderListExpandedModel;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {
    reminderListExpandedModel =
        createModel(context, () => ReminderListExpandedModel());

    debugLogWidgetClass(this);
  }

  @override
  void dispose() {
    reminderListExpandedModel.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        generatorVariables: debugGeneratorVariables,
        backendQueries: debugBackendQueries,
        componentStates: {
          'reminderListExpandedModel (ReminderListExpanded)':
              reminderListExpandedModel.toWidgetClassDebugData(),
          ...widgetBuilderComponents.map(
            (key, value) => MapEntry(
              key,
              value.toWidgetClassDebugData(),
            ),
          ),
        }.withoutNulls,
        link:
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ReminderPage',
        searchReference: 'reference=OgxSZW1pbmRlclBhZ2VQAVoMUmVtaW5kZXJQYWdl',
        widgetClassName: 'ReminderPage',
      );
}
