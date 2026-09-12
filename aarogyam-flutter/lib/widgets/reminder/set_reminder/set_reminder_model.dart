import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'set_reminder_widget.dart' show SetReminderWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SetReminderModel extends FlutterFlowModel<SetReminderWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  DateTime? datePicked;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        widgetParameters: {
          'title': debugSerializeParam(
            widget?.title,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=setReminder',
            searchReference:
                'reference=ShcKDwoFdGl0bGUSBjh6MnFjbHIECAMgAFAAWgV0aXRsZQ==',
            name: 'String',
            nullable: true,
          ),
          'description': debugSerializeParam(
            widget?.description,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=setReminder',
            searchReference:
                'reference=Sh0KFQoLZGVzY3JpcHRpb24SBjR4bWM1YXIECAMgAFAAWgtkZXNjcmlwdGlvbg==',
            name: 'String',
            nullable: true,
          ),
          'id': debugSerializeParam(
            widget?.id,
            ParamType.int,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=setReminder',
            searchReference:
                'reference=ShoKDAoCaWQSBnI0bHF6aSoEEgI0OXIECAEgAVAAWgJpZA==',
            name: 'int',
            nullable: false,
          )
        }.withoutNulls,
        widgetStates: {
          'textFieldText1': debugSerializeParam(
            textController1?.text,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=setReminder',
            name: 'String',
            nullable: true,
          ),
          'textFieldText2': debugSerializeParam(
            textController2?.text,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=setReminder',
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=setReminder',
        searchReference: 'reference=OgtzZXRSZW1pbmRlclAAWgtzZXRSZW1pbmRlcg==',
        widgetClassName: 'setReminder',
      );
}
