import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/set_reminder/set_reminder_widget.dart';
import 'switch_remainder_widget.dart' show SwitchRemainderWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SwitchRemainderModel extends FlutterFlowModel<SwitchRemainderWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Switch widget.
  bool? _switchValue;
  set switchValue(bool? value) {
    _switchValue = value;
    debugLogWidgetClass(this);
  }

  bool? get switchValue => _switchValue;

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
        widgetParameters: {
          'id': debugSerializeParam(
            widget?.id,
            ParamType.int,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=switchRemainder',
            searchReference:
                'reference=ShQKDAoCaWQSBmJmcHNyNHIECAEgAVAAWgJpZA==',
            name: 'int',
            nullable: true,
          ),
          'title': debugSerializeParam(
            widget?.title,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=switchRemainder',
            searchReference:
                'reference=ShcKDwoFdGl0bGUSBmIwYnNnb3IECAMgAVAAWgV0aXRsZQ==',
            name: 'String',
            nullable: true,
          ),
          'message': debugSerializeParam(
            widget?.message,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=switchRemainder',
            searchReference:
                'reference=ShkKEQoHbWVzc2FnZRIGamh4ZnczcgQIAyAAUABaB21lc3NhZ2U=',
            name: 'String',
            nullable: true,
          )
        }.withoutNulls,
        widgetStates: {
          'switchValue': debugSerializeParam(
            switchValue,
            ParamType.bool,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=switchRemainder',
            name: 'bool',
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=switchRemainder',
        searchReference:
            'reference=Og9zd2l0Y2hSZW1haW5kZXJQAFoPc3dpdGNoUmVtYWluZGVy',
        widgetClassName: 'switchRemainder',
      );
}
